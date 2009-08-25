From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 10/12] broadcom: Add AC131 phy support
Date: Tue, 25 Aug 2009 13:10:58 -0700
Message-ID: <1251232430.25417@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4227 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756118AbZHYUeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 16:34:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the AC131 fast ethernet transceiver.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/phy/broadcom.c |  158 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 158 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index dec4dec..3262a24 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -142,6 +142,35 @@
 #define PHY_BCM_FLAGS_MODE_1000BX	0x00000002
 #define PHY_BCM_FLAGS_MODE_COPPER	0x00000001
 
+
+/*****************************************************************************/
+/* Fast Ethernet Transceiver definitions. */
+/*****************************************************************************/
+
+#define MII_BRCM_FET_INTREG		0x1a	/* Interrupt register */
+#define MII_BRCM_FET_IR_MASK		0x0100	/* Mask all interrupts */
+#define MII_BRCM_FET_IR_LINK_EN		0x0200	/* Link status change enable */
+#define MII_BRCM_FET_IR_SPEED_EN	0x0400	/* Link speed change enable */
+#define MII_BRCM_FET_IR_DUPLEX_EN	0x0800	/* Duplex mode change enable */
+#define MII_BRCM_FET_IR_ENABLE		0x4000	/* Interrupt enable */
+
+#define MII_BRCM_FET_BRCMTEST		0x1f	/* Brcm test register */
+#define MII_BRCM_FET_BT_SRE		0x0080	/* Shadow register enable */
+
+
+/*** Shadow register definitions ***/
+
+#define MII_BRCM_FET_SHDW_MISCCTRL	0x10	/* Shadow misc ctrl */
+#define MII_BRCM_FET_SHDW_MC_FAME	0x4000	/* Force Auto MDIX enable */
+
+#define MII_BRCM_FET_SHDW_AUXMODE4	0x1a	/* Auxiliary mode 4 */
+#define MII_BRCM_FET_SHDW_AM4_LED_MASK	0x0003
+#define MII_BRCM_FET_SHDW_AM4_LED_MODE1 0x0001
+
+#define MII_BRCM_FET_SHDW_AUXSTAT2	0x1b	/* Auxiliary status 2 */
+#define MII_BRCM_FET_SHDW_AS2_APDE	0x0020	/* Auto power down enable */
+
+
 MODULE_DESCRIPTION("Broadcom PHY driver");
 MODULE_AUTHOR("Maciej W. Rozycki");
 MODULE_LICENSE("GPL");
@@ -436,6 +465,114 @@ static int bcm5481_config_aneg(struct phy_device *phydev)
 	return ret;
 }
 
+static int brcm_phy_setbits(struct phy_device *phydev, int reg, int set)
+{
+	int val;
+
+	val = phy_read(phydev, reg);
+	if (val < 0)
+		return val;
+
+	return phy_write(phydev, reg, val | set);
+}
+
+static int brcm_fet_config_init(struct phy_device *phydev)
+{
+	int reg, err, err2, brcmtest;
+
+	/* Reset the PHY to bring it to a known state. */
+	err = phy_write(phydev, MII_BMCR, BMCR_RESET);
+	if (err < 0)
+		return err;
+
+	reg = phy_read(phydev, MII_BRCM_FET_INTREG);
+	if (reg < 0)
+		return reg;
+
+	/* Unmask events we are interested in and mask interrupts globally. */
+	reg = MII_BRCM_FET_IR_DUPLEX_EN |
+	      MII_BRCM_FET_IR_SPEED_EN |
+	      MII_BRCM_FET_IR_LINK_EN |
+	      MII_BRCM_FET_IR_ENABLE |
+	      MII_BRCM_FET_IR_MASK;
+
+	err = phy_write(phydev, MII_BRCM_FET_INTREG, reg);
+	if (err < 0)
+		return err;
+
+	/* Enable shadow register access */
+	brcmtest = phy_read(phydev, MII_BRCM_FET_BRCMTEST);
+	if (brcmtest < 0)
+		return brcmtest;
+
+	reg = brcmtest | MII_BRCM_FET_BT_SRE;
+
+	err = phy_write(phydev, MII_BRCM_FET_BRCMTEST, reg);
+	if (err < 0)
+		return err;
+
+	/* Set the LED mode */
+	reg = phy_read(phydev, MII_BRCM_FET_SHDW_AUXMODE4);
+	if (reg < 0) {
+		err = reg;
+		goto done;
+	}
+
+	reg &= ~MII_BRCM_FET_SHDW_AM4_LED_MASK;
+	reg |= MII_BRCM_FET_SHDW_AM4_LED_MODE1;
+
+	err = phy_write(phydev, MII_BRCM_FET_SHDW_AUXMODE4, reg);
+	if (err < 0)
+		goto done;
+
+	/* Enable auto MDIX */
+	err = brcm_phy_setbits(phydev, MII_BRCM_FET_SHDW_MISCCTRL,
+				       MII_BRCM_FET_SHDW_MC_FAME);
+	if (err < 0)
+		goto done;
+
+	/* Enable auto power down */
+	err = brcm_phy_setbits(phydev, MII_BRCM_FET_SHDW_AUXSTAT2,
+				       MII_BRCM_FET_SHDW_AS2_APDE);
+
+done:
+	/* Disable shadow register access */
+	err2 = phy_write(phydev, MII_BRCM_FET_BRCMTEST, brcmtest);
+	if (!err)
+		err = err2;
+
+	return err;
+}
+
+static int brcm_fet_ack_interrupt(struct phy_device *phydev)
+{
+	int reg;
+
+	/* Clear pending interrupts.  */
+	reg = phy_read(phydev, MII_BRCM_FET_INTREG);
+	if (reg < 0)
+		return reg;
+
+	return 0;
+}
+
+static int brcm_fet_config_intr(struct phy_device *phydev)
+{
+	int reg, err;
+
+	reg = phy_read(phydev, MII_BRCM_FET_INTREG);
+	if (reg < 0)
+		return reg;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		reg &= ~MII_BRCM_FET_IR_MASK;
+	else
+		reg |= MII_BRCM_FET_IR_MASK;
+
+	err = phy_write(phydev, MII_BRCM_FET_INTREG, reg);
+	return err;
+}
+
 static struct phy_driver bcm5411_driver = {
 	.phy_id		= 0x00206070,
 	.phy_id_mask	= 0xfffffff0,
@@ -571,6 +708,21 @@ static struct phy_driver bcm57780_driver = {
 	.driver		= { .owner = THIS_MODULE },
 };
 
+static struct phy_driver bcmac131_driver = {
+	.phy_id		= 0x0143bc70,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Broadcom BCMAC131",
+	.features	= PHY_BASIC_FEATURES |
+			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
+	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.config_init	= brcm_fet_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.ack_interrupt	= brcm_fet_ack_interrupt,
+	.config_intr	= brcm_fet_config_intr,
+	.driver		= { .owner = THIS_MODULE },
+};
+
 static int __init broadcom_init(void)
 {
 	int ret;
@@ -602,8 +754,13 @@ static int __init broadcom_init(void)
 	ret = phy_driver_register(&bcm57780_driver);
 	if (ret)
 		goto out_57780;
+	ret = phy_driver_register(&bcmac131_driver);
+	if (ret)
+		goto out_ac131;
 	return ret;
 
+out_ac131:
+	phy_driver_unregister(&bcm57780_driver);
 out_57780:
 	phy_driver_unregister(&bcm50610m_driver);
 out_50610m:
@@ -626,6 +783,7 @@ out_5411:
 
 static void __exit broadcom_exit(void)
 {
+	phy_driver_unregister(&bcmac131_driver);
 	phy_driver_unregister(&bcm57780_driver);
 	phy_driver_unregister(&bcm50610m_driver);
 	phy_driver_unregister(&bcm50610_driver);
-- 
1.6.3.3


