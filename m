From: Richard Weinberger <richard@nod.at>
Subject: [PATCH] netfilter: Fix br_nf_pre_routing() in conjunction with bridge-nf-call-ip(6)tables=0
Date: Tue,  3 Jan 2012 14:26:04 +0100
Message-ID: <1325597164-13459-2-git-send-email-richard@nod.at>
References: <4F025A07.2000304@nod.at>
 <1325597164-13459-1-git-send-email-richard@nod.at>
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Richard Weinberger <richard@nod.at>
To: shemminger@vyatta.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1325597164-13459-1-git-send-email-richard@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If net.bridge.bridge-nf-call-iptables or net.bridge.bridge-nf-call-ip6tables
are set to zero xt_physdev has no effect because skb->nf_bridge has not been set up.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 net/bridge/br_netfilter.c |   31 +++++++++++++++++++++++--------
 1 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index fa8b8f7..f38a8e4 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -576,10 +576,12 @@ static unsigned int br_nf_pre_routing_ipv6(unsigned int hook,
 					   struct sk_buff *skb,
 					   const struct net_device *in,
 					   const struct net_device *out,
-					   int (*okfn)(struct sk_buff *))
+					   int (*okfn)(struct sk_buff *),
+					   struct net_bridge *br)
 {
 	const struct ipv6hdr *hdr;
 	u32 pkt_len;
+	struct nf_bridge_info *nf_bridge;
 
 	if (skb->len < sizeof(struct ipv6hdr))
 		return NF_DROP;
@@ -606,6 +608,15 @@ static unsigned int br_nf_pre_routing_ipv6(unsigned int hook,
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
 		return NF_DROP;
+
+	if (!brnf_call_ip6tables && !br->nf_call_ip6tables) {
+		nf_bridge = skb->nf_bridge;
+		nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
+		nf_bridge->physindev = skb->dev;
+
+		return NF_ACCEPT;
+	}
+
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 
@@ -629,6 +640,7 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 {
 	struct net_bridge_port *p;
 	struct net_bridge *br;
+	struct nf_bridge_info *nf_bridge;
 	__u32 len = nf_bridge_encap_header_len(skb);
 
 	if (unlikely(!pskb_may_pull(skb, len)))
@@ -641,16 +653,10 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 
 	if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
 	    IS_PPPOE_IPV6(skb)) {
-		if (!brnf_call_ip6tables && !br->nf_call_ip6tables)
-			return NF_ACCEPT;
-
 		nf_bridge_pull_encap_header_rcsum(skb);
-		return br_nf_pre_routing_ipv6(hook, skb, in, out, okfn);
+		return br_nf_pre_routing_ipv6(hook, skb, in, out, okfn, br);
 	}
 
-	if (!brnf_call_iptables && !br->nf_call_iptables)
-		return NF_ACCEPT;
-
 	if (skb->protocol != htons(ETH_P_IP) && !IS_VLAN_IP(skb) &&
 	    !IS_PPPOE_IP(skb))
 		return NF_ACCEPT;
@@ -663,6 +669,15 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
 		return NF_DROP;
+
+	if (!brnf_call_iptables && !br->nf_call_iptables) {
+		nf_bridge = skb->nf_bridge;
+		nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
+		nf_bridge->physindev = skb->dev;
+
+		return NF_ACCEPT;
+	}
+
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 	store_orig_dstaddr(skb);
-- 
1.7.7.3

