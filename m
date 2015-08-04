From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/18] netfilter: bridge: reduce nf_bridge_info to 32 bytes again
Date: Tue,  4 Aug 2015 12:02:46 +0200
Message-ID: <1438682568-8346-17-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56095 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932973AbbHDJ5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:42 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

We can use union for most of the temporary cruft (original ipv4/ipv6
address, source mac, physoutdev) since they're used during different
stages of br netfilter traversal.

Also get rid of the last two ->mask users.

Shrinks struct from 48 to 32 on 64bit arch.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge.h          |   12 +++++++++---
 include/linux/skbuff.h                    |   19 +++++++++++++------
 net/bridge/br_netfilter_hooks.c           |   14 ++++++--------
 net/bridge/br_netfilter_ipv6.c            |    2 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c       |    7 ++-----
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |    7 ++-----
 6 files changed, 33 insertions(+), 28 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 6d80fc6..2437b8a 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -17,9 +17,6 @@ enum nf_br_hook_priorities {
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 
-#define BRNF_BRIDGED_DNAT		0x02
-#define BRNF_NF_BRIDGE_PREROUTING	0x08
-
 int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb);
 
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
@@ -63,8 +60,17 @@ nf_bridge_get_physoutdev(const struct sk_buff *skb)
 {
 	return skb->nf_bridge ? skb->nf_bridge->physoutdev : NULL;
 }
+
+static inline bool nf_bridge_in_prerouting(const struct sk_buff *skb)
+{
+	return skb->nf_bridge && skb->nf_bridge->in_prerouting;
+}
 #else
 #define br_drop_fake_rtable(skb)	        do { } while (0)
+static inline bool nf_bridge_in_prerouting(const struct sk_buff *skb)
+{
+	return false;
+}
 #endif /* CONFIG_BRIDGE_NETFILTER */
 
 #endif
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d6cdd6e..ac732e6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -173,17 +173,24 @@ struct nf_bridge_info {
 		BRNF_PROTO_8021Q,
 		BRNF_PROTO_PPPOE
 	} orig_proto:8;
-	bool			pkt_otherhost;
+	u8			pkt_otherhost:1;
+	u8			in_prerouting:1;
+	u8			bridged_dnat:1;
 	__u16			frag_max_size;
-	unsigned int		mask;
 	struct net_device	*physindev;
 	union {
-		struct net_device *physoutdev;
-		char neigh_header[8];
-	};
-	union {
+		/* prerouting: detect dnat in orig/reply direction */
 		__be32          ipv4_daddr;
 		struct in6_addr ipv6_daddr;
+
+		/* after prerouting + nat detected: store original source
+		 * mac since neigh resolution overwrites it, only used while
+		 * skb is out in neigh layer.
+		 */
+		char neigh_header[8];
+
+		/* always valid & non-NULL from FORWARD on, for physdev match */
+		struct net_device *physoutdev;
 	};
 };
 #endif
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index c8b9bcf..ec51c2b 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -284,7 +284,7 @@ int br_nf_pre_routing_finish_bridge(struct sock *sk, struct sk_buff *skb)
 							 nf_bridge->neigh_header,
 							 ETH_HLEN-ETH_ALEN);
 			/* tell br_dev_xmit to continue with forwarding */
-			nf_bridge->mask |= BRNF_BRIDGED_DNAT;
+			nf_bridge->bridged_dnat = 1;
 			/* FIXME Need to refragment */
 			ret = neigh->output(neigh, skb);
 		}
@@ -356,7 +356,7 @@ static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
 	}
-	nf_bridge->mask &= ~BRNF_NF_BRIDGE_PREROUTING;
+	nf_bridge->in_prerouting = 0;
 	if (br_nf_ipv4_daddr_was_changed(skb, nf_bridge)) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
 			struct in_device *in_dev = __in_dev_get_rcu(dev);
@@ -444,7 +444,7 @@ struct net_device *setup_pre_routing(struct sk_buff *skb)
 		nf_bridge->pkt_otherhost = true;
 	}
 
-	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
+	nf_bridge->in_prerouting = 1;
 	nf_bridge->physindev = skb->dev;
 	skb->dev = brnf_get_logical_dev(skb, skb->dev);
 
@@ -850,10 +850,8 @@ static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
 				   struct sk_buff *skb,
 				   const struct nf_hook_state *state)
 {
-	if (skb->nf_bridge &&
-	    !(skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
+	if (skb->nf_bridge && !skb->nf_bridge->in_prerouting)
 		return NF_STOP;
-	}
 
 	return NF_ACCEPT;
 }
@@ -872,7 +870,7 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 
 	skb_pull(skb, ETH_HLEN);
-	nf_bridge->mask &= ~BRNF_BRIDGED_DNAT;
+	nf_bridge->bridged_dnat = 0;
 
 	BUILD_BUG_ON(sizeof(nf_bridge->neigh_header) != (ETH_HLEN - ETH_ALEN));
 
@@ -887,7 +885,7 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 
 static int br_nf_dev_xmit(struct sk_buff *skb)
 {
-	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
+	if (skb->nf_bridge && skb->nf_bridge->bridged_dnat) {
 		br_nf_pre_routing_finish_bridge_slow(skb);
 		return 1;
 	}
diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index 13b7d1e..77383bf 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -174,7 +174,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
 	}
-	nf_bridge->mask &= ~BRNF_NF_BRIDGE_PREROUTING;
+	nf_bridge->in_prerouting = 0;
 	if (br_nf_ipv6_daddr_was_changed(skb, nf_bridge)) {
 		skb_dst_drop(skb);
 		v6ops->route_input(skb);
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index c88b7d4..b69e82b 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -49,12 +49,9 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 	if (skb->nfct)
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
 #endif
-
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge &&
-	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
+	if (nf_bridge_in_prerouting(skb))
 		return IP_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
-#endif
+
 	if (hooknum == NF_INET_PRE_ROUTING)
 		return IP_DEFRAG_CONNTRACK_IN + zone;
 	else
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index a45db0b..267fb8d 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -39,12 +39,9 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 	if (skb->nfct)
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
 #endif
-
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	if (skb->nf_bridge &&
-	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
+	if (nf_bridge_in_prerouting(skb))
 		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
-#endif
+
 	if (hooknum == NF_INET_PRE_ROUTING)
 		return IP6_DEFRAG_CONNTRACK_IN + zone;
 	else
-- 
1.7.10.4
