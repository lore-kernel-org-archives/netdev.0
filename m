From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] e1000: fix flow control thresholds
Date: Mon, 06 Jul 2009 13:45:01 -0700
Message-ID: <20090706204500.17533.25042.stgit@localhost.localdomain>
References: <20090706204358.17533.64103.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:33013
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753316AbZGFUpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 16:45:15 -0400
In-Reply-To: <20090706204358.17533.64103.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

when testing the jumbo frames with pages patch, the stats would
show rx_missed errors (dropped packets) even when connected to a
link partner with flow control enabled.

this indicates that for this MTU (9000) the flow control
thresholds are not adjusting correctly.

In fact, before this change, the FCRTH (xoff threshold) is 36864
when the fifo size is only 40000, with 9000 byte MTU.

fix it so that we at least have room for one frame after we send
the xoff.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_hw.c   |    2 +
 drivers/net/e1000/e1000_hw.h   |    3 --
 drivers/net/e1000/e1000_main.c |   58 ++++++++++++++++++++++------------------
 3 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index e1a3fc1..1e5ae11 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -1955,7 +1955,7 @@ static s32 e1000_setup_copper_link(struct e1000_hw *hw)
     s32 ret_val;
     u16 i;
     u16 phy_data;
-    u16 reg_data;
+    u16 reg_data = 0;
 
     DEBUGFUNC("e1000_setup_copper_link");
 
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 99fce2c..a8866bd 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -523,11 +523,8 @@ s32 e1000_check_phy_reset_block(struct e1000_hw *hw);
 
 /* The sizes (in bytes) of a ethernet packet */
 #define ENET_HEADER_SIZE             14
-#define MAXIMUM_ETHERNET_FRAME_SIZE  1518 /* With FCS */
 #define MINIMUM_ETHERNET_FRAME_SIZE  64   /* With FCS */
 #define ETHERNET_FCS_SIZE            4
-#define MAXIMUM_ETHERNET_PACKET_SIZE \
-    (MAXIMUM_ETHERNET_FRAME_SIZE - ETHERNET_FCS_SIZE)
 #define MINIMUM_ETHERNET_PACKET_SIZE \
     (MINIMUM_ETHERNET_FRAME_SIZE - ETHERNET_FCS_SIZE)
 #define CRC_LENGTH                   ETHERNET_FCS_SIZE
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f2db9e2..d7df00c 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -641,8 +641,8 @@ void e1000_reset(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 pba = 0, tx_space, min_tx_space, min_rx_space;
-	u16 fc_high_water_mark = E1000_FC_HIGH_DIFF;
 	bool legacy_pba_adjust = false;
+	u16 hwm;
 
 	/* Repartition Pba for greater than 9k mtu
 	 * To take effect CTRL.RST is required.
@@ -686,7 +686,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 	}
 
 	if (legacy_pba_adjust) {
-		if (adapter->netdev->mtu > E1000_RXBUFFER_8192)
+		if (hw->max_frame_size > E1000_RXBUFFER_8192)
 			pba -= 8; /* allocate more FIFO for Tx */
 
 		if (hw->mac_type == e1000_82547) {
@@ -696,14 +696,14 @@ void e1000_reset(struct e1000_adapter *adapter)
 				(E1000_PBA_40K - pba) << E1000_PBA_BYTES_SHIFT;
 			atomic_set(&adapter->tx_fifo_stall, 0);
 		}
-	} else if (hw->max_frame_size > MAXIMUM_ETHERNET_FRAME_SIZE) {
+	} else if (hw->max_frame_size >  ETH_FRAME_LEN + ETH_FCS_LEN) {
 		/* adjust PBA for jumbo frames */
 		ew32(PBA, pba);
 
 		/* To maintain wire speed transmits, the Tx FIFO should be
-		 * large enough to accomodate two full transmit packets,
+		 * large enough to accommodate two full transmit packets,
 		 * rounded up to the next 1KB and expressed in KB.  Likewise,
-		 * the Rx FIFO should be large enough to accomodate at least
+		 * the Rx FIFO should be large enough to accommodate at least
 		 * one full receive packet and is similarly rounded up and
 		 * expressed in KB. */
 		pba = er32(PBA);
@@ -711,13 +711,17 @@ void e1000_reset(struct e1000_adapter *adapter)
 		tx_space = pba >> 16;
 		/* lower 16 bits has Rx packet buffer allocation size in KB */
 		pba &= 0xffff;
-		/* don't include ethernet FCS because hardware appends/strips */
-		min_rx_space = adapter->netdev->mtu + ENET_HEADER_SIZE +
-		               VLAN_TAG_SIZE;
-		min_tx_space = min_rx_space;
-		min_tx_space *= 2;
+		/*
+		 * the tx fifo also stores 16 bytes of information about the tx
+		 * but don't include ethernet FCS because hardware appends it
+		 */
+		min_tx_space = (hw->max_frame_size +
+		                sizeof(struct e1000_tx_desc) -
+		                ETH_FCS_LEN) * 2;
 		min_tx_space = ALIGN(min_tx_space, 1024);
 		min_tx_space >>= 10;
+		/* software strips receive CRC, so leave room for it */
+		min_rx_space = hw->max_frame_size;
 		min_rx_space = ALIGN(min_rx_space, 1024);
 		min_rx_space >>= 10;
 
@@ -754,19 +758,21 @@ void e1000_reset(struct e1000_adapter *adapter)
 
 	ew32(PBA, pba);
 
-	/* flow control settings */
-	/* Set the FC high water mark to 90% of the FIFO size.
-	 * Required to clear last 3 LSB */
-	fc_high_water_mark = ((pba * 9216)/10) & 0xFFF8;
-	/* We can't use 90% on small FIFOs because the remainder
-	 * would be less than 1 full frame.  In this case, we size
-	 * it to allow at least a full frame above the high water
-	 *  mark. */
-	if (pba < E1000_PBA_16K)
-		fc_high_water_mark = (pba * 1024) - 1600;
-
-	hw->fc_high_water = fc_high_water_mark;
-	hw->fc_low_water = fc_high_water_mark - 8;
+	/*
+	 * flow control settings:
+	 * The high water mark must be low enough to fit one full frame
+	 * (or the size used for early receive) above it in the Rx FIFO.
+	 * Set it to the lower of:
+	 * - 90% of the Rx FIFO size, and
+	 * - the full Rx FIFO size minus the early receive size (for parts
+	 *   with ERT support assuming ERT set to E1000_ERT_2048), or
+	 * - the full Rx FIFO size minus one full frame
+	 */
+	hwm = min(((pba << 10) * 9 / 10),
+		  ((pba << 10) - hw->max_frame_size));
+
+	hw->fc_high_water = hwm & 0xFFF8;	/* 8-byte granularity */
+	hw->fc_low_water = hw->fc_high_water - 8;
 	hw->fc_pause_time = E1000_FC_PAUSE_TIME;
 	hw->fc_send_xon = 1;
 	hw->fc = hw->original_fc;
@@ -3474,7 +3480,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	switch (hw->mac_type) {
 	case e1000_undefined ... e1000_82542_rev2_1:
 	case e1000_ich8lan:
-		if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
+		if (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
 			DPRINTK(PROBE, ERR, "Jumbo Frames not supported.\n");
 			return -EINVAL;
 		}
@@ -3487,7 +3493,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		                  &eeprom_data);
 		if ((hw->device_id != E1000_DEV_ID_82573L) ||
 		    (eeprom_data & EEPROM_WORD1A_ASPM_MASK)) {
-			if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
+			if (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
 				DPRINTK(PROBE, ERR,
 			            	"Jumbo Frames not supported.\n");
 				return -EINVAL;
@@ -3535,7 +3541,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
 	if (!hw->tbi_compatibility_on &&
-	    ((max_frame == MAXIMUM_ETHERNET_FRAME_SIZE) ||
+	    ((max_frame == (ETH_FRAME_LEN + ETH_FCS_LEN)) ||
 	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE)))
 		adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 

