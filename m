From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] fix oops when mangling and brouting and tcpdumping packets
 (revised)
Date: Wed, 25 Aug 2004 14:15:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825141539.08ca19b8@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bart De Schuymer <bdschuym@pandora.be>, netdev@oss.sgi.com,
        bridge@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The ebtables brouting chain, traversed through the call
br_should_route_hook(), can alter a packet. The redirect target
does this, f.e., to change the MAC destination.

Bart discovered this and proposed a patch; this is a revised version.
This version cleans up the handle_bridge code in net/core/dev.c as well
as getting rid of extra rcu_read_lock and only does the br_port checking
once.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/if_bridge.h b/include/linux/if_bridge.h
--- a/include/linux/if_bridge.h	2004-08-25 14:10:43 -07:00
+++ b/include/linux/if_bridge.h	2004-08-25 14:10:43 -07:00
@@ -105,7 +105,7 @@
 #include <linux/netdevice.h>
 
 extern void brioctl_set(int (*ioctl_hook)(unsigned int, void __user *));
-extern int (*br_handle_frame_hook)(struct sk_buff *skb);
+extern int (*br_handle_frame_hook)(struct net_bridge_port *p, struct sk_buff **pskb);
 extern int (*br_should_route_hook)(struct sk_buff **pskb);
 
 #endif
diff -Nru a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c	2004-08-25 14:10:43 -07:00
+++ b/net/bridge/br_input.c	2004-08-25 14:10:43 -07:00
@@ -45,26 +45,15 @@
 			br_pass_frame_up_finish);
 }
 
+/* note: already called with rcu_read_lock (preempt_disabled) */
 int br_handle_frame_finish(struct sk_buff *skb)
 {
-	struct net_bridge *br;
-	unsigned char *dest;
+	const unsigned char *dest = skb->mac.ethernet->h_dest;
+	struct net_bridge_port *p = skb->dev->br_port;
+	struct net_bridge *br = p->br;
 	struct net_bridge_fdb_entry *dst;
-	struct net_bridge_port *p;
-	int passedup;
+	int passedup = 0;
 
-	dest = skb->mac.ethernet->h_dest;
-
-	rcu_read_lock();
-	p = rcu_dereference(skb->dev->br_port);
-
-	if (p == NULL || p->state == BR_STATE_DISABLED) {
-		kfree_skb(skb);
-		goto out;
-	}
-
-	br = p->br;
-	passedup = 0;
 	if (br->dev->flags & IFF_PROMISC) {
 		struct sk_buff *skb2;
 
@@ -99,20 +88,21 @@
 	br_flood_forward(br, skb, 0);
 
 out:
-	rcu_read_unlock();
 	return 0;
 }
 
-int br_handle_frame(struct sk_buff *skb)
+/*
+ * Called via br_handle_frame_hook.
+ * Return 0 if *pskb should be processed furthur
+ *	  1 if *pskb is handled
+ * note: already called with rcu_read_lock (preempt_disabled) 
+ */
+int br_handle_frame(struct net_bridge_port *p, struct sk_buff **pskb)
 {
-	unsigned char *dest;
-	struct net_bridge_port *p;
-
-	dest = skb->mac.ethernet->h_dest;
+	struct sk_buff *skb = *pskb;
+	const unsigned char *dest = skb->mac.ethernet->h_dest;
 
-	rcu_read_lock();
-	p = skb->dev->br_port;
-	if (p == NULL || p->state == BR_STATE_DISABLED)
+	if (p->state == BR_STATE_DISABLED)
 		goto err;
 
 	if (skb->mac.ethernet->h_source[0] & 1)
@@ -128,15 +118,16 @@
 		if (!dest[5]) {
 			NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev, 
 				NULL, br_stp_handle_bpdu);
-			rcu_read_unlock();
-			return 0;
+			return 1;
 		}
 	}
 
 	else if (p->state == BR_STATE_FORWARDING) {
-		if (br_should_route_hook && br_should_route_hook(&skb)) {
-			rcu_read_unlock();
-			return -1;
+		if (br_should_route_hook) {
+			if (br_should_route_hook(pskb)) 
+				return 0;
+			skb = *pskb;
+			dest = skb->mac.ethernet->h_dest;
 		}
 
 		if (!memcmp(p->br->dev->dev_addr, dest, ETH_ALEN))
@@ -144,12 +135,10 @@
 
 		NF_HOOK(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 			br_handle_frame_finish);
-		rcu_read_unlock();
-		return 0;
+		return 1;
 	}
 
 err:
-	rcu_read_unlock();
 	kfree_skb(skb);
-	return 0;
+	return 1;
 }
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2004-08-25 14:10:43 -07:00
+++ b/net/bridge/br_private.h	2004-08-25 14:10:43 -07:00
@@ -177,7 +177,7 @@
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
-extern int br_handle_frame(struct sk_buff *skb);
+extern int br_handle_frame(struct net_bridge_port *p, struct sk_buff **pskb);
 
 /* br_ioctl.c */
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-08-25 14:10:43 -07:00
+++ b/net/core/dev.c	2004-08-25 14:10:43 -07:00
@@ -1682,37 +1682,28 @@
 	return pt_prev->func(skb, skb->dev, pt_prev);
 }
 
-
 #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
-int (*br_handle_frame_hook)(struct sk_buff *skb);
+int (*br_handle_frame_hook)(struct net_bridge_port *p, struct sk_buff **pskb);
 
-static __inline__ int handle_bridge(struct sk_buff *skb,
-				     struct packet_type *pt_prev)
+static __inline__ int handle_bridge(struct sk_buff **pskb,
+				    struct packet_type **pt_prev, int *ret)
 {
-	int ret = NET_RX_DROP;
-	if (pt_prev)
-		ret = deliver_skb(skb, pt_prev);
+	struct net_bridge_port *port;
 
-	return ret;
-}
-
-#endif
-
-static inline int __handle_bridge(struct sk_buff *skb,
-			struct packet_type **pt_prev, int *ret)
-{
-#if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-	if (skb->dev->br_port && skb->pkt_type != PACKET_LOOPBACK) {
-		*ret = handle_bridge(skb, *pt_prev);
-		if (br_handle_frame_hook(skb) == 0)
-			return 1;
+	if ((*pskb)->pkt_type == PACKET_LOOPBACK ||
+	    (port = rcu_dereference((*pskb)->dev->br_port)) == NULL)
+		return 0;
 
+	if (*pt_prev) {
+		*ret = deliver_skb(*pskb, *pt_prev);
 		*pt_prev = NULL;
-	}
-#endif
-	return 0;
+	} 
+	
+	return br_handle_frame_hook(port, pskb);
 }
-
+#else
+#define handle_bridge(skb, pt_prev, ret)	(0)
+#endif
 
 #ifdef CONFIG_NET_CLS_ACT
 /* TODO: Maybe we should just force sch_ingress to be compiled in
@@ -1817,7 +1808,7 @@
 
 	handle_diverter(skb);
 
-	if (__handle_bridge(skb, &pt_prev, &ret))
+	if (handle_bridge(&skb, &pt_prev, &ret))
 		goto out;
 
 	type = skb->protocol;
