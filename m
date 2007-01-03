From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] sungem: PHY updates & pause fixes (#2)
Date: Wed, 03 Jan 2007 16:30:20 +1100
Message-ID: <1167802220.6165.122.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33372 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753845AbXACFa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 00:30:27 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for a few more PHYs used by Apple and fixes
advertising and detecting of Pause (we were missing setting the bit in
MII_ADVERTISE and weren't testing in LPA for all PHYs).

Note that I currently only advertise pause, not asymetric pause. I don't
know for sure the details there, I suppose I should read a bit more
802.3 references, and I don't now what sungem is capable of, but I
noticed the PCS code (originated from you) does the same.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

(Applies on top of Eric's locking patch)

This version advertise pause support for all speeds. Note that I think
pause support was never broken for PCS, only for MII.

Index: linux-work/drivers/net/sungem_phy.c
===================================================================
--- linux-work.orig/drivers/net/sungem_phy.c	2007-01-03 12:04:12.000000000 +1100
+++ linux-work/drivers/net/sungem_phy.c	2007-01-03 16:28:55.000000000 +1100
@@ -3,10 +3,9 @@
  *
  * This file could be shared with other drivers.
  *
- * (c) 2002, Benjamin Herrenscmidt (benh@kernel.crashing.org)
+ * (c) 2002-2007, Benjamin Herrenscmidt (benh@kernel.crashing.org)
  *
  * TODO:
- *  - Implement WOL
  *  - Add support for PHYs that provide an IRQ line
  *  - Eventually moved the entire polling state machine in
  *    there (out of the eth driver), so that it can easily be
@@ -152,6 +151,44 @@ static int bcm5221_suspend(struct mii_ph
 	return 0;
 }
 
+static int bcm5241_init(struct mii_phy* phy)
+{
+	u16 data;
+
+	data = phy_read(phy, MII_BCM5221_TEST);
+	phy_write(phy, MII_BCM5221_TEST,
+		data | MII_BCM5221_TEST_ENABLE_SHADOWS);
+
+	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_STAT2);
+	phy_write(phy, MII_BCM5221_SHDOW_AUX_STAT2,
+		data | MII_BCM5221_SHDOW_AUX_STAT2_APD);
+
+	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_MODE4);
+	phy_write(phy, MII_BCM5221_SHDOW_AUX_MODE4,
+		data & ~MII_BCM5241_SHDOW_AUX_MODE4_STANDBYPWR);
+
+	data = phy_read(phy, MII_BCM5221_TEST);
+	phy_write(phy, MII_BCM5221_TEST,
+		data & ~MII_BCM5221_TEST_ENABLE_SHADOWS);
+
+	return 0;
+}
+
+static int bcm5241_suspend(struct mii_phy* phy)
+{
+	u16 data;
+
+	data = phy_read(phy, MII_BCM5221_TEST);
+	phy_write(phy, MII_BCM5221_TEST,
+		data | MII_BCM5221_TEST_ENABLE_SHADOWS);
+
+	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_MODE4);
+	phy_write(phy, MII_BCM5221_SHDOW_AUX_MODE4,
+		  data | MII_BCM5241_SHDOW_AUX_MODE4_STANDBYPWR);
+
+	return 0;
+}
+
 static int bcm5400_init(struct mii_phy* phy)
 {
 	u16 data;
@@ -373,6 +410,10 @@ static int bcm54xx_setup_aneg(struct mii
 		adv |= ADVERTISE_100HALF;
 	if (advertise & ADVERTISED_100baseT_Full)
 		adv |= ADVERTISE_100FULL;
+	if (advertise & ADVERTISED_Pause)
+		adv |= ADVERTISE_PAUSE_CAP;
+	if (advertise & ADVERTISED_Asym_Pause)
+		adv |= ADVERTISE_PAUSE_ASYM;
 	phy_write(phy, MII_ADVERTISE, adv);
 
 	/* Setup 1000BT advertise */
@@ -436,12 +477,15 @@ static int bcm54xx_read_link(struct mii_
 	    	val = phy_read(phy, MII_BCM5400_AUXSTATUS);
 		link_mode = ((val & MII_BCM5400_AUXSTATUS_LINKMODE_MASK) >>
 			     MII_BCM5400_AUXSTATUS_LINKMODE_SHIFT);
-		phy->duplex = phy_BCM5400_link_table[link_mode][0] ? DUPLEX_FULL : DUPLEX_HALF;
+		phy->duplex = phy_BCM5400_link_table[link_mode][0] ?
+			DUPLEX_FULL : DUPLEX_HALF;
 		phy->speed = phy_BCM5400_link_table[link_mode][2] ?
 				SPEED_1000 :
-				(phy_BCM5400_link_table[link_mode][1] ? SPEED_100 : SPEED_10);
+				(phy_BCM5400_link_table[link_mode][1] ?
+				 SPEED_100 : SPEED_10);
 		val = phy_read(phy, MII_LPA);
-		phy->pause = ((val & LPA_PAUSE) != 0);
+		phy->pause = (phy->duplex == DUPLEX_FULL) &&
+			((val & LPA_PAUSE) != 0);
 	}
 	/* On non-aneg, we assume what we put in BMCR is the speed,
 	 * though magic-aneg shouldn't prevent this case from occurring
@@ -450,6 +494,28 @@ static int bcm54xx_read_link(struct mii_
 	return 0;
 }
 
+static int marvell88e1111_init(struct mii_phy* phy)
+{
+	u16 rev;
+
+	/* magic init sequence for rev 0 */
+	rev = phy_read(phy, MII_PHYSID2) & 0x000f;
+	if (rev == 0) {
+		phy_write(phy, 0x1d, 0x000a);
+		phy_write(phy, 0x1e, 0x0821);
+
+		phy_write(phy, 0x1d, 0x0006);
+		phy_write(phy, 0x1e, 0x8600);
+
+		phy_write(phy, 0x1d, 0x000b);
+		phy_write(phy, 0x1e, 0x0100);
+
+		phy_write(phy, 0x1d, 0x0004);
+		phy_write(phy, 0x1e, 0x4850);
+	}
+	return 0;
+}
+
 static int marvell_setup_aneg(struct mii_phy *phy, u32 advertise)
 {
 	u16 ctl, adv;
@@ -471,6 +537,10 @@ static int marvell_setup_aneg(struct mii
 		adv |= ADVERTISE_100HALF;
 	if (advertise & ADVERTISED_100baseT_Full)
 		adv |= ADVERTISE_100FULL;
+	if (advertise & ADVERTISED_Pause)
+		adv |= ADVERTISE_PAUSE_CAP;
+	if (advertise & ADVERTISED_Asym_Pause)
+		adv |= ADVERTISE_PAUSE_ASYM;
 	phy_write(phy, MII_ADVERTISE, adv);
 
 	/* Setup 1000BT advertise & enable crossover detect
@@ -549,7 +619,7 @@ static int marvell_setup_forced(struct m
 
 static int marvell_read_link(struct mii_phy *phy)
 {
-	u16 status;
+	u16 status, pmask;
 
 	if (phy->autoneg) {
 		status = phy_read(phy, MII_M1011_PHY_SPEC_STATUS);
@@ -565,7 +635,9 @@ static int marvell_read_link(struct mii_
 			phy->duplex = DUPLEX_FULL;
 		else
 			phy->duplex = DUPLEX_HALF;
-		phy->pause = 0; /* XXX Check against spec ! */
+		pmask = MII_M1011_PHY_SPEC_STATUS_TX_PAUSE |
+			MII_M1011_PHY_SPEC_STATUS_RX_PAUSE;
+		phy->pause = (status & pmask) == pmask;
 	}
 	/* On non-aneg, we assume what we put in BMCR is the speed,
 	 * though magic-aneg shouldn't prevent this case from occurring
@@ -595,6 +667,10 @@ static int genmii_setup_aneg(struct mii_
 		adv |= ADVERTISE_100HALF;
 	if (advertise & ADVERTISED_100baseT_Full)
 		adv |= ADVERTISE_100FULL;
+	if (advertise & ADVERTISED_Pause)
+		adv |= ADVERTISE_PAUSE_CAP;
+	if (advertise & ADVERTISED_Asym_Pause)
+		adv |= ADVERTISE_PAUSE_ASYM;
 	phy_write(phy, MII_ADVERTISE, adv);
 
 	/* Start/Restart aneg */
@@ -666,7 +742,8 @@ static int genmii_read_link(struct mii_p
 			phy->speed = SPEED_100;
 		else
 			phy->speed = SPEED_10;
-		phy->pause = 0;
+		phy->pause = (phy->duplex == DUPLEX_FULL) &&
+			((lpa & LPA_PAUSE) != 0);
 	}
 	/* On non-aneg, we assume what we put in BMCR is the speed,
 	 * though magic-aneg shouldn't prevent this case from occurring
@@ -676,11 +753,19 @@ static int genmii_read_link(struct mii_p
 }
 
 
-#define MII_BASIC_FEATURES	(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full | \
-				 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full | \
-				 SUPPORTED_Autoneg | SUPPORTED_TP | SUPPORTED_MII)
-#define MII_GBIT_FEATURES	(MII_BASIC_FEATURES | \
-				 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full)
+#define MII_BASIC_FEATURES \
+	(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |	\
+	 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |	\
+	 SUPPORTED_Autoneg | SUPPORTED_TP | SUPPORTED_MII |	\
+	 SUPPORTED_Pause)
+
+/* On gigabit capable PHYs, we advertise Pause support but not asym pause
+ * support for now as I'm not sure it's supported and Darwin doesn't do
+ * it neither. --BenH.
+ */
+#define MII_GBIT_FEATURES \
+	(MII_BASIC_FEATURES |	\
+	 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full)
 
 /* Broadcom BCM 5201 */
 static struct mii_phy_ops bcm5201_phy_ops = {
@@ -720,6 +805,24 @@ static struct mii_phy_def bcm5221_phy_de
 	.ops		= &bcm5221_phy_ops
 };
 
+/* Broadcom BCM 5241 */
+static struct mii_phy_ops bcm5241_phy_ops = {
+	.suspend	= bcm5241_suspend,
+	.init		= bcm5241_init,
+	.setup_aneg	= genmii_setup_aneg,
+	.setup_forced	= genmii_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= genmii_read_link,
+};
+static struct mii_phy_def bcm5241_phy_def = {
+	.phy_id		= 0x0143bc30,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5241",
+	.features	= MII_BASIC_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5241_phy_ops
+};
+
 /* Broadcom BCM 5400 */
 static struct mii_phy_ops bcm5400_phy_ops = {
 	.init		= bcm5400_init,
@@ -854,11 +957,8 @@ static struct mii_phy_def bcm5462V_phy_d
 	.ops		= &bcm5462V_phy_ops
 };
 
-/* Marvell 88E1101 (Apple seem to deal with 2 different revs,
- * I masked out the 8 last bits to get both, but some specs
- * would be useful here) --BenH.
- */
-static struct mii_phy_ops marvell_phy_ops = {
+/* Marvell 88E1101 amd 88E1111 */
+static struct mii_phy_ops marvell88e1101_phy_ops = {
 	.suspend	= generic_suspend,
 	.setup_aneg	= marvell_setup_aneg,
 	.setup_forced	= marvell_setup_forced,
@@ -866,13 +966,41 @@ static struct mii_phy_ops marvell_phy_op
 	.read_link	= marvell_read_link
 };
 
-static struct mii_phy_def marvell_phy_def = {
-	.phy_id		= 0x01410c00,
-	.phy_id_mask	= 0xffffff00,
-	.name		= "Marvell 88E1101",
+static struct mii_phy_ops marvell88e1111_phy_ops = {
+	.init		= marvell88e1111_init,
+	.suspend	= generic_suspend,
+	.setup_aneg	= marvell_setup_aneg,
+	.setup_forced	= marvell_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= marvell_read_link
+};
+
+/* two revs in darwin for the 88e1101 ... I could use a datasheet
+ * to get the proper names...
+ */
+static struct mii_phy_def marvell88e1101v1_phy_def = {
+	.phy_id		= 0x01410c20,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Marvell 88E1101v1",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &marvell88e1101_phy_ops
+};
+static struct mii_phy_def marvell88e1101v2_phy_def = {
+	.phy_id		= 0x01410c60,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Marvell 88E1101v2",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &marvell88e1101_phy_ops
+};
+static struct mii_phy_def marvell88e1111_phy_def = {
+	.phy_id		= 0x01410cc0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Marvell 88E1111",
 	.features	= MII_GBIT_FEATURES,
 	.magic_aneg	= 1,
-	.ops		= &marvell_phy_ops
+	.ops		= &marvell88e1111_phy_ops
 };
 
 /* Generic implementation for most 10/100 PHYs */
@@ -895,6 +1023,7 @@ static struct mii_phy_def genmii_phy_def
 static struct mii_phy_def* mii_phy_table[] = {
 	&bcm5201_phy_def,
 	&bcm5221_phy_def,
+	&bcm5241_phy_def,
 	&bcm5400_phy_def,
 	&bcm5401_phy_def,
 	&bcm5411_phy_def,
@@ -902,7 +1031,9 @@ static struct mii_phy_def* mii_phy_table
 	&bcm5421k2_phy_def,
 	&bcm5461_phy_def,
 	&bcm5462V_phy_def,
-	&marvell_phy_def,
+	&marvell88e1101v1_phy_def,
+	&marvell88e1101v2_phy_def,
+	&marvell88e1111_phy_def,
 	&genmii_phy_def,
 	NULL
 };
Index: linux-work/drivers/net/sungem_phy.h
===================================================================
--- linux-work.orig/drivers/net/sungem_phy.h	2007-01-03 11:59:53.000000000 +1100
+++ linux-work/drivers/net/sungem_phy.h	2007-01-03 15:40:19.000000000 +1100
@@ -30,7 +30,7 @@ struct mii_phy_def
 struct mii_phy
 {
 	struct mii_phy_def*	def;
-	int			advertising;
+	u32			advertising;
 	int			mii_id;
 
 	/* 1: autoneg enabled, 0: disabled */
@@ -85,6 +85,9 @@ extern int mii_phy_probe(struct mii_phy 
 #define MII_BCM5221_SHDOW_AUX_MODE4_IDDQMODE	0x0001
 #define MII_BCM5221_SHDOW_AUX_MODE4_CLKLOPWR	0x0004
 
+/* MII BCM5241 Additional registers */
+#define MII_BCM5241_SHDOW_AUX_MODE4_STANDBYPWR	0x0008
+
 /* MII BCM5400 1000-BASET Control register */
 #define MII_BCM5400_GB_CONTROL			0x09
 #define MII_BCM5400_GB_CONTROL_FULLDUPLEXCAP	0x0200
@@ -115,5 +118,7 @@ extern int mii_phy_probe(struct mii_phy 
 #define MII_M1011_PHY_SPEC_STATUS_SPD_MASK	0xc000
 #define MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX	0x2000
 #define MII_M1011_PHY_SPEC_STATUS_RESOLVED	0x0800
+#define MII_M1011_PHY_SPEC_STATUS_TX_PAUSE	0x0008
+#define MII_M1011_PHY_SPEC_STATUS_RX_PAUSE	0x0004
 
 #endif /* __SUNGEM_PHY_H__ */
Index: linux-work/drivers/net/sungem.c
===================================================================
--- linux-work.orig/drivers/net/sungem.c	2007-01-03 15:41:52.000000000 +1100
+++ linux-work/drivers/net/sungem.c	2007-01-03 15:42:16.000000000 +1100
@@ -70,7 +70,8 @@
 
 #define ADVERTISE_MASK	(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full | \
 			 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full | \
-			 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full)
+			 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full | \
+			 SUPPORTED_Pause | SUPPORTED_Autoneg)
 
 #define DRV_NAME	"sungem"
 #define DRV_VERSION	"0.98"


