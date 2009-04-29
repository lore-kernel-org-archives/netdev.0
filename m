From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 16/16] mii: Rewrite mii_ethtool_gset() to report
	mdio_support and lp_advertising
Date: Wed, 29 Apr 2009 19:34:44 +0100
Message-ID: <1241030084.3246.81.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:54489 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752450AbZD2Seq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:34:46 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ignore link partner advertising flags while AN is not complete.

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I can't seem to find any hardware whose driver uses the mii module now,
so this is unfortunately untested.

This might well be better split into 2 or more patches.

Ben.

 drivers/net/mii.c |   91 +++++++++++++++++++++++++++++++++--------------------
 1 files changed, 57 insertions(+), 34 deletions(-)

diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index 9205605..d81a5d2 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -31,7 +31,27 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
-#include <linux/mii.h>
+#include <linux/mdio.h>
+
+static u32 mii_get_an(struct mii_if_info *mii, u16 addr)
+{
+	u32 result = 0;
+	int advert;
+
+	advert = mii->mdio_read(mii->dev, mii->phy_id, addr);
+	if (advert & LPA_LPACK)
+		result |= ADVERTISED_Autoneg;
+	if (advert & ADVERTISE_10HALF)
+		result |= ADVERTISED_10baseT_Half;
+	if (advert & ADVERTISE_10FULL)
+		result |= ADVERTISED_10baseT_Full;
+	if (advert & ADVERTISE_100HALF)
+		result |= ADVERTISED_100baseT_Half;
+	if (advert & ADVERTISE_100FULL)
+		result |= ADVERTISED_100baseT_Full;
+
+	return result;
+}
 
 /**
  * mii_ethtool_gset - get settings that are specified in @ecmd
@@ -43,8 +63,8 @@
 int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 {
 	struct net_device *dev = mii->dev;
-	u32 advert, bmcr, lpa, nego;
-	u32 advert2 = 0, bmcr2 = 0, lpa2 = 0;
+	u16 bmcr, bmsr, ctrl1000 = 0, stat1000 = 0;
+	u32 nego;
 
 	ecmd->supported =
 	    (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -62,50 +82,51 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 
 	/* this isn't fully supported at higher layers */
 	ecmd->phy_address = mii->phy_id;
+	ecmd->mdio_support = MDIO_SUPPORTS_C22;
 
 	ecmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
-	advert = mii->mdio_read(dev, mii->phy_id, MII_ADVERTISE);
-	if (mii->supports_gmii)
-		advert2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
-
-	if (advert & ADVERTISE_10HALF)
-		ecmd->advertising |= ADVERTISED_10baseT_Half;
-	if (advert & ADVERTISE_10FULL)
-		ecmd->advertising |= ADVERTISED_10baseT_Full;
-	if (advert & ADVERTISE_100HALF)
-		ecmd->advertising |= ADVERTISED_100baseT_Half;
-	if (advert & ADVERTISE_100FULL)
-		ecmd->advertising |= ADVERTISED_100baseT_Full;
-	if (advert2 & ADVERTISE_1000HALF)
-		ecmd->advertising |= ADVERTISED_1000baseT_Half;
-	if (advert2 & ADVERTISE_1000FULL)
-		ecmd->advertising |= ADVERTISED_1000baseT_Full;
 
 	bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
-	lpa = mii->mdio_read(dev, mii->phy_id, MII_LPA);
+	bmsr = mii->mdio_read(dev, mii->phy_id, MII_BMSR);
 	if (mii->supports_gmii) {
-		bmcr2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
-		lpa2 = mii->mdio_read(dev, mii->phy_id, MII_STAT1000);
+ 		ctrl1000 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
+		stat1000 = mii->mdio_read(dev, mii->phy_id, MII_STAT1000);
 	}
 	if (bmcr & BMCR_ANENABLE) {
 		ecmd->advertising |= ADVERTISED_Autoneg;
 		ecmd->autoneg = AUTONEG_ENABLE;
 
-		nego = mii_nway_result(advert & lpa);
-		if ((bmcr2 & (ADVERTISE_1000HALF | ADVERTISE_1000FULL)) &
-		    (lpa2 >> 2))
+		ecmd->advertising |= mii_get_an(mii, MII_ADVERTISE);
+		if (ctrl1000 & ADVERTISE_1000HALF)
+			ecmd->advertising |= ADVERTISED_1000baseT_Half;
+		if (ctrl1000 & ADVERTISE_1000FULL)
+			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+
+		if (bmsr & BMSR_ANEGCOMPLETE) {
+			ecmd->lp_advertising = mii_get_an(mii, MII_LPA);
+			if (stat1000 & LPA_1000HALF)
+				ecmd->lp_advertising |=
+					ADVERTISED_1000baseT_Half;
+			if (stat1000 & LPA_1000FULL)
+				ecmd->lp_advertising |=
+					ADVERTISED_1000baseT_Full;
+		} else {
+			ecmd->lp_advertising = 0;
+		}
+
+		nego = ecmd->advertising & ecmd->lp_advertising;
+
+		if (nego & (ADVERTISED_1000baseT_Full |
+			    ADVERTISED_1000baseT_Half)) {
 			ecmd->speed = SPEED_1000;
-		else if (nego == LPA_100FULL || nego == LPA_100HALF)
+			ecmd->duplex = !!(nego & ADVERTISED_1000baseT_Full);
+		} else if (nego & (ADVERTISED_100baseT_Full |
+				   ADVERTISED_100baseT_Half)) {
 			ecmd->speed = SPEED_100;
-		else
-			ecmd->speed = SPEED_10;
-		if ((lpa2 & LPA_1000FULL) || nego == LPA_100FULL ||
-		    nego == LPA_10FULL) {
-			ecmd->duplex = DUPLEX_FULL;
-			mii->full_duplex = 1;
+			ecmd->duplex = !!(nego & ADVERTISED_100baseT_Full);
 		} else {
-			ecmd->duplex = DUPLEX_HALF;
-			mii->full_duplex = 0;
+			ecmd->speed = SPEED_10;
+			ecmd->duplex = !!(nego & ADVERTISED_10baseT_Full);
 		}
 	} else {
 		ecmd->autoneg = AUTONEG_DISABLE;
@@ -116,6 +137,8 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 		ecmd->duplex = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL : DUPLEX_HALF;
 	}
 
+	mii->full_duplex = ecmd->duplex;
+
 	/* ignore maxtxpkt, maxrxpkt for now */
 
 	return 0;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

