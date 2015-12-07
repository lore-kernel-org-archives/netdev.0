From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 22/26] phylink: add EEE support
Date: Mon, 07 Dec 2015 17:39:04 +0000
Message-ID: <E1a5zke-00076o-5v@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60319 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756041AbbLGRjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:39:08 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add EEE hooks to phylink to allow the phylib EEE functions for the
connected phy to be safely accessed.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/phylink.c | 58 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/phylink.h   |  7 +++++-
 2 files changed, 63 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
index 22c8b0711252..82492db0fd04 100644
--- a/drivers/net/phy/phylink.c
+++ b/drivers/net/phy/phylink.c
@@ -314,7 +314,8 @@ static void phylink_resolve(struct work_struct *w)
 			if (pl->link_an_mode == MLO_AN_PHY)
 				pl->ops->mac_config(ndev, MLO_AN_PHY, &link_state);
 
-			pl->ops->mac_link_up(ndev, pl->link_an_mode);
+			pl->ops->mac_link_up(ndev, pl->link_an_mode,
+					     pl->phydev);
 
 			netif_carrier_on(ndev);
 
@@ -799,6 +800,61 @@ int phylink_ethtool_set_pauseparam(struct phylink *pl,
 }
 EXPORT_SYMBOL_GPL(phylink_ethtool_set_pauseparam);
 
+int phylink_init_eee(struct phylink *pl, bool clk_stop_enable)
+{
+	int ret = -EPROTONOSUPPORT;
+
+	mutex_lock(&pl->config_mutex);
+	if (pl->phydev)
+		ret = phy_init_eee(pl->phydev, clk_stop_enable);
+	mutex_unlock(&pl->config_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_init_eee);
+
+int phylink_get_eee_err(struct phylink *pl)
+{
+	int ret = 0;
+
+	mutex_lock(&pl->config_mutex);
+	if (pl->phydev)
+		ret = phy_get_eee_err(pl->phydev);
+	mutex_unlock(&pl->config_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_get_eee_err);
+
+int phylink_ethtool_get_eee(struct phylink *pl, struct ethtool_eee *eee)
+{
+	int ret = -EOPNOTSUPP;
+
+	mutex_lock(&pl->config_mutex);
+	if (pl->phydev)
+		ret = phy_ethtool_get_eee(pl->phydev, eee);
+	mutex_unlock(&pl->config_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_ethtool_get_eee);
+
+int phylink_ethtool_set_eee(struct phylink *pl, struct ethtool_eee *eee)
+{
+	int ret = -EOPNOTSUPP;
+
+	mutex_lock(&pl->config_mutex);
+	if (pl->phydev) {
+		ret = phy_ethtool_set_eee(pl->phydev, eee);
+		if (ret == 0 && eee->eee_enabled)
+			phy_start_aneg(pl->phydev);
+	}
+	mutex_unlock(&pl->config_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_ethtool_set_eee);
+
 /* This emulates MII registers for a fixed-mode phy operating as per the
  * passed in state. "aneg" defines if we report negotiation is possible.
  *
diff --git a/include/linux/phylink.h b/include/linux/phylink.h
index a23c772cc3f9..361fbe9222b2 100644
--- a/include/linux/phylink.h
+++ b/include/linux/phylink.h
@@ -51,7 +51,8 @@ struct phylink_mac_ops {
 	void (*mac_an_restart)(struct net_device *, unsigned int mode);
 
 	void (*mac_link_down)(struct net_device *, unsigned int mode);
-	void (*mac_link_up)(struct net_device *, unsigned int mode);
+	void (*mac_link_up)(struct net_device *, unsigned int mode,
+			    struct phy_device *);
 };
 
 struct phylink *phylink_create(struct net_device *, struct device_node *,
@@ -74,6 +75,10 @@ void phylink_ethtool_get_pauseparam(struct phylink *,
 				    struct ethtool_pauseparam *);
 int phylink_ethtool_set_pauseparam(struct phylink *,
 				   struct ethtool_pauseparam *);
+int phylink_init_eee(struct phylink *, bool);
+int phylink_get_eee_err(struct phylink *);
+int phylink_ethtool_get_eee(struct phylink *, struct ethtool_eee *);
+int phylink_ethtool_set_eee(struct phylink *, struct ethtool_eee *);
 int phylink_mii_ioctl(struct phylink *, struct ifreq *, int);
 
 void phylink_set_link_port(struct phylink *pl, u32 support, u8 port);
-- 
2.1.0
