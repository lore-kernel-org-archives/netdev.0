From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: dsa: Make most functions take a dsa_port argument
Date: Thu, 26 Jan 2017 10:28:06 -0800
Message-ID: <20170126182808.13435-3-f.fainelli@gmail.com>
References: <20170126182808.13435-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32880 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751986AbdAZShZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:37:25 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so22967459pgd.0
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 10:37:17 -0800 (PST)
In-Reply-To: <20170126182808.13435-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing platform data, and therefore no valid
device_node pointer, make most DSA functions takes a pointer to a
dsa_port structure whenever possible. While at it, introduce a
dsa_port_is_valid() helper function which checks whether port->dn is
NULL or not at the moment.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c      | 15 ++++++++------
 net/dsa/dsa2.c     | 61 +++++++++++++++++++++++++++++-------------------------
 net/dsa/dsa_priv.h |  4 ++--
 3 files changed, 44 insertions(+), 36 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 1f3afeb673d6..07e863369e04 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -110,8 +110,9 @@ dsa_switch_probe(struct device *parent, struct device *host_dev, int sw_addr,
 
 /* basic switch operations **************************************************/
 int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
-		      struct device_node *port_dn, int port)
+		      struct dsa_port *dport, int port)
 {
+	struct device_node *port_dn = dport->dn;
 	struct phy_device *phydev;
 	int ret, mode;
 
@@ -141,15 +142,15 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 
 static int dsa_cpu_dsa_setups(struct dsa_switch *ds, struct device *dev)
 {
-	struct device_node *port_dn;
+	struct dsa_port *dport;
 	int ret, port;
 
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
 
-		port_dn = ds->ports[port].dn;
-		ret = dsa_cpu_dsa_setup(ds, dev, port_dn, port);
+		dport = &ds->ports[port];
+		ret = dsa_cpu_dsa_setup(ds, dev, dport, port);
 		if (ret)
 			return ret;
 	}
@@ -364,8 +365,10 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	return ds;
 }
 
-void dsa_cpu_dsa_destroy(struct device_node *port_dn)
+void dsa_cpu_dsa_destroy(struct dsa_port *port)
 {
+	struct device_node *port_dn = port->dn;
+
 	if (of_phy_is_fixed_link(port_dn))
 		of_phy_deregister_fixed_link(port_dn);
 }
@@ -389,7 +392,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
-		dsa_cpu_dsa_destroy(ds->ports[port].dn);
+		dsa_cpu_dsa_destroy(&ds->ports[port]);
 
 		/* Clearing a bit which is not set does no harm */
 		ds->cpu_port_mask |= ~(1 << port);
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 2cf489c5e90f..56c43ca7c049 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -78,14 +78,19 @@ static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
 	kref_put(&dst->refcount, dsa_free_dst);
 }
 
-static bool dsa_port_is_dsa(struct device_node *port)
+static bool dsa_port_is_valid(struct dsa_port *port)
 {
-	return !!of_parse_phandle(port, "link", 0);
+	return !!port->dn;
 }
 
-static bool dsa_port_is_cpu(struct device_node *port)
+static bool dsa_port_is_dsa(struct dsa_port *port)
 {
-	return !!of_parse_phandle(port, "ethernet", 0);
+	return !!of_parse_phandle(port->dn, "link", 0);
+}
+
+static bool dsa_port_is_cpu(struct dsa_port *port)
+{
+	return !!of_parse_phandle(port->dn, "ethernet", 0);
 }
 
 static bool dsa_ds_find_port(struct dsa_switch *ds,
@@ -119,7 +124,7 @@ static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
 
 static int dsa_port_complete(struct dsa_switch_tree *dst,
 			     struct dsa_switch *src_ds,
-			     struct device_node *port,
+			     struct dsa_port *port,
 			     u32 src_port)
 {
 	struct device_node *link;
@@ -127,7 +132,7 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
 	struct dsa_switch *dst_ds;
 
 	for (index = 0;; index++) {
-		link = of_parse_phandle(port, "link", index);
+		link = of_parse_phandle(port->dn, "link", index);
 		if (!link)
 			break;
 
@@ -150,13 +155,13 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
  */
 static int dsa_ds_complete(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 {
-	struct device_node *port;
+	struct dsa_port *port;
 	u32 index;
 	int err;
 
 	for (index = 0; index < DSA_MAX_PORTS; index++) {
-		port = ds->ports[index].dn;
-		if (!port)
+		port = &ds->ports[index];
+		if (!dsa_port_is_valid(port))
 			continue;
 
 		if (!dsa_port_is_dsa(port))
@@ -196,7 +201,7 @@ static int dsa_dst_complete(struct dsa_switch_tree *dst)
 	return 0;
 }
 
-static int dsa_dsa_port_apply(struct device_node *port, u32 index,
+static int dsa_dsa_port_apply(struct dsa_port *port, u32 index,
 			      struct dsa_switch *ds)
 {
 	int err;
@@ -211,13 +216,13 @@ static int dsa_dsa_port_apply(struct device_node *port, u32 index,
 	return 0;
 }
 
-static void dsa_dsa_port_unapply(struct device_node *port, u32 index,
+static void dsa_dsa_port_unapply(struct dsa_port *port, u32 index,
 				 struct dsa_switch *ds)
 {
 	dsa_cpu_dsa_destroy(port);
 }
 
-static int dsa_cpu_port_apply(struct device_node *port, u32 index,
+static int dsa_cpu_port_apply(struct dsa_port *port, u32 index,
 			      struct dsa_switch *ds)
 {
 	int err;
@@ -234,7 +239,7 @@ static int dsa_cpu_port_apply(struct device_node *port, u32 index,
 	return 0;
 }
 
-static void dsa_cpu_port_unapply(struct device_node *port, u32 index,
+static void dsa_cpu_port_unapply(struct dsa_port *port, u32 index,
 				 struct dsa_switch *ds)
 {
 	dsa_cpu_dsa_destroy(port);
@@ -242,13 +247,13 @@ static void dsa_cpu_port_unapply(struct device_node *port, u32 index,
 
 }
 
-static int dsa_user_port_apply(struct device_node *port, u32 index,
+static int dsa_user_port_apply(struct dsa_port *port, u32 index,
 			       struct dsa_switch *ds)
 {
 	const char *name;
 	int err;
 
-	name = of_get_property(port, "label", NULL);
+	name = of_get_property(port->dn, "label", NULL);
 	if (!name)
 		name = "eth%d";
 
@@ -262,7 +267,7 @@ static int dsa_user_port_apply(struct device_node *port, u32 index,
 	return 0;
 }
 
-static void dsa_user_port_unapply(struct device_node *port, u32 index,
+static void dsa_user_port_unapply(struct dsa_port *port, u32 index,
 				  struct dsa_switch *ds)
 {
 	if (ds->ports[index].netdev) {
@@ -274,7 +279,7 @@ static void dsa_user_port_unapply(struct device_node *port, u32 index,
 
 static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 {
-	struct device_node *port;
+	struct dsa_port *port;
 	u32 index;
 	int err;
 
@@ -308,8 +313,8 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	}
 
 	for (index = 0; index < DSA_MAX_PORTS; index++) {
-		port = ds->ports[index].dn;
-		if (!port)
+		port = &ds->ports[index];
+		if (!dsa_port_is_valid(port))
 			continue;
 
 		if (dsa_port_is_dsa(port)) {
@@ -336,12 +341,12 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 
 static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 {
-	struct device_node *port;
+	struct dsa_port *port;
 	u32 index;
 
 	for (index = 0; index < DSA_MAX_PORTS; index++) {
-		port = ds->ports[index].dn;
-		if (!port)
+		port = &ds->ports[index];
+		if (!dsa_port_is_valid(port))
 			continue;
 
 		if (dsa_port_is_dsa(port)) {
@@ -425,7 +430,7 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	dst->applied = false;
 }
 
-static int dsa_cpu_parse(struct device_node *port, u32 index,
+static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 			 struct dsa_switch_tree *dst,
 			 struct dsa_switch *ds)
 {
@@ -433,7 +438,7 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 	struct net_device *ethernet_dev;
 	struct device_node *ethernet;
 
-	ethernet = of_parse_phandle(port, "ethernet", 0);
+	ethernet = of_parse_phandle(port->dn, "ethernet", 0);
 	if (!ethernet)
 		return -EINVAL;
 
@@ -466,13 +471,13 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 
 static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 {
-	struct device_node *port;
+	struct dsa_port *port;
 	u32 index;
 	int err;
 
 	for (index = 0; index < DSA_MAX_PORTS; index++) {
-		port = ds->ports[index].dn;
-		if (!port)
+		port = &ds->ports[index];
+		if (!dsa_port_is_valid(port))
 			continue;
 
 		if (dsa_port_is_cpu(port)) {
@@ -533,7 +538,7 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 		 * to have access to a correct value, just like what
 		 * net/dsa/dsa.c::dsa_switch_setup_one does.
 		 */
-		if (!dsa_port_is_cpu(port))
+		if (!dsa_port_is_cpu(&ds->ports[reg]))
 			ds->enabled_port_mask |= 1 << reg;
 	}
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 63ae1484abae..16194a4bb2fe 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -50,8 +50,8 @@ struct dsa_slave_priv {
 
 /* dsa.c */
 int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
-		      struct device_node *port_dn, int port);
-void dsa_cpu_dsa_destroy(struct device_node *port_dn);
+		      struct dsa_port *dport, int port);
+void dsa_cpu_dsa_destroy(struct dsa_port *dport);
 const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
 int dsa_cpu_port_ethtool_setup(struct dsa_switch *ds);
 void dsa_cpu_port_ethtool_restore(struct dsa_switch *ds);
-- 
2.9.3
