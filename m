From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/3] drivers: of: add phy fixup support in DT
Date: Mon, 22 Apr 2013 23:50:36 +0530
Message-ID: <1366654838-26479-2-git-send-email-mugunthanvnm@ti.com>
References: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:50202 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546Ab3DVSUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Apr 2013 14:20:52 -0400
In-Reply-To: <1366654838-26479-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In earlier case phy fixup are added in board file as this is no more the case
so adding support for phy register fixup in Device Tree

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 .../devicetree/bindings/net/phy-fixup.txt          |   26 ++++++
 drivers/of/of_net.c                                |   92 ++++++++++++++++++++
 include/linux/of_net.h                             |    6 ++
 3 files changed, 124 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/phy-fixup.txt

diff --git a/Documentation/devicetree/bindings/net/phy-fixup.txt b/Documentation/devicetree/bindings/net/phy-fixup.txt
new file mode 100644
index 0000000..460f76d
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/phy-fixup.txt
@@ -0,0 +1,26 @@
+Ethernet Phy fixup Device Tree Bindings
+---------------------------------------
+
+The following DT fields can be added to MDIO DT notes and can be used to
+add phy fix up needed
+
+Required properties:
+- phy-fixup-registers	: Will contain a array of register fix nodes which has
+			  the following node parameters
+- phy-id		: Specifies the phy id for which the fix belongs to
+- phy-mask		: Specifies the phy mask for which the fix belongs to
+- fixup-registers	: Specifies the fix up registers and values in array
+			  of offset value pair
+Optional properties:
+
+Examples:
+
+&davinci_mdio {
+	phy-fixup-registers = <&atheros_txclk_delay_fixup>;
+
+	atheros_txclk_delay_fixup: atheros_txclk_delay_fixup {
+		phy-id = <0x4dd074>;
+		phy-mask = <0xfffffffe>;
+		fixup-registers = <0x1d 0x5 0x1e 0x100>;
+	};
+};
diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
index ffab033..50ad671 100644
--- a/drivers/of/of_net.c
+++ b/drivers/of/of_net.c
@@ -10,6 +10,7 @@
 #include <linux/of_net.h>
 #include <linux/phy.h>
 #include <linux/export.h>
+#include <linux/of_net.h>
 
 /**
  * It maps 'enum phy_interface_t' found in include/linux/phy.h
@@ -92,3 +93,94 @@ const void *of_get_mac_address(struct device_node *np)
 	return NULL;
 }
 EXPORT_SYMBOL(of_get_mac_address);
+
+static int __of_phy_fixup_cb(struct phy_device *phydev)
+{
+	struct device_node *node = phydev->bus->parent->of_node;
+	struct device_node *phy_fixup_node;
+	const __be32 *parp;
+	int lenp;
+	int i, j;
+
+	parp = of_get_property(node, "phy-fixup-registers", &lenp);
+	if (parp == NULL)
+		return 0;
+	lenp /= sizeof(void *);
+
+	for (i = 0; i < lenp; i++) {
+		u32 phy_id;
+		const __be32 *fixups;
+		int fixup_len;
+
+		phy_fixup_node = of_find_node_by_phandle(be32_to_cpup(parp+i));
+		if (of_property_read_u32(phy_fixup_node, "phy-id", &phy_id)) {
+			pr_err("Missing PHY id in Phy fixup\n");
+			return -EINVAL;
+		}
+		if (phy_id != phydev->phy_id)
+			continue;
+
+		fixups = of_get_property(phy_fixup_node, "fixup-registers",
+					 &fixup_len);
+		if (fixups == NULL) {
+			pr_err("Missing fixup registers in Phy fixup\n");
+			return -EINVAL;
+		}
+		fixup_len /= sizeof(void *);
+		for (j = 0; j < fixup_len; j += 2) {
+			u16 regnum = be32_to_cpup(fixups + j);
+			u16 val = be32_to_cpup(fixups + j + 1);
+			phy_write(phydev, regnum, val);
+		}
+	}
+
+	return 0;
+}
+
+int of_add_phy_fixup_register(struct device_node *node)
+{
+	struct device_node *phy_fixup_node;
+	const __be32 *parp;
+	int lenp;
+	int i;
+
+	parp = of_get_property(node, "phy-fixup-registers", &lenp);
+	if (parp == NULL)
+		return 0;
+	lenp /= sizeof(void *);
+
+	for (i = 0; i < lenp; i++) {
+		u32 phy_id;
+		u32 phy_mask;
+		const __be32 *fixups;
+		int fixup_len;
+
+		phy_fixup_node = of_find_node_by_phandle(be32_to_cpup(parp+i));
+		if (of_property_read_u32(phy_fixup_node, "phy-id", &phy_id)) {
+			pr_err("Missing PHY id in Phy fixup\n");
+			continue;
+		}
+
+		if (of_property_read_u32(phy_fixup_node, "phy-mask",
+					 &phy_mask)) {
+			pr_err("Missing PHY mask in Phy fixup\n");
+			continue;
+		}
+
+		fixups = of_get_property(phy_fixup_node, "fixup-registers",
+					 &fixup_len);
+		if (fixups == NULL) {
+			pr_err("Missing fixup registers in Phy fixup\n");
+			continue;
+		}
+		fixup_len /= sizeof(void *);
+		if (fixup_len % 2) {
+			pr_err("Fixup registers length is invalid in Phy fixup\n");
+			continue;
+		}
+		phy_register_fixup_for_uid(phy_id, phy_mask, __of_phy_fixup_cb);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(of_add_phy_fixup_register);
diff --git a/include/linux/of_net.h b/include/linux/of_net.h
index 61bf53b..c690e38 100644
--- a/include/linux/of_net.h
+++ b/include/linux/of_net.h
@@ -11,6 +11,7 @@
 #include <linux/of.h>
 extern const int of_get_phy_mode(struct device_node *np);
 extern const void *of_get_mac_address(struct device_node *np);
+extern int of_add_phy_fixup_register(struct device_node *node);
 #else
 static inline const int of_get_phy_mode(struct device_node *np)
 {
@@ -21,6 +22,11 @@ static inline const void *of_get_mac_address(struct device_node *np)
 {
 	return NULL;
 }
+
+static int of_add_phy_fixup_register(struct device_node *node)
+{
+	return -ENODEV;
+}
 #endif
 
 #endif /* __LINUX_OF_NET_H */
-- 
1.7.9.5
