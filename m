From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH] net: sched: make default fifo qdiscs appear in the dump
Date: Fri, 21 Oct 2016 10:45:33 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1610211024400.31629@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The original reason [1] for having hidden qdiscs (potential scalability 
issues in qdisc_match_from_root() with single linked list in case of large 
amount of qdiscs) has been invalidated by 59cc1f61f0 ("net: sched: convert 
qdisc linked list to hashtable").

This allows us for bringing more clarity and determinism into the dump by 
making default pfifo qdiscs visible.

[1] http://lkml.kernel.org/r/1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---

Tested for cbq, htb and tbf.

 net/sched/sch_cbq.c    | 4 ++++
 net/sched/sch_drr.c    | 2 ++
 net/sched/sch_dsmark.c | 1 +
 net/sched/sch_hfsc.c   | 2 ++
 net/sched/sch_htb.c    | 1 +
 net/sched/sch_multiq.c | 1 +
 net/sched/sch_prio.c   | 4 +++-
 net/sched/sch_qfq.c    | 1 +
 net/sched/sch_red.c    | 1 +
 net/sched/sch_sfb.c    | 1 +
 net/sched/sch_tbf.c    | 1 +
 11 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index beb554a..3c85e8d 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1161,6 +1161,8 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!q->link.q)
 		q->link.q = &noop_qdisc;
 
+	qdisc_hash_add(q->link.q);
+
 	q->link.priority = TC_CBQ_MAXPRIO - 1;
 	q->link.priority2 = TC_CBQ_MAXPRIO - 1;
 	q->link.cpriority = TC_CBQ_MAXPRIO - 1;
@@ -1606,6 +1608,8 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 	cl->quantum = cl->allot;
 	cl->weight = cl->R_tab->rate.rate;
 
+	qdisc_hash_add(cl->q);
+
 	sch_tree_lock(sch);
 	cbq_link_class(cl);
 	cl->borrow = cl->tparent;
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 8af5c59..1d33b94 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -118,6 +118,8 @@ static int drr_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
 
+	qdisc_hash_add(cl->qdisc);
+
 	if (tca[TCA_RATE]) {
 		err = gen_replace_estimator(&cl->bstats, NULL, &cl->rate_est,
 					    NULL,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 1308bbf..d0bffd6 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -367,6 +367,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	p->q = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops, sch->handle);
 	if (p->q == NULL)
 		p->q = &noop_qdisc;
+	qdisc_hash_add(p->q);
 
 	pr_debug("%s: qdisc %p\n", __func__, p->q);
 
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 000f1d3..a75710e 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1066,6 +1066,7 @@ struct hfsc_sched {
 				      &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
+	qdisc_hash_add(cl->qdisc);
 	INIT_LIST_HEAD(&cl->children);
 	cl->vt_tree = RB_ROOT;
 	cl->cf_tree = RB_ROOT;
@@ -1425,6 +1426,7 @@ struct hfsc_sched {
 					  sch->handle);
 	if (q->root.qdisc == NULL)
 		q->root.qdisc = &noop_qdisc;
+	qdisc_hash_add(q->root.qdisc);
 	INIT_LIST_HEAD(&q->root.children);
 	q->root.vt_tree = RB_ROOT;
 	q->root.cf_tree = RB_ROOT;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c798d0d..421d0a9 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1459,6 +1459,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		qdisc_class_hash_insert(&q->clhash, &cl->common);
 		if (parent)
 			parent->children++;
+		qdisc_hash_add(cl->un.leaf.q);
 	} else {
 		if (tca[TCA_RATE]) {
 			err = gen_replace_estimator(&cl->bstats, NULL,
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 9ffbb02..9266e9c 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -217,6 +217,7 @@ static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
 				sch_tree_lock(sch);
 				old = q->queues[i];
 				q->queues[i] = child;
+				qdisc_hash_add(child);
 
 				if (old != &noop_qdisc) {
 					qdisc_tree_reduce_backlog(old,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 8f57589..604a817 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -192,8 +192,10 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 		qdisc_destroy(child);
 	}
 
-	for (i = oldbands; i < q->bands; i++)
+	for (i = oldbands; i < q->bands; i++) {
 		q->queues[i] = queues[i];
+		qdisc_hash_add(q->queues[i]);
+	}
 
 	sch_tree_unlock(sch);
 	return 0;
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index ca0516e..f29676c 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -494,6 +494,7 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			goto destroy_class;
 	}
 
+	qdisc_hash_add(cl->qdisc);
 	sch_tree_lock(sch);
 	qdisc_class_hash_insert(&q->clhash, &cl->common);
 	sch_tree_unlock(sch);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 249b2a1..cad2370 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -191,6 +191,7 @@ static int red_change(struct Qdisc *sch, struct nlattr *opt)
 			return PTR_ERR(child);
 	}
 
+	qdisc_hash_add(child);
 	sch_tree_lock(sch);
 	q->flags = ctl->flags;
 	q->limit = ctl->limit;
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 20a350b..a0a9829 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -512,6 +512,7 @@ static int sfb_change(struct Qdisc *sch, struct nlattr *opt)
 	if (IS_ERR(child))
 		return PTR_ERR(child);
 
+	qdisc_hash_add(child);
 	sch_tree_lock(sch);
 
 	qdisc_tree_reduce_backlog(q->qdisc, q->qdisc->q.qlen,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 303355c..7e23392 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -396,6 +396,7 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 					  q->qdisc->qstats.backlog);
 		qdisc_destroy(q->qdisc);
 		q->qdisc = child;
+		qdisc_hash_add(child);
 	}
 	q->limit = qopt->limit;
 	if (tb[TCA_TBF_PBURST])
-- 
Jiri Kosina
SUSE Labs
