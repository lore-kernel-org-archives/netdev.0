From: Stas Sergeev <stsp-cmBhpYW9OiY@public.gmane.org>
Subject: [PATCH 2/3] of_mdio: add new DT property 'autoneg' for fixed-link
Date: Fri, 10 Jul 2015 19:43:42 +0300
Message-ID: <559FF63E.8020209@list.ru>
References: <559FF511.5080102@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sebastien Rannou <mxs-i6rsG8ix9II@public.gmane.org>,
	Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>,
	Stas Sergeev <stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <559FF511.5080102-cmBhpYW9OiY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Currently for fixed-link the MAC driver decides whether to use the
link status auto-negotiation or not.
Unfortunately the auto-negotiation may not work when expected by
the MAC driver. Sebastien Rannou explains:
<< Yes, I confirm that my HW does not generate an in-band status. AFAIK, it's
a PHY that aggregates 4xSGMIIs to 1xQSGMII ; the MAC side of the PHY (with
inband status) is connected to the switch through QSGMII, and in this context
we are on the media side of the PHY. >>
https://lkml.org/lkml/2015/7/10/206

This patch introduces the new boolean property 'autoneg' that allows
the user to request the auto-negotiation explicitly.

Signed-off-by: Stas Sergeev <stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

CC: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
CC: Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>
CC: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
CC: Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
CC: Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
CC: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
CC: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 .../devicetree/bindings/net/fixed-link.txt         |  6 +++++-
 drivers/of/of_mdio.c                               | 23 ++++++++++++++++++++--
 include/linux/of_mdio.h                            |  5 +++++
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
index 82bf7e0..e2959a8 100644
--- a/Documentation/devicetree/bindings/net/fixed-link.txt
+++ b/Documentation/devicetree/bindings/net/fixed-link.txt
@@ -9,8 +9,12 @@ Such a fixed link situation is described by creating a 'fixed-link'
 sub-node of the Ethernet MAC device node, with the following
 properties:

+* 'autoneg' (boolean, optional), to enable the auto-negotiation of link
+  state. Auto-negotiation is MII protocol, HW and driver-specific and is
+  not supported in many cases, so use it only when you know what you do.
 * 'speed' (integer, mandatory), to indicate the link speed. Accepted
-  values are 10, 100 and 1000
+  values are 10, 100 and 1000. If the auto-negotiation is enabled,
+  'speed' may not be set. It will then be auto-negotiated, if possible.
 * 'full-duplex' (boolean, optional), to indicate that full duplex is
   used. When absent, half duplex is assumed.
 * 'pause' (boolean, optional), to indicate that pause should be
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 1bd4305..12b2ede 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -280,6 +280,22 @@ bool of_phy_is_fixed_link(struct device_node *np)
 }
 EXPORT_SYMBOL(of_phy_is_fixed_link);

+bool of_phy_is_autoneg_link(struct device_node *np)
+{
+	struct device_node *dn;
+	bool ret;
+
+	dn = of_get_child_by_name(np, "fixed-link");
+	if (!dn)
+		return false;
+
+	ret = of_property_read_bool(dn, "autoneg");
+
+	of_node_put(dn);
+	return ret;
+}
+EXPORT_SYMBOL(of_phy_is_autoneg_link);
+
 int of_phy_register_fixed_link(struct device_node *np)
 {
 	struct fixed_phy_status status = {};
@@ -291,10 +307,13 @@ int of_phy_register_fixed_link(struct device_node *np)
 	/* New binding */
 	fixed_link_node = of_get_child_by_name(np, "fixed-link");
 	if (fixed_link_node) {
-		status.link = 1;
+		bool autoneg = of_property_read_bool(fixed_link_node,
+						     "autoneg");
+		status.link = !autoneg;
 		status.duplex = of_property_read_bool(fixed_link_node,
 						      "full-duplex");
-		if (of_property_read_u32(fixed_link_node, "speed", &status.speed))
+		if (of_property_read_u32(fixed_link_node, "speed",
+					 &status.speed) != 0 && !autoneg)
 			return -EINVAL;
 		status.pause = of_property_read_bool(fixed_link_node, "pause");
 		status.asym_pause = of_property_read_bool(fixed_link_node,
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index d449018..647f348 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -65,6 +65,7 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
 #if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
 extern int of_phy_register_fixed_link(struct device_node *np);
 extern bool of_phy_is_fixed_link(struct device_node *np);
+extern bool of_phy_is_autoneg_link(struct device_node *np);
 #else
 static inline int of_phy_register_fixed_link(struct device_node *np)
 {
@@ -74,6 +75,10 @@ static inline bool of_phy_is_fixed_link(struct device_node *np)
 {
 	return false;
 }
+static inline bool of_phy_is_autoneg_link(struct device_node *np)
+{
+	return false;
+}
 #endif


-- 
1.9.1
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
