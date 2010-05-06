From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] net: adjust handle_macvlan to pass port struct
 to hook
Date: Thu, 6 May 2010 13:33:53 +0200
Message-ID: <20100506113352.GB3406@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56599 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750805Ab0EFLd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 07:33:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now there's null check here and also again in the hook. Looking at bridge bits
which are simmilar, port structure is rcu_dereferenced right away in
handle_bridge and passed to hook. Looks nicer.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9a939d8..1b78c00 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -145,19 +145,15 @@ static void macvlan_broadcast(struct sk_buff *skb,
 }
 
 /* called under rcu_read_lock() from netif_receive_skb */
-static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
+static struct sk_buff *macvlan_handle_frame(struct macvlan_port *port,
+					    struct sk_buff *skb)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
-	const struct macvlan_port *port;
 	const struct macvlan_dev *vlan;
 	const struct macvlan_dev *src;
 	struct net_device *dev;
 	unsigned int len;
 
-	port = rcu_dereference(skb->dev->macvlan_port);
-	if (port == NULL)
-		return skb;
-
 	if (is_multicast_ether_addr(eth->h_dest)) {
 		src = macvlan_hash_lookup(port, eth->h_source);
 		if (!src)
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index b78a712..9ea047a 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -85,6 +85,7 @@ extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev);
 
 
-extern struct sk_buff *(*macvlan_handle_frame_hook)(struct sk_buff *);
+extern struct sk_buff *(*macvlan_handle_frame_hook)(struct macvlan_port *,
+						    struct sk_buff *);
 
 #endif /* _LINUX_IF_MACVLAN_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index 36d53be..f316a37 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2605,7 +2605,8 @@ static inline struct sk_buff *handle_bridge(struct sk_buff *skb,
 #endif
 
 #if defined(CONFIG_MACVLAN) || defined(CONFIG_MACVLAN_MODULE)
-struct sk_buff *(*macvlan_handle_frame_hook)(struct sk_buff *skb) __read_mostly;
+struct sk_buff *(*macvlan_handle_frame_hook)(struct macvlan_port *p,
+					     struct sk_buff *skb) __read_mostly;
 EXPORT_SYMBOL_GPL(macvlan_handle_frame_hook);
 
 static inline struct sk_buff *handle_macvlan(struct sk_buff *skb,
@@ -2613,14 +2614,17 @@ static inline struct sk_buff *handle_macvlan(struct sk_buff *skb,
 					     int *ret,
 					     struct net_device *orig_dev)
 {
-	if (skb->dev->macvlan_port == NULL)
+	struct macvlan_port *port;
+
+	port = rcu_dereference(skb->dev->macvlan_port);
+	if (!port)
 		return skb;
 
 	if (*pt_prev) {
 		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
 	}
-	return macvlan_handle_frame_hook(skb);
+	return macvlan_handle_frame_hook(port, skb);
 }
 #else
 #define handle_macvlan(skb, pt_prev, ret, orig_dev)	(skb)
