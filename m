From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 3/2] pkt_sched: Fix locking of qdisc_root with
	qdisc_root_sleeping_lock()
Date: Tue, 26 Aug 2008 22:58:29 +0200
Message-ID: <20080826205829.GA2555@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:38943 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbYHZU5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 16:57:20 -0400
Received: by ug-out-1314.google.com with SMTP id c2so832417ugf.37
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 13:57:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After this patch the only remaining user of qdisc_root_lock() is
ieee80211_requeue() in net/mac80211/wme.c, and probably could be
changed too.

Thanks,
Jarek P.
-------------->

pkt_sched: Fix locking of qdisc_root with qdisc_root_sleeping_lock()

Use qdisc_root_sleeping_lock() instead of qdisc_root_lock() where
appropriate. The only difference is while dev is deactivated, when
currently we can use a sleeping qdisc with the lock of noop_qdisc.
This shouldn't be dangerous since after deactivation root lock could
be used only by gen_estimator code, but looks wrong anyway.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/cls_api.c   |    2 +-
 net/sched/cls_route.c |    2 +-
 net/sched/sch_api.c   |    8 ++++----
 net/sched/sch_cbq.c   |    2 +-
 net/sched/sch_htb.c   |    4 ++--
 net/sched/sch_netem.c |    2 +-
 net/sched/sch_teql.c  |    2 +-
 7 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 5cafdd4..8eb79e9 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -205,7 +205,7 @@ replay:
 		}
 	}
 
-	root_lock = qdisc_root_lock(q);
+	root_lock = qdisc_root_sleeping_lock(q);
 
 	if (tp == NULL) {
 		/* Proto-tcf does not exist, create new one */
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 481260a..e3d8455 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -75,7 +75,7 @@ static __inline__ int route4_fastmap_hash(u32 id, int iif)
 static inline
 void route4_reset_fastmap(struct Qdisc *q, struct route4_head *head, u32 id)
 {
-	spinlock_t *root_lock = qdisc_root_lock(q);
+	spinlock_t *root_lock = qdisc_root_sleeping_lock(q);
 
 	spin_lock_bh(root_lock);
 	memset(head->fastmap, 0, sizeof(head->fastmap));
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 85e078c..14c11a0 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1169,8 +1169,8 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	if (q->stab && qdisc_dump_stab(skb, q->stab) < 0)
 		goto nla_put_failure;
 
-	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
-					 TCA_XSTATS, qdisc_root_lock(q), &d) < 0)
+	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
+					 qdisc_root_sleeping_lock(q), &d) < 0)
 		goto nla_put_failure;
 
 	if (q->ops->dump_stats && q->ops->dump_stats(q, &d) < 0)
@@ -1461,8 +1461,8 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	if (cl_ops->dump && cl_ops->dump(q, cl, skb, tcm) < 0)
 		goto nla_put_failure;
 
-	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
-					 TCA_XSTATS, qdisc_root_lock(q), &d) < 0)
+	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTATS,
+					 qdisc_root_sleeping_lock(q), &d) < 0)
 		goto nla_put_failure;
 
 	if (cl_ops->dump_stats && cl_ops->dump_stats(q, cl, &d) < 0)
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 9b720ad..8b06fa9 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1754,7 +1754,7 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 
 	if (--cl->refcnt == 0) {
 #ifdef CONFIG_NET_CLS_ACT
-		spinlock_t *root_lock = qdisc_root_lock(sch);
+		spinlock_t *root_lock = qdisc_root_sleeping_lock(sch);
 		struct cbq_sched_data *q = qdisc_priv(sch);
 
 		spin_lock_bh(root_lock);
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 97d4761..d14f020 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1043,7 +1043,7 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 
 static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	spinlock_t *root_lock = qdisc_root_lock(sch);
+	spinlock_t *root_lock = qdisc_root_sleeping_lock(sch);
 	struct htb_sched *q = qdisc_priv(sch);
 	struct nlattr *nest;
 	struct tc_htb_glob gopt;
@@ -1075,7 +1075,7 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 			  struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
-	spinlock_t *root_lock = qdisc_root_lock(sch);
+	spinlock_t *root_lock = qdisc_root_sleeping_lock(sch);
 	struct nlattr *nest;
 	struct tc_htb_opt opt;
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index fb0294d..3781e55 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -341,7 +341,7 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	for (i = 0; i < n; i++)
 		d->table[i] = data[i];
 
-	root_lock = qdisc_root_lock(sch);
+	root_lock = qdisc_root_sleeping_lock(sch);
 
 	spin_lock_bh(root_lock);
 	d = xchg(&q->delay_dist, d);
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 2c35c67..d35ef05 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -161,7 +161,7 @@ teql_destroy(struct Qdisc* sch)
 						txq = netdev_get_tx_queue(master->dev, 0);
 						master->slaves = NULL;
 
-						root_lock = qdisc_root_lock(txq->qdisc);
+						root_lock = qdisc_root_sleeping_lock(txq->qdisc);
 						spin_lock_bh(root_lock);
 						qdisc_reset(txq->qdisc);
 						spin_unlock_bh(root_lock);
