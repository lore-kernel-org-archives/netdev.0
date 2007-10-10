From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/7] [IPSEC]: Move IP protocol setting from transforms into xfrm4_input.c
Date: Wed, 10 Oct 2007 22:40:16 +0800
Message-ID: <E1IfcjQ-00024k-00@gondolin.me.apana.org.au>
References: <20071010143915.GA7650@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3595 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754456AbXJJOkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:40:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move IP protocol setting from transforms into xfrm4_input.c

This patch makes the IPv4 x->type->input functions return the next protocol
instead of setting it directly.  This is identical to how we do things in
IPv6 and will help us merge common code on the input path.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ah4.c          |    5 +++--
 net/ipv4/esp4.c         |    3 +--
 net/ipv4/ipcomp.c       |    7 ++++---
 net/ipv4/xfrm4_input.c  |    7 ++++++-
 net/ipv4/xfrm4_tunnel.c |    2 +-
 5 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 60925fe..4e8e3b0 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -125,6 +125,7 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int ah_hlen;
 	int ihl;
+	int nexthdr;
 	int err = -EINVAL;
 	struct iphdr *iph;
 	struct ip_auth_hdr *ah;
@@ -136,6 +137,7 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	ah = (struct ip_auth_hdr *)skb->data;
 	ahp = x->data;
+	nexthdr = ah->nexthdr;
 	ah_hlen = (ah->hdrlen + 2) << 2;
 
 	if (ah_hlen != XFRM_ALIGN8(sizeof(*ah) + ahp->icv_full_len) &&
@@ -182,13 +184,12 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 			goto out;
 		}
 	}
-	((struct iphdr*)work_buf)->protocol = ah->nexthdr;
 	skb->network_header += ah_hlen;
 	memcpy(skb_network_header(skb), work_buf, ihl);
 	skb->transport_header = skb->network_header;
 	__skb_pull(skb, ah_hlen + ihl);
 
-	return 0;
+	return nexthdr;
 
 out:
 	return err;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 8377bed..6b1a31a 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -257,12 +257,11 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	iph->protocol = nexthdr[1];
 	pskb_trim(skb, skb->len - alen - padlen - 2);
 	__skb_pull(skb, sizeof(*esph) + esp->conf.ivlen);
 	skb_set_transport_header(skb, -ihl);
 
-	return 0;
+	return nexthdr[1];
 
 out:
 	return -EINVAL;
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 32b02de..0bfeb02 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -75,7 +75,6 @@ out:
 static int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err = -ENOMEM;
-	struct iphdr *iph;
 	struct ip_comp_hdr *ipch;
 
 	if (skb_linearize_cow(skb))
@@ -84,12 +83,14 @@ static int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb)
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Remove ipcomp header and decompress original payload */
-	iph = ip_hdr(skb);
 	ipch = (void *)skb->data;
-	iph->protocol = ipch->nexthdr;
 	skb->transport_header = skb->network_header + sizeof(*ipch);
 	__skb_pull(skb, sizeof(*ipch));
 	err = ipcomp_decompress(x, skb);
+	if (err)
+		goto out;
+
+	err = ipch->nexthdr;
 
 out:
 	return err;
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 2fa1082..e9bbfde 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -54,12 +54,14 @@ static int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
 	int xfrm_nr = 0;
 	int decaps = 0;
 	int err = xfrm4_parse_spi(skb, ip_hdr(skb)->protocol, &spi, &seq);
+	unsigned int nhoff = offsetof(struct iphdr, protocol);
 
 	if (err != 0)
 		goto drop;
 
 	do {
 		const struct iphdr *iph = ip_hdr(skb);
+		int nexthdr;
 
 		if (xfrm_nr == XFRM_MAX_DEPTH)
 			goto drop;
@@ -82,9 +84,12 @@ static int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
 		if (xfrm_state_check_expire(x))
 			goto drop_unlock;
 
-		if (x->type->input(x, skb))
+		nexthdr = x->type->input(x, skb);
+		if (nexthdr <= 0)
 			goto drop_unlock;
 
+		skb_network_header(skb)[nhoff] = nexthdr;
+
 		/* only the first xfrm gets the encap type */
 		encap_type = 0;
 
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index e1fafc1..1312417 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -18,7 +18,7 @@ static int ipip_output(struct xfrm_state *x, struct sk_buff *skb)
 
 static int ipip_xfrm_rcv(struct xfrm_state *x, struct sk_buff *skb)
 {
-	return 0;
+	return IPPROTO_IP;
 }
 
 static int ipip_init_state(struct xfrm_state *x)
