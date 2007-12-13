From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Fix reversed ICMP6 policy check
Date: Thu, 13 Dec 2007 09:58:56 +0800
Message-ID: <20071213015856.GA32668@gondor.apana.org.au>
References: <20071212162140.6b81328d.akpm@linux-foundation.org> <20071212.162613.186792052.davem@davemloft.net> <20071212173951.4f1eb99a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1112 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751874AbXLMB7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 20:59:08 -0500
Content-Disposition: inline
In-Reply-To: <20071212173951.4f1eb99a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2007 at 05:39:51PM -0800, Andrew Morton wrote:
>
> Here's the screen-shot (actually more like a reen-hot):
> http://userweb.kernel.org/~akpm/pc121694.jpg
> 
> I'm awaiting a reoccurrence with the screen in 50-row mode.

Sorry, I didn't test IPv6.

[IPSEC]: Fix reversed ICMP6 policy check

The policy check I added for ICMP on IPv6 is reversed.  This
patch fixes that.

It also adds an skb->sp check so that unprotected packets that
fail the policy check do not crash the machine.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 4e3bfcd..132e879 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -978,7 +978,7 @@ int icmp_rcv(struct sk_buff *skb)
 	struct icmphdr *icmph;
 	struct rtable *rt = (struct rtable *)skb->dst;
 
-	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb) &&
+	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb) && skb->sp &&
 	    skb->sp->xvec[skb->sp->len - 1]->props.flags & XFRM_STATE_ICMP) {
 		int nh;
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 478ee77..64d78c9 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -646,7 +646,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	struct icmp6hdr *hdr;
 	int type;
 
-	if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb) &&
+	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb) && skb->sp &&
 	    skb->sp->xvec[skb->sp->len - 1]->props.flags & XFRM_STATE_ICMP) {
 		int nh;
 
