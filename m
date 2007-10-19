From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH] netdev: Interfamily support for IPSEC BEET
Date: Fri, 19 Oct 2007 13:07:55 +0300
Message-ID: <200710191307.55589.joakim.koskela@hiit.fi>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:36658 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751758AbXJSKMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 06:12:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here's an updated version of the patch adding support for ipv4/ipv6
interfamily addressing for the ipsec BEET (Bound End-to-End Tunnel)
mode, as specified by the ietf draft found at:

http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-07.txt

The previous implementation required that both address pairs in the SA
were of the same family. This patch enables mixing ipv4 and ipv6
addresses. All combinations (4-4, 4-6, 6-4, 6-6) have been tested.

The generic interfamily fixes have been chopped off from this into
separate patches.

Signed-off-by: Joakim Koskela <jookos@gmail.com>
Signed-off-by: Herbert Xu     <herbert@gondor.apana.org.au>
Signed-off-by: Diego Beltrami <diego.beltrami@gmail.com>
Signed-off-by: Miika Komu     <miika@iki.fi>
---

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 6b1a31a..b41e68d 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -288,8 +288,6 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 		mtu += min_t(u32, blksize - 4, rem);
 		break;
 	case XFRM_MODE_BEET:
-		/* The worst case. */
-		mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem);
 		break;
 	}
 
@@ -397,8 +395,11 @@ static int esp_init_state(struct xfrm_state *x)
 	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
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
 
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 2f14745..be58f8e 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -656,3 +656,6 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 	}
 	return 0;
 }
+
+EXPORT_SYMBOL(ip_options_compile);
+
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 5e95c8a..b2e9308 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -94,7 +94,9 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		if (x->outer_mode->input(x, skb))
 			goto drop;
 
-		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
+		if ((x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
+		    (x->props.mode != XFRM_MODE_BEET ||
+		     x->sel.family != AF_INET)) {
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index e42e122..1346efc 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -6,6 +6,7 @@
  *                    Herbert Xu     <herbert@gondor.apana.org.au>
  *                    Abhinav Pathak <abhinav.pathak@hiit.fi>
  *                    Jeff Ahrenholz <ahrenholz@gmail.com>
+ *                    Joakim Koskela <jookos@gmail.com>
  */
 
 #include <linux/init.h>
@@ -16,6 +17,7 @@
 #include <net/dst.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
+#include <net/inet_ecn.h>
 
 /* Add encapsulation header.
  *
@@ -23,88 +25,172 @@
  */
 static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct ip_beet_phdr *ph;
-	struct iphdr *iph, *top_iph;
-	int hdrlen, optlen;
-
-	iph = ip_hdr(skb);
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
-	ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iph) - hdrlen);
-
-	top_iph = ip_hdr(skb);
-	memmove(top_iph, iph, sizeof(*iph));
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
-	}
+	struct dst_entry *dst = skb->dst;
+	struct iphdr *iphv4, *top_iphv4;
+	int hdrlen;
+
+	if (ip_hdr(skb)->version == 4) {
+		int optlen;
+		struct ip_beet_phdr *ph;
 
-	top_iph->saddr = x->props.saddr.a4;
-	top_iph->daddr = x->id.daddr.a4;
+		/* 4-4 */
+		iphv4 = ip_hdr(skb);
+
+		hdrlen = 0;
+		optlen = iphv4->ihl * 4 - sizeof(*iphv4);
+		if (unlikely(optlen))
+			hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+		skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
+				       hdrlen);
+		skb->mac_header = skb->network_header +
+			offsetof(struct iphdr, protocol);
+		skb->transport_header = skb->network_header + sizeof(*iphv4);
+
+		ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iphv4) - hdrlen);
+
+		top_iphv4 = ip_hdr(skb);
+		memmove(top_iphv4, iphv4, sizeof(*iphv4));
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
+			top_iphv4->protocol = IPPROTO_BEETPH;
+			top_iphv4->ihl = 5;
+		}
+
+		top_iphv4->saddr = x->props.saddr.a4;
+		top_iphv4->daddr = x->id.daddr.a4;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	} else if (ip_hdr(skb)->version == 6) {
+		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+		u8 protocol = ipv6_hdr(skb)->nexthdr;
+
+		/* Inner = 6, Outer = 4 : changing the external IP hdr
+		 * to the outer addresses
+		 */
+		skb_set_network_header(skb, delta - x->props.header_len);
+		skb->transport_header = skb->network_header + sizeof(*iphv4);
+		skb->mac_header = skb->network_header +
+			offsetof(struct iphdr, protocol);
+		skb_pull(skb, sizeof(struct ipv6hdr));
+
+		top_iphv4 = ip_hdr(skb);
+		top_iphv4->ihl = 5;
+		top_iphv4->version = 4;
+		top_iphv4->id = 0;
+		top_iphv4->frag_off = htons(IP_DF);
+		top_iphv4->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
+		top_iphv4->protocol = protocol;
+
+		top_iphv4->saddr = x->props.saddr.a4;
+		top_iphv4->daddr = x->id.daddr.a4;
+		IPCB(skb)->flags = 0;
+#endif
+	}
 
+	skb->protocol = htons(ETH_P_IP);
+	memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 	return 0;
+
 }
 
 static int xfrm4_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
+	int hops = iph->ttl;
 	int phlen = 0;
 	int optlen = 0;
-	u8 ph_nexthdr = 0;
+	__u8 protocol = 0;
 	int err = -EINVAL;
 
-	if (unlikely(iph->protocol == IPPROTO_BEETPH)) {
-		struct ip_beet_phdr *ph;
+	protocol = iph->protocol;
+	if (x->sel.family == AF_INET) {
+		if (unlikely(protocol == IPPROTO_BEETPH)) {
+			struct ip_beet_phdr *ph;
 
-		if (!pskb_may_pull(skb, sizeof(*ph)))
-			goto out;
-		ph = (struct ip_beet_phdr *)(ipip_hdr(skb) + 1);
+			if (!pskb_may_pull(skb, sizeof(*ph)))
+				goto out;
 
-		phlen = sizeof(*ph) + ph->padlen;
-		optlen = ph->hdrlen * 8 + (IPV4_BEET_PHMAXLEN - phlen);
-		if (optlen < 0 || optlen & 3 || optlen > 250)
-			goto out;
+			ph = (struct ip_beet_phdr *)(ipip_hdr(skb) + 1);
+
+			phlen = sizeof(*ph) + ph->padlen;
+			optlen = ph->hdrlen * 8 + (IPV4_BEET_PHMAXLEN - phlen);
+			if (optlen < 0 || optlen & 3 || optlen > 250)
+				goto out;
+
+			if (!pskb_may_pull(skb, phlen + optlen))
+				goto out;
+
+			protocol = ph->nexthdr;
+		}
 
-		if (!pskb_may_pull(skb, phlen + optlen))
+		skb_push(skb, sizeof(*iph) - phlen);
+		skb_reset_network_header(skb);
+		memmove(skb_network_header(skb), iph, sizeof(*iph));
+
+		iph = ip_hdr(skb);
+		iph->ihl = (sizeof(*iph) + optlen) / 4;
+		iph->tot_len = htons(skb->len);
+		iph->daddr = x->sel.daddr.a4;
+		iph->saddr = x->sel.saddr.a4;
+		iph->protocol = protocol;
+
+		ip_send_check(iph);
+		if (ip_options_compile(NULL, skb))
 			goto out;
-		skb->len -= phlen + optlen;
 
-		ph_nexthdr = ph->nexthdr;
+		dst_release(skb->dst);
+		skb->dst = NULL;
+
+		pskb_pull(skb, sizeof(*iph) + optlen);
+		skb_reset_transport_header(skb);
+		err = 0;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	} else if (x->sel.family == AF_INET6) {
+		int delta = sizeof(struct ipv6hdr) + skb->mac_len;
+		struct ipv6hdr *ip6h;
+		const unsigned char *old_mac;
+
+		/* Here, the inner family is 6, therefore I have to
+		 * substitute the IPhdr by enlarging it.
+		 */
+		if (skb_headroom(skb) < delta) {
+			if (pskb_expand_head(skb, delta, 0, GFP_ATOMIC))
+				goto out;
+		}
+
+		skb_push(skb, sizeof(*ip6h));
+
+		/* mac might have references to ipv4. shouldn't matter */
+		old_mac = skb_mac_header(skb);
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+
+		skb_reset_network_header(skb);
+		skb_reset_transport_header(skb);
+
+		ip6h = ipv6_hdr(skb);
+		memset(ip6h->flow_lbl, 0, sizeof(ip6h->flow_lbl));
+		ip6h->version = 6;
+		ip6h->priority = 0;
+		ip6h->nexthdr = protocol;
+		ip6h->hop_limit = hops;
+		ip6h->payload_len = htons(skb->len - sizeof(*ip6h));
+		ipv6_addr_copy(&ip6h->daddr,
+			       (struct in6_addr *)&x->sel.daddr.a6);
+		ipv6_addr_copy(&ip6h->saddr,
+			       (struct in6_addr *)&x->sel.saddr.a6);
+		skb->protocol = htons(ETH_P_IPV6);
+		err = 0;
+#endif
 	}
-
-	skb_set_network_header(skb, phlen - sizeof(*iph));
-	memmove(skb_network_header(skb), iph, sizeof(*iph));
-	skb_set_transport_header(skb, phlen + optlen);
-	skb->data = skb_transport_header(skb);
-
-	iph = ip_hdr(skb);
-	iph->ihl = (sizeof(*iph) + optlen) / 4;
-	iph->tot_len = htons(skb->len + iph->ihl * 4);
-	iph->daddr = x->sel.daddr.a4;
-	iph->saddr = x->sel.saddr.a4;
-	if (ph_nexthdr)
-		iph->protocol = ph_nexthdr;
-	iph->check = 0;
-	iph->check = ip_fast_csum(skb_network_header(skb), iph->ihl);
-	err = 0;
 out:
 	return err;
 }
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index b071543..f6d5d3c 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -244,7 +244,8 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 	rem = mtu & (align - 1);
 	mtu &= ~(align - 1);
 
-	if (x->props.mode != XFRM_MODE_TUNNEL) {
+	if (x->props.mode != XFRM_MODE_TUNNEL ||
+	    x->props.mode != XFRM_MODE_BEET) {
 		u32 padsize = ((blksize - 1) & 7) + 1;
 		mtu -= blksize - padsize;
 		mtu += min_t(u32, blksize - padsize, rem);
@@ -356,6 +357,11 @@ static int esp6_init_state(struct xfrm_state *x)
 	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
 	switch (x->props.mode) {
 	case XFRM_MODE_BEET:
+ 		if (x->sel.family == AF_INET) {
+ 			x->props.header_len += IPV4_BEET_PHMAXLEN +
+ 				(sizeof(struct ipv6hdr) - sizeof(struct iphdr));
+ 		}
+		break;
 	case XFRM_MODE_TRANSPORT:
 		break;
 	case XFRM_MODE_TUNNEL:
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 5157837..55f2130 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -71,7 +71,9 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 		if (x->outer_mode->input(x, skb))
 			goto drop;
 
-		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
+		if ((x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
+ 		    (x->props.mode != XFRM_MODE_BEET ||
+ 		     x->sel.family != AF_INET6)) {
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 2bfb4f0..377e921 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -6,6 +6,7 @@
  *                    Herbert Xu     <herbert@gondor.apana.org.au>
  *                    Abhinav Pathak <abhinav.pathak@hiit.fi>
  *                    Jeff Ahrenholz <ahrenholz@gmail.com>
+ *                    Joakim Koskela <jookos@gmail.com>
  */
 
 #include <linux/init.h>
@@ -17,6 +18,7 @@
 #include <net/dst.h>
 #include <net/inet_ecn.h>
 #include <net/ipv6.h>
+#include <net/ip.h>
 #include <net/xfrm.h>
 
 /* Add encapsulation header.
@@ -25,25 +27,81 @@
  */
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct ipv6hdr *iph, *top_iph;
-	u8 *prevhdr;
-	int hdr_len;
-
-	iph = ipv6_hdr(skb);
-
-	hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
-
-	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
-	skb_set_network_header(skb, -x->props.header_len);
-	skb->transport_header = skb->network_header + hdr_len;
-	__skb_pull(skb, hdr_len);
-
-	top_iph = ipv6_hdr(skb);
-	memmove(top_iph, iph, hdr_len);
-
-	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
-	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
-
+	struct dst_entry *dst = skb->dst;
+	struct iphdr *iphv4;
+	struct ipv6hdr *iphv6, *top_iphv6;
+	int hdrlen;
+
+	if (ip_hdr(skb)->version == 6) {
+		u8 *prevhdr;
+
+		iphv6 = ipv6_hdr(skb);
+
+		hdrlen = ip6_find_1stfragopt(skb, &prevhdr);
+
+		skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
+		skb_set_network_header(skb, -x->props.header_len);
+		skb->transport_header = skb->network_header + hdrlen;
+		__skb_pull(skb, hdrlen);
+
+		top_iphv6 = ipv6_hdr(skb);
+		memmove(top_iphv6, iphv6, hdrlen);
+
+		ipv6_addr_copy(&top_iphv6->saddr, (struct in6_addr *)&x->props.saddr);
+		ipv6_addr_copy(&top_iphv6->daddr, (struct in6_addr *)&x->id.daddr);
+	} else if (ip_hdr(skb)->version == 4) {
+		int flags, optlen, dsfield;
+		struct ip_beet_phdr *ph;
+		u8 protocol;
+
+		iphv4 = ip_hdr(skb);
+		hdrlen = 0;
+		optlen = iphv4->ihl * 4 - sizeof(*iphv4);
+		if (unlikely(optlen))
+			hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+		skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
+				       hdrlen);
+		skb->mac_header = skb->network_header + offsetof(struct ipv6hdr, nexthdr);
+		skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
+
+		ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iphv4) - hdrlen);
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
+		top_iphv6 = ipv6_hdr(skb);
+
+		/* DS disclosed */
+		top_iphv6->version = 6;
+		top_iphv6->priority = 0;
+		top_iphv6->flow_lbl[0] = 0;
+		top_iphv6->flow_lbl[1] = 0;
+		top_iphv6->flow_lbl[2] = 0;
+		dsfield = ipv6_get_dsfield(top_iphv6);
+		dsfield = INET_ECN_encapsulate(dsfield, dsfield);
+		flags = x->props.flags;
+		if (flags & XFRM_STATE_NOECN)
+			dsfield &= ~INET_ECN_MASK;
+		ipv6_change_dsfield(top_iphv6, 0, dsfield);
+
+		top_iphv6->nexthdr = protocol;
+		top_iphv6->hop_limit = dst_metric(dst->child, RTAX_HOPLIMIT);
+		ipv6_addr_copy(&top_iphv6->saddr, (struct in6_addr *)&x->props.saddr);
+		ipv6_addr_copy(&top_iphv6->daddr, (struct in6_addr *)&x->id.daddr);
+	}
+
+	skb->protocol = htons(ETH_P_IPV6);
 	return 0;
 }
 
@@ -51,26 +109,82 @@ static int xfrm6_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *ip6h;
 	const unsigned char *old_mac;
-	int size = sizeof(struct ipv6hdr);
+	int size = ((x->sel.family == AF_INET) ?
+		    sizeof(struct iphdr) :
+		    sizeof(struct ipv6hdr));
 	int err = -EINVAL;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-		goto out;
-
-	skb_push(skb, size);
-	memmove(skb->data, skb_network_header(skb), size);
-	skb_reset_network_header(skb);
-
-	old_mac = skb_mac_header(skb);
-	skb_set_mac_header(skb, -skb->mac_len);
-	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
-
-	ip6h = ipv6_hdr(skb);
-	ip6h->payload_len = htons(skb->len - size);
-	ipv6_addr_copy(&ip6h->daddr, (struct in6_addr *) &x->sel.daddr.a6);
-	ipv6_addr_copy(&ip6h->saddr, (struct in6_addr *) &x->sel.saddr.a6);
-	err = 0;
-out:
+	if (x->sel.family == AF_INET6) {
+		if (skb_cloned(skb) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			goto out;
+
+		ip6h = ipv6_hdr(skb);
+		skb_set_network_header(skb, -size);
+		memmove(skb_network_header(skb), ip6h, size);
+
+		ip6h = ipv6_hdr(skb);
+		ipv6_addr_copy(&ip6h->daddr, (struct in6_addr *) &x->sel.daddr.a6);
+		ipv6_addr_copy(&ip6h->saddr, (struct in6_addr *) &x->sel.saddr.a6);
+
+		ip6h->payload_len = htons(skb->len);
+		skb_reset_transport_header(skb);
+		skb->protocol = htons(ETH_P_IPV6);
+		err = 0;
+	} else {
+		__u8 proto = ipv6_hdr(skb)->nexthdr;
+		__u8 hops = ipv6_hdr(skb)->hop_limit;
+		int phlen = 0;
+		int optlen = 0;
+		struct iphdr *iph;
+
+		/* Inner = IPv4, therefore the IPhdr must be shrunk */
+		/* Inner = 4, Outer = 6 */
+		if (unlikely(proto == IPPROTO_BEETPH)) {
+			struct ip_beet_phdr *ph = (struct ip_beet_phdr *)
+				(struct ip_beet_phdr *)skb->data;
+
+			if (!pskb_may_pull(skb, sizeof(*ph)))
+				goto out;
+
+			phlen = sizeof(*ph) + ph->padlen;
+			optlen = ph->hdrlen * 8 + (IPV4_BEET_PHMAXLEN - phlen);
+			if (optlen < 0 || optlen & 3 || optlen > 250)
+				goto out;
+
+			if (!pskb_may_pull(skb, phlen + optlen))
+				goto out;
+			proto = ph->nexthdr;
+		}
+
+		if (skb_cloned(skb) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			goto out;
+
+		skb_push(skb, size - phlen);
+		skb_reset_network_header(skb);
+		skb_reset_transport_header(skb);
+
+		old_mac = skb_mac_header(skb);
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+
+		iph = ip_hdr(skb);
+		iph->ihl = (sizeof(*iph) + optlen) / 4;
+		iph->version = 4;
+		iph->tos = 0;
+		iph->id = 0;
+		iph->frag_off = 0;
+		iph->ttl = hops;
+		iph->protocol = proto;
+		iph->daddr = x->sel.daddr.a4;
+		iph->saddr = x->sel.saddr.a4;
+		iph->tot_len = htons(skb->len);
+		ip_send_check(iph);
+		skb->protocol = htons(ETH_P_IP);
+		err = 0;
+	}
+ out:
 	return err;
 }
 
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index b392bee..4e4c5a9 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -99,6 +99,17 @@ __xfrm6_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n)
 			src[i] = NULL;
 		}
 	}
+	if (j == n)
+		goto end;
+
+	/* Rule 5: select IPsec BEET */
+	for (i = 0; i < n; i++) {
+		if (src[i] &&
+		    src[i]->props.mode == XFRM_MODE_BEET) {
+			dst[j++] = src[i];
+			src[i] = NULL;
+		}
+	}
 	if (likely(j == n))
 		goto end;
 
