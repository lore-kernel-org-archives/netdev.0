From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 08/10] net: dsa: Add support for platform data
Date: Tue, 17 Jan 2017 15:21:50 -0800
Message-ID: <20170117232152.1661-9-f.fainelli@gmail.com>
References: <20170117232152.1661-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Russell King <linux@armlinux.org.uk>, open list <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
 <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170117232152.1661-1-f.fainelli@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Allow drivers to use the new DSA API with platform data. Most of the
code in net/dsa/dsa2.c does not rely so much on device_nodes and can get
the same information from platform_data instead.

We purposely do not support distributed configurations with platform
data, so drivers should be providing a pointer to a 'struct
dsa_chip_data' structure if they wish to communicate per-port layout.

Multiple CPUs port could potentially be supported and dsa_chip_data is
extended to receive up to one reference to an upstream network device
per port described by a dsa_chip_data structure.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h |   6 ++++
 net/dsa/dsa2.c    | 102 ++++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 90 insertions(+), 18 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 16a502a6c26a..491008792e4d 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -42,6 +42,11 @@ struct dsa_chip_data {
 	struct device	*host_dev;
 	int		sw_addr;
 
+	/*
+	 * Reference to network devices
+	 */
+	struct device	*netdev[DSA_MAX_PORTS];
+
 	/* set to size of eeprom if supported by the switch */
 	int		eeprom_len;
 
@@ -140,6 +145,7 @@ struct dsa_switch_tree {
 };
 
 struct dsa_port {
+	const char		*name;
 	struct net_device	*netdev;
 	struct device_node	*dn;
 	unsigned int		ageing_time;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index cd91070b5467..761e8724423f 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -79,19 +79,28 @@ static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
 	kref_put(&dst->refcount, dsa_free_dst);
 }
 
+/* For platform data configurations, we need to have a valid name argument to
+ * differentiate a disabled port from an enabled one
+ */
 static bool dsa_port_is_valid(struct dsa_port *port)
 {
-	return !!port->dn;
+	return !!(port->dn || port->name);
 }
 
 static bool dsa_port_is_dsa(struct dsa_port *port)
 {
-	return !!of_parse_phandle(port->dn, "link", 0);
+	if (port->name && !strcmp(port->name, "dsa"))
+		return true;
+	else
+		return !!of_parse_phandle(port->dn, "link", 0);
 }
 
 static bool dsa_port_is_cpu(struct dsa_port *port)
 {
-	return !!of_parse_phandle(port->dn, "ethernet", 0);
+	if (port->name && !strcmp(port->name, "cpu"))
+		return true;
+	else
+		return !!of_parse_phandle(port->dn, "ethernet", 0);
 }
 
 static bool dsa_ds_find_port_dn(struct dsa_switch *ds,
@@ -251,10 +260,11 @@ static void dsa_cpu_port_unapply(struct dsa_port *port, u32 index,
 static int dsa_user_port_apply(struct dsa_port *port, u32 index,
 			       struct dsa_switch *ds)
 {
-	const char *name;
+	const char *name = port->name;
 	int err;
 
-	name = of_get_property(port->dn, "label", NULL);
+	if (port->dn)
+		name = of_get_property(port->dn, "label", NULL);
 	if (!name)
 		name = "eth%d";
 
@@ -439,11 +449,15 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
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
+	} else {
+		ethernet_dev = device_to_net_device(ds->cd->netdev[index]);
+	}
 
-	ethernet_dev = of_find_net_device_by_node(ethernet);
 	if (!ethernet_dev)
 		return -EPROBE_DEFER;
 
@@ -462,6 +476,7 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 	dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 	if (IS_ERR(dst->tag_ops)) {
 		dev_warn(ds->dev, "No tagger for this switch\n");
+		dev_put(ethernet_dev);
 		return PTR_ERR(dst->tag_ops);
 	}
 
@@ -546,6 +561,33 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
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
+		valid_name_found = true;
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
@@ -570,6 +612,18 @@ static int dsa_parse_member_dn(struct device_node *np, u32 *tree, u32 *index)
 	return 0;
 }
 
+static int dsa_parse_member(struct dsa_chip_data *pd, u32 *tree, u32 *index)
+{
+	if (!pd)
+		return -ENODEV;
+
+	/* We do not support complex trees with dsa_chip_data */
+	*tree = 0;
+	*index = 0;
+
+	return 0;
+}
+
 static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 					 struct device_node *np)
 {
@@ -586,23 +640,34 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 
 static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
+	struct dsa_chip_data *pdata = dev->platform_data;
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
+		err = dsa_parse_ports(pdata, ds);
+		if (err)
+			return err;
+	}
 
 	dst = dsa_get_dst(tree);
 	if (!dst) {
@@ -618,6 +683,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 
 	ds->dst = dst;
 	ds->index = index;
+	ds->cd = pdata;
 
 	/* Initialize the routing table */
 	for (i = 0; i < DSA_MAX_SWITCHES; ++i)
-- 
2.9.3
