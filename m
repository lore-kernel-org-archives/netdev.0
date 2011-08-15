From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Sun, 14 Aug 2011 22:56:10 -0700 (PDT)
Message-ID: <20110814.225610.2264854100578866902.davem@davemloft.net>
References: <20110815152048.3b8f8484faf1891ef2fce266@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110815152048.3b8f8484faf1891ef2fce266@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 15 Aug 2011 15:20:48 +1000

> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> make[5]: *** No rule to make target `drivers/net/ethernet/toshiba/ethernet/sun/sungem_phy.o', needed by `drivers/net/ethernet/toshiba/built-in.o'.
> In file included from drivers/net/ethernet/toshiba/spider_net_ethtool.c:28:0:
> drivers/net/ethernet/toshiba/spider_net.h:30:39: fatal error: ./ethernet/sun/sungem_phy.h: No such file or directory
> In file included from drivers/net/ethernet/toshiba/spider_net.c:54:0:
> drivers/net/ethernet/toshiba/spider_net.h:30:39: fatal error: ./ethernet/sun/sungem_phy.h: No such file or directory
> 
> Caused by commit 8df158ac36fa ("toshiba: Move the Toshiba drivers") or
> the surrounding commits.
> 
> I have just left this failure for today.

This should fix the include problem, but I suspect this thing won't
link.

Jeff we have to resolve this somehow, I explained last week how
you can't include object files outside of the current directory
in constructs like is being done for the spider_net driver in
order to get the sungem_phy.o thing tacked on.

--------------------
>From 2bb698412d8aab0bfc3f269f5ebe8eb67d7cc8f4 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Sun, 14 Aug 2011 22:52:04 -0700
Subject: [PATCH] net: Move sungem_phy.h under include/linux

Fixes build failures of the spider_net driver because it tries
to use a convoluted path to include this header.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/sun/sungem.c         |    2 +-
 drivers/net/ethernet/sun/sungem_phy.h     |  132 -----------------------------
 drivers/net/ethernet/toshiba/spider_net.h |    2 +-
 include/linux/sungem_phy.h                |  132 +++++++++++++++++++++++++++++
 4 files changed, 134 insertions(+), 134 deletions(-)
 delete mode 100644 drivers/net/ethernet/sun/sungem_phy.h
 create mode 100644 include/linux/sungem_phy.h

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index ade35dd..0f13c5d 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -59,7 +59,7 @@
 #include <asm/pmac_feature.h>
 #endif
 
-#include "sungem_phy.h"
+#include <linux/sungem_phy.h>
 #include "sungem.h"
 
 /* Stripping FCS is causing problems, disabled for now */
diff --git a/drivers/net/ethernet/sun/sungem_phy.h b/drivers/net/ethernet/sun/sungem_phy.h
deleted file mode 100644
index af02f94..0000000
--- a/drivers/net/ethernet/sun/sungem_phy.h
+++ /dev/null
@@ -1,132 +0,0 @@
-#ifndef __SUNGEM_PHY_H__
-#define __SUNGEM_PHY_H__
-
-struct mii_phy;
-
-/* Operations supported by any kind of PHY */
-struct mii_phy_ops
-{
-	int		(*init)(struct mii_phy *phy);
-	int		(*suspend)(struct mii_phy *phy);
-	int		(*setup_aneg)(struct mii_phy *phy, u32 advertise);
-	int		(*setup_forced)(struct mii_phy *phy, int speed, int fd);
-	int		(*poll_link)(struct mii_phy *phy);
-	int		(*read_link)(struct mii_phy *phy);
-	int		(*enable_fiber)(struct mii_phy *phy, int autoneg);
-};
-
-/* Structure used to statically define an mii/gii based PHY */
-struct mii_phy_def
-{
-	u32				phy_id;		/* Concatenated ID1 << 16 | ID2 */
-	u32				phy_id_mask;	/* Significant bits */
-	u32				features;	/* Ethtool SUPPORTED_* defines */
-	int				magic_aneg;	/* Autoneg does all speed test for us */
-	const char*			name;
-	const struct mii_phy_ops*	ops;
-};
-
-enum {
-	BCM54XX_COPPER,
-	BCM54XX_FIBER,
-	BCM54XX_GBIC,
-	BCM54XX_SGMII,
-	BCM54XX_UNKNOWN,
-};
-
-/* An instance of a PHY, partially borrowed from mii_if_info */
-struct mii_phy
-{
-	struct mii_phy_def*	def;
-	u32			advertising;
-	int			mii_id;
-
-	/* 1: autoneg enabled, 0: disabled */
-	int			autoneg;
-
-	/* forced speed & duplex (no autoneg)
-	 * partner speed & duplex & pause (autoneg)
-	 */
-	int			speed;
-	int			duplex;
-	int			pause;
-
-	/* Provided by host chip */
-	struct net_device	*dev;
-	int (*mdio_read) (struct net_device *dev, int mii_id, int reg);
-	void (*mdio_write) (struct net_device *dev, int mii_id, int reg, int val);
-	void			*platform_data;
-};
-
-/* Pass in a struct mii_phy with dev, mdio_read and mdio_write
- * filled, the remaining fields will be filled on return
- */
-extern int mii_phy_probe(struct mii_phy *phy, int mii_id);
-
-
-/* MII definitions missing from mii.h */
-
-#define BMCR_SPD2	0x0040		/* Gigabit enable (bcm54xx)	*/
-#define LPA_PAUSE	0x0400
-
-/* More PHY registers (model specific) */
-
-/* MII BCM5201 MULTIPHY interrupt register */
-#define MII_BCM5201_INTERRUPT			0x1A
-#define MII_BCM5201_INTERRUPT_INTENABLE		0x4000
-
-#define MII_BCM5201_AUXMODE2			0x1B
-#define MII_BCM5201_AUXMODE2_LOWPOWER		0x0008
-
-#define MII_BCM5201_MULTIPHY                    0x1E
-
-/* MII BCM5201 MULTIPHY register bits */
-#define MII_BCM5201_MULTIPHY_SERIALMODE         0x0002
-#define MII_BCM5201_MULTIPHY_SUPERISOLATE       0x0008
-
-/* MII BCM5221 Additional registers */
-#define MII_BCM5221_TEST			0x1f
-#define MII_BCM5221_TEST_ENABLE_SHADOWS		0x0080
-#define MII_BCM5221_SHDOW_AUX_STAT2		0x1b
-#define MII_BCM5221_SHDOW_AUX_STAT2_APD		0x0020
-#define MII_BCM5221_SHDOW_AUX_MODE4		0x1a
-#define MII_BCM5221_SHDOW_AUX_MODE4_IDDQMODE	0x0001
-#define MII_BCM5221_SHDOW_AUX_MODE4_CLKLOPWR	0x0004
-
-/* MII BCM5241 Additional registers */
-#define MII_BCM5241_SHDOW_AUX_MODE4_STANDBYPWR	0x0008
-
-/* MII BCM5400 1000-BASET Control register */
-#define MII_BCM5400_GB_CONTROL			0x09
-#define MII_BCM5400_GB_CONTROL_FULLDUPLEXCAP	0x0200
-
-/* MII BCM5400 AUXCONTROL register */
-#define MII_BCM5400_AUXCONTROL                  0x18
-#define MII_BCM5400_AUXCONTROL_PWR10BASET       0x0004
-
-/* MII BCM5400 AUXSTATUS register */
-#define MII_BCM5400_AUXSTATUS                   0x19
-#define MII_BCM5400_AUXSTATUS_LINKMODE_MASK     0x0700
-#define MII_BCM5400_AUXSTATUS_LINKMODE_SHIFT    8
-
-/* 1000BT control (Marvell & BCM54xx at least) */
-#define MII_1000BASETCONTROL			0x09
-#define MII_1000BASETCONTROL_FULLDUPLEXCAP	0x0200
-#define MII_1000BASETCONTROL_HALFDUPLEXCAP	0x0100
-
-/* Marvell 88E1011 PHY control */
-#define MII_M1011_PHY_SPEC_CONTROL		0x10
-#define MII_M1011_PHY_SPEC_CONTROL_MANUAL_MDIX	0x20
-#define MII_M1011_PHY_SPEC_CONTROL_AUTO_MDIX	0x40
-
-/* Marvell 88E1011 PHY status */
-#define MII_M1011_PHY_SPEC_STATUS		0x11
-#define MII_M1011_PHY_SPEC_STATUS_1000		0x8000
-#define MII_M1011_PHY_SPEC_STATUS_100		0x4000
-#define MII_M1011_PHY_SPEC_STATUS_SPD_MASK	0xc000
-#define MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX	0x2000
-#define MII_M1011_PHY_SPEC_STATUS_RESOLVED	0x0800
-#define MII_M1011_PHY_SPEC_STATUS_TX_PAUSE	0x0008
-#define MII_M1011_PHY_SPEC_STATUS_RX_PAUSE	0x0004
-
-#endif /* __SUNGEM_PHY_H__ */
diff --git a/drivers/net/ethernet/toshiba/spider_net.h b/drivers/net/ethernet/toshiba/spider_net.h
index a891ad0..4ba2135 100644
--- a/drivers/net/ethernet/toshiba/spider_net.h
+++ b/drivers/net/ethernet/toshiba/spider_net.h
@@ -27,7 +27,7 @@
 
 #define VERSION "2.0 B"
 
-#include "./ethernet/sun/sungem_phy.h"
+#include <linux/sungem_phy.h>
 
 extern int spider_net_stop(struct net_device *netdev);
 extern int spider_net_open(struct net_device *netdev);
diff --git a/include/linux/sungem_phy.h b/include/linux/sungem_phy.h
new file mode 100644
index 0000000..af02f94
--- /dev/null
+++ b/include/linux/sungem_phy.h
@@ -0,0 +1,132 @@
+#ifndef __SUNGEM_PHY_H__
+#define __SUNGEM_PHY_H__
+
+struct mii_phy;
+
+/* Operations supported by any kind of PHY */
+struct mii_phy_ops
+{
+	int		(*init)(struct mii_phy *phy);
+	int		(*suspend)(struct mii_phy *phy);
+	int		(*setup_aneg)(struct mii_phy *phy, u32 advertise);
+	int		(*setup_forced)(struct mii_phy *phy, int speed, int fd);
+	int		(*poll_link)(struct mii_phy *phy);
+	int		(*read_link)(struct mii_phy *phy);
+	int		(*enable_fiber)(struct mii_phy *phy, int autoneg);
+};
+
+/* Structure used to statically define an mii/gii based PHY */
+struct mii_phy_def
+{
+	u32				phy_id;		/* Concatenated ID1 << 16 | ID2 */
+	u32				phy_id_mask;	/* Significant bits */
+	u32				features;	/* Ethtool SUPPORTED_* defines */
+	int				magic_aneg;	/* Autoneg does all speed test for us */
+	const char*			name;
+	const struct mii_phy_ops*	ops;
+};
+
+enum {
+	BCM54XX_COPPER,
+	BCM54XX_FIBER,
+	BCM54XX_GBIC,
+	BCM54XX_SGMII,
+	BCM54XX_UNKNOWN,
+};
+
+/* An instance of a PHY, partially borrowed from mii_if_info */
+struct mii_phy
+{
+	struct mii_phy_def*	def;
+	u32			advertising;
+	int			mii_id;
+
+	/* 1: autoneg enabled, 0: disabled */
+	int			autoneg;
+
+	/* forced speed & duplex (no autoneg)
+	 * partner speed & duplex & pause (autoneg)
+	 */
+	int			speed;
+	int			duplex;
+	int			pause;
+
+	/* Provided by host chip */
+	struct net_device	*dev;
+	int (*mdio_read) (struct net_device *dev, int mii_id, int reg);
+	void (*mdio_write) (struct net_device *dev, int mii_id, int reg, int val);
+	void			*platform_data;
+};
+
+/* Pass in a struct mii_phy with dev, mdio_read and mdio_write
+ * filled, the remaining fields will be filled on return
+ */
+extern int mii_phy_probe(struct mii_phy *phy, int mii_id);
+
+
+/* MII definitions missing from mii.h */
+
+#define BMCR_SPD2	0x0040		/* Gigabit enable (bcm54xx)	*/
+#define LPA_PAUSE	0x0400
+
+/* More PHY registers (model specific) */
+
+/* MII BCM5201 MULTIPHY interrupt register */
+#define MII_BCM5201_INTERRUPT			0x1A
+#define MII_BCM5201_INTERRUPT_INTENABLE		0x4000
+
+#define MII_BCM5201_AUXMODE2			0x1B
+#define MII_BCM5201_AUXMODE2_LOWPOWER		0x0008
+
+#define MII_BCM5201_MULTIPHY                    0x1E
+
+/* MII BCM5201 MULTIPHY register bits */
+#define MII_BCM5201_MULTIPHY_SERIALMODE         0x0002
+#define MII_BCM5201_MULTIPHY_SUPERISOLATE       0x0008
+
+/* MII BCM5221 Additional registers */
+#define MII_BCM5221_TEST			0x1f
+#define MII_BCM5221_TEST_ENABLE_SHADOWS		0x0080
+#define MII_BCM5221_SHDOW_AUX_STAT2		0x1b
+#define MII_BCM5221_SHDOW_AUX_STAT2_APD		0x0020
+#define MII_BCM5221_SHDOW_AUX_MODE4		0x1a
+#define MII_BCM5221_SHDOW_AUX_MODE4_IDDQMODE	0x0001
+#define MII_BCM5221_SHDOW_AUX_MODE4_CLKLOPWR	0x0004
+
+/* MII BCM5241 Additional registers */
+#define MII_BCM5241_SHDOW_AUX_MODE4_STANDBYPWR	0x0008
+
+/* MII BCM5400 1000-BASET Control register */
+#define MII_BCM5400_GB_CONTROL			0x09
+#define MII_BCM5400_GB_CONTROL_FULLDUPLEXCAP	0x0200
+
+/* MII BCM5400 AUXCONTROL register */
+#define MII_BCM5400_AUXCONTROL                  0x18
+#define MII_BCM5400_AUXCONTROL_PWR10BASET       0x0004
+
+/* MII BCM5400 AUXSTATUS register */
+#define MII_BCM5400_AUXSTATUS                   0x19
+#define MII_BCM5400_AUXSTATUS_LINKMODE_MASK     0x0700
+#define MII_BCM5400_AUXSTATUS_LINKMODE_SHIFT    8
+
+/* 1000BT control (Marvell & BCM54xx at least) */
+#define MII_1000BASETCONTROL			0x09
+#define MII_1000BASETCONTROL_FULLDUPLEXCAP	0x0200
+#define MII_1000BASETCONTROL_HALFDUPLEXCAP	0x0100
+
+/* Marvell 88E1011 PHY control */
+#define MII_M1011_PHY_SPEC_CONTROL		0x10
+#define MII_M1011_PHY_SPEC_CONTROL_MANUAL_MDIX	0x20
+#define MII_M1011_PHY_SPEC_CONTROL_AUTO_MDIX	0x40
+
+/* Marvell 88E1011 PHY status */
+#define MII_M1011_PHY_SPEC_STATUS		0x11
+#define MII_M1011_PHY_SPEC_STATUS_1000		0x8000
+#define MII_M1011_PHY_SPEC_STATUS_100		0x4000
+#define MII_M1011_PHY_SPEC_STATUS_SPD_MASK	0xc000
+#define MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX	0x2000
+#define MII_M1011_PHY_SPEC_STATUS_RESOLVED	0x0800
+#define MII_M1011_PHY_SPEC_STATUS_TX_PAUSE	0x0008
+#define MII_M1011_PHY_SPEC_STATUS_RX_PAUSE	0x0004
+
+#endif /* __SUNGEM_PHY_H__ */
-- 
1.7.6
