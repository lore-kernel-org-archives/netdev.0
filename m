From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] ipv6: Fix IPsec pre-encap fragmentation check
Date: Thu, 22 Oct 2015 08:07:16 +0200
Message-ID: <1445494039-2612-2-git-send-email-steffen.klassert@secunet.com>
References: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50521 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbbJVGH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 02:07:28 -0400
In-Reply-To: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

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
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_output.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

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
1.9.1
