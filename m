From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/8] net: dsa: Make most functions take a dsa_port
 argument
Date: Tue, 10 Jan 2017 12:12:29 -0800
Message-ID: <20170110201235.21771-3-f.fainelli@gmail.com>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 open list <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>,
 Stuart Yoder <stuart.yoder@nxp.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Philippe Reynes <tremyfr@gmail.com>, "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
 <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170110201235.21771-1-f.fainelli@gmail.com>
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
index fd532487dfdf..2306d1b87c83 100644
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
@@ -366,8 +367,10 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
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
@@ -393,7 +396,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
-		dsa_cpu_dsa_destroy(ds->ports[port].dn);
+		dsa_cpu_dsa_destroy(&ds->ports[port]);
 
 		/* Clearing a bit which is not set does no harm */
 		ds->cpu_port_mask |= ~(1 << port);
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index f0e3212ae9d5..91141ac6ec18 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -79,11 +79,16 @@ static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
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
 
@@ -93,11 +98,11 @@ static bool dsa_port_is_dsa(struct device_node *port)
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
 
@@ -138,7 +143,7 @@ static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
 
 static int dsa_port_complete(struct dsa_switch_tree *dst,
 			     struct dsa_switch *src_ds,
-			     struct device_node *port,
+			     struct dsa_port *port,
 			     u32 src_port)
 {
 	struct device_node *link;
@@ -146,7 +151,7 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
 	struct dsa_switch *dst_ds;
 
 	for (index = 0;; index++) {
-		link = of_parse_phandle(port, "link", index);
+		link = of_parse_phandle(port->dn, "link", index);
 		if (!link)
 			break;
 
@@ -169,13 +174,13 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
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
@@ -215,7 +220,7 @@ static int dsa_dst_complete(struct dsa_switch_tree *dst)
 	return 0;
 }
 
-static int dsa_dsa_port_apply(struct device_node *port, u32 index,
+static int dsa_dsa_port_apply(struct dsa_port *port, u32 index,
 			      struct dsa_switch *ds)
 {
 	int err;
@@ -230,13 +235,13 @@ static int dsa_dsa_port_apply(struct device_node *port, u32 index,
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
@@ -253,7 +258,7 @@ static int dsa_cpu_port_apply(struct device_node *port, u32 index,
 	return 0;
 }
 
-static void dsa_cpu_port_unapply(struct device_node *port, u32 index,
+static void dsa_cpu_port_unapply(struct dsa_port *port, u32 index,
 				 struct dsa_switch *ds)
 {
 	dsa_cpu_dsa_destroy(port);
@@ -261,13 +266,13 @@ static void dsa_cpu_port_unapply(struct device_node *port, u32 index,
 
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
@@ -279,7 +284,7 @@ static int dsa_user_port_apply(struct device_node *port, u32 index,
 	return 0;
 }
 
-static void dsa_user_port_unapply(struct device_node *port, u32 index,
+static void dsa_user_port_unapply(struct dsa_port *port, u32 index,
 				  struct dsa_switch *ds)
 {
 	if (ds->ports[index].netdev) {
@@ -291,7 +296,7 @@ static void dsa_user_port_unapply(struct device_node *port, u32 index,
 
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
@@ -439,7 +444,7 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	dst->applied = false;
 }
 
-static int dsa_cpu_parse(struct device_node *port, u32 index,
+static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 			 struct dsa_switch_tree *dst,
 			 struct dsa_switch *ds)
 {
@@ -447,7 +452,7 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 	struct net_device *ethernet_dev;
 	struct device_node *ethernet;
 
-	ethernet = of_parse_phandle(port, "ethernet", 0);
+	ethernet = of_parse_phandle(port->dn, "ethernet", 0);
 	if (!ethernet)
 		return -EINVAL;
 
@@ -480,13 +485,13 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
 
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
@@ -547,7 +552,7 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 		 * to have access to a correct value, just like what
 		 * net/dsa/dsa.c::dsa_switch_setup_one does.
 		 */
-		if (!dsa_port_is_cpu(port))
+		if (!dsa_port_is_cpu(&ds->ports[reg]))
 			ds->enabled_port_mask |= 1 << reg;
 	}
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7e3385ec73f4..a015ec97c289 100644
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
