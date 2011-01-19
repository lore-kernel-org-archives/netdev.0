From: kaber@trash.net
Subject: [PATCH 22/79] ipvs: allow transmit of GRO aggregated skbs
Date: Wed, 19 Jan 2011 20:14:22 +0100
Message-ID: <1295464519-21763-23-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51979 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632Ab1ASTP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:28 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

Attempt at allowing LVS to transmit skbs of greater than MTU length that
have been aggregated by GRO and can thus be deaggregated by GSO.

Cc: Julian Anastasov <ja@ssi.bg>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 50b131c..fb2a445 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -407,7 +407,8 @@ ip_vs_bypass_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
+	    !skb_is_gso(skb)) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -460,7 +461,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -560,7 +561,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
+	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF)) &&
+	    !skb_is_gso(skb)) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL_PKT(0, AF_INET, pp, skb, 0,
 				 "ip_vs_nat_xmit(): frag needed for");
@@ -675,7 +677,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -790,8 +792,8 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	df |= (old_iph->frag_off & htons(IP_DF));
 
-	if ((old_iph->frag_off & htons(IP_DF))
-	    && mtu < ntohs(old_iph->tot_len)) {
+	if ((old_iph->frag_off & htons(IP_DF) &&
+	    mtu < ntohs(old_iph->tot_len) && !skb_is_gso(skb))) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error_put;
@@ -903,7 +905,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb_dst(skb))
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
 
-	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr)) {
+	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
+	    !skb_is_gso(skb)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -1008,7 +1011,8 @@ ip_vs_dr_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu) {
+	if ((iph->frag_off & htons(IP_DF)) && skb->len > mtu &&
+	    !skb_is_gso(skb)) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
@@ -1175,7 +1179,8 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF))) {
+	if ((skb->len > mtu) && (ip_hdr(skb)->frag_off & htons(IP_DF)) &&
+	    !skb_is_gso(skb)) {
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 		IP_VS_DBG_RL("%s(): frag needed\n", __func__);
 		goto tx_error_put;
@@ -1289,7 +1294,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu) {
+	if (skb->len > mtu && !skb_is_gso(skb)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
-- 
1.7.2.3

