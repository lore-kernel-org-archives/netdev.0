From: David Miller <davem@davemloft.net>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Thu, 07 Aug 2008 03:45:45 -0700 (PDT)
Message-ID: <20080807.034545.202633862.davem@davemloft.net>
References: <20080807100910.GA12391@ff.dom.local>
	<20080807.031058.193703340.davem@davemloft.net>
	<20080807103130.GA12654@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43070
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751003AbYHGMkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:40:04 -0400
In-Reply-To: <20080807103130.GA12654@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 7 Aug 2008 10:31:30 +0000

> On Thu, Aug 07, 2008 at 03:10:58AM -0700, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Thu, 7 Aug 2008 10:09:10 +0000
> ...
> > > After some checking it looks mostly OK to me, but one thing: in
> > > sch_gred gred_drop() calls qdisc_drop(), so now it needs kfree_skb().
> > > BTW, maybe it would be nicer to add __qdisc_drop() for these new
> > > things?
> > 
> > qdisc_drop() sets the new __NET_XMIT_KFREE bit, but sch_gred wants to
> > return NET_XMIT_CN, so I OR'd in the __NET_XMIT_KFREE bit there.
> 
> Hmm... I'm not sure we're thinking about the same function?

Indeed, you're right.

I've added the kfree_skb() call to gred_drop() in my local tree.

Thanks!

BTW, speaking of ->requeue(), I think we could easily eliminate
that thing.  It only exists because we allow drivers to kick things
back to us via ->hard_start_xmit() return values.

There are two cases:

1) NETDEV_TX_LOCKED... thanks to the bogon named LLTX

2) NETDEV_TX_BUSY, which is pretty much a bug

   %99.999 of the cases that return NETDEV_TX_BUSY are error
   conditions in the driver which log a message and we could
   just as validly drop the packet for this case

But anyways, LLTX isn't dying tomorrow as much as we'd like it go
away.

But we could cache the SKB instead of requeueing it, just like how
we handle the ->gso_skb right now.

In fact it seems we can just reuse the ->gso_skb Qdisc member for
this purpose.

Then all of the ->requeue() code and resulting complexity can just
go away.
