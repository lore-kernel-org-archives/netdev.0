From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/6] net: dsa: Make most functions take a dsa_port argument
Date: Mon, 27 Jun 2016 17:52:39 -0700
Message-ID: <1467075163-15890-3-git-send-email-f.fainelli@gmail.com>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36668 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbcF1AxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 20:53:02 -0400
Received: by mail-oi0-f66.google.com with SMTP id x6so257464oif.3
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 17:52:49 -0700 (PDT)
In-Reply-To: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for allowing platform data, and therefore no valid
device_node pointer, make most DSA functions takes a pointer to a
dsa_port structure whenever possible. While at it, introduce a
dsa_port_is_valid() helper function which checks whether port->dn is
NULL or not at the moment.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c      | 14 +++++++------
 net/dsa/dsa2.c     | 61 +++++++++++++++++++++++++++++-------------------------
 net/dsa/dsa_priv.h |  4 ++--
 3 files changed, 43 insertions(+), 36 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 766d2a525ada..d117580a78b6 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -208,8 +208,9 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
 
 /* basic switch operations **************************************************/
 int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
-		      struct device_node *port_dn, int port)
+		      struct dsa_port *dport, int port)
 {
+	struct device_node *port_dn = dport->dn;
 	struct phy_device *phydev;
 	int ret, mode;
 
@@ -237,15 +238,15 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 
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
@@ -494,8 +495,9 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	return ds;
 }
 
-void dsa_cpu_dsa_destroy(struct device_node *port_dn)
+void dsa_cpu_dsa_destroy(struct dsa_port *port)
 {
+	struct device_node *port_dn = port->dn;
 	struct phy_device *phydev;
 
 	if (of_phy_is_fixed_link(port_dn)) {
@@ -531,7 +533,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
-		dsa_cpu_dsa_destroy(ds->ports[port].dn);
+		dsa_cpu_dsa_destroy(&ds->ports[port]);
 
 		/* Clearing a bit which is not set does no harm */
 		ds->cpu_port_mask |= ~(1 << port);
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 0940a0ec83e6..3a782ceef716 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -77,11 +77,16 @@ static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
 	kref_put(&dst->refcount, dsa_free_dst);
 }
 
-static bool dsa_port_is_dsa(struct device_node *port)
+static bool dsa_port_is_valid(struct dsa_port *port)
+{
+	return !!port->dn;
+}
+
+static bool dsa_port_is_dsa(struct dsa_port *port)
 {
 	const char *name;
 
-	name = of_get_property(port, "label", NULL);
+	name = of_get_property(port->dn, "label", NULL);
 	if (!name)
 		return false;
 
@@ -91,11 +96,11 @@ static bool dsa_port_is_dsa(struct device_node *port)
 	return false;
 }
 
-static bool dsa_port_is_cpu(struct device_node *port)
+static bool dsa_port_is_cpu(struct dsa_port *port)
 {
 	const char *name;
 
-	name = of_get_property(port, "label", NULL);
+	name = of_get_property(port->dn, "label", NULL);
 	if (!name)
 		return false;
 
@@ -136,7 +141,7 @@ static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
 
 static int dsa_port_complete(struct dsa_switch_tree *dst,
 			     struct dsa_switch *src_ds,
-			     struct device_node *port,
+			     struct dsa_port *port,
 			     u32 src_port)
 {
 	struct device_node *link;
@@ -144,7 +149,7 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
 	struct dsa_switch *dst_ds;
 
 	for (index = 0;; index++) {
-		link = of_parse_phandle(port, "link", index);
+		link = of_parse_phandle(port->dn, "link", index);
 		if (!link)
 			break;
 
@@ -167,13 +172,13 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
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
@@ -213,7 +218,7 @@ static int dsa_dst_complete(struct dsa_switch_tree *dst)
 	return 0;
 }
 
-static int dsa_dsa_port_apply(struct device_node *port, u32 index,
+static int dsa_dsa_port_apply(struct dsa_port *port, u32 index,
 			      struct dsa_switch *ds)
 {
 	int err;
@@ -228,13 +233,13 @@ static int dsa_dsa_port_apply(struct device_node *port, u32 index,
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
@@ -251,7 +256,7 @@ static int dsa_cpu_port_apply(struct device_node *port, u32 index,
 	return 0;
 }
 
-static void dsa_cpu_port_unapply(struct device_node *port, u32 index,
+static void dsa_cpu_port_unapply(struct dsa_port *port, u32 index,
 				 struct dsa_switch *ds)
 {
 	dsa_cpu_dsa_destroy(port);
@@ -259,13 +264,13 @@ static void dsa_cpu_port_unapply(struct device_node *port, u32 index,
 
 }
 
-static int dsa_user_port_apply(struct device_node *port, u32 index,
+static int dsa_user_port_apply(struct dsa_port *port, u32 index,
 			       struct dsa_switch *ds)
 {
 	const char *name;
 	int err;
 
-	name = of_get_property(port, "label", NULL);
+	name = of_get_property(port->dn, "label", NULL);
 
 	err = dsa_slave_create(ds, ds->dev, index, name);
 	if (err) {
@@ -277,7 +282,7 @@ static int dsa_user_port_apply(struct device_node *port, u32 index,
 	return 0;
 }
 
-static void dsa_user_port_unapply(struct device_node *port, u32 index,
+static void dsa_user_port_unapply(struct dsa_port *port, u32 index,
 				  struct dsa_switch *ds)
 {
 	if (ds->ports[index].netdev) {
@@ -289,7 +294,7 @@ static void dsa_user_port_unapply(struct device_node *port, u32 index,
 
 static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 {
-	struct device_node *port;
+	struct dsa_port *port;
 	u32 index;
 	int err;
 
@@ -325,8 +330,8 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	}
 
 	for (index = 0; index < DSA_MAX_PORTS; index++) {
-		port = ds->ports[index].dn;
-		if (!port)
+		port = &ds->ports[index];
+		if (!dsa_port_is_valid(port))
 			continue;
 
 		if (dsa_port_is_dsa(port)) {
@@ -353,12 +358,12 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 
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
@@ -439,14 +444,14 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	dst->applied = false;
 }
 
-static int dsa_cpu_parse(struct device_node *port, u32 index,
+static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 			 struct dsa_switch_tree *dst,
 			 struct dsa_switch *ds)
 {
 	struct net_device *ethernet_dev;
 	struct device_node *ethernet;
 
-	ethernet = of_parse_phandle(port, "ethernet", 0);
+	ethernet = of_parse_phandle(port->dn, "ethernet", 0);
 	if (!ethernet)
 		return -EINVAL;
 
@@ -478,13 +483,13 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 
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
@@ -545,7 +550,7 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 		 * to have access to a correct value, just like what
 		 * net/dsa/dsa.c::dsa_switch_setup_one does.
 		 */
-		if (!dsa_port_is_cpu(port))
+		if (!dsa_port_is_cpu(&ds->ports[reg]))
 			ds->enabled_port_mask |= 1 << reg;
 	}
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 00077a9c97f4..3dbc9ce10ab0 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -51,8 +51,8 @@ struct dsa_slave_priv {
 /* dsa.c */
 extern char dsa_driver_version[];
 int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
-		      struct device_node *port_dn, int port);
-void dsa_cpu_dsa_destroy(struct device_node *port_dn);
+		      struct dsa_port *dport, int port);
+void dsa_cpu_dsa_destroy(struct dsa_port *dport);
 const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
 int dsa_cpu_port_ethtool_setup(struct dsa_switch *ds);
 void dsa_cpu_port_ethtool_restore(struct dsa_switch *ds);
-- 
2.7.4
