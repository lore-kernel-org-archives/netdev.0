From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 4/9] openfirmware: Add OF phylib support code
Date: Wed, 18 Mar 2009 23:00:33 -0600
Message-ID: <20090319050032.11320.37658.stgit@localhost.localdomain>
References: <20090319050015.11320.61641.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:12515 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbZCSFAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:00:36 -0400
Received: by wa-out-1112.google.com with SMTP id j5so245042wah.21
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:00:35 -0700 (PDT)
In-Reply-To: <20090319050015.11320.61641.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

Add support for parsing the device tree for PHY devices on an MDIO bus

CC: Andy Fleming <afleming@freescale.com>
CC: linuxppc-dev@ozlabs.org
CC: devtree-discuss@ozlabs.org

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/of/Kconfig      |    6 ++
 drivers/of/Makefile     |    1 
 drivers/of/of_mdio.c    |  130 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/of_mdio.h |   21 ++++++++
 4 files changed, 158 insertions(+), 0 deletions(-)
 create mode 100644 drivers/of/of_mdio.c
 create mode 100644 include/linux/of_mdio.h


diff --git a/drivers/of/Kconfig b/drivers/of/Kconfig
index f821dbc..6fe043b 100644
--- a/drivers/of/Kconfig
+++ b/drivers/of/Kconfig
@@ -19,3 +19,9 @@ config OF_SPI
 	depends on OF && PPC_OF && SPI
 	help
 	  OpenFirmware SPI accessors
+
+config OF_MDIO
+	def_tristate PHYLIB
+	depends on OF && PHYLIB
+	help
+	  OpenFirmware MDIO bus (Ethernet PHY) accessors
diff --git a/drivers/of/Makefile b/drivers/of/Makefile
index 4c3c6f8..bdfb5f5 100644
--- a/drivers/of/Makefile
+++ b/drivers/of/Makefile
@@ -3,3 +3,4 @@ obj-$(CONFIG_OF_DEVICE) += device.o platform.o
 obj-$(CONFIG_OF_GPIO)   += gpio.o
 obj-$(CONFIG_OF_I2C)	+= of_i2c.o
 obj-$(CONFIG_OF_SPI)	+= of_spi.o
+obj-$(CONFIG_OF_MDIO)	+= of_mdio.o
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
new file mode 100644
index 0000000..6f3038a
--- /dev/null
+++ b/drivers/of/of_mdio.c
@@ -0,0 +1,130 @@
+/*
+ * OF helpers for the MDIO (Ethernet PHY) API
+ *
+ * Copyright (c) 2009 Secret Lab Technologies, Ltd.
+ *
+ * This file is released under the GPLv2
+ *
+ * This file provides helper functions for extracting PHY device information
+ * out of the OpenFirmware device tree and using it to populate an mii_bus.
+ */
+
+#include <linux/phy.h>
+#include <linux/of.h>
+#include <linux/of_mdio.h>
+#include <linux/module.h>
+
+MODULE_AUTHOR("Grant Likely <grant.likely@secretlab.ca>");
+MODULE_LICENSE("GPL");
+
+/**
+ * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
+ * @mdio: pointer to mii_bus structure
+ * @np: pointer to device_node of MDIO bus.
+ *
+ * This function registers the mii_bus structure and registers a phy_device
+ * for each child node of @np.
+ */
+int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
+{
+	struct phy_device *phy;
+	struct device_node *child;
+	int rc, i;
+
+	/* Mask out all PHYs from auto probing.  Instead the PHYs listed in
+	 * the device tree are populated after the bus has been registered */
+	mdio->phy_mask = ~0;
+
+	/* Clear all the IRQ properties */
+	if (mdio->irq)
+		for (i=0; i<PHY_MAX_ADDR; i++)
+			mdio->irq[i] = PHY_POLL;
+
+	/* Register the MDIO bus */
+	rc = mdiobus_register(mdio);
+	if (rc)
+		return rc;
+
+	/* Loop over the child nodes and register a phy_device for each one */
+	for_each_child_of_node(np, child) {
+		const u32 *addr;
+		int len;
+
+		/* A PHY must have a reg property in the range [0-31] */
+		addr = of_get_property(child, "reg", &len);
+		if (!addr || len < sizeof(*addr) || *addr >= 32 || *addr < 0) {
+			dev_err(&mdio->dev, "%s has invalid PHY address\n",
+				child->full_name);
+			continue;
+		}
+
+		if (mdio->irq) {
+			mdio->irq[*addr] = irq_of_parse_and_map(child, 0);
+			if (!mdio->irq[*addr])
+				mdio->irq[*addr] = PHY_POLL;
+		}
+
+		phy = get_phy_device(mdio, *addr);
+		if (!phy) {
+			dev_err(&mdio->dev, "error probing PHY at address %i\n",
+				*addr);
+			continue;
+		}
+		phy_scan_fixups(phy);
+
+		/* Associate the OF node with the device structure so it
+		 * can be looked up later */
+		of_node_get(child);
+		dev_archdata_set_node(&phy->dev.archdata, child);
+
+		/* All data is now stored in the phy struct; register it */
+		rc = phy_device_register(phy);
+		if (rc) {
+			phy_device_free(phy);
+			of_node_put(child);
+			continue;
+		}
+
+		dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
+			child->name, *addr);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(of_mdiobus_register);
+
+/**
+ * of_phy_connect - Connect to the phy described in the device tree
+ * @dev: pointer to net_device claiming the phy
+ * @phy_np: Pointer to device tree node for the PHY
+ * @hndlr: Link state callback for the network device
+ * @iface: PHY data interface type
+ *
+ * Returns a pointer to the phy_device if successfull.  NULL otherwise
+ */
+struct phy_device *of_phy_connect(struct net_device *dev,
+				  struct device_node *phy_np,
+				  void (*hndlr)(struct net_device *), u32 flags,
+				  phy_interface_t iface)
+{
+	int match(struct device *dev, void *phy_np)
+	{
+		return dev_archdata_get_node(&dev->archdata) == phy_np;
+	}
+	struct device *d;
+	int rc;
+
+	if (!phy_np)
+		return NULL;
+
+	d = bus_find_device(&mdio_bus_type, NULL, phy_np, match);
+	if (!d)
+		return NULL;
+
+	rc = phy_connect_direct(dev, to_phy_device(d), hndlr, flags, iface);
+	if (rc)
+		return NULL;
+
+	return to_phy_device(d);
+}
+EXPORT_SYMBOL(of_phy_connect);
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
new file mode 100644
index 0000000..ec092cc
--- /dev/null
+++ b/include/linux/of_mdio.h
@@ -0,0 +1,21 @@
+/*
+ * OF helpers for the MDIO (Ethernet PHY) API
+ *
+ * Copyright (c) 2009 Secret Lab Technologies, Ltd.
+ *
+ * This file is released under the GPLv2
+ */
+
+#ifndef __LINUX_OF_MDIO_H
+#define __LINUX_OF_MDIO_H
+
+#include <linux/phy.h>
+#include <linux/of.h>
+
+extern int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np);
+extern struct phy_device *of_phy_connect(struct net_device *dev,
+					 struct device_node *phy_np,
+					 void (*hndlr)(struct net_device *),
+					 u32 flags, phy_interface_t iface);
+
+#endif /* __LINUX_OF_MDIO_H */

