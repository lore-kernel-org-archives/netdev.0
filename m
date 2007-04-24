From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 8057] New: slab corruption running ip6sic
Date: Tue, 24 Apr 2007 09:31:51 +0200
Message-ID: <20070424073151.GA2333@ff.dom.local>
References: <20070222134918.e2f1af6d.akpm@linux-foundation.org> <20070312102403.GB1664@ff.dom.local> <20070420.163515.26929060.davem@davemloft.net> <20070423064416.GB1684@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, snakebyte@gmx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:37605 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161692AbXDXH0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 03:26:06 -0400
Content-Disposition: inline
In-Reply-To: <20070423064416.GB1684@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 23, 2007 at 08:44:16AM +0200, Jarek Poplawski wrote:
> On Fri, Apr 20, 2007 at 04:35:15PM -0700, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@o2.pl>
> > Date: Mon, 12 Mar 2007 11:24:03 +0100
> > 
> > > > the ipcomp handler is xfrm6_rcv(), which calls xfrm6_rcv_spi(), which contrary
> > > > to all other handlers returns -1 instead of 0 after calling kfree_skb() on the
> > > > skb. Changing the return value to 0 in xfrm6_input.c:xfrm6_rcv_spi() fixes the
> > > > problem.
> > > > But I got no clue at all if this would be a correct fix
> > > 
> > > I think your diagnose is correct (all "return -1" should be
> > > changed to "return 0" in xfrm6_input.c).
> 
> I've corrected this, yet:
> 
> "Sorry! Of course should be:
> I think your diagnose is correct (all "return -1" should be
> changed to "return 0" in xfrm6_rcv_spi())."
> 
> It's just like Eric diagnosed:
> 
> xfrm6_rcv() calls tunnel6_rcv(), which calls handlers->handler()
> and if handler() returns anything but 0, skb is kfreed. But
> handler: xfrm6_tunnel_rcv() calls xfrm6_rcv_spi() and returns its
> return without changing, which is only 1 and -1. It seems, in
> every -1 case skb is kfreed by xfrm6_rcv_spi() or by functions
> called by it, probably meaning skb was handled (delivered or
> kfreed). The only path where skb is not kfreed returns 1.
> 
> tunnel6_rcv() treats both returns the same way - so some skbs
> are kfreed 2 times.

OK, now I see this place is really "special" and there is more
than this. The same handler is used for 2 things, which expect
different error codes for similar things. 

My proposal is: maybe Eric could change this in
xfrm6_tunnel_rcv() from xfrm6_tunnel.c e.g. like this:

return xfrm6_rcv_spi(skb, spi) > 0 ? : 0;

and, if no errors in testing, he could resubmit this patch? 

Regards,
Jarek P.
