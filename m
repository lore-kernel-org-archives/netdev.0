From: James Chapman <jchapman@katalix.com>
Subject: [PATCH: 2.6.11-rc5 netdev-2.6] mii: add GigE support
Date: Fri, 25 Feb 2005 21:20:05 +0000
Message-ID: <421F9685.5090109@katalix.com>
References: <421B466C.4010902@katalix.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090905080402050506000709"
Cc: Jeff Garzik <jgarzik@pobox.com>
To: Netdev <netdev@oss.sgi.com>
In-Reply-To: <421B466C.4010902@katalix.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090905080402050506000709
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Add support for GigE PHYs in MII support library.

This patch allows GigE drivers to use the MII library the same way
10/100 drivers do.

Since the MII library is already used by lots of network drivers and the
GigE MII register bit definitions were reserved when many 10/100 PHYs
were designed, the new GigE registers are accessed only if a driver
specifically enables it. Existing 10/100 drivers should see no behavior
differences with this change.

Signed-off-by: James Chapman <jchapman@katalix.com>


--------------090905080402050506000709
Content-Type: text/plain;
 name="mii.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mii.patch"

diff -Nru a/drivers/net/mii.c b/drivers/net/mii.c
--- a/drivers/net/mii.c	2005-02-25 21:12:07 +00:00
+++ b/drivers/net/mii.c	2005-02-25 21:12:07 +00:00
@@ -37,6 +37,7 @@
 {
 	struct net_device *dev = mii->dev;
 	u32 advert, bmcr, lpa, nego;
+	u32 advert2 = 0, bmcr2 = 0, lpa2 = 0;
 
 	ecmd->supported =
 	    (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -54,6 +55,9 @@
 
 	ecmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
 	advert = mii->mdio_read(dev, mii->phy_id, MII_ADVERTISE);
+	if (mii->supports_gmii)
+		advert2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
+
 	if (advert & ADVERTISE_10HALF)
 		ecmd->advertising |= ADVERTISED_10baseT_Half;
 	if (advert & ADVERTISE_10FULL)
@@ -62,19 +66,31 @@
 		ecmd->advertising |= ADVERTISED_100baseT_Half;
 	if (advert & ADVERTISE_100FULL)
 		ecmd->advertising |= ADVERTISED_100baseT_Full;
+	if (advert2 & ADVERTISE_1000HALF)
+		ecmd->advertising |= ADVERTISED_1000baseT_Half;
+	if (advert2 & ADVERTISE_1000FULL)
+		ecmd->advertising |= ADVERTISED_1000baseT_Full;
 
 	bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
 	lpa = mii->mdio_read(dev, mii->phy_id, MII_LPA);
+	if (mii->supports_gmii) {
+		bmcr2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
+		lpa2 = mii->mdio_read(dev, mii->phy_id, MII_STAT1000);
+	}
 	if (bmcr & BMCR_ANENABLE) {
 		ecmd->advertising |= ADVERTISED_Autoneg;
 		ecmd->autoneg = AUTONEG_ENABLE;
 		
 		nego = mii_nway_result(advert & lpa);
-		if (nego == LPA_100FULL || nego == LPA_100HALF)
+		if ((bmcr2 & (ADVERTISE_1000HALF | ADVERTISE_1000FULL)) & 
+		    (lpa2 >> 2))
+			ecmd->speed = SPEED_1000;
+		else if (nego == LPA_100FULL || nego == LPA_100HALF)
 			ecmd->speed = SPEED_100;
 		else
 			ecmd->speed = SPEED_10;
-		if (nego == LPA_100FULL || nego == LPA_10FULL) {
+		if ((lpa2 & LPA_1000FULL) || nego == LPA_100FULL ||
+		    nego == LPA_10FULL) {
 			ecmd->duplex = DUPLEX_FULL;
 			mii->full_duplex = 1;
 		} else {
@@ -84,7 +100,9 @@
 	} else {
 		ecmd->autoneg = AUTONEG_DISABLE;
 
-		ecmd->speed = (bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10;
+		ecmd->speed = ((bmcr2 & BMCR_SPEED1000 && 
+				(bmcr & BMCR_SPEED100) == 0) ? SPEED_1000 :
+			       (bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10);
 		ecmd->duplex = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL : DUPLEX_HALF;
 	}
 
@@ -97,7 +115,9 @@
 {
 	struct net_device *dev = mii->dev;
 
-	if (ecmd->speed != SPEED_10 && ecmd->speed != SPEED_100)
+	if (ecmd->speed != SPEED_10 && 
+	    ecmd->speed != SPEED_100 && 
+	    ecmd->speed != SPEED_1000)
 		return -EINVAL;
 	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
 		return -EINVAL;
@@ -109,21 +129,30 @@
 		return -EINVAL;
 	if (ecmd->autoneg != AUTONEG_DISABLE && ecmd->autoneg != AUTONEG_ENABLE)
 		return -EINVAL;
+	if ((ecmd->speed == SPEED_1000) && (!mii->supports_gmii))
+		return -EINVAL;
 				  
 	/* ignore supported, maxtxpkt, maxrxpkt */
 	
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		u32 bmcr, advert, tmp;
+		u32 advert2 = 0, tmp2 = 0;
 
 		if ((ecmd->advertising & (ADVERTISED_10baseT_Half |
 					  ADVERTISED_10baseT_Full |
 					  ADVERTISED_100baseT_Half |
-					  ADVERTISED_100baseT_Full)) == 0)
+					  ADVERTISED_100baseT_Full |
+					  ADVERTISED_1000baseT_Half |
+					  ADVERTISED_1000baseT_Full)) == 0)
 			return -EINVAL;
 
 		/* advertise only what has been requested */
 		advert = mii->mdio_read(dev, mii->phy_id, MII_ADVERTISE);
 		tmp = advert & ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
+		if (mii->supports_gmii) {
+			advert2 = mii->mdio_read(dev, mii->phy_id, MII_CTRL1000);
+			tmp2 = advert2 & ~(ADVERTISE_1000HALF | ADVERTISE_1000FULL);
+		}
 		if (ecmd->advertising & ADVERTISED_10baseT_Half)
 			tmp |= ADVERTISE_10HALF;
 		if (ecmd->advertising & ADVERTISED_10baseT_Full)
@@ -132,10 +161,18 @@
 			tmp |= ADVERTISE_100HALF;
 		if (ecmd->advertising & ADVERTISED_100baseT_Full)
 			tmp |= ADVERTISE_100FULL;
+		if (mii->supports_gmii) {
+			if (ecmd->advertising & ADVERTISED_1000baseT_Half)
+				advert2 |= ADVERTISE_1000HALF;
+			if (ecmd->advertising & ADVERTISED_1000baseT_Full)
+				advert2 |= ADVERTISE_1000FULL;
+		}
 		if (advert != tmp) {
 			mii->mdio_write(dev, mii->phy_id, MII_ADVERTISE, tmp);
 			mii->advertising = tmp;
 		}
+		if ((mii->supports_gmii) && (advert2 != tmp2))
+			mii->mdio_write(dev, mii->phy_id, MII_CTRL1000, tmp2);
 		
 		/* turn on autonegotiation, and force a renegotiate */
 		bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
@@ -148,8 +185,11 @@
 
 		/* turn off auto negotiation, set speed and duplexity */
 		bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
-		tmp = bmcr & ~(BMCR_ANENABLE | BMCR_SPEED100 | BMCR_FULLDPLX);
-		if (ecmd->speed == SPEED_100)
+		tmp = bmcr & ~(BMCR_ANENABLE | BMCR_SPEED100 | 
+			       BMCR_SPEED1000 | BMCR_FULLDPLX);
+		if (ecmd->speed == SPEED_1000)
+			tmp |= BMCR_SPEED1000;
+		else if (ecmd->speed == SPEED_100)
 			tmp |= BMCR_SPEED100;
 		if (ecmd->duplex == DUPLEX_FULL) {
 			tmp |= BMCR_FULLDPLX;
@@ -207,6 +247,7 @@
 {
 	unsigned int old_carrier, new_carrier;
 	int advertise, lpa, media, duplex;
+	int lpa2 = 0;
 
 	/* if forced media, go no further */
 	if (mii->force_media)
@@ -243,16 +284,20 @@
 		mii->advertising = advertise;
 	}
 	lpa = mii->mdio_read(mii->dev, mii->phy_id, MII_LPA);
+	if (mii->supports_gmii)
+		lpa2 = mii->mdio_read(mii->dev, mii->phy_id, MII_STAT1000);
 
 	/* figure out media and duplex from advertise and LPA values */
 	media = mii_nway_result(lpa & advertise);
 	duplex = (media & ADVERTISE_FULL) ? 1 : 0;
+	if (lpa2 & LPA_1000FULL)
+		duplex = 1;
 
 	if (ok_to_print)
 		printk(KERN_INFO "%s: link up, %sMbps, %s-duplex, lpa 0x%04X\n",
 		       mii->dev->name,
-		       media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ?
-		       		"100" : "10",
+		       lpa2 & (LPA_1000FULL | LPA_1000HALF) ? "1000" :
+		       media & (ADVERTISE_100FULL | ADVERTISE_100HALF) ? "100" : "10",
 		       duplex ? "full" : "half",
 		       lpa);
 
diff -Nru a/include/linux/mii.h b/include/linux/mii.h
--- a/include/linux/mii.h	2005-02-25 21:12:07 +00:00
+++ b/include/linux/mii.h	2005-02-25 21:12:07 +00:00
@@ -20,6 +20,8 @@
 #define MII_ADVERTISE       0x04        /* Advertisement control reg   */
 #define MII_LPA             0x05        /* Link partner ability reg    */
 #define MII_EXPANSION       0x06        /* Expansion register          */
+#define MII_CTRL1000        0x09        /* 1000BASE-T control          */
+#define MII_STAT1000        0x0a        /* 1000BASE-T status           */
 #define MII_DCOUNTER        0x12        /* Disconnect counter          */
 #define MII_FCSCOUNTER      0x13        /* False carrier counter       */
 #define MII_NWAYTEST        0x14        /* N-way auto-neg test reg     */
@@ -67,9 +69,9 @@
 #define ADVERTISE_100HALF       0x0080  /* Try for 100mbps half-duplex */
 #define ADVERTISE_100FULL       0x0100  /* Try for 100mbps full-duplex */
 #define ADVERTISE_100BASE4      0x0200  /* Try for 100mbps 4k packets  */
-#define ADVERTISE_PAUSE_CAP	0x0400  /* Try for pause               */
-#define ADVERTISE_PAUSE_ASYM	0x0800  /* Try for asymetric pause     */
-#define ADVERTISE_RESV          0x1c00  /* Unused...                   */
+#define ADVERTISE_PAUSE_CAP     0x0400  /* Try for pause               */
+#define ADVERTISE_PAUSE_ASYM    0x0800  /* Try for asymetric pause     */
+#define ADVERTISE_RESV          0x1000  /* Unused...                   */
 #define ADVERTISE_RFAULT        0x2000  /* Say we can detect faults    */
 #define ADVERTISE_LPACK         0x4000  /* Ack link partners response  */
 #define ADVERTISE_NPAGE         0x8000  /* Next page bit               */
@@ -86,9 +88,9 @@
 #define LPA_100HALF             0x0080  /* Can do 100mbps half-duplex  */
 #define LPA_100FULL             0x0100  /* Can do 100mbps full-duplex  */
 #define LPA_100BASE4            0x0200  /* Can do 100mbps 4k packets   */
-#define LPA_PAUSE_CAP		0x0400  /* Can pause                   */
-#define LPA_PAUSE_ASYM		0x0800	/* Can pause asymetrically     */
-#define LPA_RESV                0x1c00  /* Unused...                   */
+#define LPA_PAUSE_CAP           0x0400  /* Can pause                   */
+#define LPA_PAUSE_ASYM          0x0800  /* Can pause asymetrically     */
+#define LPA_RESV                0x1000  /* Unused...                   */
 #define LPA_RFAULT              0x2000  /* Link partner faulted        */
 #define LPA_LPACK               0x4000  /* Link partner acked us       */
 #define LPA_NPAGE               0x8000  /* Next page bit               */
@@ -109,6 +111,15 @@
 #define NWAYTEST_LOOPBACK       0x0100  /* Enable loopback for N-way   */
 #define NWAYTEST_RESV2          0xfe00  /* Unused...                   */
 
+/* 1000BASE-T Control register */
+#define ADVERTISE_1000FULL      0x0200  /* Advertise 1000BASE-T full duplex */
+#define ADVERTISE_1000HALF      0x0100  /* Advertise 1000BASE-T half duplex */
+
+/* 1000BASE-T Status register */
+#define LPA_1000LOCALRXOK       0x2000  /* Link partner local receiver status */
+#define LPA_1000REMRXOK         0x1000  /* Link partner remote receiver status */
+#define LPA_1000FULL            0x0800  /* Link partner 1000BASE-T full duplex */
+#define LPA_1000HALF            0x0400  /* Link partner 1000BASE-T half duplex */
 
 struct mii_if_info {
 	int phy_id;
@@ -118,6 +129,7 @@
 
 	unsigned int full_duplex : 1;	/* is full duplex? */
 	unsigned int force_media : 1;	/* is autoneg. disabled? */
+	unsigned int supports_gmii : 1; /* are GMII registers supported? */
 
 	struct net_device *dev;
 	int (*mdio_read) (struct net_device *dev, int phy_id, int location);

--------------090905080402050506000709--
