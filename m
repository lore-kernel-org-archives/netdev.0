From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 4/5] openfirmware: Add OF phylib support code
Date: Tue, 10 Mar 2009 09:22:19 -0600
Message-ID: <20090310152218.12455.93700.stgit@localhost.localdomain>
References: <20090310150751.12455.70598.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: afleming@freescale.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:46896 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755868AbZCJPWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 11:22:22 -0400
In-Reply-To: <20090310150751.12455.70598.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

Add support for parsing the device tree for PHY devices on an MDIO bus

CC: Andy Fleming <afleming@freescale.com>
CC: linuxppc-dev@ozlabs.org
CC: devtree-discuss@ozlabs.org

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/of/Kconfig      |    6 ++++
 drivers/of/Makefile     |    1 +
 drivers/of/of_mdio.c    |   70 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/of_mdio.h |   20 +++++++++++++
 4 files changed, 97 insertions(+), 0 deletions(-)
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
index 0000000..6a7d4b2
--- /dev/null
+++ b/drivers/of/of_mdio.c
@@ -0,0 +1,70 @@
+/*
+ * OF helpers for the MDIO (Ethernet PHY) API
+ *
+ * Copyright (c) 2009 Secret Lab Technologies, Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
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
+void of_register_phy_devices(struct mii_bus *mdio, struct device_node *np)
+{
+	struct phy_device *phy;
+	struct device_node *child;
+	int rc;
+
+	for_each_child_of_node(np, child) {
+		const u32 *addr;
+		int len;
+
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
+}
+EXPORT_SYMBOL(of_register_phy_devices);
+
+MODULE_LICENSE("GPL");
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
new file mode 100644
index 0000000..9ea9745
--- /dev/null
+++ b/include/linux/of_mdio.h
@@ -0,0 +1,20 @@
+/*
+ * OF helpers for the MDIO (Ethernet PHY) API
+ *
+ * Copyright (c) 2009 Secret Lab Technologies, Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_OF_MDIO_H
+#define __LINUX_OF_MDIO_H
+
+#include <linux/phy.h>
+#include <linux/of.h>
+
+void of_register_phy_devices(struct mii_bus *mdio, struct device_node *np);
+
+#endif /* __LINUX_OF_MDIO_H */

