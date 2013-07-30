From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] xfrm{4,6}: only report errors back to local sockets if we don't cross address family
Date: Tue, 30 Jul 2013 12:40:38 +0200
Message-ID: <20130730104038.GB7068@order.stressinduktion.org>
References: <20130729145017.GD2490@order.stressinduktion.org> <20130730082118.GA25511@secunet.com> <20130730083017.GA7068@order.stressinduktion.org> <20130730102611.GB25511@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, vi0oss@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:48251 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab3G3Kkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 06:40:40 -0400
Content-Disposition: inline
In-Reply-To: <20130730102611.GB25511@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 12:26:11PM +0200, Steffen Klassert wrote:
> On Tue, Jul 30, 2013 at 10:30:17AM +0200, Hannes Frederic Sowa wrote:
> > On Tue, Jul 30, 2013 at 10:21:18AM +0200, Steffen Klassert wrote:
> > > On Mon, Jul 29, 2013 at 04:50:17PM +0200, Hannes Frederic Sowa wrote:
> > > > xfrm6_local_error/xfrm4_tunnel_check_size report mtu errors back to a
> > > > socket in case it is locally generated. If the packet first traversed
> > > > a 6in4/4in6 tunnel before passing the xfrm layer, we could get a panic
> > > > because of address family type mismatch in the error reporting functions.
> > > > 
> > > 
> > > So the skb is still owned by a socket of the inner address family.
> > > Is this intentional? Maybe the ndo_start_xmit() function of the
> > > tunnel device should orphan the skb if we tunnel the packet
> > > through a different address family.
> > 
> > I thought about this, too. But then we would stop accounting the data
> > to the socket while it is travelling the stack. I don't know about the
> > possible problems resulting from this.
> > 
> 
> I'm also not absolutely sure, but we reinsert the packet to
> the ipv4/ipv6 output path which is also used to output forwarded
> packets. So the code should be prepared for handling a skb without
> socket context.
> 
> There are already situations where we orphan the skb in some
> tunnel xmit functions. For example if we tunnel through
> another namespace.

Somehow this seems the way to go.

Even if we get a matching address family socket we would still call
ipv6_local_error with the wrong fl6.daddr for that socket. I do think
IPv4 has the same issue, but I have not checked.

Because skbs could circulate multiple times through devices, a check as
(skb->dev->type | tunnel_types) seems to be not enough, too.
