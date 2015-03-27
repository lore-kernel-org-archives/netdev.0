From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 4/6] of: add API for changing parameters of fixed link
Date: Fri, 27 Mar 2015 16:37:57 +0300
Message-ID: <55155D35.1070703@list.ru>
References: <55155AFC.4050800@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, devicetree@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55155AFC.4050800@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The following API is added:
- of_phy_fixed_link_set_link() allows to set link state (up/down)
- of_phy_fixed_link_set_speed() allows to set link speed
- of_phy_fixed_link_set_duplex() allows to enable/disable duplex

This API is needed when the MDIO-less link have some other means
of a status passing to MAC, for example with in-band data (SGMII).
MAC driver can then use that API to update the PHY status.

CC: Florian Fainelli <f.fainelli@gmail.com>
CC: Grant Likely <grant.likely@linaro.org>
CC: Rob Herring <robh+dt@kernel.org>
CC: netdev@vger.kernel.org
CC: devicetree@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/of/of_mdio.c    |   72 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/of_mdio.h |   17 +++++++++++
 2 files changed, 89 insertions(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index b3dc1e6..ade2426 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -251,6 +251,69 @@ struct phy_device *of_phy_attach(struct net_device *dev,
 EXPORT_SYMBOL(of_phy_attach);

 #if defined(CONFIG_FIXED_PHY)
+struct fixed_link_data {
+	struct fixed_phy_status status;
+	struct fixed_phy_status changed;
+};
+
+static int of_phy_fixed_link_update(struct phy_device *phy,
+		  struct fixed_phy_status *status)
+{
+	struct fixed_link_data *priv = phy->priv;
+
+	if (priv->changed.link) {
+		status->link = priv->status.link;
+		priv->changed.link = 0;
+	}
+	if (priv->changed.speed) {
+		status->speed = priv->status.speed;
+		priv->changed.speed = 0;
+	}
+	if (priv->changed.duplex) {
+		status->duplex = priv->status.duplex;
+		priv->changed.duplex = 0;
+	}
+	if (priv->changed.pause) {
+		status->pause = priv->status.pause;
+		priv->changed.pause = 0;
+	}
+	if (priv->changed.asym_pause) {
+		status->asym_pause = priv->status.asym_pause;
+		priv->changed.asym_pause = 0;
+	}
+	return 0;
+}
+
+int of_phy_fixed_link_set_link(struct phy_device *phy, int link)
+{
+	struct fixed_link_data *priv = phy->priv;
+
+	priv->status.link = link;
+	priv->changed.link = 1;
+	return 0;
+}
+EXPORT_SYMBOL(of_phy_fixed_link_set_link);
+
+int of_phy_fixed_link_set_speed(struct phy_device *phy, int speed)
+{
+	struct fixed_link_data *priv = phy->priv;
+
+	priv->status.speed = speed;
+	priv->changed.speed = 1;
+	return 0;
+}
+EXPORT_SYMBOL(of_phy_fixed_link_set_speed);
+
+int of_phy_fixed_link_set_duplex(struct phy_device *phy, int duplex)
+{
+	struct fixed_link_data *priv = phy->priv;
+
+	priv->status.duplex = duplex;
+	priv->changed.duplex = 1;
+	return 0;
+}
+EXPORT_SYMBOL(of_phy_fixed_link_set_duplex);
+
 /*
  * of_phy_is_fixed_link() and of_phy_register_fixed_link() must
  * support two DT bindings:
@@ -287,6 +350,7 @@ int of_phy_register_fixed_link(struct device_node *np)
 	const __be32 *fixed_link_prop;
 	int len;
 	struct phy_device *phy;
+	struct fixed_link_data *priv;

 	/* New binding */
 	fixed_link_node = of_get_child_by_name(np, "fixed-link");
@@ -320,6 +384,14 @@ int of_phy_register_fixed_link(struct device_node *np)
 		}
 	}

+	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		fixed_phy_unregister(phy);
+		return -ENOMEM;
+	}
+	memset(&priv->changed, 0, sizeof(priv->changed));
+	phy->priv = priv;
+	fixed_phy_set_link_update(phy, of_phy_fixed_link_update);
 	return 0;
 }
 EXPORT_SYMBOL(of_phy_register_fixed_link);
diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
index d449018..677adac 100644
--- a/include/linux/of_mdio.h
+++ b/include/linux/of_mdio.h
@@ -65,6 +65,9 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
 #if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
 extern int of_phy_register_fixed_link(struct device_node *np);
 extern bool of_phy_is_fixed_link(struct device_node *np);
+extern int of_phy_fixed_link_set_link(struct phy_device *phy, int link);
+extern int of_phy_fixed_link_set_speed(struct phy_device *phy, int speed);
+extern int of_phy_fixed_link_set_duplex(struct phy_device *phy, int duplex);
 #else
 static inline int of_phy_register_fixed_link(struct device_node *np)
 {
@@ -74,6 +77,20 @@ static inline bool of_phy_is_fixed_link(struct device_node *np)
 {
 	return false;
 }
+static inline int of_phy_fixed_link_set_link(struct phy_device *phy, int link)
+{
+	return -ENOSYS;
+}
+static inline int of_phy_fixed_link_set_speed(struct phy_device *phy,
+					      int speed)
+{
+	return -ENOSYS;
+}
+static inline int of_phy_fixed_link_set_duplex(struct phy_device *phy,
+					       int duplex)
+{
+	return -ENOSYS;
+}
 #endif


-- 
1.7.9.5
