From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 1/3] net: dsa: add cross-chip notification for bridge
Date: Wed, 20 Apr 2016 16:26:07 -0400
Message-ID: <1461183969-24610-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461183969-24610-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461183969-24610-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When multiple switch chips are chained together, one needs to know about
the bridge membership of others. For instance, switches like Marvell
6352 have cross-chip port-based VLAN table to allow or forbid cross-chip
frames to egress.

Add a cross_chip_bridge DSA driver function, used to notify a switch
about bridge membership configured in other chips.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  6 ++++++
 net/dsa/slave.c   | 60 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 62 insertions(+), 4 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index c4bc42b..1994fa7 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -340,6 +340,12 @@ struct dsa_switch_driver {
 	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
 				 struct switchdev_obj_port_fdb *fdb,
 				 int (*cb)(struct switchdev_obj *obj));
+
+	/*
+	 * Cross-chip notifications
+	 */
+	void	(*cross_chip_bridge)(struct dsa_switch *ds, int sw_index,
+				     int sw_port, struct net_device *bridge);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3b6750f..bd8f4e2 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -431,19 +431,68 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	return err;
 }
 
+static void dsa_slave_broadcast_bridge(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int chip;
+
+	for (chip = 0; chip < ds->dst->pd->nr_chips; ++chip) {
+		struct dsa_switch *sw = ds->dst->ds[chip];
+
+		if (sw->index == ds->index)
+			continue;
+
+		if (sw->drv->cross_chip_bridge)
+			sw->drv->cross_chip_bridge(sw, ds->index, p->port,
+						   p->bridge_dev);
+	}
+}
+
+static void dsa_tree_broadcast_bridge(struct dsa_switch_tree *dst,
+				      struct net_device *bridge)
+{
+	struct net_device *dev;
+	struct dsa_slave_priv *p;
+	struct dsa_switch *ds;
+	int chip, port;
+
+	for (chip = 0; chip < dst->pd->nr_chips; ++chip) {
+		ds = dst->ds[chip];
+
+		for (port = 0; port < DSA_MAX_PORTS; ++port) {
+			if (!ds->ports[port])
+				continue;
+
+			dev = ds->ports[port];
+			p = netdev_priv(dev);
+
+			if (p->bridge_dev == bridge)
+				dsa_slave_broadcast_bridge(dev);
+		}
+	}
+}
+
 static int dsa_slave_bridge_port_join(struct net_device *dev,
 				      struct net_device *br)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	int ret = -EOPNOTSUPP;
+	int err;
 
 	p->bridge_dev = br;
 
-	if (ds->drv->port_bridge_join)
-		ret = ds->drv->port_bridge_join(ds, p->port, br);
+	/* In-chip hardware bridging */
+	if (ds->drv->port_bridge_join) {
+		err = ds->drv->port_bridge_join(ds, p->port, br);
+		if (err && err != -EOPNOTSUPP)
+			return err;
+	}
+
+	/* Broadcast bridge membership across chips */
+	dsa_tree_broadcast_bridge(ds->dst, br);
 
-	return ret == -EOPNOTSUPP ? 0 : ret;
+	return 0;
 }
 
 static void dsa_slave_bridge_port_leave(struct net_device *dev)
@@ -462,6 +511,9 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev)
 	 */
 	if (ds->drv->port_stp_state_set)
 		ds->drv->port_stp_state_set(ds, p->port, BR_STATE_FORWARDING);
+
+	/* Notify the port leaving to other chips */
+	dsa_slave_broadcast_bridge(dev);
 }
 
 static int dsa_slave_port_attr_get(struct net_device *dev,
-- 
2.8.0
