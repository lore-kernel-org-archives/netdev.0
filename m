From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Thu, 19 Jul 2007 17:08:58 +0300
Message-ID: <200707191708.58863.joakim.koskela@hiit.fi>
References: <200707161506.47915.joakim.koskela@hiit.fi> <200707171730.21655.joakim.koskela@hiit.fi> <469CE793.7020903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:44589 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965271AbXGSOJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 10:09:01 -0400
In-Reply-To: <469CE793.7020903@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here's once again a corrected version of the patch adding support for
ipv4/ipv6 interfamily addressing for the ipsec BEET (Bound End-to-End
Tunnel) mode, as specified by the ietf draft found at:

http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-07.txt

The previous implementation required that both address pairs in the SA
were of the same family. This patch enables mixing ipv4 and ipv6
addresses. All combinations (4-4, 4-6, 6-4, 6-6) have been tested
using manual key setups.

Signed-off-by: Joakim Koskela <jookos@gmail.com>
Signed-off-by: Herbert Xu     <herbert@gondor.apana.org.au>
Signed-off-by: Diego Beltrami <diego.beltrami@gmail.com>
Signed-off-by: Miika Komu     <miika@iki.fi>
---

diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index fa1902d..43c0d80 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -108,7 +108,9 @@ int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
 		if (x->mode->input(x, skb))
 			goto drop;
 
-		if (x->props.mode == XFRM_MODE_TUNNEL) {
+		if (x->props.mode == XFRM_MODE_TUNNEL ||
+		    (x->props.mode == XFRM_MODE_BEET &&
+		     x->sel.family != AF_INET)) {
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index a73e710..20e0610 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -6,6 +6,7 @@
  *                    Herbert Xu     <herbert@gondor.apana.org.au>
  *                    Abhinav Pathak <abhinav.pathak@hiit.fi>
  *                    Jeff Ahrenholz <ahrenholz@gmail.com>
+ *                    Joakim Koskela <jookos@gmail.com>
  */
 
 #include <linux/init.h>
@@ -24,92 +25,179 @@
  *      tot_len
  *      check
  *
- * On exit, skb->h will be set to the start of the payload to be processed
- * by x->type->output and skb->nh will be set to the top IP header.
+ * On exit, skb->transport_header will be set to the start of the
+ * payload to be processed by x->type->output and skb->network_header
+ * will be set to the top IP header.
  */
 static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct iphdr *iph, *top_iph;
-	int hdrlen, optlen;
-
-	iph = ip_hdr(skb);
-	skb->transport_header = skb->network_header;
-
-	hdrlen = 0;
-	optlen = iph->ihl * 4 - sizeof(*iph);
-	if (unlikely(optlen))
-		hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
-
-	skb_push(skb, x->props.header_len - IPV4_BEET_PHMAXLEN + hdrlen);
-	skb_reset_network_header(skb);
-	top_iph = ip_hdr(skb);
-	skb->transport_header += sizeof(*iph) - hdrlen;
-
-	memmove(top_iph, iph, sizeof(*iph));
-	if (unlikely(optlen)) {
-		struct ip_beet_phdr *ph;
-
-		BUG_ON(optlen < 0);
-
-		ph = (struct ip_beet_phdr *)skb_transport_header(skb);
-		ph->padlen = 4 - (optlen & 4);
-		ph->hdrlen = optlen / 8;
-		ph->nexthdr = top_iph->protocol;
-		if (ph->padlen)
-			memset(ph + 1, IPOPT_NOP, ph->padlen);
-
-		top_iph->protocol = IPPROTO_BEETPH;
-		top_iph->ihl = sizeof(struct iphdr) / 4;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	struct ipv6hdr *iphv6, *top_iphv6;
+#endif
+	struct dst_entry *dst = skb->dst;
+	struct iphdr *iphv4, *top_iphv4;
+	int hdrlen;
+
+	if (ip_hdr(skb)->version == 4) {
+		int optlen;
+
+		/* 4-4 */
+		iphv4 = ip_hdr(skb);
+		skb->transport_header = skb->network_header;
+
+		hdrlen = 0;
+		optlen = iphv4->ihl * 4 - sizeof(*iphv4);
+		if (unlikely(optlen))
+			hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+		skb_push(skb, x->props.header_len - IPV4_BEET_PHMAXLEN + hdrlen);
+		skb_reset_network_header(skb);
+		top_iphv4 = ip_hdr(skb);
+		skb->transport_header += sizeof(*iphv4) - hdrlen;
+
+		memmove(top_iphv4, iphv4, sizeof(*iphv4));
+		if (unlikely(optlen)) {
+			struct ip_beet_phdr *ph;
+
+			BUG_ON(optlen < 0);
+
+			ph = (struct ip_beet_phdr *)skb_transport_header(skb);
+			ph->padlen = 4 - (optlen & 4);
+			ph->hdrlen = optlen / 8;
+			ph->nexthdr = iphv4->protocol;
+			if (ph->padlen)
+				memset(ph + 1, IPOPT_NOP, ph->padlen);
+			top_iphv4->protocol = IPPROTO_BEETPH;
+			top_iphv4->ihl = sizeof(struct iphdr) / 4;
+		}
+
+		top_iphv4->saddr = x->props.saddr.a4;
+		top_iphv4->daddr = x->id.daddr.a4;
+
+		skb->protocol = htons(ETH_P_IP);
+	} else if (ip_hdr(skb)->version == 6) {
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+		u8 protocol;
+
+		/* Inner = 6, Outer = 4 : changing the external IP hdr
+		 * to the outer addresses
+		 */
+		hdrlen = x->props.header_len - IPV4_BEET_PHMAXLEN;
+		skb_push(skb, hdrlen);
+		iphv6 = ipv6_hdr(skb);
+
+		skb_reset_network_header(skb);
+		top_iphv6 = ipv6_hdr(skb);
+
+		protocol = iphv6->nexthdr;
+		skb_pull(skb, delta);
+		skb_reset_network_header(skb);
+		top_iphv4 = ip_hdr(skb);
+		skb_set_transport_header(skb, hdrlen);
+		top_iphv4->ihl = (sizeof(struct iphdr) >> 2);
+		top_iphv4->version = 4;
+		top_iphv4->id = 0;
+		top_iphv4->frag_off = htons(IP_DF);
+		top_iphv4->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
+		top_iphv4->saddr = x->props.saddr.a4;
+		top_iphv4->daddr = x->id.daddr.a4;
+		skb->transport_header += top_iphv4->ihl*4;
+		top_iphv4->protocol = protocol;
+
+		skb->protocol = htons(ETH_P_IP);
+#endif
 	}
 
-	top_iph->saddr = x->props.saddr.a4;
-	top_iph->daddr = x->id.daddr.a4;
-
 	return 0;
 }
 
 static int xfrm4_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
+	int hops = iph->ttl;
 	int phlen = 0;
 	int optlen = 0;
-	u8 ph_nexthdr = 0;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	int size = ((x->sel.family == AF_INET) ?
+		    sizeof(struct iphdr) :
+		    sizeof(struct ipv6hdr));
+	int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+	struct ipv6hdr *ip6h;
+#endif
+	__u8 ph_nexthdr = 0, protocol = 0;
 	int err = -EINVAL;
 
-	if (unlikely(iph->protocol == IPPROTO_BEETPH)) {
-		struct ip_beet_phdr *ph;
-
-		if (!pskb_may_pull(skb, sizeof(*ph)))
-			goto out;
-		ph = (struct ip_beet_phdr *)(ipip_hdr(skb) + 1);
-
-		phlen = sizeof(*ph) + ph->padlen;
-		optlen = ph->hdrlen * 8 + (IPV4_BEET_PHMAXLEN - phlen);
-		if (optlen < 0 || optlen & 3 || optlen > 250)
-			goto out;
-
-		if (!pskb_may_pull(skb, phlen + optlen))
-			goto out;
-		skb->len -= phlen + optlen;
-
-		ph_nexthdr = ph->nexthdr;
+	protocol = iph->protocol;
+	if (x->sel.family == AF_INET) {
+
+		if (unlikely(iph->protocol == IPPROTO_BEETPH)) {
+			struct ip_beet_phdr *ph;
+
+			if (!pskb_may_pull(skb, sizeof(*ph)))
+				goto out;
+			ph = (struct ip_beet_phdr *)(ipip_hdr(skb) + 1);
+
+			phlen = sizeof(*ph) + ph->padlen;
+			optlen = ph->hdrlen * 8 + (IPV4_BEET_PHMAXLEN - phlen);
+			if (optlen < 0 || optlen & 3 || optlen > 250)
+				goto out;
+
+			if (!pskb_may_pull(skb, phlen + optlen))
+				goto out;
+			skb->len -= phlen + optlen;
+
+			ph_nexthdr = ph->nexthdr;
+		}
+
+		skb_set_network_header(skb, phlen - sizeof(*iph));
+		memmove(skb_network_header(skb), iph, sizeof(*iph));
+		skb_set_transport_header(skb, phlen + optlen);
+		skb->data = skb_transport_header(skb);
+
+		iph = ip_hdr(skb);
+		iph->ihl = (sizeof(*iph) + optlen) / 4;
+		iph->tot_len = htons(skb->len + iph->ihl * 4);
+		iph->daddr = x->sel.daddr.a4;
+		iph->saddr = x->sel.saddr.a4;
+		if (ph_nexthdr)
+			iph->protocol = ph_nexthdr;
+		iph->check = 0;
+		iph->check = ip_fast_csum(skb_network_header(skb), iph->ihl);
+		err = 0;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	} else if (x->sel.family == AF_INET6) {
+		/* Here, the inner family is 6, therefore I have to
+		 * substitute the IPhdr by enlarging it.
+		 */
+		if (skb_tailroom(skb) < delta) {
+			if (pskb_expand_head(skb, 0, delta, GFP_ATOMIC))
+				goto out;
+		}
+
+		skb->network_header -= delta;
+
+		size += (optlen - phlen);
+		skb_push(skb, size);
+		memmove(skb->data, skb_network_header(skb), sizeof(*iph));
+		skb_reset_network_header(skb);
+
+		ip6h = ipv6_hdr(skb);
+		memset(ip6h->flow_lbl, 0, sizeof(ip6h->flow_lbl));
+		ip6h->version = 6;
+		ip6h->priority = 0;
+		ip6h->nexthdr = protocol;
+		ip6h->hop_limit = hops;
+		ip6h->payload_len = htons(skb->len - size);
+		ipv6_addr_copy(&ip6h->daddr,
+			       (struct in6_addr *)&x->sel.daddr.a6);
+		ipv6_addr_copy(&ip6h->saddr,
+			       (struct in6_addr *)&x->sel.saddr.a6);
+		skb->protocol = htons(ETH_P_IPV6);
+
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
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4ff8ed3..ff3d638 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -15,6 +15,7 @@
 
 static struct dst_ops xfrm4_dst_ops;
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
+static void xfrm4_update_pmtu(struct dst_entry *dst, u32 mtu);
 
 static int xfrm4_dst_lookup(struct xfrm_dst **dst, struct flowi *fl)
 {
@@ -81,10 +82,17 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 			}
 		}
 	};
+	union {
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+		struct in6_addr *in6;
+#endif
+		struct in_addr *in;
+	} remote, local;
 	int i;
 	int err;
 	int header_len = 0;
 	int trailer_len = 0;
+	unsigned short encap_family = 0;
 
 	dst = dst_prev = NULL;
 	dst_hold(&rt->u.dst);
@@ -113,12 +121,26 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
-
+		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
+			encap_family = xfrm[i]->props.family;
+			if (encap_family == AF_INET) {
+				remote.in = (struct in_addr *)
+					&xfrm[i]->id.daddr.a4;
+				local.in  = (struct in_addr *)
+					&xfrm[i]->props.saddr.a4;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+			} else if (encap_family == AF_INET6) {
+				remote.in6 = (struct in6_addr *)
+					xfrm[i]->id.daddr.a6;
+				local.in6 = (struct in6_addr *)
+					xfrm[i]->props.saddr.a6;
+#endif
+			}
+		}
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
-		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL) {
-			unsigned short encap_family = xfrm[i]->props.family;
+		if (encap_family) {
 			switch (encap_family) {
 			case AF_INET:
 				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
@@ -198,6 +220,14 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 	}
 
 	xfrm_init_pmtu(dst);
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	if (encap_family == AF_INET6) {
+		/* The worst case */
+		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+		u32 mtu = dst_mtu(dst);
+		xfrm4_update_pmtu(dst, mtu - delta);
+	}
+#endif
 	return 0;
 
 error:
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 7107bb7..7ddd858 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -246,7 +246,8 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 	rem = mtu & (align - 1);
 	mtu &= ~(align - 1);
 
-	if (x->props.mode != XFRM_MODE_TUNNEL) {
+	if (x->props.mode != XFRM_MODE_TUNNEL ||
+	    x->props.mode != XFRM_MODE_BEET) {
 		u32 padsize = ((blksize - 1) & 7) + 1;
 		mtu -= blksize - padsize;
 		mtu += min_t(u32, blksize - padsize, rem);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index c858537..1728f69 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -73,7 +73,9 @@ int xfrm6_rcv_spi(struct sk_buff *skb, __be32 spi)
 		if (x->mode->input(x, skb))
 			goto drop;
 
-		if (x->props.mode == XFRM_MODE_TUNNEL) { /* XXX */
+		if (x->props.mode == XFRM_MODE_TUNNEL ||
+		    (x->props.mode == XFRM_MODE_BEET &&
+		     x->sel.family != AF_INET6)) {
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 2e61d6d..c5c2f4f 100644
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
@@ -33,57 +35,218 @@
  */
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct ipv6hdr *iph, *top_iph;
-	u8 *prevhdr;
+	struct dst_entry *dst = skb->dst;
+	struct iphdr *iphv4, *top_iphv4;
+	struct ipv6hdr *iphv6, *top_iphv6;
 	int hdr_len;
 
-	skb_push(skb, x->props.header_len);
-	iph = ipv6_hdr(skb);
+	if (ip_hdr(skb)->version == 6) {
+		u8 *prevhdr;
 
-	hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
-	skb_set_network_header(skb,
-			       (prevhdr - x->props.header_len) - skb->data);
-	skb_set_transport_header(skb, hdr_len);
-	memmove(skb->data, iph, hdr_len);
+		skb_push(skb, x->props.header_len);
+		iphv6 = ipv6_hdr(skb);
 
-	skb_reset_network_header(skb);
-	top_iph = ipv6_hdr(skb);
-	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
-	skb->network_header += offsetof(struct ipv6hdr, nexthdr);
+		hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
 
-	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
-	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
+		skb_set_network_header(skb,
+				       (prevhdr - x->props.header_len) - skb->data);
+		skb_set_transport_header(skb, hdr_len);
+		memmove(skb->data, iphv6, hdr_len);
+
+		skb_reset_network_header(skb);
+		top_iphv6 = ipv6_hdr(skb);
+		skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
+		skb->network_header += offsetof(struct ipv6hdr, nexthdr);
+
+		ipv6_addr_copy(&top_iphv6->saddr, (struct in6_addr *)&x->props.saddr);
+		ipv6_addr_copy(&top_iphv6->daddr, (struct in6_addr *)&x->id.daddr);
+
+	} else if (ip_hdr(skb)->version == 4) {
+		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+		int flags, optlen, dsfield;
+		u8 protocol;
+
+		iphv4 = ip_hdr(skb);
+		skb->transport_header = skb->network_header;
+
+		hdr_len = 0;
+		optlen = iphv4->ihl * 4 - sizeof(*iphv4);
+		if (unlikely(optlen))
+			hdr_len += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+		skb_push(skb, x->props.header_len + hdr_len);
+		skb_reset_network_header(skb);
+		top_iphv4 = ip_hdr(skb);
+		skb->transport_header += sizeof(*iphv4) - hdr_len;
+
+		if (unlikely(optlen)) {
+			struct ip_beet_phdr *ph;
+
+			BUG_ON(optlen < 0);
+
+			ph = (struct ip_beet_phdr *)skb_transport_header(skb);
+			ph->padlen = 4 - (optlen & 4);
+			ph->hdrlen = optlen / 8;
+			ph->nexthdr = iphv4->protocol;
+			if (ph->padlen)
+				memset(ph + 1, IPOPT_NOP, ph->padlen);
+			top_iphv4->protocol = IPPROTO_BEETPH;
+			top_iphv4->ihl = sizeof(struct iphdr) / 4;
+		}
+
+		if (unlikely(optlen))
+			protocol = top_iphv4->protocol;
+		else
+			protocol = iphv4->protocol;
+
+		if (skb_headroom(skb) <=  2*delta) {
+			if (pskb_expand_head(skb, delta,0, GFP_ATOMIC))
+				return -ENOMEM;
+		}
+
+		skb_push(skb, delta);
+		skb_reset_network_header(skb);
+
+		top_iphv6 = ipv6_hdr(skb);
+		skb_set_transport_header(skb, sizeof(struct ipv6hdr));
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
+		top_iphv6->payload_len = htons(skb->len -
+					       sizeof(struct ipv6hdr));
+		ipv6_addr_copy(&top_iphv6->saddr,
+			       (struct in6_addr *) &x->props.saddr);
+		ipv6_addr_copy(&top_iphv6->daddr,
+			       (struct in6_addr *) &x->id.daddr);
+
+		skb->network_header += offsetof(struct ipv6hdr, nexthdr);
+
+		skb->protocol = htons(ETH_P_IPV6);
+	}
 
 	return 0;
 }
 
 static int xfrm6_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 {
+
 	struct ipv6hdr *ip6h;
 	const unsigned char *old_mac;
-	int size = sizeof(struct ipv6hdr);
+	int size = ((x->sel.family == AF_INET) ?
+		    sizeof(struct iphdr) :
+		    sizeof(struct ipv6hdr));
 	int err = -EINVAL;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-		goto out;
+	if (x->sel.family == AF_INET6) {
+
+		if (skb_cloned(skb) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			goto out;
+
+		skb_push(skb, size);
+		memmove(skb->data, skb_network_header(skb), size);
+		skb_reset_network_header(skb);
+
+		old_mac = skb_mac_header(skb);
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+
+		skb_set_transport_header(skb, size);
+		skb->data = skb_transport_header(skb);
+		skb->len -= size;
+
+		ip6h = ipv6_hdr(skb);
+		ip6h->payload_len = htons(skb->len);
+		ipv6_addr_copy(&ip6h->daddr, (struct in6_addr *) &x->sel.daddr.a6);
+		ipv6_addr_copy(&ip6h->saddr, (struct in6_addr *) &x->sel.saddr.a6);
+		skb->protocol = htons(ETH_P_IPV6);
+
+		err = 0;
+	} else {
+		struct ip_beet_phdr *ph = (struct ip_beet_phdr *)
+			skb_transport_header(skb);
+		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+		__u8 proto = ipv6_hdr(skb)->nexthdr;
+		__u8 hops = ipv6_hdr(skb)->hop_limit;
+		int phlen = 0;
+		int optlen = 0;
+		struct iphdr *iph;
+
+		/* Inner = IPv4, therefore the IPhdr must be shrunk */
+		/* Inner = 4, Outer = 6 */
+		if (unlikely(proto == IPPROTO_BEETPH)) {
+			if (!pskb_may_pull(skb, sizeof(*ph)))
+				goto out;
 
-	skb_push(skb, size);
-	memmove(skb->data, skb_network_header(skb), size);
-	skb_reset_network_header(skb);
+			phlen = sizeof(*ph) + ph->padlen;
+			optlen = ph->hdrlen * 8 + (IPV4_BEET_PHMAXLEN - phlen);
+			if (optlen < 0 || optlen & 3 || optlen > 250)
+				goto out;
 
-	old_mac = skb_mac_header(skb);
-	skb_set_mac_header(skb, -skb->mac_len);
-	memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+			if (!pskb_may_pull(skb, phlen + optlen))
+				goto out;
+			skb->len -= phlen + optlen;
+			proto = ph->nexthdr;
+		}
+		skb->network_header += delta;
 
-	ip6h = ipv6_hdr(skb);
-	ip6h->payload_len = htons(skb->len - size);
-	ipv6_addr_copy(&ip6h->daddr, (struct in6_addr *) &x->sel.daddr.a6);
-	ipv6_addr_copy(&ip6h->saddr, (struct in6_addr *) &x->sel.saddr.a6);
-	err = 0;
-out:
+		if (skb_cloned(skb) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			goto out;
+
+		skb_push(skb, size);
+		memmove(skb->data, skb_network_header(skb), size);
+		skb_reset_network_header(skb);
+
+		old_mac = skb_mac_header(skb);
+		skb_set_mac_header(skb, -skb->mac_len);
+		memmove(skb_mac_header(skb), old_mac, skb->mac_len);
+
+		if (unlikely(phlen)) {
+			skb_pull(skb, phlen - optlen);
+			skb_reset_network_header(skb);
+		}
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
+		if (unlikely(!optlen))
+			skb->transport_header = skb->network_header;
+
+		dst_release(skb->dst);
+		skb->dst = NULL;
+
+		err = 0;
+	}
+ out:
 	return err;
 }
 
+
+
 static struct xfrm_mode xfrm6_beet_mode = {
 	.input = xfrm6_beet_input,
 	.output = xfrm6_beet_output,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 1faa2ea..7c6b69a 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -24,6 +24,7 @@
 
 static struct dst_ops xfrm6_dst_ops;
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
+static void xfrm6_update_pmtu(struct dst_entry *dst, u32 mtu);
 
 static int xfrm6_dst_lookup(struct xfrm_dst **xdst, struct flowi *fl)
 {
@@ -131,6 +132,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 	struct dst_entry *dst, *dst_prev;
 	struct rt6_info *rt0 = (struct rt6_info*)(*dst_p);
 	struct rt6_info *rt  = rt0;
+	unsigned short encap_family = 0, beet = 0;
 	struct flowi fl_tunnel = {
 		.nl_u = {
 			.ip6_u = {
@@ -179,16 +181,21 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		trailer_len += xfrm[i]->props.trailer_len;
 
 		if (xfrm[i]->props.mode == XFRM_MODE_TUNNEL ||
+		    xfrm[i]->props.mode == XFRM_MODE_BEET ||
 		    xfrm[i]->props.mode == XFRM_MODE_ROUTEOPTIMIZATION) {
-			unsigned short encap_family = xfrm[i]->props.family;
+
+			beet = xfrm[i]->props.mode == XFRM_MODE_BEET;
+			encap_family = xfrm[i]->props.family;
+
 			switch(encap_family) {
 			case AF_INET:
 				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
 				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
+				fl_tunnel.fl4_tos = 0;
+				fl_tunnel.fl4_scope = 0;
 				break;
 			case AF_INET6:
 				ipv6_addr_copy(&fl_tunnel.fl6_dst, __xfrm6_bundle_addr_remote(xfrm[i], &fl->fl6_dst));
-
 				ipv6_addr_copy(&fl_tunnel.fl6_src, __xfrm6_bundle_addr_local(xfrm[i], &fl->fl6_src));
 				break;
 			default:
@@ -259,7 +266,14 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
 
+
 	xfrm_init_pmtu(dst);
+	if (beet && encap_family == AF_INET) {
+		int delta = sizeof(struct ipv6hdr) - sizeof(struct iphdr);
+		u32 mtu = dst_mtu(dst);
+		xfrm6_update_pmtu(dst, mtu + delta);
+	}
+
 	return 0;
 
 error:
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index baa461b..5c14227 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -98,6 +98,17 @@ __xfrm6_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n)
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
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 157bfbd..75fdb7d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1299,7 +1299,8 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, struct flowi *fl,
 		xfrm_address_t *local  = saddr;
 		struct xfrm_tmpl *tmpl = &policy->xfrm_vec[i];
 
-		if (tmpl->mode == XFRM_MODE_TUNNEL) {
+		if (tmpl->mode == XFRM_MODE_TUNNEL ||
+		    tmpl->mode == XFRM_MODE_BEET) {
 			remote = &tmpl->id.daddr;
 			local = &tmpl->saddr;
 			family = tmpl->encap_family;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index dfacb9c..0a2ff8e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -611,7 +611,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			      selector.
 			 */
 			if (x->km.state == XFRM_STATE_VALID) {
-				if (!xfrm_selector_match(&x->sel, fl, family) ||
+				if (!xfrm_selector_match(&x->sel, fl, x->sel.family) ||
 				    !security_xfrm_state_pol_flow_match(x, pol, fl))
 					continue;
 				if (!best ||
@@ -623,7 +623,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 				acquire_in_progress = 1;
 			} else if (x->km.state == XFRM_STATE_ERROR ||
 				   x->km.state == XFRM_STATE_EXPIRED) {
-				if (xfrm_selector_match(&x->sel, fl, family) &&
+				if (xfrm_selector_match(&x->sel, fl, x->sel.family) &&
 				    security_xfrm_state_pol_flow_match(x, pol, fl))
 					error = -ESRCH;
 			}
