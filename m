From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 07/36] bnx2x: Reading the FW version of the BCM8481
 PHY
Date: Wed, 12 Aug 2009 21:22:54 +0300
Message-ID: <1250101374.27379.158.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018AbZHLSXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:23:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |  118 ++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 113 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 9e1f19a..c925249 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -2046,6 +2046,111 @@ static void bnx2x_save_bcm_spirom_ver(struct bnx2x *bp, u8 port,
 				(u32)(fw_ver1<<16 | fw_ver2));
 }
 
+
+static void bnx2x_save_8481_spirom_version(struct bnx2x *bp, u8 port,
+					 u8 ext_phy_addr, u32 shmem_base)
+{
+	u16 val, fw_ver1, fw_ver2, cnt;
+	/* For the 32 bits registers in 8481, access via MDIO2ARM interface.*/
+	/* (1) set register 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		       ext_phy_addr, MDIO_PMA_DEVAD,
+		       0xA819, 0x0014);
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       0xA81A,
+		       0xc200);
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       0xA81B,
+		       0x0000);
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       0xA81C,
+		       0x0300);
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       0xA817,
+		       0x0009);
+
+	for (cnt = 0; cnt < 100; cnt++) {
+		bnx2x_cl45_read(bp, port,
+			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+			      ext_phy_addr,
+			      MDIO_PMA_DEVAD,
+			      0xA818,
+			      &val);
+		if (val & 1)
+			break;
+		udelay(5);
+	}
+	if (cnt == 100) {
+		DP(NETIF_MSG_LINK, "Unable to read 8481 phy fw version(1)\n");
+		bnx2x_save_spirom_version(bp, port,
+					shmem_base, 0);
+		return;
+	}
+
+
+	/* 2) read register 0xc200_0000 (SPI_FW_STATUS) */
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		       ext_phy_addr, MDIO_PMA_DEVAD,
+		       0xA819, 0x0000);
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		       ext_phy_addr, MDIO_PMA_DEVAD,
+		       0xA81A, 0xc200);
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		       ext_phy_addr, MDIO_PMA_DEVAD,
+		       0xA817, 0x000A);
+	for (cnt = 0; cnt < 100; cnt++) {
+		bnx2x_cl45_read(bp, port,
+			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+			      ext_phy_addr,
+			      MDIO_PMA_DEVAD,
+			      0xA818,
+			      &val);
+		if (val & 1)
+			break;
+		udelay(5);
+	}
+	if (cnt == 100) {
+		DP(NETIF_MSG_LINK, "Unable to read 8481 phy fw version(2)\n");
+		bnx2x_save_spirom_version(bp, port,
+					shmem_base, 0);
+		return;
+	}
+
+	/* lower 16 bits of the register SPI_FW_STATUS */
+	bnx2x_cl45_read(bp, port,
+		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		      ext_phy_addr,
+		      MDIO_PMA_DEVAD,
+		      0xA81B,
+		      &fw_ver1);
+	/* upper 16 bits of register SPI_FW_STATUS */
+	bnx2x_cl45_read(bp, port,
+		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+		      ext_phy_addr,
+		      MDIO_PMA_DEVAD,
+		      0xA81C,
+		      &fw_ver2);
+
+	bnx2x_save_spirom_version(bp, port,
+				shmem_base, (fw_ver2<<16) | fw_ver1);
+}
+
 static void bnx2x_bcm8072_external_rom_boot(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
@@ -4269,11 +4374,10 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					       autoneg_ctrl);
 			}
 
-			bnx2x_save_bcm_spirom_ver(bp, params->port,
-						ext_phy_type,
-						ext_phy_addr,
-						params->shmem_base);
-
+			/* Save spirom version */
+			bnx2x_save_8481_spirom_version(bp, params->port,
+						     ext_phy_addr,
+						     params->shmem_base);
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 			DP(NETIF_MSG_LINK,
@@ -5320,7 +5424,11 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+		status = bnx2x_format_ver(spirom_ver, version, len);
+		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
+		spirom_ver = ((spirom_ver & 0xF80) >> 7) << 16 |
+			(spirom_ver & 0x7F);
 		status = bnx2x_format_ver(spirom_ver, version, len);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-- 
1.5.4.3




