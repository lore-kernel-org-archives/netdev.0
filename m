From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/6] net: dsa: allow switches driver to implement get/set EEE
Date: Wed, 24 Sep 2014 17:05:21 -0700
Message-ID: <1411603522-8384-6-git-send-email-f.fainelli@gmail.com>
References: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:62797 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbaIYAGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 20:06:04 -0400
Received: by mail-pd0-f182.google.com with SMTP id p10so9395876pdj.27
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 17:06:04 -0700 (PDT)
In-Reply-To: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow switches driver to query and enable/disable EEE on a per-port
basis by implementing the ethtool_{get,set}_eee settings and delegating
these operations to the switch driver.

set_eee() will need to coordinate with the PHY driver to make sure that
EEE is enabled, the link-partner supports it and the auto-negotiation
result is satisfactory.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  9 +++++++++
 net/dsa/slave.c   | 40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4f664fe0e42c..58ad8c6492db 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -232,6 +232,15 @@ struct dsa_switch_driver {
 			       struct phy_device *phy);
 	void	(*port_disable)(struct dsa_switch *ds, int port,
 				struct phy_device *phy);
+
+	/*
+	 * EEE setttings
+	 */
+	int	(*set_eee)(struct dsa_switch *ds, int port,
+			   struct phy_device *phydev,
+			   struct ethtool_eee *e);
+	int	(*get_eee)(struct dsa_switch *ds, int port,
+			   struct ethtool_eee *e);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 182d30ae6818..36953c84ff2d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -342,6 +342,44 @@ static int dsa_slave_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
 	return ret;
 }
 
+static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret;
+
+	if (!ds->drv->set_eee)
+		return -EOPNOTSUPP;
+
+	ret = ds->drv->set_eee(ds, p->port, p->phy, e);
+	if (ret)
+		return ret;
+
+	if (p->phy)
+		ret = phy_ethtool_set_eee(p->phy, e);
+
+	return ret;
+}
+
+static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret;
+
+	if (!ds->drv->get_eee)
+		return -EOPNOTSUPP;
+
+	ret = ds->drv->get_eee(ds, p->port, e);
+	if (ret)
+		return ret;
+
+	if (p->phy)
+		ret = phy_ethtool_get_eee(p->phy, e);
+
+	return ret;
+}
+
 static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_settings		= dsa_slave_get_settings,
 	.set_settings		= dsa_slave_set_settings,
@@ -353,6 +391,8 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_sset_count		= dsa_slave_get_sset_count,
 	.set_wol		= dsa_slave_set_wol,
 	.get_wol		= dsa_slave_get_wol,
+	.set_eee		= dsa_slave_set_eee,
+	.get_eee		= dsa_slave_get_eee,
 };
 
 static const struct net_device_ops dsa_slave_netdev_ops = {
-- 
1.9.1
