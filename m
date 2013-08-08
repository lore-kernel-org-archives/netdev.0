From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] xfrm{4,6}: only report errors back to local sockets if we don't cross address family
Date: Fri, 9 Aug 2013 00:44:40 +0200
Message-ID: <20130808224440.GJ14001@order.stressinduktion.org>
References: <20130729145017.GD2490@order.stressinduktion.org> <20130730082118.GA25511@secunet.com> <20130730083017.GA7068@order.stressinduktion.org> <20130730102611.GB25511@secunet.com> <20130801081150.GF3688@order.stressinduktion.org> <20130801100522.GC25511@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, vi0oss@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40407 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966781Ab3HHWol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 18:44:41 -0400
Content-Disposition: inline
In-Reply-To: <20130801100522.GC25511@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 12:05:22PM +0200, Steffen Klassert wrote:
> On Thu, Aug 01, 2013 at 10:11:50AM +0200, Hannes Frederic Sowa wrote:
> > 
> > If you have not yet done so, I would try to find a solution over the weekend.
> > 
> 
> I have not yet done so, please go ahead.

Ok, this patch should do the trick. In xfrm6 error path we now generate
a plain icmpv6 packet back to us in this specific case vi0oss reported. I
wonder if we should suppress these.

Btw. is the memset(IPCB, 0) actually needed in the ipv4 output path?

[PATCH RFC] net: orphan socket when skb traverses tunnel interface

When a local generated packet traverses a tunnel the socket has to be
orphaned from the skb. Otherwise lower layer, like xfrm, try to report
errors directly to this socket. If, because of a transitioning tunnel,
the address family changes we deliver an invalid error or panic in the
error reporting functions.

Also add a call to secpath_reset() in the ipv6 tunnel xmit path. It
seems like it was just forgotten.

Reported-by: <vi0oss@gmail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_tunnel.h  | 5 +++++
 net/ipv4/ip_tunnel_core.c | 1 +
 2 files changed, 6 insertions(+)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 4da5de1..92770de 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -6,6 +6,8 @@
 #include <linux/if_tunnel.h>
 #include <linux/ip6_tunnel.h>
 
+#include <net/xfrm.h>
+
 #define IP6TUNNEL_ERR_TIMEO (30*HZ)
 
 /* capable of sending packets */
@@ -74,7 +76,10 @@ static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_device_stats *stats = &dev->stats;
 	int pkt_len, err;
 
+	skb_orphan(skb);
 	nf_reset(skb);
+	secpath_reset(skb);
+	skb->rxhash = 0;
 	pkt_len = skb->len;
 	err = ip6_local_out(skb);
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 7167b08..8a1a378 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -55,6 +55,7 @@ int iptunnel_xmit(struct net *net, struct rtable *rt,
 	struct iphdr *iph;
 	int err;
 
+	skb_orphan(skb);
 	nf_reset(skb);
 	secpath_reset(skb);
 	skb->rxhash = 0;
-- 
1.8.3.1
