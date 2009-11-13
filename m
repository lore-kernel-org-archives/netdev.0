From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 3/3] macvlan: allow in-kernel modules to create and manage
	macvlan devices
Date: Fri, 13 Nov 2009 14:55:29 -0500
Message-ID: <20091113195529.11184.19011.stgit@mimic.site>
References: <20091113195201.11184.25766.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, arnd@arndb.de,
	bridge@lists.linux-foundation.org
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20091113195201.11184.25766.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvlan driver didn't allow for creation/deletion of devices
by other in-kernel modules. This patch provides common routines
for both in-kernel and netlink based management. This patch
also enables macvlan device support for gro for lower level
devices that support gro.

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
---

 drivers/net/macvlan.c   |   72 ++++++++++++++++++++++++++++++++---------------
 include/linux/macvlan.h |    4 +++
 2 files changed, 53 insertions(+), 23 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3425e12..bb180d0 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -210,7 +210,7 @@ static const struct header_ops macvlan_hard_header_ops = {
 	.cache_update	= eth_header_cache_update,
 };
 
-static int macvlan_open(struct net_device *dev)
+int macvlan_open(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
@@ -237,7 +237,7 @@ out:
 	return err;
 }
 
-static int macvlan_stop(struct net_device *dev)
+int macvlan_stop(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
@@ -318,7 +318,7 @@ static struct lock_class_key macvlan_netdev_addr_lock_key;
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
-	 NETIF_F_TSO_ECN | NETIF_F_TSO6)
+	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO)
 
 #define MACVLAN_STATE_MASK \
 	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
@@ -454,6 +454,44 @@ int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 EXPORT_SYMBOL_GPL(macvlan_validate);
 
+int macvlan_link_lowerdev(struct net_device *dev,
+			  struct net_device *lowerdev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvlan_port *port;
+	int err = 0;
+
+	if (lowerdev->macvlan_port == NULL) {
+		err = macvlan_port_create(lowerdev);
+		if (err < 0)
+			return err;
+	}
+	port = lowerdev->macvlan_port;
+
+	vlan->lowerdev = lowerdev;
+	vlan->dev      = dev;
+	vlan->port     = port;
+	vlan->receive  = netif_rx;
+
+	macvlan_init(dev);
+
+	list_add_tail(&vlan->list, &port->vlans);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(macvlan_link_lowerdev);
+
+void macvlan_unlink_lowerdev(struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvlan_port *port = vlan->port;
+
+	list_del(&vlan->list);
+
+	if (list_empty(&port->vlans))
+		macvlan_port_destroy(port->dev);
+}
+EXPORT_SYMBOL_GPL(macvlan_unlink_lowerdev);
+
 static int macvlan_get_tx_queues(struct net *net,
 				 struct nlattr *tb[],
 				 unsigned int *num_tx_queues,
@@ -504,38 +542,26 @@ int macvlan_newlink(struct net_device *dev,
 	if (!tb[IFLA_ADDRESS])
 		random_ether_addr(dev->dev_addr);
 
-	if (lowerdev->macvlan_port == NULL) {
-		err = macvlan_port_create(lowerdev);
-		if (err < 0)
-			return err;
-	}
-	port = lowerdev->macvlan_port;
-
-	vlan->lowerdev = lowerdev;
-	vlan->dev      = dev;
-	vlan->port     = port;
-	vlan->receive  = netif_rx;
+	err = macvlan_link_lowerdev(dev, lowerdev);
+	if (err < 0)
+		return err;
 
 	err = register_netdevice(dev);
-	if (err < 0)
+	if (err < 0) {
+		macvlan_unlink_lowerdev(dev);
 		return err;
+	}
 
-	list_add_tail(&vlan->list, &port->vlans);
 	netif_stacked_transfer_operstate(dev, lowerdev);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(macvlan_newlink);
 
 void macvlan_dellink(struct net_device *dev)
 {
-	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct macvlan_port *port = vlan->port;
-
-	list_del(&vlan->list);
+	macvlan_unlink_lowerdev(dev);
 	unregister_netdevice(dev);
-
-	if (list_empty(&port->vlans))
-		macvlan_port_destroy(port->dev);
 }
 EXPORT_SYMBOL_GPL(macvlan_dellink);
 
diff --git a/include/linux/macvlan.h b/include/linux/macvlan.h
index 3f3c6c3..27f56d9 100644
--- a/include/linux/macvlan.h
+++ b/include/linux/macvlan.h
@@ -24,6 +24,10 @@ struct macvlan_dev {
 };
 
 extern int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev);
+extern int macvlan_link_lowerdev(struct net_device *dev,
+				 struct net_device *lowerdev);
+
+extern void macvlan_unlink_lowerdev(struct net_device *dev);
 
 extern void macvlan_setup(struct net_device *dev);
 

