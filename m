From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Fix reversed ICMP6 policy check
Date: Thu, 13 Dec 2007 10:49:18 +0800
Message-ID: <20071213024918.GA731@gondor.apana.org.au>
References: <20071212162140.6b81328d.akpm@linux-foundation.org> <20071212.162613.186792052.davem@davemloft.net> <20071212173951.4f1eb99a.akpm@linux-foundation.org> <20071213015856.GA32668@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1603 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751817AbXLMCt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 21:49:26 -0500
Content-Disposition: inline
In-Reply-To: <20071213015856.GA32668@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2007 at 09:58:56AM +0800, Herbert Xu wrote:
>
> [IPSEC]: Fix reversed ICMP6 policy check

While that won't crash anymore, it's still logically wrong.

Here's a more complete fix.

[IPSEC]: Fix reversed ICMP6 policy check

The policy check I added for ICMP on IPv6 is reversed.  We were also
letting packets through incorrectly if the ICMP flag isn't set.  This
patch fixes that.

It also adds an skb->sp check so that unprotected packets that
fail the policy check do not crash the machine.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 4e3bfcd..ccdef9a 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -978,10 +978,13 @@ int icmp_rcv(struct sk_buff *skb)
 	struct icmphdr *icmph;
 	struct rtable *rt = (struct rtable *)skb->dst;
 
-	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb) &&
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
index 478ee77..bbf4162 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -646,10 +646,13 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	struct icmp6hdr *hdr;
 	int type;
 
-	if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb) &&
-	    skb->sp->xvec[skb->sp->len - 1]->props.flags & XFRM_STATE_ICMP) {
+	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		int nh;
 
+		if (!(skb->sp && skb->sp->xvec[skb->sp->len - 1]->props.flags &
+				 XFRM_STATE_ICMP))
+			goto drop_no_count;
+
 		if (!pskb_may_pull(skb, sizeof(*hdr) + sizeof(*orig_hdr)))
 			goto drop_no_count;
 

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
