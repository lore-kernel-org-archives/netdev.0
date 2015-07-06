From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 2/7] net: sched: add percpu stats to actions
Date: Sun,  5 Jul 2015 23:41:27 -0700
Message-ID: <1436164896-8243-3-git-send-email-edumazet@google.com>
References: <1436164896-8243-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35811 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbbGFGrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 02:47:31 -0400
Received: by iecuq6 with SMTP id uq6so107344170iec.2
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 23:47:30 -0700 (PDT)
In-Reply-To: <1436164896-8243-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reuse existing percpu infrastructure John Fastabend added for qdisc.

This patch adds a new cpustats parameter to tcf_hash_create() and all
actions pass false, meaning this patch should have no effect yet.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: John Fastabend <john.fastabend@gmail.com>
---
 include/net/act_api.h    |  4 +++-
 net/sched/act_api.c      | 44 ++++++++++++++++++++++++++++++++++----------
 net/sched/act_bpf.c      |  2 +-
 net/sched/act_connmark.c |  3 ++-
 net/sched/act_csum.c     |  3 ++-
 net/sched/act_gact.c     |  3 ++-
 net/sched/act_ipt.c      |  2 +-
 net/sched/act_mirred.c   |  3 ++-
 net/sched/act_nat.c      |  3 ++-
 net/sched/act_pedit.c    |  3 ++-
 net/sched/act_simple.c   |  3 ++-
 net/sched/act_skbedit.c  |  3 ++-
 net/sched/act_vlan.c     |  3 ++-
 13 files changed, 57 insertions(+), 22 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 3ee4c92afd1b..db2063ffd181 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -21,6 +21,8 @@ struct tcf_common {
 	struct gnet_stats_rate_est64	tcfc_rate_est;
 	spinlock_t			tcfc_lock;
 	struct rcu_head			tcfc_rcu;
+	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
+	struct gnet_stats_queue __percpu *cpu_qstats;
 };
 #define tcf_head	common.tcfc_head
 #define tcf_index	common.tcfc_index
@@ -103,7 +105,7 @@ int tcf_hash_release(struct tc_action *a, int bind);
 u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo);
 int tcf_hash_check(u32 index, struct tc_action *a, int bind);
 int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
-		    int size, int bind);
+		    int size, int bind, bool cpustats);
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
 void tcf_hash_insert(struct tc_action *a);
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index af427a3dbcba..074a32f466f8 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -27,6 +27,15 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 
+static void free_tcf(struct rcu_head *head)
+{
+	struct tcf_common *p = container_of(head, struct tcf_common, tcfc_rcu);
+
+	free_percpu(p->cpu_bstats);
+	free_percpu(p->cpu_qstats);
+	kfree(p);
+}
+
 void tcf_hash_destroy(struct tc_action *a)
 {
 	struct tcf_common *p = a->priv;
@@ -41,7 +50,7 @@ void tcf_hash_destroy(struct tc_action *a)
 	 * gen_estimator est_timer() might access p->tcfc_lock
 	 * or bstats, wait a RCU grace period before freeing p
 	 */
-	kfree_rcu(p, tcfc_rcu);
+	call_rcu(&p->tcfc_rcu, free_tcf);
 }
 EXPORT_SYMBOL(tcf_hash_destroy);
 
@@ -230,15 +239,16 @@ void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est)
 	if (est)
 		gen_kill_estimator(&pc->tcfc_bstats,
 				   &pc->tcfc_rate_est);
-	kfree_rcu(pc, tcfc_rcu);
+	call_rcu(&pc->tcfc_rcu, free_tcf);
 }
 EXPORT_SYMBOL(tcf_hash_cleanup);
 
 int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
-		    int size, int bind)
+		    int size, int bind, bool cpustats)
 {
 	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = kzalloc(size, GFP_KERNEL);
+	int err = -ENOMEM;
 
 	if (unlikely(!p))
 		return -ENOMEM;
@@ -246,18 +256,32 @@ int tcf_hash_create(u32 index, struct nlattr *est, struct tc_action *a,
 	if (bind)
 		p->tcfc_bindcnt = 1;
 
+	if (cpustats) {
+		p->cpu_bstats = netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
+		if (!p->cpu_bstats) {
+err1:
+			kfree(p);
+			return err;
+		}
+		p->cpu_qstats = alloc_percpu(struct gnet_stats_queue);
+		if (!p->cpu_qstats) {
+err2:
+			free_percpu(p->cpu_bstats);
+			goto err1;
+		}
+	}
 	spin_lock_init(&p->tcfc_lock);
 	INIT_HLIST_NODE(&p->tcfc_head);
 	p->tcfc_index = index ? index : tcf_hash_new_index(hinfo);
 	p->tcfc_tm.install = jiffies;
 	p->tcfc_tm.lastuse = jiffies;
 	if (est) {
-		int err = gen_new_estimator(&p->tcfc_bstats, NULL,
-					    &p->tcfc_rate_est,
-					    &p->tcfc_lock, est);
+		err = gen_new_estimator(&p->tcfc_bstats, p->cpu_bstats,
+					&p->tcfc_rate_est,
+					&p->tcfc_lock, est);
 		if (err) {
-			kfree(p);
-			return err;
+			free_percpu(p->cpu_qstats);
+			goto err2;
 		}
 	}
 
@@ -615,10 +639,10 @@ int tcf_action_copy_stats(struct sk_buff *skb, struct tc_action *a,
 	if (err < 0)
 		goto errout;
 
-	if (gnet_stats_copy_basic(&d, NULL, &p->tcfc_bstats) < 0 ||
+	if (gnet_stats_copy_basic(&d, p->cpu_bstats, &p->tcfc_bstats) < 0 ||
 	    gnet_stats_copy_rate_est(&d, &p->tcfc_bstats,
 				     &p->tcfc_rate_est) < 0 ||
-	    gnet_stats_copy_queue(&d, NULL,
+	    gnet_stats_copy_queue(&d, p->cpu_qstats,
 				  &p->tcfc_qstats,
 				  p->tcfc_qstats.qlen) < 0)
 		goto errout;
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1d56903fd4c7..99aa271633e9 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -281,7 +281,7 @@ static int tcf_bpf_init(struct net *net, struct nlattr *nla,
 
 	if (!tcf_hash_check(parm->index, act, bind)) {
 		ret = tcf_hash_create(parm->index, est, act,
-				      sizeof(*prog), bind);
+				      sizeof(*prog), bind, false);
 		if (ret < 0)
 			goto destroy_fp;
 
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 295d14bd6c67..f2b540220ad0 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -108,7 +108,8 @@ static int tcf_connmark_init(struct net *net, struct nlattr *nla,
 	parm = nla_data(tb[TCA_CONNMARK_PARMS]);
 
 	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*ci), bind);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*ci),
+				      bind, false);
 		if (ret)
 			return ret;
 
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 4cd5cf1aedf8..b07c535ba8e7 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -62,7 +62,8 @@ static int tcf_csum_init(struct net *n, struct nlattr *nla, struct nlattr *est,
 	parm = nla_data(tb[TCA_CSUM_PARMS]);
 
 	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*p),
+				      bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 7fffc2272701..a4f8af29ee30 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -85,7 +85,8 @@ static int tcf_gact_init(struct net *net, struct nlattr *nla,
 #endif
 
 	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*gact), bind);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*gact),
+				      bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index cbc8dd7dd48a..99c9cc1c7af9 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -114,7 +114,7 @@ static int tcf_ipt_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 		index = nla_get_u32(tb[TCA_IPT_INDEX]);
 
 	if (!tcf_hash_check(index, a, bind) ) {
-		ret = tcf_hash_create(index, est, a, sizeof(*ipt), bind);
+		ret = tcf_hash_create(index, est, a, sizeof(*ipt), bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index a42a3b257226..002cd6c83dc6 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -93,7 +93,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	if (!tcf_hash_check(parm->index, a, bind)) {
 		if (dev == NULL)
 			return -EINVAL;
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*m), bind);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*m),
+				      bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 270a030d5fd0..5be0b3c1c5b0 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -55,7 +55,8 @@ static int tcf_nat_init(struct net *net, struct nlattr *nla, struct nlattr *est,
 	parm = nla_data(tb[TCA_NAT_PARMS]);
 
 	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*p),
+				      bind, false);
 		if (ret)
 			return ret;
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 17e6d6669c7f..ce8676ad892f 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -57,7 +57,8 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	if (!tcf_hash_check(parm->index, a, bind)) {
 		if (!parm->nkeys)
 			return -EINVAL;
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*p), bind);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*p),
+				      bind, false);
 		if (ret)
 			return ret;
 		p = to_pedit(a);
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 6a8d9488613a..d6b708d6afdf 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -103,7 +103,8 @@ static int tcf_simp_init(struct net *net, struct nlattr *nla,
 	defdata = nla_data(tb[TCA_DEF_DATA]);
 
 	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*d), bind);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*d),
+				      bind, false);
 		if (ret)
 			return ret;
 
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index fcfeeaf838be..6751b5f8c046 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -99,7 +99,8 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
 	parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
 
 	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*d), bind);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*d),
+				      bind, false);
 		if (ret)
 			return ret;
 
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index d735ecf0b1a7..796785e0bf96 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -116,7 +116,8 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
 	action = parm->v_action;
 
 	if (!tcf_hash_check(parm->index, a, bind)) {
-		ret = tcf_hash_create(parm->index, est, a, sizeof(*v), bind);
+		ret = tcf_hash_create(parm->index, est, a, sizeof(*v),
+				      bind, false);
 		if (ret)
 			return ret;
 
-- 
2.4.3.573.g4eafbef
