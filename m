From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH v2 1/4] of/mdio: Add support function for Ethernet fixed-link
	property
Date: Fri, 17 Jul 2009 01:31:31 -0600
Message-ID: <20090717073131.15652.83355.stgit@localhost.localdomain>
References: <20090717065220.15652.93331.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com
To: avorontsov@ru.mvista.com, davem@davemloft.net,
	afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f185.google.com ([209.85.216.185]:58828 "EHLO
	mail-px0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934153AbZGQHbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 03:31:35 -0400
Received: by pxi15 with SMTP id 15so444558pxi.33
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 00:31:33 -0700 (PDT)
In-Reply-To: <20090717065220.15652.93331.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>

Fixed-link support is broken for the ucc_eth, gianfar, and fs_enet
device drivers.  The "OF MDIO rework" patches removed most of the
support. Instead of re-adding fixed-link stuff to the drivers, this
patch adds a support function for parsing the fixed-link property
and obtaining a dummy phy to match.

Note: the dummy phy handling in arch/powerpc is a bit of a hack and
needs to be reworked.  This function is being added now to solve the
regression in the Ethernet drivers, but it should be considered a
temporary measure until the fixed link handling can be reworked.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/of/of_mdio.c    |   42 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/of_mdio.h |    3 +++
 2 files changed, 45 insertions(+), 0 deletions(-)


diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index aee967d..bacaa53 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -9,6 +9,10 @@
  * out of the OpenFirmware device tree and using it to populate an mii_bus.
  */
 
+#include <linux/kernel.h>
+#include <linux/device.h>
+#include <linux/netdevice.h>
+#include <linux/err.h>
 #include <linux/phy.h>
 #include <linux/of.h>
 #include <linux/of_mdio.h>
@@ -137,3 +141,41 @@ struct phy_device *of_phy_connect(struct net_device *dev,
 	return phy_connect_direct(dev, phy, hndlr, flags, iface) ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_connect);
+
+/**
+ * of_phy_connect_fixed_link - Parse fixed-link property and return a dummy phy
+ * @dev: pointer to net_device claiming the phy
+ * @hndlr: Link state callback for the network device
+ * @iface: PHY data interface type
+ *
+ * This function is a temporary stop-gap and will be removed soon.  It is
+ * only to support the fs_enet, ucc_geth and gianfar Ethernet drivers.  Do
+ * not call this function from new drivers.
+ */
+struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
+					     void (*hndlr)(struct net_device *),
+					     phy_interface_t iface)
+{
+	struct device_node *net_np;
+	char bus_id[MII_BUS_ID_SIZE + 3];
+	struct phy_device *phy;
+	const u32 *phy_id;
+	int sz;
+
+	if (!dev->dev.parent)
+		return NULL;
+
+	net_np = dev_archdata_get_node(&dev->dev.parent->archdata);
+	if (!net_np)
+		return NULL;
+
+	phy_id = of_get_property(net_np, "fixed-link", &sz);
+	if (!phy_id || sz < sizeof(*phy_id))
+		return NULL;
+
+	sprintf(bus_id, PHY_ID_FMT, "0", phy_id[0]);
+
+	phy = phy_connect(dev, bus_id, hndlr, 0, iface);
+	return IS_ERR(phy) ? NULL : phy;
+}
+EXPORT_SYMBOL(of_phy_connect_fixed_link);
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index c9663c6..53b94e0 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -18,5 +18,8 @@ extern struct phy_device *of_phy_connect(struct net_device *dev,
 					 struct device_node *phy_np,
 					 void (*hndlr)(struct net_device *),
 					 u32 flags, phy_interface_t iface);
+extern struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
+					 void (*hndlr)(struct net_device *),
+					 phy_interface_t iface);
 
 #endif /* __LINUX_OF_MDIO_H */

