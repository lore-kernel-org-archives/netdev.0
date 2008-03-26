From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [XFRM] Beet: Fix output for ipv6
Date: Wed, 26 Mar 2008 21:30:26 +0800
Message-ID: <20080326133026.GA2812@gondor.apana.org.au>
References: <200802081812.18985.joakim.koskela@hiit.fi> <200802252231.01021.joakim.koskela@hiit.fi> <20080306110835.GA6802@gondor.apana.org.au> <200803071922.23513.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38963 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754650AbYCZNae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 09:30:34 -0400
Content-Disposition: inline
In-Reply-To: <200803071922.23513.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2008 at 07:22:23PM +0200, Joakim Koskela wrote:
>
> Thanks for checking this out. I didn't actually think about
> interfamily in this patch at all as it didn't work for me without any
> patching either, this was only for fixing the 6-6 case.  We've been
> using another patch (which sort of builds on this one) for
> interfamily, I could actually send it (as a rfc) in just a minute
> (it's sort of ugly, follows the old model of handling ipv4/6
> differently in x_beet_output), was sort of waiting to get feedback for
> the 6-6 case before introducing interfamily.
> 
> But anyway - here's the trace from the crash I get. I just do a manual
> key setup and try to get a ping through.

Sorry, I dropped the ball on this.

I've found the problem thanks to your report.

[IPSEC]: Fix BEET output

The IPv6 BEET output function is incorrectly including the inner
header in the payload to be protected.  This causes a crash as
the packet doesn't actually have that many bytes for a second
header.

The IPv4 BEET output on the other hand is broken when it comes
to handling an inner IPv6 header since it always assumes an
inner IPv4 header.

This patch fixes both by making sure that neither BEET output
function touches the inner header at all.  All access is now
done through the protocol-independent cb structure.  Two new
attributes are added to make this work, the IP header length
and the IPv4 option length.  They're filled in by the inner
mode's output function.

Thanks to Joakim Koskela for finding this problem.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 619c53b..700cb26 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -530,6 +530,9 @@ struct xfrm_mode_skb_cb {
 	__be16 id;
 	__be16 frag_off;
 
+	/* IP header length (excluding options or extension headers). */
+	u8 ihl;
+
 	/* TOS for IPv4, class for IPv6. */
 	u8 tos;
 
@@ -539,6 +542,9 @@ struct xfrm_mode_skb_cb {
 	/* Protocol for IPv4, NH for IPv6. */
 	u8 protocol;
 
+	/* Option length for IPv4, zero for IPv6. */
+	u8 optlen;
+
 	/* Used by IPv6 only, zero for IPv4. */
 	u8 flow_lbl[3];
 };
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index b47030b..9c798ab 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -39,13 +39,11 @@ static void xfrm4_beet_make_header(struct sk_buff *skb)
 static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ip_beet_phdr *ph;
-	struct iphdr *iph, *top_iph;
+	struct iphdr *top_iph;
 	int hdrlen, optlen;
 
-	iph = ip_hdr(skb);
-
 	hdrlen = 0;
-	optlen = iph->ihl * 4 - sizeof(*iph);
+	optlen = XFRM_MODE_SKB_CB(skb)->optlen;
 	if (unlikely(optlen))
 		hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
 
@@ -53,11 +51,12 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 				    hdrlen);
 	skb->mac_header = skb->network_header +
 			  offsetof(struct iphdr, protocol);
-	skb->transport_header = skb->network_header + sizeof(*iph);
+	skb->transport_header = skb->network_header + sizeof(*top_iph);
 
 	xfrm4_beet_make_header(skb);
 
-	ph = (struct ip_beet_phdr *)__skb_pull(skb, sizeof(*iph) - hdrlen);
+	ph = (struct ip_beet_phdr *)
+		__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl - hdrlen);
 
 	top_iph = ip_hdr(skb);
 
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index fdeebe6..07735ed 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -52,10 +52,12 @@ int xfrm4_extract_header(struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 
+	XFRM_MODE_SKB_CB(skb)->ihl = sizeof(*iph);
 	XFRM_MODE_SKB_CB(skb)->id = iph->id;
 	XFRM_MODE_SKB_CB(skb)->frag_off = iph->frag_off;
 	XFRM_MODE_SKB_CB(skb)->tos = iph->tos;
 	XFRM_MODE_SKB_CB(skb)->ttl = iph->ttl;
+	XFRM_MODE_SKB_CB(skb)->optlen = iph->ihl * 4 - sizeof(*iph);
 	memset(XFRM_MODE_SKB_CB(skb)->flow_lbl, 0,
 	       sizeof(XFRM_MODE_SKB_CB(skb)->flow_lbl));
 
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 0527d11..d6ce400 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -45,6 +45,7 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	skb->mac_header = skb->network_header +
 			  offsetof(struct ipv6hdr, nexthdr);
 	skb->transport_header = skb->network_header + sizeof(*top_iph);
+	__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl);
 
 	xfrm6_beet_make_header(skb);
 
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index dc817e0..ff1e1db 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -174,10 +174,12 @@ int xfrm6_extract_header(struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 
+	XFRM_MODE_SKB_CB(skb)->ihl = sizeof(*iph);
 	XFRM_MODE_SKB_CB(skb)->id = 0;
 	XFRM_MODE_SKB_CB(skb)->frag_off = htons(IP_DF);
 	XFRM_MODE_SKB_CB(skb)->tos = ipv6_get_dsfield(iph);
 	XFRM_MODE_SKB_CB(skb)->ttl = iph->hop_limit;
+	XFRM_MODE_SKB_CB(skb)->optlen = 0;
 	memcpy(XFRM_MODE_SKB_CB(skb)->flow_lbl, iph->flow_lbl,
 	       sizeof(XFRM_MODE_SKB_CB(skb)->flow_lbl));
 
