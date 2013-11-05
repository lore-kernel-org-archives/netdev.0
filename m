From: Alistair Popple <alistair@popple.id.au>
Subject: [PATCH 3/7] IBM Akebono: Add support for a new PHY to the IBM emac driver
Date: Tue,  5 Nov 2013 16:31:07 +1100
Message-ID: <1383629471-16979-3-git-send-email-alistair@popple.id.au>
References: <1383629471-16979-1-git-send-email-alistair@popple.id.au>
Cc: Alistair Popple <alistair@popple.id.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:36297 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751874Ab3KEFbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 00:31:51 -0500
In-Reply-To: <1383629471-16979-1-git-send-email-alistair@popple.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IBM Akebono board uses a different ethernet PHY that has wake on
lan (WOL) support with the IBM emac. This patch adds suppot to the IBM
emac driver for this new PHY.

At this stage the wake on lan functionality has not been implemented.

Signed-off-by: Alistair Popple <alistair@popple.id.au>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 .../devicetree/bindings/powerpc/4xx/emac.txt       |    9 +
 drivers/net/ethernet/ibm/emac/Kconfig              |    4 +
 drivers/net/ethernet/ibm/emac/Makefile             |    1 +
 drivers/net/ethernet/ibm/emac/core.c               |   50 +++-
 drivers/net/ethernet/ibm/emac/core.h               |   12 +
 drivers/net/ethernet/ibm/emac/rgmii_wol.c          |  262 ++++++++++++++++++++
 drivers/net/ethernet/ibm/emac/rgmii_wol.h          |   62 +++++
 7 files changed, 394 insertions(+), 6 deletions(-)
 create mode 100644 drivers/net/ethernet/ibm/emac/rgmii_wol.c
 create mode 100644 drivers/net/ethernet/ibm/emac/rgmii_wol.h

diff --git a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt b/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
index 712baf6..9928d9d 100644
--- a/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
+++ b/Documentation/devicetree/bindings/powerpc/4xx/emac.txt
@@ -61,6 +61,8 @@
 			  Fox Axon: present, whatever value is appropriate for each
 			  EMAC, that is the content of the current (bogus) "phy-port"
 			  property.
+    - rgmii-wol-device  : 1 cell, required iff conntect to a RGMII in the WKUP
+                          power domain. phandle of the RGMII-WOL device node.
 
     Optional properties:
     - phy-address       : 1 cell, optional, MDIO address of the PHY. If absent,
@@ -146,3 +148,10 @@
 			   available.
 			   For Axon: 0x0000012a
 
+      iv) RGMII-WOL node
+
+    Required properties:
+    - compatible         : compatible list, containing 2 entries, first is
+			   "ibm,rgmii-wol-CHIP" where CHIP is the host ASIC (like
+			   EMAC) and the second is "ibm,rgmii-wol".
+    - reg                : <registers mapping>
diff --git a/drivers/net/ethernet/ibm/emac/Kconfig b/drivers/net/ethernet/ibm/emac/Kconfig
index 3f44a30..7425c27 100644
--- a/drivers/net/ethernet/ibm/emac/Kconfig
+++ b/drivers/net/ethernet/ibm/emac/Kconfig
@@ -55,6 +55,10 @@ config IBM_EMAC_RGMII
 	bool
 	default n
 
+config IBM_EMAC_RGMII_WOL
+	bool
+	default n
+
 config IBM_EMAC_TAH
 	bool
 	default n
diff --git a/drivers/net/ethernet/ibm/emac/Makefile b/drivers/net/ethernet/ibm/emac/Makefile
index eba2183..8843803 100644
--- a/drivers/net/ethernet/ibm/emac/Makefile
+++ b/drivers/net/ethernet/ibm/emac/Makefile
@@ -7,5 +7,6 @@ obj-$(CONFIG_IBM_EMAC) += ibm_emac.o
 ibm_emac-y := mal.o core.o phy.o
 ibm_emac-$(CONFIG_IBM_EMAC_ZMII) += zmii.o
 ibm_emac-$(CONFIG_IBM_EMAC_RGMII) += rgmii.o
+ibm_emac-$(CONFIG_IBM_EMAC_RGMII_WOL) += rgmii_wol.o
 ibm_emac-$(CONFIG_IBM_EMAC_TAH) += tah.o
 ibm_emac-$(CONFIG_IBM_EMAC_DEBUG) += debug.o
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 6b5c722..fc1a775 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -630,6 +630,8 @@ static int emac_configure(struct emac_instance *dev)
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII))
 		rgmii_set_speed(dev->rgmii_dev, dev->rgmii_port,
 				dev->phy.speed);
+	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII_WOL))
+		rgmii_wol_set_speed(dev->rgmii_wol_dev, dev->phy.speed);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII))
 		zmii_set_speed(dev->zmii_dev, dev->zmii_port, dev->phy.speed);
 
@@ -797,6 +799,8 @@ static int __emac_mdio_read(struct emac_instance *dev, u8 id, u8 reg)
 		zmii_get_mdio(dev->zmii_dev, dev->zmii_port);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII))
 		rgmii_get_mdio(dev->rgmii_dev, dev->rgmii_port);
+	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII_WOL))
+		rgmii_wol_get_mdio(dev->rgmii_wol_dev);
 
 	/* Wait for management interface to become idle */
 	n = 20;
@@ -844,6 +848,8 @@ static int __emac_mdio_read(struct emac_instance *dev, u8 id, u8 reg)
 	DBG2(dev, "mdio_read -> %04x" NL, r);
 	err = 0;
  bail:
+	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII_WOL))
+		rgmii_wol_put_mdio(dev->rgmii_wol_dev);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII))
 		rgmii_put_mdio(dev->rgmii_dev, dev->rgmii_port);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII))
@@ -869,6 +875,8 @@ static void __emac_mdio_write(struct emac_instance *dev, u8 id, u8 reg,
 		zmii_get_mdio(dev->zmii_dev, dev->zmii_port);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII))
 		rgmii_get_mdio(dev->rgmii_dev, dev->rgmii_port);
+	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII_WOL))
+		rgmii_wol_get_mdio(dev->rgmii_wol_dev);
 
 	/* Wait for management interface to be idle */
 	n = 20;
@@ -907,6 +915,8 @@ static void __emac_mdio_write(struct emac_instance *dev, u8 id, u8 reg,
 	}
 	err = 0;
  bail:
+	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII_WOL))
+		rgmii_wol_put_mdio(dev->rgmii_wol_dev);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII))
 		rgmii_put_mdio(dev->rgmii_dev, dev->rgmii_port);
 	if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII))
@@ -2275,10 +2285,11 @@ struct emac_depentry {
 #define	EMAC_DEP_MAL_IDX	0
 #define	EMAC_DEP_ZMII_IDX	1
 #define	EMAC_DEP_RGMII_IDX	2
-#define	EMAC_DEP_TAH_IDX	3
-#define	EMAC_DEP_MDIO_IDX	4
-#define	EMAC_DEP_PREV_IDX	5
-#define	EMAC_DEP_COUNT		6
+#define EMAC_DEP_RGMII_WOL_IDX  3
+#define	EMAC_DEP_TAH_IDX	4
+#define	EMAC_DEP_MDIO_IDX	5
+#define	EMAC_DEP_PREV_IDX	6
+#define	EMAC_DEP_COUNT		7
 
 static int emac_check_deps(struct emac_instance *dev,
 			   struct emac_depentry *deps)
@@ -2356,6 +2367,7 @@ static int emac_wait_deps(struct emac_instance *dev)
 	deps[EMAC_DEP_MAL_IDX].phandle = dev->mal_ph;
 	deps[EMAC_DEP_ZMII_IDX].phandle = dev->zmii_ph;
 	deps[EMAC_DEP_RGMII_IDX].phandle = dev->rgmii_ph;
+	deps[EMAC_DEP_RGMII_WOL_IDX].phandle = dev->rgmii_wol_ph;
 	if (dev->tah_ph)
 		deps[EMAC_DEP_TAH_IDX].phandle = dev->tah_ph;
 	if (dev->mdio_ph)
@@ -2378,6 +2390,7 @@ static int emac_wait_deps(struct emac_instance *dev)
 		dev->mal_dev = deps[EMAC_DEP_MAL_IDX].ofdev;
 		dev->zmii_dev = deps[EMAC_DEP_ZMII_IDX].ofdev;
 		dev->rgmii_dev = deps[EMAC_DEP_RGMII_IDX].ofdev;
+		dev->rgmii_wol_dev = deps[EMAC_DEP_RGMII_WOL_IDX].ofdev;
 		dev->tah_dev = deps[EMAC_DEP_TAH_IDX].ofdev;
 		dev->mdio_dev = deps[EMAC_DEP_MDIO_IDX].ofdev;
 	}
@@ -2583,6 +2596,8 @@ static int emac_init_config(struct emac_instance *dev)
 		dev->rgmii_ph = 0;
 	if (emac_read_uint_prop(np, "rgmii-channel", &dev->rgmii_port, 0))
 		dev->rgmii_port = 0xffffffff;
+	if (emac_read_uint_prop(np, "rgmii-wol-device", &dev->rgmii_wol_ph, 0))
+		dev->rgmii_wol_ph = 0;
 	if (emac_read_uint_prop(np, "fifo-entry-size", &dev->fifo_entry_size, 0))
 		dev->fifo_entry_size = 16;
 	if (emac_read_uint_prop(np, "mal-burst-size", &dev->mal_burst_size, 0))
@@ -2669,6 +2684,16 @@ static int emac_init_config(struct emac_instance *dev)
 #endif
 	}
 
+	if (dev->rgmii_wol_ph != 0) {
+#ifdef CONFIG_IBM_EMAC_RGMII_WOL
+		dev->features |= EMAC_FTR_HAS_RGMII_WOL;
+#else
+		printk(KERN_ERR "%s: RGMII WOL support not enabled !\n",
+		       np->full_name);
+		return -ENXIO;
+#endif
+	}
+
 	/* Read MAC-address */
 	p = of_get_property(np, "local-mac-address", NULL);
 	if (p == NULL) {
@@ -2842,10 +2867,15 @@ static int emac_probe(struct platform_device *ofdev)
 	    (err = rgmii_attach(dev->rgmii_dev, dev->rgmii_port, dev->phy_mode)) != 0)
 		goto err_detach_zmii;
 
+	/* Attach to RGMII_WOL, if needed */
+	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII_WOL) &&
+	    (err = rgmii_wol_attach(dev->rgmii_wol_dev, dev->phy_mode)) != 0)
+		goto err_detach_rgmii;
+
 	/* Attach to TAH, if needed */
 	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH) &&
 	    (err = tah_attach(dev->tah_dev, dev->tah_port)) != 0)
-		goto err_detach_rgmii;
+		goto err_detach_rgmii_wol;
 
 	/* Set some link defaults before we can find out real parameters */
 	dev->phy.speed = SPEED_100;
@@ -2918,6 +2948,9 @@ static int emac_probe(struct platform_device *ofdev)
  err_detach_tah:
 	if (emac_has_feature(dev, EMAC_FTR_HAS_TAH))
 		tah_detach(dev->tah_dev, dev->tah_port);
+ err_detach_rgmii_wol:
+	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII_WOL))
+		rgmii_wol_detach(dev->rgmii_wol_dev);
  err_detach_rgmii:
 	if (emac_has_feature(dev, EMAC_FTR_HAS_RGMII))
 		rgmii_detach(dev->rgmii_dev, dev->rgmii_port);
@@ -3079,12 +3112,17 @@ static int __init emac_init(void)
 	rc = tah_init();
 	if (rc)
 		goto err_rgmii;
-	rc = platform_driver_register(&emac_driver);
+	rc = rgmii_wol_init();
 	if (rc)
 		goto err_tah;
+	rc = platform_driver_register(&emac_driver);
+	if (rc)
+		goto err_rgmii_wol;
 
 	return 0;
 
+ err_rgmii_wol:
+	rgmii_wol_exit();
  err_tah:
 	tah_exit();
  err_rgmii:
diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index 7007479..930a6f6 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -43,6 +43,7 @@
 #include "phy.h"
 #include "zmii.h"
 #include "rgmii.h"
+#include "rgmii_wol.h"
 #include "mal.h"
 #include "tah.h"
 #include "debug.h"
@@ -210,6 +211,10 @@ struct emac_instance {
 	u32				rgmii_port;
 	struct platform_device		*rgmii_dev;
 
+	/* RGMII WOL infos if any */
+	u32				rgmii_wol_ph;
+	struct platform_device		*rgmii_wol_dev;
+
 	/* TAH infos if any */
 	u32				tah_ph;
 	u32				tah_port;
@@ -333,6 +338,10 @@ struct emac_instance {
  * APM821xx does not support Half Duplex mode
  */
 #define EMAC_FTR_APM821XX_NO_HALF_DUPLEX	0x00001000
+/*
+ * Set if we have a RGMII with wake on LAN.
+ */
+#define EMAC_FTR_HAS_RGMII_WOL		0x00020000
 
 /* Right now, we don't quite handle the always/possible masks on the
  * most optimal way as we don't have a way to say something like
@@ -356,6 +365,9 @@ enum {
 #ifdef CONFIG_IBM_EMAC_RGMII
 	    EMAC_FTR_HAS_RGMII	|
 #endif
+#ifdef CONFIG_IBM_EMAC_RGMII_WOL
+	    EMAC_FTR_HAS_RGMII_WOL	|
+#endif
 #ifdef CONFIG_IBM_EMAC_NO_FLOW_CTRL
 	    EMAC_FTR_NO_FLOW_CONTROL_40x |
 #endif
diff --git a/drivers/net/ethernet/ibm/emac/rgmii_wol.c b/drivers/net/ethernet/ibm/emac/rgmii_wol.c
new file mode 100644
index 0000000..8e0dcf6
--- /dev/null
+++ b/drivers/net/ethernet/ibm/emac/rgmii_wol.c
@@ -0,0 +1,262 @@
+/* drivers/net/ethernet/ibm/emac/rgmii_wol.c
+ *
+ * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge with
+ * wake on LAN support.
+ *
+ * Copyright 2013 Alistair Popple, IBM Corp.
+ *                <alistair@popple.id.au>
+ *
+ * Based on rgmii.h:
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+#include <linux/slab.h>
+#include <linux/kernel.h>
+#include <linux/ethtool.h>
+#include <linux/io.h>
+
+#include "emac.h"
+#include "debug.h"
+
+/* RGMII_WOL_REG */
+
+#define WKUP_ETH_RGSPD      0xC0000000
+#define WKUP_ETH_FCSEN      0x20000000
+#define WKUP_ETH_CRSEN      0x02000000
+#define WKUP_ETH_COLEN      0x01000000
+#define WKUP_ETH_TX_OE      0x00040000
+#define WKUP_ETH_RX_IE      0x00020000
+#define WKUP_ETH_RGMIIEN    0x00010000
+
+#define WKUP_ETH_RGSPD_10   0x00000000
+#define WKUP_ETH_RGSPD_100  0x40000000
+#define WKUP_ETH_RGSPD_1000 0x80000000
+
+/* RGMII bridge supports only GMII/TBI and RGMII/RTBI PHYs */
+static inline int rgmii_valid_mode(int phy_mode)
+{
+	return  phy_mode == PHY_MODE_GMII ||
+		phy_mode == PHY_MODE_MII ||
+		phy_mode == PHY_MODE_RGMII ||
+		phy_mode == PHY_MODE_TBI ||
+		phy_mode == PHY_MODE_RTBI;
+}
+
+static inline const char *rgmii_mode_name(int mode)
+{
+	switch (mode) {
+	case PHY_MODE_RGMII:
+		return "RGMII";
+	case PHY_MODE_TBI:
+		return "TBI";
+	case PHY_MODE_GMII:
+		return "GMII";
+	case PHY_MODE_MII:
+		return "MII";
+	case PHY_MODE_RTBI:
+		return "RTBI";
+	default:
+		BUG();
+	}
+}
+
+int rgmii_wol_attach(struct platform_device *ofdev, int mode)
+{
+	struct rgmii_wol_instance *dev = platform_get_drvdata(ofdev);
+
+	dev_dbg(&ofdev->dev, "attach\n");
+
+	/* Check if we need to attach to a RGMII */
+	if (!rgmii_valid_mode(mode)) {
+		dev_err(&ofdev->dev, "unsupported settings !\n");
+		return -ENODEV;
+	}
+
+	mutex_lock(&dev->lock);
+
+	/* Enable this input */
+	out_be32(dev->reg, in_be32(dev->reg) | WKUP_ETH_RGMIIEN
+		 | WKUP_ETH_TX_OE | WKUP_ETH_RX_IE);
+	dev_notice(&ofdev->dev, "in %s mode\n", rgmii_mode_name(mode));
+
+	++dev->users;
+
+	mutex_unlock(&dev->lock);
+
+	return 0;
+}
+
+void rgmii_wol_set_speed(struct platform_device *ofdev, int speed)
+{
+	struct rgmii_wol_instance *dev = platform_get_drvdata(ofdev);
+	u32 reg;
+
+	mutex_lock(&dev->lock);
+
+	reg = in_be32(dev->reg) & ~WKUP_ETH_RGSPD;
+
+	dev_dbg(&ofdev->dev, "speed(%d)\n", speed);
+
+	switch (speed) {
+	case SPEED_1000:
+		reg |= WKUP_ETH_RGSPD_1000;
+		break;
+	case SPEED_100:
+		reg |= WKUP_ETH_RGSPD_100;
+		break;
+	case SPEED_10:
+		reg |= WKUP_ETH_RGSPD_10;
+		break;
+	default:
+		dev_err(&ofdev->dev, "invalid speed set!\n");
+	}
+
+	out_be32(dev->reg, reg);
+
+	mutex_unlock(&dev->lock);
+}
+
+void rgmii_wol_get_mdio(struct platform_device *ofdev)
+{
+	/* MDIO is always enabled when RGMII_WOL is enabled, so we
+	 * don't have to do anything here.
+	 */
+	dev_dbg(&ofdev->dev, "get_mdio\n");
+}
+
+void rgmii_wol_put_mdio(struct platform_device *ofdev)
+{
+	dev_dbg(&ofdev->dev, "put_mdio\n");
+}
+
+void rgmii_wol_detach(struct platform_device *ofdev)
+{
+	struct rgmii_wol_instance *dev = platform_get_drvdata(ofdev);
+
+	BUG_ON(!dev || dev->users == 0);
+
+	mutex_lock(&dev->lock);
+
+	dev_dbg(&ofdev->dev, "detach\n");
+
+	/* Disable this input */
+	out_be32(dev->reg, 0);
+
+	--dev->users;
+
+	mutex_unlock(&dev->lock);
+}
+
+int rgmii_wol_get_regs_len(struct platform_device *ofdev)
+{
+	return sizeof(struct emac_ethtool_regs_subhdr) +
+		sizeof(u32);
+}
+
+void *rgmii_wol_dump_regs(struct platform_device *ofdev, void *buf)
+{
+	struct rgmii_wol_instance *dev = platform_get_drvdata(ofdev);
+	struct emac_ethtool_regs_subhdr *hdr = buf;
+	u32 *regs = (u32 *)(hdr + 1);
+
+	hdr->version = 0;
+	hdr->index = 0; /* for now, are there chips with more than one
+			 * rgmii ? if yes, then we'll add a cell_index
+			 * like we do for emac
+			 */
+	memcpy_fromio(regs, dev->reg, sizeof(u32));
+	return regs + 1;
+}
+
+
+static int rgmii_wol_probe(struct platform_device *ofdev)
+{
+	struct device_node *np = ofdev->dev.of_node;
+	struct rgmii_wol_instance *dev;
+	int rc;
+
+	rc = -ENOMEM;
+	dev = kzalloc(sizeof(struct rgmii_wol_instance), GFP_KERNEL);
+	if (dev == NULL)
+		goto err_gone;
+
+	mutex_init(&dev->lock);
+
+	dev->reg = of_iomap(np, 0);
+	if (!dev->reg) {
+		dev_err(&ofdev->dev, "Can't map registers\n");
+		rc = -ENXIO;
+		goto err_free;
+	}
+
+	/* Check for RGMII flags */
+	if (of_get_property(ofdev->dev.of_node, "has-mdio", NULL))
+		dev->flags |= EMAC_RGMII_FLAG_HAS_MDIO;
+
+	dev_dbg(&ofdev->dev, " Boot REG = 0x%08x\n", in_be32(dev->reg));
+
+	/* Disable all inputs by default */
+	out_be32(dev->reg, 0);
+
+	dev_info(&ofdev->dev,
+	       "RGMII %s initialized with%s MDIO support\n",
+	       ofdev->dev.of_node->full_name,
+	       (dev->flags & EMAC_RGMII_FLAG_HAS_MDIO) ? "" : "out");
+
+	wmb();
+	platform_set_drvdata(ofdev, dev);
+
+	return 0;
+
+ err_free:
+	kfree(dev);
+ err_gone:
+	return rc;
+}
+
+static int rgmii_wol_remove(struct platform_device *ofdev)
+{
+	struct rgmii_wol_instance *dev = platform_get_drvdata(ofdev);
+
+	WARN_ON(dev->users != 0);
+
+	iounmap(dev->reg);
+	kfree(dev);
+
+	return 0;
+}
+
+static struct of_device_id rgmii_wol_match[] = {
+	{
+		.compatible	= "ibm,rgmii-wol",
+	},
+	{
+		.type		= "emac-rgmii-wol",
+	},
+	{},
+};
+
+static struct platform_driver rgmii_wol_driver = {
+	.driver = {
+		.name = "emac-rgmii-wol",
+		.owner = THIS_MODULE,
+		.of_match_table = rgmii_wol_match,
+	},
+	.probe = rgmii_wol_probe,
+	.remove = rgmii_wol_remove,
+};
+
+int __init rgmii_wol_init(void)
+{
+	return platform_driver_register(&rgmii_wol_driver);
+}
+
+void rgmii_wol_exit(void)
+{
+	platform_driver_unregister(&rgmii_wol_driver);
+}
diff --git a/drivers/net/ethernet/ibm/emac/rgmii_wol.h b/drivers/net/ethernet/ibm/emac/rgmii_wol.h
new file mode 100644
index 0000000..44ce268
--- /dev/null
+++ b/drivers/net/ethernet/ibm/emac/rgmii_wol.h
@@ -0,0 +1,62 @@
+/* drivers/net/ethernet/ibm/emac/rgmii_wol.h
+ *
+ * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge with
+ * wake on LAN support.
+ *
+ * Copyright 2013 Alistair Popple, IBM Corp.
+ *                <alistair@popple.id.au>
+ *
+ * Based on rgmii.h:
+ * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
+ *                <benh@kernel.crashing.org>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+
+#ifndef __IBM_NEWEMAC_RGMII_WOL_H
+#define __IBM_NEWEMAC_RGMII_WOL_H
+
+/* RGMII device */
+struct rgmii_wol_instance {
+	u32 __iomem			*reg;
+
+	/* RGMII bridge flags */
+	int				flags;
+#define EMAC_RGMII_FLAG_HAS_MDIO	0x00000001
+
+	/* Only one EMAC whacks us at a time */
+	struct mutex			lock;
+
+	/* number of EMACs using this RGMII bridge */
+	int				users;
+};
+
+#ifdef CONFIG_IBM_EMAC_RGMII_WOL
+
+extern int rgmii_wol_init(void);
+extern void rgmii_wol_exit(void);
+extern int rgmii_wol_attach(struct platform_device *ofdev, int mode);
+extern void rgmii_wol_detach(struct platform_device *ofdev);
+extern void rgmii_wol_get_mdio(struct platform_device *ofdev);
+extern void rgmii_wol_put_mdio(struct platform_device *ofdev);
+extern void rgmii_wol_set_speed(struct platform_device *ofdev, int speed);
+extern int rgmii_wol_get_regs_len(struct platform_device *ofdev);
+extern void *rgmii_wol_dump_regs(struct platform_device *ofdev, void *buf);
+
+#else
+
+# define rgmii_wol_init()		0
+# define rgmii_wol_exit()		do { } while (0)
+# define rgmii_wol_attach(x, y, z)	(-ENXIO)
+# define rgmii_wol_detach(x, y)	do { } while (0)
+# define rgmii_wol_get_mdio(o, i)	do { } while (0)
+# define rgmii_wol_put_mdio(o, i)	do { } while (0)
+# define rgmii_wol_set_speed(x, y, z)	do { } while (0)
+# define rgmii_wol_get_regs_len(x)	0
+# define rgmii_wol_dump_regs(x, buf)	(buf)
+#endif				/* !CONFIG_IBM_EMAC_RGMII_WOL */
+
+#endif /* __IBM_NEWEMAC_RGMII_WOL_H */
-- 
1.7.10.4
