From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] ixgbevf: Cleanup handling of configuration for jumbo frames
Date: Thu, 30 Aug 2012 22:16:14 -0700
Message-ID: <1346390174-30449-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39778 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309Ab2HaFQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 01:16:43 -0400
In-Reply-To: <1346390174-30449-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves the code for notifying the PF of the VF maximum packet
size into the vf.c file.  The main motivation behind this is that the vf.c
file is supposed to contain all of the messages used when communicating
with the PF.

In addition it creates a separate function for setting the Rx buffer size
so that we have on centralized area to review what buffer sizes will be
requested by the VF.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 67 ++++++++++++++---------
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 14 +++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
 4 files changed, 58 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 98cadb0..eb26fda 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -101,7 +101,9 @@ struct ixgbevf_ring {
 
 /* Supported Rx Buffer Sizes */
 #define IXGBEVF_RXBUFFER_256   256    /* Used for packet split */
-#define IXGBEVF_RXBUFFER_2048  2048
+#define IXGBEVF_RXBUFFER_3K    3072
+#define IXGBEVF_RXBUFFER_7K    7168
+#define IXGBEVF_RXBUFFER_15K   15360
 #define IXGBEVF_MAX_RXBUFFER   16384  /* largest size for single descriptor */
 
 #define IXGBEVF_RX_HDR_SIZE IXGBEVF_RXBUFFER_256
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 87f87d8..a5d9cc5 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1057,15 +1057,46 @@ static void ixgbevf_configure_srrctl(struct ixgbevf_adapter *adapter, int index)
 
 	srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
 
-	if (rx_ring->rx_buf_len == MAXIMUM_ETHERNET_VLAN_SIZE)
-		srrctl |= IXGBEVF_RXBUFFER_2048 >>
-			IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-	else
-		srrctl |= rx_ring->rx_buf_len >>
-			IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+	srrctl |= ALIGN(rx_ring->rx_buf_len, 1024) >>
+		  IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+
 	IXGBE_WRITE_REG(hw, IXGBE_VFSRRCTL(index), srrctl);
 }
 
+static void ixgbevf_set_rx_buffer_len(struct ixgbevf_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	int i;
+	u16 rx_buf_len;
+
+	/* notify the PF of our intent to use this size of frame */
+	ixgbevf_rlpml_set_vf(hw, max_frame);
+
+	/* PF will allow an extra 4 bytes past for vlan tagged frames */
+	max_frame += VLAN_HLEN;
+
+	/*
+	 * Make best use of allocation by using all but 1K of a
+	 * power of 2 allocation that will be used for skb->head.
+	 */
+	if ((hw->mac.type == ixgbe_mac_X540_vf) &&
+	    (max_frame <= MAXIMUM_ETHERNET_VLAN_SIZE))
+		rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
+	else if (max_frame <= IXGBEVF_RXBUFFER_3K)
+		rx_buf_len = IXGBEVF_RXBUFFER_3K;
+	else if (max_frame <= IXGBEVF_RXBUFFER_7K)
+		rx_buf_len = IXGBEVF_RXBUFFER_7K;
+	else if (max_frame <= IXGBEVF_RXBUFFER_15K)
+		rx_buf_len = IXGBEVF_RXBUFFER_15K;
+	else
+		rx_buf_len = IXGBEVF_MAX_RXBUFFER;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
+}
+
 /**
  * ixgbevf_configure_rx - Configure 82599 VF Receive Unit after Reset
  * @adapter: board private structure
@@ -1076,18 +1107,14 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 {
 	u64 rdba;
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
-	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i, j;
 	u32 rdlen;
-	int rx_buf_len;
 
 	/* PSRTYPE must be initialized in 82599 */
 	IXGBE_WRITE_REG(hw, IXGBE_VFPSRTYPE, 0);
-	if (netdev->mtu <= ETH_DATA_LEN)
-		rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
-	else
-		rx_buf_len = ALIGN(max_frame, 1024);
+
+	/* set_rx_buffer_len must be called before ring initialization */
+	ixgbevf_set_rx_buffer_len(adapter);
 
 	rdlen = adapter->rx_ring[0].count * sizeof(union ixgbe_adv_rx_desc);
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
@@ -1103,7 +1130,6 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_VFRDT(j), 0);
 		adapter->rx_ring[i].head = IXGBE_VFRDH(j);
 		adapter->rx_ring[i].tail = IXGBE_VFRDT(j);
-		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
 
 		ixgbevf_configure_srrctl(adapter, j);
 	}
@@ -1315,7 +1341,6 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	int i, j = 0;
 	int num_rx_rings = adapter->num_rx_queues;
 	u32 txdctl, rxdctl;
-	u32 msg[2];
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		j = adapter->tx_ring[i].reg_idx;
@@ -1356,10 +1381,6 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 			hw->mac.ops.set_rar(hw, 0, hw->mac.perm_addr, 0);
 	}
 
-	msg[0] = IXGBE_VF_SET_LPE;
-	msg[1] = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
-	hw->mbx.ops.write_posted(hw, msg, 2);
-
 	spin_unlock(&adapter->mbx_lock);
 
 	clear_bit(__IXGBEVF_DOWN, &adapter->state);
@@ -2876,10 +2897,8 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
 static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 	int max_possible_frame = MAXIMUM_ETHERNET_VLAN_SIZE;
-	u32 msg[2];
 
 	if (adapter->hw.mac.type == ixgbe_mac_X540_vf)
 		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
@@ -2893,12 +2912,6 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
 
-	if (!netif_running(netdev)) {
-		msg[0] = IXGBE_VF_SET_LPE;
-		msg[1] = max_frame;
-		hw->mbx.ops.write_posted(hw, msg, 2);
-	}
-
 	if (netif_running(netdev))
 		ixgbevf_reinit_locked(adapter);
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index ec89b86..3d555a1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -419,6 +419,20 @@ static s32 ixgbevf_check_mac_link_vf(struct ixgbe_hw *hw,
 	return 0;
 }
 
+/**
+ *  ixgbevf_rlpml_set_vf - Set the maximum receive packet length
+ *  @hw: pointer to the HW structure
+ *  @max_size: value to assign to max frame size
+ **/
+void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size)
+{
+	u32 msgbuf[2];
+
+	msgbuf[0] = IXGBE_VF_SET_LPE;
+	msgbuf[1] = max_size;
+	ixgbevf_write_msg_read_ack(hw, msgbuf, 2);
+}
+
 static const struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.init_hw             = ixgbevf_init_hw_vf,
 	.reset_hw            = ixgbevf_reset_hw_vf,
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 25c951d..07fd876 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -170,5 +170,6 @@ struct ixgbevf_info {
 	const struct ixgbe_mac_operations *mac_ops;
 };
 
+void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size);
 #endif /* __IXGBE_VF_H__ */
 
-- 
1.7.11.4
