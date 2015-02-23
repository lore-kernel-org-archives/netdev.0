From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT PATCH] net: dsa: Ensure that port array elements are initialized before being used
Date: Mon, 23 Feb 2015 08:33:46 -0800
Message-ID: <1424709226-3586-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39946 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbBWQeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 11:34:01 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPvxH-0021XY-QQ
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 16:34:00 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dsa_slave_netdevice_event can be called for one or more of the created
slave devices before all slave devices have been registered. This can
result in a mismatch between ds->phys_port_mask and the registered devices
by the time the call is made, and it can result in a slave device being
added to a bridge before its entry in ds->ports[] has been initialized.

Rework the initialization code to initialize entries in ds->ports[] in
dsa_slave_create. With this change, dsa_slave_create no longer needs
to return slave_dev but can return an error code instead.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Applies on top of Florian's patches integrating dsa with SWITCHDEV (v3).

 net/dsa/dsa.c      | 10 +++-------
 net/dsa/dsa_priv.h |  5 ++---
 net/dsa/slave.c    | 17 ++++++++++-------
 3 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 293e0c3..9c208f0 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -314,19 +314,15 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	 * Create network devices for physical switch ports.
 	 */
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
-		struct net_device *slave_dev;
-
 		if (!(ds->phys_port_mask & (1 << i)))
 			continue;
 
-		slave_dev = dsa_slave_create(ds, parent, i, pd->port_names[i]);
-		if (slave_dev == NULL) {
+		ret = dsa_slave_create(ds, parent, i, pd->port_names[i]);
+		if (ret < 0) {
 			netdev_err(dst->master_netdev, "[%d]: can't create dsa slave device for port %d(%s)\n",
 				   index, i, pd->port_names[i]);
-			continue;
+			ret = 0;
 		}
-
-		ds->ports[i] = slave_dev;
 	}
 
 #ifdef CONFIG_NET_DSA_HWMON
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index b8d7231..d5f1f9b 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -55,9 +55,8 @@ extern char dsa_driver_version[];
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
-struct net_device *dsa_slave_create(struct dsa_switch *ds,
-				    struct device *parent,
-				    int port, char *name);
+int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
+		     int port, char *name);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
 int dsa_slave_netdevice_event(struct notifier_block *unused,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7ab19f2..ca8f45f 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -224,6 +224,8 @@ static u32 dsa_slave_br_port_mask(struct dsa_switch *ds,
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if (!((1 << port) & ds->phys_port_mask))
 			continue;
+		if (!ds->ports[port])
+			continue;
 
 		p = netdev_priv(ds->ports[port]);
 
@@ -709,9 +711,8 @@ int dsa_slave_resume(struct net_device *slave_dev)
 	return 0;
 }
 
-struct net_device *
-dsa_slave_create(struct dsa_switch *ds, struct device *parent,
-		 int port, char *name)
+int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
+		     int port, char *name)
 {
 	struct net_device *master = ds->dst->master_netdev;
 	struct net_device *slave_dev;
@@ -721,7 +722,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
 				 NET_NAME_UNKNOWN, ether_setup);
 	if (slave_dev == NULL)
-		return slave_dev;
+		return -ENOMEM;
 
 	slave_dev->features = master->vlan_features;
 	slave_dev->ethtool_ops = &dsa_slave_ethtool_ops;
@@ -771,21 +772,23 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	ret = dsa_slave_phy_setup(p, slave_dev);
 	if (ret) {
 		free_netdev(slave_dev);
-		return NULL;
+		return ret;
 	}
 
+	ds->ports[port] = slave_dev;
 	ret = register_netdev(slave_dev);
 	if (ret) {
 		netdev_err(master, "error %d registering interface %s\n",
 			   ret, slave_dev->name);
 		phy_disconnect(p->phy);
+		ds->ports[port] = NULL;
 		free_netdev(slave_dev);
-		return NULL;
+		return ret;
 	}
 
 	netif_carrier_off(slave_dev);
 
-	return slave_dev;
+	return 0;
 }
 
 static bool dsa_slave_dev_check(struct net_device *dev)
-- 
2.1.0
