From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 xfrm GSO fragmentation bug
Date: Fri, 4 Sep 2015 13:21:06 +0800
Message-ID: <20150904052106.GA5689@gondor.apana.org.au>
References: <20150830082432.GA25588@gondor.apana.org.au>
 <20150831071916.GG25499@secunet.com>
 <20150831073526.GA31958@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35854 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757340AbbIDFVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 01:21:11 -0400
Content-Disposition: inline
In-Reply-To: <20150831073526.GA31958@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2015 at 03:35:26PM +0800, Herbert Xu wrote:
> 
> I see where the bug came from.  Indeed IPv6 does do fragmentation
> but only for tunnel mode.  While your patch added a check that also
> affected transport mode.  So in addition to the GSO fix we should
> also make the MTU check conditional to tunnel mode.

Here is the patch:

---8<---
ipv6: Fix IPsec pre-encap fragmentation check

The IPv6 IPsec pre-encap path performs fragmentation for tunnel-mode
packets.  That is, we perform fragmentation pre-encap rather than
post-encap.

A check was added later to ensure that proper MTU information is
passed back for locally generated traffic.  Unfortunately this
check was performed on all IPsec packets, including transport-mode
packets.

What's more, the check failed to take GSO into account.

The end result is that transport-mode GSO packets get dropped at
the check.

This patch fixes it by moving the tunnel mode check forward as well
as adding the GSO check.

Fixes: dd767856a36e ("xfrm6: Don't call icmpv6_send on local error")
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 09c76a7..be033f2 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -136,6 +136,7 @@ static int __xfrm6_output(struct sock *sk, struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
 	int mtu;
+	bool toobig;
 
 #ifdef CONFIG_NETFILTER
 	if (!x) {
@@ -144,25 +145,29 @@ static int __xfrm6_output(struct sock *sk, struct sk_buff *skb)
 	}
 #endif
 
+	if (x->props.mode != XFRM_MODE_TUNNEL)
+		goto skip_frag;
+
 	if (skb->protocol == htons(ETH_P_IPV6))
 		mtu = ip6_skb_dst_mtu(skb);
 	else
 		mtu = dst_mtu(skb_dst(skb));
 
-	if (skb->len > mtu && xfrm6_local_dontfrag(skb)) {
+	toobig = skb->len > mtu && !skb_is_gso(skb);
+
+	if (toobig && xfrm6_local_dontfrag(skb)) {
 		xfrm6_local_rxpmtu(skb, mtu);
 		return -EMSGSIZE;
-	} else if (!skb->ignore_df && skb->len > mtu && skb->sk) {
+	} else if (!skb->ignore_df && toobig && skb->sk) {
 		xfrm_local_error(skb, mtu);
 		return -EMSGSIZE;
 	}
 
-	if (x->props.mode == XFRM_MODE_TUNNEL &&
-	    ((skb->len > mtu && !skb_is_gso(skb)) ||
-		dst_allfrag(skb_dst(skb)))) {
+	if (toobig || dst_allfrag(skb_dst(skb)))
 		return ip6_fragment(sk, skb,
 				    x->outer_mode->afinfo->output_finish);
-	}
+
+skip_frag:
 	return x->outer_mode->afinfo->output_finish(sk, skb);
 }
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
