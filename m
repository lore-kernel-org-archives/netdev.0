From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 4/4] net: bridge: remove _deliver functions and consolidate forward code
Date: Thu, 14 Jul 2016 06:10:02 +0300
Message-ID: <1468465802-4571-5-git-send-email-nikolay@cumulusnetworks.com>
References: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	davem@davemloft.net, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34416 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbcGNSD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 14:03:58 -0400
Received: by mail-pa0-f46.google.com with SMTP id fi15so30744254pac.1
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 11:03:58 -0700 (PDT)
In-Reply-To: <1468465802-4571-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch we had two flavors of most forwarding functions -
_forward and _deliver, the difference being that the latter are used
when the packets are locally originated. Instead of all this function
pointer passing and code duplication, we can just pass a boolean noting
that the packet was locally originated and use that to perform the
necessary checks in __br_forward. This gives a minor performance
improvement but more importantly consolidates the forwarding paths.
Also add a kernel doc comment to explain the exported br_forward()'s
arguments.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_device.c                   |  22 ++--
 net/bridge/br_forward.c                  | 184 +++++++++++--------------------
 net/bridge/br_input.c                    |   6 +-
 net/bridge/br_private.h                  |  27 ++---
 net/bridge/netfilter/nft_reject_bridge.c |   8 +-
 5 files changed, 94 insertions(+), 153 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 8eecd0ec22f2..09f26940aba5 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -61,11 +61,11 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!br_allowed_ingress(br, br_vlan_group_rcu(br), skb, &vid))
 		goto out;
 
-	if (is_broadcast_ether_addr(dest))
-		br_flood_deliver(br, skb, false);
-	else if (is_multicast_ether_addr(dest)) {
+	if (is_broadcast_ether_addr(dest)) {
+		br_flood(br, skb, false, false, true);
+	} else if (is_multicast_ether_addr(dest)) {
 		if (unlikely(netpoll_tx_running(dev))) {
-			br_flood_deliver(br, skb, false);
+			br_flood(br, skb, false, false, true);
 			goto out;
 		}
 		if (br_multicast_rcv(br, NULL, skb, vid)) {
@@ -76,14 +76,14 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 		mdst = br_mdb_get(br, skb, vid);
 		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
 		    br_multicast_querier_exists(br, eth_hdr(skb)))
-			br_multicast_deliver(mdst, skb);
+			br_multicast_flood(mdst, skb, false, true);
 		else
-			br_flood_deliver(br, skb, false);
-	} else if ((dst = __br_fdb_get(br, dest, vid)) != NULL)
-		br_deliver(dst->dst, skb);
-	else
-		br_flood_deliver(br, skb, true);
-
+			br_flood(br, skb, false, false, true);
+	} else if ((dst = __br_fdb_get(br, dest, vid)) != NULL) {
+		br_forward(dst->dst, skb, false, true);
+	} else {
+		br_flood(br, skb, true, false, true);
+	}
 out:
 	rcu_read_unlock();
 	return NETDEV_TX_OK;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 204f99304a8a..63a83d8d7da3 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -21,11 +21,6 @@
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
 
-static int deliver_clone(const struct net_bridge_port *prev,
-			 struct sk_buff *skb,
-			 void (*__packet_hook)(const struct net_bridge_port *p,
-					       struct sk_buff *skb));
-
 /* Don't forward packets to originating port or forwarding disabled */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
@@ -75,106 +70,92 @@ int br_forward_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(br_forward_finish);
 
-static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
+static void __br_forward(const struct net_bridge_port *to,
+			 struct sk_buff *skb, bool local_orig)
 {
 	struct net_bridge_vlan_group *vg;
+	struct net_device *indev;
+	struct net *net;
+	int br_hook;
 
 	vg = nbp_vlan_group_rcu(to);
 	skb = br_handle_vlan(to->br, vg, skb);
 	if (!skb)
 		return;
 
+	indev = skb->dev;
 	skb->dev = to->dev;
-
-	if (unlikely(netpoll_tx_running(to->br->dev))) {
-		if (!is_skb_forwardable(skb->dev, skb))
+	if (!local_orig) {
+		if (skb_warn_if_lro(skb)) {
 			kfree_skb(skb);
-		else {
-			skb_push(skb, ETH_HLEN);
-			br_netpoll_send_skb(to, skb);
+			return;
 		}
-		return;
+		br_hook = NF_BR_FORWARD;
+		skb_forward_csum(skb);
+		net = dev_net(indev);
+	} else {
+		if (unlikely(netpoll_tx_running(to->br->dev))) {
+			if (!is_skb_forwardable(skb->dev, skb)) {
+				kfree_skb(skb);
+			} else {
+				skb_push(skb, ETH_HLEN);
+				br_netpoll_send_skb(to, skb);
+			}
+			return;
+		}
+		br_hook = NF_BR_LOCAL_OUT;
+		net = dev_net(skb->dev);
+		indev = NULL;
 	}
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT,
-		dev_net(skb->dev), NULL, skb,NULL, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, br_hook,
+		net, NULL, skb, indev, skb->dev,
 		br_forward_finish);
 }
 
-static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
+static int deliver_clone(const struct net_bridge_port *prev,
+			 struct sk_buff *skb, bool local_orig)
 {
-	struct net_bridge_vlan_group *vg;
-	struct net_device *indev;
-
-	if (skb_warn_if_lro(skb)) {
-		kfree_skb(skb);
-		return;
-	}
-
-	vg = nbp_vlan_group_rcu(to);
-	skb = br_handle_vlan(to->br, vg, skb);
-	if (!skb)
-		return;
-
-	indev = skb->dev;
-	skb->dev = to->dev;
-	skb_forward_csum(skb);
-
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD,
-		dev_net(indev), NULL, skb, indev, skb->dev,
-		br_forward_finish);
-}
+	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
 
-/* called with rcu_read_lock */
-void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
-{
-	if (to && should_deliver(to, skb)) {
-		__br_deliver(to, skb);
-		return;
+	skb = skb_clone(skb, GFP_ATOMIC);
+	if (!skb) {
+		dev->stats.tx_dropped++;
+		return -ENOMEM;
 	}
 
-	kfree_skb(skb);
+	__br_forward(prev, skb, local_orig);
+	return 0;
 }
-EXPORT_SYMBOL_GPL(br_deliver);
 
-/* called with rcu_read_lock */
-void br_forward(const struct net_bridge_port *to, struct sk_buff *skb,
-		bool local_rcv)
+/**
+ * br_forward - forward a packet to a specific port
+ * @to: destination port
+ * @skb: packet being forwarded
+ * @local_rcv: packet will be received locally after forwarding
+ * @local_orig: packet is locally originated
+ *
+ * Should be called with rcu_read_lock.
+ */
+void br_forward(const struct net_bridge_port *to,
+		struct sk_buff *skb, bool local_rcv, bool local_orig)
 {
 	if (to && should_deliver(to, skb)) {
 		if (local_rcv)
-			deliver_clone(to, skb, __br_forward);
+			deliver_clone(to, skb, local_orig);
 		else
-			__br_forward(to, skb);
+			__br_forward(to, skb, local_orig);
 		return;
 	}
 
 	if (!local_rcv)
 		kfree_skb(skb);
 }
-
-static int deliver_clone(const struct net_bridge_port *prev,
-			 struct sk_buff *skb,
-			 void (*__packet_hook)(const struct net_bridge_port *p,
-					       struct sk_buff *skb))
-{
-	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
-
-	skb = skb_clone(skb, GFP_ATOMIC);
-	if (!skb) {
-		dev->stats.tx_dropped++;
-		return -ENOMEM;
-	}
-
-	__packet_hook(prev, skb);
-	return 0;
-}
+EXPORT_SYMBOL_GPL(br_forward);
 
 static struct net_bridge_port *maybe_deliver(
 	struct net_bridge_port *prev, struct net_bridge_port *p,
-	struct sk_buff *skb,
-	void (*__packet_hook)(const struct net_bridge_port *p,
-			      struct sk_buff *skb))
+	struct sk_buff *skb, bool local_orig)
 {
 	int err;
 
@@ -184,7 +165,7 @@ static struct net_bridge_port *maybe_deliver(
 	if (!prev)
 		goto out;
 
-	err = deliver_clone(prev, skb, __packet_hook);
+	err = deliver_clone(prev, skb, local_orig);
 	if (err)
 		return ERR_PTR(err);
 
@@ -192,18 +173,14 @@ out:
 	return p;
 }
 
-/* called under bridge lock */
-static void br_flood(struct net_bridge *br, struct sk_buff *skb,
-		     void (*__packet_hook)(const struct net_bridge_port *p,
-					   struct sk_buff *skb),
-		     bool local_rcv, bool unicast)
+/* called under rcu_read_lock */
+void br_flood(struct net_bridge *br, struct sk_buff *skb,
+	      bool unicast, bool local_rcv, bool local_orig)
 {
 	u8 igmp_type = br_multicast_igmp_type(skb);
-	struct net_bridge_port *prev;
+	struct net_bridge_port *prev = NULL;
 	struct net_bridge_port *p;
 
-	prev = NULL;
-
 	list_for_each_entry_rcu(p, &br->port_list, list) {
 		/* Do not flood unicast traffic to ports that turn it off */
 		if (unicast && !(p->flags & BR_FLOOD))
@@ -216,7 +193,7 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		    BR_INPUT_SKB_CB(skb)->proxyarp_replied)
 			continue;
 
-		prev = maybe_deliver(prev, p, skb, __packet_hook);
+		prev = maybe_deliver(prev, p, skb, local_orig);
 		if (IS_ERR(prev))
 			goto out;
 		if (prev == p)
@@ -228,9 +205,9 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		goto out;
 
 	if (local_rcv)
-		deliver_clone(prev, skb, __packet_hook);
+		deliver_clone(prev, skb, local_orig);
 	else
-		__packet_hook(prev, skb);
+		__br_forward(prev, skb, local_orig);
 	return;
 
 out:
@@ -238,28 +215,11 @@ out:
 		kfree_skb(skb);
 }
 
-
-/* called with rcu_read_lock */
-void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast)
-{
-	br_flood(br, skb, __br_deliver, false, unicast);
-}
-
-/* called under bridge lock */
-void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
-		      bool local_rcv, bool unicast)
-{
-	br_flood(br, skb, __br_forward, local_rcv, unicast);
-}
-
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 /* called with rcu_read_lock */
-static void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
-			       struct sk_buff *skb,
-			       void (*__packet_hook)(
-					const struct net_bridge_port *p,
-					struct sk_buff *skb),
-			       bool local_rcv)
+void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
+			struct sk_buff *skb,
+			bool local_rcv, bool local_orig)
 {
 	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
 	u8 igmp_type = br_multicast_igmp_type(skb);
@@ -280,7 +240,7 @@ static void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
 		port = (unsigned long)lport > (unsigned long)rport ?
 		       lport : rport;
 
-		prev = maybe_deliver(prev, port, skb, __packet_hook);
+		prev = maybe_deliver(prev, port, skb, local_orig);
 		if (IS_ERR(prev))
 			goto out;
 		if (prev == port)
@@ -297,27 +257,13 @@ static void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
 		goto out;
 
 	if (local_rcv)
-		deliver_clone(prev, skb, __packet_hook);
+		deliver_clone(prev, skb, local_orig);
 	else
-		__packet_hook(prev, skb);
+		__br_forward(prev, skb, local_orig);
 	return;
 
 out:
 	if (!local_rcv)
 		kfree_skb(skb);
 }
-
-/* called with rcu_read_lock */
-void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
-			  struct sk_buff *skb)
-{
-	br_multicast_flood(mdst, skb, __br_deliver, false);
-}
-
-/* called with rcu_read_lock */
-void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
-			  struct sk_buff *skb, bool local_rcv)
-{
-	br_multicast_flood(mdst, skb, __br_forward, local_rcv);
-}
 #endif
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index dd8885def11b..8b08eec763a5 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -189,12 +189,12 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 
 	if (dst) {
 		dst->used = jiffies;
-		br_forward(dst->dst, skb, local_rcv);
+		br_forward(dst->dst, skb, local_rcv, false);
 	} else {
 		if (!mcast_hit)
-			br_flood_forward(br, skb, local_rcv, unicast);
+			br_flood(br, skb, unicast, local_rcv, false);
 		else
-			br_multicast_forward(mdst, skb, local_rcv);
+			br_multicast_flood(mdst, skb, local_rcv, false);
 	}
 
 	if (local_rcv)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4d6cdf459e57..b3088264f844 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -505,14 +505,12 @@ int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid);
 
 /* br_forward.c */
-void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
 int br_dev_queue_push_xmit(struct net *net, struct sock *sk, struct sk_buff *skb);
 void br_forward(const struct net_bridge_port *to, struct sk_buff *skb,
-		bool local_rcv);
+		bool local_rcv, bool local_orig);
 int br_forward_finish(struct net *net, struct sock *sk, struct sk_buff *skb);
-void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast);
-void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
-		      bool local_rcv, bool unicast);
+void br_flood(struct net_bridge *br, struct sk_buff *skb,
+	      bool unicast, bool local_rcv, bool local_orig);
 
 /* br_if.c */
 void br_port_carrier_check(struct net_bridge_port *p);
@@ -560,10 +558,8 @@ void br_multicast_init(struct net_bridge *br);
 void br_multicast_open(struct net_bridge *br);
 void br_multicast_stop(struct net_bridge *br);
 void br_multicast_dev_del(struct net_bridge *br);
-void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
-			  struct sk_buff *skb);
-void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
-			  struct sk_buff *skb, bool local_rcv);
+void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
+			struct sk_buff *skb, bool local_rcv, bool local_orig);
 int br_multicast_set_router(struct net_bridge *br, unsigned long val);
 int br_multicast_set_port_router(struct net_bridge_port *p, unsigned long val);
 int br_multicast_toggle(struct net_bridge *br, unsigned long val);
@@ -691,28 +687,27 @@ static inline void br_multicast_dev_del(struct net_bridge *br)
 {
 }
 
-static inline void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
-					struct sk_buff *skb)
+static inline void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
+				      struct sk_buff *skb,
+				      bool local_rcv, bool local_orig)
 {
 }
 
-static inline void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
-					struct sk_buff *skb,
-					bool local_rcv)
-{
-}
 static inline bool br_multicast_is_router(struct net_bridge *br)
 {
 	return 0;
 }
+
 static inline bool br_multicast_querier_exists(struct net_bridge *br,
 					       struct ethhdr *eth)
 {
 	return false;
 }
+
 static inline void br_mdb_init(void)
 {
 }
+
 static inline void br_mdb_uninit(void)
 {
 }
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 77f7e7a9ebe1..0b77ffbc27d6 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -72,7 +72,7 @@ static void nft_reject_br_send_v4_tcp_reset(struct net *net,
 
 	nft_reject_br_push_etherhdr(oldskb, nskb);
 
-	br_deliver(br_port_get_rcu(dev), nskb);
+	br_forward(br_port_get_rcu(dev), nskb, false, true);
 }
 
 static void nft_reject_br_send_v4_unreach(struct net *net,
@@ -140,7 +140,7 @@ static void nft_reject_br_send_v4_unreach(struct net *net,
 
 	nft_reject_br_push_etherhdr(oldskb, nskb);
 
-	br_deliver(br_port_get_rcu(dev), nskb);
+	br_forward(br_port_get_rcu(dev), nskb, false, true);
 }
 
 static void nft_reject_br_send_v6_tcp_reset(struct net *net,
@@ -174,7 +174,7 @@ static void nft_reject_br_send_v6_tcp_reset(struct net *net,
 
 	nft_reject_br_push_etherhdr(oldskb, nskb);
 
-	br_deliver(br_port_get_rcu(dev), nskb);
+	br_forward(br_port_get_rcu(dev), nskb, false, true);
 }
 
 static bool reject6_br_csum_ok(struct sk_buff *skb, int hook)
@@ -255,7 +255,7 @@ static void nft_reject_br_send_v6_unreach(struct net *net,
 
 	nft_reject_br_push_etherhdr(oldskb, nskb);
 
-	br_deliver(br_port_get_rcu(dev), nskb);
+	br_forward(br_port_get_rcu(dev), nskb, false, true);
 }
 
 static void nft_reject_bridge_eval(const struct nft_expr *expr,
-- 
2.4.3
