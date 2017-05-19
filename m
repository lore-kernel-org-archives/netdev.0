From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 01/20] net: dsa: change scope of STP state setter
Date: Fri, 19 May 2017 17:00:36 -0400
Message-ID: <20170519210055.9366-2-vivien.didelot@savoirfairelinux.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of having multiple STP state helpers scoping a slave device
supporting both the DSA logic and the switchdev binding, provide a
single dsa_port_set_state helper scoping a DSA port, as well as its
dsa_port_set_state_now wrapper which skips the prepare phase.

This allows us to better separate the DSA logic from the slave device
handling.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 44 ++++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 91236d602301..403d1dfe7f50 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -85,13 +85,15 @@ static inline bool dsa_port_is_bridged(struct dsa_port *dp)
 	return !!dp->bridge_dev;
 }
 
-static void dsa_slave_set_state(struct net_device *dev, u8 state)
+static int dsa_port_set_state(struct dsa_port *dp, u8 state,
+			      struct switchdev_trans *trans)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_port *dp = p->dp;
 	struct dsa_switch *ds = dp->ds;
 	int port = dp->index;
 
+	if (switchdev_trans_ph_prepare(trans))
+		return ds->ops->port_stp_state_set ? 0 : -EOPNOTSUPP;
+
 	if (ds->ops->port_stp_state_set)
 		ds->ops->port_stp_state_set(ds, port, state);
 
@@ -110,6 +112,17 @@ static void dsa_slave_set_state(struct net_device *dev, u8 state)
 	}
 
 	dp->stp_state = state;
+
+	return 0;
+}
+
+static void dsa_port_set_state_now(struct dsa_port *dp, u8 state)
+{
+	int err;
+
+	err = dsa_port_set_state(dp, state, NULL);
+	if (err)
+		pr_err("DSA: failed to set STP state %u (%d)\n", state, err);
 }
 
 static int dsa_slave_open(struct net_device *dev)
@@ -147,7 +160,7 @@ static int dsa_slave_open(struct net_device *dev)
 			goto clear_promisc;
 	}
 
-	dsa_slave_set_state(dev, stp_state);
+	dsa_port_set_state_now(p->dp, stp_state);
 
 	if (p->phy)
 		phy_start(p->phy);
@@ -189,7 +202,7 @@ static int dsa_slave_close(struct net_device *dev)
 	if (ds->ops->port_disable)
 		ds->ops->port_disable(ds, p->dp->index, p->phy);
 
-	dsa_slave_set_state(dev, BR_STATE_DISABLED);
+	dsa_port_set_state_now(p->dp, BR_STATE_DISABLED);
 
 	return 0;
 }
@@ -386,21 +399,6 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
-static int dsa_slave_stp_state_set(struct net_device *dev,
-				   const struct switchdev_attr *attr,
-				   struct switchdev_trans *trans)
-{
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->dp->ds;
-
-	if (switchdev_trans_ph_prepare(trans))
-		return ds->ops->port_stp_state_set ? 0 : -EOPNOTSUPP;
-
-	dsa_slave_set_state(dev, attr->u.stp_state);
-
-	return 0;
-}
-
 static int dsa_slave_vlan_filtering(struct net_device *dev,
 				    const struct switchdev_attr *attr,
 				    struct switchdev_trans *trans)
@@ -465,11 +463,13 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 				   const struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
 	int ret;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
-		ret = dsa_slave_stp_state_set(dev, attr, trans);
+		ret = dsa_port_set_state(dp, attr->u.stp_state, trans);
 		break;
 	case SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING:
 		ret = dsa_slave_vlan_filtering(dev, attr, trans);
@@ -621,7 +621,7 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev,
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
 	 */
-	dsa_slave_set_state(dev, BR_STATE_FORWARDING);
+	dsa_port_set_state_now(p->dp, BR_STATE_FORWARDING);
 }
 
 static int dsa_slave_port_attr_get(struct net_device *dev,
-- 
2.13.0
