From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Looking for a lost patch
Date: Wed, 20 May 2015 08:32:23 +0200
Message-ID: <20150520063223.GM8928@secunet.com>
References: <55538E1F.2020505@gmail.com>
 <20150518073809.GD8928@secunet.com>
 <555A0D0E.5040102@redhat.com>
 <20150519075724.GI8928@secunet.com>
 <555B81AF.5050401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34333 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbbETGc1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2015 02:32:27 -0400
Content-Disposition: inline
In-Reply-To: <555B81AF.5050401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 11:32:15AM -0700, Alexander Duyck wrote:
> On 05/19/2015 12:57 AM, Steffen Klassert wrote:
> >The MTU should be 1500. All the IPsec overhead is handled by PMTU
> >discovery, just like in the case we use IPsec without vti tunnels.
> >The IPv6 side of vti does it like that.
> 
> The problem is the PMTU isn't communicated to things that make use
> of the tunnel.  For example if I do a "ping -s 2000 x.x.x.x" across
> an IPv6 VTI interface it will fail currently as it assumes the MTU
> is 1500 and so it is fragmenting the ping packet at sizes that won't
> be communicated across the underlying interface.

Well, the problem is that the local socket is still attached on the
skb. The socket gets an error notification if the packet is too big,
but ping does not care much about these error notifications.

One option to get such applications to work is to orphan the skb
in the vti xmit function. Then the packet is not assumed to be
local, so PMTU discovery is triggered on that route.

Something like this should work for IPv6:

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ed9d681..cd50bc1 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -459,6 +459,7 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 		goto tx_err_dst_release;
 	}
 
+	skb_orphan(skb);
 	skb_scrub_packet(skb, !net_eq(t->net, dev_net(dev)));
 	skb_dst_set(skb, dst);
 	skb->dev = skb_dst(skb)->dev;
