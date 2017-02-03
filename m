From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/6] net: dsa: change state setter scope
Date: Fri,  3 Feb 2017 13:20:19 -0500
Message-ID: <20170203182021.14246-5-vivien.didelot@savoirfairelinux.com>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The scope of the functions inside net/dsa/slave.c must be the slave
net_device pointer. Change to state setter helper accordingly to
simplify callers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d726307c7795..d8c3c0f00cf3 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -74,9 +74,12 @@ static inline bool dsa_port_is_bridged(struct dsa_port *dp)
 	return !!dp->bridge_dev;
 }
 
-static void dsa_port_set_stp_state(struct dsa_switch *ds, int port, u8 state)
+static void dsa_slave_set_state(struct net_device *dev, u8 state)
 {
-	struct dsa_port *dp = &ds->ports[port];
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
+	struct dsa_switch *ds = dp->ds;
+	int port = dp->index;
 
 	if (ds->ops->port_stp_state_set)
 		ds->ops->port_stp_state_set(ds, port, state);
@@ -133,7 +136,7 @@ static int dsa_slave_open(struct net_device *dev)
 			goto clear_promisc;
 	}
 
-	dsa_port_set_stp_state(ds, p->dp->index, stp_state);
+	dsa_slave_set_state(dev, stp_state);
 
 	if (p->phy)
 		phy_start(p->phy);
@@ -175,7 +178,7 @@ static int dsa_slave_close(struct net_device *dev)
 	if (ds->ops->port_disable)
 		ds->ops->port_disable(ds, p->dp->index, p->phy);
 
-	dsa_port_set_stp_state(ds, p->dp->index, BR_STATE_DISABLED);
+	dsa_slave_set_state(dev, BR_STATE_DISABLED);
 
 	return 0;
 }
@@ -382,7 +385,7 @@ static int dsa_slave_stp_state_set(struct net_device *dev,
 	if (switchdev_trans_ph_prepare(trans))
 		return ds->ops->port_stp_state_set ? 0 : -EOPNOTSUPP;
 
-	dsa_port_set_stp_state(ds, p->dp->index, attr->u.stp_state);
+	dsa_slave_set_state(dev, attr->u.stp_state);
 
 	return 0;
 }
@@ -596,7 +599,7 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev,
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
 	 */
-	dsa_port_set_stp_state(ds, p->dp->index, BR_STATE_FORWARDING);
+	dsa_slave_set_state(dev, BR_STATE_FORWARDING);
 }
 
 static int dsa_slave_port_attr_get(struct net_device *dev,
-- 
2.11.0
