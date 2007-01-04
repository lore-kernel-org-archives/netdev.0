From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Thu, 4 Jan 2007 09:03:51 +0100
Message-ID: <20070104080351.GA1740@ff.dom.local>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, greearb@candelatech.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:40386 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932313AbXADICN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 03:02:13 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1H2M3X-0001HE-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 04, 2007 at 05:26:27PM +1100, Herbert Xu wrote:
> David Stevens <dlstevens@us.ibm.com> wrote:
> >        You're right, I don't know whether it'll fix the problem Ben saw
> > or not, but it looks like the original code can do a receive before the
> > in_device is fully initialized, and that, of course, is bad.
> >        If the device for ip_rcv() is not the same one we were
> > initializing when the receive interrupted, then the patch should have
> > no effect either way -- I don't think it'll hide other problems.
> >        If it's hard to reproduce (which I guess is true), then you're
> > right, no soft lockup doesn't really tell us if it's fixed or not.
> 
> Actually I missed your point that the multicast locks aren't even
> initialised at that point.  So this does explain the soft lock-up
> and therefore your patch is clearly the correct solution.

I doubt this is the right solution. It certainly
could fix this particular situation but my main
point was packets shouldn't get into kernel
receive queues with skb->dev not IFF_UP.

The real devices' drivers don't do that and
virtual devices should do the same. Otherwise,
the code of netif_rx or netif_receive_skb should
check this always and drop such packets or else
this kind of checking should be done later. And
this patch simply takes into consideration
something could be wrong here. But then all the
rest of receiving and routing functions should be
checked and maybe fixed to consider the same.

I've proposed some measures to check if this bug
is really caused by this skipped init but, IMHO,
this should be fixed with one of this ways:

- vlan driver should be reworked to do like "real"
drivers and assure no packet with skb->dev not
IFF_UP will be queued or processed by higher
protocols; it could possibly use bridge's master
field and skb_bond and skb_bond_should_drop (maybe
slightly changed),

- vlan driver should itself open the real devices
only after it's devices are up,

- all dev.c receive functions should be changed to
check IFF_UP - but because vlans are not so
popular - this would be the waste of time of
course.

Regards,
Jarek P.

PS: for scientific reasons we could seek this
specific place where it locks or loops now
(I've some suspicions to lockdep because it
looks like the place after it with lock init
checking isn't reached), and maybe there is
also some other bug, but it's evident this
possibility of ip_rcv and ip_route_input
before dev IFF_UP is a hole in the design and
should be fixed.
