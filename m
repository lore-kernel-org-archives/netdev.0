From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 1/3] net: dsa: Ensure that port array elements are initialized before being used
Date: Tue, 24 Feb 2015 13:15:32 -0800
Message-ID: <1424812534-8936-2-git-send-email-f.fainelli@gmail.com>
References: <1424812534-8936-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:39437 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbbBXVTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:19:25 -0500
Received: by pablf10 with SMTP id lf10so38994793pab.6
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 13:19:24 -0800 (PST)
In-Reply-To: <1424812534-8936-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

A network device notifier can be called for one or more of the created
slave devices before all slave devices have been registered. This can
result in a mismatch between ds->phys_port_mask and the registered devices
by the time the call is made, and it can result in a slave device being
added to a bridge before its entry in ds->ports[] has been initialized.

Rework the initialization code to initialize entries in ds->ports[] in
dsa_slave_create. With this change, dsa_slave_create no longer needs
to return slave_dev but can return an error code instead.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Changes in v2:
- slightly rework the commit message so it does not mention the
  netdevice_notifier that we are adding in the next patch

 net/dsa/dsa.c      | 10 +++-------
 net/dsa/dsa_priv.h |  5 ++---
 net/dsa/slave.c    | 15 ++++++++-------
 3 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 2173402d87e0..fc1813140be6 100644
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
index dc9756d3154c..7eb1a6acd46c 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -53,9 +53,8 @@ extern char dsa_driver_version[];
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
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index f23deadf42a0..5be4c928c9c9 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -605,9 +605,8 @@ int dsa_slave_resume(struct net_device *slave_dev)
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
@@ -617,7 +616,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev = alloc_netdev(sizeof(struct dsa_slave_priv), name,
 				 NET_NAME_UNKNOWN, ether_setup);
 	if (slave_dev == NULL)
-		return slave_dev;
+		return -ENOMEM;
 
 	slave_dev->features = master->vlan_features;
 	slave_dev->ethtool_ops = &dsa_slave_ethtool_ops;
@@ -667,19 +666,21 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
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
-- 
2.1.0
