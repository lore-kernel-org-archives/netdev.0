From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Wed, 19 Sep 2012 21:18:57 +0100
Message-ID: <1348085937.2636.54.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120917.121243.1665284878800146060.davem@davemloft.net>
	 <1347901326.26523.149.camel@edumazet-glaptop>
	 <1347901493.26523.151.camel@edumazet-glaptop>
	 <20120917.130732.1894375657044880827.davem@davemloft.net>
	 <1348067659.26523.949.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11848 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751454Ab2ISUTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 16:19:01 -0400
In-Reply-To: <1348067659.26523.949.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 17:14 +0200, Eric Dumazet wrote:
> On Mon, 2012-09-17 at 13:07 -0400, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Mon, 17 Sep 2012 19:04:53 +0200
> > 
> > > On Mon, 2012-09-17 at 19:02 +0200, Eric Dumazet wrote:
> > > 
> > >> A driver already exports a dev->gso_max_size, dev->gso_max_segs, I guess
> > >> it could export a dev->max_seg_order (default to 0)
> > > 
> > > Oh well, if we use a per thread order-3 page, a driver wont define an
> > > order, but the max size of a segment (dev->max_seg_size).
> > 
> > Since you said that your audit showed that most can handle arbitrary
> > segment sizes, it's better to default to infinity or similar.
> > 
> > Otherwise we'll have to annotate almost every single driver with a
> > non-zero value, that's not an efficient way to handle this and
> > deploy the higher performance quickly.
> 
> I did some tests and got no problem so far, even using splice() [ this
> one was tricky because it only deals with order-0 pages at this moment ]
> 
> NIC tested : ixgbe, igb, bnx2x, tg3, mellanox mlx4

I think sfc would also be fine with this; we split at 4K boundaries
regardless of the host page size.

My only concern is fragmentation on busy machines making high-order
allocations more prone to failure (though this change might well slow
that fragmentation).  The larger allocation size should at least be made
dependent on (sk->sk_allocation & GFP_KERNEL) == GPF_KERNEL.  (Even
then, I've seen some stress test failures where ring reallocation
(similar size, GFP_KERNEL) fails.  But those were done with an older
kernel version and the current mm should do better.)

Ben.

> On loopback, performance of netperf goes from 31900 Mb/s to 38500 Mb/s,
> thats a 20 % increase.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
