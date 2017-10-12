From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/5] net: dsa: add slave get master helper
Date: Thu, 12 Oct 2017 18:51:55 -0400
Message-ID: <20171012225156.20758-5-vivien.didelot@savoirfairelinux.com>
References: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many part of the DSA slave code require to get the master device
assigned to a slave device. Remove dsa_master_netdev() in favor of a
dsa_slave_get_master() helper which does that.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h | 13 ++++++++-----
 net/dsa/slave.c    | 26 +++++++++-----------------
 2 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 569a4929b4c9..f1dc5a856fda 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -176,6 +176,14 @@ static inline struct dsa_port *dsa_slave_to_port(const struct net_device *dev)
 	return p->dp;
 }
 
+static inline struct net_device *
+dsa_slave_get_master(const struct net_device *dev)
+{
+	struct dsa_port *dp = dsa_slave_to_port(dev);
+
+	return dp->cpu_dp->netdev;
+}
+
 /* switch.c */
 int dsa_switch_register_notifier(struct dsa_switch *ds);
 void dsa_switch_unregister_notifier(struct dsa_switch *ds);
@@ -204,9 +212,4 @@ extern const struct dsa_device_ops qca_netdev_ops;
 /* tag_trailer.c */
 extern const struct dsa_device_ops trailer_netdev_ops;
 
-static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
-{
-	return p->dp->cpu_dp->netdev;
-}
-
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 894602c88b09..d2c780f13d78 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -64,15 +64,12 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 /* slave device handling ****************************************************/
 static int dsa_slave_get_iflink(const struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-
-	return dsa_master_netdev(p)->ifindex;
+	return dsa_slave_get_master(dev)->ifindex;
 }
 
 static int dsa_slave_open(struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = dsa_slave_get_master(dev);
 	struct dsa_port *dp = dsa_slave_to_port(dev);
 	int err;
 
@@ -120,8 +117,7 @@ static int dsa_slave_open(struct net_device *dev)
 
 static int dsa_slave_close(struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = dsa_slave_get_master(dev);
 	struct dsa_port *dp = dsa_slave_to_port(dev);
 
 	if (dev->phydev)
@@ -144,8 +140,7 @@ static int dsa_slave_close(struct net_device *dev)
 
 static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = dsa_slave_get_master(dev);
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(master, dev->flags & IFF_ALLMULTI ? 1 : -1);
@@ -155,8 +150,7 @@ static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 
 static void dsa_slave_set_rx_mode(struct net_device *dev)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = dsa_slave_get_master(dev);
 
 	dev_mc_sync(master, dev);
 	dev_uc_sync(master, dev);
@@ -164,8 +158,7 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
 
 static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = dsa_slave_get_master(dev);
 	struct sockaddr *addr = a;
 	int err;
 
@@ -409,7 +402,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
 	 */
-	nskb->dev = dsa_master_netdev(p);
+	nskb->dev = dsa_slave_get_master(dev);
 	dev_queue_xmit(nskb);
 
 	return NETDEV_TX_OK;
@@ -632,8 +625,8 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 static int dsa_slave_netpoll_setup(struct net_device *dev,
 				   struct netpoll_info *ni)
 {
+	struct net_device *master = dsa_slave_get_master(dev);
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
 	struct netpoll *netpoll;
 	int err = 0;
 
@@ -1115,8 +1108,7 @@ int dsa_slave_resume(struct net_device *slave_dev)
 
 static void dsa_slave_notify(struct net_device *dev, unsigned long val)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = dsa_slave_get_master(dev);
 	struct dsa_port *dp = dsa_slave_to_port(dev);
 	struct dsa_notifier_register_info rinfo = {
 		.switch_number = dp->ds->index,
-- 
2.14.2
