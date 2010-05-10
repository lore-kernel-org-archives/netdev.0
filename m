From: kaber@trash.net
Subject: [PATCH 69/84] netfilter: bridge-netfilter: Fix MAC header handling with IP DNAT
Date: Mon, 10 May 2010 22:18:40 +0200
Message-ID: <1273522735-24672-70-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54512 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756928Ab0EJUT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:27 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bart De Schuymer <bdschuym@pandora.be>

- fix IP DNAT on vlan- or pppoe-encapsulated traffic: The functions
neigh_hh_output() or dst->neighbour->output() overwrite the complete
Ethernet header, although we only need the destination MAC address.
For encapsulated packets, they ended up overwriting the encapsulating
header. The new code copies the Ethernet source MAC address and
protocol number before calling dst->neighbour->output(). The Ethernet
source MAC and protocol number are copied back in place in
br_nf_pre_routing_finish_bridge_slow(). This also makes the IP DNAT
more transparent because in the old scheme the source MAC of the
bridge was copied into the source address in the Ethernet header. We
also let skb->protocol equal ETH_P_IP resp. ETH_P_IPV6 during the
execution of the PF_INET resp. PF_INET6 hooks.

- Speed up IP DNAT by calling neigh_hh_bridge() instead of
neigh_hh_output(): if dst->hh is available, we already know the MAC
address so we can just copy it.

Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_bridge.h |    5 ++-
 include/net/neighbour.h          |   14 ++++++
 net/bridge/br_netfilter.c        |   90 +++++++++++++++++++++++++++----------
 3 files changed, 83 insertions(+), 26 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index ffab6c4..ea0e44b 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -43,7 +43,8 @@ enum nf_br_hook_priorities {
 #define BRNF_BRIDGED_DNAT		0x02
 #define BRNF_BRIDGED			0x04
 #define BRNF_NF_BRIDGE_PREROUTING	0x08
-
+#define BRNF_8021Q			0x10
+#define BRNF_PPPoE			0x20
 
 /* Only used in br_forward.c */
 extern int nf_bridge_copy_header(struct sk_buff *skb);
@@ -75,6 +76,8 @@ static inline int br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 
 	skb_pull(skb, ETH_HLEN);
 	nf_bridge->mask ^= BRNF_BRIDGED_DNAT;
+	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
+				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
 	skb->dev = nf_bridge->physindev;
 	return br_handle_frame_finish(skb);
 }
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index da1d58b..eb21340 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -299,6 +299,20 @@ static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 	return 0;
 }
 
+#ifdef CONFIG_BRIDGE_NETFILTER
+static inline int neigh_hh_bridge(struct hh_cache *hh, struct sk_buff *skb)
+{
+	unsigned seq, hh_alen;
+
+	do {
+		seq = read_seqbegin(&hh->hh_lock);
+		hh_alen = HH_DATA_ALIGN(ETH_HLEN);
+		memcpy(skb->data - hh_alen, hh->hh_data, ETH_ALEN + hh_alen - ETH_HLEN);
+	} while (read_seqretry(&hh->hh_lock, seq));
+	return 0;
+}
+#endif
+
 static inline int neigh_hh_output(struct hh_cache *hh, struct sk_buff *skb)
 {
 	unsigned seq;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 05dc630..b7e405d 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -196,15 +196,24 @@ static inline void nf_bridge_save_header(struct sk_buff *skb)
 					 skb->nf_bridge->data, header_size);
 }
 
-/*
- * When forwarding bridge frames, we save a copy of the original
- * header before processing.
+static inline void nf_bridge_update_protocol(struct sk_buff *skb)
+{
+	if (skb->nf_bridge->mask & BRNF_8021Q)
+		skb->protocol = htons(ETH_P_8021Q);
+	else if (skb->nf_bridge->mask & BRNF_PPPoE)
+		skb->protocol = htons(ETH_P_PPP_SES);
+}
+
+/* Fill in the header for fragmented IP packets handled by
+ * the IPv4 connection tracking code.
  */
 int nf_bridge_copy_header(struct sk_buff *skb)
 {
 	int err;
-	int header_size = ETH_HLEN + nf_bridge_encap_header_len(skb);
+	unsigned int header_size;
 
+	nf_bridge_update_protocol(skb);
+	header_size = ETH_HLEN + nf_bridge_encap_header_len(skb);
 	err = skb_cow_head(skb, header_size);
 	if (err)
 		return err;
@@ -238,6 +247,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	skb_dst_set(skb, &rt->u.dst);
 
 	skb->dev = nf_bridge->physindev;
+	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
 	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 		       br_handle_frame_finish, 1);
@@ -245,6 +255,38 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	return 0;
 }
 
+/* Obtain the correct destination MAC address, while preserving the original
+ * source MAC address. If we already know this address, we just copy it. If we
+ * don't, we use the neighbour framework to find out. In both cases, we make
+ * sure that br_handle_frame_finish() is called afterwards.
+ */
+static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
+{
+	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct dst_entry *dst;
+
+	skb->dev = bridge_parent(skb->dev);
+	if (!skb->dev)
+		goto free_skb;
+	dst = skb_dst(skb);
+	if (dst->hh) {
+		neigh_hh_bridge(dst->hh, skb);
+		skb->dev = nf_bridge->physindev;
+		return br_handle_frame_finish(skb);
+	} else if (dst->neighbour) {
+		/* the neighbour function below overwrites the complete
+		 * MAC header, so we save the Ethernet source address and
+		 * protocol number. */
+		skb_copy_from_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN), skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
+		/* tell br_dev_xmit to continue with forwarding */
+		nf_bridge->mask |= BRNF_BRIDGED_DNAT;
+		return dst->neighbour->output(skb);
+	}
+free_skb:
+	kfree_skb(skb);
+	return 0;
+}
+
 /* This requires some explaining. If DNAT has taken place,
  * we will need to fix up the destination Ethernet address.
  *
@@ -283,25 +325,6 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
  * device, we proceed as if ip_route_input() succeeded. If it differs from the
  * logical bridge port or if ip_route_output_key() fails we drop the packet.
  */
-
-static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
-{
-	skb->dev = bridge_parent(skb->dev);
-	if (skb->dev) {
-		struct dst_entry *dst = skb_dst(skb);
-
-		nf_bridge_pull_encap_header(skb);
-		skb->nf_bridge->mask |= BRNF_BRIDGED_DNAT;
-
-		if (dst->hh)
-			return neigh_hh_output(dst->hh, skb);
-		else if (dst->neighbour)
-			return dst->neighbour->output(skb);
-	}
-	kfree_skb(skb);
-	return 0;
-}
-
 static int br_nf_pre_routing_finish(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
@@ -354,6 +377,7 @@ free_skb:
 			if (skb_dst(skb)->dev == dev) {
 bridged_dnat:
 				skb->dev = nf_bridge->physindev;
+				nf_bridge_update_protocol(skb);
 				nf_bridge_push_encap_header(skb);
 				NF_HOOK_THRESH(NFPROTO_BRIDGE,
 					       NF_BR_PRE_ROUTING,
@@ -376,6 +400,7 @@ bridged_dnat:
 	}
 
 	skb->dev = nf_bridge->physindev;
+	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
 	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 		       br_handle_frame_finish, 1);
@@ -396,6 +421,10 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
 	nf_bridge->physindev = skb->dev;
 	skb->dev = bridge_parent(skb->dev);
+	if (skb->protocol == htons(ETH_P_8021Q))
+		nf_bridge->mask |= BRNF_8021Q;
+	else if (skb->protocol == htons(ETH_P_PPP_SES))
+		nf_bridge->mask |= BRNF_PPPoE;
 
 	return skb->dev;
 }
@@ -494,6 +523,7 @@ static unsigned int br_nf_pre_routing_ipv6(unsigned int hook,
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 
+	skb->protocol = htons(ETH_P_IPV6);
 	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish_ipv6);
 
@@ -566,6 +596,7 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 	store_orig_dstaddr(skb);
+	skb->protocol = htons(ETH_P_IP);
 
 	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish);
@@ -614,7 +645,9 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 	} else {
 		in = *((struct net_device **)(skb->cb));
 	}
+	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
+
 	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, in,
 		       skb->dev, br_forward_finish, 1);
 	return 0;
@@ -666,6 +699,10 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 	/* The physdev module checks on this */
 	nf_bridge->mask |= BRNF_BRIDGED;
 	nf_bridge->physoutdev = skb->dev;
+	if (pf == PF_INET)
+		skb->protocol = htons(ETH_P_IP);
+	else
+		skb->protocol = htons(ETH_P_IPV6);
 
 	NF_HOOK(pf, NF_INET_FORWARD, skb, bridge_parent(in), parent,
 		br_nf_forward_finish);
@@ -706,8 +743,7 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff *skb,
 #if defined(CONFIG_NF_CONNTRACK_IPV4) || defined(CONFIG_NF_CONNTRACK_IPV4_MODULE)
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
-	if (skb->nfct != NULL &&
-	    (skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb)) &&
+	if (skb->nfct != NULL && skb->protocol == htons(ETH_P_IP) &&
 	    skb->len > skb->dev->mtu &&
 	    !skb_is_gso(skb))
 		return ip_fragment(skb, br_dev_queue_push_xmit);
@@ -755,6 +791,10 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 
 	nf_bridge_pull_encap_header(skb);
 	nf_bridge_save_header(skb);
+	if (pf == PF_INET)
+		skb->protocol = htons(ETH_P_IP);
+	else
+		skb->protocol = htons(ETH_P_IPV6);
 
 	NF_HOOK(pf, NF_INET_POST_ROUTING, skb, NULL, realoutdev,
 		br_nf_dev_queue_xmit);
-- 
1.7.0.4

