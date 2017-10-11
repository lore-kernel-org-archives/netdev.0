From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH net-next 2/3] sched: act: ife: migrate to use per-cpu counters
Date: Wed, 11 Oct 2017 17:16:07 -0400
Message-ID: <20171011211608.22692-3-aring@mojatatu.com>
References: <20171011211608.22692-1-aring@mojatatu.com>
Cc: xiyou.wangcong@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, bjb@mojatatu.com,
        Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:48120 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752531AbdJKVQl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:16:41 -0400
Received: by mail-io0-f196.google.com with SMTP id h70so3296556ioi.4
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:16:40 -0700 (PDT)
In-Reply-To: <20171011211608.22692-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch migrates the current counter handling which is protected by a
spinlock to a per-cpu counter handling. This reduce the time where the
spinlock is being held.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 net/sched/act_ife.c | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index efac8a32c30a..f0d86b182387 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -463,7 +463,7 @@ static int tcf_ife_init(struct net *net, struct nlattr *nla,
 
 	if (!exists) {
 		ret = tcf_idr_create(tn, parm->index, est, a, &act_ife_ops,
-				     bind, false);
+				     bind, true);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
@@ -624,19 +624,15 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 	u8 *tlv_data;
 	u16 metalen;
 
-	spin_lock(&ife->tcf_lock);
-	bstats_update(&ife->tcf_bstats, skb);
+	bstats_cpu_update(this_cpu_ptr(ife->common.cpu_bstats), skb);
 	tcf_lastuse_update(&ife->tcf_tm);
-	spin_unlock(&ife->tcf_lock);
 
 	if (skb_at_tc_ingress(skb))
 		skb_push(skb, skb->dev->hard_header_len);
 
 	tlv_data = ife_decode(skb, &metalen);
 	if (unlikely(!tlv_data)) {
-		spin_lock(&ife->tcf_lock);
-		ife->tcf_qstats.drops++;
-		spin_unlock(&ife->tcf_lock);
+		qstats_drop_inc(this_cpu_ptr(ife->common.cpu_qstats));
 		return TC_ACT_SHOT;
 	}
 
@@ -654,14 +650,12 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 			 */
 			pr_info_ratelimited("Unknown metaid %d dlen %d\n",
 					    mtype, dlen);
-			ife->tcf_qstats.overlimits++;
+			qstats_overlimit_inc(this_cpu_ptr(ife->common.cpu_qstats));
 		}
 	}
 
 	if (WARN_ON(tlv_data != ifehdr_end)) {
-		spin_lock(&ife->tcf_lock);
-		ife->tcf_qstats.drops++;
-		spin_unlock(&ife->tcf_lock);
+		qstats_drop_inc(this_cpu_ptr(ife->common.cpu_qstats));
 		return TC_ACT_SHOT;
 	}
 
@@ -713,23 +707,20 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 			exceed_mtu = true;
 	}
 
-	spin_lock(&ife->tcf_lock);
-	bstats_update(&ife->tcf_bstats, skb);
+	bstats_cpu_update(this_cpu_ptr(ife->common.cpu_bstats), skb);
 	tcf_lastuse_update(&ife->tcf_tm);
 
 	if (!metalen) {		/* no metadata to send */
 		/* abuse overlimits to count when we allow packet
 		 * with no metadata
 		 */
-		ife->tcf_qstats.overlimits++;
-		spin_unlock(&ife->tcf_lock);
+		qstats_overlimit_inc(this_cpu_ptr(ife->common.cpu_qstats));
 		return action;
 	}
 	/* could be stupid policy setup or mtu config
 	 * so lets be conservative.. */
 	if ((action == TC_ACT_SHOT) || exceed_mtu) {
-		ife->tcf_qstats.drops++;
-		spin_unlock(&ife->tcf_lock);
+		qstats_drop_inc(this_cpu_ptr(ife->common.cpu_qstats));
 		return TC_ACT_SHOT;
 	}
 
@@ -738,6 +729,8 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 
 	ife_meta = ife_encode(skb, metalen);
 
+	spin_lock(&ife->tcf_lock);
+
 	/* XXX: we dont have a clever way of telling encode to
 	 * not repeat some of the computations that are done by
 	 * ops->presence_check...
@@ -749,8 +742,8 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 		}
 		if (err < 0) {
 			/* too corrupt to keep around if overwritten */
-			ife->tcf_qstats.drops++;
 			spin_unlock(&ife->tcf_lock);
+			qstats_drop_inc(this_cpu_ptr(ife->common.cpu_qstats));
 			return TC_ACT_SHOT;
 		}
 		skboff += err;
-- 
2.11.0
