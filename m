From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] igb: Remove multi_tx_table and simplify igb_xmit_frame
Date: Tue, 20 Sep 2011 00:11:30 -0700
Message-ID: <1316502690-25488-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28383 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1ITHLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 03:11:37 -0400
In-Reply-To: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Instead of using the multi_tx_table to map possible Tx queues to Tx rings
we can just do simple subtraction for the unlikely event that the Tx queue
provided exceeds the number of Tx rings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    4 +--
 drivers/net/ethernet/intel/igb/igb_main.c |   36 +++++++++++++++++-----------
 2 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 8607a1d..b725937 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -63,8 +63,7 @@ struct igb_adapter;
 /* Transmit and receive queues */
 #define IGB_MAX_RX_QUEUES                  (adapter->vfs_allocated_count ? 2 : \
                                            (hw->mac.type > e1000_82575 ? 8 : 4))
-#define IGB_ABS_MAX_TX_QUEUES              8
-#define IGB_MAX_TX_QUEUES                  IGB_MAX_RX_QUEUES
+#define IGB_MAX_TX_QUEUES                  16
 
 #define IGB_MAX_VF_MC_ENTRIES              30
 #define IGB_MAX_VF_FUNCTIONS               8
@@ -324,7 +323,6 @@ struct igb_adapter {
 	/* to not mess up cache alignment, always add to the bottom */
 	u32 eeprom_wol;
 
-	struct igb_ring *multi_tx_table[IGB_ABS_MAX_TX_QUEUES];
 	u16 tx_ring_count;
 	u16 rx_ring_count;
 	unsigned int vfs_allocated_count;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 55d6431..7ad25e8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1875,7 +1875,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	err = -ENOMEM;
 	netdev = alloc_etherdev_mq(sizeof(struct igb_adapter),
-	                           IGB_ABS_MAX_TX_QUEUES);
+				   IGB_MAX_TX_QUEUES);
 	if (!netdev)
 		goto err_alloc_etherdev;
 
@@ -2620,10 +2620,6 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 		}
 	}
 
-	for (i = 0; i < IGB_ABS_MAX_TX_QUEUES; i++) {
-		int r_idx = i % adapter->num_tx_queues;
-		adapter->multi_tx_table[i] = adapter->tx_ring[r_idx];
-	}
 	return err;
 }
 
@@ -4363,12 +4359,21 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static inline struct igb_ring *igb_tx_queue_mapping(struct igb_adapter *adapter,
+						    struct sk_buff *skb)
+{
+	unsigned int r_idx = skb->queue_mapping;
+
+	if (r_idx >= adapter->num_tx_queues)
+		r_idx = r_idx % adapter->num_tx_queues;
+
+	return adapter->tx_ring[r_idx];
+}
+
 static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
 				  struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	struct igb_ring *tx_ring;
-	int r_idx = 0;
 
 	if (test_bit(__IGB_DOWN, &adapter->state)) {
 		dev_kfree_skb_any(skb);
@@ -4380,14 +4385,17 @@ static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	r_idx = skb->queue_mapping & (IGB_ABS_MAX_TX_QUEUES - 1);
-	tx_ring = adapter->multi_tx_table[r_idx];
+	/*
+	 * The minimum packet size with TCTL.PSP set is 17 so pad the skb
+	 * in order to meet this minimum size requirement.
+	 */
+	if (skb->len < 17) {
+		if (skb_padto(skb, 17))
+			return NETDEV_TX_OK;
+		skb->len = 17;
+	}
 
-	/* This goes back to the question of how to logically map a tx queue
-	 * to a flow.  Right now, performance is impacted slightly negatively
-	 * if using multiple tx queues.  If the stack breaks away from a
-	 * single qdisc implementation, we can look at this again. */
-	return igb_xmit_frame_ring(skb, tx_ring);
+	return igb_xmit_frame_ring(skb, igb_tx_queue_mapping(adapter, skb));
 }
 
 /**
-- 
1.7.6.2
