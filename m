From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [RFC PATCH resend]: Fix output for BEET ipsec
Date: Tue, 22 Apr 2008 15:12:40 +0300
Message-ID: <200804221512.40780.joakim.koskela@hiit.fi>
References: <200803261115.26157.joakim.koskela@hiit.fi> <20080326133152.GA3022@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:41119 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424AbYDVMKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2008 08:10:03 -0400
In-Reply-To: <20080326133152.GA3022@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 26 March 2008 15:31, Herbert Xu wrote:
> In light of the patch I just posted I believe we can drop everything
> but the props_header_len adjustments.  Please let me know if it still
> doesn't work with my earlier patch.
>
> Cheers,

Thanks, but I'm still having problems with 6-6 and the interfamilies.

Here's what I'm using right now to get net-2.6 beet working (testing with older
versions and another implementation). It's basically the same as I sent before, 
slightly updated (to use the protocol-independent accessors).

br, j

Signed-off-by: Joakim Koskela <jookos@gmail.com>
--
 net/ipv4/esp4.c            |    2 +-
 net/ipv4/xfrm4_mode_beet.c |  101 ++++++++++++++++++++++++++++---------------
 net/ipv6/esp6.c            |    5 ++
 net/ipv6/xfrm6_mode_beet.c |   65 ++++++++++++++++++++++++----
 4 files changed, 128 insertions(+), 45 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 4e73e57..135094e 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -575,7 +575,7 @@ static int esp_init_state(struct xfrm_state *x)
 			      crypto_aead_ivsize(aead);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
-	else if (x->props.mode == XFRM_MODE_BEET)
+	else if (x->props.mode == XFRM_MODE_BEET && x->sel.family == AF_INET)
 		x->props.header_len += IPV4_BEET_PHMAXLEN;
 	if (x->encap) {
 		struct xfrm_encap_tmpl *encap = x->encap;
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 9c798ab..7f218cc 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -6,6 +6,7 @@
  *                    Herbert Xu     <herbert@gondor.apana.org.au>
  *                    Abhinav Pathak <abhinav.pathak@hiit.fi>
  *                    Jeff Ahrenholz <ahrenholz@gmail.com>
+ *                    Joakim Koskela <jookos@gmail.com>
  */
 
 #include <linux/init.h>
@@ -38,44 +39,74 @@ static void xfrm4_beet_make_header(struct sk_buff *skb)
  */
 static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct ip_beet_phdr *ph;
-	struct iphdr *top_iph;
-	int hdrlen, optlen;
+	struct iphdr *iph, *top_iph;
 
-	hdrlen = 0;
-	optlen = XFRM_MODE_SKB_CB(skb)->optlen;
-	if (unlikely(optlen))
-		hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
-
-	skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
-				    hdrlen);
-	skb->mac_header = skb->network_header +
-			  offsetof(struct iphdr, protocol);
-	skb->transport_header = skb->network_header + sizeof(*top_iph);
-
-	xfrm4_beet_make_header(skb);
-
-	ph = (struct ip_beet_phdr *)
-		__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl - hdrlen);
-
-	top_iph = ip_hdr(skb);
-
-	if (unlikely(optlen)) {
-		BUG_ON(optlen < 0);
-
-		ph->padlen = 4 - (optlen & 4);
-		ph->hdrlen = optlen / 8;
-		ph->nexthdr = top_iph->protocol;
-		if (ph->padlen)
-			memset(ph + 1, IPOPT_NOP, ph->padlen);
-
-		top_iph->protocol = IPPROTO_BEETPH;
-		top_iph->ihl = sizeof(struct iphdr) / 4;
+	iph = ip_hdr(skb);
+	if (iph->version == 4) {
+		struct ip_beet_phdr *ph;
+		int hdrlen, optlen;
+
+		hdrlen = 0;
+		optlen = XFRM_MODE_SKB_CB(skb)->optlen;
+		if (unlikely(optlen))
+			hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+		skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
+				       hdrlen);
+		skb->mac_header = skb->network_header +
+			offsetof(struct iphdr, protocol);
+		skb->transport_header = skb->network_header + sizeof(*top_iph);
+
+		xfrm4_beet_make_header(skb);
+
+		ph = (struct ip_beet_phdr *)
+			__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl - hdrlen);
+
+		top_iph = ip_hdr(skb);
+
+		if (unlikely(optlen)) {
+			BUG_ON(optlen < 0);
+
+			ph->padlen = 4 - (optlen & 4);
+			ph->hdrlen = optlen / 8;
+			ph->nexthdr = top_iph->protocol;
+			if (ph->padlen)
+				memset(ph + 1, IPOPT_NOP, ph->padlen);
+
+			top_iph->protocol = IPPROTO_BEETPH;
+			top_iph->ihl = sizeof(struct iphdr) / 4;
+		}
+
+		top_iph->saddr = x->props.saddr.a4;
+		top_iph->daddr = x->id.daddr.a4;
+
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	} else if (iph->version == 6) {
+		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+		u8 protocol = ipv6_hdr(skb)->nexthdr;
+
+		/* Inner = 6, Outer = 4 : changing the external IP hdr
+		 * to the outer addresses
+		 */
+		skb_set_network_header(skb, delta - x->props.header_len);
+		skb->transport_header = skb->network_header + sizeof(*iph);
+		skb->mac_header = skb->network_header +
+			offsetof(struct iphdr, protocol);
+		skb_pull(skb, sizeof(struct ipv6hdr));
+
+		xfrm4_beet_make_header(skb);
+
+		top_iph = ip_hdr(skb);
+		top_iph->protocol = protocol;
+		top_iph->saddr = x->props.saddr.a4;
+		top_iph->daddr = x->id.daddr.a4;
+		IPCB(skb)->flags = 0;
+
+		skb->protocol = htons(ETH_P_IP);
+		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+#endif
 	}
 
-	top_iph->saddr = x->props.saddr.a4;
-	top_iph->daddr = x->id.daddr.a4;
-
 	return 0;
 }
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index c6bb4c6..8356c11 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -521,6 +521,11 @@ static int esp6_init_state(struct xfrm_state *x)
 			      crypto_aead_ivsize(aead);
 	switch (x->props.mode) {
 	case XFRM_MODE_BEET:
+		if (x->sel.family == AF_INET) {
+			x->props.header_len += IPV4_BEET_PHMAXLEN +
+				(sizeof(struct ipv6hdr) - sizeof(struct iphdr));
+		}
+		break;
 	case XFRM_MODE_TRANSPORT:
 		break;
 	case XFRM_MODE_TUNNEL:
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index d6ce400..a11af00 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -40,19 +40,66 @@ static void xfrm6_beet_make_header(struct sk_buff *skb)
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *top_iph;
+	int hdr_len;
 
-	skb_set_network_header(skb, -x->props.header_len);
-	skb->mac_header = skb->network_header +
-			  offsetof(struct ipv6hdr, nexthdr);
-	skb->transport_header = skb->network_header + sizeof(*top_iph);
-	__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl);
+	if (ip_hdr(skb)->version == 6) {
+		u8 *prevhdr;
 
-	xfrm6_beet_make_header(skb);
+		hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
+		skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
+		skb_set_network_header(skb, -x->props.header_len);
+		skb->transport_header = skb->network_header + hdr_len;
+		__skb_pull(skb, hdr_len);
+
+		xfrm6_beet_make_header(skb);
+
+		top_iph = ipv6_hdr(skb);
+
+		ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
+		ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+	} else {
+		struct iphdr *iphv4;
+		int optlen;
+		struct ip_beet_phdr *ph;
+		u8 protocol;
+
+		iphv4 = ip_hdr(skb);
+		hdr_len = 0;
+		optlen = XFRM_MODE_SKB_CB(skb)->optlen;
+		if (unlikely(optlen))
+			hdr_len += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+		skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
+				       hdr_len);
+		skb->mac_header = skb->network_header +
+			offsetof(struct ipv6hdr, nexthdr);
+		skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
+
+		ph = (struct ip_beet_phdr *)
+			__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl - hdr_len);
+		if (unlikely(optlen)) {
+
+			BUG_ON(optlen < 0);
+
+			ph->padlen = 4 - (optlen & 4);
+			ph->hdrlen = optlen / 8;
+			ph->nexthdr = iphv4->protocol;
+			if (ph->padlen)
+				memset(ph + 1, IPOPT_NOP, ph->padlen);
+
+			protocol = IPPROTO_BEETPH;
+		} else
+			protocol = iphv4->protocol;
+
+		xfrm6_beet_make_header(skb);
+
+		top_iph = ipv6_hdr(skb);
 
-	top_iph = ipv6_hdr(skb);
+		top_iph->nexthdr = protocol;
+		ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
+		ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+	}
 
-	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
-	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
 	return 0;
 }
