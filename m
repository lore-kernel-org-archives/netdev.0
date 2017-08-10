From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Thu, 10 Aug 2017 12:31:52 +0300
Message-ID: <150235751251.493255.14955523507789154918.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1j.cmail.yandex.net ([5.255.227.106]:33341 "EHLO
        forwardcorp1j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751732AbdHJJi4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 05:38:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In previous API tcf_destroy_chain() could be called several times and
some schedulers like hfsc and atm use that. In new API tcf_block_put()
frees block but leaves stale pointer, second call will free it once again.

This patch fixes such double-frees.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: 6529eaba33f0 ("net: sched: introduce tcf block infractructure")
---
 include/net/pkt_cls.h    |    4 ++--
 net/sched/cls_api.c      |    4 +++-
 net/sched/sch_atm.c      |    4 ++--
 net/sched/sch_cbq.c      |    6 +++---
 net/sched/sch_drr.c      |    2 +-
 net/sched/sch_dsmark.c   |    2 +-
 net/sched/sch_fq_codel.c |    2 +-
 net/sched/sch_hfsc.c     |    6 +++---
 net/sched/sch_htb.c      |    8 ++++----
 net/sched/sch_ingress.c  |    6 +++---
 net/sched/sch_multiq.c   |    2 +-
 net/sched/sch_prio.c     |    2 +-
 net/sched/sch_qfq.c      |    2 +-
 net/sched/sch_sfb.c      |    2 +-
 net/sched/sch_sfq.c      |    2 +-
 15 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 537d0a0ad4c4..96aef16e5d56 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -23,7 +23,7 @@ struct tcf_chain *tcf_chain_get(struct tcf_block *block, u32 chain_index,
 void tcf_chain_put(struct tcf_chain *chain);
 int tcf_block_get(struct tcf_block **p_block,
 		  struct tcf_proto __rcu **p_filter_chain);
-void tcf_block_put(struct tcf_block *block);
+void tcf_block_put(struct tcf_block **p_block);
 int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		 struct tcf_result *res, bool compat_mode);
 
@@ -35,7 +35,7 @@ int tcf_block_get(struct tcf_block **p_block,
 	return 0;
 }
 
-static inline void tcf_block_put(struct tcf_block *block)
+static inline void tcf_block_put(struct tcf_block **p_block)
 {
 }
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 39da0c5801c9..72147650b179 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -281,8 +281,9 @@ int tcf_block_get(struct tcf_block **p_block,
 }
 EXPORT_SYMBOL(tcf_block_get);
 
-void tcf_block_put(struct tcf_block *block)
+void tcf_block_put(struct tcf_block **p_block)
 {
+	struct tcf_block *block = *p_block;
 	struct tcf_chain *chain, *tmp;
 
 	if (!block)
@@ -291,6 +292,7 @@ void tcf_block_put(struct tcf_block *block)
 	list_for_each_entry_safe(chain, tmp, &block->chain_list, list)
 		tcf_chain_destroy(chain);
 	kfree(block);
+	*p_block = NULL;
 }
 EXPORT_SYMBOL(tcf_block_put);
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 572fe2584e48..b6b24a9834b0 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -144,7 +144,7 @@ static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
 	list_del_init(&flow->list);
 	pr_debug("atm_tc_put: qdisc %p\n", flow->q);
 	qdisc_destroy(flow->q);
-	tcf_block_put(flow->block);
+	tcf_block_put(&flow->block);
 	if (flow->sock) {
 		pr_debug("atm_tc_put: f_count %ld\n",
 			file_count(flow->sock->file));
@@ -573,7 +573,7 @@ static void atm_tc_destroy(struct Qdisc *sch)
 
 	pr_debug("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
 	list_for_each_entry(flow, &p->flows, list)
-		tcf_block_put(flow->block);
+		tcf_block_put(&flow->block);
 
 	list_for_each_entry_safe(flow, tmp, &p->flows, list) {
 		if (flow->ref > 1)
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 481036f6b54e..89bff8d4e113 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1407,7 +1407,7 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 
 	WARN_ON(cl->filters);
 
-	tcf_block_put(cl->block);
+	tcf_block_put(&cl->block);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
 	gen_kill_estimator(&cl->rate_est);
@@ -1432,7 +1432,7 @@ static void cbq_destroy(struct Qdisc *sch)
 	 */
 	for (h = 0; h < q->clhash.hashsize; h++) {
 		hlist_for_each_entry(cl, &q->clhash.hash[h], common.hnode)
-			tcf_block_put(cl->block);
+			tcf_block_put(&cl->block);
 	}
 	for (h = 0; h < q->clhash.hashsize; h++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[h],
@@ -1599,7 +1599,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 					qdisc_root_sleeping_running(sch),
 					tca[TCA_RATE]);
 		if (err) {
-			tcf_block_put(cl->block);
+			tcf_block_put(&cl->block);
 			kfree(cl);
 			goto failure;
 		}
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index a413dc1c2098..fb73a903ab74 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -466,7 +466,7 @@ static void drr_destroy_qdisc(struct Qdisc *sch)
 	struct hlist_node *next;
 	unsigned int i;
 
-	tcf_block_put(q->block);
+	tcf_block_put(&q->block);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 6d94fcc3592a..1110d577c978 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -406,7 +406,7 @@ static void dsmark_destroy(struct Qdisc *sch)
 
 	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
-	tcf_block_put(p->block);
+	tcf_block_put(&p->block);
 	qdisc_destroy(p->q);
 	if (p->mv != p->embedded)
 		kfree(p->mv);
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 337f2d6d81e4..f905c83a5f4a 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -452,7 +452,7 @@ static void fq_codel_destroy(struct Qdisc *sch)
 {
 	struct fq_codel_sched_data *q = qdisc_priv(sch);
 
-	tcf_block_put(q->block);
+	tcf_block_put(&q->block);
 	kvfree(q->backlogs);
 	kvfree(q->flows);
 }
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 3ad02bbe6903..8da31692c675 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1053,7 +1053,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 					qdisc_root_sleeping_running(sch),
 					tca[TCA_RATE]);
 		if (err) {
-			tcf_block_put(cl->block);
+			tcf_block_put(&cl->block);
 			kfree(cl);
 			return err;
 		}
@@ -1099,7 +1099,7 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 
-	tcf_block_put(cl->block);
+	tcf_block_put(&cl->block);
 	qdisc_destroy(cl->qdisc);
 	gen_kill_estimator(&cl->rate_est);
 	if (cl != &q->root)
@@ -1531,7 +1531,7 @@ hfsc_destroy_qdisc(struct Qdisc *sch)
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry(cl, &q->clhash.hash[i], cl_common.hnode)
-			tcf_block_put(cl->block);
+			tcf_block_put(&cl->block);
 	}
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 203286ab4427..890ad577022f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1237,7 +1237,7 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 		qdisc_destroy(cl->un.leaf.q);
 	}
 	gen_kill_estimator(&cl->rate_est);
-	tcf_block_put(cl->block);
+	tcf_block_put(&cl->block);
 	kfree(cl);
 }
 
@@ -1255,11 +1255,11 @@ static void htb_destroy(struct Qdisc *sch)
 	 * because filter need its target class alive to be able to call
 	 * unbind_filter on it (without Oops).
 	 */
-	tcf_block_put(q->block);
+	tcf_block_put(&q->block);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry(cl, &q->clhash.hash[i], common.hnode)
-			tcf_block_put(cl->block);
+			tcf_block_put(&cl->block);
 	}
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
@@ -1415,7 +1415,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 						qdisc_root_sleeping_running(sch),
 						tca[TCA_RATE] ? : &est.nla);
 			if (err) {
-				tcf_block_put(cl->block);
+				tcf_block_put(&cl->block);
 				kfree(cl);
 				goto failure;
 			}
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index d8a9bebcab90..f0bcc78c43e0 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -78,7 +78,7 @@ static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_sched_data *q = qdisc_priv(sch);
 
-	tcf_block_put(q->block);
+	tcf_block_put(&q->block);
 	net_dec_ingress_queue();
 }
 
@@ -185,8 +185,8 @@ static void clsact_destroy(struct Qdisc *sch)
 {
 	struct clsact_sched_data *q = qdisc_priv(sch);
 
-	tcf_block_put(q->egress_block);
-	tcf_block_put(q->ingress_block);
+	tcf_block_put(&q->egress_block);
+	tcf_block_put(&q->ingress_block);
 
 	net_dec_ingress_queue();
 	net_dec_egress_queue();
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index f143b7bbaa0d..7e5f1a021664 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -172,7 +172,7 @@ multiq_destroy(struct Qdisc *sch)
 	int band;
 	struct multiq_sched_data *q = qdisc_priv(sch);
 
-	tcf_block_put(q->block);
+	tcf_block_put(&q->block);
 	for (band = 0; band < q->bands; band++)
 		qdisc_destroy(q->queues[band]);
 
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index e3e364cc9a70..83c63670df98 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -147,7 +147,7 @@ prio_destroy(struct Qdisc *sch)
 	int prio;
 	struct prio_sched_data *q = qdisc_priv(sch);
 
-	tcf_block_put(q->block);
+	tcf_block_put(&q->block);
 	for (prio = 0; prio < q->bands; prio++)
 		qdisc_destroy(q->queues[prio]);
 }
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 0e16dfda0bd7..b111d98b43cb 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1497,7 +1497,7 @@ static void qfq_destroy_qdisc(struct Qdisc *sch)
 	struct hlist_node *next;
 	unsigned int i;
 
-	tcf_block_put(q->block);
+	tcf_block_put(&q->block);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 11fb6ec878d6..76b469cd97d1 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -467,7 +467,7 @@ static void sfb_destroy(struct Qdisc *sch)
 {
 	struct sfb_sched_data *q = qdisc_priv(sch);
 
-	tcf_block_put(q->block);
+	tcf_block_put(&q->block);
 	qdisc_destroy(q->qdisc);
 }
 
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index f80ea2cc5f1f..10a8aef68162 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -699,7 +699,7 @@ static void sfq_destroy(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
-	tcf_block_put(q->block);
+	tcf_block_put(&q->block);
 	q->perturb_period = 0;
 	del_timer_sync(&q->perturb_timer);
 	sfq_free(q->ht);
