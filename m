From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] igb: Update RXDCTL/TXDCTL configurations
Date: Sat, 17 Sep 2011 01:04:26 -0700
Message-ID: <1316246677-8830-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752153Ab1IQIEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Sep 2011 04:04:42 -0400
In-Reply-To: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change cleans up the RXDCTL and TXDCTL configurations and optimizes RX
performance by allowing back write-backs on all hardware other than 82576.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    5 +++--
 drivers/net/ethernet/intel/igb/igb_main.c |   23 +++++++++--------------
 2 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 265e151..577fd3e 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -100,11 +100,12 @@ struct vf_data_storage {
  */
 #define IGB_RX_PTHRESH                     8
 #define IGB_RX_HTHRESH                     8
-#define IGB_RX_WTHRESH                     1
 #define IGB_TX_PTHRESH                     8
 #define IGB_TX_HTHRESH                     1
+#define IGB_RX_WTHRESH                     ((hw->mac.type == e1000_82576 && \
+					     adapter->msix_entries) ? 1 : 4)
 #define IGB_TX_WTHRESH                     ((hw->mac.type == e1000_82576 && \
-                                             adapter->msix_entries) ? 1 : 16)
+					     adapter->msix_entries) ? 1 : 16)
 
 /* this is the size past which hardware will drop packets when setting LPE=0 */
 #define MAXIMUM_ETHERNET_VLAN_SIZE 1522
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3cb1bc9..aa78c10 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2666,14 +2666,12 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
                            struct igb_ring *ring)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 txdctl;
+	u32 txdctl = 0;
 	u64 tdba = ring->dma;
 	int reg_idx = ring->reg_idx;
 
 	/* disable the queue */
-	txdctl = rd32(E1000_TXDCTL(reg_idx));
-	wr32(E1000_TXDCTL(reg_idx),
-	                txdctl & ~E1000_TXDCTL_QUEUE_ENABLE);
+	wr32(E1000_TXDCTL(reg_idx), 0);
 	wrfl();
 	mdelay(10);
 
@@ -2685,7 +2683,7 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 
 	ring->head = hw->hw_addr + E1000_TDH(reg_idx);
 	ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
-	writel(0, ring->head);
+	wr32(E1000_TDH(reg_idx), 0);
 	writel(0, ring->tail);
 
 	txdctl |= IGB_TX_PTHRESH;
@@ -3028,12 +3026,10 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	struct e1000_hw *hw = &adapter->hw;
 	u64 rdba = ring->dma;
 	int reg_idx = ring->reg_idx;
-	u32 srrctl, rxdctl;
+	u32 srrctl = 0, rxdctl = 0;
 
 	/* disable the queue */
-	rxdctl = rd32(E1000_RXDCTL(reg_idx));
-	wr32(E1000_RXDCTL(reg_idx),
-	                rxdctl & ~E1000_RXDCTL_QUEUE_ENABLE);
+	wr32(E1000_RXDCTL(reg_idx), 0);
 
 	/* Set DMA base address registers */
 	wr32(E1000_RDBAL(reg_idx),
@@ -3045,7 +3041,7 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	/* initialize head and tail */
 	ring->head = hw->hw_addr + E1000_RDH(reg_idx);
 	ring->tail = hw->hw_addr + E1000_RDT(reg_idx);
-	writel(0, ring->head);
+	wr32(E1000_RDH(reg_idx), 0);
 	writel(0, ring->tail);
 
 	/* set descriptor configuration */
@@ -3076,13 +3072,12 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	/* set filtering for VMDQ pools */
 	igb_set_vmolr(adapter, reg_idx & 0x7, true);
 
-	/* enable receive descriptor fetching */
-	rxdctl = rd32(E1000_RXDCTL(reg_idx));
-	rxdctl |= E1000_RXDCTL_QUEUE_ENABLE;
-	rxdctl &= 0xFFF00000;
 	rxdctl |= IGB_RX_PTHRESH;
 	rxdctl |= IGB_RX_HTHRESH << 8;
 	rxdctl |= IGB_RX_WTHRESH << 16;
+
+	/* enable receive descriptor fetching */
+	rxdctl |= E1000_RXDCTL_QUEUE_ENABLE;
 	wr32(E1000_RXDCTL(reg_idx), rxdctl);
 }
 
-- 
1.7.6
