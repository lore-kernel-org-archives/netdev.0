From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 2/5] bnx2x: Fix 84833 RX CRC
Date: Sun, 21 Feb 2016 15:07:26 +0200
Message-ID: <1456060049-10678-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:13331 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751390AbcBURpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:45:03 -0500
In-Reply-To: <1456060049-10678-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a problem in current 84833 phy configuration -
in case 1Gb link is configured and jumbo-sized packets are being
used, device will experience RX crc errors.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 26 ++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index a529905..b496e4a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10416,6 +10416,32 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		vars->eee_status &= ~SHMEM_EEE_SUPPORTED_MASK;
 	}
 
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
+		/* Additional settings for jumbo packets in 1000BASE-T mode */
+		/* Allow rx extended length */
+		bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
+				MDIO_AN_REG_8481_AUX_CTRL, &val);
+		val |= 0x4000;
+		bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
+				 MDIO_AN_REG_8481_AUX_CTRL, val);
+		/* TX FIFO Elasticity LSB */
+		bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
+				MDIO_AN_REG_8481_1G_100T_EXT_CTRL, &val);
+		val |= 0x1;
+		bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
+				 MDIO_AN_REG_8481_1G_100T_EXT_CTRL, val);
+		/* TX FIFO Elasticity MSB */
+		/* Enable expansion register 0x46 (Pattern Generator status) */
+		bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
+				 MDIO_AN_REG_8481_EXPANSION_REG_ACCESS, 0xf46);
+
+		bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
+				MDIO_AN_REG_8481_EXPANSION_REG_RD_RW, &val);
+		val |= 0x4000;
+		bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
+				 MDIO_AN_REG_8481_EXPANSION_REG_RD_RW, val);
+	}
+
 	if (bnx2x_is_8483x_8485x(phy)) {
 		/* Bring PHY out of super isolate mode as the final step. */
 		bnx2x_cl45_read_and_write(bp, phy,
-- 
1.9.3
