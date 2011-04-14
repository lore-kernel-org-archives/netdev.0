From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 23/24] ixgbe: DCB, misallocated packet buffer size with X540 device
Date: Wed, 13 Apr 2011 18:02:19 -0700
Message-ID: <1302742940-22141-24-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2477 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754929Ab1DNBD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:03:26 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The X540 device has a smaller packet buffer but the DCB configuration
never took this into account. Under stress this can result in the DMA
engine hanging and TX Unit hang occurring to reset the device. This
patch reworks the packet buffer allocation routine used for DCB on
82599 and X540 devices to account for RX packet buffer sizes.

This fixes the immediate hang. We should consolidate the various
hardware specific routines for configuring features into a single
routine. This will make it much harder to miss feature cases like
this.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c     |    3 ++
 drivers/net/ixgbe/ixgbe_82599.c     |    2 +
 drivers/net/ixgbe/ixgbe_dcb_82599.c |   68 +++++++++++++++++++++-------------
 drivers/net/ixgbe/ixgbe_dcb_82599.h |    2 +
 drivers/net/ixgbe/ixgbe_type.h      |    1 +
 drivers/net/ixgbe/ixgbe_x540.c      |    3 +-
 6 files changed, 52 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index af4054a..7a64f50 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -37,6 +37,7 @@
 #define IXGBE_82598_RAR_ENTRIES   16
 #define IXGBE_82598_MC_TBL_SIZE  128
 #define IXGBE_82598_VFT_TBL_SIZE 128
+#define IXGBE_82598_RX_PB_SIZE	 512
 
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw,
                                          ixgbe_link_speed speed,
@@ -224,6 +225,8 @@ static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
 	}
 
+	hw->mac.rx_pb_size = IXGBE_82598_RX_PB_SIZE;
+
 	/* set the completion timeout for interface */
 	if (ret_val == 0)
 		ixgbe_set_pcie_completion_timeout(hw);
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index e432305..b341ed8 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -38,6 +38,7 @@
 #define IXGBE_82599_RAR_ENTRIES   128
 #define IXGBE_82599_MC_TBL_SIZE   128
 #define IXGBE_82599_VFT_TBL_SIZE  128
+#define IXGBE_82599_RX_PB_SIZE	  512
 
 static void ixgbe_disable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
 static void ixgbe_enable_tx_laser_multispeed_fiber(struct ixgbe_hw *hw);
@@ -1765,6 +1766,7 @@ static s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
 
 	/* We need to run link autotry after the driver loads */
 	hw->mac.autotry_restart = true;
+	hw->mac.rx_pb_size = IXGBE_82599_RX_PB_SIZE;
 
 	if (ret_val == 0)
 		ret_val = ixgbe_verify_fw_version_82599(hw);
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 025af8c..865ddd8 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -39,36 +39,52 @@
  */
 static s32 ixgbe_dcb_config_packet_buffers_82599(struct ixgbe_hw *hw, u8 rx_pba)
 {
-	s32 ret_val = 0;
-	u32 value = IXGBE_RXPBSIZE_64KB;
+	int num_tcs = IXGBE_MAX_PACKET_BUFFERS;
+	u32 rx_pb_size = hw->mac.rx_pb_size << IXGBE_RXPBSIZE_SHIFT;
+	u32 rxpktsize;
+	u32 txpktsize;
+	u32 txpbthresh;
 	u8  i = 0;
 
-	/* Setup Rx packet buffer sizes */
-	switch (rx_pba) {
-	case pba_80_48:
-		/* Setup the first four at 80KB */
-		value = IXGBE_RXPBSIZE_80KB;
-		for (; i < 4; i++)
-			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), value);
-		/* Setup the last four at 48KB...don't re-init i */
-		value = IXGBE_RXPBSIZE_48KB;
-		/* Fall Through */
-	case pba_equal:
-	default:
-		for (; i < IXGBE_MAX_PACKET_BUFFERS; i++)
-			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), value);
-
-		/* Setup Tx packet buffer sizes */
-		for (i = 0; i < IXGBE_MAX_PACKET_BUFFERS; i++) {
-			IXGBE_WRITE_REG(hw, IXGBE_TXPBSIZE(i),
-			                IXGBE_TXPBSIZE_20KB);
-			IXGBE_WRITE_REG(hw, IXGBE_TXPBTHRESH(i),
-			                IXGBE_TXPBTHRESH_DCB);
-		}
-		break;
+	/*
+	 * This really means configure the first half of the TCs
+	 * (Traffic Classes) to use 5/8 of the Rx packet buffer
+	 * space.  To determine the size of the buffer for each TC,
+	 * we are multiplying the average size by 5/4 and applying
+	 * it to half of the traffic classes.
+	 */
+	if (rx_pba == pba_80_48) {
+		rxpktsize = (rx_pb_size * 5) / (num_tcs * 4);
+		rx_pb_size -= rxpktsize * (num_tcs / 2);
+		for (; i < (num_tcs / 2); i++)
+			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), rxpktsize);
+	}
+
+	/* Divide the remaining Rx packet buffer evenly among the TCs */
+	rxpktsize = rx_pb_size / (num_tcs - i);
+	for (; i < num_tcs; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), rxpktsize);
+
+	/*
+	 * Setup Tx packet buffer and threshold equally for all TCs
+	 * TXPBTHRESH register is set in K so divide by 1024 and subtract
+	 * 10 since the largest packet we support is just over 9K.
+	 */
+	txpktsize = IXGBE_TXPBSIZE_MAX / num_tcs;
+	txpbthresh = (txpktsize / 1024) - IXGBE_TXPKT_SIZE_MAX;
+	for (i = 0; i < num_tcs; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_TXPBSIZE(i), txpktsize);
+		IXGBE_WRITE_REG(hw, IXGBE_TXPBTHRESH(i), txpbthresh);
 	}
 
-	return ret_val;
+	/* Clear unused TCs, if any, to zero buffer size*/
+	for (; i < MAX_TRAFFIC_CLASS; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_TXPBSIZE(i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_TXPBTHRESH(i), 0);
+	}
+
+	return 0;
 }
 
 /**
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ixgbe/ixgbe_dcb_82599.h
index 148fd8b..2de71a5 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.h
@@ -92,8 +92,10 @@
 #define IXGBE_RXPBSIZE_64KB     0x00010000 /* 64KB Packet Buffer */
 #define IXGBE_RXPBSIZE_80KB     0x00014000 /* 80KB Packet Buffer */
 #define IXGBE_RXPBSIZE_128KB    0x00020000 /* 128KB Packet Buffer */
+#define IXGBE_TXPBSIZE_MAX	0x00028000 /* 160KB Packet Buffer*/
 
 #define IXGBE_TXPBTHRESH_DCB    0xA        /* THRESH value for DCB mode */
+#define IXGBE_TXPKT_SIZE_MAX    0xA        /* Max Tx Packet size  */
 
 /* SECTXMINIFG DCB */
 #define IXGBE_SECTX_DCB		0x00001F00 /* DCB TX Buffer IFG */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 15580d6..7d0b37d 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2606,6 +2606,7 @@ struct ixgbe_mac_info {
 	u32                             vft_size;
 	u32                             num_rar_entries;
 	u32                             rar_highwater;
+	u32				rx_pb_size;
 	u32                             max_tx_queues;
 	u32                             max_rx_queues;
 	u32                             max_msix_vectors;
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index 05f8e9c..932394f 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -37,6 +37,7 @@
 #define IXGBE_X540_RAR_ENTRIES   128
 #define IXGBE_X540_MC_TBL_SIZE   128
 #define IXGBE_X540_VFT_TBL_SIZE  128
+#define IXGBE_X540_RX_PB_SIZE	 384
 
 static s32 ixgbe_update_flash_X540(struct ixgbe_hw *hw);
 static s32 ixgbe_poll_flash_update_done_X540(struct ixgbe_hw *hw);
@@ -242,7 +243,7 @@ static s32 ixgbe_start_hw_X540(struct ixgbe_hw *hw)
 		goto out;
 
 	ret_val = ixgbe_start_hw_gen2(hw);
-
+	hw->mac.rx_pb_size = IXGBE_X540_RX_PB_SIZE;
 out:
 	return ret_val;
 }
-- 
1.7.4.2

