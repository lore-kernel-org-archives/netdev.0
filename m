From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 03/20] net: dsa: change scope of bridging code
Date: Fri, 19 May 2017 17:00:38 -0400
Message-ID: <20170519210055.9366-4-vivien.didelot@savoirfairelinux.com>
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

Now that the bridge join and leave functions only deal with a DSA port,
change their scope from the DSA slave net_device to the DSA generic
dsa_port.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 36 +++++++++++++++++-------------------
 1 file changed, 17 insertions(+), 19 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 371f6d267917..1ad62ef8c261 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -572,13 +572,11 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	return err;
 }
 
-static int dsa_slave_bridge_port_join(struct net_device *dev,
-				      struct net_device *br)
+static int dsa_port_bridge_join(struct dsa_port *dp, struct net_device *br)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_notifier_bridge_info info = {
-		.sw_index = p->dp->ds->index,
-		.port = p->dp->index,
+		.sw_index = dp->ds->index,
+		.port = dp->index,
 		.br = br,
 	};
 	int err;
@@ -586,24 +584,22 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 	/* Here the port is already bridged. Reflect the current configuration
 	 * so that drivers can program their chips accordingly.
 	 */
-	p->dp->bridge_dev = br;
+	dp->bridge_dev = br;
 
-	err = dsa_port_notify(p->dp, DSA_NOTIFIER_BRIDGE_JOIN, &info);
+	err = dsa_port_notify(dp, DSA_NOTIFIER_BRIDGE_JOIN, &info);
 
 	/* The bridging is rolled back on error */
 	if (err)
-		p->dp->bridge_dev = NULL;
+		dp->bridge_dev = NULL;
 
 	return err;
 }
 
-static void dsa_slave_bridge_port_leave(struct net_device *dev,
-					struct net_device *br)
+static void dsa_port_bridge_leave(struct dsa_port *dp, struct net_device *br)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_notifier_bridge_info info = {
-		.sw_index = p->dp->ds->index,
-		.port = p->dp->index,
+		.sw_index = dp->ds->index,
+		.port = dp->index,
 		.br = br,
 	};
 	int err;
@@ -611,16 +607,16 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev,
 	/* Here the port is already unbridged. Reflect the current configuration
 	 * so that drivers can program their chips accordingly.
 	 */
-	p->dp->bridge_dev = NULL;
+	dp->bridge_dev = NULL;
 
-	err = dsa_port_notify(p->dp, DSA_NOTIFIER_BRIDGE_LEAVE, &info);
+	err = dsa_port_notify(dp, DSA_NOTIFIER_BRIDGE_LEAVE, &info);
 	if (err)
-		netdev_err(dev, "failed to notify DSA_NOTIFIER_BRIDGE_LEAVE\n");
+		pr_err("DSA: failed to notify DSA_NOTIFIER_BRIDGE_LEAVE\n");
 
 	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
 	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
 	 */
-	dsa_port_set_state_now(p->dp, BR_STATE_FORWARDING);
+	dsa_port_set_state_now(dp, BR_STATE_FORWARDING);
 }
 
 static int dsa_slave_port_attr_get(struct net_device *dev,
@@ -1526,14 +1522,16 @@ static bool dsa_slave_dev_check(struct net_device *dev)
 static int dsa_slave_changeupper(struct net_device *dev,
 				 struct netdev_notifier_changeupper_info *info)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_port *dp = p->dp;
 	int err = NOTIFY_DONE;
 
 	if (netif_is_bridge_master(info->upper_dev)) {
 		if (info->linking) {
-			err = dsa_slave_bridge_port_join(dev, info->upper_dev);
+			err = dsa_port_bridge_join(dp, info->upper_dev);
 			err = notifier_from_errno(err);
 		} else {
-			dsa_slave_bridge_port_leave(dev, info->upper_dev);
+			dsa_port_bridge_leave(dp, info->upper_dev);
 			err = NOTIFY_OK;
 		}
 	}
-- 
2.13.0
