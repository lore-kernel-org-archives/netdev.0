From: Patrick McHardy <kaber@trash.net>
Subject: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 19:57:55 +0200
Message-ID: <4683F6A3.5070705@trash.net>
References: <20070628162056.18728.20195.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050904000609050406070202"
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56232 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764281AbXF1R6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 13:58:51 -0400
In-Reply-To: <20070628162056.18728.20195.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050904000609050406070202
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Updated version of Peter's patch, changes:

- remove NET_SCH_MULTIQUEUE
- remove all ifdefs, the price is 4-8 bytes additional
  memory usage per prio qdisc.
- return -EOPNOTSUPP when multiqueue is requested but not supported
  on the device or not compiled in
- clean up prio_classify, only a single assigment of skb->queue_mapping
- fix error handling during registation


--------------050904000609050406070202
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[SCHED] Qdisc changes and sch_rr added for multiqueue

Add the new sch_rr qdisc for multiqueue network device support.
Allow sch_prio and sch_rr to be compiled with or without multiqueue
hardware support.

sch_rr is part of sch_prio, and is referenced from MODULE_ALIAS.  This
was done since sch_prio and sch_rr only differ in their dequeue routine.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 69316230fac0d52803f098565d530b8061d32aea
tree 06fa5dc8cfb274ad712c3646df38efe01aa8ea52
parent 48e334930c5fbb64a821733a7056e2800057c128
author Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com> Thu, 28 Jun 2007 18:47:49 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 28 Jun 2007 19:56:28 +0200

 include/linux/pkt_sched.h |    9 +++
 net/sched/Kconfig         |   11 ++++
 net/sched/sch_prio.c      |  127 ++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 132 insertions(+), 15 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d10f353..268c515 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -101,6 +101,15 @@ struct tc_prio_qopt
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
 };
 
+enum
+{
+	TCA_PRIO_UNSPEC,
+	TCA_PRIO_MQ,
+	__TCA_PRIO_MAX
+};
+
+#define TCA_PRIO_MAX    (__TCA_PRIO_MAX - 1)
+
 /* TBF section */
 
 struct tc_tbf_qopt
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 475df84..f321794 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -111,6 +111,17 @@ config NET_SCH_PRIO
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_prio.
 
+config NET_SCH_RR
+	tristate "Multi Band Round Robin Queuing (RR)"
+	select NET_SCH_PRIO
+	---help---
+	  Say Y here if you want to use an n-band round robin packet
+	  scheduler.
+
+	  The module uses sch_prio for its framework and is aliased as
+	  sch_rr, so it will load sch_prio, although it is referred
+	  to using sch_rr.
+
 config NET_SCH_RED
 	tristate "Random Early Detection (RED)"
 	---help---
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 6d7542c..cc6b541 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -40,9 +40,11 @@
 struct prio_sched_data
 {
 	int bands;
+	int curband; /* for round-robin */
 	struct tcf_proto *filter_list;
 	u8  prio2band[TC_PRIO_MAX+1];
 	struct Qdisc *queues[TCQ_PRIO_BANDS];
+	int mq;
 };
 
 
@@ -70,14 +72,17 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 #endif
 			if (TC_H_MAJ(band))
 				band = 0;
-			return q->queues[q->prio2band[band&TC_PRIO_MAX]];
+			band = q->prio2band[band&TC_PRIO_MAX];
+			goto out;
 		}
 		band = res.classid;
 	}
 	band = TC_H_MIN(band) - 1;
 	if (band >= q->bands)
-		return q->queues[q->prio2band[0]];
-
+		band = q->prio2band[0];
+out:
+	if (q->mq)
+		skb_set_queue_mapping(skb, band);
 	return q->queues[band];
 }
 
@@ -144,17 +149,58 @@ prio_dequeue(struct Qdisc* sch)
 	struct Qdisc *qdisc;
 
 	for (prio = 0; prio < q->bands; prio++) {
-		qdisc = q->queues[prio];
-		skb = qdisc->dequeue(qdisc);
-		if (skb) {
-			sch->q.qlen--;
-			return skb;
+		/* Check if the target subqueue is available before
+		 * pulling an skb.  This way we avoid excessive requeues
+		 * for slower queues.
+		 */
+		if (!netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {
+			qdisc = q->queues[prio];
+			skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				return skb;
+			}
 		}
 	}
 	return NULL;
 
 }
 
+static struct sk_buff *rr_dequeue(struct Qdisc* sch)
+{
+	struct sk_buff *skb;
+	struct prio_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *qdisc;
+	int bandcount;
+
+	/* Only take one pass through the queues.  If nothing is available,
+	 * return nothing.
+	 */
+	for (bandcount = 0; bandcount < q->bands; bandcount++) {
+		/* Check if the target subqueue is available before
+		 * pulling an skb.  This way we avoid excessive requeues
+		 * for slower queues.  If the queue is stopped, try the
+		 * next queue.
+		 */
+		if (!netif_subqueue_stopped(sch->dev,
+					    (q->mq ? q->curband : 0))) {
+			qdisc = q->queues[q->curband];
+			skb = qdisc->dequeue(qdisc);
+			if (skb) {
+				sch->q.qlen--;
+				q->curband++;
+				if (q->curband >= q->bands)
+					q->curband = 0;
+				return skb;
+			}
+		}
+		q->curband++;
+		if (q->curband >= q->bands)
+			q->curband = 0;
+	}
+	return NULL;
+}
+
 static unsigned int prio_drop(struct Qdisc* sch)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -198,21 +244,39 @@ prio_destroy(struct Qdisc* sch)
 static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
-	struct tc_prio_qopt *qopt = RTA_DATA(opt);
+	struct tc_prio_qopt *qopt;
+	struct rtattr *tb[TCA_PRIO_MAX];
 	int i;
 
-	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
+	if (rtattr_parse_nested_compat(tb, TCA_PRIO_MAX, opt, qopt,
+				       sizeof(*qopt)))
 		return -EINVAL;
-	if (qopt->bands > TCQ_PRIO_BANDS || qopt->bands < 2)
+	q->bands = qopt->bands;
+	/* If we're multiqueue, make sure the number of incoming bands
+	 * matches the number of queues on the device we're associating with.
+	 * If the number of bands requested is zero, then set q->bands to
+	 * dev->egress_subqueue_count.
+	 */
+	q->mq = RTA_GET_FLAG(tb[TCA_PRIO_MQ - 1]);
+	if (q->mq) {
+		if (netif_is_multiqueue(sch->dev)) {
+			if (q->bands == 0)
+				q->bands = sch->dev->egress_subqueue_count;
+			else if (q->bands != sch->dev->egress_subqueue_count)
+				return -EINVAL;
+		} else
+			return -EOPNOTSUPP;
+	}
+
+	if (q->bands > TCQ_PRIO_BANDS || q->bands < 2)
 		return -EINVAL;
 
 	for (i=0; i<=TC_PRIO_MAX; i++) {
-		if (qopt->priomap[i] >= qopt->bands)
+		if (qopt->priomap[i] >= q->bands)
 			return -EINVAL;
 	}
 
 	sch_tree_lock(sch);
-	q->bands = qopt->bands;
 	memcpy(q->prio2band, qopt->priomap, TC_PRIO_MAX+1);
 
 	for (i=q->bands; i<TCQ_PRIO_BANDS; i++) {
@@ -268,11 +332,17 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
+	struct rtattr *nest;
 	struct tc_prio_qopt opt;
 
 	opt.bands = q->bands;
 	memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX+1);
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+
+	nest = RTA_NEST_COMPAT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	if (q->mq)
+		RTA_PUT_FLAG(skb, TCA_PRIO_MQ);
+	RTA_NEST_COMPAT_END(skb, nest);
+
 	return skb->len;
 
 rtattr_failure:
@@ -443,17 +513,44 @@ static struct Qdisc_ops prio_qdisc_ops = {
 	.owner		=	THIS_MODULE,
 };
 
+static struct Qdisc_ops rr_qdisc_ops = {
+	.next		=	NULL,
+	.cl_ops		=	&prio_class_ops,
+	.id		=	"rr",
+	.priv_size	=	sizeof(struct prio_sched_data),
+	.enqueue	=	prio_enqueue,
+	.dequeue	=	rr_dequeue,
+	.requeue	=	prio_requeue,
+	.drop		=	prio_drop,
+	.init		=	prio_init,
+	.reset		=	prio_reset,
+	.destroy	=	prio_destroy,
+	.change		=	prio_tune,
+	.dump		=	prio_dump,
+	.owner		=	THIS_MODULE,
+};
+
 static int __init prio_module_init(void)
 {
-	return register_qdisc(&prio_qdisc_ops);
+	int err;
+
+	err = register_qdisc(&prio_qdisc_ops);
+	if (err < 0)
+		return err;
+	err = register_qdisc(&rr_qdisc_ops);
+	if (err < 0)
+		unregister_qdisc(&prio_qdisc_ops);
+	return err;
 }
 
 static void __exit prio_module_exit(void)
 {
 	unregister_qdisc(&prio_qdisc_ops);
+	unregister_qdisc(&rr_qdisc_ops);
 }
 
 module_init(prio_module_init)
 module_exit(prio_module_exit)
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("sch_rr");

--------------050904000609050406070202--
