From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/7] [IPSEC]: Use IPv6 calling convention as the convention for x->mode->output
Date: Wed, 10 Oct 2007 22:40:13 +0800
Message-ID: <E1IfcjN-00024M-00@gondolin.me.apana.org.au>
References: <20071010143915.GA7650@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3585 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754403AbXJJOk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:40:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Use IPv6 calling convention as the convention for x->mode->output

The IPv6 calling convention for x->mode->output is more general and could
help an eventual protocol-generic x->type->output implementation.  This
patch adopts it for IPv4 as well and modifies the IPv4 type output functions
accordingly.

It also rewrites the IPv6 mac/transport header calculation to be based off
the network header where practical.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h              |   12 ++++++++++++
 net/ipv4/ah4.c                  |    6 +++---
 net/ipv4/esp4.c                 |   11 +++++------
 net/ipv4/ipcomp.c               |   10 +++++-----
 net/ipv4/xfrm4_mode_beet.c      |   17 +++++++----------
 net/ipv4/xfrm4_mode_transport.c |    7 +++----
 net/ipv4/xfrm4_mode_tunnel.c    |    7 +++----
 net/ipv6/xfrm6_mode_beet.c      |    9 +--------
 net/ipv6/xfrm6_mode_ro.c        |    9 +--------
 net/ipv6/xfrm6_mode_transport.c |    9 +--------
 net/ipv6/xfrm6_mode_tunnel.c    |   14 +++-----------
 11 files changed, 44 insertions(+), 67 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1c116dc..77be396 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -300,6 +300,18 @@ extern void xfrm_put_type(struct xfrm_type *type);
 
 struct xfrm_mode {
 	int (*input)(struct xfrm_state *x, struct sk_buff *skb);
+
+	/*
+	 * Add encapsulation header.
+	 *
+	 * On exit, the transport header will be set to the start of the
+	 * encapsulation header to be filled in by x->type->output and
+	 * the mac header will be set to the nextheader (protocol for
+	 * IPv4) field of the extension header directly preceding the
+	 * encapsulation header, or in its absence, that of the top IP
+	 * header.  The value of the network header will always point
+	 * to the top IP header while skb->data will point to the payload.
+	 */
 	int (*output)(struct xfrm_state *x,struct sk_buff *skb);
 
 	struct module *owner;
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index dbb1f11..e4f7aa3 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -82,14 +82,14 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 			goto error;
 	}
 
-	ah = (struct ip_auth_hdr *)((char *)top_iph+top_iph->ihl*4);
-	ah->nexthdr = top_iph->protocol;
+	ah = (struct ip_auth_hdr *)skb_transport_header(skb);
+	ah->nexthdr = *skb_mac_header(skb);
+	*skb_mac_header(skb) = IPPROTO_AH;
 
 	top_iph->tos = 0;
 	top_iph->tot_len = htons(skb->len);
 	top_iph->frag_off = 0;
 	top_iph->ttl = 0;
-	top_iph->protocol = IPPROTO_AH;
 	top_iph->check = 0;
 
 	ahp = x->data;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 0f5e838..93153d1 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -60,10 +60,10 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb_push(skb, -skb_network_offset(skb));
 	top_iph = ip_hdr(skb);
-	esph = (struct ip_esp_hdr *)(skb_network_header(skb) +
-				     top_iph->ihl * 4);
+	esph = (struct ip_esp_hdr *)skb_transport_header(skb);
 	top_iph->tot_len = htons(skb->len + alen);
-	*(skb_tail_pointer(trailer) - 1) = top_iph->protocol;
+	*(skb_tail_pointer(trailer) - 1) = *skb_mac_header(skb);
+	*skb_mac_header(skb) = IPPROTO_ESP;
 
 	spin_lock_bh(&x->lock);
 
@@ -91,9 +91,8 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 			break;
 		}
 
-		top_iph->protocol = IPPROTO_UDP;
-	} else
-		top_iph->protocol = IPPROTO_ESP;
+		*skb_mac_header(skb) = IPPROTO_UDP;
+	}
 
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 1929d45..bf74f64 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -98,10 +98,10 @@ out:
 static int ipcomp_compress(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipcomp_data *ipcd = x->data;
-	const int ihlen = ip_hdrlen(skb);
+	const int ihlen = skb_transport_offset(skb);
 	const int plen = skb->len - ihlen;
 	int dlen = IPCOMP_SCRATCH_SIZE;
-	u8 *start = skb->data + ihlen;
+	u8 *start = skb_transport_header(skb);
 	const int cpu = get_cpu();
 	u8 *scratch = *per_cpu_ptr(ipcomp_scratches, cpu);
 	struct crypto_comp *tfm = *per_cpu_ptr(ipcd->tfms, cpu);
@@ -154,11 +154,11 @@ static int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	/* Install ipcomp header, convert into ipcomp datagram. */
 	iph->tot_len = htons(skb->len);
-	ipch = (struct ip_comp_hdr *)((char *)iph + iph->ihl * 4);
-	ipch->nexthdr = iph->protocol;
+	ipch = (struct ip_comp_hdr *)skb_transport_header(skb);
+	ipch->nexthdr = *skb_mac_header(skb);
 	ipch->flags = 0;
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
-	iph->protocol = IPPROTO_COMP;
+	*skb_mac_header(skb) = IPPROTO_COMP;
 	ip_send_check(iph);
 	return 0;
 
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 77888f5..7226c64 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -23,17 +23,14 @@
  * The following fields in it shall be filled in by x->type->output:
  *      tot_len
  *      check
- *
- * On exit, skb->h will be set to the start of the payload to be processed
- * by x->type->output and skb->nh will be set to the top IP header.
  */
 static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
+	struct ip_beet_phdr *ph;
 	struct iphdr *iph, *top_iph;
 	int hdrlen, optlen;
 
 	iph = ip_hdr(skb);
-	skb->transport_header = skb->network_header;
 
 	hdrlen = 0;
 	optlen = iph->ihl * 4 - sizeof(*iph);
@@ -42,17 +39,17 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
 				    hdrlen);
-	top_iph = ip_hdr(skb);
-	skb->transport_header += sizeof(*iph) - hdrlen;
-	__skb_pull(skb, sizeof(*iph) - hdrlen);
+	skb->mac_header = skb->network_header +
+			  offsetof(struct iphdr, protocol);
+	skb->transport_header = skb->network_header + sizeof(*iph);
+
+	ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iph) - hdrlen);
 
+	top_iph = ip_hdr(skb);
 	memmove(top_iph, iph, sizeof(*iph));
 	if (unlikely(optlen)) {
-		struct ip_beet_phdr *ph;
-
 		BUG_ON(optlen < 0);
 
-		ph = (struct ip_beet_phdr *)skb_transport_header(skb);
 		ph->padlen = 4 - (optlen & 4);
 		ph->hdrlen = optlen / 8;
 		ph->nexthdr = top_iph->protocol;
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index 10499d2..fd840c7 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -17,17 +17,16 @@
  *
  * The IP header will be moved forward to make space for the encapsulation
  * header.
- *
- * On exit, skb->h will be set to the start of the payload to be processed
- * by x->type->output and skb->nh will be set to the top IP header.
  */
 static int xfrm4_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 	int ihl = iph->ihl * 4;
 
-	skb->transport_header = skb->network_header + ihl;
 	skb_set_network_header(skb, -x->props.header_len);
+	skb->mac_header = skb->network_header +
+			  offsetof(struct iphdr, protocol);
+	skb->transport_header = skb->network_header + ihl;
 	__skb_pull(skb, ihl);
 	memmove(skb_network_header(skb), iph, ihl);
 	return 0;
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index bac1a91..f1d41ea 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -35,9 +35,6 @@ static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
  * in it shall be filled in by x->type->output:
  *      tot_len
  *      check
- *
- * On exit, skb->h will be set to the start of the payload to be processed
- * by x->type->output and skb->nh will be set to the top IP header.
  */
 static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -47,9 +44,11 @@ static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	int flags;
 
 	iph = ip_hdr(skb);
-	skb->transport_header = skb->network_header;
 
 	skb_set_network_header(skb, -x->props.header_len);
+	skb->mac_header = skb->network_header +
+			  offsetof(struct iphdr, protocol);
+	skb->transport_header = skb->network_header + sizeof(*iph);
 	top_iph = ip_hdr(skb);
 
 	top_iph->ihl = 5;
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index bca018d..42c6ef8 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -24,13 +24,6 @@
  * The top IP header will be constructed per draft-nikander-esp-beet-mode-06.txt.
  * The following fields in it shall be filled in by x->type->output:
  *	payload_len
- *
- * On exit, skb->h will be set to the start of the encapsulation header to be
- * filled in by x->type->output and the mac header will be set to the
- * nextheader field of the extension header directly preceding the
- * encapsulation header, or in its absence, that of the top IP header.
- * The value of the network header will always point to the top IP header
- * while skb->data will point to the payload.
  */
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -44,7 +37,7 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
 	skb_set_network_header(skb, -x->props.header_len);
-	skb_set_transport_header(skb, hdr_len - x->props.header_len);
+	skb->transport_header = skb->network_header + hdr_len;
 	__skb_pull(skb, hdr_len);
 
 	top_iph = ipv6_hdr(skb);
diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index 5c29b36..957ae36 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -37,13 +37,6 @@
  *
  * The IP header and mutable extension headers will be moved forward to make
  * space for the route optimization header.
- *
- * On exit, skb->h will be set to the start of the encapsulation header to be
- * filled in by x->type->output and the mac header will be set to the
- * nextheader field of the extension header directly preceding the
- * encapsulation header, or in its absence, that of the top IP header.
- * The value of the network header will always point to the top IP header
- * while skb->data will point to the payload.
  */
 static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -56,7 +49,7 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
 	skb_set_network_header(skb, -x->props.header_len);
-	skb_set_transport_header(skb, hdr_len - x->props.header_len);
+	skb->transport_header = skb->network_header + hdr_len;
 	__skb_pull(skb, hdr_len);
 	memmove(ipv6_hdr(skb), iph, hdr_len);
 
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
index f2ee186..4e34410 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -18,13 +18,6 @@
  *
  * The IP header and mutable extension headers will be moved forward to make
  * space for the encapsulation header.
- *
- * On exit, skb->h will be set to the start of the encapsulation header to be
- * filled in by x->type->output and the mac header will be set to the
- * nextheader field of the extension header directly preceding the
- * encapsulation header, or in its absence, that of the top IP header.
- * The value of the network header will always point to the top IP header
- * while skb->data will point to the payload.
  */
 static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -37,7 +30,7 @@ static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
 	skb_set_network_header(skb, -x->props.header_len);
-	skb_set_transport_header(skb, hdr_len - x->props.header_len);
+	skb->transport_header = skb->network_header + hdr_len;
 	__skb_pull(skb, hdr_len);
 	memmove(ipv6_hdr(skb), iph, hdr_len);
 	return 0;
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 01bd7d1..e79c6bd 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -36,13 +36,6 @@ static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
  * The top IP header will be constructed per RFC 2401.  The following fields
  * in it shall be filled in by x->type->output:
  *	payload_len
- *
- * On exit, skb->h will be set to the start of the encapsulation header to be
- * filled in by x->type->output and the mac header will be set to the
- * nextheader field of the extension header directly preceding the
- * encapsulation header, or in its absence, that of the top IP header.
- * The value of the network header will always point to the top IP header
- * while skb->data will point to the payload.
  */
 static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -53,11 +46,10 @@ static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	iph = ipv6_hdr(skb);
 
-	skb_set_mac_header(skb, offsetof(struct ipv6hdr, nexthdr) -
-				x->props.header_len);
 	skb_set_network_header(skb, -x->props.header_len);
-	skb_set_transport_header(skb, sizeof(struct ipv6hdr) -
-				      x->props.header_len);
+	skb->mac_header = skb->network_header +
+			  offsetof(struct ipv6hdr, nexthdr);
+	skb->transport_header = skb->network_header + sizeof(*iph);
 	top_iph = ipv6_hdr(skb);
 
 	top_iph->version = 6;
