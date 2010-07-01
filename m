From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] net: decreasing real_num_tx_queues needs to flush
	qdisc
Date: Thu, 01 Jul 2010 16:21:57 -0700
Message-ID: <20100701232156.15685.69551.stgit@localhost.localdomain>
References: <20100701232103.15685.48453.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.westchester.pa.mail.comcast.net ([76.96.59.228]:54934
	"EHLO qmta15.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752493Ab0GAXWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:22:17 -0400
In-Reply-To: <20100701232103.15685.48453.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Reducing real_num_queues needs to flush the qdisc otherwise
skbs with queue_mappings greater then real_num_tx_queues can
be sent to the underlying driver.

The flow for this is,

dev_queue_xmit()
	dev_pick_tx()
		skb_tx_hash()  => hash using real_num_tx_queues
		skb_set_queue_mapping()
	...
	qdisc_enqueue_root() => enqueue skb on txq from hash
...
dev->real_num_tx_queues -= n
...
sch_direct_xmit()
	dev_hard_start_xmit()
		ndo_start_xmit(skb,dev) => skb queue set with old hash

skbs are enqueued on the qdisc with skb->queue_mapping set
0 < queue_mappings < real_num_tx_queues.  When the driver
decreases real_num_tx_queues skb's may be dequeued from the
qdisc with a queue_mapping greater then real_num_tx_queues.

This fixes a case in ixgbe where this was occurring with DCB
and FCoE. Because the driver is using queue_mapping to map
skbs to tx descriptor rings we can potentially map skbs to
rings that no longer exist.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 include/linux/netdevice.h      |    3 +++
 include/net/sch_generic.h      |   12 ++++++++----
 net/core/dev.c                 |   18 ++++++++++++++++++
 4 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a0b3316..7b5d976 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4001,7 +4001,7 @@ static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 
 done:
 	/* Notify the stack of the (possibly) reduced Tx Queue count. */
-	adapter->netdev->real_num_tx_queues = adapter->num_tx_queues;
+	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
 }
 
 static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 40291f3..5e6188d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1656,6 +1656,9 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
 	return (dev->num_tx_queues > 1);
 }
 
+extern void netif_set_real_num_tx_queues(struct net_device *dev,
+					 unsigned int txq);
+
 /* Use this variant when it is known for sure that it
  * is executing from hardware interrupt context or with hardware interrupts
  * disabled.
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ba749be..433604b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -313,13 +313,12 @@ extern void qdisc_calculate_pkt_len(struct sk_buff *skb,
 extern void tcf_destroy(struct tcf_proto *tp);
 extern void tcf_destroy_chain(struct tcf_proto **fl);
 
-/* Reset all TX qdiscs of a device.  */
-static inline void qdisc_reset_all_tx(struct net_device *dev)
+/* Reset all TX qdiscs greater then index of a device.  */
+static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
 {
-	unsigned int i;
 	struct Qdisc *qdisc;
 
-	for (i = 0; i < dev->num_tx_queues; i++) {
+	for (; i < dev->num_tx_queues; i++) {
 		qdisc = netdev_get_tx_queue(dev, i)->qdisc;
 		if (qdisc) {
 			spin_lock_bh(qdisc_lock(qdisc));
@@ -329,6 +328,11 @@ static inline void qdisc_reset_all_tx(struct net_device *dev)
 	}
 }
 
+static inline void qdisc_reset_all_tx(struct net_device *dev)
+{
+	qdisc_reset_all_tx_gt(dev, 0);
+}
+
 /* Are all TX queues of the device empty?  */
 static inline bool qdisc_all_tx_empty(const struct net_device *dev)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 2b3bf53..723a347 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1553,6 +1553,24 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 	rcu_read_unlock();
 }
 
+/*
+ * Routine to help set real_num_tx_queues. To avoid skbs mapped to queues
+ * greater then real_num_tx_queues stale skbs on the qdisc must be flushed.
+ */
+void netif_set_real_num_tx_queues(struct net_device *dev, unsigned int txq)
+{
+	unsigned int real_num = dev->real_num_tx_queues;
+
+	if (unlikely(txq > dev->num_tx_queues))
+		;
+	else if (txq > real_num)
+		dev->real_num_tx_queues = txq;
+	else if (txq < real_num) {
+		dev->real_num_tx_queues = txq;
+		qdisc_reset_all_tx_gt(dev, txq);
+	}
+}
+EXPORT_SYMBOL(netif_set_real_num_tx_queues);
 
 static inline void __netif_reschedule(struct Qdisc *q)
 {

