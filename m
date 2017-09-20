From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: better scoping of slave functions
Date: Wed, 20 Sep 2017 19:31:57 -0400
Message-ID: <20170920233157.6832-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A few DSA slave functions take a dsa_slave_priv pointer as first
argument, whereas the scope of the slave.c functions is the slave
net_device structure. Fix this and rename dsa_netpoll_send_skb to
dsa_slave_netpoll_send_skb.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d51b10450e1b..bc376fc1bbe7 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -385,10 +385,12 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
 	return 0;
 }
 
-static inline netdev_tx_t dsa_netpoll_send_skb(struct dsa_slave_priv *p,
-					       struct sk_buff *skb)
+static inline netdev_tx_t dsa_slave_netpoll_send_skb(struct net_device *dev,
+						     struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_POLL_CONTROLLER
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
 	if (p->netpoll)
 		netpoll_send_skb(p->netpoll, skb);
 #else
@@ -422,7 +424,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * tag to be successfully transmitted
 	 */
 	if (unlikely(netpoll_tx_running(dev)))
-		return dsa_netpoll_send_skb(p, nskb);
+		return dsa_slave_netpoll_send_skb(dev, nskb);
 
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
@@ -736,9 +738,9 @@ static int dsa_slave_get_phys_port_name(struct net_device *dev,
 }
 
 static struct dsa_mall_tc_entry *
-dsa_slave_mall_tc_entry_find(struct dsa_slave_priv *p,
-			     unsigned long cookie)
+dsa_slave_mall_tc_entry_find(struct net_device *dev, unsigned long cookie)
 {
+	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_mall_tc_entry *mall_tc_entry;
 
 	list_for_each_entry(mall_tc_entry, &p->mall_tc_list, list)
@@ -820,7 +822,7 @@ static void dsa_slave_del_cls_matchall(struct net_device *dev,
 	if (!ds->ops->port_mirror_del)
 		return;
 
-	mall_tc_entry = dsa_slave_mall_tc_entry_find(p, cls->cookie);
+	mall_tc_entry = dsa_slave_mall_tc_entry_find(dev, cls->cookie);
 	if (!mall_tc_entry)
 		return;
 
@@ -1027,10 +1029,9 @@ static int dsa_slave_fixed_link_update(struct net_device *dev,
 }
 
 /* slave device setup *******************************************************/
-static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
-				 struct net_device *slave_dev,
-				 int addr)
+static int dsa_slave_phy_connect(struct net_device *slave_dev, int addr)
 {
+	struct dsa_slave_priv *p = netdev_priv(slave_dev);
 	struct dsa_switch *ds = p->dp->ds;
 
 	p->phy = mdiobus_get_phy(ds->slave_mii_bus, addr);
@@ -1046,9 +1047,9 @@ static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
 				  p->phy_interface);
 }
 
-static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
-				struct net_device *slave_dev)
+static int dsa_slave_phy_setup(struct net_device *slave_dev)
 {
+	struct dsa_slave_priv *p = netdev_priv(slave_dev);
 	struct dsa_switch *ds = p->dp->ds;
 	struct device_node *phy_dn, *port_dn;
 	bool phy_is_fixed = false;
@@ -1088,7 +1089,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		 */
 		if (!phy_is_fixed && phy_id >= 0 &&
 		    (ds->phys_mii_mask & (1 << phy_id))) {
-			ret = dsa_slave_phy_connect(p, slave_dev, phy_id);
+			ret = dsa_slave_phy_connect(slave_dev, phy_id);
 			if (ret) {
 				netdev_err(slave_dev, "failed to connect to phy%d: %d\n", phy_id, ret);
 				of_node_put(phy_dn);
@@ -1111,7 +1112,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	 * MDIO bus instead
 	 */
 	if (!p->phy) {
-		ret = dsa_slave_phy_connect(p, slave_dev, p->dp->index);
+		ret = dsa_slave_phy_connect(slave_dev, p->dp->index);
 		if (ret) {
 			netdev_err(slave_dev, "failed to connect to port %d: %d\n",
 				   p->dp->index, ret);
@@ -1233,7 +1234,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 
 	netif_carrier_off(slave_dev);
 
-	ret = dsa_slave_phy_setup(p, slave_dev);
+	ret = dsa_slave_phy_setup(slave_dev);
 	if (ret) {
 		netdev_err(master, "error %d setting up slave phy\n", ret);
 		unregister_netdev(slave_dev);
-- 
2.14.1
