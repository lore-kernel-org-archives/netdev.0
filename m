From: Madalin Bucur <madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: [PATCH RFC 1/2] of: separate fixed link parsing from registration
Date: Wed, 5 Aug 2015 17:42:24 +0300
Message-ID: <1438785745-15517-2-git-send-email-madalin.bucur@freescale.com>
References: <1438785745-15517-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<Igal.Liberman-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Madalin Bucur <madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1438785745-15517-1-git-send-email-madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some drivers may need to parse the fixed link values before registering
the fixed link phy or access the status values. Separate the parsing from
the actual registration and provide an export for the added parsing function.

Signed-off-by: Madalin Bucur <madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
---
 drivers/of/of_mdio.c    | 52 +++++++++++++++++++++++++++++++------------------
 include/linux/of_mdio.h |  9 +++++++++
 2 files changed, 42 insertions(+), 19 deletions(-)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index fdc60db..b7e8288 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -284,43 +284,57 @@ bool of_phy_is_fixed_link(struct device_node *np)
 }
 EXPORT_SYMBOL(of_phy_is_fixed_link);
 
-int of_phy_register_fixed_link(struct device_node *np)
+int of_phy_parse_fixed_link(struct device_node *np,
+			    struct fixed_phy_status *status)
 {
-	struct fixed_phy_status status = {};
 	struct device_node *fixed_link_node;
 	const __be32 *fixed_link_prop;
 	int len;
-	struct phy_device *phy;
 
 	/* New binding */
 	fixed_link_node = of_get_child_by_name(np, "fixed-link");
 	if (fixed_link_node) {
-		status.link = 1;
-		status.duplex = of_property_read_bool(fixed_link_node,
-						      "full-duplex");
-		if (of_property_read_u32(fixed_link_node, "speed", &status.speed))
+		status->link = 1;
+		status->duplex = of_property_read_bool(fixed_link_node,
+						       "full-duplex");
+		if (of_property_read_u32(fixed_link_node, "speed",
+					 &status->speed))
 			return -EINVAL;
-		status.pause = of_property_read_bool(fixed_link_node, "pause");
-		status.asym_pause = of_property_read_bool(fixed_link_node,
-							  "asym-pause");
+		status->pause = of_property_read_bool(fixed_link_node,
+						      "pause");
+		status->asym_pause = of_property_read_bool(fixed_link_node,
+							   "asym-pause");
 		of_node_put(fixed_link_node);
-		phy = fixed_phy_register(PHY_POLL, &status, np);
-		return IS_ERR(phy) ? PTR_ERR(phy) : 0;
+
+		return 0;
 	}
 
 	/* Old binding */
 	fixed_link_prop = of_get_property(np, "fixed-link", &len);
 	if (fixed_link_prop && len == (5 * sizeof(__be32))) {
-		status.link = 1;
-		status.duplex = be32_to_cpu(fixed_link_prop[1]);
-		status.speed = be32_to_cpu(fixed_link_prop[2]);
-		status.pause = be32_to_cpu(fixed_link_prop[3]);
-		status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
-		phy = fixed_phy_register(PHY_POLL, &status, np);
-		return IS_ERR(phy) ? PTR_ERR(phy) : 0;
+		status->link = 1;
+		status->duplex = be32_to_cpu(fixed_link_prop[1]);
+		status->speed = be32_to_cpu(fixed_link_prop[2]);
+		status->pause = be32_to_cpu(fixed_link_prop[3]);
+		status->asym_pause = be32_to_cpu(fixed_link_prop[4]);
+
+		return 0;
 	}
 
 	return -ENODEV;
 }
+EXPORT_SYMBOL(of_phy_parse_fixed_link);
+
+int of_phy_register_fixed_link(struct device_node *np)
+{
+	struct phy_device *phy;
+	struct fixed_phy_status status = {};
+
+	if (of_phy_parse_fixed_link(np, &status))
+		return -ENODEV;
+
+	phy = fixed_phy_register(PHY_POLL, &status, np);
+	return IS_ERR(phy) ? PTR_ERR(phy) : 0;
+}
 EXPORT_SYMBOL(of_phy_register_fixed_link);
 #endif
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index 8f2237e..311b2cf 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -12,6 +12,8 @@
 #include <linux/phy.h>
 #include <linux/of.h>
 
+struct fixed_phy_status;
+
 #ifdef CONFIG_OF
 extern int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np);
 extern struct phy_device *of_phy_find_device(struct device_node *phy_np);
@@ -70,9 +72,16 @@ static inline int of_mdio_parse_addr(struct device *dev,
 #endif /* CONFIG_OF */
 
 #if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
+extern int of_phy_parse_fixed_link(struct device_node *np,
+				   struct fixed_phy_status *status);
 extern int of_phy_register_fixed_link(struct device_node *np);
 extern bool of_phy_is_fixed_link(struct device_node *np);
 #else
+static inline int of_phy_parse_fixed_link(struct device_node *np,
+					  struct fixed_phy_status *status)
+{
+	return -EINVAL;
+}
 static inline int of_phy_register_fixed_link(struct device_node *np)
 {
 	return -ENOSYS;
-- 
1.7.11.7

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
