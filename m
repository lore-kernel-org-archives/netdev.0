From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 24/26] phylink: add module EEPROM support
Date: Mon, 07 Dec 2015 17:39:14 +0000
Message-ID: <E1a5zko-000772-Iq@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60325 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932668AbbLGRjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:39:17 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for reading module EEPROMs through phylink.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/phylink.c | 66 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/phylink.h   | 12 +++++++++
 2 files changed, 78 insertions(+)

diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
index 82492db0fd04..cd56d454c587 100644
--- a/drivers/net/phy/phylink.c
+++ b/drivers/net/phy/phylink.c
@@ -60,6 +60,9 @@ struct phylink {
 	struct work_struct resolve;
 
 	bool mac_link_up;
+
+	const struct phylink_module_ops *module_ops;
+	void *module_data;
 };
 
 static const char *phylink_an_mode_str(unsigned int mode)
@@ -800,6 +803,36 @@ int phylink_ethtool_set_pauseparam(struct phylink *pl,
 }
 EXPORT_SYMBOL_GPL(phylink_ethtool_set_pauseparam);
 
+int phylink_ethtool_get_module_info(struct phylink *pl,
+				    struct ethtool_modinfo *modinfo)
+{
+	int ret = -EOPNOTSUPP;
+
+	mutex_lock(&pl->config_mutex);
+	if (pl->module_ops)
+		ret = pl->module_ops->get_module_info(pl->module_data,
+						      modinfo);
+	mutex_unlock(&pl->config_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_ethtool_get_module_info);
+
+int phylink_ethtool_get_module_eeprom(struct phylink *pl,
+				      struct ethtool_eeprom *ee, u8 *buf)
+{
+	int ret = -EOPNOTSUPP;
+
+	mutex_lock(&pl->config_mutex);
+	if (pl->module_ops)
+		ret = pl->module_ops->get_module_eeprom(pl->module_data, ee,
+							buf);
+	mutex_unlock(&pl->config_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_ethtool_get_module_eeprom);
+
 int phylink_init_eee(struct phylink *pl, bool clk_stop_enable)
 {
 	int ret = -EPROTONOSUPPORT;
@@ -996,6 +1029,39 @@ EXPORT_SYMBOL_GPL(phylink_mii_ioctl);
 
 
 
+int phylink_register_module(struct phylink *pl, void *data,
+			    const struct phylink_module_ops *ops)
+{
+	int ret = -EBUSY;
+
+	mutex_lock(&pl->config_mutex);
+	if (!pl->module_ops) {
+		pl->module_ops = ops;
+		pl->module_data = data;
+		ret = 0;
+	}
+	mutex_unlock(&pl->config_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_register_module);
+
+int phylink_unregister_module(struct phylink *pl, void *data)
+{
+	int ret = -EINVAL;
+
+	mutex_lock(&pl->config_mutex);
+	if (pl->module_data == data) {
+		pl->module_ops = NULL;
+		pl->module_data = NULL;
+		ret = 0;
+	}
+	mutex_unlock(&pl->config_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_unregister_module);
+
 void phylink_disable(struct phylink *pl)
 {
 	set_bit(PHYLINK_DISABLE_LINK, &pl->phylink_disable_state);
diff --git a/include/linux/phylink.h b/include/linux/phylink.h
index 361fbe9222b2..01d442b08e62 100644
--- a/include/linux/phylink.h
+++ b/include/linux/phylink.h
@@ -55,6 +55,11 @@ struct phylink_mac_ops {
 			    struct phy_device *);
 };
 
+struct phylink_module_ops {
+	int (*get_module_info)(void *, struct ethtool_modinfo *);
+	int (*get_module_eeprom)(void *, struct ethtool_eeprom *, u8 *);
+};
+
 struct phylink *phylink_create(struct net_device *, struct device_node *,
 	phy_interface_t iface, const struct phylink_mac_ops *ops);
 void phylink_destroy(struct phylink *);
@@ -75,12 +80,19 @@ void phylink_ethtool_get_pauseparam(struct phylink *,
 				    struct ethtool_pauseparam *);
 int phylink_ethtool_set_pauseparam(struct phylink *,
 				   struct ethtool_pauseparam *);
+int phylink_ethtool_get_module_info(struct phylink *, struct ethtool_modinfo *);
+int phylink_ethtool_get_module_eeprom(struct phylink *,
+				      struct ethtool_eeprom *, u8 *);
 int phylink_init_eee(struct phylink *, bool);
 int phylink_get_eee_err(struct phylink *);
 int phylink_ethtool_get_eee(struct phylink *, struct ethtool_eee *);
 int phylink_ethtool_set_eee(struct phylink *, struct ethtool_eee *);
 int phylink_mii_ioctl(struct phylink *, struct ifreq *, int);
 
+int phylink_register_module(struct phylink *, void *,
+			    const struct phylink_module_ops *);
+int phylink_unregister_module(struct phylink *, void *);
+
 void phylink_set_link_port(struct phylink *pl, u32 support, u8 port);
 int phylink_set_link_an_mode(struct phylink *pl, unsigned int mode);
 void phylink_disable(struct phylink *pl);
-- 
2.1.0
