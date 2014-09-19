From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: dsa: add {get,set}_wol callbacks to slave devices
Date: Thu, 18 Sep 2014 17:31:24 -0700
Message-ID: <1411086685-18684-4-git-send-email-f.fainelli@gmail.com>
References: <1411086685-18684-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:43173 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610AbaISAbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 20:31:49 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so113181pab.20
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 17:31:49 -0700 (PDT)
In-Reply-To: <1411086685-18684-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow switch drivers to implement per-port Wake-on-LAN getter and
setters.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  8 ++++++++
 net/dsa/slave.c   | 23 +++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 0a34bf3d1ddd..1de4efff4e42 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -211,6 +211,14 @@ struct dsa_switch_driver {
 	int	(*get_sset_count)(struct dsa_switch *ds);
 
 	/*
+	 * ethtool Wake-on-LAN
+	 */
+	void	(*get_wol)(struct dsa_switch *ds, int port,
+			   struct ethtool_wolinfo *w);
+	int	(*set_wol)(struct dsa_switch *ds, int port,
+			   struct ethtool_wolinfo *w);
+
+	/*
 	 * Suspend and resume
 	 */
 	int	(*suspend)(struct dsa_switch *ds);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e11c9bdca6e6..db53c1bf998c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -301,6 +301,27 @@ static int dsa_slave_get_sset_count(struct net_device *dev, int sset)
 	return -EOPNOTSUPP;
 }
 
+static void dsa_slave_get_wol(struct net_device *dev, struct ethtool_wolinfo *w)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+
+	if (ds->drv->get_wol)
+		ds->drv->get_wol(ds, p->port, w);
+}
+
+static int dsa_slave_set_wol(struct net_device *dev, struct ethtool_wolinfo *w)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret = -EOPNOTSUPP;
+
+	if (ds->drv->set_wol)
+		ret = ds->drv->set_wol(ds, p->port, w);
+
+	return ret;
+}
+
 static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_settings		= dsa_slave_get_settings,
 	.set_settings		= dsa_slave_set_settings,
@@ -310,6 +331,8 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_strings		= dsa_slave_get_strings,
 	.get_ethtool_stats	= dsa_slave_get_ethtool_stats,
 	.get_sset_count		= dsa_slave_get_sset_count,
+	.set_wol		= dsa_slave_set_wol,
+	.get_wol		= dsa_slave_get_wol,
 };
 
 static const struct net_device_ops dsa_slave_netdev_ops = {
-- 
1.9.1
