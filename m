From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next] netfilter: bridge: kill nf_bridge_pad
Date: Wed, 18 Mar 2015 20:55:31 +0100
Message-ID: <1426708531-6343-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The br_netfilter frag output function calls skb_cow_head() so in
case it needs a larger headroom to e.g. re-add a previously stripped PPPOE
or VLAN header things will still work (at cost of reallocation).

We can then move nf_bridge_encap_header_len to br_netfilter.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Dave, it would be great if you could (n)ack this explicitly
 since it touches ip_fragment().

 include/linux/netfilter_bridge.h | 22 ----------------------
 net/bridge/br_netfilter.c        | 12 ++++++++++++
 net/ipv4/ip_output.c             |  5 +----
 3 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index ed0d3bf..2734977 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -23,18 +23,6 @@ enum nf_br_hook_priorities {
 #define BRNF_8021Q			0x10
 #define BRNF_PPPoE			0x20
 
-static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
-{
-	switch (skb->protocol) {
-	case __cpu_to_be16(ETH_P_8021Q):
-		return VLAN_HLEN;
-	case __cpu_to_be16(ETH_P_PPP_SES):
-		return PPPOE_SES_HLEN;
-	default:
-		return 0;
-	}
-}
-
 static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 {
 	if (unlikely(skb->nf_bridge->mask & BRNF_PPPoE))
@@ -44,15 +32,6 @@ static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 
 int br_handle_frame_finish(struct sk_buff *skb);
 
-/* This is called by the IP fragmenting code and it ensures there is
- * enough room for the encapsulating header (if there is one). */
-static inline unsigned int nf_bridge_pad(const struct sk_buff *skb)
-{
-	if (skb->nf_bridge)
-		return nf_bridge_encap_header_len(skb);
-	return 0;
-}
-
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
@@ -62,7 +41,6 @@ static inline void br_drop_fake_rtable(struct sk_buff *skb)
 }
 
 #else
-#define nf_bridge_pad(skb)			(0)
 #define br_drop_fake_rtable(skb)	        do { } while (0)
 #endif /* CONFIG_BRIDGE_NETFILTER */
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index bd2d24d..f3884a1 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -153,6 +153,18 @@ static inline struct nf_bridge_info *nf_bridge_unshare(struct sk_buff *skb)
 	return nf_bridge;
 }
 
+static unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case __cpu_to_be16(ETH_P_8021Q):
+		return VLAN_HLEN;
+	case __cpu_to_be16(ETH_P_PPP_SES):
+		return PPPOE_SES_HLEN;
+	default:
+		return 0;
+	}
+}
+
 static inline void nf_bridge_push_encap_header(struct sk_buff *skb)
 {
 	unsigned int len = nf_bridge_encap_header_len(skb);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a7aea20..90b49e8 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -636,10 +636,7 @@ slow_path:
 	left = skb->len - hlen;		/* Space per frame */
 	ptr = hlen;		/* Where to start from */
 
-	/* for bridged IP traffic encapsulated inside f.e. a vlan header,
-	 * we need to make room for the encapsulating header
-	 */
-	ll_rs = LL_RESERVED_SPACE_EXTRA(rt->dst.dev, nf_bridge_pad(skb));
+	ll_rs = LL_RESERVED_SPACE(rt->dst.dev);
 
 	/*
 	 *	Fragment the datagram.
-- 
2.0.5

