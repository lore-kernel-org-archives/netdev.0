From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH 2/4] net/sched: Allow multiple mq qdisc to be used as
	non-root
Date: Thu, 09 Dec 2010 12:00:02 -0800
Message-ID: <20101209200002.3554.66177.stgit@jf-dev1-dcblab>
References: <20101209195956.3554.49511.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, shemminger@vyatta.com,
	tgraf@infradead.org, eric.dumazet@gmail.com,
	john.r.fastabend@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43190 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757012Ab0LIUCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 15:02:06 -0500
In-Reply-To: <20101209195956.3554.49511.stgit@jf-dev1-dcblab>
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

 net/sched/sch_mq.c |   73 +++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 57 insertions(+), 16 deletions(-)

diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index ecc302f..deac04c 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -19,17 +19,42 @@
 
 struct mq_sched {
 	struct Qdisc		**qdiscs;
+	u8 num_tc;
 };
 
+static void mq_queues(struct net_device *dev, struct Qdisc *sch,
+		      unsigned int *count, unsigned int *offset)
+{
+	struct mq_sched *priv = qdisc_priv(sch);
+	if (priv->num_tc) {
+		struct netdev_tc_txq *tc;
+		int queue = TC_H_MIN(sch->parent) - 1;
+
+		tc = netdev_get_tc_queue(dev, queue);
+		if (count)
+			*count = tc->count;
+		if (offset)
+			*offset = tc->offset;
+	} else {
+		if (count)
+			*count = dev->num_tx_queues;
+		if (offset)
+			*offset = 0;
+	}
+}
+
 static void mq_destroy(struct Qdisc *sch)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct mq_sched *priv = qdisc_priv(sch);
-	unsigned int ntx;
+	unsigned int ntx, count;
 
 	if (!priv->qdiscs)
 		return;
-	for (ntx = 0; ntx < dev->num_tx_queues && priv->qdiscs[ntx]; ntx++)
+
+	mq_queues(dev, sch, &count, NULL);
+
+	for (ntx = 0; ntx < count && priv->qdiscs[ntx]; ntx++)
 		qdisc_destroy(priv->qdiscs[ntx]);
 	kfree(priv->qdiscs);
 }
@@ -41,21 +66,26 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 	struct netdev_queue *dev_queue;
 	struct Qdisc *qdisc;
 	unsigned int ntx;
+	unsigned int count, offset;
 
-	if (sch->parent != TC_H_ROOT)
+	if (sch->parent != TC_H_ROOT && !dev->num_tc)
 		return -EOPNOTSUPP;
 
 	if (!netif_is_multiqueue(dev))
 		return -EOPNOTSUPP;
 
+	/* Record num tc's in priv so we can tear down cleanly */
+	priv->num_tc = dev->num_tc;
+	mq_queues(dev, sch, &count, &offset);
+
 	/* pre-allocate qdiscs, attachment can't fail */
-	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
+	priv->qdiscs = kcalloc(count, sizeof(priv->qdiscs[0]),
 			       GFP_KERNEL);
 	if (priv->qdiscs == NULL)
 		return -ENOMEM;
 
-	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
-		dev_queue = netdev_get_tx_queue(dev, ntx);
+	for (ntx = 0; ntx < count; ntx++) {
+		dev_queue = netdev_get_tx_queue(dev, ntx + offset);
 		qdisc = qdisc_create_dflt(dev_queue, &pfifo_fast_ops,
 					  TC_H_MAKE(TC_H_MAJ(sch->handle),
 						    TC_H_MIN(ntx + 1)));
@@ -65,7 +95,8 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 		priv->qdiscs[ntx] = qdisc;
 	}
 
-	sch->flags |= TCQ_F_MQROOT;
+	if (!priv->num_tc)
+		sch->flags |= TCQ_F_MQROOT;
 	return 0;
 
 err:
@@ -78,9 +109,11 @@ static void mq_attach(struct Qdisc *sch)
 	struct net_device *dev = qdisc_dev(sch);
 	struct mq_sched *priv = qdisc_priv(sch);
 	struct Qdisc *qdisc;
-	unsigned int ntx;
+	unsigned int ntx, count;
 
-	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
+	mq_queues(dev, sch, &count, NULL);
+
+	for (ntx = 0; ntx < count; ntx++) {
 		qdisc = priv->qdiscs[ntx];
 		qdisc = dev_graft_qdisc(qdisc->dev_queue, qdisc);
 		if (qdisc)
@@ -94,14 +127,17 @@ static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct Qdisc *qdisc;
-	unsigned int ntx;
+	unsigned int ntx, count, offset;
+
+	mq_queues(dev, sch, &count, &offset);
 
 	sch->q.qlen = 0;
 	memset(&sch->bstats, 0, sizeof(sch->bstats));
 	memset(&sch->qstats, 0, sizeof(sch->qstats));
 
-	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
-		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
+	for (ntx = 0; ntx < count; ntx++) {
+		int txq = ntx + offset;
+		qdisc = netdev_get_tx_queue(dev, txq)->qdisc_sleeping;
 		spin_lock_bh(qdisc_lock(qdisc));
 		sch->q.qlen		+= qdisc->q.qlen;
 		sch->bstats.bytes	+= qdisc->bstats.bytes;
@@ -120,10 +156,13 @@ static struct netdev_queue *mq_queue_get(struct Qdisc *sch, unsigned long cl)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	unsigned long ntx = cl - 1;
+	unsigned int count, offset;
+
+	mq_queues(dev, sch, &count, &offset);
 
-	if (ntx >= dev->num_tx_queues)
+	if (ntx >= count)
 		return NULL;
-	return netdev_get_tx_queue(dev, ntx);
+	return netdev_get_tx_queue(dev, offset + ntx);
 }
 
 static struct netdev_queue *mq_select_queue(struct Qdisc *sch,
@@ -203,13 +242,15 @@ static int mq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 static void mq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
 	struct net_device *dev = qdisc_dev(sch);
-	unsigned int ntx;
+	unsigned int ntx, count;
+
+	mq_queues(dev, sch, &count, NULL);
 
 	if (arg->stop)
 		return;
 
 	arg->count = arg->skip;
-	for (ntx = arg->skip; ntx < dev->num_tx_queues; ntx++) {
+	for (ntx = arg->skip; ntx < count; ntx++) {
 		if (arg->fn(sch, ntx + 1, arg) < 0) {
 			arg->stop = 1;
 			break;

