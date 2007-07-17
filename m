From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH 3/4] phy: Fix Vitesse RGMII-ID support
Date: Mon, 16 Jul 2007 20:27:00 -0500
Message-ID: <11846356241295-git-send-email-afleming@freescale.com>
References: <1184635621688-git-send-email-afleming@freescale.com> <1184635622653-git-send-email-afleming@freescale.com> <11846356233423-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com, paulus@samba.org, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:50114 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754246AbXGQB1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 21:27:35 -0400
In-Reply-To: <11846356233423-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Vitesse PHY on the 8641D needs to be set up with internal delay to
work in RGMII mode.  So we add skew when it is set to RGMII_ID mode.

Signed-off-by: Andy Fleming <afleming@freescale.com>
Signed-off-by: Haruki Dai <Dai.Haruki@freescale.com>
Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
---
 drivers/net/phy/vitesse.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index f39ab76..6a53856 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -21,6 +21,10 @@
 /* Vitesse Extended Control Register 1 */
 #define MII_VSC8244_EXT_CON1           0x17
 #define MII_VSC8244_EXTCON1_INIT       0x0000
+#define MII_VSC8244_EXTCON1_TX_SKEW_MASK	0x0c00
+#define MII_VSC8244_EXTCON1_RX_SKEW_MASK	0x0300
+#define MII_VSC8244_EXTCON1_TX_SKEW	0x0800
+#define MII_VSC8244_EXTCON1_RX_SKEW	0x0200
 
 /* Vitesse Interrupt Mask Register */
 #define MII_VSC8244_IMASK		0x19
@@ -39,7 +43,7 @@
 
 /* Vitesse Auxiliary Control/Status Register */
 #define MII_VSC8244_AUX_CONSTAT        	0x1c
-#define MII_VSC8244_AUXCONSTAT_INIT    	0x0004
+#define MII_VSC8244_AUXCONSTAT_INIT    	0x0000
 #define MII_VSC8244_AUXCONSTAT_DUPLEX  	0x0020
 #define MII_VSC8244_AUXCONSTAT_SPEED   	0x0018
 #define MII_VSC8244_AUXCONSTAT_GBIT    	0x0010
@@ -51,6 +55,7 @@ MODULE_LICENSE("GPL");
 
 static int vsc824x_config_init(struct phy_device *phydev)
 {
+	int extcon;
 	int err;
 
 	err = phy_write(phydev, MII_VSC8244_AUX_CONSTAT,
@@ -58,8 +63,20 @@ static int vsc824x_config_init(struct phy_device *phydev)
 	if (err < 0)
 		return err;
 
-	err = phy_write(phydev, MII_VSC8244_EXT_CON1,
-			MII_VSC8244_EXTCON1_INIT);
+	extcon = phy_read(phydev, MII_VSC8244_EXT_CON1);
+
+	if (extcon < 0)
+		return err;
+
+	extcon &= ~(MII_VSC8244_EXTCON1_TX_SKEW_MASK |
+			MII_VSC8244_EXTCON1_RX_SKEW_MASK);
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
+		extcon |= (MII_VSC8244_EXTCON1_TX_SKEW |
+				MII_VSC8244_EXTCON1_RX_SKEW);
+
+	err = phy_write(phydev, MII_VSC8244_EXT_CON1, extcon);
+
 	return err;
 }
 
-- 
1.5.0.2.230.gfbe3d-dirty

