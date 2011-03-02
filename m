From: "John W. Linville" <linville@tuxdriver.com>
Subject: [RFC LOL OMG] pfifo_lat: qdisc that limits dequeueing based on estimated link latency
Date: Wed,  2 Mar 2011 16:54:10 -0500
Message-ID: <1299102850-2883-1-git-send-email-linville@tuxdriver.com>
References: <20110228132341.194975v6ojrudl18@hayate.sektori.org>
Cc: bloat-devel@lists.bufferbloat.net,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40608 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756193Ab1CBWAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 17:00:39 -0500
In-Reply-To: <20110228132341.194975v6ojrudl18@hayate.sektori.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a qdisc based on the existing pfifo_fast code.  The difference
is that this qdisc limits the dequeue rate based on estimates of how
many packets can be in-flight at a given time while maintaining a target
link latency.

This work is based on the eBDP documented in Section IV of "Buffer
Sizing for 802.11 Based Networks" by Tianji Li, et al.

	http://www.hamilton.ie/tianji_li/buffersizing.pdf

This implementation timestamps an skb as it dequeues it, then
computes the service time when the frame is freed by the driver.
An exponentially weighted moving average of per fragment service times
is used to restrict queueing delays in hopes of achieving a target
fragment transmission latency.  The skb->deconstructor mechanism is
abused in order to obtain packet service time estimates.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
I took a whack at reimplementing my eBDP patch at the qdisc level.
Unfortunately, it doesn't seem to work very well and I'm at a loss
as to why... :-( Comments welcome -- maybe I'm doing something really
stupid in the math and just can't see it.

The skb->deconstructor abuse includes adding a union member in the skb
to record the qdisc->handle on the way out so that it can be used for
accounting in the deconstructor -- thanks to Neil Horman for the
suggestion!

The reason I think this is an idea worth exploring is that existing
qdisc code doesn't seem to account for the fact that the devices could
be doing a lot of queueing behind them.  Even Jussi's recent
sch_fifo_ewma post doesn't seem to take into account how long the device
holds-on to packets, which limits his ability to fight latency.

Anyway, all comments appreciated!

 include/linux/skbuff.h  |    2 +
 include/net/pkt_sched.h |    1 +
 net/sched/sch_api.c     |    1 +
 net/sched/sch_fifo.c    |  131 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 135 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bf221d6..d99861e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -296,6 +296,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@end: End pointer
  *	@destructor: Destruct function
  *	@mark: Generic packet mark
+ *	@qdhandle: handle of leaf qdisc that handled skb
  *	@nfct: Associated connection, if any
  *	@ipvs_property: skbuff is owned by ipvs
  *	@peeked: this packet has been seen already, so stats have been
@@ -407,6 +408,7 @@ struct sk_buff {
 	union {
 		__u32		mark;
 		__u32		dropcount;
+		__u32		qdhandle;
 	};
 
 	__u16			vlan_tci;
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index d9549af..93189f6 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -72,6 +72,7 @@ extern void qdisc_watchdog_cancel(struct qdisc_watchdog *wd);
 extern struct Qdisc_ops pfifo_qdisc_ops;
 extern struct Qdisc_ops bfifo_qdisc_ops;
 extern struct Qdisc_ops pfifo_head_drop_qdisc_ops;
+extern struct Qdisc_ops pfifo_lat_qdisc_ops;
 
 extern int fifo_set_limit(struct Qdisc *q, unsigned int limit);
 extern struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index b22ca2d..9c9ba9a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1769,6 +1769,7 @@ static int __init pktsched_init(void)
 	register_qdisc(&pfifo_qdisc_ops);
 	register_qdisc(&bfifo_qdisc_ops);
 	register_qdisc(&pfifo_head_drop_qdisc_ops);
+	register_qdisc(&pfifo_lat_qdisc_ops);
 	register_qdisc(&mq_qdisc_ops);
 
 	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index d468b47..0d2cb48 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -15,6 +15,7 @@
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
+#include <linux/average.h>
 #include <net/pkt_sched.h>
 
 /* 1 band FIFO pseudo-"scheduler" */
@@ -24,6 +25,20 @@ struct fifo_sched_data
 	u32 limit;
 };
 
+/*
+ * Private data for a pfifo_lat scheduler containing:
+ *	- embedded fifo private data
+ *	- EWMA of average skb service time for each band
+ *	- count of currently in-flight skbs for each band
+ *	- maximum in-flight skbs for each band
+ */
+struct pfifo_lat_data {
+	struct fifo_sched_data q;
+	struct ewma tserv;
+	unsigned int inflight;
+	unsigned int inflight_max;
+};
+
 static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
@@ -59,6 +74,86 @@ static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 	return NET_XMIT_CN;
 }
 
+static int pfifo_lat_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+{
+	struct pfifo_lat_data *priv = qdisc_priv(sch);
+
+	/* include inflight count when checking queue length limit */
+	if (skb_queue_len(&sch->q) + priv->inflight < priv->q.limit)
+		return qdisc_enqueue_tail(skb, sch);
+
+	return qdisc_reshape_fail(skb, sch);
+}
+
+static void pfifo_lat_skb_free(struct sk_buff *skb)
+{
+	struct Qdisc *qdisc = qdisc_lookup(skb->dev, skb->qdhandle);
+	struct pfifo_lat_data *priv = qdisc_priv(qdisc);
+	unsigned int tserv_ns, inflight_mult;
+
+	/*
+	 * grab timestamp info for buffer control estimates and factor
+	 * that into service time estimate for this queue
+	 */
+	ewma_add(&priv->tserv,
+		 ktime_to_ns(ktime_sub(ktime_get(), skb->tstamp)));
+	tserv_ns = ewma_read(&priv->tserv);
+	if (tserv_ns) {
+		/* calculate multiplier between tserv and target latency */
+		inflight_mult = 2 * NSEC_PER_MSEC / tserv_ns;
+
+		/*
+		 * use current inflight number as proxy for number of
+		 * packets inflight when this packet was sent to
+		 * hardware queue
+		 */
+		priv->inflight_max =
+			max_t(int, 2, priv->inflight * inflight_mult);
+	}
+
+	priv->inflight--;
+}
+
+static struct sk_buff *pfifo_lat_dequeue(struct Qdisc *qdisc)
+{
+	struct pfifo_lat_data *priv = qdisc_priv(qdisc);
+	struct sk_buff *skb;
+
+	if (priv->inflight >= priv->inflight_max)
+		return NULL;
+
+	skb = qdisc_dequeue_head(qdisc);
+	if (!skb)
+		return NULL;
+
+	priv->inflight++;
+
+	/* take ownership of skb and timestamp it */
+	skb_orphan(skb);
+	skb->qdhandle = qdisc->handle;
+	skb->destructor = pfifo_lat_skb_free;
+	skb->dev = qdisc_dev(qdisc); /* do I need to set this?  */
+	skb->tstamp = ktime_get();
+
+	return skb;
+}
+
+static void pfifo_lat_reset(struct Qdisc* qdisc)
+{
+	struct pfifo_lat_data *priv = qdisc_priv(qdisc);
+
+	/*
+	 * since fifo_sched_data is embedded at head of pfifo_lat_data,
+	 * this should be OK to do...
+	 */
+	qdisc_reset_queue(qdisc);
+
+	/* need to reset priv->tserv somehow? */
+
+	priv->inflight = 0;
+	priv->inflight_max = (typeof(priv->inflight_max))-1;
+}
+
 static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
@@ -82,6 +177,30 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
+static int pfifo_lat_init(struct Qdisc *qdisc, struct nlattr *opt)
+{
+	struct pfifo_lat_data *priv = qdisc_priv(qdisc);
+	int rc;
+
+	/*
+	 * since fifo_sched_data is embedded at head of pfifo_lat_data,
+	 * this should be OK to do...
+	 */
+	rc = fifo_init(qdisc, opt);
+	if (rc)
+		return rc;
+
+	/* initialize service time estimate */
+	ewma_init(&priv->tserv, 1, 64);
+
+	priv->inflight = 0; /* necessary to set this explicitly? */
+
+	/* initial inflight_max should be ??? */
+	priv->inflight_max = (typeof(priv->inflight_max))-1;
+
+	return 0;
+}
+
 static int fifo_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
@@ -138,6 +257,18 @@ struct Qdisc_ops pfifo_head_drop_qdisc_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 
+struct Qdisc_ops pfifo_lat_qdisc_ops __read_mostly = {
+	.id		=	"pfifo_lat",
+	.priv_size	=	sizeof(struct pfifo_lat_data),
+	.enqueue	=	pfifo_lat_enqueue,
+	.dequeue	=	pfifo_lat_dequeue,
+	.peek		=	qdisc_peek_head,
+	.init		=	pfifo_lat_init,
+	.reset		=	pfifo_lat_reset,
+	.dump		=	fifo_dump,
+	.owner		=	THIS_MODULE,
+};
+
 /* Pass size change message down to embedded FIFO */
 int fifo_set_limit(struct Qdisc *q, unsigned int limit)
 {
-- 
1.7.4

