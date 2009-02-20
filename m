From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/5] igb: add vfs_allocated_count as placeholder for
	number of vfs
Date: Thu, 19 Feb 2009 20:39:23 -0800
Message-ID: <20090220043922.29650.58034.stgit@lost.foo-projects.org>
References: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Yu Zhao <yu.zhao@intel.com>,
	LKML <linux-kernel@vger.kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:45693 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753320AbZBTEjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 23:39:44 -0500
In-Reply-To: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This is the first step in supporting sr-iov.  The vf_allocated_count value
will be 0 until we actually have vfs present.  In the meantime it
represents an offset value for the start of the queues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Yu Zhao <yu.zhao@intel.com>
CC: LKML <linux-kernel@vger.kernel.org>
---

 drivers/net/igb/igb.h      |    9 ++++++---
 drivers/net/igb/igb_main.c |   17 +++++++++++------
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 49fc0da..3d3e5f6 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -57,8 +57,10 @@ struct igb_adapter;
 #define IGB_MIN_ITR_USECS                 10
 
 /* Transmit and receive queues */
-#define IGB_MAX_RX_QUEUES                  4
-#define IGB_MAX_TX_QUEUES                  4
+#define IGB_MAX_RX_QUEUES     (adapter->vfs_allocated_count ? \
+                               (adapter->vfs_allocated_count > 6 ? 1 : 2) : 4)
+#define IGB_MAX_TX_QUEUES     IGB_MAX_RX_QUEUES
+#define IGB_ABS_MAX_TX_QUEUES     4
 
 /* RX descriptor control thresholds.
  * PTHRESH - MAC will consider prefetch if it has fewer than this number of
@@ -267,9 +269,10 @@ struct igb_adapter {
 	unsigned int flags;
 	u32 eeprom_wol;
 
-	struct igb_ring *multi_tx_table[IGB_MAX_TX_QUEUES];
+	struct igb_ring *multi_tx_table[IGB_ABS_MAX_TX_QUEUES];
 	unsigned int tx_ring_count;
 	unsigned int rx_ring_count;
+	unsigned int vfs_allocated_count;
 };
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d2cd58b..014570a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -312,6 +312,7 @@ module_exit(igb_exit_module);
 static void igb_cache_ring_register(struct igb_adapter *adapter)
 {
 	int i;
+	unsigned int rbase_offset = adapter->vfs_allocated_count;
 
 	switch (adapter->hw.mac.type) {
 	case e1000_82576:
@@ -321,9 +322,11 @@ static void igb_cache_ring_register(struct igb_adapter *adapter)
 		 * and continue consuming queues in the same sequence
 		 */
 		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i].reg_idx = Q_IDX_82576(i);
+			adapter->rx_ring[i].reg_idx = rbase_offset +
+			                              Q_IDX_82576(i);
 		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i].reg_idx = Q_IDX_82576(i);
+			adapter->tx_ring[i].reg_idx = rbase_offset +
+			                              Q_IDX_82576(i);
 		break;
 	case e1000_82575:
 	default:
@@ -423,7 +426,7 @@ static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 		   a vector number along with a "valid" bit.  Sadly, the layout
 		   of the table is somewhat counterintuitive. */
 		if (rx_queue > IGB_N0_QUEUE) {
-			index = (rx_queue >> 1);
+			index = (rx_queue >> 1) + adapter->vfs_allocated_count;
 			ivar = array_rd32(E1000_IVAR0, index);
 			if (rx_queue & 0x1) {
 				/* vector goes into third byte of register */
@@ -438,7 +441,7 @@ static void igb_assign_vector(struct igb_adapter *adapter, int rx_queue,
 			array_wr32(E1000_IVAR0, index, ivar);
 		}
 		if (tx_queue > IGB_N0_QUEUE) {
-			index = (tx_queue >> 1);
+			index = (tx_queue >> 1) + adapter->vfs_allocated_count;
 			ivar = array_rd32(E1000_IVAR0, index);
 			if (tx_queue & 0x1) {
 				/* vector goes into high byte of register */
@@ -1157,7 +1160,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	pci_save_state(pdev);
 
 	err = -ENOMEM;
-	netdev = alloc_etherdev_mq(sizeof(struct igb_adapter), IGB_MAX_TX_QUEUES);
+	netdev = alloc_etherdev_mq(sizeof(struct igb_adapter),
+	                           IGB_ABS_MAX_TX_QUEUES);
 	if (!netdev)
 		goto err_alloc_etherdev;
 
@@ -2029,6 +2033,7 @@ static void igb_configure_rx(struct igb_adapter *adapter)
 				writel(reta.dword,
 				       hw->hw_addr + E1000_RETA(0) + (j & ~3));
 		}
+
 		mrqc = E1000_MRQC_ENABLE_RSS_4Q;
 
 		/* Fill out hash function seeds */
@@ -3150,7 +3155,7 @@ static int igb_xmit_frame_adv(struct sk_buff *skb, struct net_device *netdev)
 	struct igb_ring *tx_ring;
 
 	int r_idx = 0;
-	r_idx = skb->queue_mapping & (IGB_MAX_TX_QUEUES - 1);
+	r_idx = skb->queue_mapping & (IGB_ABS_MAX_TX_QUEUES - 1);
 	tx_ring = adapter->multi_tx_table[r_idx];
 
 	/* This goes back to the question of how to logically map a tx queue

