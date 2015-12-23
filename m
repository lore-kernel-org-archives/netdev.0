From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 04/28] dsa: Rename mv88e6123_61_65 to mv88e6123 to be consistent
Date: Wed, 23 Dec 2015 13:56:18 +0100
Message-ID: <1450875402-20740-5-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48672 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755444AbbLWM5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:17 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the drivers support multiple chips, but mv88e6123_61_65 is the
only one that reflects this in its naming. Change it to be consistent
with the other drivers.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/Kconfig           |   2 +-
 drivers/net/dsa/Makefile          |   4 +-
 drivers/net/dsa/mv88e6123.c       | 124 ++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6123_61_65.c | 124 --------------------------------------
 drivers/net/dsa/mv88e6xxx.c       |   4 +-
 drivers/net/dsa/mv88e6xxx.h       |   2 +-
 6 files changed, 130 insertions(+), 130 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6123.c
 delete mode 100644 drivers/net/dsa/mv88e6123_61_65.c

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 4c483d937481..90ba003d8fdf 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -27,7 +27,7 @@ config NET_DSA_MV88E6131
 	  This enables support for the Marvell 88E6085/6095/6095F/6131
 	  ethernet switch chips.
 
-config NET_DSA_MV88E6123_61_65
+config NET_DSA_MV88E6123
 	tristate "Marvell 88E6123/6161/6165 ethernet switch chip support"
 	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
diff --git a/drivers/net/dsa/Makefile b/drivers/net/dsa/Makefile
index e2d51c4b9382..a6e09939be65 100644
--- a/drivers/net/dsa/Makefile
+++ b/drivers/net/dsa/Makefile
@@ -1,8 +1,8 @@
 obj-$(CONFIG_NET_DSA_MV88E6060) += mv88e6060.o
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx_drv.o
 mv88e6xxx_drv-y += mv88e6xxx.o
-ifdef CONFIG_NET_DSA_MV88E6123_61_65
-mv88e6xxx_drv-y += mv88e6123_61_65.o
+ifdef CONFIG_NET_DSA_MV88E6123
+mv88e6xxx_drv-y += mv88e6123.o
 endif
 ifdef CONFIG_NET_DSA_MV88E6131
 mv88e6xxx_drv-y += mv88e6131.o
diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
new file mode 100644
index 000000000000..69a6f79dcb10
--- /dev/null
+++ b/drivers/net/dsa/mv88e6123.c
@@ -0,0 +1,124 @@
+/*
+ * net/dsa/mv88e6123_61_65.c - Marvell 88e6123/6161/6165 switch chip support
+ * Copyright (c) 2008-2009 Marvell Semiconductor
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/delay.h>
+#include <linux/jiffies.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <net/dsa.h>
+#include "mv88e6xxx.h"
+
+static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
+	{ PORT_SWITCH_ID_6123, "Marvell 88E6123" },
+	{ PORT_SWITCH_ID_6123_A1, "Marvell 88E6123 (A1)" },
+	{ PORT_SWITCH_ID_6123_A2, "Marvell 88E6123 (A2)" },
+	{ PORT_SWITCH_ID_6161, "Marvell 88E6161" },
+	{ PORT_SWITCH_ID_6161_A1, "Marvell 88E6161 (A1)" },
+	{ PORT_SWITCH_ID_6161_A2, "Marvell 88E6161 (A2)" },
+	{ PORT_SWITCH_ID_6165, "Marvell 88E6165" },
+	{ PORT_SWITCH_ID_6165_A1, "Marvell 88E6165 (A1)" },
+	{ PORT_SWITCH_ID_6165_A2, "Marvell 88e6165 (A2)" },
+};
+
+static char *mv88e6123_probe(struct device *host_dev, int sw_addr)
+{
+	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6123_table,
+				     ARRAY_SIZE(mv88e6123_table));
+}
+
+static int mv88e6123_setup_global(struct dsa_switch *ds)
+{
+	u32 upstream_port = dsa_upstream_port(ds);
+	int ret;
+	u32 reg;
+
+	ret = mv88e6xxx_setup_global(ds);
+	if (ret)
+		return ret;
+
+	/* Disable the PHY polling unit (since there won't be any
+	 * external PHYs to poll), don't discard packets with
+	 * excessive collisions, and mask all interrupt sources.
+	 */
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL, 0x0000);
+
+	/* Configure the upstream port, and configure the upstream
+	 * port as the port to which ingress and egress monitor frames
+	 * are to be sent.
+	 */
+	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
+	REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
+
+	/* Disable remote management for now, and set the switch's
+	 * DSA device number.
+	 */
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL_2, ds->index & 0x1f);
+
+	return 0;
+}
+
+static int mv88e6123_setup(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	ret = mv88e6xxx_setup_common(ds);
+	if (ret < 0)
+		return ret;
+
+	switch (ps->id) {
+	case PORT_SWITCH_ID_6123:
+		ps->num_ports = 3;
+		break;
+	case PORT_SWITCH_ID_6161:
+	case PORT_SWITCH_ID_6165:
+		ps->num_ports = 6;
+		break;
+	default:
+		return -ENODEV;
+	}
+
+	ret = mv88e6xxx_switch_reset(ds, false);
+	if (ret < 0)
+		return ret;
+
+	ret = mv88e6123_setup_global(ds);
+	if (ret < 0)
+		return ret;
+
+	return mv88e6xxx_setup_ports(ds);
+}
+
+struct dsa_switch_driver mv88e6123_switch_driver = {
+	.tag_protocol		= DSA_TAG_PROTO_EDSA,
+	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
+	.probe			= mv88e6123_probe,
+	.setup			= mv88e6123_setup,
+	.set_addr		= mv88e6xxx_set_addr_indirect,
+	.phy_read		= mv88e6xxx_phy_read,
+	.phy_write		= mv88e6xxx_phy_write,
+	.get_strings		= mv88e6xxx_get_strings,
+	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
+	.get_sset_count		= mv88e6xxx_get_sset_count,
+	.adjust_link		= mv88e6xxx_adjust_link,
+#ifdef CONFIG_NET_DSA_HWMON
+	.get_temp		= mv88e6xxx_get_temp,
+#endif
+	.get_regs_len		= mv88e6xxx_get_regs_len,
+	.get_regs		= mv88e6xxx_get_regs,
+};
+
+MODULE_ALIAS("platform:mv88e6123");
+MODULE_ALIAS("platform:mv88e6161");
+MODULE_ALIAS("platform:mv88e6165");
diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
deleted file mode 100644
index d4fcf4570d95..000000000000
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ /dev/null
@@ -1,124 +0,0 @@
-/*
- * net/dsa/mv88e6123_61_65.c - Marvell 88e6123/6161/6165 switch chip support
- * Copyright (c) 2008-2009 Marvell Semiconductor
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#include <linux/delay.h>
-#include <linux/jiffies.h>
-#include <linux/list.h>
-#include <linux/module.h>
-#include <linux/netdevice.h>
-#include <linux/phy.h>
-#include <net/dsa.h>
-#include "mv88e6xxx.h"
-
-static const struct mv88e6xxx_switch_id mv88e6123_61_65_table[] = {
-	{ PORT_SWITCH_ID_6123, "Marvell 88E6123" },
-	{ PORT_SWITCH_ID_6123_A1, "Marvell 88E6123 (A1)" },
-	{ PORT_SWITCH_ID_6123_A2, "Marvell 88E6123 (A2)" },
-	{ PORT_SWITCH_ID_6161, "Marvell 88E6161" },
-	{ PORT_SWITCH_ID_6161_A1, "Marvell 88E6161 (A1)" },
-	{ PORT_SWITCH_ID_6161_A2, "Marvell 88E6161 (A2)" },
-	{ PORT_SWITCH_ID_6165, "Marvell 88E6165" },
-	{ PORT_SWITCH_ID_6165_A1, "Marvell 88E6165 (A1)" },
-	{ PORT_SWITCH_ID_6165_A2, "Marvell 88e6165 (A2)" },
-};
-
-static char *mv88e6123_61_65_probe(struct device *host_dev, int sw_addr)
-{
-	return mv88e6xxx_lookup_name(host_dev, sw_addr, mv88e6123_61_65_table,
-				     ARRAY_SIZE(mv88e6123_61_65_table));
-}
-
-static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
-{
-	u32 upstream_port = dsa_upstream_port(ds);
-	int ret;
-	u32 reg;
-
-	ret = mv88e6xxx_setup_global(ds);
-	if (ret)
-		return ret;
-
-	/* Disable the PHY polling unit (since there won't be any
-	 * external PHYs to poll), don't discard packets with
-	 * excessive collisions, and mask all interrupt sources.
-	 */
-	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL, 0x0000);
-
-	/* Configure the upstream port, and configure the upstream
-	 * port as the port to which ingress and egress monitor frames
-	 * are to be sent.
-	 */
-	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
-		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
-	REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
-
-	/* Disable remote management for now, and set the switch's
-	 * DSA device number.
-	 */
-	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL_2, ds->index & 0x1f);
-
-	return 0;
-}
-
-static int mv88e6123_61_65_setup(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	ret = mv88e6xxx_setup_common(ds);
-	if (ret < 0)
-		return ret;
-
-	switch (ps->id) {
-	case PORT_SWITCH_ID_6123:
-		ps->num_ports = 3;
-		break;
-	case PORT_SWITCH_ID_6161:
-	case PORT_SWITCH_ID_6165:
-		ps->num_ports = 6;
-		break;
-	default:
-		return -ENODEV;
-	}
-
-	ret = mv88e6xxx_switch_reset(ds, false);
-	if (ret < 0)
-		return ret;
-
-	ret = mv88e6123_61_65_setup_global(ds);
-	if (ret < 0)
-		return ret;
-
-	return mv88e6xxx_setup_ports(ds);
-}
-
-struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
-	.tag_protocol		= DSA_TAG_PROTO_EDSA,
-	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
-	.probe			= mv88e6123_61_65_probe,
-	.setup			= mv88e6123_61_65_setup,
-	.set_addr		= mv88e6xxx_set_addr_indirect,
-	.phy_read		= mv88e6xxx_phy_read,
-	.phy_write		= mv88e6xxx_phy_write,
-	.get_strings		= mv88e6xxx_get_strings,
-	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
-	.get_sset_count		= mv88e6xxx_get_sset_count,
-	.adjust_link		= mv88e6xxx_adjust_link,
-#ifdef CONFIG_NET_DSA_HWMON
-	.get_temp		= mv88e6xxx_get_temp,
-#endif
-	.get_regs_len		= mv88e6xxx_get_regs_len,
-	.get_regs		= mv88e6xxx_get_regs,
-};
-
-MODULE_ALIAS("platform:mv88e6123");
-MODULE_ALIAS("platform:mv88e6161");
-MODULE_ALIAS("platform:mv88e6165");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 75e245c4235e..529273676d36 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2640,8 +2640,8 @@ static int __init mv88e6xxx_init(void)
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
 	register_switch_driver(&mv88e6131_switch_driver);
 #endif
-#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123_61_65)
-	register_switch_driver(&mv88e6123_61_65_switch_driver);
+#if IS_ENABLED(CONFIG_NET_DSA_MV88E6123)
+	register_switch_driver(&mv88e6123_switch_driver);
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6352)
 	register_switch_driver(&mv88e6352_switch_driver);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 21c8daa03f78..9e5c56800b7b 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -498,7 +498,7 @@ int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 			     int reg, int val);
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
-extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
+extern struct dsa_switch_driver mv88e6123_switch_driver;
 extern struct dsa_switch_driver mv88e6352_switch_driver;
 extern struct dsa_switch_driver mv88e6171_switch_driver;
 
-- 
2.6.3
