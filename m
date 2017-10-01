From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 5/5] net: dsa: loop: Add support for LAG
Date: Sun,  1 Oct 2017 12:46:39 -0700
Message-ID: <20171001194639.8647-6-f.fainelli@gmail.com>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us, idosch@mellanox.com, Woojung.Huh@microchip.com,
        john@phrozen.org, sean.wang@mediatek.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:37191 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751971AbdJATq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 15:46:56 -0400
Received: by mail-oi0-f67.google.com with SMTP id h9so2118131oia.4
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 12:46:56 -0700 (PDT)
In-Reply-To: <20171001194639.8647-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement LAG operations for the DSA loopback/mock-up driver in order to
exercise the DSA core code. This just maintains a software bitmask of ports
belonging to a LAG group, we allow up to 2 LAG groups and up to 2 members per
LAG group.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/dsa_loop.c | 54 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 52 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
index d55051abf4ed..776130c69c7f 100644
--- a/drivers/net/dsa/dsa_loop.c
+++ b/drivers/net/dsa/dsa_loop.c
@@ -1,7 +1,7 @@
 /*
  * Distributed Switch Architecture loopback driver
  *
- * Copyright (C) 2016, Florian Fainelli <f.fainelli@gmail.com>
+ * Copyright (C) 2016-2017, Florian Fainelli <f.fainelli@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -27,6 +27,10 @@ struct dsa_loop_vlan {
 	u16 untagged;
 };
 
+struct dsa_loop_lag {
+	u8 members;
+};
+
 struct dsa_loop_mib_entry {
 	char name[ETH_GSTRING_LEN];
 	unsigned long val;
@@ -52,6 +56,7 @@ struct dsa_loop_port {
 };
 
 #define DSA_LOOP_VLANS	5
+#define DSA_LOOP_LAGS	2
 
 struct dsa_loop_priv {
 	struct mii_bus	*bus;
@@ -60,6 +65,7 @@ struct dsa_loop_priv {
 	struct net_device *netdev;
 	struct dsa_loop_port ports[DSA_MAX_PORTS];
 	u16 pvid;
+	struct dsa_loop_lag lags[DSA_LOOP_LAGS];
 };
 
 static struct phy_device *phydevs[PHY_MAX_ADDR];
@@ -257,6 +263,40 @@ static int dsa_loop_port_vlan_del(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+static bool dsa_loop_lag_member(struct dsa_switch *ds, int port, u8 lag_id)
+{
+	struct dsa_loop_priv *priv = ds->priv;
+	struct dsa_loop_lag *lag = &priv->lags[lag_id];
+
+	return !!(BIT(port) & lag->members);
+}
+
+static int dsa_loop_lag_join(struct dsa_switch *ds, int port, u8 lag_id)
+{
+	struct dsa_loop_priv *priv = ds->priv;
+	struct dsa_loop_lag *lag = &priv->lags[lag_id];
+
+	lag->members |= BIT(port);
+
+	dev_dbg(ds->dev, "%s, added port %d to lag: %d\n",
+		__func__, port, lag_id);
+
+	return 0;
+}
+
+static void dsa_loop_lag_leave(struct dsa_switch *ds, int port, u8 lag_id,
+				bool lag_disable)
+{
+	struct dsa_loop_priv *priv = ds->priv;
+	struct dsa_loop_lag *lag = &priv->lags[lag_id];
+
+
+	lag->members &= ~BIT(port);
+
+	dev_dbg(ds->dev, "%s, removed port %d from lag: %d\n",
+		__func__, port, lag_id);
+}
+
 static const struct dsa_switch_ops dsa_loop_driver = {
 	.get_tag_protocol	= dsa_loop_get_protocol,
 	.setup			= dsa_loop_setup,
@@ -273,6 +313,9 @@ static const struct dsa_switch_ops dsa_loop_driver = {
 	.port_vlan_prepare	= dsa_loop_port_vlan_prepare,
 	.port_vlan_add		= dsa_loop_port_vlan_add,
 	.port_vlan_del		= dsa_loop_port_vlan_del,
+	.port_lag_member	= dsa_loop_lag_member,
+	.port_lag_join		= dsa_loop_lag_join,
+	.port_lag_leave		= dsa_loop_lag_leave,
 };
 
 static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
@@ -280,6 +323,7 @@ static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
 	struct dsa_loop_pdata *pdata = mdiodev->dev.platform_data;
 	struct dsa_loop_priv *ps;
 	struct dsa_switch *ds;
+	int ret;
 
 	if (!pdata)
 		return -ENODEV;
@@ -291,6 +335,13 @@ static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
 	if (!ds)
 		return -ENOMEM;
 
+	ds->dev = &mdiodev->dev;
+	ds->max_lag_members = 2;
+
+	ret = dsa_switch_alloc_lags(ds, DSA_LOOP_LAGS);
+	if (ret)
+		return ret;
+
 	ps = devm_kzalloc(&mdiodev->dev, sizeof(*ps), GFP_KERNEL);
 	if (!ps)
 		return -ENOMEM;
@@ -301,7 +352,6 @@ static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
 
 	pdata->cd.netdev[DSA_LOOP_CPU_PORT] = &ps->netdev->dev;
 
-	ds->dev = &mdiodev->dev;
 	ds->ops = &dsa_loop_driver;
 	ds->priv = ps;
 	ps->bus = mdiodev->bus;
-- 
2.11.0
