From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 05/10] bnx2x: Move common function into
 aggregated function
Date: Wed, 8 Sep 2010 00:41:04 +0300
Message-ID: <1283895664.5452.65.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3330 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932437Ab0IGSXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:23:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all PHY specific logic from bnx2x_main into bnx2x_link.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |   95 ++++++++++++++++++++++++++++++++++---
 drivers/net/bnx2x/bnx2x_link.h |    8 +++
 drivers/net/bnx2x/bnx2x_main.c |  103 +++++-----------------------------------
 3 files changed, 108 insertions(+), 98 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index fec3d75..895ae00 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -2079,7 +2079,7 @@ static u8 bnx2x_init_xgxs(struct bnx2x_phy *phy,
 	return rc;
 }
 /*****************************************************************************/
-/*      		     External Phy section       		     */
+/*			    External Phy section			     */
 /*****************************************************************************/
 void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port)
 {
@@ -3271,6 +3271,8 @@ static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 				 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
+	u32 val;
+	u32 swap_val, swap_override, aeu_gpio_mask, offset;
 	DP(NETIF_MSG_LINK, "Initializing BCM8726\n");
 	/* Restore normal power mode*/
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
@@ -3351,6 +3353,31 @@ static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 				 MDIO_PMA_REG_8726_TX_CTRL2,
 				 phy->tx_preemphasis[1]);
 	}
+
+	/* Set GPIO3 to trigger SFP+ module insertion/removal */
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
+			    MISC_REGISTERS_GPIO_INPUT_HI_Z, params->port);
+
+	/* The GPIO should be swapped if the swap register is set and active */
+	swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
+	swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
+
+	/* Select function upon port-swap configuration */
+	if (params->port == 0) {
+		offset = MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0;
+		aeu_gpio_mask = (swap_val && swap_override) ?
+			AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_1 :
+			AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0;
+	} else {
+		offset = MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0;
+		aeu_gpio_mask = (swap_val && swap_override) ?
+			AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0 :
+			AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_1;
+	}
+	val = REG_RD(bp, offset);
+	/* add GPIO3 to group */
+	val |= aeu_gpio_mask;
+	REG_WR(bp, offset, val);
 	return 0;
 
 }
@@ -4888,10 +4915,9 @@ u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars)
 }
 
 static u8 bnx2x_link_initialize(struct link_params *params,
-			      struct link_vars *vars)
+				struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
 	u8 rc = 0;
 	u8 phy_index, non_ext_phy;
 	struct bnx2x_phy *ext_phy = &params->phy[EXT_PHY1];
@@ -4964,10 +4990,13 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 				params, vars);
 		}
 
-	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-		     (NIG_STATUS_XGXS0_LINK10G |
-		      NIG_STATUS_XGXS0_LINK_STATUS |
-		      NIG_STATUS_SERDES0_LINK_STATUS));
+	/* Reset the interrupt indication after phy was initialized */
+	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 +
+		       params->port*4,
+		       (NIG_STATUS_XGXS0_LINK10G |
+			NIG_STATUS_XGXS0_LINK_STATUS |
+			NIG_STATUS_SERDES0_LINK_STATUS |
+			NIG_MASK_MI_INT));
 
 	return rc;
 }
@@ -6516,3 +6545,55 @@ void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy)
 	}
 }
 
+u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base)
+{
+	u8 phy_index;
+	struct bnx2x_phy phy;
+	for (phy_index = INT_PHY; phy_index < MAX_PHYS;
+	      phy_index++) {
+		if (bnx2x_populate_phy(bp, phy_index, shmem_base,
+				       0, &phy) != 0) {
+			DP(NETIF_MSG_LINK, "populate phy failed\n");
+			return 0;
+		}
+
+		if (phy.flags & FLAGS_HW_LOCK_REQUIRED)
+			return 1;
+	}
+	return 0;
+}
+
+u8 bnx2x_fan_failure_det_req(struct bnx2x *bp,
+			     u32 shmem_base,
+			     u8 port)
+{
+	u8 phy_index, fan_failure_det_req = 0;
+	struct bnx2x_phy phy;
+	for (phy_index = EXT_PHY1; phy_index < MAX_PHYS;
+	      phy_index++) {
+		if (bnx2x_populate_phy(bp, phy_index, shmem_base,
+				       port, &phy)
+		    != 0) {
+			DP(NETIF_MSG_LINK, "populate phy failed\n");
+			return 0;
+		}
+		fan_failure_det_req |= (phy.flags &
+					FLAGS_FAN_FAILURE_DET_REQ);
+	}
+	return fan_failure_det_req;
+}
+
+void bnx2x_hw_reset_phy(struct link_params *params)
+{
+	u8 phy_index;
+	for (phy_index = EXT_PHY1; phy_index < MAX_PHYS;
+	      phy_index++) {
+		if (params->phy[phy_index].hw_reset) {
+			params->phy[phy_index].hw_reset(
+				&params->phy[phy_index],
+				params);
+			params->phy[phy_index] = phy_null;
+		}
+	}
+}
+
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 9717cb1..d663c4f 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -311,8 +311,16 @@ void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy);
 u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 				struct link_params *params, u16 addr,
 			      u8 byte_cnt, u8 *o_buf);
+
+void bnx2x_hw_reset_phy(struct link_params *params);
+
+/* Checks if HW lock is required for this phy/board type */
+u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base);
 /* Returns the aggregative supported attributes of the phys on board */
 u32 bnx2x_supported_attr(struct link_params *params, u8 phy_idx);
 /* Probe the phys on board, and populate them in "params" */
 u8 bnx2x_phy_probe(struct link_params *params);
+/* Checks if fan failure detection is required on one of the phys on board */
+u8 bnx2x_fan_failure_det_req(struct bnx2x *bp, u32 shmem_base, u8 port);
+
 #endif /* BNX2X_LINK_H */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 1184677..0210dde 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1981,7 +1981,7 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 {
 	int port = BP_PORT(bp);
 	int reg_offset;
-	u32 val, swap_val, swap_override;
+	u32 val;
 
 	reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
 			     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
@@ -1995,30 +1995,7 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 		BNX2X_ERR("SPIO5 hw attention\n");
 
 		/* Fan failure attention */
-		switch (bp->link_params.phy[EXT_PHY1].type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-			/* Low power mode is controlled by GPIO 2 */
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
-			/* The PHY reset is controlled by GPIO 1 */
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-				       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-			/* The PHY reset is controlled by GPIO 1 */
-			/* fake the port number to cancel the swap done in
-			   set_gpio() */
-			swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
-			swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
-			port = (swap_val && swap_override) ^ 1;
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-				       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
-			break;
-
-		default:
-			break;
-		}
+		bnx2x_hw_reset_phy(&bp->link_params);
 		bnx2x_fan_failure(bp);
 	}
 
@@ -3867,17 +3844,11 @@ static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
 	 */
 	else if (val == SHARED_HW_CFG_FAN_FAILURE_PHY_TYPE)
 		for (port = PORT_0; port < PORT_MAX; port++) {
-			u32 phy_type =
-				SHMEM_RD(bp, dev_info.port_hw_config[port].
-					 external_phy_config) &
-				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
 			is_required |=
-				((phy_type ==
-				  PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101) ||
-				 (phy_type ==
-				  PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727) ||
-				 (phy_type ==
-				  PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481));
+				bnx2x_fan_failure_det_req(
+					bp,
+					bp->common.shmem_base,
+					port);
 		}
 
 	DP(NETIF_MSG_HW, "fan detection setting: %d\n", is_required);
@@ -4144,17 +4115,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 		return -EBUSY;
 	}
 
-	switch (bp->link_params.phy[EXT_PHY1].type) {
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-		bp->port.need_hw_lock = 1;
-		break;
-
-	default:
-		break;
-	}
+	bp->port.need_hw_lock = bnx2x_hw_lock_required(bp,
+						       bp->common.shmem_base);
 
 	bnx2x_setup_fan_failure_detection(bp);
 
@@ -4302,57 +4264,16 @@ static int bnx2x_init_port(struct bnx2x *bp)
 
 	bnx2x_init_block(bp, MCP_BLOCK, init_stage);
 	bnx2x_init_block(bp, DMAE_BLOCK, init_stage);
+	bp->port.need_hw_lock = bnx2x_hw_lock_required(bp,
+						       bp->common.shmem_base);
 
-	switch (bp->link_params.phy[EXT_PHY1].type) {
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-		{
-		u32 swap_val, swap_override, aeu_gpio_mask, offset;
-
-		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
-			       MISC_REGISTERS_GPIO_INPUT_HI_Z, port);
-
-		/* The GPIO should be swapped if the swap register is
-		   set and active */
-		swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
-		swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
-
-		/* Select function upon port-swap configuration */
-		if (port == 0) {
-			offset = MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0;
-			aeu_gpio_mask = (swap_val && swap_override) ?
-				AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_1 :
-				AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0;
-		} else {
-			offset = MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0;
-			aeu_gpio_mask = (swap_val && swap_override) ?
-				AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0 :
-				AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_1;
-		}
-		val = REG_RD(bp, offset);
-		/* add GPIO3 to group */
-		val |= aeu_gpio_mask;
-		REG_WR(bp, offset, val);
-		}
-		bp->port.need_hw_lock = 1;
-		break;
-
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-		bp->port.need_hw_lock = 1;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-		/* add SPIO 5 to group 0 */
-		{
+	if (bnx2x_fan_failure_det_req(bp, bp->common.shmem_base,
+				      port)) {
 		u32 reg_addr = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
 				       MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
 		val = REG_RD(bp, reg_addr);
 		val |= AEU_INPUTS_ATTN_BITS_SPIO5;
 		REG_WR(bp, reg_addr, val);
-		}
-		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-		bp->port.need_hw_lock = 1;
-		break;
-	default:
-		break;
 	}
 	bnx2x__link_reset(bp);
 
-- 
1.7.1




