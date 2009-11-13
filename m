From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 2/3] macvlan:  derived from Arnd Bergmann's patch for macvtap
Date: Fri, 13 Nov 2009 14:55:21 -0500
Message-ID: <20091113195521.11184.13203.stgit@mimic.site>
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

This patch includes only the basic framework for overriding the
receive path and the macvlan header was moved to allow modules
outside of driver/net to use it.

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
---

 drivers/net/macvlan.c   |   41 ++++++++++++++++-------------------------
 include/linux/macvlan.h |   37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+), 25 deletions(-)
 create mode 100644 include/linux/macvlan.h

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 41dc71f..3425e12 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -30,22 +30,7 @@
 #include <linux/if_macvlan.h>
 #include <net/rtnetlink.h>
 
-#define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
-
-struct macvlan_port {
-	struct net_device	*dev;
-	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
-	struct list_head	vlans;
-};
-
-struct macvlan_dev {
-	struct net_device	*dev;
-	struct list_head	list;
-	struct hlist_node	hlist;
-	struct macvlan_port	*port;
-	struct net_device	*lowerdev;
-};
-
+#include <linux/macvlan.h>
 
 static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
 					       const unsigned char *addr)
@@ -135,7 +120,7 @@ static void macvlan_broadcast(struct sk_buff *skb,
 			else
 				nskb->pkt_type = PACKET_MULTICAST;
 
-			netif_rx(nskb);
+			vlan->receive(nskb);
 		}
 	}
 }
@@ -180,12 +165,12 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
 
-	netif_rx(skb);
+	vlan->receive(skb);
 	return NULL;
 }
 
-static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
-				      struct net_device *dev)
+netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
+			       struct net_device *dev)
 {
 	int i = skb_get_queue_mapping(skb);
 	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
@@ -204,6 +189,7 @@ static netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 
 	return NETDEV_TX_OK;
 }
+EXPORT_SYMBOL_GPL(macvlan_start_xmit);
 
 static int macvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 			       unsigned short type, const void *daddr,
@@ -414,7 +400,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static void macvlan_setup(struct net_device *dev)
+void macvlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
@@ -425,6 +411,7 @@ static void macvlan_setup(struct net_device *dev)
 	dev->ethtool_ops	= &macvlan_ethtool_ops;
 	dev->tx_queue_len	= 0;
 }
+EXPORT_SYMBOL_GPL(macvlan_setup);
 
 static int macvlan_port_create(struct net_device *dev)
 {
@@ -455,7 +442,7 @@ static void macvlan_port_destroy(struct net_device *dev)
 	kfree(port);
 }
 
-static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
+int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -465,6 +452,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(macvlan_validate);
 
 static int macvlan_get_tx_queues(struct net *net,
 				 struct nlattr *tb[],
@@ -485,8 +473,8 @@ static int macvlan_get_tx_queues(struct net *net,
 	return 0;
 }
 
-static int macvlan_newlink(struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+int macvlan_newlink(struct net_device *dev,
+		    struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvlan_port *port;
@@ -526,6 +514,7 @@ static int macvlan_newlink(struct net_device *dev,
 	vlan->lowerdev = lowerdev;
 	vlan->dev      = dev;
 	vlan->port     = port;
+	vlan->receive  = netif_rx;
 
 	err = register_netdevice(dev);
 	if (err < 0)
@@ -535,8 +524,9 @@ static int macvlan_newlink(struct net_device *dev,
 	netif_stacked_transfer_operstate(dev, lowerdev);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(macvlan_newlink);
 
-static void macvlan_dellink(struct net_device *dev)
+void macvlan_dellink(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvlan_port *port = vlan->port;
@@ -547,6 +537,7 @@ static void macvlan_dellink(struct net_device *dev)
 	if (list_empty(&port->vlans))
 		macvlan_port_destroy(port->dev);
 }
+EXPORT_SYMBOL_GPL(macvlan_dellink);
 
 static struct rtnl_link_ops macvlan_link_ops __read_mostly = {
 	.kind		= "macvlan",
diff --git a/include/linux/macvlan.h b/include/linux/macvlan.h
new file mode 100644
index 0000000..3f3c6c3
--- /dev/null
+++ b/include/linux/macvlan.h
@@ -0,0 +1,37 @@
+#ifndef _MACVLAN_H
+#define _MACVLAN_H
+
+#include <linux/netdevice.h>
+#include <linux/netlink.h>
+#include <linux/list.h>
+
+#define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
+
+struct macvlan_port {
+	struct net_device	*dev;
+	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
+	struct list_head	vlans;
+};
+
+struct macvlan_dev {
+	struct net_device	*dev;
+	struct list_head	list;
+	struct hlist_node	hlist;
+	struct macvlan_port	*port;
+	struct net_device	*lowerdev;
+
+	int (*receive)(struct sk_buff *skb);
+};
+
+extern int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev);
+
+extern void macvlan_setup(struct net_device *dev);
+
+extern int macvlan_validate(struct nlattr *tb[], struct nlattr *data[]);
+
+extern int macvlan_newlink(struct net_device *dev,
+		struct nlattr *tb[], struct nlattr *data[]);
+
+extern void macvlan_dellink(struct net_device *dev);
+
+#endif /* _MACVLAN_H */

