From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/5] net: phy: broadcom: Move bcm54xx_auxctl_{read,write} to common library
Date: Tue, 22 Nov 2016 11:40:54 -0800
Message-ID: <20161122194058.29820-2-f.fainelli@gmail.com>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bcm-kernel-feedback-list@broadcom.com,
        andrew@lunn.ch, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35040 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933856AbcKVTlL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 14:41:11 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so2898996pga.2
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 11:41:10 -0800 (PST)
In-Reply-To: <20161122194058.29820-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are going to need these functions to implement support for Broadcom
Wirespeed, aka downshift.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm-phy-lib.c | 17 +++++++++++++++++
 drivers/net/phy/bcm-phy-lib.h |  3 +++
 drivers/net/phy/broadcom.c    | 15 ---------------
 3 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
index df0416db0b88..18e11b3a0f41 100644
--- a/drivers/net/phy/bcm-phy-lib.c
+++ b/drivers/net/phy/bcm-phy-lib.c
@@ -50,6 +50,23 @@ int bcm_phy_read_exp(struct phy_device *phydev, u16 reg)
 }
 EXPORT_SYMBOL_GPL(bcm_phy_read_exp);
 
+int bcm54xx_auxctl_read(struct phy_device *phydev, u16 regnum)
+{
+	/* The register must be written to both the Shadow Register Select and
+	 * the Shadow Read Register Selector
+	 */
+	phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum |
+		  regnum << MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT);
+	return phy_read(phydev, MII_BCM54XX_AUX_CTL);
+}
+EXPORT_SYMBOL_GPL(bcm54xx_auxctl_read);
+
+int bcm54xx_auxctl_write(struct phy_device *phydev, u16 regnum, u16 val)
+{
+	return phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum | val);
+}
+EXPORT_SYMBOL(bcm54xx_auxctl_write);
+
 int bcm_phy_write_misc(struct phy_device *phydev,
 		       u16 reg, u16 chl, u16 val)
 {
diff --git a/drivers/net/phy/bcm-phy-lib.h b/drivers/net/phy/bcm-phy-lib.h
index b2091c88b44d..31cb4fdf5d5a 100644
--- a/drivers/net/phy/bcm-phy-lib.h
+++ b/drivers/net/phy/bcm-phy-lib.h
@@ -19,6 +19,9 @@
 int bcm_phy_write_exp(struct phy_device *phydev, u16 reg, u16 val);
 int bcm_phy_read_exp(struct phy_device *phydev, u16 reg);
 
+int bcm54xx_auxctl_write(struct phy_device *phydev, u16 regnum, u16 val);
+int bcm54xx_auxctl_read(struct phy_device *phydev, u16 regnum);
+
 int bcm_phy_write_misc(struct phy_device *phydev,
 		       u16 reg, u16 chl, u16 value);
 int bcm_phy_read_misc(struct phy_device *phydev,
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index b1e32e9be1b3..409b365f12b1 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -30,21 +30,6 @@ MODULE_DESCRIPTION("Broadcom PHY driver");
 MODULE_AUTHOR("Maciej W. Rozycki");
 MODULE_LICENSE("GPL");
 
-static int bcm54xx_auxctl_read(struct phy_device *phydev, u16 regnum)
-{
-	/* The register must be written to both the Shadow Register Select and
-	 * the Shadow Read Register Selector
-	 */
-	phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum |
-		  regnum << MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT);
-	return phy_read(phydev, MII_BCM54XX_AUX_CTL);
-}
-
-static int bcm54xx_auxctl_write(struct phy_device *phydev, u16 regnum, u16 val)
-{
-	return phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum | val);
-}
-
 static int bcm54810_config(struct phy_device *phydev)
 {
 	int rc, val;
-- 
2.9.3
