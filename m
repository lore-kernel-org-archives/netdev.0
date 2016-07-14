From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 3/4] net: bridge: drop skb2/skb0 variables and use a local_rcv boolean
Date: Thu, 14 Jul 2016 06:10:01 +0300
Message-ID: <1468465802-4571-4-git-send-email-nikolay@cumulusnetworks.com>
References: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	davem@davemloft.net, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35473 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbcGNSD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 14:03:57 -0400
Received: by mail-pa0-f42.google.com with SMTP id dx3so30956232pab.2
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 11:03:56 -0700 (PDT)
In-Reply-To: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently if the packet is going to be received locally we set skb0 or
sometimes called skb2 variables to the original skb. This can get
confusing and also we can avoid one conditional on the fast path by
simply using a boolean and passing it around. Thanks to Roopa for the
name suggestion.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_forward.c | 35 ++++++++++++++++++-----------------
 net/bridge/br_input.c   | 25 ++++++++++---------------
 net/bridge/br_private.h | 10 +++++-----
 3 files changed, 33 insertions(+), 37 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d610644368b9..204f99304a8a 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -138,17 +138,18 @@ void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 EXPORT_SYMBOL_GPL(br_deliver);
 
 /* called with rcu_read_lock */
-void br_forward(const struct net_bridge_port *to, struct sk_buff *skb, struct sk_buff *skb0)
+void br_forward(const struct net_bridge_port *to, struct sk_buff *skb,
+		bool local_rcv)
 {
 	if (to && should_deliver(to, skb)) {
-		if (skb0)
+		if (local_rcv)
 			deliver_clone(to, skb, __br_forward);
 		else
 			__br_forward(to, skb);
 		return;
 	}
 
-	if (!skb0)
+	if (!local_rcv)
 		kfree_skb(skb);
 }
 
@@ -193,10 +194,9 @@ out:
 
 /* called under bridge lock */
 static void br_flood(struct net_bridge *br, struct sk_buff *skb,
-		     struct sk_buff *skb0,
 		     void (*__packet_hook)(const struct net_bridge_port *p,
 					   struct sk_buff *skb),
-		     bool unicast)
+		     bool local_rcv, bool unicast)
 {
 	u8 igmp_type = br_multicast_igmp_type(skb);
 	struct net_bridge_port *prev;
@@ -227,14 +227,14 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 	if (!prev)
 		goto out;
 
-	if (skb0)
+	if (local_rcv)
 		deliver_clone(prev, skb, __packet_hook);
 	else
 		__packet_hook(prev, skb);
 	return;
 
 out:
-	if (!skb0)
+	if (!local_rcv)
 		kfree_skb(skb);
 }
 
@@ -242,23 +242,24 @@ out:
 /* called with rcu_read_lock */
 void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast)
 {
-	br_flood(br, skb, NULL, __br_deliver, unicast);
+	br_flood(br, skb, __br_deliver, false, unicast);
 }
 
 /* called under bridge lock */
 void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
-		      struct sk_buff *skb2, bool unicast)
+		      bool local_rcv, bool unicast)
 {
-	br_flood(br, skb, skb2, __br_forward, unicast);
+	br_flood(br, skb, __br_forward, local_rcv, unicast);
 }
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 /* called with rcu_read_lock */
 static void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
-			       struct sk_buff *skb, struct sk_buff *skb0,
+			       struct sk_buff *skb,
 			       void (*__packet_hook)(
 					const struct net_bridge_port *p,
-					struct sk_buff *skb))
+					struct sk_buff *skb),
+			       bool local_rcv)
 {
 	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
 	u8 igmp_type = br_multicast_igmp_type(skb);
@@ -295,14 +296,14 @@ static void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
 	if (!prev)
 		goto out;
 
-	if (skb0)
+	if (local_rcv)
 		deliver_clone(prev, skb, __packet_hook);
 	else
 		__packet_hook(prev, skb);
 	return;
 
 out:
-	if (!skb0)
+	if (!local_rcv)
 		kfree_skb(skb);
 }
 
@@ -310,13 +311,13 @@ out:
 void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
 			  struct sk_buff *skb)
 {
-	br_multicast_flood(mdst, skb, NULL, __br_deliver);
+	br_multicast_flood(mdst, skb, __br_deliver, false);
 }
 
 /* called with rcu_read_lock */
 void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
-			  struct sk_buff *skb, struct sk_buff *skb2)
+			  struct sk_buff *skb, bool local_rcv)
 {
-	br_multicast_flood(mdst, skb, skb2, __br_forward);
+	br_multicast_flood(mdst, skb, __br_forward, local_rcv);
 }
 #endif
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index c20c5be6fc22..dd8885def11b 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -131,13 +131,12 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 /* note: already called with rcu_read_lock */
 int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
+	bool local_rcv = false, mcast_hit = false, unicast = true;
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_fdb_entry *dst = NULL;
-	bool mcast_hit = false, unicast = true;
 	struct net_bridge_mdb_entry *mdst;
 	struct net_bridge *br;
-	struct sk_buff *skb2;
 	u16 vid = 0;
 
 	if (!p || p->state == BR_STATE_DISABLED)
@@ -160,17 +159,13 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 
 	BR_INPUT_SKB_CB(skb)->brdev = br->dev;
 
-	/* The packet skb2 goes to the local host (NULL to skip). */
-	skb2 = NULL;
-
-	if (br->dev->flags & IFF_PROMISC)
-		skb2 = skb;
+	local_rcv = !!(br->dev->flags & IFF_PROMISC);
 
 	if (IS_ENABLED(CONFIG_INET) && skb->protocol == htons(ETH_P_ARP))
 		br_do_proxy_arp(skb, br, vid, p);
 
 	if (is_broadcast_ether_addr(dest)) {
-		skb2 = skb;
+		local_rcv = true;
 		unicast = false;
 	} else if (is_multicast_ether_addr(dest)) {
 		mdst = br_mdb_get(br, skb, vid);
@@ -178,12 +173,12 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 		    br_multicast_querier_exists(br, eth_hdr(skb))) {
 			if ((mdst && mdst->mglist) ||
 			    br_multicast_is_router(br)) {
-				skb2 = skb;
+				local_rcv = true;
 				br->dev->stats.multicast++;
 			}
 			mcast_hit = true;
 		} else {
-			skb2 = skb;
+			local_rcv = true;
 			br->dev->stats.multicast++;
 		}
 		unicast = false;
@@ -194,16 +189,16 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 
 	if (dst) {
 		dst->used = jiffies;
-		br_forward(dst->dst, skb, skb2);
+		br_forward(dst->dst, skb, local_rcv);
 	} else {
 		if (!mcast_hit)
-			br_flood_forward(br, skb, skb2, unicast);
+			br_flood_forward(br, skb, local_rcv, unicast);
 		else
-			br_multicast_forward(mdst, skb, skb2);
+			br_multicast_forward(mdst, skb, local_rcv);
 	}
 
-	if (skb2)
-		return br_pass_frame_up(skb2);
+	if (local_rcv)
+		return br_pass_frame_up(skb);
 
 out:
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 40f200947ddc..4d6cdf459e57 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -507,12 +507,12 @@ int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 /* br_forward.c */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
 int br_dev_queue_push_xmit(struct net *net, struct sock *sk, struct sk_buff *skb);
-void br_forward(const struct net_bridge_port *to,
-		struct sk_buff *skb, struct sk_buff *skb0);
+void br_forward(const struct net_bridge_port *to, struct sk_buff *skb,
+		bool local_rcv);
 int br_forward_finish(struct net *net, struct sock *sk, struct sk_buff *skb);
 void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast);
 void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
-		      struct sk_buff *skb2, bool unicast);
+		      bool local_rcv, bool unicast);
 
 /* br_if.c */
 void br_port_carrier_check(struct net_bridge_port *p);
@@ -563,7 +563,7 @@ void br_multicast_dev_del(struct net_bridge *br);
 void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
 			  struct sk_buff *skb);
 void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
-			  struct sk_buff *skb, struct sk_buff *skb2);
+			  struct sk_buff *skb, bool local_rcv);
 int br_multicast_set_router(struct net_bridge *br, unsigned long val);
 int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val);
 int br_multicast_toggle(struct net_bridge *br, unsigned long val);
@@ -698,7 +698,7 @@ static inline void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
 
 static inline void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
 					struct sk_buff *skb,
-					struct sk_buff *skb2)
+					bool local_rcv)
 {
 }
 static inline bool br_multicast_is_router(struct net_bridge *br)
-- 
2.4.3
