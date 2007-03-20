From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/3] bridge: eliminate call by reference
Date: Tue, 20 Mar 2007 14:12:51 -0700
Message-ID: <20070320141251.3760d87f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60768 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682AbXCTVUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 17:20:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Change the bridging hook to be simple function with return value
rather than modifying the skb argument. This could generate better
code and is cleaner.


Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 include/linux/if_bridge.h |    3 ++-
 net/bridge/br_input.c     |   20 +++++++++-----------
 net/bridge/br_private.h   |    3 ++-
 net/core/dev.c            |   31 +++++++++++++++++++------------
 4 files changed, 32 insertions(+), 25 deletions(-)

--- net-2.6.22.orig/net/core/dev.c
+++ net-2.6.22/net/core/dev.c
@@ -1686,31 +1686,37 @@ static inline int deliver_skb(struct sk_
 }
 
 #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
-int (*br_handle_frame_hook)(struct net_bridge_port *p, struct sk_buff **pskb);
+/* These hooks defined here for ATM */
 struct net_bridge;
 struct net_bridge_fdb_entry *(*br_fdb_get_hook)(struct net_bridge *br,
 						unsigned char *addr);
-void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent);
+void (*br_fdb_put_hook)(struct net_bridge_fdb_entry *ent) __read_mostly;
 
-static __inline__ int handle_bridge(struct sk_buff **pskb,
-				    struct packet_type **pt_prev, int *ret,
-				    struct net_device *orig_dev)
+/*
+ * If bridge module is loaded call bridging hook.
+ *  returns NULL if packet was consumed.
+ */
+struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port *p,
+					struct sk_buff *skb) __read_mostly;
+static inline struct sk_buff *handle_bridge(struct sk_buff *skb,
+					    struct packet_type **pt_prev, int *ret,
+					    struct net_device *orig_dev)
 {
 	struct net_bridge_port *port;
 
-	if ((*pskb)->pkt_type == PACKET_LOOPBACK ||
-	    (port = rcu_dereference((*pskb)->dev->br_port)) == NULL)
-		return 0;
+	if (skb->pkt_type == PACKET_LOOPBACK ||
+	    (port = rcu_dereference(skb->dev->br_port)) == NULL)
+		return skb;
 
 	if (*pt_prev) {
-		*ret = deliver_skb(*pskb, *pt_prev, orig_dev);
+		*ret = deliver_skb(skb, *pt_prev, orig_dev);
 		*pt_prev = NULL;
 	}
 
-	return br_handle_frame_hook(port, pskb);
+	return br_handle_frame_hook(port, skb);
 }
 #else
-#define handle_bridge(skb, pt_prev, ret, orig_dev)	(0)
+#define handle_bridge(skb)	skb
 #endif
 
 #ifdef CONFIG_NET_CLS_ACT
@@ -1817,7 +1823,8 @@ int netif_receive_skb(struct sk_buff *sk
 ncls:
 #endif
 
-	if (handle_bridge(&skb, &pt_prev, &ret, orig_dev))
+	skb = handle_bridge(skb, &pt_prev, &ret, orig_dev);
+	if (!skb)
 		goto out;
 
 	type = skb->protocol;
--- net-2.6.22.orig/include/linux/if_bridge.h
+++ net-2.6.22/include/linux/if_bridge.h
@@ -105,7 +105,8 @@ struct __fdb_entry
 #include <linux/netdevice.h>
 
 extern void brioctl_set(int (*ioctl_hook)(unsigned int, void __user *));
-extern int (*br_handle_frame_hook)(struct net_bridge_port *p, struct sk_buff **pskb);
+extern struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port *p,
+					       struct sk_buff *skb);
 extern int (*br_should_route_hook)(struct sk_buff **pskb);
 
 #endif
--- net-2.6.22.orig/net/bridge/br_input.c
+++ net-2.6.22/net/bridge/br_input.c
@@ -121,13 +121,11 @@ static inline int is_link_local(const un
 
 /*
  * Called via br_handle_frame_hook.
- * Return 0 if *pskb should be processed furthur
- *	  1 if *pskb is handled
+ * Return NULL if skb is handled
  * note: already called with rcu_read_lock (preempt_disabled)
  */
-int br_handle_frame(struct net_bridge_port *p, struct sk_buff **pskb)
+struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
 {
-	struct sk_buff *skb = *pskb;
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 
 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
@@ -135,15 +133,15 @@ int br_handle_frame(struct net_bridge_po
 
 	if (unlikely(is_link_local(dest))) {
 		skb->pkt_type = PACKET_HOST;
-		return NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-			       NULL, br_handle_local_finish) != 0;
+
+		return (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
+				NULL, br_handle_local_finish) == 0) ? skb : NULL;
 	}
 
 	if (p->state == BR_STATE_FORWARDING || p->state == BR_STATE_LEARNING) {
 		if (br_should_route_hook) {
-			if (br_should_route_hook(pskb))
-				return 0;
-			skb = *pskb;
+			if (br_should_route_hook(&skb))
+				return skb;
 			dest = eth_hdr(skb)->h_dest;
 		}
 
@@ -152,10 +150,10 @@ int br_handle_frame(struct net_bridge_po
 
 		NF_HOOK(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 			br_handle_frame_finish);
-		return 1;
+		return NULL;
 	}
 
 err:
 	kfree_skb(skb);
-	return 1;
+	return NULL;
 }
--- net-2.6.22.orig/net/bridge/br_private.h
+++ net-2.6.22/net/bridge/br_private.h
@@ -182,7 +182,8 @@ extern void br_features_recompute(struct
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern int br_handle_frame(struct net_bridge_port *p, struct sk_buff **pskb);
+extern struct sk_buff *br_handle_frame(struct net_bridge_port *p,
+				       struct sk_buff *skb);
 
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
