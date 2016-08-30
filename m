From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 1/2] net: bridge: change unicast boolean to exact pkt_type
Date: Tue, 30 Aug 2016 15:08:58 +0200
Message-ID: <1472562539-23247-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1472562539-23247-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, sashok@cumulusnetworks.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org, davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35933 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752857AbcH3NJP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 09:09:15 -0400
Received: by mail-wm0-f41.google.com with SMTP id q128so120214675wma.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 06:09:14 -0700 (PDT)
In-Reply-To: <1472562539-23247-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unicast flag and introduce an exact pkt_type. That would help us
for the upcoming per-port multicast flood flag and also slightly reduce the
tests in the input fast path.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_device.c  |  8 ++++----
 net/bridge/br_forward.c |  4 ++--
 net/bridge/br_input.c   | 40 +++++++++++++++++++++++++---------------
 net/bridge/br_private.h |  7 ++++++-
 4 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 09f26940aba5..89a687f3c0a3 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -62,10 +62,10 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 
 	if (is_broadcast_ether_addr(dest)) {
-		br_flood(br, skb, false, false, true);
+		br_flood(br, skb, BR_PKT_BROADCAST, false, true);
 	} else if (is_multicast_ether_addr(dest)) {
 		if (unlikely(netpoll_tx_running(dev))) {
-			br_flood(br, skb, false, false, true);
+			br_flood(br, skb, BR_PKT_MULTICAST, false, true);
 			goto out;
 		}
 		if (br_multicast_rcv(br, NULL, skb, vid)) {
@@ -78,11 +78,11 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 		    br_multicast_querier_exists(br, eth_hdr(skb)))
 			br_multicast_flood(mdst, skb, false, true);
 		else
-			br_flood(br, skb, false, false, true);
+			br_flood(br, skb, BR_PKT_MULTICAST, false, true);
 	} else if ((dst = __br_fdb_get(br, dest, vid)) != NULL) {
 		br_forward(dst->dst, skb, false, true);
 	} else {
-		br_flood(br, skb, true, false, true);
+		br_flood(br, skb, BR_PKT_UNICAST, false, true);
 	}
 out:
 	rcu_read_unlock();
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 32a02de39cd2..a1fc6edfdeb0 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -176,7 +176,7 @@ out:
 
 /* called under rcu_read_lock */
 void br_flood(struct net_bridge *br, struct sk_buff *skb,
-	      bool unicast, bool local_rcv, bool local_orig)
+	      int pkt_type, bool local_rcv, bool local_orig)
 {
 	u8 igmp_type = br_multicast_igmp_type(skb);
 	struct net_bridge_port *prev = NULL;
@@ -184,7 +184,7 @@ void br_flood(struct net_bridge *br, struct sk_buff *skb,
 
 	list_for_each_entry_rcu(p, &br->port_list, list) {
 		/* Do not flood unicast traffic to ports that turn it off */
-		if (unicast && !(p->flags & BR_FLOOD))
+		if (pkt_type == BR_PKT_UNICAST && !(p->flags & BR_FLOOD))
 			continue;
 
 		/* Do not flood to ports that enable proxy ARP */
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 3132cfc80e9d..ddc3b974828a 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -131,11 +131,12 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 /* note: already called with rcu_read_lock */
 int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	bool local_rcv = false, mcast_hit = false, unicast = true;
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_fdb_entry *dst = NULL;
 	struct net_bridge_mdb_entry *mdst;
+	bool local_rcv, mcast_hit = false;
+	int pkt_type = BR_PKT_UNICAST;
 	struct net_bridge *br;
 	u16 vid = 0;
 
@@ -152,24 +153,29 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	if (p->flags & BR_LEARNING)
 		br_fdb_update(br, p, eth_hdr(skb)->h_source, vid, false);
 
-	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
-	    br_multicast_rcv(br, p, skb, vid))
-		goto drop;
+	local_rcv = !!(br->dev->flags & IFF_PROMISC);
+	if (is_multicast_ether_addr(dest)) {
+		/* by definition the broadcast is also a multicast address */
+		if (is_broadcast_ether_addr(dest)) {
+			pkt_type = BR_PKT_BROADCAST;
+			local_rcv = true;
+		} else {
+			pkt_type = BR_PKT_MULTICAST;
+			if (br_multicast_rcv(br, p, skb, vid))
+				goto drop;
+		}
+	}
 
 	if (p->state == BR_STATE_LEARNING)
 		goto drop;
 
 	BR_INPUT_SKB_CB(skb)->brdev = br->dev;
 
-	local_rcv = !!(br->dev->flags & IFF_PROMISC);
-
 	if (IS_ENABLED(CONFIG_INET) && skb->protocol == htons(ETH_P_ARP))
 		br_do_proxy_arp(skb, br, vid, p);
 
-	if (is_broadcast_ether_addr(dest)) {
-		local_rcv = true;
-		unicast = false;
-	} else if (is_multicast_ether_addr(dest)) {
+	switch (pkt_type) {
+	case BR_PKT_MULTICAST:
 		mdst = br_mdb_get(br, skb, vid);
 		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
 		    br_multicast_querier_exists(br, eth_hdr(skb))) {
@@ -183,18 +189,22 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 			local_rcv = true;
 			br->dev->stats.multicast++;
 		}
-		unicast = false;
-	} else if ((dst = __br_fdb_get(br, dest, vid)) && dst->is_local) {
-		/* Do not forward the packet since it's local. */
-		return br_pass_frame_up(skb);
+		break;
+	case BR_PKT_UNICAST:
+		dst = __br_fdb_get(br, dest, vid);
+	default:
+		break;
 	}
 
 	if (dst) {
+		if (dst->is_local)
+			return br_pass_frame_up(skb);
+
 		dst->used = jiffies;
 		br_forward(dst->dst, skb, local_rcv, false);
 	} else {
 		if (!mcast_hit)
-			br_flood(br, skb, unicast, local_rcv, false);
+			br_flood(br, skb, pkt_type, local_rcv, false);
 		else
 			br_multicast_flood(mdst, skb, local_rcv, false);
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2379b2b865c9..d9e492b2a17e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -517,12 +517,17 @@ int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid);
 
 /* br_forward.c */
+enum {
+	BR_PKT_UNICAST,
+	BR_PKT_MULTICAST,
+	BR_PKT_BROADCAST
+};
 int br_dev_queue_push_xmit(struct net *net, struct sock *sk, struct sk_buff *skb);
 void br_forward(const struct net_bridge_port *to, struct sk_buff *skb,
 		bool local_rcv, bool local_orig);
 int br_forward_finish(struct net *net, struct sock *sk, struct sk_buff *skb);
 void br_flood(struct net_bridge *br, struct sk_buff *skb,
-	      bool unicast, bool local_rcv, bool local_orig);
+	      int pkt_type, bool local_rcv, bool local_orig);
 
 /* br_if.c */
 void br_port_carrier_check(struct net_bridge_port *p);
-- 
2.1.4
