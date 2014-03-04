From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 3/4] of: provide a binding for fixed link PHYs
Date: Tue,  4 Mar 2014 11:58:23 +0100
Message-ID: <1393930704-24374-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:40120 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756631AbaCDK6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 05:58:30 -0500
In-Reply-To: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet MACs have a "fixed link", and are not connected to a
normal MDIO-managed PHY device. For those situations, a Device Tree
binding allows to describe a "fixed link" using a special PHY node.

This patch adds:

 * A documentation for the fixed PHY Device Tree binding.

 * An of_phy_is_fixed_link() function that an Ethernet driver can call
   on its PHY phandle to find out whether it's a fixed link PHY or
   not. It should typically be used to know if
   of_phy_register_fixed_link() should be called.

 * An of_phy_register_fixed_link() function that instantiates the
   fixed PHY into the PHY subsystem, so that when the driver calls
   of_phy_connect(), the PHY device associated to the OF node will be
   found.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 .../devicetree/bindings/net/fixed-link.txt         | 34 ++++++++++++++++++++++
 drivers/of/of_mdio.c                               | 24 +++++++++++++++
 include/linux/of_mdio.h                            | 15 ++++++++++
 3 files changed, 73 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/fixed-link.txt

diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
new file mode 100644
index 0000000..9f2a1a50
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/fixed-link.txt
@@ -0,0 +1,34 @@
+Fixed link Device Tree binding
+------------------------------
+
+Some Ethernet MACs have a "fixed link", and are not connected to a
+normal MDIO-managed PHY device. For those situations, a Device Tree
+binding allows to describe a "fixed link".
+
+Such a fixed link situation is described by creating a PHY node as a
+sub-node of an Ethernet device, with the following properties:
+
+* 'fixed-link' (boolean, mandatory), to indicate that this PHY is a
+  fixed link PHY.
+* 'speed' (integer, mandatory), to indicate the link speed. Accepted
+  values are 10, 100 and 1000
+* 'full-duplex' (boolean, optional), to indicate that full duplex is
+  used. When absent, half duplex is assumed.
+* 'pause' (boolean, optional), to indicate that pause should be
+  enabled.
+* 'asym-pause' (boolean, optional), to indicate that asym_pause should
+  be enabled.
+
+Example:
+
+ethernet@0 {
+	...
+	phy = <&phy0>;
+	phy0: phy@0 {
+	      fixed-link;
+	      speed = <1000>;
+	      full-duplex;
+	};
+	...
+};
+
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 875b7b6..c645fb8 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -14,6 +14,7 @@
 #include <linux/netdevice.h>
 #include <linux/err.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <linux/of.h>
 #include <linux/of_irq.h>
 #include <linux/of_mdio.h>
@@ -274,3 +275,26 @@ struct phy_device *of_phy_attach(struct net_device *dev,
 	return phy_attach_direct(dev, phy, flags, iface) ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_attach);
+
+#if defined(CONFIG_FIXED_PHY)
+bool of_phy_is_fixed_link(struct device_node *np)
+{
+	return of_property_read_bool(np, "fixed-link");
+}
+EXPORT_SYMBOL(of_phy_is_fixed_link);
+
+int of_phy_register_fixed_link(struct device_node *np)
+{
+	struct fixed_phy_status status = {};
+
+	status.link = 1;
+	status.duplex = of_property_read_bool(np, "full-duplex");
+	if (of_property_read_u32(np, "speed", &status.speed))
+		return -EINVAL;
+	status.pause = of_property_read_bool(np, "pause");
+	status.asym_pause = of_property_read_bool(np, "asym-pause");
+
+	return fixed_phy_register(PHY_POLL, &status, np);
+}
+EXPORT_SYMBOL(of_phy_register_fixed_link);
+#endif
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 6fe8464..77a6e32 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -67,4 +67,19 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
 }
 #endif /* CONFIG_OF */
 
+#if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
+extern int of_phy_register_fixed_link(struct device_node *np);
+extern bool of_phy_is_fixed_link(struct device_node *np);
+#else
+static inline int of_phy_register_fixed_link(struct device_node *np)
+{
+	return -ENOSYS;
+}
+static inline bool of_phy_is_fixed_link(struct device_node *np)
+{
+	return false;
+}
+#endif
+
+
 #endif /* __LINUX_OF_MDIO_H */
-- 
1.8.3.2
