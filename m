From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/4] net: dsa: add port STP state helper
Date: Thu, 22 Sep 2016 16:49:21 -0400
Message-ID: <20160922204924.16229-2-vivien.didelot@savoirfairelinux.com>
References: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a void helper to set the STP state of a port, checking first if the
required routine is provided by the driver.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9ecbe78..fd78d4c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -69,6 +69,12 @@ static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
 	return !!p->bridge_dev;
 }
 
+static void dsa_port_set_stp_state(struct dsa_switch *ds, int port, u8 state)
+{
+	if (ds->ops->port_stp_state_set)
+		ds->ops->port_stp_state_set(ds, port, state);
+}
+
 static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -104,8 +110,7 @@ static int dsa_slave_open(struct net_device *dev)
 			goto clear_promisc;
 	}
 
-	if (ds->ops->port_stp_state_set)
-		ds->ops->port_stp_state_set(ds, p->port, stp_state);
+	dsa_port_set_stp_state(ds, p->port, stp_state);
 
 	if (p->phy)
 		phy_start(p->phy);
@@ -147,8 +152,7 @@ static int dsa_slave_close(struct net_device *dev)
 	if (ds->ops->port_disable)
 		ds->ops->port_disable(ds, p->port, p->phy);
 
-	if (ds->ops->port_stp_state_set)
-		ds->ops->port_stp_state_set(ds, p->port, BR_STATE_DISABLED);
+	dsa_port_set_stp_state(ds, p->port, BR_STATE_DISABLED);
 
 	return 0;
 }
@@ -354,7 +358,7 @@ static int dsa_slave_stp_state_set(struct net_device *dev,
 	if (switchdev_trans_ph_prepare(trans))
 		return ds->ops->port_stp_state_set ? 0 : -EOPNOTSUPP;
 
-	ds->ops->port_stp_state_set(ds, p->port, attr->u.stp_state);
+	dsa_port_set_stp_state(ds, p->port, attr->u.stp_state);
 
 	return 0;
 }
@@ -556,8 +560,7 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev)
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
 	 */
-	if (ds->ops->port_stp_state_set)
-		ds->ops->port_stp_state_set(ds, p->port, BR_STATE_FORWARDING);
+	dsa_port_set_stp_state(ds, p->port, BR_STATE_FORWARDING);
 }
 
 static int dsa_slave_port_attr_get(struct net_device *dev,
-- 
2.10.0
