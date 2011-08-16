From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 15 Aug 2011 23:11:16 -0700 (PDT)
Message-ID: <20110815.231116.1728582609642497613.davem@davemloft.net>
References: <20110815152048.3b8f8484faf1891ef2fce266@canb.auug.org.au>
	<20110814.225610.2264854100578866902.davem@davemloft.net>
	<20110816152815.911f15937efa2ebf58a2795d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110816152815.911f15937efa2ebf58a2795d@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 16 Aug 2011 15:28:15 +1000

> Hi Dave,
> 
> On Sun, 14 Aug 2011 22:56:10 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>>
>> This should fix the include problem, but I suspect this thing won't
>> link.
> 
> Yep, indeed, today I get:
> 
> make[5]: *** No rule to make target `drivers/net/ethernet/toshiba/ethernet/sun/sungem_phy.o', needed by `drivers/net/ethernet/toshiba/built-in.o'.

Please test this patch:

--------------------
net: Fix sungem_phy sharing.

Since sungem_phy is used by multiple, unrelated, drivers make it
build as a real module under drivers/net.

depmod will pick up the symbol dependency and make sure sungem_phy.ko
gets loaded any time sungem.ko or spider_net.ko is loaded.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/Kconfig                       |    3 +
 drivers/net/Makefile                      |    2 +
 drivers/net/ethernet/sun/Makefile         |    1 -
 drivers/net/ethernet/sun/sungem.c         |    2 +-
 drivers/net/ethernet/sun/sungem_phy.c     | 1200 -----------------------------
 drivers/net/ethernet/toshiba/Makefile     |    2 +-
 drivers/net/ethernet/toshiba/spider_net.c |    4 +-
 drivers/net/sungem_phy.c                  | 1199 ++++++++++++++++++++++++++++
 include/linux/sungem_phy.h                |    2 +-
 9 files changed, 1209 insertions(+), 1206 deletions(-)
 delete mode 100644 drivers/net/ethernet/sun/sungem_phy.c
 create mode 100644 drivers/net/sungem_phy.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 31d8792..ef6b6be 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -186,6 +186,9 @@ config MII
 
 source "drivers/net/phy/Kconfig"
 
+config SUNGEM_PHY
+	tristate
+
 #
 #	Ethernet
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 9cb47bb..c33009b 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -75,3 +75,5 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 
 obj-$(CONFIG_WIMAX) += wimax/
 obj-$(CONFIG_CAIF) += caif/
+
+obj-$(CONFIG_SUNGEM_PHY) += sungem_phy.o
diff --git a/drivers/net/ethernet/sun/Makefile b/drivers/net/ethernet/sun/Makefile
index 6e25dad..1e620ff 100644
--- a/drivers/net/ethernet/sun/Makefile
+++ b/drivers/net/ethernet/sun/Makefile
@@ -6,7 +6,6 @@ obj-$(CONFIG_HAPPYMEAL) += sunhme.o
 obj-$(CONFIG_SUNQE) += sunqe.o
 obj-$(CONFIG_SUNBMAC) += sunbmac.o
 obj-$(CONFIG_SUNGEM) += sungem.o
-obj-$(CONFIG_SUNGEM_PHY) += sungem_phy.o
 obj-$(CONFIG_CASSINI) += cassini.o
 obj-$(CONFIG_SUNVNET) += sunvnet.o
 obj-$(CONFIG_NIU) += niu.o
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 0f13c5d..fb9885d 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -1721,7 +1721,7 @@ static void gem_init_phy(struct gem *gp)
 	if (gp->phy_type == phy_mii_mdio0 ||
 	    gp->phy_type == phy_mii_mdio1) {
 		/* Reset and detect MII PHY */
-		mii_phy_probe(&gp->phy_mii, gp->mii_phy_addr);
+		sungem_phy_probe(&gp->phy_mii, gp->mii_phy_addr);
 
 		/* Init PHY */
 		if (gp->phy_mii.def && gp->phy_mii.def->ops->init)
diff --git a/drivers/net/ethernet/sun/sungem_phy.c b/drivers/net/ethernet/sun/sungem_phy.c
deleted file mode 100644
index db99c22..0000000
--- a/drivers/net/ethernet/sun/sungem_phy.c
+++ /dev/null
@@ -1,1200 +0,0 @@
-/*
- * PHY drivers for the sungem ethernet driver.
- *
- * This file could be shared with other drivers.
- *
- * (c) 2002-2007, Benjamin Herrenscmidt (benh@kernel.crashing.org)
- *
- * TODO:
- *  - Add support for PHYs that provide an IRQ line
- *  - Eventually moved the entire polling state machine in
- *    there (out of the eth driver), so that it can easily be
- *    skipped on PHYs that implement it in hardware.
- *  - On LXT971 & BCM5201, Apple uses some chip specific regs
- *    to read the link status. Figure out why and if it makes
- *    sense to do the same (magic aneg ?)
- *  - Apple has some additional power management code for some
- *    Broadcom PHYs that they "hide" from the OpenSource version
- *    of darwin, still need to reverse engineer that
- */
-
-
-#include <linux/module.h>
-
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/mii.h>
-#include <linux/ethtool.h>
-#include <linux/delay.h>
-
-#ifdef CONFIG_PPC_PMAC
-#include <asm/prom.h>
-#endif
-
-#include <linux/sungem_phy.h>
-
-/* Link modes of the BCM5400 PHY */
-static const int phy_BCM5400_link_table[8][3] = {
-	{ 0, 0, 0 },	/* No link */
-	{ 0, 0, 0 },	/* 10BT Half Duplex */
-	{ 1, 0, 0 },	/* 10BT Full Duplex */
-	{ 0, 1, 0 },	/* 100BT Half Duplex */
-	{ 0, 1, 0 },	/* 100BT Half Duplex */
-	{ 1, 1, 0 },	/* 100BT Full Duplex*/
-	{ 1, 0, 1 },	/* 1000BT */
-	{ 1, 0, 1 },	/* 1000BT */
-};
-
-static inline int __phy_read(struct mii_phy* phy, int id, int reg)
-{
-	return phy->mdio_read(phy->dev, id, reg);
-}
-
-static inline void __phy_write(struct mii_phy* phy, int id, int reg, int val)
-{
-	phy->mdio_write(phy->dev, id, reg, val);
-}
-
-static inline int phy_read(struct mii_phy* phy, int reg)
-{
-	return phy->mdio_read(phy->dev, phy->mii_id, reg);
-}
-
-static inline void phy_write(struct mii_phy* phy, int reg, int val)
-{
-	phy->mdio_write(phy->dev, phy->mii_id, reg, val);
-}
-
-static int reset_one_mii_phy(struct mii_phy* phy, int phy_id)
-{
-	u16 val;
-	int limit = 10000;
-
-	val = __phy_read(phy, phy_id, MII_BMCR);
-	val &= ~(BMCR_ISOLATE | BMCR_PDOWN);
-	val |= BMCR_RESET;
-	__phy_write(phy, phy_id, MII_BMCR, val);
-
-	udelay(100);
-
-	while (--limit) {
-		val = __phy_read(phy, phy_id, MII_BMCR);
-		if ((val & BMCR_RESET) == 0)
-			break;
-		udelay(10);
-	}
-	if ((val & BMCR_ISOLATE) && limit > 0)
-		__phy_write(phy, phy_id, MII_BMCR, val & ~BMCR_ISOLATE);
-
-	return limit <= 0;
-}
-
-static int bcm5201_init(struct mii_phy* phy)
-{
-	u16 data;
-
-	data = phy_read(phy, MII_BCM5201_MULTIPHY);
-	data &= ~MII_BCM5201_MULTIPHY_SUPERISOLATE;
-	phy_write(phy, MII_BCM5201_MULTIPHY, data);
-
-	phy_write(phy, MII_BCM5201_INTERRUPT, 0);
-
-	return 0;
-}
-
-static int bcm5201_suspend(struct mii_phy* phy)
-{
-	phy_write(phy, MII_BCM5201_INTERRUPT, 0);
-	phy_write(phy, MII_BCM5201_MULTIPHY, MII_BCM5201_MULTIPHY_SUPERISOLATE);
-
-	return 0;
-}
-
-static int bcm5221_init(struct mii_phy* phy)
-{
-	u16 data;
-
-	data = phy_read(phy, MII_BCM5221_TEST);
-	phy_write(phy, MII_BCM5221_TEST,
-		data | MII_BCM5221_TEST_ENABLE_SHADOWS);
-
-	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_STAT2);
-	phy_write(phy, MII_BCM5221_SHDOW_AUX_STAT2,
-		data | MII_BCM5221_SHDOW_AUX_STAT2_APD);
-
-	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_MODE4);
-	phy_write(phy, MII_BCM5221_SHDOW_AUX_MODE4,
-		data | MII_BCM5221_SHDOW_AUX_MODE4_CLKLOPWR);
-
-	data = phy_read(phy, MII_BCM5221_TEST);
-	phy_write(phy, MII_BCM5221_TEST,
-		data & ~MII_BCM5221_TEST_ENABLE_SHADOWS);
-
-	return 0;
-}
-
-static int bcm5221_suspend(struct mii_phy* phy)
-{
-	u16 data;
-
-	data = phy_read(phy, MII_BCM5221_TEST);
-	phy_write(phy, MII_BCM5221_TEST,
-		data | MII_BCM5221_TEST_ENABLE_SHADOWS);
-
-	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_MODE4);
-	phy_write(phy, MII_BCM5221_SHDOW_AUX_MODE4,
-		  data | MII_BCM5221_SHDOW_AUX_MODE4_IDDQMODE);
-
-	return 0;
-}
-
-static int bcm5241_init(struct mii_phy* phy)
-{
-	u16 data;
-
-	data = phy_read(phy, MII_BCM5221_TEST);
-	phy_write(phy, MII_BCM5221_TEST,
-		data | MII_BCM5221_TEST_ENABLE_SHADOWS);
-
-	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_STAT2);
-	phy_write(phy, MII_BCM5221_SHDOW_AUX_STAT2,
-		data | MII_BCM5221_SHDOW_AUX_STAT2_APD);
-
-	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_MODE4);
-	phy_write(phy, MII_BCM5221_SHDOW_AUX_MODE4,
-		data & ~MII_BCM5241_SHDOW_AUX_MODE4_STANDBYPWR);
-
-	data = phy_read(phy, MII_BCM5221_TEST);
-	phy_write(phy, MII_BCM5221_TEST,
-		data & ~MII_BCM5221_TEST_ENABLE_SHADOWS);
-
-	return 0;
-}
-
-static int bcm5241_suspend(struct mii_phy* phy)
-{
-	u16 data;
-
-	data = phy_read(phy, MII_BCM5221_TEST);
-	phy_write(phy, MII_BCM5221_TEST,
-		data | MII_BCM5221_TEST_ENABLE_SHADOWS);
-
-	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_MODE4);
-	phy_write(phy, MII_BCM5221_SHDOW_AUX_MODE4,
-		  data | MII_BCM5241_SHDOW_AUX_MODE4_STANDBYPWR);
-
-	return 0;
-}
-
-static int bcm5400_init(struct mii_phy* phy)
-{
-	u16 data;
-
-	/* Configure for gigabit full duplex */
-	data = phy_read(phy, MII_BCM5400_AUXCONTROL);
-	data |= MII_BCM5400_AUXCONTROL_PWR10BASET;
-	phy_write(phy, MII_BCM5400_AUXCONTROL, data);
-
-	data = phy_read(phy, MII_BCM5400_GB_CONTROL);
-	data |= MII_BCM5400_GB_CONTROL_FULLDUPLEXCAP;
-	phy_write(phy, MII_BCM5400_GB_CONTROL, data);
-
-	udelay(100);
-
-	/* Reset and configure cascaded 10/100 PHY */
-	(void)reset_one_mii_phy(phy, 0x1f);
-
-	data = __phy_read(phy, 0x1f, MII_BCM5201_MULTIPHY);
-	data |= MII_BCM5201_MULTIPHY_SERIALMODE;
-	__phy_write(phy, 0x1f, MII_BCM5201_MULTIPHY, data);
-
-	data = phy_read(phy, MII_BCM5400_AUXCONTROL);
-	data &= ~MII_BCM5400_AUXCONTROL_PWR10BASET;
-	phy_write(phy, MII_BCM5400_AUXCONTROL, data);
-
-	return 0;
-}
-
-static int bcm5400_suspend(struct mii_phy* phy)
-{
-#if 0 /* Commented out in Darwin... someone has those dawn docs ? */
-	phy_write(phy, MII_BMCR, BMCR_PDOWN);
-#endif
-	return 0;
-}
-
-static int bcm5401_init(struct mii_phy* phy)
-{
-	u16 data;
-	int rev;
-
-	rev = phy_read(phy, MII_PHYSID2) & 0x000f;
-	if (rev == 0 || rev == 3) {
-		/* Some revisions of 5401 appear to need this
-		 * initialisation sequence to disable, according
-		 * to OF, "tap power management"
-		 *
-		 * WARNING ! OF and Darwin don't agree on the
-		 * register addresses. OF seem to interpret the
-		 * register numbers below as decimal
-		 *
-		 * Note: This should (and does) match tg3_init_5401phy_dsp
-		 *       in the tg3.c driver. -DaveM
-		 */
-		phy_write(phy, 0x18, 0x0c20);
-		phy_write(phy, 0x17, 0x0012);
-		phy_write(phy, 0x15, 0x1804);
-		phy_write(phy, 0x17, 0x0013);
-		phy_write(phy, 0x15, 0x1204);
-		phy_write(phy, 0x17, 0x8006);
-		phy_write(phy, 0x15, 0x0132);
-		phy_write(phy, 0x17, 0x8006);
-		phy_write(phy, 0x15, 0x0232);
-		phy_write(phy, 0x17, 0x201f);
-		phy_write(phy, 0x15, 0x0a20);
-	}
-
-	/* Configure for gigabit full duplex */
-	data = phy_read(phy, MII_BCM5400_GB_CONTROL);
-	data |= MII_BCM5400_GB_CONTROL_FULLDUPLEXCAP;
-	phy_write(phy, MII_BCM5400_GB_CONTROL, data);
-
-	udelay(10);
-
-	/* Reset and configure cascaded 10/100 PHY */
-	(void)reset_one_mii_phy(phy, 0x1f);
-
-	data = __phy_read(phy, 0x1f, MII_BCM5201_MULTIPHY);
-	data |= MII_BCM5201_MULTIPHY_SERIALMODE;
-	__phy_write(phy, 0x1f, MII_BCM5201_MULTIPHY, data);
-
-	return 0;
-}
-
-static int bcm5401_suspend(struct mii_phy* phy)
-{
-#if 0 /* Commented out in Darwin... someone has those dawn docs ? */
-	phy_write(phy, MII_BMCR, BMCR_PDOWN);
-#endif
-	return 0;
-}
-
-static int bcm5411_init(struct mii_phy* phy)
-{
-	u16 data;
-
-	/* Here's some more Apple black magic to setup
-	 * some voltage stuffs.
-	 */
-	phy_write(phy, 0x1c, 0x8c23);
-	phy_write(phy, 0x1c, 0x8ca3);
-	phy_write(phy, 0x1c, 0x8c23);
-
-	/* Here, Apple seems to want to reset it, do
-	 * it as well
-	 */
-	phy_write(phy, MII_BMCR, BMCR_RESET);
-	phy_write(phy, MII_BMCR, 0x1340);
-
-	data = phy_read(phy, MII_BCM5400_GB_CONTROL);
-	data |= MII_BCM5400_GB_CONTROL_FULLDUPLEXCAP;
-	phy_write(phy, MII_BCM5400_GB_CONTROL, data);
-
-	udelay(10);
-
-	/* Reset and configure cascaded 10/100 PHY */
-	(void)reset_one_mii_phy(phy, 0x1f);
-
-	return 0;
-}
-
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
-		phy->pause = 0;
-	}
-	/* On non-aneg, we assume what we put in BMCR is the speed,
-	 * though magic-aneg shouldn't prevent this case from occurring
-	 */
-
-	 return 0;
-}
-
-static int generic_suspend(struct mii_phy* phy)
-{
-	phy_write(phy, MII_BMCR, BMCR_PDOWN);
-
-	return 0;
-}
-
-static int bcm5421_init(struct mii_phy* phy)
-{
-	u16 data;
-	unsigned int id;
-
-	id = (phy_read(phy, MII_PHYSID1) << 16 | phy_read(phy, MII_PHYSID2));
-
-	/* Revision 0 of 5421 needs some fixups */
-	if (id == 0x002060e0) {
-		/* This is borrowed from MacOS
-		 */
-		phy_write(phy, 0x18, 0x1007);
-		data = phy_read(phy, 0x18);
-		phy_write(phy, 0x18, data | 0x0400);
-		phy_write(phy, 0x18, 0x0007);
-		data = phy_read(phy, 0x18);
-		phy_write(phy, 0x18, data | 0x0800);
-		phy_write(phy, 0x17, 0x000a);
-		data = phy_read(phy, 0x15);
-		phy_write(phy, 0x15, data | 0x0200);
-	}
-
-	/* Pick up some init code from OF for K2 version */
-	if ((id & 0xfffffff0) == 0x002062e0) {
-		phy_write(phy, 4, 0x01e1);
-		phy_write(phy, 9, 0x0300);
-	}
-
-	/* Check if we can enable automatic low power */
-#ifdef CONFIG_PPC_PMAC
-	if (phy->platform_data) {
-		struct device_node *np = of_get_parent(phy->platform_data);
-		int can_low_power = 1;
-		if (np == NULL || of_get_property(np, "no-autolowpower", NULL))
-			can_low_power = 0;
-		if (can_low_power) {
-			/* Enable automatic low-power */
-			phy_write(phy, 0x1c, 0x9002);
-			phy_write(phy, 0x1c, 0xa821);
-			phy_write(phy, 0x1c, 0x941d);
-		}
-	}
-#endif /* CONFIG_PPC_PMAC */
-
-	return 0;
-}
-
-static int bcm54xx_setup_aneg(struct mii_phy *phy, u32 advertise)
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
-	/* Setup 1000BT advertise */
-	adv = phy_read(phy, MII_1000BASETCONTROL);
-	adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP|MII_1000BASETCONTROL_HALFDUPLEXCAP);
-	if (advertise & SUPPORTED_1000baseT_Half)
-		adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
-	if (advertise & SUPPORTED_1000baseT_Full)
-		adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
-	phy_write(phy, MII_1000BASETCONTROL, adv);
-
-	/* Start/Restart aneg */
-	ctl = phy_read(phy, MII_BMCR);
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
-	phy_write(phy, MII_BMCR, ctl);
-
-	return 0;
-}
-
-static int bcm54xx_setup_forced(struct mii_phy *phy, int speed, int fd)
-{
-	u16 ctl;
-
-	phy->autoneg = 0;
-	phy->speed = speed;
-	phy->duplex = fd;
-	phy->pause = 0;
-
-	ctl = phy_read(phy, MII_BMCR);
-	ctl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_SPD2|BMCR_ANENABLE);
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
-		ctl |= BMCR_SPD2;
-	}
-	if (fd == DUPLEX_FULL)
-		ctl |= BMCR_FULLDPLX;
-
-	// XXX Should we set the sungem to GII now on 1000BT ?
-
-	phy_write(phy, MII_BMCR, ctl);
-
-	return 0;
-}
-
-static int bcm54xx_read_link(struct mii_phy *phy)
-{
-	int link_mode;
-	u16 val;
-
-	if (phy->autoneg) {
-	    	val = phy_read(phy, MII_BCM5400_AUXSTATUS);
-		link_mode = ((val & MII_BCM5400_AUXSTATUS_LINKMODE_MASK) >>
-			     MII_BCM5400_AUXSTATUS_LINKMODE_SHIFT);
-		phy->duplex = phy_BCM5400_link_table[link_mode][0] ?
-			DUPLEX_FULL : DUPLEX_HALF;
-		phy->speed = phy_BCM5400_link_table[link_mode][2] ?
-				SPEED_1000 :
-				(phy_BCM5400_link_table[link_mode][1] ?
-				 SPEED_100 : SPEED_10);
-		val = phy_read(phy, MII_LPA);
-		phy->pause = (phy->duplex == DUPLEX_FULL) &&
-			((val & LPA_PAUSE) != 0);
-	}
-	/* On non-aneg, we assume what we put in BMCR is the speed,
-	 * though magic-aneg shouldn't prevent this case from occurring
-	 */
-
-	return 0;
-}
-
-static int marvell88e1111_init(struct mii_phy* phy)
-{
-	u16 rev;
-
-	/* magic init sequence for rev 0 */
-	rev = phy_read(phy, MII_PHYSID2) & 0x000f;
-	if (rev == 0) {
-		phy_write(phy, 0x1d, 0x000a);
-		phy_write(phy, 0x1e, 0x0821);
-
-		phy_write(phy, 0x1d, 0x0006);
-		phy_write(phy, 0x1e, 0x8600);
-
-		phy_write(phy, 0x1d, 0x000b);
-		phy_write(phy, 0x1e, 0x0100);
-
-		phy_write(phy, 0x1d, 0x0004);
-		phy_write(phy, 0x1e, 0x4850);
-	}
-	return 0;
-}
-
-#define BCM5421_MODE_MASK	(1 << 5)
-
-static int bcm5421_poll_link(struct mii_phy* phy)
-{
-	u32 phy_reg;
-	int mode;
-
-	/* find out in what mode we are */
-	phy_write(phy, MII_NCONFIG, 0x1000);
-	phy_reg = phy_read(phy, MII_NCONFIG);
-
-	mode = (phy_reg & BCM5421_MODE_MASK) >> 5;
-
-	if ( mode == BCM54XX_COPPER)
-		return genmii_poll_link(phy);
-
-	/* try to find out wether we have a link */
-	phy_write(phy, MII_NCONFIG, 0x2000);
-	phy_reg = phy_read(phy, MII_NCONFIG);
-
-	if (phy_reg & 0x0020)
-		return 0;
-	else
-		return 1;
-}
-
-static int bcm5421_read_link(struct mii_phy* phy)
-{
-	u32 phy_reg;
-	int mode;
-
-	/* find out in what mode we are */
-	phy_write(phy, MII_NCONFIG, 0x1000);
-	phy_reg = phy_read(phy, MII_NCONFIG);
-
-	mode = (phy_reg & BCM5421_MODE_MASK ) >> 5;
-
-	if ( mode == BCM54XX_COPPER)
-		return bcm54xx_read_link(phy);
-
-	phy->speed = SPEED_1000;
-
-	/* find out wether we are running half- or full duplex */
-	phy_write(phy, MII_NCONFIG, 0x2000);
-	phy_reg = phy_read(phy, MII_NCONFIG);
-
-	if ( (phy_reg & 0x0080) >> 7)
-		phy->duplex |=  DUPLEX_HALF;
-	else
-		phy->duplex |=  DUPLEX_FULL;
-
-	return 0;
-}
-
-static int bcm5421_enable_fiber(struct mii_phy* phy, int autoneg)
-{
-	/* enable fiber mode */
-	phy_write(phy, MII_NCONFIG, 0x9020);
-	/* LEDs active in both modes, autosense prio = fiber */
-	phy_write(phy, MII_NCONFIG, 0x945f);
-
-	if (!autoneg) {
-		/* switch off fibre autoneg */
-		phy_write(phy, MII_NCONFIG, 0xfc01);
-		phy_write(phy, 0x0b, 0x0004);
-	}
-
-	phy->autoneg = autoneg;
-
-	return 0;
-}
-
-#define BCM5461_FIBER_LINK	(1 << 2)
-#define BCM5461_MODE_MASK	(3 << 1)
-
-static int bcm5461_poll_link(struct mii_phy* phy)
-{
-	u32 phy_reg;
-	int mode;
-
-	/* find out in what mode we are */
-	phy_write(phy, MII_NCONFIG, 0x7c00);
-	phy_reg = phy_read(phy, MII_NCONFIG);
-
-	mode = (phy_reg & BCM5461_MODE_MASK ) >> 1;
-
-	if ( mode == BCM54XX_COPPER)
-		return genmii_poll_link(phy);
-
-	/* find out wether we have a link */
-	phy_write(phy, MII_NCONFIG, 0x7000);
-	phy_reg = phy_read(phy, MII_NCONFIG);
-
-	if (phy_reg & BCM5461_FIBER_LINK)
-		return 1;
-	else
-		return 0;
-}
-
-#define BCM5461_FIBER_DUPLEX	(1 << 3)
-
-static int bcm5461_read_link(struct mii_phy* phy)
-{
-	u32 phy_reg;
-	int mode;
-
-	/* find out in what mode we are */
-	phy_write(phy, MII_NCONFIG, 0x7c00);
-	phy_reg = phy_read(phy, MII_NCONFIG);
-
-	mode = (phy_reg & BCM5461_MODE_MASK ) >> 1;
-
-	if ( mode == BCM54XX_COPPER) {
-		return bcm54xx_read_link(phy);
-	}
-
-	phy->speed = SPEED_1000;
-
-	/* find out wether we are running half- or full duplex */
-	phy_write(phy, MII_NCONFIG, 0x7000);
-	phy_reg = phy_read(phy, MII_NCONFIG);
-
-	if (phy_reg & BCM5461_FIBER_DUPLEX)
-		phy->duplex |=  DUPLEX_FULL;
-	else
-		phy->duplex |=  DUPLEX_HALF;
-
-	return 0;
-}
-
-static int bcm5461_enable_fiber(struct mii_phy* phy, int autoneg)
-{
-	/* select fiber mode, enable 1000 base-X registers */
-	phy_write(phy, MII_NCONFIG, 0xfc0b);
-
-	if (autoneg) {
-		/* enable fiber with no autonegotiation */
-		phy_write(phy, MII_ADVERTISE, 0x01e0);
-		phy_write(phy, MII_BMCR, 0x1140);
-	} else {
-		/* enable fiber with autonegotiation */
-		phy_write(phy, MII_BMCR, 0x0140);
-	}
-
-	phy->autoneg = autoneg;
-
-	return 0;
-}
-
-static int marvell_setup_aneg(struct mii_phy *phy, u32 advertise)
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
-	/* Setup 1000BT advertise & enable crossover detect
-	 * XXX How do we advertise 1000BT ? Darwin source is
-	 * confusing here, they read from specific control and
-	 * write to control... Someone has specs for those
-	 * beasts ?
-	 */
-	adv = phy_read(phy, MII_M1011_PHY_SPEC_CONTROL);
-	adv |= MII_M1011_PHY_SPEC_CONTROL_AUTO_MDIX;
-	adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
-			MII_1000BASETCONTROL_HALFDUPLEXCAP);
-	if (advertise & SUPPORTED_1000baseT_Half)
-		adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
-	if (advertise & SUPPORTED_1000baseT_Full)
-		adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
-	phy_write(phy, MII_1000BASETCONTROL, adv);
-
-	/* Start/Restart aneg */
-	ctl = phy_read(phy, MII_BMCR);
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
-	phy_write(phy, MII_BMCR, ctl);
-
-	return 0;
-}
-
-static int marvell_setup_forced(struct mii_phy *phy, int speed, int fd)
-{
-	u16 ctl, ctl2;
-
-	phy->autoneg = 0;
-	phy->speed = speed;
-	phy->duplex = fd;
-	phy->pause = 0;
-
-	ctl = phy_read(phy, MII_BMCR);
-	ctl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_SPD2|BMCR_ANENABLE);
-	ctl |= BMCR_RESET;
-
-	/* Select speed & duplex */
-	switch(speed) {
-	case SPEED_10:
-		break;
-	case SPEED_100:
-		ctl |= BMCR_SPEED100;
-		break;
-	/* I'm not sure about the one below, again, Darwin source is
-	 * quite confusing and I lack chip specs
-	 */
-	case SPEED_1000:
-		ctl |= BMCR_SPD2;
-	}
-	if (fd == DUPLEX_FULL)
-		ctl |= BMCR_FULLDPLX;
-
-	/* Disable crossover. Again, the way Apple does it is strange,
-	 * though I don't assume they are wrong ;)
-	 */
-	ctl2 = phy_read(phy, MII_M1011_PHY_SPEC_CONTROL);
-	ctl2 &= ~(MII_M1011_PHY_SPEC_CONTROL_MANUAL_MDIX |
-		MII_M1011_PHY_SPEC_CONTROL_AUTO_MDIX |
-		MII_1000BASETCONTROL_FULLDUPLEXCAP |
-		MII_1000BASETCONTROL_HALFDUPLEXCAP);
-	if (speed == SPEED_1000)
-		ctl2 |= (fd == DUPLEX_FULL) ?
-			MII_1000BASETCONTROL_FULLDUPLEXCAP :
-			MII_1000BASETCONTROL_HALFDUPLEXCAP;
-	phy_write(phy, MII_1000BASETCONTROL, ctl2);
-
-	// XXX Should we set the sungem to GII now on 1000BT ?
-
-	phy_write(phy, MII_BMCR, ctl);
-
-	return 0;
-}
-
-static int marvell_read_link(struct mii_phy *phy)
-{
-	u16 status, pmask;
-
-	if (phy->autoneg) {
-		status = phy_read(phy, MII_M1011_PHY_SPEC_STATUS);
-		if ((status & MII_M1011_PHY_SPEC_STATUS_RESOLVED) == 0)
-			return -EAGAIN;
-		if (status & MII_M1011_PHY_SPEC_STATUS_1000)
-			phy->speed = SPEED_1000;
-		else if (status & MII_M1011_PHY_SPEC_STATUS_100)
-			phy->speed = SPEED_100;
-		else
-			phy->speed = SPEED_10;
-		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
-			phy->duplex = DUPLEX_FULL;
-		else
-			phy->duplex = DUPLEX_HALF;
-		pmask = MII_M1011_PHY_SPEC_STATUS_TX_PAUSE |
-			MII_M1011_PHY_SPEC_STATUS_RX_PAUSE;
-		phy->pause = (status & pmask) == pmask;
-	}
-	/* On non-aneg, we assume what we put in BMCR is the speed,
-	 * though magic-aneg shouldn't prevent this case from occurring
-	 */
-
-	return 0;
-}
-
-#define MII_BASIC_FEATURES \
-	(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |	\
-	 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |	\
-	 SUPPORTED_Autoneg | SUPPORTED_TP | SUPPORTED_MII |	\
-	 SUPPORTED_Pause)
-
-/* On gigabit capable PHYs, we advertise Pause support but not asym pause
- * support for now as I'm not sure it's supported and Darwin doesn't do
- * it neither. --BenH.
- */
-#define MII_GBIT_FEATURES \
-	(MII_BASIC_FEATURES |	\
-	 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full)
-
-/* Broadcom BCM 5201 */
-static struct mii_phy_ops bcm5201_phy_ops = {
-	.init		= bcm5201_init,
-	.suspend	= bcm5201_suspend,
-	.setup_aneg	= genmii_setup_aneg,
-	.setup_forced	= genmii_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= genmii_read_link,
-};
-
-static struct mii_phy_def bcm5201_phy_def = {
-	.phy_id		= 0x00406210,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5201",
-	.features	= MII_BASIC_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5201_phy_ops
-};
-
-/* Broadcom BCM 5221 */
-static struct mii_phy_ops bcm5221_phy_ops = {
-	.suspend	= bcm5221_suspend,
-	.init		= bcm5221_init,
-	.setup_aneg	= genmii_setup_aneg,
-	.setup_forced	= genmii_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= genmii_read_link,
-};
-
-static struct mii_phy_def bcm5221_phy_def = {
-	.phy_id		= 0x004061e0,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5221",
-	.features	= MII_BASIC_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5221_phy_ops
-};
-
-/* Broadcom BCM 5241 */
-static struct mii_phy_ops bcm5241_phy_ops = {
-	.suspend	= bcm5241_suspend,
-	.init		= bcm5241_init,
-	.setup_aneg	= genmii_setup_aneg,
-	.setup_forced	= genmii_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= genmii_read_link,
-};
-static struct mii_phy_def bcm5241_phy_def = {
-	.phy_id		= 0x0143bc30,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5241",
-	.features	= MII_BASIC_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5241_phy_ops
-};
-
-/* Broadcom BCM 5400 */
-static struct mii_phy_ops bcm5400_phy_ops = {
-	.init		= bcm5400_init,
-	.suspend	= bcm5400_suspend,
-	.setup_aneg	= bcm54xx_setup_aneg,
-	.setup_forced	= bcm54xx_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= bcm54xx_read_link,
-};
-
-static struct mii_phy_def bcm5400_phy_def = {
-	.phy_id		= 0x00206040,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5400",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5400_phy_ops
-};
-
-/* Broadcom BCM 5401 */
-static struct mii_phy_ops bcm5401_phy_ops = {
-	.init		= bcm5401_init,
-	.suspend	= bcm5401_suspend,
-	.setup_aneg	= bcm54xx_setup_aneg,
-	.setup_forced	= bcm54xx_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= bcm54xx_read_link,
-};
-
-static struct mii_phy_def bcm5401_phy_def = {
-	.phy_id		= 0x00206050,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5401",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5401_phy_ops
-};
-
-/* Broadcom BCM 5411 */
-static struct mii_phy_ops bcm5411_phy_ops = {
-	.init		= bcm5411_init,
-	.suspend	= generic_suspend,
-	.setup_aneg	= bcm54xx_setup_aneg,
-	.setup_forced	= bcm54xx_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= bcm54xx_read_link,
-};
-
-static struct mii_phy_def bcm5411_phy_def = {
-	.phy_id		= 0x00206070,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5411",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5411_phy_ops
-};
-
-/* Broadcom BCM 5421 */
-static struct mii_phy_ops bcm5421_phy_ops = {
-	.init		= bcm5421_init,
-	.suspend	= generic_suspend,
-	.setup_aneg	= bcm54xx_setup_aneg,
-	.setup_forced	= bcm54xx_setup_forced,
-	.poll_link	= bcm5421_poll_link,
-	.read_link	= bcm5421_read_link,
-	.enable_fiber   = bcm5421_enable_fiber,
-};
-
-static struct mii_phy_def bcm5421_phy_def = {
-	.phy_id		= 0x002060e0,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5421",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5421_phy_ops
-};
-
-/* Broadcom BCM 5421 built-in K2 */
-static struct mii_phy_ops bcm5421k2_phy_ops = {
-	.init		= bcm5421_init,
-	.suspend	= generic_suspend,
-	.setup_aneg	= bcm54xx_setup_aneg,
-	.setup_forced	= bcm54xx_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= bcm54xx_read_link,
-};
-
-static struct mii_phy_def bcm5421k2_phy_def = {
-	.phy_id		= 0x002062e0,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5421-K2",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5421k2_phy_ops
-};
-
-static struct mii_phy_ops bcm5461_phy_ops = {
-	.init		= bcm5421_init,
-	.suspend	= generic_suspend,
-	.setup_aneg	= bcm54xx_setup_aneg,
-	.setup_forced	= bcm54xx_setup_forced,
-	.poll_link	= bcm5461_poll_link,
-	.read_link	= bcm5461_read_link,
-	.enable_fiber   = bcm5461_enable_fiber,
-};
-
-static struct mii_phy_def bcm5461_phy_def = {
-	.phy_id		= 0x002060c0,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5461",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5461_phy_ops
-};
-
-/* Broadcom BCM 5462 built-in Vesta */
-static struct mii_phy_ops bcm5462V_phy_ops = {
-	.init		= bcm5421_init,
-	.suspend	= generic_suspend,
-	.setup_aneg	= bcm54xx_setup_aneg,
-	.setup_forced	= bcm54xx_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= bcm54xx_read_link,
-};
-
-static struct mii_phy_def bcm5462V_phy_def = {
-	.phy_id		= 0x002060d0,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "BCM5462-Vesta",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &bcm5462V_phy_ops
-};
-
-/* Marvell 88E1101 amd 88E1111 */
-static struct mii_phy_ops marvell88e1101_phy_ops = {
-	.suspend	= generic_suspend,
-	.setup_aneg	= marvell_setup_aneg,
-	.setup_forced	= marvell_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= marvell_read_link
-};
-
-static struct mii_phy_ops marvell88e1111_phy_ops = {
-	.init		= marvell88e1111_init,
-	.suspend	= generic_suspend,
-	.setup_aneg	= marvell_setup_aneg,
-	.setup_forced	= marvell_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= marvell_read_link
-};
-
-/* two revs in darwin for the 88e1101 ... I could use a datasheet
- * to get the proper names...
- */
-static struct mii_phy_def marvell88e1101v1_phy_def = {
-	.phy_id		= 0x01410c20,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "Marvell 88E1101v1",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &marvell88e1101_phy_ops
-};
-static struct mii_phy_def marvell88e1101v2_phy_def = {
-	.phy_id		= 0x01410c60,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "Marvell 88E1101v2",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &marvell88e1101_phy_ops
-};
-static struct mii_phy_def marvell88e1111_phy_def = {
-	.phy_id		= 0x01410cc0,
-	.phy_id_mask	= 0xfffffff0,
-	.name		= "Marvell 88E1111",
-	.features	= MII_GBIT_FEATURES,
-	.magic_aneg	= 1,
-	.ops		= &marvell88e1111_phy_ops
-};
-
-/* Generic implementation for most 10/100 PHYs */
-static struct mii_phy_ops generic_phy_ops = {
-	.setup_aneg	= genmii_setup_aneg,
-	.setup_forced	= genmii_setup_forced,
-	.poll_link	= genmii_poll_link,
-	.read_link	= genmii_read_link
-};
-
-static struct mii_phy_def genmii_phy_def = {
-	.phy_id		= 0x00000000,
-	.phy_id_mask	= 0x00000000,
-	.name		= "Generic MII",
-	.features	= MII_BASIC_FEATURES,
-	.magic_aneg	= 0,
-	.ops		= &generic_phy_ops
-};
-
-static struct mii_phy_def* mii_phy_table[] = {
-	&bcm5201_phy_def,
-	&bcm5221_phy_def,
-	&bcm5241_phy_def,
-	&bcm5400_phy_def,
-	&bcm5401_phy_def,
-	&bcm5411_phy_def,
-	&bcm5421_phy_def,
-	&bcm5421k2_phy_def,
-	&bcm5461_phy_def,
-	&bcm5462V_phy_def,
-	&marvell88e1101v1_phy_def,
-	&marvell88e1101v2_phy_def,
-	&marvell88e1111_phy_def,
-	&genmii_phy_def,
-	NULL
-};
-
-int mii_phy_probe(struct mii_phy *phy, int mii_id)
-{
-	int rc;
-	u32 id;
-	struct mii_phy_def* def;
-	int i;
-
-	/* We do not reset the mii_phy structure as the driver
-	 * may re-probe the PHY regulary
-	 */
-	phy->mii_id = mii_id;
-
-	/* Take PHY out of isloate mode and reset it. */
-	rc = reset_one_mii_phy(phy, mii_id);
-	if (rc)
-		goto fail;
-
-	/* Read ID and find matching entry */
-	id = (phy_read(phy, MII_PHYSID1) << 16 | phy_read(phy, MII_PHYSID2));
-	printk(KERN_DEBUG KBUILD_MODNAME ": " "PHY ID: %x, addr: %x\n",
-	       id, mii_id);
-	for (i=0; (def = mii_phy_table[i]) != NULL; i++)
-		if ((id & def->phy_id_mask) == def->phy_id)
-			break;
-	/* Should never be NULL (we have a generic entry), but... */
-	if (def == NULL)
-		goto fail;
-
-	phy->def = def;
-
-	return 0;
-fail:
-	phy->speed = 0;
-	phy->duplex = 0;
-	phy->pause = 0;
-	phy->advertising = 0;
-	return -ENODEV;
-}
-
-EXPORT_SYMBOL(mii_phy_probe);
-MODULE_LICENSE("GPL");
-
diff --git a/drivers/net/ethernet/toshiba/Makefile b/drivers/net/ethernet/toshiba/Makefile
index 71d861f..a506900 100644
--- a/drivers/net/ethernet/toshiba/Makefile
+++ b/drivers/net/ethernet/toshiba/Makefile
@@ -6,5 +6,5 @@ obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
 gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
 ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
 spidernet-y += spider_net.o spider_net_ethtool.o
-obj-$(CONFIG_SPIDER_NET) += spidernet.o ethernet/sun/sungem_phy.o
+obj-$(CONFIG_SPIDER_NET) += spidernet.o
 obj-$(CONFIG_TC35815) += tc35815.o
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 1ff3491c..af345db 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -196,7 +196,7 @@ spider_net_setup_aneg(struct spider_net_card *card)
 	if ((bmsr & BMSR_ESTATEN) && (estat & ESTATUS_1000_THALF))
 		advertise |= SUPPORTED_1000baseT_Half;
 
-	mii_phy_probe(phy, phy->mii_id);
+	sungem_phy_probe(phy, phy->mii_id);
 	phy->def->ops->setup_aneg(phy, advertise);
 
 }
@@ -2120,7 +2120,7 @@ spider_net_setup_phy(struct spider_net_card *card)
 		unsigned short id;
 		id = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
 		if (id != 0x0000 && id != 0xffff) {
-			if (!mii_phy_probe(phy, phy->mii_id)) {
+			if (!sungem_phy_probe(phy, phy->mii_id)) {
 				pr_info("Found %s.\n", phy->def->name);
 				break;
 			}
diff --git a/drivers/net/sungem_phy.c b/drivers/net/sungem_phy.c
new file mode 100644
index 0000000..58f13ad
--- /dev/null
+++ b/drivers/net/sungem_phy.c
@@ -0,0 +1,1199 @@
+/*
+ * PHY drivers for the sungem ethernet driver.
+ *
+ * This file could be shared with other drivers.
+ *
+ * (c) 2002-2007, Benjamin Herrenscmidt (benh@kernel.crashing.org)
+ *
+ * TODO:
+ *  - Add support for PHYs that provide an IRQ line
+ *  - Eventually moved the entire polling state machine in
+ *    there (out of the eth driver), so that it can easily be
+ *    skipped on PHYs that implement it in hardware.
+ *  - On LXT971 & BCM5201, Apple uses some chip specific regs
+ *    to read the link status. Figure out why and if it makes
+ *    sense to do the same (magic aneg ?)
+ *  - Apple has some additional power management code for some
+ *    Broadcom PHYs that they "hide" from the OpenSource version
+ *    of darwin, still need to reverse engineer that
+ */
+
+
+#include <linux/module.h>
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/delay.h>
+
+#ifdef CONFIG_PPC_PMAC
+#include <asm/prom.h>
+#endif
+
+#include <linux/sungem_phy.h>
+
+/* Link modes of the BCM5400 PHY */
+static const int phy_BCM5400_link_table[8][3] = {
+	{ 0, 0, 0 },	/* No link */
+	{ 0, 0, 0 },	/* 10BT Half Duplex */
+	{ 1, 0, 0 },	/* 10BT Full Duplex */
+	{ 0, 1, 0 },	/* 100BT Half Duplex */
+	{ 0, 1, 0 },	/* 100BT Half Duplex */
+	{ 1, 1, 0 },	/* 100BT Full Duplex*/
+	{ 1, 0, 1 },	/* 1000BT */
+	{ 1, 0, 1 },	/* 1000BT */
+};
+
+static inline int __phy_read(struct mii_phy* phy, int id, int reg)
+{
+	return phy->mdio_read(phy->dev, id, reg);
+}
+
+static inline void __phy_write(struct mii_phy* phy, int id, int reg, int val)
+{
+	phy->mdio_write(phy->dev, id, reg, val);
+}
+
+static inline int phy_read(struct mii_phy* phy, int reg)
+{
+	return phy->mdio_read(phy->dev, phy->mii_id, reg);
+}
+
+static inline void phy_write(struct mii_phy* phy, int reg, int val)
+{
+	phy->mdio_write(phy->dev, phy->mii_id, reg, val);
+}
+
+static int reset_one_mii_phy(struct mii_phy* phy, int phy_id)
+{
+	u16 val;
+	int limit = 10000;
+
+	val = __phy_read(phy, phy_id, MII_BMCR);
+	val &= ~(BMCR_ISOLATE | BMCR_PDOWN);
+	val |= BMCR_RESET;
+	__phy_write(phy, phy_id, MII_BMCR, val);
+
+	udelay(100);
+
+	while (--limit) {
+		val = __phy_read(phy, phy_id, MII_BMCR);
+		if ((val & BMCR_RESET) == 0)
+			break;
+		udelay(10);
+	}
+	if ((val & BMCR_ISOLATE) && limit > 0)
+		__phy_write(phy, phy_id, MII_BMCR, val & ~BMCR_ISOLATE);
+
+	return limit <= 0;
+}
+
+static int bcm5201_init(struct mii_phy* phy)
+{
+	u16 data;
+
+	data = phy_read(phy, MII_BCM5201_MULTIPHY);
+	data &= ~MII_BCM5201_MULTIPHY_SUPERISOLATE;
+	phy_write(phy, MII_BCM5201_MULTIPHY, data);
+
+	phy_write(phy, MII_BCM5201_INTERRUPT, 0);
+
+	return 0;
+}
+
+static int bcm5201_suspend(struct mii_phy* phy)
+{
+	phy_write(phy, MII_BCM5201_INTERRUPT, 0);
+	phy_write(phy, MII_BCM5201_MULTIPHY, MII_BCM5201_MULTIPHY_SUPERISOLATE);
+
+	return 0;
+}
+
+static int bcm5221_init(struct mii_phy* phy)
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
+		data | MII_BCM5221_SHDOW_AUX_MODE4_CLKLOPWR);
+
+	data = phy_read(phy, MII_BCM5221_TEST);
+	phy_write(phy, MII_BCM5221_TEST,
+		data & ~MII_BCM5221_TEST_ENABLE_SHADOWS);
+
+	return 0;
+}
+
+static int bcm5221_suspend(struct mii_phy* phy)
+{
+	u16 data;
+
+	data = phy_read(phy, MII_BCM5221_TEST);
+	phy_write(phy, MII_BCM5221_TEST,
+		data | MII_BCM5221_TEST_ENABLE_SHADOWS);
+
+	data = phy_read(phy, MII_BCM5221_SHDOW_AUX_MODE4);
+	phy_write(phy, MII_BCM5221_SHDOW_AUX_MODE4,
+		  data | MII_BCM5221_SHDOW_AUX_MODE4_IDDQMODE);
+
+	return 0;
+}
+
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
+static int bcm5400_init(struct mii_phy* phy)
+{
+	u16 data;
+
+	/* Configure for gigabit full duplex */
+	data = phy_read(phy, MII_BCM5400_AUXCONTROL);
+	data |= MII_BCM5400_AUXCONTROL_PWR10BASET;
+	phy_write(phy, MII_BCM5400_AUXCONTROL, data);
+
+	data = phy_read(phy, MII_BCM5400_GB_CONTROL);
+	data |= MII_BCM5400_GB_CONTROL_FULLDUPLEXCAP;
+	phy_write(phy, MII_BCM5400_GB_CONTROL, data);
+
+	udelay(100);
+
+	/* Reset and configure cascaded 10/100 PHY */
+	(void)reset_one_mii_phy(phy, 0x1f);
+
+	data = __phy_read(phy, 0x1f, MII_BCM5201_MULTIPHY);
+	data |= MII_BCM5201_MULTIPHY_SERIALMODE;
+	__phy_write(phy, 0x1f, MII_BCM5201_MULTIPHY, data);
+
+	data = phy_read(phy, MII_BCM5400_AUXCONTROL);
+	data &= ~MII_BCM5400_AUXCONTROL_PWR10BASET;
+	phy_write(phy, MII_BCM5400_AUXCONTROL, data);
+
+	return 0;
+}
+
+static int bcm5400_suspend(struct mii_phy* phy)
+{
+#if 0 /* Commented out in Darwin... someone has those dawn docs ? */
+	phy_write(phy, MII_BMCR, BMCR_PDOWN);
+#endif
+	return 0;
+}
+
+static int bcm5401_init(struct mii_phy* phy)
+{
+	u16 data;
+	int rev;
+
+	rev = phy_read(phy, MII_PHYSID2) & 0x000f;
+	if (rev == 0 || rev == 3) {
+		/* Some revisions of 5401 appear to need this
+		 * initialisation sequence to disable, according
+		 * to OF, "tap power management"
+		 *
+		 * WARNING ! OF and Darwin don't agree on the
+		 * register addresses. OF seem to interpret the
+		 * register numbers below as decimal
+		 *
+		 * Note: This should (and does) match tg3_init_5401phy_dsp
+		 *       in the tg3.c driver. -DaveM
+		 */
+		phy_write(phy, 0x18, 0x0c20);
+		phy_write(phy, 0x17, 0x0012);
+		phy_write(phy, 0x15, 0x1804);
+		phy_write(phy, 0x17, 0x0013);
+		phy_write(phy, 0x15, 0x1204);
+		phy_write(phy, 0x17, 0x8006);
+		phy_write(phy, 0x15, 0x0132);
+		phy_write(phy, 0x17, 0x8006);
+		phy_write(phy, 0x15, 0x0232);
+		phy_write(phy, 0x17, 0x201f);
+		phy_write(phy, 0x15, 0x0a20);
+	}
+
+	/* Configure for gigabit full duplex */
+	data = phy_read(phy, MII_BCM5400_GB_CONTROL);
+	data |= MII_BCM5400_GB_CONTROL_FULLDUPLEXCAP;
+	phy_write(phy, MII_BCM5400_GB_CONTROL, data);
+
+	udelay(10);
+
+	/* Reset and configure cascaded 10/100 PHY */
+	(void)reset_one_mii_phy(phy, 0x1f);
+
+	data = __phy_read(phy, 0x1f, MII_BCM5201_MULTIPHY);
+	data |= MII_BCM5201_MULTIPHY_SERIALMODE;
+	__phy_write(phy, 0x1f, MII_BCM5201_MULTIPHY, data);
+
+	return 0;
+}
+
+static int bcm5401_suspend(struct mii_phy* phy)
+{
+#if 0 /* Commented out in Darwin... someone has those dawn docs ? */
+	phy_write(phy, MII_BMCR, BMCR_PDOWN);
+#endif
+	return 0;
+}
+
+static int bcm5411_init(struct mii_phy* phy)
+{
+	u16 data;
+
+	/* Here's some more Apple black magic to setup
+	 * some voltage stuffs.
+	 */
+	phy_write(phy, 0x1c, 0x8c23);
+	phy_write(phy, 0x1c, 0x8ca3);
+	phy_write(phy, 0x1c, 0x8c23);
+
+	/* Here, Apple seems to want to reset it, do
+	 * it as well
+	 */
+	phy_write(phy, MII_BMCR, BMCR_RESET);
+	phy_write(phy, MII_BMCR, 0x1340);
+
+	data = phy_read(phy, MII_BCM5400_GB_CONTROL);
+	data |= MII_BCM5400_GB_CONTROL_FULLDUPLEXCAP;
+	phy_write(phy, MII_BCM5400_GB_CONTROL, data);
+
+	udelay(10);
+
+	/* Reset and configure cascaded 10/100 PHY */
+	(void)reset_one_mii_phy(phy, 0x1f);
+
+	return 0;
+}
+
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
+static int generic_suspend(struct mii_phy* phy)
+{
+	phy_write(phy, MII_BMCR, BMCR_PDOWN);
+
+	return 0;
+}
+
+static int bcm5421_init(struct mii_phy* phy)
+{
+	u16 data;
+	unsigned int id;
+
+	id = (phy_read(phy, MII_PHYSID1) << 16 | phy_read(phy, MII_PHYSID2));
+
+	/* Revision 0 of 5421 needs some fixups */
+	if (id == 0x002060e0) {
+		/* This is borrowed from MacOS
+		 */
+		phy_write(phy, 0x18, 0x1007);
+		data = phy_read(phy, 0x18);
+		phy_write(phy, 0x18, data | 0x0400);
+		phy_write(phy, 0x18, 0x0007);
+		data = phy_read(phy, 0x18);
+		phy_write(phy, 0x18, data | 0x0800);
+		phy_write(phy, 0x17, 0x000a);
+		data = phy_read(phy, 0x15);
+		phy_write(phy, 0x15, data | 0x0200);
+	}
+
+	/* Pick up some init code from OF for K2 version */
+	if ((id & 0xfffffff0) == 0x002062e0) {
+		phy_write(phy, 4, 0x01e1);
+		phy_write(phy, 9, 0x0300);
+	}
+
+	/* Check if we can enable automatic low power */
+#ifdef CONFIG_PPC_PMAC
+	if (phy->platform_data) {
+		struct device_node *np = of_get_parent(phy->platform_data);
+		int can_low_power = 1;
+		if (np == NULL || of_get_property(np, "no-autolowpower", NULL))
+			can_low_power = 0;
+		if (can_low_power) {
+			/* Enable automatic low-power */
+			phy_write(phy, 0x1c, 0x9002);
+			phy_write(phy, 0x1c, 0xa821);
+			phy_write(phy, 0x1c, 0x941d);
+		}
+	}
+#endif /* CONFIG_PPC_PMAC */
+
+	return 0;
+}
+
+static int bcm54xx_setup_aneg(struct mii_phy *phy, u32 advertise)
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
+	if (advertise & ADVERTISED_Pause)
+		adv |= ADVERTISE_PAUSE_CAP;
+	if (advertise & ADVERTISED_Asym_Pause)
+		adv |= ADVERTISE_PAUSE_ASYM;
+	phy_write(phy, MII_ADVERTISE, adv);
+
+	/* Setup 1000BT advertise */
+	adv = phy_read(phy, MII_1000BASETCONTROL);
+	adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP|MII_1000BASETCONTROL_HALFDUPLEXCAP);
+	if (advertise & SUPPORTED_1000baseT_Half)
+		adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
+	if (advertise & SUPPORTED_1000baseT_Full)
+		adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
+	phy_write(phy, MII_1000BASETCONTROL, adv);
+
+	/* Start/Restart aneg */
+	ctl = phy_read(phy, MII_BMCR);
+	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	phy_write(phy, MII_BMCR, ctl);
+
+	return 0;
+}
+
+static int bcm54xx_setup_forced(struct mii_phy *phy, int speed, int fd)
+{
+	u16 ctl;
+
+	phy->autoneg = 0;
+	phy->speed = speed;
+	phy->duplex = fd;
+	phy->pause = 0;
+
+	ctl = phy_read(phy, MII_BMCR);
+	ctl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_SPD2|BMCR_ANENABLE);
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
+		ctl |= BMCR_SPD2;
+	}
+	if (fd == DUPLEX_FULL)
+		ctl |= BMCR_FULLDPLX;
+
+	// XXX Should we set the sungem to GII now on 1000BT ?
+
+	phy_write(phy, MII_BMCR, ctl);
+
+	return 0;
+}
+
+static int bcm54xx_read_link(struct mii_phy *phy)
+{
+	int link_mode;
+	u16 val;
+
+	if (phy->autoneg) {
+	    	val = phy_read(phy, MII_BCM5400_AUXSTATUS);
+		link_mode = ((val & MII_BCM5400_AUXSTATUS_LINKMODE_MASK) >>
+			     MII_BCM5400_AUXSTATUS_LINKMODE_SHIFT);
+		phy->duplex = phy_BCM5400_link_table[link_mode][0] ?
+			DUPLEX_FULL : DUPLEX_HALF;
+		phy->speed = phy_BCM5400_link_table[link_mode][2] ?
+				SPEED_1000 :
+				(phy_BCM5400_link_table[link_mode][1] ?
+				 SPEED_100 : SPEED_10);
+		val = phy_read(phy, MII_LPA);
+		phy->pause = (phy->duplex == DUPLEX_FULL) &&
+			((val & LPA_PAUSE) != 0);
+	}
+	/* On non-aneg, we assume what we put in BMCR is the speed,
+	 * though magic-aneg shouldn't prevent this case from occurring
+	 */
+
+	return 0;
+}
+
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
+static int marvell_setup_aneg(struct mii_phy *phy, u32 advertise)
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
+	if (advertise & ADVERTISED_Pause)
+		adv |= ADVERTISE_PAUSE_CAP;
+	if (advertise & ADVERTISED_Asym_Pause)
+		adv |= ADVERTISE_PAUSE_ASYM;
+	phy_write(phy, MII_ADVERTISE, adv);
+
+	/* Setup 1000BT advertise & enable crossover detect
+	 * XXX How do we advertise 1000BT ? Darwin source is
+	 * confusing here, they read from specific control and
+	 * write to control... Someone has specs for those
+	 * beasts ?
+	 */
+	adv = phy_read(phy, MII_M1011_PHY_SPEC_CONTROL);
+	adv |= MII_M1011_PHY_SPEC_CONTROL_AUTO_MDIX;
+	adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
+			MII_1000BASETCONTROL_HALFDUPLEXCAP);
+	if (advertise & SUPPORTED_1000baseT_Half)
+		adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
+	if (advertise & SUPPORTED_1000baseT_Full)
+		adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
+	phy_write(phy, MII_1000BASETCONTROL, adv);
+
+	/* Start/Restart aneg */
+	ctl = phy_read(phy, MII_BMCR);
+	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
+	phy_write(phy, MII_BMCR, ctl);
+
+	return 0;
+}
+
+static int marvell_setup_forced(struct mii_phy *phy, int speed, int fd)
+{
+	u16 ctl, ctl2;
+
+	phy->autoneg = 0;
+	phy->speed = speed;
+	phy->duplex = fd;
+	phy->pause = 0;
+
+	ctl = phy_read(phy, MII_BMCR);
+	ctl &= ~(BMCR_FULLDPLX|BMCR_SPEED100|BMCR_SPD2|BMCR_ANENABLE);
+	ctl |= BMCR_RESET;
+
+	/* Select speed & duplex */
+	switch(speed) {
+	case SPEED_10:
+		break;
+	case SPEED_100:
+		ctl |= BMCR_SPEED100;
+		break;
+	/* I'm not sure about the one below, again, Darwin source is
+	 * quite confusing and I lack chip specs
+	 */
+	case SPEED_1000:
+		ctl |= BMCR_SPD2;
+	}
+	if (fd == DUPLEX_FULL)
+		ctl |= BMCR_FULLDPLX;
+
+	/* Disable crossover. Again, the way Apple does it is strange,
+	 * though I don't assume they are wrong ;)
+	 */
+	ctl2 = phy_read(phy, MII_M1011_PHY_SPEC_CONTROL);
+	ctl2 &= ~(MII_M1011_PHY_SPEC_CONTROL_MANUAL_MDIX |
+		MII_M1011_PHY_SPEC_CONTROL_AUTO_MDIX |
+		MII_1000BASETCONTROL_FULLDUPLEXCAP |
+		MII_1000BASETCONTROL_HALFDUPLEXCAP);
+	if (speed == SPEED_1000)
+		ctl2 |= (fd == DUPLEX_FULL) ?
+			MII_1000BASETCONTROL_FULLDUPLEXCAP :
+			MII_1000BASETCONTROL_HALFDUPLEXCAP;
+	phy_write(phy, MII_1000BASETCONTROL, ctl2);
+
+	// XXX Should we set the sungem to GII now on 1000BT ?
+
+	phy_write(phy, MII_BMCR, ctl);
+
+	return 0;
+}
+
+static int marvell_read_link(struct mii_phy *phy)
+{
+	u16 status, pmask;
+
+	if (phy->autoneg) {
+		status = phy_read(phy, MII_M1011_PHY_SPEC_STATUS);
+		if ((status & MII_M1011_PHY_SPEC_STATUS_RESOLVED) == 0)
+			return -EAGAIN;
+		if (status & MII_M1011_PHY_SPEC_STATUS_1000)
+			phy->speed = SPEED_1000;
+		else if (status & MII_M1011_PHY_SPEC_STATUS_100)
+			phy->speed = SPEED_100;
+		else
+			phy->speed = SPEED_10;
+		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
+			phy->duplex = DUPLEX_FULL;
+		else
+			phy->duplex = DUPLEX_HALF;
+		pmask = MII_M1011_PHY_SPEC_STATUS_TX_PAUSE |
+			MII_M1011_PHY_SPEC_STATUS_RX_PAUSE;
+		phy->pause = (status & pmask) == pmask;
+	}
+	/* On non-aneg, we assume what we put in BMCR is the speed,
+	 * though magic-aneg shouldn't prevent this case from occurring
+	 */
+
+	return 0;
+}
+
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
+
+/* Broadcom BCM 5201 */
+static struct mii_phy_ops bcm5201_phy_ops = {
+	.init		= bcm5201_init,
+	.suspend	= bcm5201_suspend,
+	.setup_aneg	= genmii_setup_aneg,
+	.setup_forced	= genmii_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= genmii_read_link,
+};
+
+static struct mii_phy_def bcm5201_phy_def = {
+	.phy_id		= 0x00406210,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5201",
+	.features	= MII_BASIC_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5201_phy_ops
+};
+
+/* Broadcom BCM 5221 */
+static struct mii_phy_ops bcm5221_phy_ops = {
+	.suspend	= bcm5221_suspend,
+	.init		= bcm5221_init,
+	.setup_aneg	= genmii_setup_aneg,
+	.setup_forced	= genmii_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= genmii_read_link,
+};
+
+static struct mii_phy_def bcm5221_phy_def = {
+	.phy_id		= 0x004061e0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5221",
+	.features	= MII_BASIC_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5221_phy_ops
+};
+
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
+/* Broadcom BCM 5400 */
+static struct mii_phy_ops bcm5400_phy_ops = {
+	.init		= bcm5400_init,
+	.suspend	= bcm5400_suspend,
+	.setup_aneg	= bcm54xx_setup_aneg,
+	.setup_forced	= bcm54xx_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= bcm54xx_read_link,
+};
+
+static struct mii_phy_def bcm5400_phy_def = {
+	.phy_id		= 0x00206040,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5400",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5400_phy_ops
+};
+
+/* Broadcom BCM 5401 */
+static struct mii_phy_ops bcm5401_phy_ops = {
+	.init		= bcm5401_init,
+	.suspend	= bcm5401_suspend,
+	.setup_aneg	= bcm54xx_setup_aneg,
+	.setup_forced	= bcm54xx_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= bcm54xx_read_link,
+};
+
+static struct mii_phy_def bcm5401_phy_def = {
+	.phy_id		= 0x00206050,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5401",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5401_phy_ops
+};
+
+/* Broadcom BCM 5411 */
+static struct mii_phy_ops bcm5411_phy_ops = {
+	.init		= bcm5411_init,
+	.suspend	= generic_suspend,
+	.setup_aneg	= bcm54xx_setup_aneg,
+	.setup_forced	= bcm54xx_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= bcm54xx_read_link,
+};
+
+static struct mii_phy_def bcm5411_phy_def = {
+	.phy_id		= 0x00206070,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5411",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5411_phy_ops
+};
+
+/* Broadcom BCM 5421 */
+static struct mii_phy_ops bcm5421_phy_ops = {
+	.init		= bcm5421_init,
+	.suspend	= generic_suspend,
+	.setup_aneg	= bcm54xx_setup_aneg,
+	.setup_forced	= bcm54xx_setup_forced,
+	.poll_link	= bcm5421_poll_link,
+	.read_link	= bcm5421_read_link,
+	.enable_fiber   = bcm5421_enable_fiber,
+};
+
+static struct mii_phy_def bcm5421_phy_def = {
+	.phy_id		= 0x002060e0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5421",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5421_phy_ops
+};
+
+/* Broadcom BCM 5421 built-in K2 */
+static struct mii_phy_ops bcm5421k2_phy_ops = {
+	.init		= bcm5421_init,
+	.suspend	= generic_suspend,
+	.setup_aneg	= bcm54xx_setup_aneg,
+	.setup_forced	= bcm54xx_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= bcm54xx_read_link,
+};
+
+static struct mii_phy_def bcm5421k2_phy_def = {
+	.phy_id		= 0x002062e0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5421-K2",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5421k2_phy_ops
+};
+
+static struct mii_phy_ops bcm5461_phy_ops = {
+	.init		= bcm5421_init,
+	.suspend	= generic_suspend,
+	.setup_aneg	= bcm54xx_setup_aneg,
+	.setup_forced	= bcm54xx_setup_forced,
+	.poll_link	= bcm5461_poll_link,
+	.read_link	= bcm5461_read_link,
+	.enable_fiber   = bcm5461_enable_fiber,
+};
+
+static struct mii_phy_def bcm5461_phy_def = {
+	.phy_id		= 0x002060c0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5461",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5461_phy_ops
+};
+
+/* Broadcom BCM 5462 built-in Vesta */
+static struct mii_phy_ops bcm5462V_phy_ops = {
+	.init		= bcm5421_init,
+	.suspend	= generic_suspend,
+	.setup_aneg	= bcm54xx_setup_aneg,
+	.setup_forced	= bcm54xx_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= bcm54xx_read_link,
+};
+
+static struct mii_phy_def bcm5462V_phy_def = {
+	.phy_id		= 0x002060d0,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "BCM5462-Vesta",
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &bcm5462V_phy_ops
+};
+
+/* Marvell 88E1101 amd 88E1111 */
+static struct mii_phy_ops marvell88e1101_phy_ops = {
+	.suspend	= generic_suspend,
+	.setup_aneg	= marvell_setup_aneg,
+	.setup_forced	= marvell_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= marvell_read_link
+};
+
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
+	.features	= MII_GBIT_FEATURES,
+	.magic_aneg	= 1,
+	.ops		= &marvell88e1111_phy_ops
+};
+
+/* Generic implementation for most 10/100 PHYs */
+static struct mii_phy_ops generic_phy_ops = {
+	.setup_aneg	= genmii_setup_aneg,
+	.setup_forced	= genmii_setup_forced,
+	.poll_link	= genmii_poll_link,
+	.read_link	= genmii_read_link
+};
+
+static struct mii_phy_def genmii_phy_def = {
+	.phy_id		= 0x00000000,
+	.phy_id_mask	= 0x00000000,
+	.name		= "Generic MII",
+	.features	= MII_BASIC_FEATURES,
+	.magic_aneg	= 0,
+	.ops		= &generic_phy_ops
+};
+
+static struct mii_phy_def* mii_phy_table[] = {
+	&bcm5201_phy_def,
+	&bcm5221_phy_def,
+	&bcm5241_phy_def,
+	&bcm5400_phy_def,
+	&bcm5401_phy_def,
+	&bcm5411_phy_def,
+	&bcm5421_phy_def,
+	&bcm5421k2_phy_def,
+	&bcm5461_phy_def,
+	&bcm5462V_phy_def,
+	&marvell88e1101v1_phy_def,
+	&marvell88e1101v2_phy_def,
+	&marvell88e1111_phy_def,
+	&genmii_phy_def,
+	NULL
+};
+
+int sungem_phy_probe(struct mii_phy *phy, int mii_id)
+{
+	int rc;
+	u32 id;
+	struct mii_phy_def* def;
+	int i;
+
+	/* We do not reset the mii_phy structure as the driver
+	 * may re-probe the PHY regulary
+	 */
+	phy->mii_id = mii_id;
+
+	/* Take PHY out of isloate mode and reset it. */
+	rc = reset_one_mii_phy(phy, mii_id);
+	if (rc)
+		goto fail;
+
+	/* Read ID and find matching entry */
+	id = (phy_read(phy, MII_PHYSID1) << 16 | phy_read(phy, MII_PHYSID2));
+	printk(KERN_DEBUG KBUILD_MODNAME ": " "PHY ID: %x, addr: %x\n",
+	       id, mii_id);
+	for (i=0; (def = mii_phy_table[i]) != NULL; i++)
+		if ((id & def->phy_id_mask) == def->phy_id)
+			break;
+	/* Should never be NULL (we have a generic entry), but... */
+	if (def == NULL)
+		goto fail;
+
+	phy->def = def;
+
+	return 0;
+fail:
+	phy->speed = 0;
+	phy->duplex = 0;
+	phy->pause = 0;
+	phy->advertising = 0;
+	return -ENODEV;
+}
+
+EXPORT_SYMBOL(sungem_phy_probe);
+MODULE_LICENSE("GPL");
diff --git a/include/linux/sungem_phy.h b/include/linux/sungem_phy.h
index af02f94..bd9be9f 100644
--- a/include/linux/sungem_phy.h
+++ b/include/linux/sungem_phy.h
@@ -61,7 +61,7 @@ struct mii_phy
 /* Pass in a struct mii_phy with dev, mdio_read and mdio_write
  * filled, the remaining fields will be filled on return
  */
-extern int mii_phy_probe(struct mii_phy *phy, int mii_id);
+extern int sungem_phy_probe(struct mii_phy *phy, int mii_id);
 
 
 /* MII definitions missing from mii.h */
-- 
1.7.6
