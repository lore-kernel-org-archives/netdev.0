From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 06/25] bnx2x: HW lock mechanism
Date: Wed, 13 Aug 2008 17:13:29 +0300
Message-ID: <1218636809.547.81.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4376 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888AbYHMONr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:13:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW lock mechanism
Enhancing the HW lock to work per function and not only per port - this
is needed for the next patch that protects races over HW attention
detection between the different functions. At this chance, changing the
functions names to be more inline with the current naming convention

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |  102 ++++++++++++++++++++++++++--------------------
 drivers/net/bnx2x_reg.h  |   17 ++++++++
 2 files changed, 75 insertions(+), 44 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index dfa8c7b..3e86ff4 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1693,11 +1693,12 @@ static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
  * General service functions
  */
 
-static int bnx2x_hw_lock(struct bnx2x *bp, u32 resource)
+static int bnx2x_acquire_hw_lock(struct bnx2x *bp, u32 resource)
 {
 	u32 lock_status;
 	u32 resource_bit = (1 << resource);
-	u8 port = BP_PORT(bp);
+	int func = BP_FUNC(bp);
+	u32 hw_lock_control_reg;
 	int cnt;
 
 	/* Validating that the resource is within range */
@@ -1708,8 +1709,15 @@ static int bnx2x_hw_lock(struct bnx2x *bp, u32 resource)
 		return -EINVAL;
 	}
 
+	if (func <= 5) {
+		hw_lock_control_reg = (MISC_REG_DRIVER_CONTROL_1 + func*8);
+	} else {
+		hw_lock_control_reg =
+				(MISC_REG_DRIVER_CONTROL_7 + (func - 6)*8);
+	}
+
 	/* Validating that the resource is not already taken */
-	lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + port*8);
+	lock_status = REG_RD(bp, hw_lock_control_reg);
 	if (lock_status & resource_bit) {
 		DP(NETIF_MSG_HW, "lock_status 0x%x  resource_bit 0x%x\n",
 		   lock_status, resource_bit);
@@ -1719,9 +1727,8 @@ static int bnx2x_hw_lock(struct bnx2x *bp, u32 resource)
 	/* Try for 1 second every 5ms */
 	for (cnt = 0; cnt < 200; cnt++) {
 		/* Try to acquire the lock */
-		REG_WR(bp, MISC_REG_DRIVER_CONTROL_1 + port*8 + 4,
-		       resource_bit);
-		lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + port*8);
+		REG_WR(bp, hw_lock_control_reg + 4, resource_bit);
+		lock_status = REG_RD(bp, hw_lock_control_reg);
 		if (lock_status & resource_bit)
 			return 0;
 
@@ -1731,11 +1738,12 @@ static int bnx2x_hw_lock(struct bnx2x *bp, u32 resource)
 	return -EAGAIN;
 }
 
-static int bnx2x_hw_unlock(struct bnx2x *bp, u32 resource)
+static int bnx2x_release_hw_lock(struct bnx2x *bp, u32 resource)
 {
 	u32 lock_status;
 	u32 resource_bit = (1 << resource);
-	u8 port = BP_PORT(bp);
+	int func = BP_FUNC(bp);
+	u32 hw_lock_control_reg;
 
 	/* Validating that the resource is within range */
 	if (resource > HW_LOCK_MAX_RESOURCE_VALUE) {
@@ -1745,20 +1753,27 @@ static int bnx2x_hw_unlock(struct bnx2x *bp, u32 resource)
 		return -EINVAL;
 	}
 
+	if (func <= 5) {
+		hw_lock_control_reg = (MISC_REG_DRIVER_CONTROL_1 + func*8);
+	} else {
+		hw_lock_control_reg =
+				(MISC_REG_DRIVER_CONTROL_7 + (func - 6)*8);
+	}
+
 	/* Validating that the resource is currently taken */
-	lock_status = REG_RD(bp, MISC_REG_DRIVER_CONTROL_1 + port*8);
+	lock_status = REG_RD(bp, hw_lock_control_reg);
 	if (!(lock_status & resource_bit)) {
 		DP(NETIF_MSG_HW, "lock_status 0x%x  resource_bit 0x%x\n",
 		   lock_status, resource_bit);
 		return -EFAULT;
 	}
 
-	REG_WR(bp, MISC_REG_DRIVER_CONTROL_1 + port*8, resource_bit);
+	REG_WR(bp, hw_lock_control_reg, resource_bit);
 	return 0;
 }
 
 /* HW Lock for shared dual port PHYs */
-static void bnx2x_phy_hw_lock(struct bnx2x *bp)
+static void bnx2x_acquire_phy_lock(struct bnx2x *bp)
 {
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
 
@@ -1766,16 +1781,16 @@ static void bnx2x_phy_hw_lock(struct bnx2x *bp)
 
 	if ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
-		bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
 }
 
-static void bnx2x_phy_hw_unlock(struct bnx2x *bp)
+static void bnx2x_release_phy_lock(struct bnx2x *bp)
 {
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
 
 	if ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073))
-		bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_8072_MDIO);
+		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_8072_MDIO);
 
 	mutex_unlock(&bp->port.phy_mutex);
 }
@@ -1795,7 +1810,7 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode)
 		return -EINVAL;
 	}
 
-	bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_GPIO);
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_GPIO);
 	/* read GPIO and mask except the float bits */
 	gpio_reg = (REG_RD(bp, MISC_REG_GPIO) & MISC_REGISTERS_GPIO_FLOAT);
 
@@ -1828,7 +1843,7 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode)
 	}
 
 	REG_WR(bp, MISC_REG_GPIO, gpio_reg);
-	bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_GPIO);
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_GPIO);
 
 	return 0;
 }
@@ -1844,7 +1859,7 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
 		return -EINVAL;
 	}
 
-	bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_SPIO);
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_SPIO);
 	/* read SPIO and mask except the float bits */
 	spio_reg = (REG_RD(bp, MISC_REG_SPIO) & MISC_REGISTERS_SPIO_FLOAT);
 
@@ -1874,7 +1889,7 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
 	}
 
 	REG_WR(bp, MISC_REG_SPIO, spio_reg);
-	bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_SPIO);
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_SPIO);
 
 	return 0;
 }
@@ -1940,9 +1955,9 @@ static u8 bnx2x_initial_phy_init(struct bnx2x *bp)
 		/* Initialize link parameters structure variables */
 		bp->link_params.mtu = bp->dev->mtu;
 
-		bnx2x_phy_hw_lock(bp);
+		bnx2x_acquire_phy_lock(bp);
 		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-		bnx2x_phy_hw_unlock(bp);
+		bnx2x_release_phy_lock(bp);
 
 		if (bp->link_vars.link_up)
 			bnx2x_link_report(bp);
@@ -1958,9 +1973,9 @@ static u8 bnx2x_initial_phy_init(struct bnx2x *bp)
 static void bnx2x_link_set(struct bnx2x *bp)
 {
 	if (!BP_NOMCP(bp)) {
-		bnx2x_phy_hw_lock(bp);
+		bnx2x_acquire_phy_lock(bp);
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-		bnx2x_phy_hw_unlock(bp);
+		bnx2x_release_phy_lock(bp);
 
 		bnx2x_calc_fc_adv(bp);
 	} else
@@ -1970,9 +1985,9 @@ static void bnx2x_link_set(struct bnx2x *bp)
 static void bnx2x__link_reset(struct bnx2x *bp)
 {
 	if (!BP_NOMCP(bp)) {
-		bnx2x_phy_hw_lock(bp);
+		bnx2x_acquire_phy_lock(bp);
 		bnx2x_link_reset(&bp->link_params, &bp->link_vars);
-		bnx2x_phy_hw_unlock(bp);
+		bnx2x_release_phy_lock(bp);
 	} else
 		BNX2X_ERR("Bootcode is missing -not resetting link\n");
 }
@@ -1981,9 +1996,9 @@ static u8 bnx2x_link_test(struct bnx2x *bp)
 {
 	u8 rc;
 
-	bnx2x_phy_hw_lock(bp);
+	bnx2x_acquire_phy_lock(bp);
 	rc = bnx2x_test_link(&bp->link_params, &bp->link_vars);
-	bnx2x_phy_hw_unlock(bp);
+	bnx2x_release_phy_lock(bp);
 
 	return rc;
 }
@@ -2207,9 +2222,9 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 	/* Make sure that we are synced with the current statistics */
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
-	bnx2x_phy_hw_lock(bp);
+	bnx2x_acquire_phy_lock(bp);
 	bnx2x_link_update(&bp->link_params, &bp->link_vars);
-	bnx2x_phy_hw_unlock(bp);
+	bnx2x_release_phy_lock(bp);
 
 	if (bp->link_vars.link_up) {
 
@@ -2361,7 +2376,7 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 }
 
 /* acquire split MCP access lock register */
-static int bnx2x_lock_alr(struct bnx2x *bp)
+static int bnx2x_acquire_alr(struct bnx2x *bp)
 {
 	u32 i, j, val;
 	int rc = 0;
@@ -2385,8 +2400,8 @@ static int bnx2x_lock_alr(struct bnx2x *bp)
 	return rc;
 }
 
-/* Release split MCP access lock register */
-static void bnx2x_unlock_alr(struct bnx2x *bp)
+/* release split MCP access lock register */
+static void bnx2x_release_alr(struct bnx2x *bp)
 {
 	u32 val = 0;
 
@@ -2399,7 +2414,6 @@ static inline u16 bnx2x_update_dsb_idx(struct bnx2x *bp)
 	u16 rc = 0;
 
 	barrier(); /* status block is written to by the chip */
-
 	if (bp->def_att_idx != def_sb->atten_status_block.attn_bits_index) {
 		bp->def_att_idx = def_sb->atten_status_block.attn_bits_index;
 		rc |= 1;
@@ -2706,7 +2720,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 
 	/* need to take HW lock because MCP or other port might also
 	   try to handle this event */
-	bnx2x_lock_alr(bp);
+	bnx2x_acquire_alr(bp);
 
 	attn.sig[0] = REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_1_FUNC_0 + port*4);
 	attn.sig[1] = REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_2_FUNC_0 + port*4);
@@ -2742,7 +2756,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 		}
 	}
 
-	bnx2x_unlock_alr(bp);
+	bnx2x_release_alr(bp);
 
 	reg_addr = (IGU_ADDR_ATTN_BITS_CLR + IGU_FUNC_BASE * BP_FUNC(bp)) * 8;
 
@@ -6767,7 +6781,7 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 		/* Check if it is the UNDI driver
 		 * UNDI driver initializes CID offset for normal bell to 0x7
 		 */
-		bnx2x_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
+		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 		val = REG_RD(bp, DORQ_REG_NORM_CID_OFST);
 		if (val == 0x7) {
 			u32 reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
@@ -6846,7 +6860,7 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
 				DRV_MSG_SEQ_NUMBER_MASK);
 		}
-		bnx2x_hw_unlock(bp, HW_LOCK_RESOURCE_UNDI);
+		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 	}
 }
 
@@ -7703,11 +7717,11 @@ static void bnx2x_get_drvinfo(struct net_device *dev,
 
 	phy_fw_ver[0] = '\0';
 	if (bp->port.pmf) {
-		bnx2x_phy_hw_lock(bp);
+		bnx2x_acquire_phy_lock(bp);
 		bnx2x_get_ext_phy_fw_version(&bp->link_params,
 					     (bp->state != BNX2X_STATE_CLOSED),
 					     phy_fw_ver, PHY_FW_VER_LEN);
-		bnx2x_phy_hw_unlock(bp);
+		bnx2x_release_phy_lock(bp);
 	}
 
 	snprintf(info->fw_version, 32, "%d.%d.%d:%d BC:%x%s%s",
@@ -8165,7 +8179,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 	if (eeprom->magic == 0x00504859)
 		if (bp->port.pmf) {
 
-			bnx2x_phy_hw_lock(bp);
+			bnx2x_acquire_phy_lock(bp);
 			rc = bnx2x_flash_download(bp, BP_PORT(bp),
 					     bp->link_params.ext_phy_config,
 					     (bp->state != BNX2X_STATE_CLOSED),
@@ -8177,7 +8191,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 				rc |= bnx2x_phy_init(&bp->link_params,
 						     &bp->link_vars);
 			}
-			bnx2x_phy_hw_unlock(bp);
+			bnx2x_release_phy_lock(bp);
 
 		} else /* Only the PMF can access the PHY */
 			return -EINVAL;
@@ -8601,15 +8615,15 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 
 	if (loopback_mode == BNX2X_MAC_LOOPBACK) {
 		bp->link_params.loopback_mode = LOOPBACK_BMAC;
-		bnx2x_phy_hw_lock(bp);
+		bnx2x_acquire_phy_lock(bp);
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-		bnx2x_phy_hw_unlock(bp);
+		bnx2x_release_phy_lock(bp);
 
 	} else if (loopback_mode == BNX2X_PHY_LOOPBACK) {
 		bp->link_params.loopback_mode = LOOPBACK_XGXS_10;
-		bnx2x_phy_hw_lock(bp);
+		bnx2x_acquire_phy_lock(bp);
 		bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-		bnx2x_phy_hw_unlock(bp);
+		bnx2x_release_phy_lock(bp);
 		/* wait until link state is restored */
 		bnx2x_wait_for_link(bp, link_up);
 
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index b5313c2..3f65dff 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1372,6 +1372,23 @@
    be asserted). */
 #define MISC_REG_DRIVER_CONTROL_16				 0xa5f0
 #define MISC_REG_DRIVER_CONTROL_16_SIZE 			 2
+/* [RW 32] The following driver registers(1...16) represent 16 drivers and
+   32 clients. Each client can be controlled by one driver only. One in each
+   bit represent that this driver control the appropriate client (Ex: bit 5
+   is set means this driver control client number 5). addr1 = set; addr0 =
+   clear; read from both addresses will give the same result = status. write
+   to address 1 will set a request to control all the clients that their
+   appropriate bit (in the write command) is set. if the client is free (the
+   appropriate bit in all the other drivers is clear) one will be written to
+   that driver register; if the client isn't free the bit will remain zero.
+   if the appropriate bit is set (the driver request to gain control on a
+   client it already controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW
+   interrupt will be asserted). write to address 0 will set a request to
+   free all the clients that their appropriate bit (in the write command) is
+   set. if the appropriate bit is clear (the driver request to free a client
+   it doesn't controls the ~MISC_REGISTERS_INT_STS.GENERIC_SW interrupt will
+   be asserted). */
+#define MISC_REG_DRIVER_CONTROL_7				 0xa3c8
 /* [RW 1] e1hmf for WOL. If clr WOL signal o the PXP will be send on bit 0
    only. */
 #define MISC_REG_E1HMF_MODE					 0xa5f8
-- 
1.5.3.2




