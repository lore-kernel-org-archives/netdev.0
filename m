From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/3] Revert "netfilter: bridge: query conntrack about skb dnat"
Date: Fri, 22 May 2015 12:34:06 +0200
Message-ID: <1432290846-4310-4-git-send-email-pablo@netfilter.org>
References: <1432290846-4310-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38984 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161062AbbEVK3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 06:29:23 -0400
In-Reply-To: <1432290846-4310-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This reverts commit c055d5b03bb4cb69d349d787c9787c0383abd8b2.

There are two issues:
'dnat_took_place' made me think that this is related to
-j DNAT/MASQUERADE.

But thats only one part of the story.  This is also relevant for SNAT
when we undo snat translation in reverse/reply direction.

Furthermore, I originally wanted to do this mainly to avoid
storing ipv6 addresses once we make DNAT/REDIRECT work
for ipv6 on bridges.

However, I forgot about SNPT/DNPT which is stateless.

So we can't escape storing address for ipv6 anyway. Might as
well do it for ipv4 too.

Reported-and-tested-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/skbuff.h    |    1 +
 net/bridge/br_netfilter.c |   27 +++++++++------------------
 2 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 66e374d..f15154a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -176,6 +176,7 @@ struct nf_bridge_info {
 	struct net_device	*physindev;
 	struct net_device	*physoutdev;
 	char			neigh_header[8];
+	__be32			ipv4_daddr;
 };
 #endif
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index ab55e24..60ddfbe 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -37,10 +37,6 @@
 #include <net/route.h>
 #include <net/netfilter/br_netfilter.h>
 
-#if IS_ENABLED(CONFIG_NF_CONNTRACK)
-#include <net/netfilter/nf_conntrack.h>
-#endif
-
 #include <asm/uaccess.h>
 #include "br_private.h"
 #ifdef CONFIG_SYSCTL
@@ -350,24 +346,15 @@ free_skb:
 	return 0;
 }
 
-static bool dnat_took_place(const struct sk_buff *skb)
+static bool daddr_was_changed(const struct sk_buff *skb,
+			      const struct nf_bridge_info *nf_bridge)
 {
-#if IS_ENABLED(CONFIG_NF_CONNTRACK)
-	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct;
-
-	ct = nf_ct_get(skb, &ctinfo);
-	if (!ct || nf_ct_is_untracked(ct))
-		return false;
-
-	return test_bit(IPS_DST_NAT_BIT, &ct->status);
-#else
-	return false;
-#endif
+	return ip_hdr(skb)->daddr != nf_bridge->ipv4_daddr;
 }
 
 /* This requires some explaining. If DNAT has taken place,
  * we will need to fix up the destination Ethernet address.
+ * This is also true when SNAT takes place (for the reply direction).
  *
  * There are two cases to consider:
  * 1. The packet was DNAT'ed to a device in the same bridge
@@ -421,7 +408,7 @@ static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 		nf_bridge->pkt_otherhost = false;
 	}
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
-	if (dnat_took_place(skb)) {
+	if (daddr_was_changed(skb, nf_bridge)) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
 			struct in_device *in_dev = __in_dev_get_rcu(dev);
 
@@ -632,6 +619,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
+	struct nf_bridge_info *nf_bridge;
 	struct net_bridge_port *p;
 	struct net_bridge *br;
 	__u32 len = nf_bridge_encap_header_len(skb);
@@ -669,6 +657,9 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 
+	nf_bridge = nf_bridge_info_get(skb);
+	nf_bridge->ipv4_daddr = ip_hdr(skb)->daddr;
+
 	skb->protocol = htons(ETH_P_IP);
 
 	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, state->sk, skb,
-- 
1.7.10.4
