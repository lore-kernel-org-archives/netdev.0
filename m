From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Problematic commits in the ipsec tree
Date: Fri, 23 Aug 2013 14:49:11 +0200
Message-ID: <20130823124911.GD808@order.stressinduktion.org>
References: <20130822104724.GD26773@secunet.com> <20130822135342.GC30722@order.stressinduktion.org> <20130823085807.GH26773@secunet.com> <20130823110323.GB808@order.stressinduktion.org> <20130823113435.GC808@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42213 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754483Ab3HWMtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 08:49:12 -0400
Content-Disposition: inline
In-Reply-To: <20130823113435.GC808@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 23, 2013 at 01:34:35PM +0200, Hannes Frederic Sowa wrote:
> On Fri, Aug 23, 2013 at 01:03:23PM +0200, Hannes Frederic Sowa wrote:
> > Hello!
> > 
> > On Fri, Aug 23, 2013 at 10:58:07AM +0200, Steffen Klassert wrote:
> > > On Thu, Aug 22, 2013 at 03:53:42PM +0200, Hannes Frederic Sowa wrote:
> > > > On Thu, Aug 22, 2013 at 12:47:24PM +0200, Steffen Klassert wrote:
> > > > > Hannes,
> > > > > 
> > > > > I have two problematic commits from you in the ipsec tree. The first one is:
> > > > > 
> > > > > commit 0ea9d5e3e (xfrm: introduce helper for safe determination of mtu)
> > > > > 
> > > > > This breakes pmtu discovery for IPv4 because now we use the device mtu
> > > > > instead of the reduced IPsec mtu in xfrm4_tunnel_check_size() if a IPv4
> > > > > socket is at the skb.
> > > > 
> > > > I am currently testing this following patch. It should restore old behavior
> > > > for ipv4 sockets.
> > > > 
> > > > diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> > > > index ac5b025..65d3529 100644
> > > > --- a/include/net/xfrm.h
> > > > +++ b/include/net/xfrm.h
> > > > @@ -1730,8 +1730,6 @@ static inline int xfrm_skb_dst_mtu(struct sk_buff *skb)
> > > >  
> > > >  	if (sk && skb->protocol == htons(ETH_P_IPV6))
> > > >  		return ip6_skb_dst_mtu(skb);
> > > > -	else if (sk && skb->protocol == htons(ETH_P_IP))
> > > > -		return ip_skb_dst_mtu(skb);
> > > >  	return dst_mtu(skb_dst(skb));
> > > >  }
> > > 
> > > This looks still fragile. xfrm_skb_dst_mtu() is called from
> > > __xfrm6_output() and from xfrm4_tunnel_check_size().
> > > We will have the same bug again as soon as somebody thinks that
> > > it is save to call it from xfrm6_tunnel_check_size() too. So I
> > > think it is better not to call it from xfrm4_tunnel_check_size().
> > 
> > Hm, I don't think I can follow you completly here. I searched for allocations
> > of ipv6 skbs (where they originated from a socket) and checked these
> > allocations also initialize the skb->protocol field (the second patch).
> > 
> > I wonder if ip6_skb_dst_mtu was correct all along and if we should just
> > switch to dst_mtu(skb_dst(skb)) in all cases?
> 
> Ok, I got it.
> 
> How about just checking in __xfrm6_output if we actually have a packet
> originated from an IPv6 socket so that we only replace the original call to
> ip6_skb_dst_mtu(skb)?

This could be the replacement for patch 1/2 to reassemble old behaviour
without touching ip6_skb_dst_mtu if the socket type is not an IPv6 one.

I would still like to look if we could correctly handle *_PMTUDISC_PROBE one
day and fallback to dst_mtu(dst->path) if possible. So I don't know if
removing xfrm_skb_dst_mtu is good style and would just make churn in the git
history. What do you think?

[PATCH ipsec 1/2] xfrm: revert ipv4 mtu determination to dst_mtu

In commit 0ea9d5e3e0e03a63b11392f5613378977dae7eca ("xfrm: introduce
helper for safe determination of mtu") I switched the determination of
ipv4 mtus from dst_mtu to ip_skb_dst_mtu. This was an error because in
case of IP_PMTUDISC_PROBE we fall back to the interface mtu, which is
never correct for ipv4 ipsec.

This patch partly reverts 0ea9d5e3e0e03a63b11392f5613378977dae7eca
("xfrm: introduce helper for safe determination of mtu").

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/xfrm.h      | 12 ------------
 net/ipv4/xfrm4_output.c |  2 +-
 net/ipv6/xfrm6_output.c |  8 +++++---
 3 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ac5b025..e823786 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -20,7 +20,6 @@
 #include <net/route.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
-#include <net/ip6_route.h>
 #include <net/flow.h>
 
 #include <linux/interrupt.h>
@@ -1724,15 +1723,4 @@ static inline int xfrm_mark_put(struct sk_buff *skb, const struct xfrm_mark *m)
 	return ret;
 }
 
-static inline int xfrm_skb_dst_mtu(struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-
-	if (sk && skb->protocol == htons(ETH_P_IPV6))
-		return ip6_skb_dst_mtu(skb);
-	else if (sk && skb->protocol == htons(ETH_P_IP))
-		return ip_skb_dst_mtu(skb);
-	return dst_mtu(skb_dst(skb));
-}
-
 #endif	/* _NET_XFRM_H */
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 80baf4a..baa0f63 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -28,7 +28,7 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 	if (!(ip_hdr(skb)->frag_off & htons(IP_DF)) || skb->local_df)
 		goto out;
 
-	mtu = xfrm_skb_dst_mtu(skb);
+	mtu = dst_mtu(skb_dst(skb));
 	if (skb->len > mtu) {
 		if (skb->sk)
 			xfrm_local_error(skb, mtu);
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index e092e30..6cd625e 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -140,10 +140,12 @@ static int __xfrm6_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
-	int mtu = xfrm_skb_dst_mtu(skb);
+	int mtu;
 
-	if (mtu < IPV6_MIN_MTU)
-		mtu = IPV6_MIN_MTU;
+	if (skb->protocol == htons(ETH_P_IPV6))
+		mtu = ip6_skb_dst_mtu(skb);
+	else
+		mtu = dst_mtu(skb_dst(skb));
 
 	if (skb->len > mtu && xfrm6_local_dontfrag(skb)) {
 		xfrm6_local_rxpmtu(skb, mtu);
-- 
1.8.3.1
