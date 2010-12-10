From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Use consistent NF_DROP returns in nf_pre_routing
Date: Fri, 10 Dec 2010 11:38:11 +0800
Message-ID: <20101210033811.GA4803@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44512 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389Ab0LJDiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 22:38:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

bridge: Use consistent NF_DROP returns in nf_pre_routing

The nf_pre_routing functions in bridging have collected two
distinct ways of returning NF_DROP over the years, inline and
via goto.  There is no reason for preferring either one.

So this patch arbitrarily picks the inline variant and converts
the all the gotos.

Also removes a redundant comment.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 865fd76..3fb35fb 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -566,26 +566,26 @@ static unsigned int br_nf_pre_routing_ipv6(unsigned int hook,
 	u32 pkt_len;
 
 	if (skb->len < sizeof(struct ipv6hdr))
-		goto inhdr_error;
+		return NF_DROP;
 
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-		goto inhdr_error;
+		return NF_DROP;
 
 	hdr = ipv6_hdr(skb);
 
 	if (hdr->version != 6)
-		goto inhdr_error;
+		return NF_DROP;
 
 	pkt_len = ntohs(hdr->payload_len);
 
 	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
 		if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
-			goto inhdr_error;
+			return NF_DROP;
 		if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr)))
-			goto inhdr_error;
+			return NF_DROP;
 	}
 	if (hdr->nexthdr == NEXTHDR_HOP && check_hbh_len(skb))
-		goto inhdr_error;
+		return NF_DROP;
 
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
@@ -598,9 +598,6 @@ static unsigned int br_nf_pre_routing_ipv6(unsigned int hook,
 		br_nf_pre_routing_finish_ipv6);
 
 	return NF_STOLEN;
-
-inhdr_error:
-	return NF_DROP;
 }
 
 /* Direct IPv6 traffic to br_nf_pre_routing_ipv6.
@@ -619,11 +616,11 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 	__u32 len = nf_bridge_encap_header_len(skb);
 
 	if (unlikely(!pskb_may_pull(skb, len)))
-		goto out;
+		return NF_DROP;
 
 	p = br_port_get_rcu(in);
 	if (p == NULL)
-		goto out;
+		return NF_DROP;
 	br = p->br;
 
 	if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
@@ -645,8 +642,7 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 	nf_bridge_pull_encap_header_rcsum(skb);
 
 	if (br_parse_ip_options(skb))
-		/* Drop invalid packet */
-		goto out;
+		return NF_DROP;
 
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
@@ -660,9 +656,6 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 		br_nf_pre_routing_finish);
 
 	return NF_STOLEN;
-
-out:
-	return NF_DROP;
 }
 
 

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
