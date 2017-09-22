From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/3] net: dsa: add port enable and disable helpers
Date: Fri, 22 Sep 2017 15:40:45 -0400
Message-ID: <20170922194045.18814-4-vivien.didelot@savoirfairelinux.com>
References: <20170922194045.18814-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922194045.18814-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Provide dsa_port_enable and dsa_port_disable helpers to respectively
enable and disable a switch port. This makes the dsa_port_set_state_now
helper static.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa_priv.h |  3 ++-
 net/dsa/port.c     | 31 ++++++++++++++++++++++++++++++-
 net/dsa/slave.c    | 19 +++++--------------
 3 files changed, 37 insertions(+), 16 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 9803952a5b40..0298a0f6a349 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -117,7 +117,8 @@ void dsa_master_ethtool_restore(struct net_device *dev);
 /* port.c */
 int dsa_port_set_state(struct dsa_port *dp, u8 state,
 		       struct switchdev_trans *trans);
-void dsa_port_set_state_now(struct dsa_port *dp, u8 state);
+int dsa_port_enable(struct dsa_port *dp, struct phy_device *phy);
+void dsa_port_disable(struct dsa_port *dp, struct phy_device *phy);
 int dsa_port_bridge_join(struct dsa_port *dp, struct net_device *br);
 void dsa_port_bridge_leave(struct dsa_port *dp, struct net_device *br);
 int dsa_port_vlan_filtering(struct dsa_port *dp, bool vlan_filtering,
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 76d43a82d397..72c8dbd3d3f2 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -56,7 +56,7 @@ int dsa_port_set_state(struct dsa_port *dp, u8 state,
 	return 0;
 }
 
-void dsa_port_set_state_now(struct dsa_port *dp, u8 state)
+static void dsa_port_set_state_now(struct dsa_port *dp, u8 state)
 {
 	int err;
 
@@ -65,6 +65,35 @@ void dsa_port_set_state_now(struct dsa_port *dp, u8 state)
 		pr_err("DSA: failed to set STP state %u (%d)\n", state, err);
 }
 
+int dsa_port_enable(struct dsa_port *dp, struct phy_device *phy)
+{
+	u8 stp_state = dp->bridge_dev ? BR_STATE_BLOCKING : BR_STATE_FORWARDING;
+	struct dsa_switch *ds = dp->ds;
+	int port = dp->index;
+	int err;
+
+	if (ds->ops->port_enable) {
+		err = ds->ops->port_enable(ds, port, phy);
+		if (err)
+			return err;
+	}
+
+	dsa_port_set_state_now(dp, stp_state);
+
+	return 0;
+}
+
+void dsa_port_disable(struct dsa_port *dp, struct phy_device *phy)
+{
+	struct dsa_switch *ds = dp->ds;
+	int port = dp->index;
+
+	dsa_port_set_state_now(dp, BR_STATE_DISABLED);
+
+	if (ds->ops->port_disable)
+		ds->ops->port_disable(ds, port, phy);
+}
+
 int dsa_port_bridge_join(struct dsa_port *dp, struct net_device *br)
 {
 	struct dsa_notifier_bridge_info info = {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0aab29928152..4ea1c6eb0da8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -73,9 +73,7 @@ static int dsa_slave_open(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_port *dp = p->dp;
-	struct dsa_switch *ds = dp->ds;
 	struct net_device *master = dsa_master_netdev(p);
-	u8 stp_state = dp->bridge_dev ? BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
 
 	if (!(master->flags & IFF_UP))
@@ -98,13 +96,9 @@ static int dsa_slave_open(struct net_device *dev)
 			goto clear_allmulti;
 	}
 
-	if (ds->ops->port_enable) {
-		err = ds->ops->port_enable(ds, p->dp->index, dev->phydev);
-		if (err)
-			goto clear_promisc;
-	}
-
-	dsa_port_set_state_now(p->dp, stp_state);
+	err = dsa_port_enable(dp, dev->phydev);
+	if (err)
+		goto clear_promisc;
 
 	if (dev->phydev)
 		phy_start(dev->phydev);
@@ -128,15 +122,12 @@ static int dsa_slave_close(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct net_device *master = dsa_master_netdev(p);
-	struct dsa_switch *ds = p->dp->ds;
+	struct dsa_port *dp = p->dp;
 
 	if (dev->phydev)
 		phy_stop(dev->phydev);
 
-	dsa_port_set_state_now(p->dp, BR_STATE_DISABLED);
-
-	if (ds->ops->port_disable)
-		ds->ops->port_disable(ds, p->dp->index, dev->phydev);
+	dsa_port_disable(dp, dev->phydev);
 
 	dev_mc_unsync(master, dev);
 	dev_uc_unsync(master, dev);
-- 
2.14.1
