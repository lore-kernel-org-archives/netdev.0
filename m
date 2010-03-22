From: Amerigo Wang <amwang@redhat.com>
Subject: [RFC Patch 1/3] netpoll: add generic support for bridge and bonding devices
Date: Mon, 22 Mar 2010 04:17:17 -0400
Message-ID: <20100322082059.4967.63492.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Amerigo Wang <amwang@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This whole patchset is for adding netpoll support to bridge and bonding
devices. I already tested it for bridge, bonding, bridge over bonding,
and bonding over bridge. It looks fine now.

Please comment.


To make bridge and bonding support netpoll, we need to adjust
some netpoll generic code. This patch does the following things:

1) introduce two new priv_flags for struct net_device:
   IFF_IN_NETPOLL which identifies we are processing a netpoll;
   IFF_DISABLE_NETPOLL is used to disable netpoll support for a device
   at run-time;

2) introduce three new methods for netdev_ops:
   ->ndo_netpoll_setup() is used to setup netpoll for a device;
   ->ndo_netpoll_xmit() is used to transmit netpoll requests;
   ->ndo_netpoll_cleanup() is used to clean up netpoll when a device is
     removed.

3) introduce netpoll_poll_dev() which takes a struct net_device * parameter;

4) export netpoll_send_skb() and netpoll_poll_dev() which will be used later;

5) hide a pointer to struct netpoll in struct netpoll_info, ditto.

Cc: David Miller <davem@davemloft.net>
Cc: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: WANG Cong <amwang@redhat.com>

---
Index: linux-2.6/include/linux/if.h
===================================================================
--- linux-2.6.orig/include/linux/if.h
+++ linux-2.6/include/linux/if.h
@@ -71,6 +71,8 @@
 					 * release skb->dst
 					 */
 #define IFF_DONT_BRIDGE 0x800		/* disallow bridging this ether dev */
+#define IFF_IN_NETPOLL	0x1000		/* whether we are processing netpoll */
+#define IFF_DISABLE_NETPOLL	0x2000	/* disable netpoll at run-time */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
Index: linux-2.6/include/linux/netdevice.h
===================================================================
--- linux-2.6.orig/include/linux/netdevice.h
+++ linux-2.6/include/linux/netdevice.h
@@ -530,6 +530,8 @@ struct netdev_queue {
 	unsigned long		tx_dropped;
 } ____cacheline_aligned_in_smp;
 
+struct netpoll;
+struct netpoll_info;
 
 /*
  * This structure defines the management hooks for network devices.
@@ -667,6 +669,12 @@ struct net_device_ops {
 						        unsigned short vid);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	void                    (*ndo_poll_controller)(struct net_device *dev);
+	void			(*ndo_netpoll_setup)(struct net_device *dev,
+						     struct netpoll_info *npinfo);
+	int			(*ndo_netpoll_xmit)(struct netpoll *np,
+						    struct sk_buff *skb,
+						    struct net_device *dev);
+	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
 #endif
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
 						  int queue, u8 *mac);
Index: linux-2.6/include/linux/netpoll.h
===================================================================
--- linux-2.6.orig/include/linux/netpoll.h
+++ linux-2.6/include/linux/netpoll.h
@@ -36,8 +36,11 @@ struct netpoll_info {
 	struct sk_buff_head txq;
 
 	struct delayed_work tx_work;
+
+	struct netpoll *netpoll;
 };
 
+void netpoll_poll_dev(struct net_device *dev);
 void netpoll_poll(struct netpoll *np);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
@@ -47,6 +50,7 @@ int netpoll_trap(void);
 void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
 int __netpoll_rx(struct sk_buff *skb);
+void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb);
 
 
 #ifdef CONFIG_NETPOLL
Index: linux-2.6/net/core/netpoll.c
===================================================================
--- linux-2.6.orig/net/core/netpoll.c
+++ linux-2.6/net/core/netpoll.c
@@ -178,9 +178,8 @@ static void service_arp_queue(struct net
 	}
 }
 
-void netpoll_poll(struct netpoll *np)
+void netpoll_poll_dev(struct net_device *dev)
 {
-	struct net_device *dev = np->dev;
 	const struct net_device_ops *ops;
 
 	if (!dev || !netif_running(dev))
@@ -200,6 +199,13 @@ void netpoll_poll(struct netpoll *np)
 	zap_completion_queue();
 }
 
+void netpoll_poll(struct netpoll *np)
+{
+	if (!np->dev)
+		return;
+	netpoll_poll_dev(np->dev);
+}
+
 static void refill_skbs(void)
 {
 	struct sk_buff *skb;
@@ -281,7 +287,7 @@ static int netpoll_owner_active(struct n
 	return 0;
 }
 
-static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
+void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 {
 	int status = NETDEV_TX_BUSY;
 	unsigned long tries;
@@ -307,7 +313,10 @@ static void netpoll_send_skb(struct netp
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
 				if (!netif_tx_queue_stopped(txq)) {
-					status = ops->ndo_start_xmit(skb, dev);
+					if (ops->ndo_netpoll_xmit)
+						status = ops->ndo_netpoll_xmit(np, skb, dev);
+					else
+						status = ops->ndo_start_xmit(skb, dev);
 					if (status == NETDEV_TX_OK)
 						txq_trans_update(txq);
 				}
@@ -752,7 +761,10 @@ int netpoll_setup(struct netpoll *np)
 		atomic_inc(&npinfo->refcnt);
 	}
 
-	if (!ndev->netdev_ops->ndo_poll_controller) {
+	npinfo->netpoll = np;
+
+	if (ndev->priv_flags & IFF_DISABLE_NETPOLL
+			|| !ndev->netdev_ops->ndo_poll_controller) {
 		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
 		       np->name, np->dev_name);
 		err = -ENOTSUPP;
@@ -830,6 +842,9 @@ int netpoll_setup(struct netpoll *np)
 	/* last thing to do is link it to the net device structure */
 	ndev->npinfo = npinfo;
 
+	if (ndev->netdev_ops->ndo_netpoll_setup)
+		ndev->netdev_ops->ndo_netpoll_setup(ndev, npinfo);
+
 	/* avoid racing with NAPI reading npinfo */
 	synchronize_rcu();
 
@@ -904,6 +919,7 @@ void netpoll_set_trap(int trap)
 		atomic_dec(&trapped);
 }
 
+EXPORT_SYMBOL(netpoll_send_skb);
 EXPORT_SYMBOL(netpoll_set_trap);
 EXPORT_SYMBOL(netpoll_trap);
 EXPORT_SYMBOL(netpoll_print_options);
@@ -911,4 +927,5 @@ EXPORT_SYMBOL(netpoll_parse_options);
 EXPORT_SYMBOL(netpoll_setup);
 EXPORT_SYMBOL(netpoll_cleanup);
 EXPORT_SYMBOL(netpoll_send_udp);
+EXPORT_SYMBOL(netpoll_poll_dev);
 EXPORT_SYMBOL(netpoll_poll);
