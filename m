From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [RFC PATCH resend]: Fix output for BEET ipsec
Date: Wed, 26 Mar 2008 11:15:26 +0200
Message-ID: <200803261115.26157.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Komu Miika <Miika.Komu@hiit.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:51228 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbYCZJLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 05:11:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Any comments on this? Would be great to get beet working soon!

br, j

== original post:

This patch fixes the ipsec BEET (Bound End-to-End Tunnel) mode
interfamily handling of the net-2.6 (25-rc3) kernel, as specified by
the ietf draft found at:

http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-08.txt

It is sent as a RFC as it doesn't fit that neatly into the newly
cleaned-up xfrm model - I suspect that there could be a better way to
solve this.

Signed-off-by: Joakim Koskela <jookos@gmail.com>
---
 net/ipv4/esp4.c            |   10 +++-
 net/ipv4/xfrm4_mode_beet.c |  104 +++++++++++++++++++++++++++++---------------
 net/ipv6/esp6.c            |    6 +++
 net/ipv6/xfrm6_mode_beet.c |   83 ++++++++++++++++++++++++++++++-----
 4 files changed, 153 insertions(+), 50 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 091e670..20d214f 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -404,7 +404,8 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 		break;
 	case XFRM_MODE_BEET:
 		/* The worst case. */
-		mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem);
+		/* This will be seen to in the esp header_len */
+		/* mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem); */
 		break;
 	}
 
@@ -575,8 +576,11 @@ static int esp_init_state(struct xfrm_state *x)
 			      crypto_aead_ivsize(aead);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
-	else if (x->props.mode == XFRM_MODE_BEET)
-		x->props.header_len += IPV4_BEET_PHMAXLEN;
+	else if (x->props.mode == XFRM_MODE_BEET) {
+		if (x->sel.family == AF_INET) {
+			x->props.header_len += IPV4_BEET_PHMAXLEN;
+		}
+	}
 	if (x->encap) {
 		struct xfrm_encap_tmpl *encap = x->encap;
 
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index b47030b..83db9b2 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -6,6 +6,7 @@
  *                    Herbert Xu     <herbert@gondor.apana.org.au>
  *                    Abhinav Pathak <abhinav.pathak@hiit.fi>
  *                    Jeff Ahrenholz <ahrenholz@gmail.com>
+ *                    Joakim Koskela <jookos@gmail.com>
  */
 
 #include <linux/init.h>
@@ -38,45 +39,78 @@ static void xfrm4_beet_make_header(struct sk_buff *skb)
  */
 static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct ip_beet_phdr *ph;
 	struct iphdr *iph, *top_iph;
-	int hdrlen, optlen;
 
 	iph = ip_hdr(skb);
-
-	hdrlen = 0;
-	optlen = iph->ihl * 4 - sizeof(*iph);
-	if (unlikely(optlen))
-		hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
-
-	skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
-				    hdrlen);
-	skb->mac_header = skb->network_header +
-			  offsetof(struct iphdr, protocol);
-	skb->transport_header = skb->network_header + sizeof(*iph);
-
-	xfrm4_beet_make_header(skb);
-
-	ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iph) - hdrlen);
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
+	if (iph->version == 4) {
+		struct ip_beet_phdr *ph;
+		int hdrlen, optlen;
+
+		hdrlen = 0;
+		optlen = iph->ihl * 4 - sizeof(*iph);
+		if (unlikely(optlen))
+			hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+		skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
+				       hdrlen);
+		skb->mac_header = skb->network_header +
+			offsetof(struct iphdr, protocol);
+		skb->transport_header = skb->network_header + sizeof(*iph);
+
+		xfrm4_beet_make_header(skb);
+
+		ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iph) - hdrlen);
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
+		struct dst_entry *dst = skb->dst;
+
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
+		top_iph = ip_hdr(skb);
+		top_iph->ihl = 5;
+		top_iph->version = 4;
+		top_iph->id = 0;
+		top_iph->frag_off = htons(IP_DF);
+		top_iph->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
+		top_iph->protocol = protocol;
+
+		top_iph->saddr = x->props.saddr.a4;
+		top_iph->daddr = x->id.daddr.a4;
+		IPCB(skb)->flags = 0;
+
+		skb->protocol = htons(ETH_P_IP);
+		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+#endif
 	}
-
-	top_iph->saddr = x->props.saddr.a4;
-	top_iph->daddr = x->id.daddr.a4;
-
 	return 0;
 }
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 0ec1402..984a03e 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -344,6 +344,7 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 	rem = mtu & (align - 1);
 	mtu &= ~(align - 1);
 
+	/* hm, is this right? maybe we shouldn't do this for beet either? */
 	if (x->props.mode != XFRM_MODE_TUNNEL) {
 		u32 padsize = ((blksize - 1) & 7) + 1;
 		mtu -= blksize - padsize;
@@ -521,6 +522,11 @@ static int esp6_init_state(struct xfrm_state *x)
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
index 0527d11..2547c51 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -6,6 +6,7 @@
  *                    Herbert Xu     <herbert@gondor.apana.org.au>
  *                    Abhinav Pathak <abhinav.pathak@hiit.fi>
  *                    Jeff Ahrenholz <ahrenholz@gmail.com>
+ *                    Joakim Koskela <jookos@gmail.com>
  */
 
 #include <linux/init.h>
@@ -40,18 +41,76 @@ static void xfrm6_beet_make_header(struct sk_buff *skb)
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *top_iph;
-
-	skb_set_network_header(skb, -x->props.header_len);
-	skb->mac_header = skb->network_header +
-			  offsetof(struct ipv6hdr, nexthdr);
-	skb->transport_header = skb->network_header + sizeof(*top_iph);
-
-	xfrm6_beet_make_header(skb);
-
-	top_iph = ipv6_hdr(skb);
-
-	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
-	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+	int hdr_len;
+
+	if (ip_hdr(skb)->version == 6) {
+		u8 *prevhdr;
+
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
+		struct dst_entry *dst = skb->dst;
+		struct iphdr *iphv4;
+		int flags, optlen, dsfield;
+		struct ip_beet_phdr *ph;
+		u8 protocol;
+
+		iphv4 = ip_hdr(skb);
+		hdr_len = 0;
+		optlen = iphv4->ihl * 4 - sizeof(*iphv4);
+		if (unlikely(optlen))
+			hdr_len += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+		skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
+				       hdr_len);
+		skb->mac_header = skb->network_header + offsetof(struct ipv6hdr, nexthdr);
+		skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
+
+		ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iphv4) - hdr_len);
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
+		top_iph = ipv6_hdr(skb);
+
+		/* DS disclosed */
+		top_iph->version = 6;
+		top_iph->priority = 0;
+		top_iph->flow_lbl[0] = 0;
+		top_iph->flow_lbl[1] = 0;
+		top_iph->flow_lbl[2] = 0;
+		dsfield = ipv6_get_dsfield(top_iph);
+		dsfield = INET_ECN_encapsulate(dsfield, dsfield);
+		flags = x->props.flags;
+		if (flags & XFRM_STATE_NOECN)
+			dsfield &= ~INET_ECN_MASK;
+		ipv6_change_dsfield(top_iph, 0, dsfield);
+
+		top_iph->nexthdr = protocol;
+		top_iph->hop_limit = dst_metric(dst->child, RTAX_HOPLIMIT);
+		ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
+		ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+	}
 	return 0;
 }

