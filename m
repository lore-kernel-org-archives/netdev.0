From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 12/36] bnx2x: Supporting PHY FW upgrade
Date: Wed, 12 Aug 2009 21:23:11 +0300
Message-ID: <1250101391.27379.164.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752524AbZHLSYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 3 operations that the driver needs to support to allow applications to
access the PHY FW (on top of the MDC/MDIO access). Since those are essentially
nvram access commands, adding them to the ethtool -E interface.

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   21 ++++++-------
 drivers/net/bnx2x_link.h |    4 ++
 drivers/net/bnx2x_main.c |   72 ++++++++++++++++++++++++++++++++++-----------
 3 files changed, 67 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 371310d..98e3e8f 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1996,7 +1996,7 @@ static u8 bnx2x_emac_program(struct link_params *params,
 /*****************************************************************************/
 /*      		     External Phy section       		     */
 /*****************************************************************************/
-static void bnx2x_hw_reset(struct bnx2x *bp, u8 port)
+void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port)
 {
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
 		       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
@@ -2035,7 +2035,7 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 					  params->port);
 
 			/* HW reset */
-			bnx2x_hw_reset(bp, params->port);
+			bnx2x_ext_phy_hw_reset(bp, params->port);
 
 			bnx2x_cl45_write(bp, params->port,
 				       ext_phy_type,
@@ -2106,8 +2106,7 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 					  params->port);
 
 			/* HW reset */
-			bnx2x_hw_reset(bp, params->port);
-
+			bnx2x_ext_phy_hw_reset(bp, params->port);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
@@ -2118,7 +2117,7 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 					  params->port);
 
 			/* HW reset */
-			bnx2x_hw_reset(bp, params->port);
+			bnx2x_ext_phy_hw_reset(bp, params->port);
 
 			bnx2x_cl45_write(bp, params->port,
 				       ext_phy_type,
@@ -2146,7 +2145,7 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 
 		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
 			DP(NETIF_MSG_LINK, "SerDes 5482\n");
-			bnx2x_hw_reset(bp, params->port);
+			bnx2x_ext_phy_hw_reset(bp, params->port);
 			break;
 
 		default:
@@ -6573,7 +6572,7 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	swap_val = REG_RD(bp,  NIG_REG_PORT_SWAP);
 	swap_override = REG_RD(bp,  NIG_REG_STRAP_OVERRIDE);
 
-	bnx2x_hw_reset(bp, 1 ^ (swap_val && swap_override));
+	bnx2x_ext_phy_hw_reset(bp, 1 ^ (swap_val && swap_override));
 	msleep(5);
 
 	if (swap_val && swap_override)
@@ -6647,7 +6646,7 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 		(1<<(MISC_REGISTERS_GPIO_3 + MISC_REGISTERS_GPIO_PORT_SHIFT)));
 	REG_WR(bp, MISC_REG_GPIO_EVENT_EN, val);
 
-	bnx2x_hw_reset(bp, 1);
+	bnx2x_ext_phy_hw_reset(bp, 1);
 	msleep(5);
 	for (port = 0; port < PORT_MAX; port++) {
 		/* Extract the ext phy address for the port */
@@ -6714,9 +6713,7 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return rc;
 }
 
-
-
-static void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, u8 port, u8 phy_addr)
+void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, u8 port, u8 phy_addr)
 {
 	u16 val, cnt;
 
@@ -7032,7 +7029,7 @@ static u8 bnx2x_sfx7101_flash_download(struct bnx2x *bp, u8 port,
 	for (cnt = 0; cnt < 100; cnt++)
 		msleep(5);
 
-	bnx2x_hw_reset(bp, port);
+	bnx2x_ext_phy_hw_reset(bp, port);
 
 	for (cnt = 0; cnt < 100; cnt++)
 		msleep(5);
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index d25ef45..9805d21 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -187,6 +187,10 @@ u8 bnx2x_test_link(struct link_params *input, struct link_vars *vars);
 /* One-time initialization for external phy after power up */
 u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base);
 
+/* Reset the external PHY using GPIO */
+void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port);
+
+void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, u8 port, u8 phy_addr);
 
 u8 bnx2x_read_sfp_module_eeprom(struct link_params *params, u16 addr,
 			      u8 byte_cnt, u8 *o_buf);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 1be2da4..06b250b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9352,7 +9352,8 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 			    struct ethtool_eeprom *eeprom, u8 *eebuf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int rc;
+	int port = BP_PORT(bp);
+	int rc = 0;
 
 	if (!netif_running(dev))
 		return -EAGAIN;
@@ -9364,27 +9365,62 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 
 	/* parameters already validated in ethtool_set_eeprom */
 
-	/* If the magic number is PHY (0x00504859) upgrade the PHY FW */
-	if (eeprom->magic == 0x00504859)
-		if (bp->port.pmf) {
+	/* PHY eeprom can be accessed only by the PMF */
+	if ((eeprom->magic >= 0x50485900) && (eeprom->magic <= 0x504859FF) &&
+	    !bp->port.pmf)
+		return -EINVAL;
+
+	if (eeprom->magic == 0x50485950) {
+		/* 'PHYP' (0x50485950): prepare phy for FW upgrade */
+		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
+		bnx2x_acquire_phy_lock(bp);
+		rc |= bnx2x_link_reset(&bp->link_params,
+				       &bp->link_vars, 0);
+		if (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config) ==
+					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101)
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
+				       MISC_REGISTERS_GPIO_HIGH, port);
+		bnx2x_release_phy_lock(bp);
+		bnx2x_link_report(bp);
+
+	} else if (eeprom->magic == 0x50485952) {
+		/* 'PHYR' (0x50485952): re-init link after FW upgrade */
+		if ((bp->state == BNX2X_STATE_OPEN) ||
+		    (bp->state == BNX2X_STATE_DISABLED)) {
 			bnx2x_acquire_phy_lock(bp);
-			rc = bnx2x_flash_download(bp, BP_PORT(bp),
-					     bp->link_params.ext_phy_config,
-					     (bp->state != BNX2X_STATE_CLOSED),
-					     eebuf, eeprom->len);
-			if ((bp->state == BNX2X_STATE_OPEN) ||
-			    (bp->state == BNX2X_STATE_DISABLED)) {
-				rc |= bnx2x_link_reset(&bp->link_params,
-						       &bp->link_vars, 1);
-				rc |= bnx2x_phy_init(&bp->link_params,
-						     &bp->link_vars);
-			}
+			rc |= bnx2x_link_reset(&bp->link_params,
+					       &bp->link_vars, 1);
+
+			rc |= bnx2x_phy_init(&bp->link_params,
+					     &bp->link_vars);
 			bnx2x_release_phy_lock(bp);
+			bnx2x_calc_fc_adv(bp);
+		}
+	} else if (eeprom->magic == 0x53985943) {
+		/* 'PHYC' (0x53985943): PHY FW upgrade completed */
+		if (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config) ==
+				       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101) {
+			u8 ext_phy_addr =
+				(bp->link_params.ext_phy_config &
+				 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT;
+
+			/* DSP Remove Download Mode */
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
+				       MISC_REGISTERS_GPIO_LOW, port);
 
-		} else /* Only the PMF can access the PHY */
-			return -EINVAL;
-	else
+			bnx2x_acquire_phy_lock(bp);
+
+			bnx2x_sfx7101_sp_sw_reset(bp, port, ext_phy_addr);
+
+			/* wait 0.5 sec to allow it to run */
+			msleep(500);
+			bnx2x_ext_phy_hw_reset(bp, port);
+			msleep(500);
+			bnx2x_release_phy_lock(bp);
+		}
+	} else
 		rc = bnx2x_nvram_write(bp, eeprom->offset, eebuf, eeprom->len);
 
 	return rc;
-- 
1.5.4.3




