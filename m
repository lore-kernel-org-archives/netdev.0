From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/6] net: dsa: Add support for platform data
Date: Mon, 27 Jun 2016 17:52:43 -0700
Message-ID: <1467075163-15890-7-git-send-email-f.fainelli@gmail.com>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33930 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752080AbcF1Awy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 20:52:54 -0400
Received: by mail-oi0-f65.google.com with SMTP id s17so267678oih.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 17:52:53 -0700 (PDT)
In-Reply-To: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow drivers to use the new DSA API with platform data. Most of the
code in net/dsa/dsa2.c does not rely so much on device_nodes and can get
the same information from platform_data instead.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/platform_data/dsa.h |  61 ++++++++++++++++
 include/net/dsa.h                 |   7 ++
 net/dsa/Kconfig                   |   1 +
 net/dsa/dsa.c                     |  43 +++++++----
 net/dsa/dsa2.c                    | 147 +++++++++++++++++++++++++++++++-------
 5 files changed, 218 insertions(+), 41 deletions(-)
 create mode 100644 include/linux/platform_data/dsa.h

diff --git a/include/linux/platform_data/dsa.h b/include/linux/platform_data/dsa.h
new file mode 100644
index 000000000000..72a91903a88f
--- /dev/null
+++ b/include/linux/platform_data/dsa.h
@@ -0,0 +1,61 @@
+#ifndef __DSA_PDATA_H
+#define __DSA_PDATA_H
+
+#include <linux/kernel.h>
+#include <net/dsa.h>
+#include <linux/phy.h>
+#include <linux/phy_fixed.h>
+
+struct dsa2_port_link {
+	bool		valid;
+	u32		index;
+	unsigned int	port;
+};
+
+struct dsa2_port_data {
+	/*
+	 * Name of the ports, can be unique or a template (e.g: port%d)
+	 */
+	const char *name;
+
+	/*
+	 * PHY interface
+	 */
+	phy_interface_t phy_iface;
+
+	/*
+	 * Fixed PHY status information, if needed by the port (e.g: CPU port)
+	 */
+	struct fixed_phy_status	fixed_phy_status;
+	int link_gpio;
+
+	/*
+	 * Links to other switches in the tree
+	 */
+	struct dsa2_port_link	links[DSA_MAX_SWITCHES];
+};
+
+struct dsa2_platform_data {
+	/*
+	 * Reference to a Linux network interface that connects
+	 * to this switch chip.
+	 */
+	struct device	*netdev;
+
+	/*
+	 * Tree number
+	 */
+	u32 tree;
+
+	/*
+	 * Switch chip index within the tree
+	 */
+	u32 index;
+
+	/*
+	 * Ports layout and description
+	 */
+	struct dsa2_port_data ports[DSA_MAX_PORTS];
+};
+
+#endif /* __DSA_PDATA_H */
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 48dce1fd100a..5e686640fd8e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -83,6 +83,7 @@ struct dsa_platform_data {
 };
 
 struct packet_type;
+struct dsa2_platform_data;
 
 struct dsa_switch_tree {
 	struct list_head	list;
@@ -101,6 +102,7 @@ struct dsa_switch_tree {
 	 * this dsa switch tree instance.
 	 */
 	struct dsa_platform_data	*pd;
+	struct dsa2_platform_data	*pd2;
 
 	/*
 	 * Reference to network device to use, and which tagging
@@ -136,9 +138,14 @@ struct dsa_switch_tree {
 	const struct dsa_device_ops *tag_ops;
 };
 
+struct dsa2_port_data;
+
 struct dsa_port {
+	const char		*name;
 	struct net_device	*netdev;
+	struct phy_device	*phydev;
 	struct device_node	*dn;
+	struct dsa2_port_data	*data;
 };
 
 struct dsa_switch {
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index ff7736f7ff42..a152bafedce5 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -8,6 +8,7 @@ config NET_DSA
 	tristate "Distributed Switch Architecture"
 	depends on HAVE_NET_DSA && NET_SWITCHDEV
 	select PHYLIB
+	select FIXED_PHY
 	---help---
 	  Say Y if you want to enable support for the hardware switches supported
 	  by the Distributed Switch Architecture.
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 9b5ff9814b5e..6a84067a5b18 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -25,6 +25,7 @@
 #include <linux/sysfs.h>
 #include <linux/phy_fixed.h>
 #include <linux/gpio/consumer.h>
+#include <linux/platform_data/dsa.h>
 #include "dsa_priv.h"
 
 char dsa_driver_version[] = "0.1";
@@ -211,10 +212,14 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		      struct dsa_port *dport, int port)
 {
 	struct device_node *port_dn = dport->dn;
+	struct dsa2_port_data *pdata = dport->data;
 	struct phy_device *phydev;
 	int ret, mode;
 
-	if (of_phy_is_fixed_link(port_dn)) {
+	if (!port_dn && !pdata)
+		return 0;
+
+	if (port_dn && of_phy_is_fixed_link(port_dn)) {
 		ret = of_phy_register_fixed_link(port_dn);
 		if (ret) {
 			dev_err(dev, "failed to register fixed PHY\n");
@@ -225,13 +230,25 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		mode = of_get_phy_mode(port_dn);
 		if (mode < 0)
 			mode = PHY_INTERFACE_MODE_NA;
-		phydev->interface = mode;
+	} else if (pdata->fixed_phy_status.speed != 0) {
+		phydev = fixed_phy_register(PHY_POLL, &pdata->fixed_phy_status,
+					    pdata->link_gpio,
+					    NULL);
+		if (IS_ERR(phydev)) {
+			dev_err(dev, "failed to register fixed PHY\n");
+			return PTR_ERR(phydev);
+		}
+		mode = pdata->phy_iface;
+	} else
+		return 0;
 
-		genphy_config_init(phydev);
-		genphy_read_status(phydev);
-		if (ds->drv->adjust_link)
-			ds->drv->adjust_link(ds, port, phydev);
-	}
+	dport->phydev = phydev;
+	phydev->interface = mode;
+
+	genphy_config_init(phydev);
+	genphy_read_status(phydev);
+	if (ds->drv->adjust_link)
+		ds->drv->adjust_link(ds, port, phydev);
 
 	return 0;
 }
@@ -497,15 +514,11 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 
 void dsa_cpu_dsa_destroy(struct dsa_port *port)
 {
-	struct device_node *port_dn = port->dn;
-	struct phy_device *phydev;
+	struct phy_device *phydev = port->phydev;
 
-	if (of_phy_is_fixed_link(port_dn)) {
-		phydev = of_phy_find_device(port_dn);
-		if (phydev) {
-			phy_device_free(phydev);
-			fixed_phy_unregister(phydev);
-		}
+	if (phydev) {
+		phy_device_free(phydev);
+		fixed_phy_unregister(phydev);
 	}
 }
 
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index a565bd919aa3..2d3c0e2b1e0e 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -18,6 +18,7 @@
 #include <net/dsa.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
+#include <linux/platform_data/dsa.h>
 #include "dsa_priv.h"
 
 static LIST_HEAD(dsa_switch_trees);
@@ -79,14 +80,15 @@ static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
 
 static bool dsa_port_is_valid(struct dsa_port *port)
 {
-	return !!port->dn;
+	return !!(port->dn || port->name);
 }
 
 static bool dsa_port_is_dsa(struct dsa_port *port)
 {
-	const char *name;
+	const char *name = port->name;
 
-	name = of_get_property(port->dn, "label", NULL);
+	if (port->dn)
+		name = of_get_property(port->dn, "label", NULL);
 	if (!name)
 		return false;
 
@@ -98,9 +100,10 @@ static bool dsa_port_is_dsa(struct dsa_port *port)
 
 static bool dsa_port_is_cpu(struct dsa_port *port)
 {
-	const char *name;
+	const char *name = port->name;
 
-	name = of_get_property(port->dn, "label", NULL);
+	if (port->dn)
+		name = of_get_property(port->dn, "label", NULL);
 	if (!name)
 		return false;
 
@@ -139,22 +142,54 @@ static struct dsa_switch *dsa_dst_find_port_dn(struct dsa_switch_tree *dst,
 	return NULL;
 }
 
+static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
+					    struct dsa2_port_link *link)
+{
+	struct dsa_switch *ds;
+	unsigned int port;
+	u32 index;
+
+	for (index = 0; index < DSA_MAX_SWITCHES; index++) {
+		ds = dst->ds[index];
+		if (!ds)
+			continue;
+
+		if (link->index != index)
+			continue;
+
+		for (port = 0; port < DSA_MAX_PORTS; port++)
+			if (link->port == port)
+				return ds;
+	}
+
+	return NULL;
+}
+
 static int dsa_port_complete(struct dsa_switch_tree *dst,
 			     struct dsa_switch *src_ds,
 			     struct dsa_port *port,
 			     u32 src_port)
 {
 	struct device_node *link;
+	struct dsa2_port_link *plink;
 	int index;
 	struct dsa_switch *dst_ds;
 
 	for (index = 0;; index++) {
-		link = of_parse_phandle(port->dn, "link", index);
-		if (!link)
-			break;
-
-		dst_ds = dsa_dst_find_port_dn(dst, link);
-		of_node_put(link);
+		if (port->dn) {
+			link = of_parse_phandle(port->dn, "link", index);
+			if (!link)
+				break;
+
+			dst_ds = dsa_dst_find_port_dn(dst, link);
+			of_node_put(link);
+		} else {
+			plink = &port->data->links[index];
+			if (!plink->valid)
+				break;
+
+			dst_ds = dsa_dst_find_port(dst, &port->data->links[index]);
+		}
 
 		if (!dst_ds)
 			return 1;
@@ -267,10 +302,11 @@ static void dsa_cpu_port_unapply(struct dsa_port *port, u32 index,
 static int dsa_user_port_apply(struct dsa_port *port, u32 index,
 			       struct dsa_switch *ds)
 {
-	const char *name;
+	const char *name = port->name;
 	int err;
 
-	name = of_get_property(port->dn, "label", NULL);
+	if (port->dn)
+		name = of_get_property(port->dn, "label", NULL);
 
 	err = dsa_slave_create(ds, ds->dev, index, name);
 	if (err) {
@@ -451,11 +487,14 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	struct net_device *ethernet_dev;
 	struct device_node *ethernet;
 
-	ethernet = of_parse_phandle(port->dn, "ethernet", 0);
-	if (!ethernet)
-		return -EINVAL;
+	if (port->dn) {
+		ethernet = of_parse_phandle(port->dn, "ethernet", 0);
+		if (!ethernet)
+			return -EINVAL;
+		ethernet_dev = of_find_net_device_by_node(ethernet);
+	} else
+		ethernet_dev = dev_to_net_device(dst->pd2->netdev);
 
-	ethernet_dev = of_find_net_device_by_node(ethernet);
 	if (!ethernet_dev)
 		return -EPROBE_DEFER;
 
@@ -557,6 +596,37 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 	return 0;
 }
 
+static int dsa_parse_ports(struct dsa2_platform_data *pdata, struct dsa_switch *ds)
+{
+	struct dsa2_port_data *port;
+	bool valid_name_found = false;
+	unsigned int i;
+
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		port = &pdata->ports[i];
+
+		if (!port->name)
+			continue;
+
+		ds->ports[i].name = port->name;
+		ds->ports[i].data = port;
+
+		/* Initialize enabled_port_mask now for drv->setup()
+		 * to have access to a correct value, just like what
+		 * net/dsa/dsa.c::dsa_switch_setup_one does.
+		 */
+		if (!dsa_port_is_cpu(&ds->ports[i]))
+			ds->enabled_port_mask |= 1 << i;
+
+		valid_name_found= true;
+	}
+
+	if (!valid_name_found && i == DSA_MAX_PORTS)
+		return -EINVAL;
+
+	return 0;
+}
+
 static int dsa_parse_member_dn(struct device_node *np, u32 *tree, u32 *index)
 {
 	int err;
@@ -581,6 +651,19 @@ static int dsa_parse_member_dn(struct device_node *np, u32 *tree, u32 *index)
 	return 0;
 }
 
+static int dsa_parse_member(struct dsa2_platform_data *pd, u32 *tree, u32 *index)
+{
+	*tree = *index = 0;
+
+	if (pd->index >= DSA_MAX_SWITCHES)
+		return -EINVAL;
+
+	*tree = pd->tree;
+	*index = pd->index;
+
+	return 0;
+}
+
 static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 					 struct device_node *np)
 {
@@ -597,23 +680,34 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 
 static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
+	struct dsa2_platform_data *pdata = dev->platform_data;
 	struct device_node *np = dev->of_node;
 	struct dsa_switch_tree *dst;
 	struct device_node *ports;
 	u32 tree, index;
 	int err;
 
-	err = dsa_parse_member_dn(np, &tree, &index);
-	if (err)
-		return err;
+	if (np) {
+		err = dsa_parse_member_dn(np, &tree, &index);
+		if (err)
+			return err;
 
-	ports = dsa_get_ports(ds, np);
-	if (IS_ERR(ports))
-		return PTR_ERR(ports);
+		ports = dsa_get_ports(ds, np);
+		if (IS_ERR(ports))
+			return PTR_ERR(ports);
 
-	err = dsa_parse_ports_dn(ports, ds);
-	if (err)
-		return err;
+		err = dsa_parse_ports_dn(ports, ds);
+		if (err)
+			return err;
+	} else {
+		err = dsa_parse_member(pdata, &tree, &index);
+		if (err)
+			return err;
+
+		err = dsa_parse_ports(pdata, ds);
+		if (err)
+			return err;
+	}
 
 	dst = dsa_get_dst(tree);
 	if (!dst) {
@@ -628,6 +722,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	}
 
 	ds->dst = dst;
+	dst->pd2 = pdata;
 	ds->index = index;
 	dsa_dst_add_ds(dst, ds, index);
 
-- 
2.7.4
