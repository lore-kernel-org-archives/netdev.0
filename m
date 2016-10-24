From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Mon, 24 Oct 2016 12:40:54 +0200
Message-ID: <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
Cc: timur@codeaurora.org, andrew@lunn.ch, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:38957 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752075AbcJXKlD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 06:41:03 -0400
In-Reply-To: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In SGMII mode, we observed an autonegotiation issue
after power-down-up cycles where the copper side
reports successful link establishment but the
SGMII side's link is down.

This happened in a setup where the at8031 is
connected over SGMII to a eTSEC (fsl gianfar),
but so far could not be reproduced with other
Ethernet device / driver combinations.

This commit adds a wrapper function for at8031
that in case of operating in SGMII mode double
checks SGMII link state when generic aneg_done()
succeeds. It prints a warning on failure but
intentionally does not try to recover from this
state. As a result, if you ever see a warning
'803x_aneg_done: SGMII link is not ok' you will
end up having an Ethernet link up but won't get
any data through. This should not happen, if it
does, please contact the module maintainer.

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
 drivers/net/phy/at803x.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index cf74d10..a52b560 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -42,10 +42,18 @@
 #define AT803X_MMD_ACCESS_CONTROL		0x0D
 #define AT803X_MMD_ACCESS_CONTROL_DATA		0x0E
 #define AT803X_FUNC_DATA			0x4003
+#define AT803X_REG_CHIP_CONFIG			0x1f
+#define AT803X_BT_BX_REG_SEL			0x8000
 
 #define AT803X_DEBUG_ADDR			0x1D
 #define AT803X_DEBUG_DATA			0x1E
 
+#define AT803X_MODE_CFG_MASK			0x0F
+#define AT803X_MODE_CFG_SGMII			0x01
+
+#define AT803X_PSSR			0x11	/*PHY-Specific Status Register*/
+#define AT803X_PSSR_MR_AN_COMPLETE	0x0200
+
 #define AT803X_DEBUG_REG_0			0x00
 #define AT803X_DEBUG_RX_CLK_DLY_EN		BIT(15)
 
@@ -355,6 +363,36 @@ static void at803x_link_change_notify(struct phy_device *phydev)
 	}
 }
 
+static int at803x_aneg_done(struct phy_device *phydev)
+{
+	int ccr;
+
+	int aneg_done = genphy_aneg_done(phydev);
+	if (aneg_done != BMSR_ANEGCOMPLETE)
+		return aneg_done;
+
+	/*
+	 * in SGMII mode, if copper side autoneg is successful,
+	 * also check SGMII side autoneg result
+	 */
+	ccr = phy_read(phydev, AT803X_REG_CHIP_CONFIG);
+	if ((ccr & AT803X_MODE_CFG_MASK) != AT803X_MODE_CFG_SGMII)
+		return aneg_done;
+
+	/* switch to SGMII/fiber page */
+	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
+
+	/* check if the SGMII link is OK. */
+	if (!(phy_read(phydev, AT803X_PSSR) & AT803X_PSSR_MR_AN_COMPLETE)) {
+		pr_warn("803x_aneg_done: SGMII link is not ok\n");
+		aneg_done = 0;
+	}
+	/* switch back to copper page */
+	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);
+
+	return aneg_done;
+}
+
 static struct phy_driver at803x_driver[] = {
 {
 	/* ATHEROS 8035 */
@@ -406,6 +444,7 @@ static struct phy_driver at803x_driver[] = {
 	.flags			= PHY_HAS_INTERRUPT,
 	.config_aneg		= genphy_config_aneg,
 	.read_status		= genphy_read_status,
+	.aneg_done		= at803x_aneg_done,
 	.ack_interrupt		= &at803x_ack_interrupt,
 	.config_intr		= &at803x_config_intr,
 } };
-- 
2.7.4
