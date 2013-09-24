From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 21:42:15 +0200
Message-ID: <20130924194215.GA4446@order.stressinduktion.org>
References: <20130924023038.GA22393@order.stressinduktion.org> <20130924033505.GB22393@order.stressinduktion.org> <1380001118.3165.41.camel@edumazet-glaptop> <20130924160145.GB26769@order.stressinduktion.org> <1380039299.3165.91.camel@edumazet-glaptop> <CA+mtBx9u3-mnULxTwyWAZA4gZ6Dg-PeYYVGZibwQi7toinHJ-A@mail.gmail.com> <1380041185.3165.97.camel@edumazet-glaptop> <CA+mtBx_tWS44q8jER+QtR5k4k2ieq99He6YdPF8KKBF4Z2+32w@mail.gmail.com> <1380044075.3165.108.camel@edumazet-glaptop> <CA+mtBx8PJj1HgaoiOoJjQL6VmU4Rn7ctBpscr1YxpfrWW9VSbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48438 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751Ab3IXTmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 15:42:20 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx8PJj1HgaoiOoJjQL6VmU4Rn7ctBpscr1YxpfrWW9VSbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 11:02:11AM -0700, Tom Herbert wrote:
> On Tue, Sep 24, 2013 at 10:34 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2013-09-24 at 10:03 -0700, Tom Herbert wrote:
> >> On Tue, Sep 24, 2013 at 9:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> > On Tue, 2013-09-24 at 09:35 -0700, Tom Herbert wrote:
> >> >
> >> >> We should really be using rxhash for that anyway, eliminate this
> >> >> ehashfn.  This would entail adding rxhash argument in the various
> >> >> udp_lookup functions.
> >> >
> >> > Nope : Some NICs provide UDP rxhash only using L3  (source IP,
> >> > destination IP), not L4 (adding source & destination ports)
> >> >
> >> Then the NIC won't set l4_rxhash and we'll rehash over 4-tuple when
> >> skb_get_rxhash is called.
> >
> > Yes, but then in this case you add cpu cycles for no reason.
> >
> > If you have multiqueue NIC, you do not use RPS/RFS, so skb->rxhash might
> > be 0
> >
> > hash = inet_ehashfn(net, daddr, hnum, saddr, sport);
> >
> > is faster than the whole flow dissection game.
> >
> But if we already have valid l4_rxhash we're just wasting time
> recomputing it (very like the same value).  So just do:
> 
> if (skb->l4_hash)
>     hash = skb->rxhash
> else
>     hash = inet_ehashfn(net, daddr, hnum, saddr, sport);
> 
> Even if we go the inet_ehashfn route in the packet, it's makes sense
> to store this in skb->rxhash so that subsequent functions don't need
> to compute the hash
> 
> By the way, I believe there is an insidious in using the same hash
> value or even related hash values in multiple places for steering.
> Since we typically do something like hash % numqueues, we introduce
> bias if multiple steering levels look at the same bits.  With
> SO_REUSEPORT this might actually be beneficial since we could get port
> selection to match RSS locality, but this is not by design!

Wouldn't this also need infrastructure to sync the keys over multiple network
cards to have best benefits?
