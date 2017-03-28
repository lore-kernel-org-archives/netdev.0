From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/2] net: dsa: dsa2: Add basic support of devlink
Date: Tue, 28 Mar 2017 23:45:07 +0200
Message-ID: <1490737507-7864-3-git-send-email-andrew@lunn.ch>
References: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, sfrench@samba.org,
        linux-cifs@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38443 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752248AbdC1VqL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 17:46:11 -0400
In-Reply-To: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register the switch and its ports with devlink.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 include/net/dsa.h |  5 +++++
 net/dsa/dsa2.c    | 47 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index f80e81912b83..951b5e49e899 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -19,6 +19,7 @@
 #include <linux/workqueue.h>
 #include <linux/of.h>
 #include <linux/ethtool.h>
+#include <net/devlink.h>
 
 struct tc_action;
 struct phy_device;
@@ -182,6 +183,7 @@ struct dsa_port {
 	unsigned int		ageing_time;
 	u8			stp_state;
 	struct net_device	*bridge_dev;
+	struct devlink_port	devlink_port;
 };
 
 struct dsa_switch {
@@ -237,6 +239,9 @@ struct dsa_switch {
 	unsigned int ageing_time_min;
 	unsigned int ageing_time_max;
 
+	/* devlink used to represent this switch device */
+	struct devlink		*devlink;
+
 	/* Dynamically allocated ports, keep last */
 	size_t num_ports;
 	struct dsa_port ports[];
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index d039c8d7adfd..033b3bfb63dc 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -24,6 +24,9 @@
 static LIST_HEAD(dsa_switch_trees);
 static DEFINE_MUTEX(dsa2_mutex);
 
+static const struct devlink_ops dsa_devlink_ops = {
+};
+
 static struct dsa_switch_tree *dsa_get_dst(u32 tree)
 {
 	struct dsa_switch_tree *dst;
@@ -223,12 +226,18 @@ static int dsa_dsa_port_apply(struct dsa_port *port, u32 index,
 		return err;
 	}
 
-	return 0;
+	memset(&ds->ports[index].devlink_port, 0,
+	       sizeof(ds->ports[index].devlink_port));
+
+	return devlink_port_register(ds->devlink,
+				     &ds->ports[index].devlink_port,
+				     index);
 }
 
 static void dsa_dsa_port_unapply(struct dsa_port *port, u32 index,
 				 struct dsa_switch *ds)
 {
+	devlink_port_unregister(&ds->ports[index].devlink_port);
 	dsa_cpu_dsa_destroy(port);
 }
 
@@ -246,12 +255,17 @@ static int dsa_cpu_port_apply(struct dsa_port *port, u32 index,
 
 	ds->cpu_port_mask |= BIT(index);
 
-	return 0;
+	memset(&ds->ports[index].devlink_port, 0,
+	       sizeof(ds->ports[index].devlink_port));
+	err = devlink_port_register(ds->devlink, &ds->ports[index].devlink_port,
+				    index);
+	return err;
 }
 
 static void dsa_cpu_port_unapply(struct dsa_port *port, u32 index,
 				 struct dsa_switch *ds)
 {
+	devlink_port_unregister(&ds->ports[index].devlink_port);
 	dsa_cpu_dsa_destroy(port);
 	ds->cpu_port_mask &= ~BIT(index);
 
@@ -276,12 +290,23 @@ static int dsa_user_port_apply(struct dsa_port *port, u32 index,
 		return err;
 	}
 
+	memset(&ds->ports[index].devlink_port, 0,
+	       sizeof(ds->ports[index].devlink_port));
+	err = devlink_port_register(ds->devlink, &ds->ports[index].devlink_port,
+				    index);
+	if (err)
+		return err;
+
+	devlink_port_type_eth_set(&ds->ports[index].devlink_port,
+				  ds->ports[index].netdev);
+
 	return 0;
 }
 
 static void dsa_user_port_unapply(struct dsa_port *port, u32 index,
 				  struct dsa_switch *ds)
 {
+	devlink_port_unregister(&ds->ports[index].devlink_port);
 	if (ds->ports[index].netdev) {
 		dsa_slave_destroy(ds->ports[index].netdev);
 		ds->ports[index].netdev = NULL;
@@ -302,6 +327,17 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	 */
 	ds->phys_mii_mask = ds->enabled_port_mask;
 
+	/* Add the switch to devlink before calling setup, so that setup can
+	 * add dpipe tables
+	 */
+	ds->devlink = devlink_alloc(&dsa_devlink_ops, 0);
+	if (!ds->devlink)
+		return -ENOMEM;
+
+	err = devlink_register(ds->devlink, ds->dev);
+	if (err)
+		return err;
+
 	err = ds->ops->setup(ds);
 	if (err < 0)
 		return err;
@@ -382,6 +418,13 @@ static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 		mdiobus_unregister(ds->slave_mii_bus);
 
 	dsa_switch_unregister_notifier(ds);
+
+	if (ds->devlink) {
+		devlink_unregister(ds->devlink);
+		devlink_free(ds->devlink);
+		ds->devlink = NULL;
+	}
+
 }
 
 static int dsa_dst_apply(struct dsa_switch_tree *dst)
-- 
2.11.0
