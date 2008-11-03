From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 10/15] tg3: Refine phylib support
Date: Mon, 3 Nov 2008 02:13:56 -0800
Message-ID: <1225751627.6193@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4895 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756126AbYKCWd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch refines the phylib support in the tg3 driver.  The patch does
the following things :

* Rename tg3_mdio_config() to tg3_mdio_config_5785().  The 5785 will be
  the only device that will use it so the name might as well reflect
  that.
* Fix a memory leak if mdiobus_register() fails.
* Add code to deal with phy device detection failures.
* Add code to correct the supported list of phy features based on the
  MAC <=> PHY interface.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   47 +++++++++++++++++++++++++++++++++++------------
 1 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d0f314c..03a930e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -877,7 +877,7 @@ static int tg3_mdio_reset(struct mii_bus *bp)
 	return 0;
 }
 
-static void tg3_mdio_config(struct tg3 *tp)
+static void tg3_mdio_config_5785(struct tg3 *tp)
 {
 	u32 val;
 
@@ -934,8 +934,9 @@ static void tg3_mdio_start(struct tg3 *tp)
 	tw32_f(MAC_MI_MODE, tp->mi_mode);
 	udelay(80);
 
-	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED)
-		tg3_mdio_config(tp);
+	if ((tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+		tg3_mdio_config_5785(tp);
 }
 
 static void tg3_mdio_stop(struct tg3 *tp)
@@ -989,14 +990,20 @@ static int tg3_mdio_init(struct tg3 *tp)
 	if (i) {
 		printk(KERN_WARNING "%s: mdiobus_reg failed (0x%x)\n",
 			tp->dev->name, i);
+		mdiobus_free(tp->mdio_bus);
 		return i;
 	}
 
-	tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_INITED;
-
 	phydev = tp->mdio_bus->phy_map[PHY_ADDR];
 
-	switch (phydev->phy_id) {
+	if (!phydev || !phydev->drv) {
+		printk(KERN_WARNING "%s: No PHY devices\n", tp->dev->name);
+		mdiobus_unregister(tp->mdio_bus);
+		mdiobus_free(tp->mdio_bus);
+		return -ENODEV;
+	}
+
+	switch (phydev->drv->phy_id & phydev->drv->phy_id_mask) {
 	case TG3_PHY_ID_BCM50610:
 		phydev->interface = PHY_INTERFACE_MODE_RGMII;
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)
@@ -1011,7 +1018,10 @@ static int tg3_mdio_init(struct tg3 *tp)
 		break;
 	}
 
-	tg3_mdio_config(tp);
+	tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_INITED;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+		tg3_mdio_config_5785(tp);
 
 	return 0;
 }
@@ -1351,12 +1361,25 @@ static int tg3_phy_init(struct tg3 *tp)
 		return PTR_ERR(phydev);
 	}
 
-	tp->tg3_flags3 |= TG3_FLG3_PHY_CONNECTED;
-
 	/* Mask with MAC supported features. */
-	phydev->supported &= (PHY_GBIT_FEATURES |
-			      SUPPORTED_Pause |
-			      SUPPORTED_Asym_Pause);
+	switch (phydev->interface) {
+	case PHY_INTERFACE_MODE_GMII:
+	case PHY_INTERFACE_MODE_RGMII:
+		phydev->supported &= (PHY_GBIT_FEATURES |
+				      SUPPORTED_Pause |
+				      SUPPORTED_Asym_Pause);
+		break;
+	case PHY_INTERFACE_MODE_MII:
+		phydev->supported &= (PHY_BASIC_FEATURES |
+				      SUPPORTED_Pause |
+				      SUPPORTED_Asym_Pause);
+		break;
+	default:
+		phy_disconnect(tp->mdio_bus->phy_map[PHY_ADDR]);
+		return -EINVAL;
+	}
+
+	tp->tg3_flags3 |= TG3_FLG3_PHY_CONNECTED;
 
 	phydev->advertising = phydev->supported;
 
-- 
1.5.6.4



