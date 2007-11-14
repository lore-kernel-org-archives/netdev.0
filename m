From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] [IPSEC]: Remove nhoff from xfrm_input
Date: Wed, 14 Nov 2007 14:27:58 +0800
Message-ID: <20071114062758.GA11173@gondor.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au> <E1IplaD-0001J4-00@gondolin.me.apana.org.au> <20071113.214609.04000914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2803 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757676AbXKNG2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:28:01 -0500
Content-Disposition: inline
In-Reply-To: <20071113.214609.04000914.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 09:46:09PM -0800, David Miller wrote:
>
> Applied to net-2.6.25

Thanks for merging Dave!

It looks like I forgot to post the last 2 patches of the series
that complete the async support for the input path.  So here
they are.

[IPSEC]: Remove nhoff from xfrm_input

The nhoff field isn't actually necessary in xfrm_input.  For tunnel mode
transforms we now throw away the output IP header so it makes no sense to
fill in the nexthdr field.  For transport mode we can now let the function
transport_finish do the setting and it knows where the nexthdr field is.

The only other thing that needs the nexthdr field to be set is the header
extraction code.  However, we can simply move the protocol extraction out
of the generic header extraction.

We want to minimise the amount of info we have to carry around between
transforms as this simplifies the resumption process for async crypto.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h      |    1 -
 net/ipv4/xfrm4_input.c  |   11 +++++++----
 net/ipv4/xfrm4_output.c |    2 ++
 net/ipv4/xfrm4_state.c  |    1 -
 net/ipv6/xfrm6_input.c  |    4 +++-
 net/ipv6/xfrm6_output.c |    3 ++-
 net/ipv6/xfrm6_state.c  |    2 --
 net/xfrm/xfrm_input.c   |    5 ++---
 8 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5c457b0..8023795 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -534,7 +534,6 @@ struct xfrm_spi_skb_cb {
 		struct inet6_skb_parm h6;
 	} header;
 
-	unsigned int nhoff;
 	unsigned int daddroff;
 };
 
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index e374903..b19890f 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -41,7 +41,6 @@ drop:
 int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		    int encap_type)
 {
-	XFRM_SPI_SKB_CB(skb)->nhoff = offsetof(struct iphdr, protocol);
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, encap_type);
 }
@@ -49,16 +48,20 @@ EXPORT_SYMBOL(xfrm4_rcv_encap);
 
 int xfrm4_transport_finish(struct sk_buff *skb, int async)
 {
+	struct iphdr *iph = ip_hdr(skb);
+
+	iph->protocol = XFRM_MODE_SKB_CB(skb)->protocol;
+
 #ifdef CONFIG_NETFILTER
 	__skb_push(skb, skb->data - skb_network_header(skb));
-	ip_hdr(skb)->tot_len = htons(skb->len);
-	ip_send_check(ip_hdr(skb));
+	iph->tot_len = htons(skb->len);
+	ip_send_check(iph);
 
 	NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
 		xfrm4_rcv_encap_finish);
 	return 0;
 #else
-	return -ip_hdr(skb)->protocol;
+	return -nexthdr;
 #endif
 }
 
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 2fb4efa..1900200 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -47,6 +47,8 @@ int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (err)
 		return err;
 
+	XFRM_MODE_SKB_CB(skb)->protocol = ip_hdr(skb)->protocol;
+
 	return xfrm4_extract_header(skb);
 }
 
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 3b067e8..d837784 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -56,7 +56,6 @@ int xfrm4_extract_header(struct sk_buff *skb)
 	XFRM_MODE_SKB_CB(skb)->frag_off = iph->frag_off;
 	XFRM_MODE_SKB_CB(skb)->tos = iph->tos;
 	XFRM_MODE_SKB_CB(skb)->ttl = iph->ttl;
-	XFRM_MODE_SKB_CB(skb)->protocol = iph->protocol;
 	memset(XFRM_MODE_SKB_CB(skb)->flow_lbl, 0,
 	       sizeof(XFRM_MODE_SKB_CB(skb)->flow_lbl));
 
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 3b9eedf..5c006c8 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -23,7 +23,6 @@ int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 
 int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
-	XFRM_SPI_SKB_CB(skb)->nhoff = IP6CB(skb)->nhoff;
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, 0);
 }
@@ -31,6 +30,9 @@ EXPORT_SYMBOL(xfrm6_rcv_spi);
 
 int xfrm6_transport_finish(struct sk_buff *skb, int async)
 {
+	skb_network_header(skb)[IP6CB(skb)->nhoff] =
+		XFRM_MODE_SKB_CB(skb)->protocol;
+
 #ifdef CONFIG_NETFILTER
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index a0a9249..318669a 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -53,7 +53,8 @@ int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (err)
 		return err;
 
-	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
+	XFRM_MODE_SKB_CB(skb)->protocol = ipv6_hdr(skb)->nexthdr;
+
 	return xfrm6_extract_header(skb);
 }
 
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 00360b5..df7e98d 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -178,8 +178,6 @@ int xfrm6_extract_header(struct sk_buff *skb)
 	XFRM_MODE_SKB_CB(skb)->frag_off = htons(IP_DF);
 	XFRM_MODE_SKB_CB(skb)->tos = ipv6_get_dsfield(iph);
 	XFRM_MODE_SKB_CB(skb)->ttl = iph->hop_limit;
-	XFRM_MODE_SKB_CB(skb)->protocol =
-		skb_network_header(skb)[IP6CB(skb)->nhoff];
 	memcpy(XFRM_MODE_SKB_CB(skb)->flow_lbl, iph->flow_lbl,
 	       sizeof(XFRM_MODE_SKB_CB(skb)->flow_lbl));
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 5cad522..cce9d45 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -102,7 +102,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	__be32 seq;
 	struct xfrm_state *x;
 	int decaps = 0;
-	unsigned int nhoff = XFRM_SPI_SKB_CB(skb)->nhoff;
 	unsigned int daddroff = XFRM_SPI_SKB_CB(skb)->daddroff;
 
 	/* Allocate new secpath or COW existing one. */
@@ -157,8 +156,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop_unlock;
 		}
 
-		skb_network_header(skb)[nhoff] = nexthdr;
-
 		/* only the first xfrm gets the encap type */
 		encap_type = 0;
 
@@ -170,6 +167,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		spin_unlock(&x->lock);
 
+		XFRM_MODE_SKB_CB(skb)->protocol = nexthdr;
+
 		if (x->inner_mode->input(x, skb))
 			goto drop;
 

-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
