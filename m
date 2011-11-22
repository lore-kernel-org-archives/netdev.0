From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/4] ipv4: Update pmtu informations on inetpeer only
 for output routes
Date: Tue, 22 Nov 2011 14:20:27 +0100
Message-ID: <20111122132027.GG20943@secunet.com>
References: <20111012.170805.2172804476308993385.davem@davemloft.net>
 <20111108.143630.106539981030509701.davem@davemloft.net>
 <20111114101244.GB20943@secunet.com>
 <20111114.143320.773675445837769668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41958 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645Ab1KVNU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Nov 2011 08:20:29 -0500
Content-Disposition: inline
In-Reply-To: <20111114.143320.773675445837769668.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 02:33:20PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Mon, 14 Nov 2011 11:12:44 +0100
> 
> > So for the moment I'm thinking about adding an ip_dst_mtu()
> > function that returns dst->ops->default_mtu() for input routes
> > and dst_mtu() for output routes. Then we could convert the
> > dst_mtu() users in net/ipv4/ over to this one.
> 
> We'll need something similar for ipv6 eventually...
> 
> I would suggest that we do away with dst_ops->default_mtu() and just
> have dst_ops->mtu() which gets invoked unconditionally by dst_mtu().
> 

I found another pmtu related issue. Since commit 2774c131b
(xfrm: Handle blackhole route creation via afinfo)
we create a blackhole route even on packet forwarding
if we have a xfrm policy but we don't have yet the states.

In this case, the packet is not dropped immediately
but continues to travel in the packet forwarding path.
This means that the blackhole route's dst_ops->default_mtu()
method is invoked which returns a mtu of null. So
we announce a pmtu of null to the original sender of
the packet.

The simplest fix would be to return e.g. IP_MAX_MTU
as the default mtu on blackhole routes. But actually
I don't see why we should create a blackhole route on
packet forwarding as long as we finally drop the
packet anyway. So perhaps it is better to create
blackhole routes just in the case when we have socket
context.
