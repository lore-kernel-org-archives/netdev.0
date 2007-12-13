From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Fix reversed ICMP6 policy check
Date: Thu, 13 Dec 2007 10:51:56 +0800
Message-ID: <20071213025155.GA784@gondor.apana.org.au>
References: <20071212.162613.186792052.davem@davemloft.net> <20071212173951.4f1eb99a.akpm@linux-foundation.org> <20071213015856.GA32668@gondor.apana.org.au> <20071212.184830.25856041.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1637 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751081AbXLMCwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 21:52:03 -0500
Content-Disposition: inline
In-Reply-To: <20071212.184830.25856041.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2007 at 06:48:30PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 13 Dec 2007 09:58:56 +0800
> 
> > [IPSEC]: Fix reversed ICMP6 policy check
> 
> Applied, thanks Herbert.

You're too quick :) Before you ask for an incremental patch, here's
a preemptive strike :)

[IPSEC]: Do not let packets pass when ICMP flag is off

This fixes a logical error in ICMP policy checks which lets
packets through if the state ICMP flag is off.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 132e879..ccdef9a 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -978,10 +978,13 @@ int icmp_rcv(struct sk_buff *skb)
 	struct icmphdr *icmph;
 	struct rtable *rt = (struct rtable *)skb->dst;
 
-	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb) && skb->sp &&
-	    skb->sp->xvec[skb->sp->len - 1]->props.flags & XFRM_STATE_ICMP) {
+	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		int nh;
 
+		if (!(skb->sp && skb->sp->xvec[skb->sp->len - 1]->props.flags &
+				 XFRM_STATE_ICMP))
+			goto drop;
+
 		if (!pskb_may_pull(skb, sizeof(*icmph) + sizeof(struct iphdr)))
 			goto drop;
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 64d78c9..bbf4162 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -646,10 +646,13 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	struct icmp6hdr *hdr;
 	int type;
 
-	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb) && skb->sp &&
-	    skb->sp->xvec[skb->sp->len - 1]->props.flags & XFRM_STATE_ICMP) {
+	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		int nh;
 
+		if (!(skb->sp && skb->sp->xvec[skb->sp->len - 1]->props.flags &
+				 XFRM_STATE_ICMP))
+			goto drop_no_count;
+
 		if (!pskb_may_pull(skb, sizeof(*hdr) + sizeof(*orig_hdr)))
 			goto drop_no_count;
 
