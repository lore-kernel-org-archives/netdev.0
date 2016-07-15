From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH v1 2/3] of_mdio: Abstract a general interface for phy connect
Date: Fri, 15 Jul 2016 16:26:34 +0800
Message-ID: <1468571195-59763-3-git-send-email-lidongpo@hisilicon.com>
References: <1468571195-59763-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
	<howell.yang@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Dongpo Li <lidongpo@hisilicon.com>
To: <f.fainelli@gmail.com>, <robh+dt@kernel.org>,
	<mark.rutland@arm.com>, <frowand.list@gmail.com>,
	<davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468571195-59763-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Abstract a general interface "of_phy_get_and_connect"
for PHY connect. User will have no bother with getting
"phy-mode" and "phy-handle" any more.

Suggested-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
Reviewed-by: Jiancheng Xue <xuejiancheng@hisilicon.com>
---
 drivers/of/of_mdio.c    | 36 ++++++++++++++++++++++++++++++++++++
 include/linux/of_mdio.h | 10 ++++++++++
 2 files changed, 46 insertions(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index e051e1b..1e93f0a 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -19,6 +19,7 @@
 #include <linux/of_gpio.h>
 #include <linux/of_irq.h>
 #include <linux/of_mdio.h>
+#include <linux/of_net.h>
 #include <linux/module.h>
 
 MODULE_AUTHOR("Grant Likely <grant.likely@secretlab.ca>");
@@ -332,6 +333,41 @@ struct phy_device *of_phy_connect(struct net_device *dev,
 EXPORT_SYMBOL(of_phy_connect);
 
 /**
+ * of_phy_get_and_connect
+ * - Get phy node and connect to the phy described in the device tree
+ * @dev: pointer to net_device claiming the phy
+ * @np: Pointer to device tree node for the net_device claiming the phy
+ * @hndlr: Link state callback for the network device
+ *
+ * If successful, returns a pointer to the phy_device with the embedded
+ * struct device refcount incremented by one, or NULL on failure. The
+ * refcount must be dropped by calling phy_disconnect() or phy_detach().
+ */
+struct phy_device *of_phy_get_and_connect(struct net_device *dev,
+					  struct device_node *np,
+					  void (*hndlr)(struct net_device *))
+{
+	phy_interface_t iface;
+	struct device_node *phy_np;
+	struct phy_device *phy;
+
+	iface = of_get_phy_mode(np);
+	if (iface < 0)
+		return NULL;
+
+	phy_np = of_parse_phandle(np, "phy-handle", 0);
+	if (!phy_np)
+		return NULL;
+
+	phy = of_phy_connect(dev, phy_np, hndlr, 0, iface);
+
+	of_node_put(phy_np);
+
+	return phy;
+}
+EXPORT_SYMBOL(of_phy_get_and_connect);
+
+/**
  * of_phy_attach - Attach to a PHY without starting the state machine
  * @dev: pointer to net_device claiming the phy
  * @phy_np: Node pointer for the PHY
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 8f2237e..6c4d7a6 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -19,6 +19,9 @@ extern struct phy_device *of_phy_connect(struct net_device *dev,
 					 struct device_node *phy_np,
 					 void (*hndlr)(struct net_device *),
 					 u32 flags, phy_interface_t iface);
+extern struct phy_device *
+of_phy_get_and_connect(struct net_device *dev, struct device_node *np,
+		       void (*hndlr)(struct net_device *));
 struct phy_device *of_phy_attach(struct net_device *dev,
 				 struct device_node *phy_np, u32 flags,
 				 phy_interface_t iface);
@@ -50,6 +53,13 @@ static inline struct phy_device *of_phy_connect(struct net_device *dev,
 	return NULL;
 }
 
+static inline struct phy_device *
+of_phy_get_and_connect(struct net_device *dev, struct device_node *np,
+		       void (*hndlr)(struct net_device *))
+{
+	return NULL;
+}
+
 static inline struct phy_device *of_phy_attach(struct net_device *dev,
 					       struct device_node *phy_np,
 					       u32 flags, phy_interface_t iface)
-- 
2.8.2
