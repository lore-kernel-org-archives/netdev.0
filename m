From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 1/12]: sungem_phy: support bcm5461 phy, autoneg.
Date: Tue, 20 Feb 2007 16:30:50 -0600
Message-ID: <20070220223050.GA28895@austin.ibm.com>
References: <20070220221314.GU923@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	kou.ishizaki@toshiba.co.jp, arnd@arndb.de,
	Jens Osterkamp <jens@de.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:51079 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030507AbXBTWaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 17:30:52 -0500
Content-Disposition: inline
In-Reply-To: <20070220221314.GU923@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Jens Osterkamp <jens@de.ibm.com>

This version moves the medium variable to the card specific structure and
changes the GMII_* to BCM54XX_* #defines.

This patch adds improved version of enable_fiber for both the 5421 and
the 5461 phy. It is now possible to specify with these wether you want
autonegotiation or not. This is needed for bladecenter switches where
some expect autonegotiation and some dont seem to like this at all.
Depending on this flag it sets phy->autoneg accordingly for the fiber mode.

More importantly it implements proper read_link and poll_link functions
for both phys which can handle both copper and fiber mode by determining
the medium first and then branching to the required functions. For fiber
they all work fine, for copper they are not tested but return the result
of the genmii_* function anyway which is supposed to work.

The patch moves the genmii_* functions around to avoid foreward declarations.

Signed-off-by: Jens Osterkamp <jens@de.ibm.com>
Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>
Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/sungem_phy.c |  389 ++++++++++++++++++++++++++++++-----------------
 drivers/net/sungem_phy.h |   10 +
 2 files changed, 263 insertions(+), 136 deletions(-)

Index: linux-2.6.20-git16/drivers/net/sungem_phy.c
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/sungem_phy.c	2007-02-20 14:24:00.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/sungem_phy.c	2007-02-20 14:33:06.000000000 -0600
@@ -310,6 +310,107 @@ static int bcm5411_init(struct mii_phy* 
 	return 0;
 }
 
+static int genmii_setup_aneg(struct mii_phy *phy, u32 advertise)
+{
+	u16 ctl, adv;
+
+	phy->autoneg = 1;
+	phy->speed = SPEED_10;
+	phy->duplex = DUPLEX_HALF;
+	phy->pause = 0;
+	phy->advertising = advertise;
+
+	/* Setup standard advertise */
+	adv = phy_read(phy, MII_ADVERTISE);
+	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
+	if (advertise & ADVERTISED_10baseT_Half)
+		adv |= ADVERTISE_10HALF;
+	if (advertise & ADVERTISED_10baseT_Full)
+		adv |= ADVERTISE_10FULL;
+	if (advertise & ADVERTISED_100baseT_Half)
+		adv |= ADVERTISE_100HALF;
+	if (advertise & ADVERTISED_100baseT_Full)
+		adv |= ADVERTISE_100FULL;
+	phy_write(phy, MII_ADVERTISE, adv);
+
+	/* Start/Restart aneg */
+	ctl = phy_read(phy, MII_BMCR);
+	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	phy_write(phy, MII_BMCR, ctl);
+
+	return 0;
+}
+
+static int genmii_setup_forced(struct mii_phy *phy, int speed, int fd)
+{
+	u16 ctl;
+
+	phy->autoneg = 0;
+	phy->speed = speed;
+	phy->duplex = fd;
+	phy->pause = 0;
+
+	ctl = phy_read(phy, MII_BMCR);
+	ctl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_ANENABLE);
+
+	/* First reset the PHY */
+	phy_write(phy, MII_BMCR, ctl | BMCR_RESET);
+
+	/* Select speed & duplex */
+	switch(speed) {
+	case SPEED_10:
+		break;
+	case SPEED_100:
+		ctl |= BMCR_SPEED100;
+		break;
+	case SPEED_1000:
+	default:
+		return -EINVAL;
+	}
+	if (fd == DUPLEX_FULL)
+		ctl |= BMCR_FULLDPLX;
+	phy_write(phy, MII_BMCR, ctl);
+
+	return 0;
+}
+
+static int genmii_poll_link(struct mii_phy *phy)
+{
+	u16 status;
+
+	(void)phy_read(phy, MII_BMSR);
+	status = phy_read(phy, MII_BMSR);
+	if ((status & BMSR_LSTATUS) == 0)
+		return 0;
+	if (phy->autoneg && !(status & BMSR_ANEGCOMPLETE))
+		return 0;
+	return 1;
+}
+
+static int genmii_read_link(struct mii_phy *phy)
+{
+	u16 lpa;
+
+	if (phy->autoneg) {
+		lpa = phy_read(phy, MII_LPA);
+
+		if (lpa & (LPA_10FULL | LPA_100FULL))
+			phy->duplex = DUPLEX_FULL;
+		else
+			phy->duplex = DUPLEX_HALF;
+		if (lpa & (LPA_100FULL | LPA_100HALF))
+			phy->speed = SPEED_100;
+		else
+			phy->speed = SPEED_10;
+		phy->pause = 0;
+	}
+	/* On non-aneg, we assume what we put in BMCR is the speed,
+	 * though magic-aneg shouldn't prevent this case from occurring
+	 */
+
+	 return 0;
+}
+
 static int generic_suspend(struct mii_phy* phy)
 {
 	phy_write(phy, MII_BMCR, BMCR_PDOWN);
@@ -364,30 +465,6 @@ static int bcm5421_init(struct mii_phy* 
 	return 0;
 }
 
-static int bcm5421_enable_fiber(struct mii_phy* phy)
-{
-	/* enable fiber mode */
-	phy_write(phy, MII_NCONFIG, 0x9020);
-	/* LEDs active in both modes, autosense prio = fiber */
-	phy_write(phy, MII_NCONFIG, 0x945f);
-
-	/* switch off fibre autoneg */
-	phy_write(phy, MII_NCONFIG, 0xfc01);
-	phy_write(phy, 0x0b, 0x0004);
-
-	return 0;
-}
-
-static int bcm5461_enable_fiber(struct mii_phy* phy)
-{
-	phy_write(phy, MII_NCONFIG, 0xfc0c);
-	phy_write(phy, MII_BMCR, 0x4140);
-	phy_write(phy, MII_NCONFIG, 0xfc0b);
-	phy_write(phy, MII_BMCR, 0x0140);
-
-	return 0;
-}
-
 static int bcm54xx_setup_aneg(struct mii_phy *phy, u32 advertise)
 {
 	u16 ctl, adv;
@@ -515,6 +592,155 @@ static int marvell88e1111_init(struct mi
 	return 0;
 }
 
+#define BCM5421_MODE_MASK	(1 << 5)
+
+static int bcm5421_poll_link(struct mii_phy* phy)
+{
+	u32 phy_reg;
+	int mode;
+
+	/* find out in what mode we are */
+	phy_write(phy, MII_NCONFIG, 0x1000);
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	mode = (phy_reg & BCM5421_MODE_MASK) >> 5;
+
+	if ( mode == BCM54XX_COPPER)
+		return genmii_poll_link(phy);
+
+	/* try to find out wether we have a link */
+	phy_write(phy, MII_NCONFIG, 0x2000);
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	if (phy_reg & 0x0020)
+		return 0;
+	else
+		return 1;
+}
+
+static int bcm5421_read_link(struct mii_phy* phy)
+{
+	u32 phy_reg;
+	int mode;
+
+	/* find out in what mode we are */
+	phy_write(phy, MII_NCONFIG, 0x1000);
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	mode = (phy_reg & BCM5421_MODE_MASK ) >> 5;
+
+	if ( mode == BCM54XX_COPPER)
+		return bcm54xx_read_link(phy);
+
+	phy->speed = SPEED_1000;
+
+	/* find out wether we are running half- or full duplex */
+	phy_write(phy, MII_NCONFIG, 0x2000);
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	if ( (phy_reg & 0x0080) >> 7)
+		phy->duplex |=  DUPLEX_HALF;
+	else
+		phy->duplex |=  DUPLEX_FULL;
+
+	return 0;
+}
+
+static int bcm5421_enable_fiber(struct mii_phy* phy, int autoneg)
+{
+	/* enable fiber mode */
+	phy_write(phy, MII_NCONFIG, 0x9020);
+	/* LEDs active in both modes, autosense prio = fiber */
+	phy_write(phy, MII_NCONFIG, 0x945f);
+
+	if (!autoneg) {
+		/* switch off fibre autoneg */
+		phy_write(phy, MII_NCONFIG, 0xfc01);
+		phy_write(phy, 0x0b, 0x0004);
+	}
+
+	phy->autoneg = autoneg;
+
+	return 0;
+}
+
+#define BCM5461_FIBER_LINK	(1 << 2)
+#define BCM5461_MODE_MASK	(3 << 1)
+
+static int bcm5461_poll_link(struct mii_phy* phy)
+{
+	u32 phy_reg;
+	int mode;
+
+	/* find out in what mode we are */
+	phy_write(phy, MII_NCONFIG, 0x7c00);
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	mode = (phy_reg & BCM5461_MODE_MASK ) >> 1;
+
+	if ( mode == BCM54XX_COPPER)
+		return genmii_poll_link(phy);
+
+	/* find out wether we have a link */
+	phy_write(phy, MII_NCONFIG, 0x7000);
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	if (phy_reg & BCM5461_FIBER_LINK)
+		return 1;
+	else
+		return 0;
+}
+
+#define BCM5461_FIBER_DUPLEX	(1 << 3)
+
+static int bcm5461_read_link(struct mii_phy* phy)
+{
+	u32 phy_reg;
+	int mode;
+
+	/* find out in what mode we are */
+	phy_write(phy, MII_NCONFIG, 0x7c00);
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	mode = (phy_reg & BCM5461_MODE_MASK ) >> 1;
+
+	if ( mode == BCM54XX_COPPER) {
+		return bcm54xx_read_link(phy);
+	}
+
+	phy->speed = SPEED_1000;
+
+	/* find out wether we are running half- or full duplex */
+	phy_write(phy, MII_NCONFIG, 0x7000);
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	if (phy_reg & BCM5461_FIBER_DUPLEX)
+		phy->duplex |=  DUPLEX_FULL;
+	else
+		phy->duplex |=  DUPLEX_HALF;
+
+	return 0;
+}
+
+static int bcm5461_enable_fiber(struct mii_phy* phy, int autoneg)
+{
+	/* select fiber mode, enable 1000 base-X registers */
+	phy_write(phy, MII_NCONFIG, 0xfc0b);
+
+	if (autoneg) {
+		/* enable fiber with no autonegotiation */
+		phy_write(phy, MII_ADVERTISE, 0x01e0);
+		phy_write(phy, MII_BMCR, 0x1140);
+	} else {
+		/* enable fiber with autonegotiation */
+		phy_write(phy, MII_BMCR, 0x0140);
+	}
+
+	phy->autoneg = autoneg;
+
+	return 0;
+}
+
 static int marvell_setup_aneg(struct mii_phy *phy, u32 advertise)
 {
 	u16 ctl, adv;
@@ -645,113 +871,6 @@ static int marvell_read_link(struct mii_
 	return 0;
 }
 
-static int genmii_setup_aneg(struct mii_phy *phy, u32 advertise)
-{
-	u16 ctl, adv;
-
-	phy->autoneg = 1;
-	phy->speed = SPEED_10;
-	phy->duplex = DUPLEX_HALF;
-	phy->pause = 0;
-	phy->advertising = advertise;
-
-	/* Setup standard advertise */
-	adv = phy_read(phy, MII_ADVERTISE);
-	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
-	if (advertise & ADVERTISED_10baseT_Half)
-		adv |= ADVERTISE_10HALF;
-	if (advertise & ADVERTISED_10baseT_Full)
-		adv |= ADVERTISE_10FULL;
-	if (advertise & ADVERTISED_100baseT_Half)
-		adv |= ADVERTISE_100HALF;
-	if (advertise & ADVERTISED_100baseT_Full)
-		adv |= ADVERTISE_100FULL;
-	if (advertise & ADVERTISED_Pause)
-		adv |= ADVERTISE_PAUSE_CAP;
-	if (advertise & ADVERTISED_Asym_Pause)
-		adv |= ADVERTISE_PAUSE_ASYM;
-	phy_write(phy, MII_ADVERTISE, adv);
-
-	/* Start/Restart aneg */
-	ctl = phy_read(phy, MII_BMCR);
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
-	phy_write(phy, MII_BMCR, ctl);
-
-	return 0;
-}
-
-static int genmii_setup_forced(struct mii_phy *phy, int speed, int fd)
-{
-	u16 ctl;
-
-	phy->autoneg = 0;
-	phy->speed = speed;
-	phy->duplex = fd;
-	phy->pause = 0;
-
-	ctl = phy_read(phy, MII_BMCR);
-	ctl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_ANENABLE);
-
-	/* First reset the PHY */
-	phy_write(phy, MII_BMCR, ctl | BMCR_RESET);
-
-	/* Select speed & duplex */
-	switch(speed) {
-	case SPEED_10:
-		break;
-	case SPEED_100:
-		ctl |= BMCR_SPEED100;
-		break;
-	case SPEED_1000:
-	default:
-		return -EINVAL;
-	}
-	if (fd == DUPLEX_FULL)
-		ctl |= BMCR_FULLDPLX;
-	phy_write(phy, MII_BMCR, ctl);
-
-	return 0;
-}
-
-static int genmii_poll_link(struct mii_phy *phy)
-{
-	u16 status;
-
-	(void)phy_read(phy, MII_BMSR);
-	status = phy_read(phy, MII_BMSR);
-	if ((status & BMSR_LSTATUS) == 0)
-		return 0;
-	if (phy->autoneg && !(status & BMSR_ANEGCOMPLETE))
-		return 0;
-	return 1;
-}
-
-static int genmii_read_link(struct mii_phy *phy)
-{
-	u16 lpa;
-
-	if (phy->autoneg) {
-		lpa = phy_read(phy, MII_LPA);
-
-		if (lpa & (LPA_10FULL | LPA_100FULL))
-			phy->duplex = DUPLEX_FULL;
-		else
-			phy->duplex = DUPLEX_HALF;
-		if (lpa & (LPA_100FULL | LPA_100HALF))
-			phy->speed = SPEED_100;
-		else
-			phy->speed = SPEED_10;
-		phy->pause = (phy->duplex == DUPLEX_FULL) &&
-			((lpa & LPA_PAUSE) != 0);
-	}
-	/* On non-aneg, we assume what we put in BMCR is the speed,
-	 * though magic-aneg shouldn't prevent this case from occurring
-	 */
-
-	 return 0;
-}
-
-
 #define MII_BASIC_FEATURES \
 	(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |	\
 	 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |	\
@@ -885,8 +1004,8 @@ static struct mii_phy_ops bcm5421_phy_op
 	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
 	.setup_forced	= bcm54xx_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= bcm54xx_read_link,
+	.poll_link	= bcm5421_poll_link,
+	.read_link	= bcm5421_read_link,
 	.enable_fiber   = bcm5421_enable_fiber,
 };
 
@@ -923,8 +1042,8 @@ static struct mii_phy_ops bcm5461_phy_op
 	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
 	.setup_forced	= bcm54xx_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= bcm54xx_read_link,
+	.poll_link	= bcm5461_poll_link,
+	.read_link	= bcm5461_read_link,
 	.enable_fiber   = bcm5461_enable_fiber,
 };
 
Index: linux-2.6.20-git16/drivers/net/sungem_phy.h
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/sungem_phy.h	2007-02-04 12:44:54.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/sungem_phy.h	2007-02-20 14:33:06.000000000 -0600
@@ -12,7 +12,7 @@ struct mii_phy_ops
 	int		(*setup_forced)(struct mii_phy *phy, int speed, int fd);
 	int		(*poll_link)(struct mii_phy *phy);
 	int		(*read_link)(struct mii_phy *phy);
-	int		(*enable_fiber)(struct mii_phy *phy);
+	int		(*enable_fiber)(struct mii_phy *phy, int autoneg);
 };
 
 /* Structure used to statically define an mii/gii based PHY */
@@ -26,6 +26,14 @@ struct mii_phy_def
 	const struct mii_phy_ops*	ops;
 };
 
+enum {
+	BCM54XX_COPPER,
+	BCM54XX_FIBER,
+	BCM54XX_GBIC,
+	BCM54XX_SGMII,
+	BCM54XX_UNKNOWN,
+};
+
 /* An instance of a PHY, partially borrowed from mii_if_info */
 struct mii_phy
 {
