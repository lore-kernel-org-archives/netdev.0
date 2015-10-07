From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/6] net: dsa: add port_fdb_prepare
Date: Wed,  7 Oct 2015 19:48:29 -0400
Message-ID: <1444261711-1829-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Push the prepare phase for FDB operations down to the DSA drivers, with
a new port_fdb_prepare function. Currently only mv88e6xxx is affected.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6171.c |  1 +
 drivers/net/dsa/mv88e6352.c |  1 +
 drivers/net/dsa/mv88e6xxx.c | 10 ++++++++++
 drivers/net/dsa/mv88e6xxx.h |  3 +++
 include/net/dsa.h           |  4 ++++
 net/dsa/slave.c             |  7 +++++--
 6 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index c95cfab..ca3330a 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -121,6 +121,7 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.vlan_getnext		= mv88e6xxx_vlan_getnext,
+	.port_fdb_prepare	= mv88e6xxx_port_fdb_prepare,
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
 	.port_fdb_del		= mv88e6xxx_port_fdb_del,
 	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 3736706..078a358 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -348,6 +348,7 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
 	.port_vlan_del		= mv88e6xxx_port_vlan_del,
 	.vlan_getnext		= mv88e6xxx_vlan_getnext,
+	.port_fdb_prepare	= mv88e6xxx_port_fdb_prepare,
 	.port_fdb_add		= mv88e6xxx_port_fdb_add,
 	.port_fdb_del		= mv88e6xxx_port_fdb_del,
 	.port_fdb_getnext	= mv88e6xxx_port_fdb_getnext,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6053d11..9fbb727 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1841,6 +1841,16 @@ static int _mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port,
 	return _mv88e6xxx_atu_load(ds, &entry);
 }
 
+int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
+			       const struct switchdev_obj_port_fdb *fdb,
+			       struct switchdev_trans *trans)
+{
+	/* We don't need any dynamic resource from the kernel (yet),
+	 * so skip the prepare phase.
+	 */
+	return 0;
+}
+
 int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid)
 {
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 39b261f..4475640 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -479,6 +479,9 @@ int mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
 int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid);
 int mv88e6xxx_vlan_getnext(struct dsa_switch *ds, u16 *vid,
 			   unsigned long *ports, unsigned long *untagged);
+int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
+			       const struct switchdev_obj_port_fdb *fdb,
+			       struct switchdev_trans *trans);
 int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid);
 int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 3e9eb6c..3aee8a5 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -19,6 +19,7 @@
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
 #include <linux/ethtool.h>
+#include <net/switchdev.h>
 
 enum dsa_tag_protocol {
 	DSA_TAG_PROTO_NONE = 0,
@@ -316,6 +317,9 @@ struct dsa_switch_driver {
 	/*
 	 * Forwarding database
 	 */
+	int	(*port_fdb_prepare)(struct dsa_switch *ds, int port,
+				    const struct switchdev_obj_port_fdb *fdb,
+				    struct switchdev_trans *trans);
 	int	(*port_fdb_add)(struct dsa_switch *ds, int port,
 				const unsigned char *addr, u16 vid);
 	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 4f607bc..48e8c15 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -346,10 +346,13 @@ static int dsa_slave_port_fdb_add(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
+	int ret;
+
+	if (!ds->drv->port_fdb_prepare || !ds->drv->port_fdb_add)
+		return -EOPNOTSUPP;
 
 	if (switchdev_trans_ph_prepare(trans))
-		ret = ds->drv->port_fdb_add ? 0 : -EOPNOTSUPP;
+		ret = ds->drv->port_fdb_prepare(ds, p->port, fdb, trans);
 	else
 		ret = ds->drv->port_fdb_add(ds, p->port, fdb->addr, fdb->vid);
 
-- 
2.6.0
