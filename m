From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/14]: pkt_sched: Make API qdisc grafting code operate on
 explicit queues.
Date: Mon, 14 Jul 2008 15:59:13 -0700 (PDT)
Message-ID: <20080714.155913.165967911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49257
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758254AbYGNW7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 18:59:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E55ACC8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 15:59:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


dev_graft_disc() now takes a netdev_queue instead of a net_device,
and it is renamed to graft_qdisc.

Similarly qdisc_graft() takes a netdev_queue arg instead of a
net_device one as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |   39 +++++++++++++++++----------------------
 1 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 830ccc5..51b8bae 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -449,12 +449,11 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 	return i>0 ? autohandle : 0;
 }
 
-/* Attach toplevel qdisc to device dev */
+/* Attach toplevel qdisc to dev_queue */
 
-static struct Qdisc *
-dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
+static struct Qdisc *graft_qdisc(struct netdev_queue *q, struct Qdisc *qdisc)
 {
-	struct netdev_queue *dev_queue;
+	struct net_device *dev = q->dev;
 	struct Qdisc *oqdisc;
 
 	if (dev->flags & IFF_UP)
@@ -462,20 +461,18 @@ dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 
 	qdisc_lock_tree(dev);
 	if (qdisc && qdisc->flags&TCQ_F_INGRESS) {
-		dev_queue = &dev->rx_queue;
-		oqdisc = dev_queue->qdisc;
+		oqdisc = q->qdisc;
 		/* Prune old scheduler */
 		if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1) {
 			/* delete */
 			qdisc_reset(oqdisc);
-			dev_queue->qdisc = NULL;
+			q->qdisc = NULL;
 		} else {  /* new */
-			dev_queue->qdisc = qdisc;
+			q->qdisc = qdisc;
 		}
 
 	} else {
-		dev_queue = netdev_get_tx_queue(dev, 0);
-		oqdisc = dev_queue->qdisc_sleeping;
+		oqdisc = q->qdisc_sleeping;
 
 		/* Prune old scheduler */
 		if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
@@ -484,8 +481,8 @@ dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 		/* ... and graft new one */
 		if (qdisc == NULL)
 			qdisc = &noop_qdisc;
-		dev_queue->qdisc_sleeping = qdisc;
-		dev_queue->qdisc = &noop_qdisc;
+		q->qdisc_sleeping = qdisc;
+		q->qdisc = &noop_qdisc;
 	}
 
 	qdisc_unlock_tree(dev);
@@ -525,24 +522,22 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
 
 /* Graft qdisc "new" to class "classid" of qdisc "parent" or
-   to device "dev".
+   to device queue "dev_queue".
 
    Old qdisc is not destroyed but returned in *old.
  */
 
-static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
-		       u32 classid,
-		       struct Qdisc *new, struct Qdisc **old)
+static int qdisc_graft(struct netdev_queue *dev_queue, struct Qdisc *parent,
+		       u32 classid, struct Qdisc *new, struct Qdisc **old)
 {
-	int err = 0;
 	struct Qdisc *q = *old;
-
+	int err = 0;
 
 	if (parent == NULL) {
 		if (q && q->flags&TCQ_F_INGRESS) {
-			*old = dev_graft_qdisc(dev, q);
+			*old = graft_qdisc(dev_queue, q);
 		} else {
-			*old = dev_graft_qdisc(dev, new);
+			*old = graft_qdisc(dev_queue, new);
 		}
 	} else {
 		const struct Qdisc_class_ops *cops = parent->ops->cl_ops;
@@ -776,7 +771,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 			return -EINVAL;
 		if (q->handle == 0)
 			return -ENOENT;
-		if ((err = qdisc_graft(dev, p, clid, NULL, &q)) != 0)
+		if ((err = qdisc_graft(q->dev_queue, p, clid, NULL, &q)) != 0)
 			return err;
 		if (q) {
 			qdisc_notify(skb, n, clid, q, NULL);
@@ -925,7 +920,7 @@ create_n_graft:
 graft:
 	if (1) {
 		struct Qdisc *old_q = NULL;
-		err = qdisc_graft(dev, p, clid, q, &old_q);
+		err = qdisc_graft(q->dev_queue, p, clid, q, &old_q);
 		if (err) {
 			if (q) {
 				qdisc_lock_tree(dev);
-- 
1.5.6.2.255.gbed62

