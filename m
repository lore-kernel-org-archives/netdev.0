From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 09/14] netfilter: bridge: add and use nf_bridge_info_get helper
Date: Wed,  1 Apr 2015 22:36:35 +0200
Message-ID: <1427920600-20366-10-git-send-email-fw@strlen.de>
References: <1427920600-20366-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42846 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753500AbbDAUg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 16:36:59 -0400
In-Reply-To: <1427920600-20366-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't access skb->nf_bridge directly, this pointer will be removed soon.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/bridge/br_netfilter.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 947a2f6..40009b1 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -124,6 +124,11 @@ struct brnf_frag_data {
 static DEFINE_PER_CPU(struct brnf_frag_data, brnf_frag_data_storage);
 #endif
 
+static struct nf_bridge_info *nf_bridge_info_get(const struct sk_buff *skb)
+{
+	return skb->nf_bridge;
+}
+
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
 	struct net_bridge_port *port;
@@ -274,7 +279,7 @@ static void nf_bridge_update_protocol(struct sk_buff *skb)
  * bridge PRE_ROUTING hook. */
 static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 {
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
 
 	if (nf_bridge->pkt_otherhost) {
@@ -306,7 +311,6 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
  */
 static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 {
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct neighbour *neigh;
 	struct dst_entry *dst;
 
@@ -316,6 +320,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 	dst = skb_dst(skb);
 	neigh = dst_neigh_lookup_skb(dst, skb);
 	if (neigh) {
+		struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 		int ret;
 
 		if (neigh->hh.hh_len) {
@@ -402,7 +407,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct iphdr *iph = ip_hdr(skb);
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
 	int err;
 	int frag_max_size;
@@ -494,7 +499,7 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
 /* Some common code for IPv4/IPv6 */
 static struct net_device *setup_pre_routing(struct sk_buff *skb)
 {
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		skb->pkt_type = PACKET_HOST;
@@ -694,7 +699,7 @@ static unsigned int br_nf_local_in(const struct nf_hook_ops *ops,
 /* PF_BRIDGE/FORWARD *************************************************/
 static int br_nf_forward_finish(struct sk_buff *skb)
 {
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct net_device *in;
 
 	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
@@ -745,6 +750,10 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	if (!nf_bridge_unshare(skb))
 		return NF_DROP;
 
+	nf_bridge = nf_bridge_info_get(skb);
+	if (!nf_bridge)
+		return NF_DROP;
+
 	parent = bridge_parent(out);
 	if (!parent)
 		return NF_DROP;
@@ -758,7 +767,6 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 
 	nf_bridge_pull_encap_header(skb);
 
-	nf_bridge = skb->nf_bridge;
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		skb->pkt_type = PACKET_HOST;
 		nf_bridge->pkt_otherhost = true;
@@ -917,7 +925,7 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 				       const struct net_device *out,
 				       int (*okfn)(struct sk_buff *))
 {
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct net_device *realoutdev = bridge_parent(skb->dev);
 	u_int8_t pf;
 
@@ -986,7 +994,7 @@ static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
  */
 static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 {
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 
 	skb_pull(skb, ETH_HLEN);
 	nf_bridge->mask &= ~BRNF_BRIDGED_DNAT;
-- 
2.0.5
