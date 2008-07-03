From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/39]: pkt_sched: Add qdisc_all_tx_empty()
Date: Thu, 03 Jul 2008 00:03:43 -0700 (PDT)
Message-ID: <20080703.000343.16709755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47523
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757302AbYGCHDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:03:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As per comments, this isn't a foolproof implementation.  This is being
added so that we can contain and isolate all the explicit ->tx_queue
references in the tree.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/irda/irda_device.h |    2 +-
 include/net/sch_generic.h      |   13 +++++++++++++
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
index 16fbf67..3025ae1 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -223,7 +223,7 @@ int  irda_device_is_receiving(struct net_device *dev);
 /* Interface for internal use */
 static inline int irda_device_txqueue_empty(const struct net_device *dev)
 {
-	return skb_queue_empty(&dev->tx_queue.qdisc->q);
+	return qdisc_all_tx_empty(dev);
 }
 int  irda_device_set_raw_mode(struct net_device* self, int status);
 struct net_device *alloc_irdadev(int sizeof_priv);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a71994b..f83e860 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -191,6 +191,19 @@ static inline void qdisc_reset_all_tx(struct net_device *dev)
 	qdisc_reset(dev->tx_queue.qdisc);
 }
 
+/* Are all TX queues of the device empty?  */
+static inline bool qdisc_all_tx_empty(const struct net_device *dev)
+{
+	struct netdev_queue *txq = &dev->tx_queue;
+
+	/* XXX This is not correct but it is good enough for the
+	 * XXX one place that wants this, IRDA.  If we wanted to
+	 * XXX do this right, we'd need to add a qdisc op to
+	 * XXX probe for the queue state.
+	 */
+	return skb_queue_empty(&txq->qdisc->q);
+}
+
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
-- 
1.5.6

