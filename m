From: David Miller <davem@davemloft.net>
Subject: [PATCH 25/31]: pkt_sched: Make qdisc grafting locking more
 specific.
Date: Thu, 17 Jul 2008 05:17:55 -0700 (PDT)
Message-ID: <20080717.051755.145101968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51694
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758642AbYGQMRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:17:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Lock the root of the qdisc being operated upon.

All explicit references to qdisc_tree_lock() are now gone.
The only remaining uses are via the sch_tree_{lock,unlock}()
and tcf_tree_{lock,unlock}() macros.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |   41 +++++++++++++++++++++++++++++------------
 1 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 6958fe7..7492489 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -441,15 +441,29 @@ static struct Qdisc *
 dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 {
 	struct netdev_queue *dev_queue;
+	spinlock_t *root_lock;
 	struct Qdisc *oqdisc;
+	int ingress;
 
 	if (dev->flags & IFF_UP)
 		dev_deactivate(dev);
 
-	qdisc_lock_tree(dev);
-	if (qdisc && qdisc->flags&TCQ_F_INGRESS) {
+	ingress = 0;
+	if (qdisc && qdisc->flags&TCQ_F_INGRESS)
+		ingress = 1;
+
+	if (ingress) {
 		dev_queue = &dev->rx_queue;
 		oqdisc = dev_queue->qdisc;
+	} else {
+		dev_queue = netdev_get_tx_queue(dev, 0);
+		oqdisc = dev_queue->qdisc_sleeping;
+	}
+
+	root_lock = qdisc_root_lock(oqdisc);
+	spin_lock_bh(root_lock);
+
+	if (ingress) {
 		/* Prune old scheduler */
 		if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1) {
 			/* delete */
@@ -460,9 +474,6 @@ dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 		}
 
 	} else {
-		dev_queue = netdev_get_tx_queue(dev, 0);
-		oqdisc = dev_queue->qdisc_sleeping;
-
 		/* Prune old scheduler */
 		if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
 			qdisc_reset(oqdisc);
@@ -474,7 +485,7 @@ dev_graft_qdisc(struct net_device *dev, struct Qdisc *qdisc)
 		dev_queue->qdisc = &noop_qdisc;
 	}
 
-	qdisc_unlock_tree(dev);
+	spin_unlock_bh(root_lock);
 
 	if (dev->flags & IFF_UP)
 		dev_activate(dev);
@@ -765,10 +776,12 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 		if ((err = qdisc_graft(dev, p, clid, NULL, &q)) != 0)
 			return err;
 		if (q) {
+			spinlock_t *root_lock = qdisc_root_lock(q);
+
 			qdisc_notify(skb, n, clid, q, NULL);
-			qdisc_lock_tree(dev);
+			spin_unlock_bh(root_lock);
 			qdisc_destroy(q);
-			qdisc_unlock_tree(dev);
+			spin_unlock_bh(root_lock);
 		}
 	} else {
 		qdisc_notify(skb, n, clid, NULL, q);
@@ -911,20 +924,24 @@ create_n_graft:
 graft:
 	if (1) {
 		struct Qdisc *old_q = NULL;
+		spinlock_t *root_lock;
+
 		err = qdisc_graft(dev, p, clid, q, &old_q);
 		if (err) {
 			if (q) {
-				qdisc_lock_tree(dev);
+				root_lock = qdisc_root_lock(q);
+				spin_lock_bh(root_lock);
 				qdisc_destroy(q);
-				qdisc_unlock_tree(dev);
+				spin_unlock_bh(root_lock);
 			}
 			return err;
 		}
 		qdisc_notify(skb, n, clid, old_q, q);
 		if (old_q) {
-			qdisc_lock_tree(dev);
+			root_lock = qdisc_root_lock(old_q);
+			spin_lock_bh(root_lock);
 			qdisc_destroy(old_q);
-			qdisc_unlock_tree(dev);
+			spin_unlock_bh(root_lock);
 		}
 	}
 	return 0;
-- 
1.5.6.2.255.gbed62

