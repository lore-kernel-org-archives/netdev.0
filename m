From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/4] net: dsa: assign a master to slave ports
Date: Thu, 31 Aug 2017 14:37:46 -0400
Message-ID: <20170831183746.2109-5-vivien.didelot@savoirfairelinux.com>
References: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36890 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751602AbdHaSm0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 14:42:26 -0400
In-Reply-To: <20170831183746.2109-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because each DSA slave port may use a different DSA master port, add a
pointer to a master in the slave structure. This is a preparatory patch
for multiple CPU ports.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |  7 ++-----
 net/dsa/slave.c    | 33 ++++++++++++++++++---------------
 2 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 59f155cbbe87..a8cd6cbe4061 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -66,6 +66,8 @@ struct dsa_notifier_vlan_info {
 };
 
 struct dsa_slave_priv {
+	struct dsa_master *master;
+
 	/* Copy of the master xmit tagging op for faster access in hot path */
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
@@ -179,9 +181,4 @@ extern const struct dsa_device_ops qca_netdev_ops;
 /* tag_trailer.c */
 extern const struct dsa_device_ops trailer_netdev_ops;
 
-static inline struct net_device *dsa_master_netdev(struct dsa_slave_priv *p)
-{
-	return p->dp->ds->dst->master->netdev;
-}
-
 #endif
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d5a03ef8d0e0..107ed0c4a850 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -66,7 +66,7 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	return dsa_master_netdev(p)->ifindex;
+	return p->master->netdev->ifindex;
 }
 
 static int dsa_slave_open(struct net_device *dev)
@@ -74,7 +74,7 @@ static int dsa_slave_open(struct net_device *dev)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_port *dp = p->dp;
 	struct dsa_switch *ds = dp->ds;
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = p->master->netdev;
 	u8 stp_state = dp->bridge_dev ? BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
 
@@ -127,7 +127,7 @@ static int dsa_slave_open(struct net_device *dev)
 static int dsa_slave_close(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = p->master->netdev;
 	struct dsa_switch *ds = p->dp->ds;
 
 	if (p->phy)
@@ -154,7 +154,7 @@ static int dsa_slave_close(struct net_device *dev)
 static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = p->master->netdev;
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(master, dev->flags & IFF_ALLMULTI ? 1 : -1);
@@ -165,7 +165,7 @@ static void dsa_slave_change_rx_flags(struct net_device *dev, int change)
 static void dsa_slave_set_rx_mode(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = p->master->netdev;
 
 	dev_mc_sync(master, dev);
 	dev_uc_sync(master, dev);
@@ -174,7 +174,7 @@ static void dsa_slave_set_rx_mode(struct net_device *dev)
 static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = p->master->netdev;
 	struct sockaddr *addr = a;
 	int err;
 
@@ -427,7 +427,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
 	 */
-	nskb->dev = dsa_master_netdev(p);
+	nskb->dev = p->master->netdev;
 	dev_queue_xmit(nskb);
 
 	return NETDEV_TX_OK;
@@ -687,7 +687,7 @@ static int dsa_slave_netpoll_setup(struct net_device *dev,
 				   struct netpoll_info *ni)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct net_device *master = dsa_master_netdev(p);
+	struct net_device *master = p->master->netdev;
 	struct netpoll *netpoll;
 	int err = 0;
 
@@ -1170,7 +1170,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 {
 	struct dsa_switch *ds = port->ds;
 	struct dsa_switch_tree *dst = ds->dst;
-	struct net_device *master = dst->master->netdev;
+	struct dsa_master *master = dst->master;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
 	int ret;
@@ -1180,10 +1180,10 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	if (slave_dev == NULL)
 		return -ENOMEM;
 
-	slave_dev->features = master->vlan_features | NETIF_F_HW_TC;
+	slave_dev->features = master->netdev->vlan_features | NETIF_F_HW_TC;
 	slave_dev->hw_features |= NETIF_F_HW_TC;
 	slave_dev->ethtool_ops = &dsa_slave_ethtool_ops;
-	eth_hw_addr_inherit(slave_dev, master);
+	eth_hw_addr_inherit(slave_dev, master->netdev);
 	slave_dev->priv_flags |= IFF_NO_QUEUE;
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
 	slave_dev->switchdev_ops = &dsa_slave_switchdev_ops;
@@ -1196,7 +1196,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 
 	SET_NETDEV_DEV(slave_dev, port->ds->dev);
 	slave_dev->dev.of_node = port->dn;
-	slave_dev->vlan_features = master->vlan_features;
+	slave_dev->vlan_features = master->netdev->vlan_features;
 
 	p = netdev_priv(slave_dev);
 	p->stats64 = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
@@ -1206,7 +1206,8 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	}
 	p->dp = port;
 	INIT_LIST_HEAD(&p->mall_tc_list);
-	p->xmit = dst->master->tag_ops->xmit;
+	p->master = master;
+	p->xmit = master->tag_ops->xmit;
 
 	p->old_pause = -1;
 	p->old_link = -1;
@@ -1215,7 +1216,8 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	port->netdev = slave_dev;
 	ret = register_netdev(slave_dev);
 	if (ret) {
-		netdev_err(master, "error %d registering interface %s\n",
+		netdev_err(master->netdev,
+			   "error %d registering interface %s\n",
 			   ret, slave_dev->name);
 		port->netdev = NULL;
 		free_percpu(p->stats64);
@@ -1227,7 +1229,8 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 
 	ret = dsa_slave_phy_setup(p, slave_dev);
 	if (ret) {
-		netdev_err(master, "error %d setting up slave phy\n", ret);
+		netdev_err(master->netdev,
+			   "error %d setting up slave phy\n", ret);
 		unregister_netdev(slave_dev);
 		free_percpu(p->stats64);
 		free_netdev(slave_dev);
-- 
2.14.1
