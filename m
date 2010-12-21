From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH v2 2/3] net_sched: Allow multiple mq qdisc to be
	used as non-root
Date: Tue, 21 Dec 2010 11:29:25 -0800
Message-ID: <20101221192925.9703.68157.stgit@jf-dev1-dcblab>
References: <20101221192831.9703.56356.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	hadi@cyberus.ca, shemminger@vyatta.com, tgraf@infradead.org,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	nhorman@tuxdriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7025 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223Ab0LUTci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 14:32:38 -0500
In-Reply-To: <20101221192831.9703.56356.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies the mq qdisc to allow multiple mq qdiscs
to be used. Allowing TX queues to be grouped for management.

This allows a root container qdisc to create multiple traffic
classes and use the mq qdisc as a default queueing discipline. It
is expected other queueing disciplines can then be grafted to the
container as needed.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/sched/sch_mq.c |   52 +++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 37 insertions(+), 15 deletions(-)

diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index ecc302f..86da74c 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -19,17 +19,32 @@
 
 struct mq_sched {
 	struct Qdisc		**qdiscs;
+	struct netdev_tc_txq	tc_txq;
+	u8 num_tc;
 };
 
+static void mq_queues(struct net_device *dev, struct Qdisc *sch)
+{
+	struct mq_sched *priv = qdisc_priv(sch);
+	if (priv->num_tc) {
+		int queue = TC_H_MIN(sch->parent) - 1;
+		priv->tc_txq.count = dev->tc_to_txq[queue].count;
+		priv->tc_txq.offset = dev->tc_to_txq[queue].offset;
+	} else {
+		priv->tc_txq.count = dev->num_tx_queues;
+		priv->tc_txq.offset = 0;
+	}
+}
+
 static void mq_destroy(struct Qdisc *sch)
 {
-	struct net_device *dev = qdisc_dev(sch);
 	struct mq_sched *priv = qdisc_priv(sch);
 	unsigned int ntx;
 
 	if (!priv->qdiscs)
 		return;
-	for (ntx = 0; ntx < dev->num_tx_queues && priv->qdiscs[ntx]; ntx++)
+
+	for (ntx = 0; ntx < priv->tc_txq.count && priv->qdiscs[ntx]; ntx++)
 		qdisc_destroy(priv->qdiscs[ntx]);
 	kfree(priv->qdiscs);
 }
@@ -42,20 +57,24 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 	struct Qdisc *qdisc;
 	unsigned int ntx;
 
-	if (sch->parent != TC_H_ROOT)
+	if (sch->parent != TC_H_ROOT && !dev->num_tc)
 		return -EOPNOTSUPP;
 
 	if (!netif_is_multiqueue(dev))
 		return -EOPNOTSUPP;
 
+	/* Record num tc info in priv so we can tear down cleanly */
+	priv->num_tc = dev->num_tc;
+	mq_queues(dev, sch);
+
 	/* pre-allocate qdiscs, attachment can't fail */
-	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
+	priv->qdiscs = kcalloc(priv->tc_txq.count, sizeof(priv->qdiscs[0]),
 			       GFP_KERNEL);
 	if (priv->qdiscs == NULL)
 		return -ENOMEM;
 
-	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
-		dev_queue = netdev_get_tx_queue(dev, ntx);
+	for (ntx = 0; ntx < priv->tc_txq.count; ntx++) {
+		dev_queue = netdev_get_tx_queue(dev, ntx + priv->tc_txq.offset);
 		qdisc = qdisc_create_dflt(dev_queue, &pfifo_fast_ops,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(ntx + 1)));
@@ -65,7 +84,8 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 		priv->qdiscs[ntx] = qdisc;
 	}
 
-	sch->flags |= TCQ_F_MQROOT;
+	if (!priv->num_tc)
+		sch->flags |= TCQ_F_MQROOT;
 	return 0;
 
 err:
@@ -75,12 +95,11 @@ err:
 
 static void mq_attach(struct Qdisc *sch)
 {
-	struct net_device *dev = qdisc_dev(sch);
 	struct mq_sched *priv = qdisc_priv(sch);
 	struct Qdisc *qdisc;
 	unsigned int ntx;
 
-	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
+	for (ntx = 0; ntx < priv->tc_txq.count; ntx++) {
 		qdisc = priv->qdiscs[ntx];
 		qdisc = dev_graft_qdisc(qdisc->dev_queue, qdisc);
 		if (qdisc)
@@ -93,6 +112,7 @@ static void mq_attach(struct Qdisc *sch)
 static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct net_device *dev = qdisc_dev(sch);
+	struct mq_sched *priv = qdisc_priv(sch);
 	struct Qdisc *qdisc;
 	unsigned int ntx;
 
@@ -100,8 +120,9 @@ static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	memset(&sch->bstats, 0, sizeof(sch->bstats));
 	memset(&sch->qstats, 0, sizeof(sch->qstats));
 
-	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
-		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
+	for (ntx = 0; ntx < priv->tc_txq.count; ntx++) {
+		int txq = ntx + priv->tc_txq.offset;
+		qdisc = netdev_get_tx_queue(dev, txq)->qdisc_sleeping;
 		spin_lock_bh(qdisc_lock(qdisc));
 		sch->q.qlen		+= qdisc->q.qlen;
 		sch->bstats.bytes	+= qdisc->bstats.bytes;
@@ -119,11 +140,12 @@ static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 static struct netdev_queue *mq_queue_get(struct Qdisc *sch, unsigned long cl)
 {
 	struct net_device *dev = qdisc_dev(sch);
+	struct mq_sched *priv = qdisc_priv(sch);
 	unsigned long ntx = cl - 1;
 
-	if (ntx >= dev->num_tx_queues)
+	if (ntx >= priv->tc_txq.count)
 		return NULL;
-	return netdev_get_tx_queue(dev, ntx);
+	return netdev_get_tx_queue(dev, priv->tc_txq.offset + ntx);
 }
 
 static struct netdev_queue *mq_select_queue(struct Qdisc *sch,
@@ -202,14 +224,14 @@ static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 static void mq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
-	struct net_device *dev = qdisc_dev(sch);
+	struct mq_sched *priv = qdisc_priv(sch);
 	unsigned int ntx;
 
 	if (arg->stop)
 		return;
 
 	arg->count = arg->skip;
-	for (ntx = arg->skip; ntx < dev->num_tx_queues; ntx++) {
+	for (ntx = arg->skip; ntx < priv->tc_txq.count; ntx++) {
 		if (arg->fn(sch, ntx + 1, arg) < 0) {
 			arg->stop = 1;
 			break;

