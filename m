From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/7] [IPSEC]: Set skb->data to payload in x->mode->output
Date: Wed, 10 Oct 2007 22:40:12 +0800
Message-ID: <E1IfcjM-00024E-00@gondolin.me.apana.org.au>
References: <20071010143915.GA7650@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3582 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754264AbXJJOkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:40:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Set skb->data to payload in x->mode->output

This patch changes the calling convention so that on entry from
x->mode->output and before entry into x->type->output skb->data
will point to the payload instead of the IP header.

This is essentially a redistribution of skb_push/skb_pull calls
with the aim of minimising them on the common path of tunnel +
ESP.

It'll also let us use the same calling convention between IPv4
and IPv6 with the next patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ah4.c                  |    1 +
 net/ipv4/esp4.c                 |    6 ++----
 net/ipv4/ipcomp.c               |    1 +
 net/ipv4/xfrm4_mode_beet.c      |    5 +++--
 net/ipv4/xfrm4_mode_transport.c |    4 ++--
 net/ipv4/xfrm4_mode_tunnel.c    |    3 +--
 net/ipv4/xfrm4_tunnel.c         |    1 +
 net/ipv6/ah6.c                  |    1 +
 net/ipv6/esp6.c                 |    9 ++-------
 net/ipv6/ipcomp6.c              |    5 ++++-
 net/ipv6/mip6.c                 |    2 ++
 net/ipv6/xfrm6_mode_beet.c      |   13 +++++++------
 net/ipv6/xfrm6_mode_ro.c        |   12 ++++++------
 net/ipv6/xfrm6_mode_transport.c |   12 ++++++------
 net/ipv6/xfrm6_mode_tunnel.c    |   13 +++++++------
 net/ipv6/xfrm6_tunnel.c         |    1 +
 16 files changed, 47 insertions(+), 42 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 3513149..dbb1f11 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -66,6 +66,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 		char 		buf[60];
 	} tmp_iph;
 
+	skb_push(skb, -skb_network_offset(skb));
 	top_iph = ip_hdr(skb);
 	iph = &tmp_iph.iph;
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 1af332d..0f5e838 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -28,9 +28,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	int alen;
 	int nfrags;
 
-	/* Strip IP+ESP header. */
-	__skb_pull(skb, skb_transport_offset(skb));
-	/* Now skb is pure payload to encrypt */
+	/* skb is pure payload to encrypt */
 
 	err = -ENOMEM;
 
@@ -60,7 +58,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	tail[clen - skb->len - 2] = (clen - skb->len) - 2;
 	pskb_put(skb, trailer, clen - skb->len);
 
-	__skb_push(skb, -skb_network_offset(skb));
+	skb_push(skb, -skb_network_offset(skb));
 	top_iph = ip_hdr(skb);
 	esph = (struct ip_esp_hdr *)(skb_network_header(skb) +
 				     top_iph->ihl * 4);
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index e787044..1929d45 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -134,6 +134,7 @@ static int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb)
 	int hdr_len = 0;
 	struct iphdr *iph = ip_hdr(skb);
 
+	skb_push(skb, -skb_network_offset(skb));
 	iph->tot_len = htons(skb->len);
 	hdr_len = iph->ihl * 4;
 	if ((skb->len - hdr_len) < ipcd->threshold) {
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index a73e710..77888f5 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -40,10 +40,11 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (unlikely(optlen))
 		hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
 
-	skb_push(skb, x->props.header_len - IPV4_BEET_PHMAXLEN + hdrlen);
-	skb_reset_network_header(skb);
+	skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
+				    hdrlen);
 	top_iph = ip_hdr(skb);
 	skb->transport_header += sizeof(*iph) - hdrlen;
+	__skb_pull(skb, sizeof(*iph) - hdrlen);
 
 	memmove(top_iph, iph, sizeof(*iph));
 	if (unlikely(optlen)) {
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index 6010471..10499d2 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -27,8 +27,8 @@ static int xfrm4_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 	int ihl = iph->ihl * 4;
 
 	skb->transport_header = skb->network_header + ihl;
-	skb_push(skb, x->props.header_len);
-	skb_reset_network_header(skb);
+	skb_set_network_header(skb, -x->props.header_len);
+	__skb_pull(skb, ihl);
 	memmove(skb_network_header(skb), iph, ihl);
 	return 0;
 }
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 9963700..bac1a91 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -49,8 +49,7 @@ static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	iph = ip_hdr(skb);
 	skb->transport_header = skb->network_header;
 
-	skb_push(skb, x->props.header_len);
-	skb_reset_network_header(skb);
+	skb_set_network_header(skb, -x->props.header_len);
 	top_iph = ip_hdr(skb);
 
 	top_iph->ihl = 5;
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 9275c79..be572f9 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -14,6 +14,7 @@ static int ipip_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 
+	skb_push(skb, -skb_network_offset(skb));
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index c51d775..ac6bae1 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -236,6 +236,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 		char hdrs[0];
 	} *tmp_ext;
 
+	skb_push(skb, -skb_network_offset(skb));
 	top_iph = ipv6_hdr(skb);
 	top_iph->payload_len = htons(skb->len - sizeof(*top_iph));
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 7355bb0..21c93f0 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -54,13 +54,8 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	int nfrags;
 	u8 *tail;
 	struct esp_data *esp = x->data;
-	int hdr_len = (skb_transport_offset(skb) +
-		       sizeof(*esph) + esp->conf.ivlen);
 
-	/* Strip IP+ESP header. */
-	__skb_pull(skb, hdr_len);
-
-	/* Now skb is pure payload to encrypt */
+	/* skb is pure payload to encrypt */
 	err = -ENOMEM;
 
 	/* Round to block size */
@@ -89,7 +84,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	tail[clen-skb->len - 2] = (clen - skb->len) - 2;
 	pskb_put(skb, trailer, clen - skb->len);
 
-	__skb_push(skb, -skb_network_offset(skb));
+	skb_push(skb, -skb_network_offset(skb));
 	top_iph = ipv6_hdr(skb);
 	esph = (struct ipv6_esp_hdr *)skb_transport_header(skb);
 	top_iph->payload_len = htons(skb->len + alen - sizeof(*top_iph));
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 71a14c0..87e6407 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -128,7 +128,10 @@ static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *start, *scratch;
 	struct crypto_comp *tfm;
 	int cpu;
-	int hdr_len = skb_transport_offset(skb);
+	int hdr_len;
+
+	skb_push(skb, -skb_network_offset(skb));
+	hdr_len = skb_transport_offset(skb);
 
 	/* check whether datagram len is larger than threshold */
 	if ((skb->len - hdr_len) < ipcd->threshold) {
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 6475bac..0e7a60f 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -153,6 +153,7 @@ static int mip6_destopt_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 nexthdr;
 	int len;
 
+	skb_push(skb, -skb_network_offset(skb));
 	iph = ipv6_hdr(skb);
 	iph->payload_len = htons(skb->len - sizeof(*iph));
 
@@ -367,6 +368,7 @@ static int mip6_rthdr_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct rt2_hdr *rt2;
 	u8 nexthdr;
 
+	skb_push(skb, -skb_network_offset(skb));
 	iph = ipv6_hdr(skb);
 	iph->payload_len = htons(skb->len - sizeof(*iph));
 
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index d9366df..bca018d 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -29,8 +29,8 @@
  * filled in by x->type->output and the mac header will be set to the
  * nextheader field of the extension header directly preceding the
  * encapsulation header, or in its absence, that of the top IP header.
- * The value of skb->data and the network header will always point to the
- * top IP header.
+ * The value of the network header will always point to the top IP header
+ * while skb->data will point to the payload.
  */
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -38,16 +38,17 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *prevhdr;
 	int hdr_len;
 
-	skb_push(skb, x->props.header_len);
 	iph = ipv6_hdr(skb);
 
 	hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
-	memmove(skb->data, iph, hdr_len);
 
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
-	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, hdr_len);
+	skb_set_network_header(skb, -x->props.header_len);
+	skb_set_transport_header(skb, hdr_len - x->props.header_len);
+	__skb_pull(skb, hdr_len);
+
 	top_iph = ipv6_hdr(skb);
+	memmove(top_iph, iph, hdr_len);
 
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index 2575804..5c29b36 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -42,8 +42,8 @@
  * filled in by x->type->output and the mac header will be set to the
  * nextheader field of the extension header directly preceding the
  * encapsulation header, or in its absence, that of the top IP header.
- * The value of skb->data and the network header will always point to the
- * top IP header.
+ * The value of the network header will always point to the top IP header
+ * while skb->data will point to the payload.
  */
 static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -51,14 +51,14 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *prevhdr;
 	int hdr_len;
 
-	skb_push(skb, x->props.header_len);
 	iph = ipv6_hdr(skb);
 
 	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
-	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, hdr_len);
-	memmove(skb->data, iph, hdr_len);
+	skb_set_network_header(skb, -x->props.header_len);
+	skb_set_transport_header(skb, hdr_len - x->props.header_len);
+	__skb_pull(skb, hdr_len);
+	memmove(ipv6_hdr(skb), iph, hdr_len);
 
 	x->lastused = get_seconds();
 
diff --git a/net/ipv6/xfrm6_mode_transport.c b/net/ipv6/xfrm6_mode_transport.c
index 65c166b..f2ee186 100644
--- a/net/ipv6/xfrm6_mode_transport.c
+++ b/net/ipv6/xfrm6_mode_transport.c
@@ -23,8 +23,8 @@
  * filled in by x->type->output and the mac header will be set to the
  * nextheader field of the extension header directly preceding the
  * encapsulation header, or in its absence, that of the top IP header.
- * The value of skb->data and the network header will always point to the
- * top IP header.
+ * The value of the network header will always point to the top IP header
+ * while skb->data will point to the payload.
  */
 static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -32,14 +32,14 @@ static int xfrm6_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *prevhdr;
 	int hdr_len;
 
-	skb_push(skb, x->props.header_len);
 	iph = ipv6_hdr(skb);
 
 	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
 	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
-	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, hdr_len);
-	memmove(skb->data, iph, hdr_len);
+	skb_set_network_header(skb, -x->props.header_len);
+	skb_set_transport_header(skb, hdr_len - x->props.header_len);
+	__skb_pull(skb, hdr_len);
+	memmove(ipv6_hdr(skb), iph, hdr_len);
 	return 0;
 }
 
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index 3dd40af..01bd7d1 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -41,8 +41,8 @@ static inline void ip6ip_ecn_decapsulate(struct sk_buff *skb)
  * filled in by x->type->output and the mac header will be set to the
  * nextheader field of the extension header directly preceding the
  * encapsulation header, or in its absence, that of the top IP header.
- * The value of skb->data and the network header will always point to the
- * top IP header.
+ * The value of the network header will always point to the top IP header
+ * while skb->data will point to the payload.
  */
 static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -51,12 +51,13 @@ static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct ipv6hdr *iph, *top_iph;
 	int dsfield;
 
-	skb_push(skb, x->props.header_len);
 	iph = ipv6_hdr(skb);
 
-	skb_set_mac_header(skb, offsetof(struct ipv6hdr, nexthdr));
-	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
+	skb_set_mac_header(skb, offsetof(struct ipv6hdr, nexthdr) -
+				x->props.header_len);
+	skb_set_network_header(skb, -x->props.header_len);
+	skb_set_transport_header(skb, sizeof(struct ipv6hdr) -
+				      x->props.header_len);
 	top_iph = ipv6_hdr(skb);
 
 	top_iph->version = 6;
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index aeb0607..00a1a3e 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -244,6 +244,7 @@ static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *top_iph;
 
+	skb_push(skb, -skb_network_offset(skb));
 	top_iph = ipv6_hdr(skb);
 	top_iph->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 
