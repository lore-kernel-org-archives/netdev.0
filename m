From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] xfrm{4,6}: only report errors back to local sockets if we don't cross address family
Date: Fri, 9 Aug 2013 01:06:20 +0200
Message-ID: <20130808230620.GK14001@order.stressinduktion.org>
References: <20130729145017.GD2490@order.stressinduktion.org> <20130730082118.GA25511@secunet.com> <20130730083017.GA7068@order.stressinduktion.org> <20130730102611.GB25511@secunet.com> <20130801081150.GF3688@order.stressinduktion.org> <20130801100522.GC25511@secunet.com> <20130808224440.GJ14001@order.stressinduktion.org> <1376002677.4004.139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, vi0oss@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40435 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966339Ab3HHXGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 19:06:21 -0400
Content-Disposition: inline
In-Reply-To: <1376002677.4004.139.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 08, 2013 at 03:57:57PM -0700, Eric Dumazet wrote:
> On Fri, 2013-08-09 at 00:44 +0200, Hannes Frederic Sowa wrote:
> > On Thu, Aug 01, 2013 at 12:05:22PM +0200, Steffen Klassert wrote:
> > > On Thu, Aug 01, 2013 at 10:11:50AM +0200, Hannes Frederic Sowa wrote:
> > > > 
> > > > If you have not yet done so, I would try to find a solution over the weekend.
> > > > 
> > > 
> > > I have not yet done so, please go ahead.
> > 
> > Ok, this patch should do the trick. In xfrm6 error path we now generate
> > a plain icmpv6 packet back to us in this specific case vi0oss reported. I
> > wonder if we should suppress these.
> > 
> > Btw. is the memset(IPCB, 0) actually needed in the ipv4 output path?
> > 
> > [PATCH RFC] net: orphan socket when skb traverses tunnel interface
> > 
> > When a local generated packet traverses a tunnel the socket has to be
> > orphaned from the skb. Otherwise lower layer, like xfrm, try to report
> > errors directly to this socket. If, because of a transitioning tunnel,
> > the address family changes we deliver an invalid error or panic in the
> > error reporting functions.
> > 
> > Also add a call to secpath_reset() in the ipv6 tunnel xmit path. It
> > seems like it was just forgotten.
> > 
> > Reported-by: <vi0oss@gmail.com>
> > Cc: Steffen Klassert <steffen.klassert@secunet.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> 
> Doing so breaks flow control.
> 
> A single socket can flood and fill the Qdisc, even a friendly one like a
> local TCP flow (see TCP Small Queues)
> 
> Can't we make the error reporting more robust instead ?

Hm, I thought so. My other patch (some mails above in this thread) checks for
a switch in address family and does prohibit the panic, but generates wrong
error reports back to the socket if the address family does not switch (which
maybe get ignored).

I will check if the skb->encapsulated bit could help. Actually I don't
know what the correct behaviour for error reporting should be in the end,
maybe: dispatch packet back to tunnel interface, let tunnel interface
decapsulate the inner packet and use this inner header to inform the
original socket about the error.

Thanks,

  Hannes
