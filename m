From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/5] bridge: add proper RCU annotation to should_route_hook
Date: Mon, 15 Nov 2010 08:38:11 -0800
Message-ID: <20101115163828.160885186@vyatta.com>
References: <20101115163809.215552143@vyatta.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38459 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757949Ab0KOQlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 11:41:44 -0500
Content-Disposition: inline; filename=bridge-hook-typedef.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Add br_should_route_hook_t typedef, this is the only way we can
get a clean RCU implementation for function pointer.

Move route_hook to location where it is used.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/if_bridge.h             |    4 +++-
 net/bridge/br.c                       |    4 ----
 net/bridge/br_input.c                 |   10 +++++++---
 net/bridge/netfilter/ebtable_broute.c |    3 ++-
 4 files changed, 12 insertions(+), 9 deletions(-)

--- a/net/bridge/br.c	2010-11-14 11:18:54.048692005 -0800
+++ b/net/bridge/br.c	2010-11-14 11:19:47.347027185 -0800
@@ -22,8 +22,6 @@
 
 #include "br_private.h"
 
-int (*br_should_route_hook)(struct sk_buff *skb);
-
 static const struct stp_proto br_stp_proto = {
 	.rcv	= br_stp_rcv,
 };
@@ -102,8 +100,6 @@ static void __exit br_deinit(void)
 	br_fdb_fini();
 }
 
-EXPORT_SYMBOL(br_should_route_hook);
-
 module_init(br_init)
 module_exit(br_deinit)
 MODULE_LICENSE("GPL");
--- a/net/bridge/br_input.c	2010-11-14 11:18:54.048692005 -0800
+++ b/net/bridge/br_input.c	2010-11-14 11:41:40.558700481 -0800
@@ -21,6 +21,10 @@
 /* Bridge group multicast address 802.1d (pg 51). */
 const u8 br_group_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
 
+/* Hook for brouter */
+br_should_route_hook_t __rcu *br_should_route_hook __read_mostly;
+EXPORT_SYMBOL(br_should_route_hook);
+
 static int br_pass_frame_up(struct sk_buff *skb)
 {
 	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
@@ -139,7 +143,7 @@ struct sk_buff *br_handle_frame(struct s
 {
 	struct net_bridge_port *p;
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
-	int (*rhook)(struct sk_buff *skb);
+	br_should_route_hook_t *rhook;
 
 	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
 		return skb;
@@ -173,8 +177,8 @@ forward:
 	switch (p->state) {
 	case BR_STATE_FORWARDING:
 		rhook = rcu_dereference(br_should_route_hook);
-		if (rhook != NULL) {
-			if (rhook(skb))
+		if (rhook) {
+			if ((*rhook)(skb))
 				return skb;
 			dest = eth_hdr(skb)->h_dest;
 		}
--- a/include/linux/if_bridge.h	2010-11-14 11:18:54.048692005 -0800
+++ b/include/linux/if_bridge.h	2010-11-14 11:19:47.351028008 -0800
@@ -102,7 +102,9 @@ struct __fdb_entry {
 #include <linux/netdevice.h>
 
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
-extern int (*br_should_route_hook)(struct sk_buff *skb);
+
+typedef int (*br_should_route_hook_t)(struct sk_buff *skb);
+extern br_should_route_hook_t __rcu *br_should_route_hook;
 
 #endif
 
--- a/net/bridge/netfilter/ebtable_broute.c	2010-11-14 11:20:39.745149494 -0800
+++ b/net/bridge/netfilter/ebtable_broute.c	2010-11-14 11:21:01.020917528 -0800
@@ -87,7 +87,8 @@ static int __init ebtable_broute_init(vo
 	if (ret < 0)
 		return ret;
 	/* see br_input.c */
-	rcu_assign_pointer(br_should_route_hook, ebt_broute);
+	rcu_assign_pointer(br_should_route_hook,
+			   (br_should_route_hook_t *)ebt_broute);
 	return 0;
 }
 


