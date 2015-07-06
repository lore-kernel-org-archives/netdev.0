From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v3 net-next 6/7] net_sched: act_gact: remove spinlock in fast path
Date: Mon,  6 Jul 2015 05:18:08 -0700
Message-ID: <1436185089-18268-7-git-send-email-edumazet@google.com>
References: <1436185089-18268-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:36594 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755318AbbGFMSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 08:18:39 -0400
Received: by iecvh10 with SMTP id vh10so111931952iec.3
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 05:18:38 -0700 (PDT)
In-Reply-To: <1436185089-18268-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Final step for gact RCU operation :

1) Use percpu stats
2) update lastuse only every clock tick to avoid false sharing
3) Remove spinlock acquisition, as it is no longer needed.

Since this is the last contended lock in packet RX when tc gact is used,
this gives impressive gain.

My host with 8 RX queues was handling 5 Mpps before the patch,
and more than 11 Mpps after patch.

Tested:

On receiver :

dev=eth0
tc qdisc del dev $dev ingress 2>/dev/null
tc qdisc add dev $dev ingress
tc filter del dev $dev root pref 10 2>/dev/null
tc filter del dev $dev pref 10 2>/dev/null
tc filter add dev $dev est 1sec 4sec parent ffff: protocol ip prio 1 \
	u32 match ip src 7.0.0.0/8 flowid 1:15 action drop

Sender sends packets flood from 7/8 network

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 include/net/act_api.h | 11 +++++++++++
 net/sched/act_gact.c  | 17 +++++++----------
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index db2063ffd181..8d2a707a9e87 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -70,6 +70,17 @@ static inline void tcf_hashinfo_destroy(struct tcf_hashinfo *hf)
 	kfree(hf->htab);
 }
 
+/* Update lastuse only if needed, to avoid dirtying a cache line.
+ * We use a temp variable to avoid fetching jiffies twice.
+ */
+static inline void tcf_lastuse_update(struct tcf_t *tm)
+{
+	unsigned long now = jiffies;
+
+	if (tm->lastuse != now)
+		tm->lastuse = now;
+}
+
 #ifdef CONFIG_NET_CLS_ACT
 
 #define ACT_P_CREATED 1
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index e4eb88d3d8dc..5c1b05170736 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -90,7 +90,7 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 
 	if (!tcf_hash_check(parm->index, a, bind)) {
 		ret = tcf_hash_create(parm->index, est, a, sizeof(*gact),
-				      bind, false);
+				      bind, true);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
@@ -104,7 +104,7 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 
 	gact = to_gact(a);
 
-	spin_lock_bh(&gact->tcf_lock);
+	ASSERT_RTNL();
 	gact->tcf_action = parm->action;
 #ifdef CONFIG_GACT_PROB
 	if (p_parm) {
@@ -117,7 +117,6 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 		gact->tcfg_ptype   = p_parm->ptype;
 	}
 #endif
-	spin_unlock_bh(&gact->tcf_lock);
 	if (ret == ACT_P_CREATED)
 		tcf_hash_insert(a);
 	return ret;
@@ -127,9 +126,8 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
 		    struct tcf_result *res)
 {
 	struct tcf_gact *gact = a->priv;
-	int action = gact->tcf_action;
+	int action = READ_ONCE(gact->tcf_action);
 
-	spin_lock(&gact->tcf_lock);
 #ifdef CONFIG_GACT_PROB
 	{
 	u32 ptype = READ_ONCE(gact->tcfg_ptype);
@@ -138,12 +136,11 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
 		action = gact_rand[ptype](gact);
 	}
 #endif
-	gact->tcf_bstats.bytes += qdisc_pkt_len(skb);
-	gact->tcf_bstats.packets++;
+	bstats_cpu_update(this_cpu_ptr(gact->common.cpu_bstats), skb);
 	if (action == TC_ACT_SHOT)
-		gact->tcf_qstats.drops++;
-	gact->tcf_tm.lastuse = jiffies;
-	spin_unlock(&gact->tcf_lock);
+		qstats_drop_inc(this_cpu_ptr(gact->common.cpu_qstats));
+
+	tcf_lastuse_update(&gact->tcf_tm);
 
 	return action;
 }
-- 
2.4.3.573.g4eafbef
