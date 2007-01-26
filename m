From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: spidernet: add improved phy support in sungem_phy.c
Date: Sat, 27 Jan 2007 00:38:09 +0100
Message-ID: <20070126233809.GA16660@electric-eye.fr.zoreil.com>
References: <200701261407.48237.jens@de.ibm.com> <1169842847.24996.106.camel@localhost.localdomain> <200701262331.58491.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, Linas Vepstas <linas@austin.ibm.com>,
	jgarzik@pobox.com, James K Lewis <jim@jklewis.com>
To: Jens Osterkamp <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46411 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965059AbXAZXmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 18:42:42 -0500
Content-Disposition: inline
In-Reply-To: <200701262331.58491.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jens Osterkamp <jens@de.ibm.com> :
> > Patch is whitespace damaged...
> 
> sending it again as attachment...

Inlined patches are preferred.


Index: linux-2.6.20-rc5/drivers/net/sungem_phy.c
===================================================================
--- linux-2.6.20-rc5.orig/drivers/net/sungem_phy.c
+++ linux-2.6.20-rc5/drivers/net/sungem_phy.c
@@ -311,6 +311,107 @@ static int bcm5411_init(struct mii_phy* 
[...]
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
                             ^^^           ^^^
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

You could do a quick:
	if (!phy->autoneg) 
		return 0;

but it would not be enough for ternary ops to fit on a single line :o/

+
 static int generic_suspend(struct mii_phy* phy)
 {
 	phy_write(phy, MII_BMCR, BMCR_PDOWN);
[...]
@@ -516,6 +593,166 @@ static int marvell88e1111_init(struct mi
 	return 0;
 }
 
+#define BCM5421_MODE_MASK	1 << 5

Please add parenthesis.

+
+static int bcm5421_poll_link(struct mii_phy* phy)
+{
+	u32 phy_reg;
+	int mode;
+
+	/* find out in what mode we are */
+        phy_write(phy, MII_NCONFIG, 0x1000);
^^^^^^^^^^
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	mode = (phy_reg & BCM5421_MODE_MASK ) >> 5;
                                          ^^^

"&" is fine despite the lack of parenthesis above but it is error-prone.

+
+	if ( mode == GMII_COPPER) {
           ^^^
+		return genmii_poll_link(phy);
+	}

No curly-braces for single line statements please.

+
+	/* try to find out wether we have a link */
+        phy_write(phy, MII_NCONFIG, 0x2000);
^^^^^^^^^^
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	if ( (phy_reg & 0x0020) >> 5 ) {
           ^^^                     ^^^
+		return 0;
+	} else {
+		return 1;
+	}

Ternary operator ?

+
+}
+
+static int bcm5421_read_link(struct mii_phy* phy)
+{
+	u32 phy_reg;
+	int mode;
+
+	/* find out in what mode we are */
+        phy_write(phy, MII_NCONFIG, 0x1000);
^^^^^^^^^^
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	mode = (phy_reg & BCM5421_MODE_MASK ) >> 5;
                                          ^^^
+
+	if ( mode == GMII_COPPER) {
           ^^^
+		return bcm54xx_read_link(phy);
+	}
+
+	phy->speed = SPEED_1000;
+
+	/* find out wether we are running half- or full duplex */
+        phy_write(phy, MII_NCONFIG, 0x2000);
^^^^^^^^^^
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	if ( (phy_reg & 0x0020) >> 7 ) {
           ^^^                     ^^^
+		phy->duplex |=  DUPLEX_HALF;
+	} else {
+		phy->duplex |=  DUPLEX_FULL;
+	}

Ternary operator ?

+
+	return 0;
+}
+
[...]
+#define BCM5461_FIBER_LINK	1 << 2
+#define BCM5461_MODE_MASK	3 << 1

Please add parenthesis.

+
+static int bcm5461_poll_link(struct mii_phy* phy)
+{
+	u32 phy_reg;
+	int mode;
+
+	/* find out in what mode we are */
+        phy_write(phy, MII_NCONFIG, 0x7c00);
^^^^^^^^^^
+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	mode = (phy_reg & BCM5461_MODE_MASK ) >> 1;
                                          ^^^
+
+	if ( mode == GMII_COPPER) {
           ^^^
+		return genmii_poll_link(phy);
+	}
+
+	/* find out wether we have a link */
+        phy_write(phy, MII_NCONFIG, 0x7000);
^^^^^^^^^^
+	phy_reg = phy_read(phy, MII_NCONFIG);
+	if (phy_reg & BCM5461_FIBER_LINK) {
+		return 1;
+	} else {
+		return 0;
+	}

Join the dark side and use a ternary operator.

+}
+
+#define BCM5461_FIBER_DUPLEX	1 << 3

Please add parenthesis.

+
+static int bcm5461_read_link(struct mii_phy* phy)
+{
+	u32 phy_reg;
+	int mode;
+
+	/* find out in what mode we are */
+        phy_write(phy, MII_NCONFIG, 0x7c00);

^^^^^^^^^^

+	phy_reg = phy_read(phy, MII_NCONFIG);
+
+	mode = (phy_reg & BCM5461_MODE_MASK ) >> 1;
                                          ^^^
+
+	if ( mode == GMII_COPPER) {
           ^^^
+		return bcm54xx_read_link(phy);
+	}

Useless curly-braces.

+
+	phy->speed = SPEED_1000;
+
+	/* find out wether we are running half- or full duplex */
+        phy_write(phy, MII_NCONFIG, 0x7000);
^^^^^^^^^^
+	phy_reg = phy_read(phy, MII_NCONFIG);
+	if (phy_reg & BCM5461_FIBER_DUPLEX) {
+		phy->duplex |=  DUPLEX_FULL;
+	} else {
+		phy->duplex |=  DUPLEX_HALF;
+	}

Ternary operator.

+
+	return 0;
+}
+
+static int bcm5461_enable_fiber(struct mii_phy* phy, int autoneg)
+{
+	/*
+	phy_write(phy, MII_NCONFIG, 0xfc0c);
+	phy_write(phy, MII_BMCR, 0x4140);
+	*/

Remove ?

-- 
Ueimor
