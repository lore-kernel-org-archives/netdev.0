From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 4/8] bnx2x: Reset PHY due to fan failure for
 578xx
Date: Tue, 5 Jul 2011 14:06:48 +0300
Message-ID: <1309864008.4050.83.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3865 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755929Ab1GELHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 07:07:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add hardware PHY reset action for BCM578xx when fan failure occur.
The new bnx2x_warpcore_hw_reset warps bnx2x_warpcore_power_module to fit the .hw_reset function template of the phy structure.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   80 ++++++++++++++++++++++++++++++++-------
 1 files changed, 65 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 270a2f7..a04fa13 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -7904,6 +7904,9 @@ static void bnx2x_warpcore_power_module(struct link_params *params,
 			dev_info.port_hw_config[params->port].e3_sfp_ctrl)) &
 			PORT_HW_CFG_E3_PWR_DIS_MASK) >>
 			PORT_HW_CFG_E3_PWR_DIS_SHIFT;
+
+	if (pin_cfg == PIN_CFG_NA)
+		return;
 	DP(NETIF_MSG_LINK, "Setting SFP+ module power to %d using pin cfg %d\n",
 		       power, pin_cfg);
 	/*
@@ -7913,6 +7916,12 @@ static void bnx2x_warpcore_power_module(struct link_params *params,
 	bnx2x_set_cfg_pin(bp, pin_cfg, power ^ 1);
 }
 
+static void bnx2x_warpcore_hw_reset(struct bnx2x_phy *phy,
+				    struct link_params *params)
+{
+	bnx2x_warpcore_power_module(params, phy, 0);
+}
+
 static void bnx2x_power_sfp_module(struct link_params *params,
 				   struct bnx2x_phy *phy,
 				   u8 power)
@@ -9294,9 +9303,9 @@ static int bnx2x_84833_pair_swap_cfg(struct bnx2x_phy *phy,
 }
 

-static int bnx2x_84833_common_init_phy(struct bnx2x *bp,
-						u32 shmem_base_path[],
-						u32 chip_id)
+static u8 bnx2x_84833_get_reset_gpios(struct bnx2x *bp,
+				      u32 shmem_base_path[],
+				      u32 chip_id)
 {
 	u32 reset_pin[2];
 	u32 idx;
@@ -9329,6 +9338,41 @@ static int bnx2x_84833_common_init_phy(struct bnx2x *bp,
 		reset_gpios = (u8)(reset_pin[0] | reset_pin[1]);
 	}
 
+	return reset_gpios;
+}
+
+static int bnx2x_84833_hw_reset_phy(struct bnx2x_phy *phy,
+				struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u8 reset_gpios;
+	u32 other_shmem_base_addr = REG_RD(bp, params->shmem2_base +
+				offsetof(struct shmem2_region,
+				other_shmem_base_addr));
+
+	u32 shmem_base_path[2];
+	shmem_base_path[0] = params->shmem_base;
+	shmem_base_path[1] = other_shmem_base_addr;
+
+	reset_gpios = bnx2x_84833_get_reset_gpios(bp, shmem_base_path,
+						  params->chip_id);
+
+	bnx2x_set_mult_gpio(bp, reset_gpios, MISC_REGISTERS_GPIO_OUTPUT_LOW);
+	udelay(10);
+	DP(NETIF_MSG_LINK, "84833 hw reset on pin values 0x%x\n",
+		reset_gpios);
+
+	return 0;
+}
+
+static int bnx2x_84833_common_init_phy(struct bnx2x *bp,
+						u32 shmem_base_path[],
+						u32 chip_id)
+{
+	u8 reset_gpios;
+
+	reset_gpios = bnx2x_84833_get_reset_gpios(bp, shmem_base_path, chip_id);
+
 	bnx2x_set_mult_gpio(bp, reset_gpios, MISC_REGISTERS_GPIO_OUTPUT_LOW);
 	udelay(10);
 	bnx2x_set_mult_gpio(bp, reset_gpios, MISC_REGISTERS_GPIO_OUTPUT_HIGH);
@@ -9362,17 +9406,11 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 			       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 			       port);
 	} else {
+		/* MDIO reset */
 		bnx2x_cl45_write(bp, phy,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_CTRL, 0x8000);
-	}
-
-	bnx2x_wait_reset_complete(bp, phy, params);
-	/* Wait for GPHY to come out of reset */
-	msleep(50);
-
-	/* Bring PHY out of super isolate mode */
-	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
+		/* Bring PHY out of super isolate mode */
 		bnx2x_cl45_read(bp, phy,
 				MDIO_CTL_DEVAD,
 				MDIO_84833_TOP_CFG_XGPHY_STRAP1, &val);
@@ -9380,9 +9418,13 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		bnx2x_cl45_write(bp, phy,
 				MDIO_CTL_DEVAD,
 				MDIO_84833_TOP_CFG_XGPHY_STRAP1, val);
-		bnx2x_wait_reset_complete(bp, phy, params);
 	}
 
+	bnx2x_wait_reset_complete(bp, phy, params);
+
+	/* Wait for GPHY to come out of reset */
+	msleep(50);
+
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
 		bnx2x_84833_pair_swap_cfg(phy, params, vars);
 
@@ -10448,7 +10490,7 @@ static struct bnx2x_phy phy_warpcore = {
 	.link_reset	= (link_reset_t)bnx2x_warpcore_link_reset,
 	.config_loopback = (config_loopback_t)bnx2x_set_warpcore_loopback,
 	.format_fw_ver	= (format_fw_ver_t)NULL,
-	.hw_reset	= (hw_reset_t)NULL,
+	.hw_reset	= (hw_reset_t)bnx2x_warpcore_hw_reset,
 	.set_link_led	= (set_link_led_t)NULL,
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
@@ -10736,7 +10778,7 @@ static struct bnx2x_phy phy_84833 = {
 	.link_reset	= (link_reset_t)bnx2x_848x3_link_reset,
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
-	.hw_reset	= (hw_reset_t)NULL,
+	.hw_reset	= (hw_reset_t)bnx2x_84833_hw_reset_phy,
 	.set_link_led	= (set_link_led_t)bnx2x_848xx_set_link_led,
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
@@ -12122,7 +12164,15 @@ u8 bnx2x_fan_failure_det_req(struct bnx2x *bp,
 void bnx2x_hw_reset_phy(struct link_params *params)
 {
 	u8 phy_index;
-	for (phy_index = EXT_PHY1; phy_index < MAX_PHYS;
+	struct bnx2x *bp = params->bp;
+	bnx2x_update_mng(params, 0);
+	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + params->port*4,
+		       (NIG_MASK_XGXS0_LINK_STATUS |
+			NIG_MASK_XGXS0_LINK10G |
+			NIG_MASK_SERDES0_LINK_STATUS |
+			NIG_MASK_MI_INT));
+
+	for (phy_index = INT_PHY; phy_index < MAX_PHYS;
 	      phy_index++) {
 		if (params->phy[phy_index].hw_reset) {
 			params->phy[phy_index].hw_reset(
-- 
1.7.1







