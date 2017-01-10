From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/8] net: dsa: Add support for platform data
Date: Tue, 10 Jan 2017 12:12:33 -0800
Message-ID: <20170110201235.21771-7-f.fainelli@gmail.com>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stuart Yoder <stuart.yoder@nxp.com>,
        Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM/Marvell
        Dove/MV78xx0/Orion SOC support),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110201235.21771-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow drivers to use the new DSA API with platform data. Most of the
code in net/dsa/dsa2.c does not rely so much on device_nodes and can get
the same information from platform_data instead.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |  1 +
 net/dsa/dsa2.c    | 96 +++++++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 77 insertions(+), 20 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index b9394379affb..f00ed7549a6e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -140,6 +140,7 @@ struct dsa_switch_tree {
 };
 
 struct dsa_port {
+	const char		*name;
 	struct net_device	*netdev;
 	struct device_node	*dn;
 	unsigned int		ageing_time;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index ddee540d9a83..7adda4b94934 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -81,14 +81,15 @@ static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
 
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
 
@@ -100,9 +101,10 @@ static bool dsa_port_is_dsa(struct dsa_port *port)
 
 static bool dsa_port_is_cpu(struct dsa_port *port)
 {
-	const char *name;
+	const char *name = port->name;
 
-	name = of_get_property(port->dn, "label", NULL);
+	if (port->dn)
+		name = of_get_property(port->dn, "label", NULL);
 	if (!name)
 		return false;
 
@@ -269,10 +271,11 @@ static void dsa_cpu_port_unapply(struct dsa_port *port, u32 index,
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
@@ -452,11 +455,14 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
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
+		ethernet_dev = dev_to_net_device(dst->pd->netdev);
 
-	ethernet_dev = of_find_net_device_by_node(ethernet);
 	if (!ethernet_dev)
 		return -EPROBE_DEFER;
 
@@ -559,6 +565,33 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 	return 0;
 }
 
+static int dsa_parse_ports(struct dsa_chip_data *cd, struct dsa_switch *ds)
+{
+	bool valid_name_found = false;
+	unsigned int i;
+
+	for (i = 0; i < DSA_MAX_PORTS; i++) {
+		if (!cd->port_names[i])
+			continue;
+
+		ds->ports[i].name = cd->port_names[i];
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
@@ -583,6 +616,17 @@ static int dsa_parse_member_dn(struct device_node *np, u32 *tree, u32 *index)
 	return 0;
 }
 
+static int dsa_parse_member(struct dsa_platform_data *pd, u32 *tree, u32 *index)
+{
+	*tree = *index = 0;
+
+	/* TODO, re-design platform data? */
+	if (pd->nr_chips >= DSA_MAX_SWITCHES || !pd->chip)
+		return -EINVAL;
+
+	return 0;
+}
+
 static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 					 struct device_node *np)
 {
@@ -599,23 +643,34 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 
 static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
+	struct dsa_platform_data *pdata = dev->platform_data;
 	struct device_node *np = dev->of_node;
 	struct dsa_switch_tree *dst;
 	struct device_node *ports;
 	u32 tree, index;
 	int i, err;
 
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
+		err = dsa_parse_ports(&pdata->chip[index], ds);
+		if (err)
+			return err;
+	}
 
 	dst = dsa_get_dst(tree);
 	if (!dst) {
@@ -630,6 +685,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	}
 
 	ds->dst = dst;
+	dst->pd = pdata;
 	ds->index = index;
 
 	/* Initialize the routing table */
-- 
2.9.3
