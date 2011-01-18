From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 4/8] bnx2x: Fix BCM8073/BCM8727 microcode
 loading
Date: Tue, 18 Jan 2011 16:33:36 +0200
Message-ID: <1295361216.5281.87.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2770 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103Ab1AROdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 09:33:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve microcode loading verification before proceeding to next stage

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   73 +++++++++++++++++++++++----------------
 1 files changed, 43 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 36a8844..500258d 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -3870,11 +3870,14 @@ static void bnx2x_8073_resolve_fc(struct bnx2x_phy *phy,
 			   pause_result);
 	}
 }
-
-static void bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
+static u8 bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
 					      struct bnx2x_phy *phy,
 					      u8 port)
 {
+	u32 count = 0;
+	u16 fw_ver1, fw_msgout;
+	u8 rc = 0;
+
 	/* Boot port from external ROM  */
 	/* EDC grst */
 	bnx2x_cl45_write(bp, phy,
@@ -3904,14 +3907,45 @@ static void bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
 		       MDIO_PMA_REG_GEN_CTRL,
 		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
 
-	/* wait for 120ms for code download via SPI port */
-	msleep(120);
+	/* Delay 100ms per the PHY specifications */
+	msleep(100);
+
+	/* 8073 sometimes taking longer to download */
+	do {
+		count++;
+		if (count > 300) {
+			DP(NETIF_MSG_LINK,
+				 "bnx2x_8073_8727_external_rom_boot port %x:"
+				 "Download failed. fw version = 0x%x\n",
+				 port, fw_ver1);
+			rc = -EINVAL;
+			break;
+		}
+
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_ROM_VER1, &fw_ver1);
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_M8051_MSGOUT_REG, &fw_msgout);
+
+		msleep(1);
+	} while (fw_ver1 == 0 || fw_ver1 == 0x4321 ||
+			((fw_msgout & 0xff) != 0x03 && (phy->type ==
+			PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073)));
 
 	/* Clear ser_boot_ctl bit */
 	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
 	bnx2x_save_bcm_spirom_ver(bp, phy, port);
+
+	DP(NETIF_MSG_LINK,
+		 "bnx2x_8073_8727_external_rom_boot port %x:"
+		 "Download complete. fw version = 0x%x\n",
+		 port, fw_ver1);
+
+	return rc;
 }
 
 static void bnx2x_8073_set_xaui_low_power_mode(struct bnx2x *bp,
@@ -7721,7 +7755,6 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
 
 	/* PART2 - Download firmware to both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
-		u16 fw_ver1;
 		if (CHIP_IS_E2(bp))
 			port_of_path = 0;
 		else
@@ -7729,19 +7762,9 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
 
 		DP(NETIF_MSG_LINK, "Loading spirom for phy address 0x%x\n",
 			   phy_blk[port]->addr);
-		bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
-						  port_of_path);
-
-		bnx2x_cl45_read(bp, phy_blk[port],
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
-		if (fw_ver1 == 0 || fw_ver1 == 0x4321) {
-			DP(NETIF_MSG_LINK,
-				 "bnx2x_8073_common_init_phy port %x:"
-				 "Download failed. fw version = 0x%x\n",
-				 port, fw_ver1);
+		if (bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
+						      port_of_path))
 			return -EINVAL;
-		}
 
 		/* Only set bit 10 = 1 (Tx power down) */
 		bnx2x_cl45_read(bp, phy_blk[port],
@@ -7906,27 +7929,17 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp,
 	}
 	/* PART2 - Download firmware to both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
-		u16 fw_ver1;
 		 if (CHIP_IS_E2(bp))
 			port_of_path = 0;
 		else
 			port_of_path = port;
 		DP(NETIF_MSG_LINK, "Loading spirom for phy address 0x%x\n",
 			   phy_blk[port]->addr);
-		bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
-						  port_of_path);
-		bnx2x_cl45_read(bp, phy_blk[port],
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
-		if (fw_ver1 == 0 || fw_ver1 == 0x4321) {
-			DP(NETIF_MSG_LINK,
-				 "bnx2x_8727_common_init_phy port %x:"
-				 "Download failed. fw version = 0x%x\n",
-				 port, fw_ver1);
+		if (bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
+						      port_of_path))
 			return -EINVAL;
-		}
-	}
 
+	}
 	return 0;
 }
 
-- 
1.7.1








