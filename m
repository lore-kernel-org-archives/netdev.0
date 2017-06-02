From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 2/3] net: dsa: Consistently use dsa_port for dsa_*_port_{apply,unapply}
Date: Fri,  2 Jun 2017 12:31:22 -0700
Message-ID: <20170602193123.23930-3-f.fainelli@gmail.com>
References: <20170602193123.23930-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33765 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751192AbdFBTbm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 15:31:42 -0400
Received: by mail-wm0-f65.google.com with SMTP id b84so20478032wmh.0
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 12:31:41 -0700 (PDT)
In-Reply-To: <20170602193123.23930-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have all the information we need in dsa_port, so use it instead of
repeating the same arguments over and over again.

Suggested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 90 ++++++++++++++++++++++++++--------------------------------
 1 file changed, 41 insertions(+), 49 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 7f9bf1456a65..067daec644c1 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -214,66 +214,61 @@ static int dsa_dst_complete(struct dsa_switch_tree *dst)
 	return 0;
 }
 
-static int dsa_dsa_port_apply(struct dsa_port *port, u32 index,
-			      struct dsa_switch *ds)
+static int dsa_dsa_port_apply(struct dsa_port *port)
 {
+	struct dsa_switch *ds = port->ds;
 	int err;
 
-	err = dsa_cpu_dsa_setup(ds, ds->dev, port, index);
+	err = dsa_cpu_dsa_setup(ds, ds->dev, port, port->index);
 	if (err) {
 		dev_warn(ds->dev, "Failed to setup dsa port %d: %d\n",
-			 index, err);
+			 port->index, err);
 		return err;
 	}
 
-	memset(&ds->ports[index].devlink_port, 0,
-	       sizeof(ds->ports[index].devlink_port));
+	memset(&port->devlink_port, 0, sizeof(port->devlink_port));
 
-	return devlink_port_register(ds->devlink,
-				     &ds->ports[index].devlink_port,
-				     index);
+	return devlink_port_register(ds->devlink, &port->devlink_port,
+				     port->index);
 }
 
-static void dsa_dsa_port_unapply(struct dsa_port *port, u32 index,
-				 struct dsa_switch *ds)
+static void dsa_dsa_port_unapply(struct dsa_port *port)
 {
-	devlink_port_unregister(&ds->ports[index].devlink_port);
+	devlink_port_unregister(&port->devlink_port);
 	dsa_cpu_dsa_destroy(port);
 }
 
-static int dsa_cpu_port_apply(struct dsa_port *port, u32 index,
-			      struct dsa_switch *ds)
+static int dsa_cpu_port_apply(struct dsa_port *port)
 {
+	struct dsa_switch *ds = port->ds;
 	int err;
 
-	err = dsa_cpu_dsa_setup(ds, ds->dev, port, index);
+	err = dsa_cpu_dsa_setup(ds, ds->dev, port, port->index);
 	if (err) {
 		dev_warn(ds->dev, "Failed to setup cpu port %d: %d\n",
-			 index, err);
+			 port->index, err);
 		return err;
 	}
 
-	ds->cpu_port_mask |= BIT(index);
+	ds->cpu_port_mask |= BIT(port->index);
 
-	memset(&ds->ports[index].devlink_port, 0,
-	       sizeof(ds->ports[index].devlink_port));
-	err = devlink_port_register(ds->devlink, &ds->ports[index].devlink_port,
-				    index);
+	memset(&port->devlink_port, 0, sizeof(port->devlink_port));
+	err = devlink_port_register(ds->devlink, &port->devlink_port,
+				    port->index);
 	return err;
 }
 
-static void dsa_cpu_port_unapply(struct dsa_port *port, u32 index,
-				 struct dsa_switch *ds)
+static void dsa_cpu_port_unapply(struct dsa_port *port)
 {
-	devlink_port_unregister(&ds->ports[index].devlink_port);
+	devlink_port_unregister(&port->devlink_port);
 	dsa_cpu_dsa_destroy(port);
-	ds->cpu_port_mask &= ~BIT(index);
+	port->ds->cpu_port_mask &= ~BIT(port->index);
 
 }
 
-static int dsa_user_port_apply(struct dsa_port *port, u32 index,
-			       struct dsa_switch *ds)
+static int dsa_user_port_apply(struct dsa_port *port)
 {
+	struct dsa_switch *ds = port->ds;
 	const char *name = port->name;
 	int err;
 
@@ -282,35 +277,32 @@ static int dsa_user_port_apply(struct dsa_port *port, u32 index,
 	if (!name)
 		name = "eth%d";
 
-	err = dsa_slave_create(ds, ds->dev, index, name);
+	err = dsa_slave_create(ds, ds->dev, port->index, name);
 	if (err) {
 		dev_warn(ds->dev, "Failed to create slave %d: %d\n",
-			 index, err);
-		ds->ports[index].netdev = NULL;
+			 port->index, err);
+		port->netdev = NULL;
 		return err;
 	}
 
-	memset(&ds->ports[index].devlink_port, 0,
-	       sizeof(ds->ports[index].devlink_port));
-	err = devlink_port_register(ds->devlink, &ds->ports[index].devlink_port,
-				    index);
+	memset(&port->devlink_port, 0, sizeof(port->devlink_port));
+	err = devlink_port_register(ds->devlink, &port->devlink_port,
+				    port->index);
 	if (err)
 		return err;
 
-	devlink_port_type_eth_set(&ds->ports[index].devlink_port,
-				  ds->ports[index].netdev);
+	devlink_port_type_eth_set(&port->devlink_port, port->netdev);
 
 	return 0;
 }
 
-static void dsa_user_port_unapply(struct dsa_port *port, u32 index,
-				  struct dsa_switch *ds)
+static void dsa_user_port_unapply(struct dsa_port *port)
 {
-	devlink_port_unregister(&ds->ports[index].devlink_port);
-	if (ds->ports[index].netdev) {
-		dsa_slave_destroy(ds->ports[index].netdev);
-		ds->ports[index].netdev = NULL;
-		ds->enabled_port_mask &= ~(1 << index);
+	devlink_port_unregister(&port->devlink_port);
+	if (port->netdev) {
+		dsa_slave_destroy(port->netdev);
+		port->netdev = NULL;
+		port->ds->enabled_port_mask &= ~(1 << port->index);
 	}
 }
 
@@ -370,20 +362,20 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 			continue;
 
 		if (dsa_port_is_dsa(port)) {
-			err = dsa_dsa_port_apply(port, index, ds);
+			err = dsa_dsa_port_apply(port);
 			if (err)
 				return err;
 			continue;
 		}
 
 		if (dsa_port_is_cpu(port)) {
-			err = dsa_cpu_port_apply(port, index, ds);
+			err = dsa_cpu_port_apply(port);
 			if (err)
 				return err;
 			continue;
 		}
 
-		err = dsa_user_port_apply(port, index, ds);
+		err = dsa_user_port_apply(port);
 		if (err)
 			continue;
 	}
@@ -402,16 +394,16 @@ static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 			continue;
 
 		if (dsa_port_is_dsa(port)) {
-			dsa_dsa_port_unapply(port, index, ds);
+			dsa_dsa_port_unapply(port);
 			continue;
 		}
 
 		if (dsa_port_is_cpu(port)) {
-			dsa_cpu_port_unapply(port, index, ds);
+			dsa_cpu_port_unapply(port);
 			continue;
 		}
 
-		dsa_user_port_unapply(port, index, ds);
+		dsa_user_port_unapply(port);
 	}
 
 	if (ds->slave_mii_bus && ds->ops->phy_read)
-- 
2.9.3
