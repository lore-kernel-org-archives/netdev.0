From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/9] net: dsa: pass bridge device when a port leaves
Date: Fri, 27 Jan 2017 15:29:41 -0500
Message-ID: <20170127202944.28598-7-vivien.didelot@savoirfairelinux.com>
References: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upon reception of the NETDEV_CHANGEUPPER, a leaving port is already
unbridged, so reflect this by assigning the port's bridge_dev pointer to
NULL before calling the port_bridge_leave DSA driver operation.

Now that the bridge_dev pointer is exposed to the drivers, reflecting
the current state of the DSA switch fabric is necessary for the drivers
to adjust their port based VLANs correctly.

Pass the bridge device pointer to the port_bridge_leave operation so
that drivers have all information to re-program their chips properly,
and do not need to cache it anymore.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c |  2 +-
 drivers/net/dsa/b53/b53_priv.h   |  2 +-
 drivers/net/dsa/mv88e6xxx/chip.c |  3 ++-
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                |  3 ++-
 net/dsa/slave.c                  | 10 +++++-----
 6 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 31afc4d4b68b..32fdcf5570c8 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1354,7 +1354,7 @@ int b53_br_join(struct dsa_switch *ds, int port, struct net_device *bridge)
 }
 EXPORT_SYMBOL(b53_br_join);
 
-void b53_br_leave(struct dsa_switch *ds, int port)
+void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct b53_device *dev = ds->priv;
 	struct net_device *bridge = dev->ports[port].bridge_dev;
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index a8031b382c55..5dafb70e75fc 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -382,7 +382,7 @@ void b53_get_strings(struct dsa_switch *ds, int port, uint8_t *data);
 void b53_get_ethtool_stats(struct dsa_switch *ds, int port, uint64_t *data);
 int b53_get_sset_count(struct dsa_switch *ds);
 int b53_br_join(struct dsa_switch *ds, int port, struct net_device *bridge);
-void b53_br_leave(struct dsa_switch *ds, int port);
+void b53_br_leave(struct dsa_switch *ds, int port, struct net_device *bridge);
 void b53_br_set_stp_state(struct dsa_switch *ds, int port, u8 state);
 void b53_br_fast_age(struct dsa_switch *ds, int port);
 int b53_vlan_filtering(struct dsa_switch *ds, int port, bool vlan_filtering);
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index cb7b24748336..8eb0dc063f4e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2343,7 +2343,8 @@ static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
+static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port,
+					struct net_device *br)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	struct net_device *bridge = chip->ports[port].bridge_dev;
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index f67c6a3cebff..c85b187aa3d9 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -775,7 +775,7 @@ qca8k_port_bridge_join(struct dsa_switch *ds, int port,
 }
 
 static void
-qca8k_port_bridge_leave(struct dsa_switch *ds, int port)
+qca8k_port_bridge_leave(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 	int i;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 924533fd4425..b951e2ebda75 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -325,7 +325,8 @@ struct dsa_switch_ops {
 	int	(*set_ageing_time)(struct dsa_switch *ds, unsigned int msecs);
 	int	(*port_bridge_join)(struct dsa_switch *ds, int port,
 				    struct net_device *bridge);
-	void	(*port_bridge_leave)(struct dsa_switch *ds, int port);
+	void	(*port_bridge_leave)(struct dsa_switch *ds, int port,
+				     struct net_device *bridge);
 	void	(*port_stp_state_set)(struct dsa_switch *ds, int port,
 				      u8 state);
 	void	(*port_fast_age)(struct dsa_switch *ds, int port);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3a7c28d64bd5..23ff53aeae50 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -565,16 +565,16 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 	return ret == -EOPNOTSUPP ? 0 : ret;
 }
 
-static void dsa_slave_bridge_port_leave(struct net_device *dev)
+static void dsa_slave_bridge_port_leave(struct net_device *dev,
+					struct net_device *br)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
 
+	p->dp->bridge_dev = NULL;
 
 	if (ds->ops->port_bridge_leave)
-		ds->ops->port_bridge_leave(ds, p->dp->index);
-
-	p->dp->bridge_dev = NULL;
+		ds->ops->port_bridge_leave(ds, p->dp->index, br);
 
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
@@ -1343,7 +1343,7 @@ static int dsa_slave_port_upper_event(struct net_device *dev,
 			if (info->linking)
 				err = dsa_slave_bridge_port_join(dev, upper);
 			else
-				dsa_slave_bridge_port_leave(dev);
+				dsa_slave_bridge_port_leave(dev, upper);
 		}
 
 		break;
-- 
2.11.0
