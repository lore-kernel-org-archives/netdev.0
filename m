From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH 1/4] macvlan:  derived from Arnd Bergmann's patch for macvtap
Date: Tue, 10 Nov 2009 17:27:49 -0500
Message-ID: <20091110222749.24100.57638.stgit@mimic.site>
References: <20091110222632.24100.14884.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net, arnd@arndb.de,
	bridge@lists.linux-foundation.org, evb@yahoogroups.com,
	netdev@vger.kernel.org
To: alacrityvm-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20091110222632.24100.14884.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in the series because this has not gone upstream yet and
the subsequent patches depend on it. This patch includes only the
basic framework for overriding the receive path and the macvlan header
was moved to allow modules outside of driver/net to use it.

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
---

 drivers/net/macvlan.c   |   39 +++++++++++++++------------------------
 include/linux/macvlan.h |   37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+), 24 deletions(-)
 create mode 100644 include/linux/macvlan.h

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 99eed9f..0a389b8 100644
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
@@ -180,11 +165,11 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	skb->dev = dev;
 	skb->pkt_type = PACKET_HOST;
 
-	netif_rx(skb);
+	vlan->receive(skb);
 	return NULL;
 }
 
-static int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
+int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	unsigned int len = skb->len;
@@ -202,6 +187,7 @@ static int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	return NETDEV_TX_OK;
 }
+EXPORT_SYMBOL_GPL(macvlan_start_xmit);
 
 static int macvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 			       unsigned short type, const void *daddr,
@@ -412,7 +398,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static void macvlan_setup(struct net_device *dev)
+void macvlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
@@ -423,6 +409,7 @@ static void macvlan_setup(struct net_device *dev)
 	dev->ethtool_ops	= &macvlan_ethtool_ops;
 	dev->tx_queue_len	= 0;
 }
+EXPORT_SYMBOL_GPL(macvlan_setup);
 
 static int macvlan_port_create(struct net_device *dev)
 {
@@ -472,7 +459,7 @@ static void macvlan_transfer_operstate(struct net_device *dev)
 	}
 }
 
-static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
+int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -482,9 +469,10 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(macvlan_validate);
 
-static int macvlan_newlink(struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+int macvlan_newlink(struct net_device *dev,
+		    struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvlan_port *port;
@@ -524,6 +512,7 @@ static int macvlan_newlink(struct net_device *dev,
 	vlan->lowerdev = lowerdev;
 	vlan->dev      = dev;
 	vlan->port     = port;
+	vlan->receive  = netif_rx;
 
 	err = register_netdevice(dev);
 	if (err < 0)
@@ -533,8 +522,9 @@ static int macvlan_newlink(struct net_device *dev,
 	macvlan_transfer_operstate(dev);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(macvlan_newlink);
 
-static void macvlan_dellink(struct net_device *dev)
+void macvlan_dellink(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvlan_port *port = vlan->port;
@@ -545,6 +535,7 @@ static void macvlan_dellink(struct net_device *dev)
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

