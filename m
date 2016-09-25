From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/53] netfilter: introduce nft_set_pktinfo_{ipv4, ipv6}_validate()
Date: Mon, 26 Sep 2016 01:06:27 +0200
Message-ID: <1474844823-2026-18-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These functions are extracted from the netdev family, they initialize
the pktinfo structure and validate that the IPv4 and IPv6 headers are
well-formed given that these functions are called from a path where
layer 3 sanitization did not happen yet.

These functions are placed in include/net/netfilter/nf_tables_ipv{4,6}.h
so they can be reused by a follow up patch to use them from the bridge
family too.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables_ipv4.h | 42 ++++++++++++++++++
 include/net/netfilter/nf_tables_ipv6.h | 49 +++++++++++++++++++++
 net/netfilter/nf_tables_netdev.c       | 79 +---------------------------------
 3 files changed, 93 insertions(+), 77 deletions(-)

diff --git a/include/net/netfilter/nf_tables_ipv4.h b/include/net/netfilter/nf_tables_ipv4.h
index af952f7843ee..968f00b82fb5 100644
--- a/include/net/netfilter/nf_tables_ipv4.h
+++ b/include/net/netfilter/nf_tables_ipv4.h
@@ -20,6 +20,48 @@ nft_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
 	pkt->xt.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
 }
 
+static inline int
+__nft_set_pktinfo_ipv4_validate(struct nft_pktinfo *pkt,
+				struct sk_buff *skb,
+				const struct nf_hook_state *state)
+{
+	struct iphdr *iph, _iph;
+	u32 len, thoff;
+
+	iph = skb_header_pointer(skb, skb_network_offset(skb), sizeof(*iph),
+				 &_iph);
+	if (!iph)
+		return -1;
+
+	iph = ip_hdr(skb);
+	if (iph->ihl < 5 || iph->version != 4)
+		return -1;
+
+	len = ntohs(iph->tot_len);
+	thoff = iph->ihl * 4;
+	if (skb->len < len)
+		return -1;
+	else if (len < thoff)
+		return -1;
+
+	pkt->tprot_set = true;
+	pkt->tprot = iph->protocol;
+	pkt->xt.thoff = thoff;
+	pkt->xt.fragoff = ntohs(iph->frag_off) & IP_OFFSET;
+
+	return 0;
+}
+
+static inline void
+nft_set_pktinfo_ipv4_validate(struct nft_pktinfo *pkt,
+			      struct sk_buff *skb,
+			      const struct nf_hook_state *state)
+{
+	nft_set_pktinfo(pkt, skb, state);
+	if (__nft_set_pktinfo_ipv4_validate(pkt, skb, state) < 0)
+		nft_set_pktinfo_proto_unspec(pkt, skb);
+}
+
 extern struct nft_af_info nft_af_ipv4;
 
 #endif
diff --git a/include/net/netfilter/nf_tables_ipv6.h b/include/net/netfilter/nf_tables_ipv6.h
index 1e0ffd5aea47..39b7b717b540 100644
--- a/include/net/netfilter/nf_tables_ipv6.h
+++ b/include/net/netfilter/nf_tables_ipv6.h
@@ -28,6 +28,55 @@ nft_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 	return 0;
 }
 
+static inline int
+__nft_set_pktinfo_ipv6_validate(struct nft_pktinfo *pkt,
+				struct sk_buff *skb,
+				const struct nf_hook_state *state)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	struct ipv6hdr *ip6h, _ip6h;
+	unsigned int thoff = 0;
+	unsigned short frag_off;
+	int protohdr;
+	u32 pkt_len;
+
+	ip6h = skb_header_pointer(skb, skb_network_offset(skb), sizeof(*ip6h),
+				  &_ip6h);
+	if (!ip6h)
+		return -1;
+
+	if (ip6h->version != 6)
+		return -1;
+
+	pkt_len = ntohs(ip6h->payload_len);
+	if (pkt_len + sizeof(*ip6h) > skb->len)
+		return -1;
+
+	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
+	if (protohdr < 0)
+		return -1;
+
+	pkt->tprot_set = true;
+	pkt->tprot = protohdr;
+	pkt->xt.thoff = thoff;
+	pkt->xt.fragoff = frag_off;
+
+	return 0;
+#else
+	return -1;
+#endif
+}
+
+static inline void
+nft_set_pktinfo_ipv6_validate(struct nft_pktinfo *pkt,
+			      struct sk_buff *skb,
+			      const struct nf_hook_state *state)
+{
+	nft_set_pktinfo(pkt, skb, state);
+	if (__nft_set_pktinfo_ipv6_validate(pkt, skb, state) < 0)
+		nft_set_pktinfo_proto_unspec(pkt, skb);
+}
+
 extern struct nft_af_info nft_af_ipv6;
 
 #endif
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index 8de502b0c37b..3e5475a833a5 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -15,81 +15,6 @@
 #include <net/netfilter/nf_tables_ipv4.h>
 #include <net/netfilter/nf_tables_ipv6.h>
 
-static inline void
-nft_netdev_set_pktinfo_ipv4(struct nft_pktinfo *pkt,
-			    struct sk_buff *skb,
-			    const struct nf_hook_state *state)
-{
-	struct iphdr *iph, _iph;
-	u32 len, thoff;
-
-	nft_set_pktinfo(pkt, skb, state);
-
-	iph = skb_header_pointer(skb, skb_network_offset(skb), sizeof(*iph),
-				 &_iph);
-	if (!iph)
-		return;
-
-	iph = ip_hdr(skb);
-	if (iph->ihl < 5 || iph->version != 4)
-		return;
-
-	len = ntohs(iph->tot_len);
-	thoff = iph->ihl * 4;
-	if (skb->len < len)
-		return;
-	else if (len < thoff)
-		return;
-
-	pkt->tprot_set = true;
-	pkt->tprot = iph->protocol;
-	pkt->xt.thoff = thoff;
-	pkt->xt.fragoff = ntohs(iph->frag_off) & IP_OFFSET;
-}
-
-static inline void
-__nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
-			      struct sk_buff *skb,
-			      const struct nf_hook_state *state)
-{
-#if IS_ENABLED(CONFIG_IPV6)
-	struct ipv6hdr *ip6h, _ip6h;
-	unsigned int thoff = 0;
-	unsigned short frag_off;
-	int protohdr;
-	u32 pkt_len;
-
-	ip6h = skb_header_pointer(skb, skb_network_offset(skb), sizeof(*ip6h),
-				  &_ip6h);
-	if (!ip6h)
-		return;
-
-	if (ip6h->version != 6)
-		return;
-
-	pkt_len = ntohs(ip6h->payload_len);
-	if (pkt_len + sizeof(*ip6h) > skb->len)
-		return;
-
-	protohdr = ipv6_find_hdr(pkt->skb, &thoff, -1, &frag_off, NULL);
-	if (protohdr < 0)
-                return;
-
-	pkt->tprot_set = true;
-	pkt->tprot = protohdr;
-	pkt->xt.thoff = thoff;
-	pkt->xt.fragoff = frag_off;
-#endif
-}
-
-static inline void nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
-					       struct sk_buff *skb,
-					       const struct nf_hook_state *state)
-{
-	nft_set_pktinfo(pkt, skb, state);
-	__nft_netdev_set_pktinfo_ipv6(pkt, skb, state);
-}
-
 static unsigned int
 nft_do_chain_netdev(void *priv, struct sk_buff *skb,
 		    const struct nf_hook_state *state)
@@ -98,10 +23,10 @@ nft_do_chain_netdev(void *priv, struct sk_buff *skb,
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		nft_netdev_set_pktinfo_ipv4(&pkt, skb, state);
+		nft_set_pktinfo_ipv4_validate(&pkt, skb, state);
 		break;
 	case htons(ETH_P_IPV6):
-		nft_netdev_set_pktinfo_ipv6(&pkt, skb, state);
+		nft_set_pktinfo_ipv6_validate(&pkt, skb, state);
 		break;
 	default:
 		nft_set_pktinfo_unspec(&pkt, skb, state);
-- 
2.1.4

