From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] ixgbe: Update link flow control to correctly handle multiple packet buffer DCB
Date: Fri,  4 May 2012 03:35:16 -0700
Message-ID: <1336127716-20383-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55510 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755305Ab2EDKfX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 06:35:23 -0400
In-Reply-To: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change updates the link flow control configuration so that we
correctly set the link flow control settings for DCB.  Previously we would
have to call the fc_enable call 8 times, once for each packet buffer.  If
we move that logic into the fc_enable call itself we can avoid multiple
unnecessary register writes.

This change also corrects an issue in which we were only shifting the water
marks for 82599 parts by 6 instead of 10.  This was resulting in us only
using 1/16 of the packet buffer when flow control was enabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |   61 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |  164 +++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |   13 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   16 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |    4 +-
 6 files changed, 102 insertions(+), 158 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index badcf82..4253733 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -324,24 +324,33 @@ out:
 /**
  *  ixgbe_fc_enable_82598 - Enable flow control
  *  @hw: pointer to hardware structure
- *  @packetbuf_num: packet buffer number (0-7)
  *
  *  Enable flow control according to the current settings.
  **/
-static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
+static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw)
 {
 	s32 ret_val = 0;
 	u32 fctrl_reg;
 	u32 rmcs_reg;
 	u32 reg;
+	u32 fcrtl, fcrth;
 	u32 link_speed = 0;
+	int i;
 	bool link_up;
 
-#ifdef CONFIG_DCB
-	if (hw->fc.requested_mode == ixgbe_fc_pfc)
+	/*
+	 * Validate the water mark configuration for packet buffer 0.  Zero
+	 * water marks indicate that the packet buffer was not configured
+	 * and the watermarks for packet buffer 0 should always be configured.
+	 */
+	if (!hw->fc.low_water ||
+	    !hw->fc.high_water[0] ||
+	    !hw->fc.pause_time) {
+		hw_dbg(hw, "Invalid water mark configuration\n");
+		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
 		goto out;
+	}
 
-#endif /* CONFIG_DCB */
 	/*
 	 * On 82598 having Rx FC on causes resets while doing 1G
 	 * so if it's on turn it off once we know link_speed. For
@@ -380,9 +389,6 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * 2: Tx flow control is enabled (we can send pause frames but
 	 *     we do not support receiving pause frames).
 	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
-#ifdef CONFIG_DCB
-	 * 4: Priority Flow Control is enabled.
-#endif
 	 * other: Invalid.
 	 */
 	switch (hw->fc.current_mode) {
@@ -415,11 +421,6 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 		fctrl_reg |= IXGBE_FCTRL_RFCE;
 		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
 		break;
-#ifdef CONFIG_DCB
-	case ixgbe_fc_pfc:
-		goto out;
-		break;
-#endif /* CONFIG_DCB */
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = IXGBE_ERR_CONFIG;
@@ -432,29 +433,29 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl_reg);
 	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
 
-	/* Set up and enable Rx high/low water mark thresholds, enable XON. */
-	if (hw->fc.current_mode & ixgbe_fc_tx_pause) {
-		reg = hw->fc.low_water << 6;
-		if (hw->fc.send_xon)
-			reg |= IXGBE_FCRTL_XONE;
+	fcrtl = (hw->fc.low_water << 10) | IXGBE_FCRTL_XONE;
 
-		IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num), reg);
-
-		reg = hw->fc.high_water[packetbuf_num] << 6;
-		reg |= IXGBE_FCRTH_FCEN;
+	/* Set up and enable Rx high/low water mark thresholds, enable XON. */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		if ((hw->fc.current_mode & ixgbe_fc_tx_pause) &&
+		    hw->fc.high_water[i]) {
+			fcrth = (hw->fc.high_water[i] << 10) | IXGBE_FCRTH_FCEN;
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(i), fcrtl);
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTH(i), fcrth);
+		} else {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(i), 0);
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTH(i), 0);
+		}
 
-		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(packetbuf_num), reg);
 	}
 
 	/* Configure pause time (2 TCs per register) */
-	reg = IXGBE_READ_REG(hw, IXGBE_FCTTV(packetbuf_num / 2));
-	if ((packetbuf_num & 1) == 0)
-		reg = (reg & 0xFFFF0000) | hw->fc.pause_time;
-	else
-		reg = (reg & 0x0000FFFF) | (hw->fc.pause_time << 16);
-	IXGBE_WRITE_REG(hw, IXGBE_FCTTV(packetbuf_num / 2), reg);
+	reg = hw->fc.pause_time * 0x00010001;
+	for (i = 0; i < (MAX_TRAFFIC_CLASS / 2); i++)
+		IXGBE_WRITE_REG(hw, IXGBE_FCTTV(i), reg);
 
-	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, (hw->fc.pause_time >> 1));
+	/* Configure flow control refresh threshold value */
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, hw->fc.pause_time / 2);
 
 out:
 	return ret_val;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 3035f19..c7e51b8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -84,39 +84,12 @@ static s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
  *
  *  Called at init time to set up flow control.
  **/
-static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
+static s32 ixgbe_setup_fc(struct ixgbe_hw *hw)
 {
 	s32 ret_val = 0;
 	u32 reg = 0, reg_bp = 0;
 	u16 reg_cu = 0;
 
-#ifdef CONFIG_DCB
-	if (hw->fc.requested_mode == ixgbe_fc_pfc) {
-		hw->fc.current_mode = hw->fc.requested_mode;
-		goto out;
-	}
-
-#endif /* CONFIG_DCB */
-	/* Validate the packetbuf configuration */
-	if (packetbuf_num < 0 || packetbuf_num > 7) {
-		hw_dbg(hw, "Invalid packet buffer number [%d], expected range is 0-7\n",
-		       packetbuf_num);
-		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
-		goto out;
-	}
-
-	/*
-	 * Validate the water mark configuration.  Zero water marks are invalid
-	 * because it causes the controller to just blast out fc packets.
-	 */
-	if (!hw->fc.low_water ||
-	    !hw->fc.high_water[packetbuf_num] ||
-	    !hw->fc.pause_time) {
-		hw_dbg(hw, "Invalid water mark configuration\n");
-		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
-		goto out;
-	}
-
 	/*
 	 * Validate the requested mode.  Strict IEEE mode does not allow
 	 * ixgbe_fc_rx_pause because it will cause us to fail at UNH.
@@ -139,21 +112,18 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * HW will be able to do fc autoneg once the cable is plugged in.  If
 	 * we link at 10G, the 1G advertisement is harmless and vice versa.
 	 */
-
 	switch (hw->phy.media_type) {
 	case ixgbe_media_type_fiber:
 	case ixgbe_media_type_backplane:
 		reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANA);
 		reg_bp = IXGBE_READ_REG(hw, IXGBE_AUTOC);
 		break;
-
 	case ixgbe_media_type_copper:
 		hw->phy.ops.read_reg(hw, MDIO_AN_ADVERTISE,
 					MDIO_MMD_AN, &reg_cu);
 		break;
-
 	default:
-		;
+		break;
 	}
 
 	/*
@@ -164,9 +134,6 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * 2: Tx flow control is enabled (we can send pause frames but
 	 *    we do not support receiving pause frames).
 	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
-#ifdef CONFIG_DCB
-	 * 4: Priority Flow Control is enabled.
-#endif
 	 * other: Invalid.
 	 */
 	switch (hw->fc.requested_mode) {
@@ -179,51 +146,40 @@ static s32 ixgbe_setup_fc(struct ixgbe_hw *hw, s32 packetbuf_num)
 		else if (hw->phy.media_type == ixgbe_media_type_copper)
 			reg_cu &= ~(IXGBE_TAF_SYM_PAUSE | IXGBE_TAF_ASM_PAUSE);
 		break;
-	case ixgbe_fc_rx_pause:
-		/*
-		 * Rx Flow control is enabled and Tx Flow control is
-		 * disabled by software override. Since there really
-		 * isn't a way to advertise that we are capable of RX
-		 * Pause ONLY, we will advertise that we support both
-		 * symmetric and asymmetric Rx PAUSE.  Later, we will
-		 * disable the adapter's ability to send PAUSE frames.
-		 */
-		reg |= (IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
-		if (hw->phy.media_type == ixgbe_media_type_backplane)
-			reg_bp |= (IXGBE_AUTOC_SYM_PAUSE |
-				   IXGBE_AUTOC_ASM_PAUSE);
-		else if (hw->phy.media_type == ixgbe_media_type_copper)
-			reg_cu |= (IXGBE_TAF_SYM_PAUSE | IXGBE_TAF_ASM_PAUSE);
-		break;
 	case ixgbe_fc_tx_pause:
 		/*
 		 * Tx Flow control is enabled, and Rx Flow control is
 		 * disabled by software override.
 		 */
-		reg |= (IXGBE_PCS1GANA_ASM_PAUSE);
-		reg &= ~(IXGBE_PCS1GANA_SYM_PAUSE);
+		reg |= IXGBE_PCS1GANA_ASM_PAUSE;
+		reg &= ~IXGBE_PCS1GANA_SYM_PAUSE;
 		if (hw->phy.media_type == ixgbe_media_type_backplane) {
-			reg_bp |= (IXGBE_AUTOC_ASM_PAUSE);
-			reg_bp &= ~(IXGBE_AUTOC_SYM_PAUSE);
+			reg_bp |= IXGBE_AUTOC_ASM_PAUSE;
+			reg_bp &= ~IXGBE_AUTOC_SYM_PAUSE;
 		} else if (hw->phy.media_type == ixgbe_media_type_copper) {
-			reg_cu |= (IXGBE_TAF_ASM_PAUSE);
-			reg_cu &= ~(IXGBE_TAF_SYM_PAUSE);
+			reg_cu |= IXGBE_TAF_ASM_PAUSE;
+			reg_cu &= ~IXGBE_TAF_SYM_PAUSE;
 		}
 		break;
+	case ixgbe_fc_rx_pause:
+		/*
+		 * Rx Flow control is enabled and Tx Flow control is
+		 * disabled by software override. Since there really
+		 * isn't a way to advertise that we are capable of RX
+		 * Pause ONLY, we will advertise that we support both
+		 * symmetric and asymmetric Rx PAUSE, as such we fall
+		 * through to the fc_full statement.  Later, we will
+		 * disable the adapter's ability to send PAUSE frames.
+		 */
 	case ixgbe_fc_full:
 		/* Flow control (both Rx and Tx) is enabled by SW override. */
-		reg |= (IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE);
+		reg |= IXGBE_PCS1GANA_SYM_PAUSE | IXGBE_PCS1GANA_ASM_PAUSE;
 		if (hw->phy.media_type == ixgbe_media_type_backplane)
-			reg_bp |= (IXGBE_AUTOC_SYM_PAUSE |
-				   IXGBE_AUTOC_ASM_PAUSE);
+			reg_bp |= IXGBE_AUTOC_SYM_PAUSE |
+				  IXGBE_AUTOC_ASM_PAUSE;
 		else if (hw->phy.media_type == ixgbe_media_type_copper)
-			reg_cu |= (IXGBE_TAF_SYM_PAUSE | IXGBE_TAF_ASM_PAUSE);
-		break;
-#ifdef CONFIG_DCB
-	case ixgbe_fc_pfc:
-		goto out;
+			reg_cu |= IXGBE_TAF_SYM_PAUSE | IXGBE_TAF_ASM_PAUSE;
 		break;
-#endif /* CONFIG_DCB */
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = IXGBE_ERR_CONFIG;
@@ -298,7 +254,7 @@ s32 ixgbe_start_hw_generic(struct ixgbe_hw *hw)
 	IXGBE_WRITE_FLUSH(hw);
 
 	/* Setup flow control */
-	ixgbe_setup_fc(hw, 0);
+	ixgbe_setup_fc(hw);
 
 	/* Clear adapter stopped flag */
 	hw->adapter_stopped = false;
@@ -2126,28 +2082,36 @@ s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw)
 /**
  *  ixgbe_fc_enable_generic - Enable flow control
  *  @hw: pointer to hardware structure
- *  @packetbuf_num: packet buffer number (0-7)
  *
  *  Enable flow control according to the current settings.
  **/
-s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
+s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw)
 {
 	s32 ret_val = 0;
 	u32 mflcn_reg, fccfg_reg;
 	u32 reg;
 	u32 fcrtl, fcrth;
+	int i;
 
-#ifdef CONFIG_DCB
-	if (hw->fc.requested_mode == ixgbe_fc_pfc)
+	/*
+	 * Validate the water mark configuration for packet buffer 0.  Zero
+	 * water marks indicate that the packet buffer was not configured
+	 * and the watermarks for packet buffer 0 should always be configured.
+	 */
+	if (!hw->fc.low_water ||
+	    !hw->fc.high_water[0] ||
+	    !hw->fc.pause_time) {
+		hw_dbg(hw, "Invalid water mark configuration\n");
+		ret_val = IXGBE_ERR_INVALID_LINK_SETTINGS;
 		goto out;
+	}
 
-#endif /* CONFIG_DCB */
 	/* Negotiate the fc mode to use */
 	ixgbe_fc_autoneg(hw);
 
 	/* Disable any previous flow control settings */
 	mflcn_reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
-	mflcn_reg &= ~(IXGBE_MFLCN_RFCE | IXGBE_MFLCN_RPFCE);
+	mflcn_reg &= ~(IXGBE_MFLCN_RPFCE_MASK | IXGBE_MFLCN_RFCE);
 
 	fccfg_reg = IXGBE_READ_REG(hw, IXGBE_FCCFG);
 	fccfg_reg &= ~(IXGBE_FCCFG_TFCE_802_3X | IXGBE_FCCFG_TFCE_PRIORITY);
@@ -2160,9 +2124,6 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 	 * 2: Tx flow control is enabled (we can send pause frames but
 	 *    we do not support receiving pause frames).
 	 * 3: Both Rx and Tx flow control (symmetric) are enabled.
-#ifdef CONFIG_DCB
-	 * 4: Priority Flow Control is enabled.
-#endif
 	 * other: Invalid.
 	 */
 	switch (hw->fc.current_mode) {
@@ -2195,11 +2156,6 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 		mflcn_reg |= IXGBE_MFLCN_RFCE;
 		fccfg_reg |= IXGBE_FCCFG_TFCE_802_3X;
 		break;
-#ifdef CONFIG_DCB
-	case ixgbe_fc_pfc:
-		goto out;
-		break;
-#endif /* CONFIG_DCB */
 	default:
 		hw_dbg(hw, "Flow control param set incorrectly\n");
 		ret_val = IXGBE_ERR_CONFIG;
@@ -2212,34 +2168,34 @@ s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num)
 	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, mflcn_reg);
 	IXGBE_WRITE_REG(hw, IXGBE_FCCFG, fccfg_reg);
 
-	fcrtl = hw->fc.low_water << 10;
+	fcrtl = (hw->fc.low_water << 10) | IXGBE_FCRTL_XONE;
 
-	if (hw->fc.current_mode & ixgbe_fc_tx_pause) {
-		fcrth = hw->fc.high_water[packetbuf_num] << 10;
-		fcrth |= IXGBE_FCRTH_FCEN;
-		if (hw->fc.send_xon)
-			fcrtl |= IXGBE_FCRTL_XONE;
-	} else {
-		/*
-		 * If Tx flow control is disabled, set our high water mark
-		 * to Rx FIFO size minus 32 in order prevent Tx switch
-		 * loopback from stalling on DMA.
-		 */
-		fcrth = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num)) - 32;
-	}
+	/* Set up and enable Rx high/low water mark thresholds, enable XON. */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		if ((hw->fc.current_mode & ixgbe_fc_tx_pause) &&
+		    hw->fc.high_water[i]) {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), fcrtl);
+			fcrth = (hw->fc.high_water[i] << 10) | IXGBE_FCRTH_FCEN;
+		} else {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), 0);
+			/*
+			 * In order to prevent Tx hangs when the internal Tx
+			 * switch is enabled we must set the high water mark
+			 * to the maximum FCRTH value.  This allows the Tx
+			 * switch to function even under heavy Rx workloads.
+			 */
+			fcrth = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i)) - 32;
+		}
 
-	IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(packetbuf_num), fcrth);
-	IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num), fcrtl);
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(i), fcrth);
+	}
 
 	/* Configure pause time (2 TCs per register) */
-	reg = IXGBE_READ_REG(hw, IXGBE_FCTTV(packetbuf_num / 2));
-	if ((packetbuf_num & 1) == 0)
-		reg = (reg & 0xFFFF0000) | hw->fc.pause_time;
-	else
-		reg = (reg & 0x0000FFFF) | (hw->fc.pause_time << 16);
-	IXGBE_WRITE_REG(hw, IXGBE_FCTTV(packetbuf_num / 2), reg);
+	reg = hw->fc.pause_time * 0x00010001;
+	for (i = 0; i < (MAX_TRAFFIC_CLASS / 2); i++)
+		IXGBE_WRITE_REG(hw, IXGBE_FCTTV(i), reg);
 
-	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, (hw->fc.pause_time >> 1));
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, hw->fc.pause_time / 2);
 
 out:
 	return ret_val;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 9e8a1c0..6222fdb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -77,7 +77,7 @@ s32 ixgbe_disable_mc_generic(struct ixgbe_hw *hw);
 s32 ixgbe_disable_rx_buff_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_buff_generic(struct ixgbe_hw *hw);
 s32 ixgbe_enable_rx_dma_generic(struct ixgbe_hw *hw, u32 regval);
-s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw, s32 packetbuf_num);
+s32 ixgbe_fc_enable_generic(struct ixgbe_hw *hw);
 void ixgbe_fc_autoneg(struct ixgbe_hw *hw);
 
 s32 ixgbe_validate_mac_addr(u8 *mac_addr);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
index 888a419..65913c5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
@@ -278,18 +278,7 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en, u8 *prio_tc)
 		IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
 
 	} else {
-		/* X540 devices have a RX bit that should be cleared
-		 * if PFC is disabled on all TCs but PFC features is
-		 * enabled.
-		 */
-		if (hw->mac.type == ixgbe_mac_X540) {
-			reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
-			reg &= ~IXGBE_MFLCN_RPFCE_MASK;
-			IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
-		}
-
-		for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-			hw->mac.ops.fc_enable(hw, i);
+		hw->mac.ops.fc_enable(hw);
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c2ceda9..b2daff3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5250,7 +5250,7 @@ static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 link_speed = adapter->link_speed;
 	bool link_up = adapter->link_up;
-	int i;
+	bool pfc_en = adapter->dcb_cfg.pfc_mode_enable;
 
 	if (!(adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE))
 		return;
@@ -5262,14 +5262,12 @@ static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)
 		link_speed = IXGBE_LINK_SPEED_10GB_FULL;
 		link_up = true;
 	}
-	if (link_up) {
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-				hw->mac.ops.fc_enable(hw, i);
-		} else {
-			hw->mac.ops.fc_enable(hw, 0);
-		}
-	}
+
+	if (adapter->ixgbe_ieee_pfc)
+		pfc_en |= !!(adapter->ixgbe_ieee_pfc->pfc_en);
+
+	if (link_up && !((adapter->flags & IXGBE_FLAG_DCB_ENABLED) && pfc_en))
+		hw->mac.ops.fc_enable(hw);
 
 	if (link_up ||
 	    time_after(jiffies, (adapter->link_check_timeout +
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 5337260..5e64c77 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1892,7 +1892,7 @@ enum {
 #define IXGBE_MFLCN_DPF         0x00000002 /* Discard Pause Frame */
 #define IXGBE_MFLCN_RPFCE       0x00000004 /* Receive Priority FC Enable */
 #define IXGBE_MFLCN_RFCE        0x00000008 /* Receive FC Enable */
-#define IXGBE_MFLCN_RPFCE_MASK	0x00000FF0 /* Receive FC Mask */
+#define IXGBE_MFLCN_RPFCE_MASK	0x00000FF4 /* Receive FC Mask */
 
 #define IXGBE_MFLCN_RPFCE_SHIFT		 4
 
@@ -2808,7 +2808,7 @@ struct ixgbe_mac_operations {
 	void (*set_vlan_anti_spoofing)(struct ixgbe_hw *, bool, int);
 
 	/* Flow Control */
-	s32 (*fc_enable)(struct ixgbe_hw *, s32);
+	s32 (*fc_enable)(struct ixgbe_hw *);
 
 	/* Manageability interface */
 	s32 (*set_fw_drv_ver)(struct ixgbe_hw *, u8, u8, u8, u8);
-- 
1.7.7.6
