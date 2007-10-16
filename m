From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/12] [IPSEC]: Remove xfrmX_tunnel_check_size
Date: Tue, 16 Oct 2007 22:33:15 +0800
Message-ID: <E1IhnTv-0003H1-00@gondolin.me.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3006 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932863AbXJPOxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:51 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1Ihnnm-0001GY-Ue
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 00:53:47 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Remove xfrmX_tunnel_check_size

These functions have always been causing trouble by sending ICMP errors
back to the local host which was totally confused about how to deal with
it and most often ended up causing a downward spiral which only finishes
when the MTU is so small that you can't send packets out anymore.

They're also wrong now that we have inter-family transforms.  They'll
end up trying to shove an IPv4 packet into the IPv6 ICMP stack and vice
versa.

In fact, I've just realised that they are totally unnecessary.  The reason
is that whoever calls us should have already checked the MTU.  In particular,
there are two cases:

1) The packet is forwarded in which case the forwarding function would've
performed the check.

2) The packet is local in which case whoever generated it should've checked.
If they didn't check then us sending back an ICMP error wouldn't do any good
anyway since the next time they transmit they'll still get it wrong.

So the only time this function has an effect is when the MTU happens to
change between the caller checking it and us checking it.  This is useless
because if we did catch such a change there's nothing stopping a further
MTU change between us checking it and the packet actually getting to the
device.

Indeed, at the bottom of the stack there will be another check by either
ip_output or ip6_output that would catch such an MTU change.

Such a change would not be able to send an ICMP error back to the original
sender but that's a general problem of our IPsec stack which we might solve
one day.  In any case, the benefit of having xfrmX_tunnel_check_size is
now outweighed by its problems.

Therefore this patch removes them both.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/xfrm4_output.c |   31 -------------------------------
 net/ipv6/xfrm6_output.c |   26 --------------------------
 2 files changed, 57 deletions(-)

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index a4edd66..ba26490 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -17,42 +17,11 @@
 #include <net/xfrm.h>
 #include <net/icmp.h>
 
-static int xfrm4_tunnel_check_size(struct sk_buff *skb)
-{
-	int mtu, ret = 0;
-	struct dst_entry *dst;
-
-	if (IPCB(skb)->flags & IPSKB_XFRM_TUNNEL_SIZE)
-		goto out;
-
-	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
-
-	if (!(ip_hdr(skb)->frag_off & htons(IP_DF)) || skb->local_df)
-		goto out;
-
-	dst = skb->dst;
-	mtu = dst_mtu(dst);
-	if (skb->len > mtu) {
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-		ret = -EMSGSIZE;
-	}
-out:
-	return ret;
-}
-
 static inline int xfrm4_output_one(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
 	struct iphdr *iph;
 	int err;
 
-	if (x->props.mode == XFRM_MODE_TUNNEL) {
-		err = xfrm4_tunnel_check_size(skb);
-		if (err)
-			goto error_nolock;
-	}
-
 	err = xfrm_output(skb);
 	if (err)
 		goto error_nolock;
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index a5a32c1..4fb477a 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -25,37 +25,11 @@ int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 
 EXPORT_SYMBOL(xfrm6_find_1stfragopt);
 
-static int xfrm6_tunnel_check_size(struct sk_buff *skb)
-{
-	int mtu, ret = 0;
-	struct dst_entry *dst = skb->dst;
-
-	mtu = dst_mtu(dst);
-	if (mtu < IPV6_MIN_MTU)
-		mtu = IPV6_MIN_MTU;
-
-	if (skb->len > mtu) {
-		skb->dev = dst->dev;
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
-		ret = -EMSGSIZE;
-	}
-
-	return ret;
-}
-
 static inline int xfrm6_output_one(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
 	struct ipv6hdr *iph;
 	int err;
 
-	if (x->props.mode == XFRM_MODE_TUNNEL) {
-		err = xfrm6_tunnel_check_size(skb);
-		if (err)
-			goto error_nolock;
-	}
-
 	err = xfrm_output(skb);
 	if (err)
 		goto error_nolock;
