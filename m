From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 8/9] net: dsa: qca8k: use dsa_port's bridge pointer
Date: Fri, 27 Jan 2017 15:29:43 -0500
Message-ID: <20170127202944.28598-9-vivien.didelot@savoirfairelinux.com>
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

Now that DSA exposes the bridge device pointer to which a port belongs,
use it when programming the port based VLANs and thus remove the cache.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/qca8k.c | 12 ++++--------
 drivers/net/dsa/qca8k.h |  1 -
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index c85b187aa3d9..a4fd4ccf7b67 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -746,17 +746,14 @@ qca8k_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
 }
 
 static int
-qca8k_port_bridge_join(struct dsa_switch *ds, int port,
-		       struct net_device *bridge)
+qca8k_port_bridge_join(struct dsa_switch *ds, int port, struct net_device *br)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 	int port_mask = BIT(QCA8K_CPU_PORT);
 	int i;
 
-	priv->port_sts[port].bridge_dev = bridge;
-
 	for (i = 1; i < QCA8K_NUM_PORTS; i++) {
-		if (priv->port_sts[i].bridge_dev != bridge)
+		if (ds->ports[i].bridge_dev != br)
 			continue;
 		/* Add this port to the portvlan mask of the other ports
 		 * in the bridge
@@ -781,8 +778,7 @@ qca8k_port_bridge_leave(struct dsa_switch *ds, int port, struct net_device *br)
 	int i;
 
 	for (i = 1; i < QCA8K_NUM_PORTS; i++) {
-		if (priv->port_sts[i].bridge_dev !=
-		    priv->port_sts[port].bridge_dev)
+		if (ds->ports[i].bridge_dev != br)
 			continue;
 		/* Remove this port to the portvlan mask of the other ports
 		 * in the bridge
@@ -791,7 +787,7 @@ qca8k_port_bridge_leave(struct dsa_switch *ds, int port, struct net_device *br)
 				QCA8K_PORT_LOOKUP_CTRL(i),
 				BIT(port));
 	}
-	priv->port_sts[port].bridge_dev = NULL;
+
 	/* Set the cpu port to be the only one in the portvlan mask of
 	 * this port
 	 */
diff --git a/drivers/net/dsa/qca8k.h b/drivers/net/dsa/qca8k.h
index 201464719531..1ed4fac6cd6d 100644
--- a/drivers/net/dsa/qca8k.h
+++ b/drivers/net/dsa/qca8k.h
@@ -157,7 +157,6 @@ enum qca8k_fdb_cmd {
 
 struct ar8xxx_port_status {
 	struct ethtool_eee eee;
-	struct net_device *bridge_dev;
 	int enabled;
 };
 
-- 
2.11.0
