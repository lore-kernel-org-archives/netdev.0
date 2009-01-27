From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Mon, 26 Jan 2009 22:10:56 -0800 (PST)
Message-ID: <20090126.221056.174077798.davem@davemloft.net>
References: <20090120103122.GC9167@ioremap.net>
	<20090126082036.GB4183@ff.dom.local>
	<20090126212130.GA4338@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, herbert@gondor.apana.org.au, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43714
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750717AbZA0GK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 01:10:59 -0500
In-Reply-To: <20090126212130.GA4338@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Tue, 27 Jan 2009 00:21:30 +0300

> Hi Jarek.
> 
> On Mon, Jan 26, 2009 at 08:20:36AM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> > > 1. Network (tree) allocator
> > > http://www.ioremap.net/projects/nta
> > 
> > I looked at this a bit, but alas I didn't find much for this Herbert's
> > idea of payload in fragments/pages. Maybe some kind of API RFC is
> > needed before this resurrection?
> 
> Basic idea is to steal some (probably a lot) pages from the slab
> allocator and put network buffers there without strict need for
> power-of-two alignment and possible wraps when we add skb_shared_info at
> the end, so that old e1000 driver required order-4 allocations for the
> jumbo frames. We can do that in alloc_skb() and friends and put returned
> buffers into skb's fraglist and updated reference counters for those
> pages; and with additional copy of the network headers into skb->head.

We are going back and forth saying the same thing, I think :-)
(BTW, I think NTA is cool and we might do something like that
eventually)

The basic thing we have to do is make the drivers receive into
pages, and then slide the network headers (only) into the linear
SKB data area.

Even for drivers like NIU and myri10ge that do this, they only
use heuristics or some fixed minimum to decide how much to
move to the linear area.

Result?  Some data payload bits end up there because it overshoots.

Since we have pskb_may_pull() calls everywhere necessary, which
means not in eth_type_trans(), we could just make these drivers
(and future drivers converted to operate in this way) only
put the ethernet headers there initially.

Then the rest of the stack will take care of moving the network
and transport payloads there, as necessary.

I bet it won't even hurt latency or routing/firewall performance.

I did test this with the NIU driver at one point, and it did not
change TCP latency nor throughput at all even at 10g speeds.
