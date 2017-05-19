From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 10/20] net: dsa: move bridging routines
Date: Fri, 19 May 2017 17:00:45 -0400
Message-ID: <20170519210055.9366-11-vivien.didelot@savoirfairelinux.com>
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

Move the DSA port code which bridges a port in port.c, where it belongs.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |  2 ++
 net/dsa/port.c     | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/slave.c    | 57 -----------------------------------------------------
 3 files changed, 60 insertions(+), 57 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index cda218cd9b05..f0b6cd3c8a65 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -64,6 +64,8 @@ void dsa_legacy_unregister(void);
 int dsa_port_set_state(struct dsa_port *dp, u8 state,
 		       struct switchdev_trans *trans);
 void dsa_port_set_state_now(struct dsa_port *dp, u8 state);
+int dsa_port_bridge_join(struct dsa_port *dp, struct net_device *br);
+void dsa_port_bridge_leave(struct dsa_port *dp, struct net_device *br);
 
 /* slave.c */
 extern const struct dsa_device_ops notag_netdev_ops;
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 6cc4704190fd..da8577fb3d07 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -11,9 +11,20 @@
  */
 
 #include <linux/if_bridge.h>
+#include <linux/notifier.h>
 
 #include "dsa_priv.h"
 
+static int dsa_port_notify(struct dsa_port *dp, unsigned long e, void *v)
+{
+	struct raw_notifier_head *nh = &dp->ds->dst->nh;
+	int err;
+
+	err = raw_notifier_call_chain(nh, e, v);
+
+	return notifier_to_errno(err);
+}
+
 int dsa_port_set_state(struct dsa_port *dp, u8 state,
 		       struct switchdev_trans *trans)
 {
@@ -53,3 +64,50 @@ void dsa_port_set_state_now(struct dsa_port *dp, u8 state)
 	if (err)
 		pr_err("DSA: failed to set STP state %u (%d)\n", state, err);
 }
+
+int dsa_port_bridge_join(struct dsa_port *dp, struct net_device *br)
+{
+	struct dsa_notifier_bridge_info info = {
+		.sw_index = dp->ds->index,
+		.port = dp->index,
+		.br = br,
+	};
+	int err;
+
+	/* Here the port is already bridged. Reflect the current configuration
+	 * so that drivers can program their chips accordingly.
+	 */
+	dp->bridge_dev = br;
+
+	err = dsa_port_notify(dp, DSA_NOTIFIER_BRIDGE_JOIN, &info);
+
+	/* The bridging is rolled back on error */
+	if (err)
+		dp->bridge_dev = NULL;
+
+	return err;
+}
+
+void dsa_port_bridge_leave(struct dsa_port *dp, struct net_device *br)
+{
+	struct dsa_notifier_bridge_info info = {
+		.sw_index = dp->ds->index,
+		.port = dp->index,
+		.br = br,
+	};
+	int err;
+
+	/* Here the port is already unbridged. Reflect the current configuration
+	 * so that drivers can program their chips accordingly.
+	 */
+	dp->bridge_dev = NULL;
+
+	err = dsa_port_notify(dp, DSA_NOTIFIER_BRIDGE_LEAVE, &info);
+	if (err)
+		pr_err("DSA: failed to notify DSA_NOTIFIER_BRIDGE_LEAVE\n");
+
+	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
+	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
+	 */
+	dsa_port_set_state_now(dp, BR_STATE_FORWARDING);
+}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2c57c7205aa3..ab298c41b8e7 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -27,16 +27,6 @@
 
 static bool dsa_slave_dev_check(struct net_device *dev);
 
-static int dsa_port_notify(struct dsa_port *dp, unsigned long e, void *v)
-{
-	struct raw_notifier_head *nh = &dp->ds->dst->nh;
-	int err;
-
-	err = raw_notifier_call_chain(nh, e, v);
-
-	return notifier_to_errno(err);
-}
-
 /* slave mii_bus handling ***************************************************/
 static int dsa_slave_phy_read(struct mii_bus *bus, int addr, int reg)
 {
@@ -514,53 +504,6 @@ static int dsa_slave_port_obj_dump(struct net_device *dev,
 	return err;
 }
 
-static int dsa_port_bridge_join(struct dsa_port *dp, struct net_device *br)
-{
-	struct dsa_notifier_bridge_info info = {
-		.sw_index = dp->ds->index,
-		.port = dp->index,
-		.br = br,
-	};
-	int err;
-
-	/* Here the port is already bridged. Reflect the current configuration
-	 * so that drivers can program their chips accordingly.
-	 */
-	dp->bridge_dev = br;
-
-	err = dsa_port_notify(dp, DSA_NOTIFIER_BRIDGE_JOIN, &info);
-
-	/* The bridging is rolled back on error */
-	if (err)
-		dp->bridge_dev = NULL;
-
-	return err;
-}
-
-static void dsa_port_bridge_leave(struct dsa_port *dp, struct net_device *br)
-{
-	struct dsa_notifier_bridge_info info = {
-		.sw_index = dp->ds->index,
-		.port = dp->index,
-		.br = br,
-	};
-	int err;
-
-	/* Here the port is already unbridged. Reflect the current configuration
-	 * so that drivers can program their chips accordingly.
-	 */
-	dp->bridge_dev = NULL;
-
-	err = dsa_port_notify(dp, DSA_NOTIFIER_BRIDGE_LEAVE, &info);
-	if (err)
-		pr_err("DSA: failed to notify DSA_NOTIFIER_BRIDGE_LEAVE\n");
-
-	/* Port left the bridge, put in BR_STATE_DISABLED by the bridge layer,
-	 * so allow it to be in BR_STATE_FORWARDING to be kept functional
-	 */
-	dsa_port_set_state_now(dp, BR_STATE_FORWARDING);
-}
-
 static int dsa_slave_port_attr_get(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
-- 
2.13.0
