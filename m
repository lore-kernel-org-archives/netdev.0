From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6 2/3] macvlan: use rx_handler_data pointer to
 store macvlan_port pointer
Date: Thu, 10 Jun 2010 15:35:48 +0200
Message-ID: <20100610133547.GE2618@psychotron.lab.eng.brq.redhat.com>
References: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@vyatta.com, kaber@trash.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758999Ab0FJNfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 09:35:52 -0400
Content-Disposition: inline
In-Reply-To: <20100610133412.GC2618@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register macvlan_port pointer as rx_handler data pointer. As macvlan_port is
removed from struct net_device, another netdev priv_flag is added to indicate
the device serves as a macvlan port.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/macvlan.c     |   27 +++++++++++++++------------
 include/linux/if.h        |    1 +
 include/linux/netdevice.h |    2 --
 3 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 87a3bf6..dec3e8f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -40,6 +40,10 @@ struct macvlan_port {
 	struct rcu_head		rcu;
 };
 
+#define macvlan_port_get_rcu(dev) ((struct macvlan_port *) rcu_dereference(dev->rx_handler_data))
+#define macvlan_port_get(dev) ((struct macvlan_port *) dev->rx_handler_data)
+#define macvlan_port_exists(dev) (dev->priv_flags & IFF_MACVLAN_PORT)
+
 static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
 					       const unsigned char *addr)
 {
@@ -155,7 +159,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 	struct net_device *dev;
 	unsigned int len;
 
-	port = rcu_dereference(skb->dev->macvlan_port);
+	port = macvlan_port_get_rcu(skb->dev);
 	if (is_multicast_ether_addr(eth->h_dest)) {
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
@@ -530,14 +534,12 @@ static int macvlan_port_create(struct net_device *dev)
 	INIT_LIST_HEAD(&port->vlans);
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
 		INIT_HLIST_HEAD(&port->vlan_hash[i]);
-	rcu_assign_pointer(dev->macvlan_port, port);
 
-	err = netdev_rx_handler_register(dev, macvlan_handle_frame, NULL);
-	if (err) {
-		rcu_assign_pointer(dev->macvlan_port, NULL);
+	err = netdev_rx_handler_register(dev, macvlan_handle_frame, port);
+	if (err)
 		kfree(port);
-	}
 
+	dev->priv_flags |= IFF_MACVLAN_PORT;
 	return err;
 }
 
@@ -551,10 +553,10 @@ static void macvlan_port_rcu_free(struct rcu_head *head)
 
 static void macvlan_port_destroy(struct net_device *dev)
 {
-	struct macvlan_port *port = dev->macvlan_port;
+	struct macvlan_port *port = macvlan_port_get(dev);
 
+	dev->priv_flags &= ~IFF_MACVLAN_PORT;
 	netdev_rx_handler_unregister(dev);
-	rcu_assign_pointer(dev->macvlan_port, NULL);
 	call_rcu(&port->rcu, macvlan_port_rcu_free);
 }
 
@@ -633,12 +635,12 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (!tb[IFLA_ADDRESS])
 		random_ether_addr(dev->dev_addr);
 
-	if (lowerdev->macvlan_port == NULL) {
+	if (!macvlan_port_exists(lowerdev)) {
 		err = macvlan_port_create(lowerdev);
 		if (err < 0)
 			return err;
 	}
-	port = lowerdev->macvlan_port;
+	port = macvlan_port_get(lowerdev);
 
 	vlan->lowerdev = lowerdev;
 	vlan->dev      = dev;
@@ -748,10 +750,11 @@ static int macvlan_device_event(struct notifier_block *unused,
 	struct macvlan_dev *vlan, *next;
 	struct macvlan_port *port;
 
-	port = dev->macvlan_port;
-	if (port == NULL)
+	if (!macvlan_port_exists(dev))
 		return NOTIFY_DONE;
 
+	port = macvlan_port_get(dev);
+
 	switch (event) {
 	case NETDEV_CHANGE:
 		list_for_each_entry(vlan, &port->vlans, list)
diff --git a/include/linux/if.h b/include/linux/if.h
index be350e6..31f2e27 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -73,6 +73,7 @@
 #define IFF_DONT_BRIDGE 0x800		/* disallow bridging this ether dev */
 #define IFF_IN_NETPOLL	0x1000		/* whether we are processing netpoll */
 #define IFF_DISABLE_NETPOLL	0x2000	/* disable netpoll at run-time */
+#define IFF_MACVLAN_PORT	0x4000	/* device used as macvlan port */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 32cc219..37faf51 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1030,8 +1030,6 @@ struct net_device {
 
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
-	/* macvlan */
-	struct macvlan_port	*macvlan_port;
 	/* GARP */
 	struct garp_port	*garp_port;
 
-- 
1.7.0.1

