From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Subject: Re: lockdep question (was Re: IPoIB caused a kernel: BUG: softlockup
	detected on CPU#0!)
Date: Mon, 12 Mar 2007 16:20:13 +0200
Message-ID: <20070312142013.GC21643@mellanox.co.il>
References: <45E552FC.4040305@mellanox.co.il>
	<f8ca0a150703030937u61bcd9aj200415b76c00d151@mail.gmail.com>
	<20070311135051.GA31985@mellanox.co.il>
	<1173626719.5182.10.camel@lappy>
	<20070311161231.GC13817@mellanox.co.il>
	<20070311184819.GA2567@elte.hu>
	<20070312132826.GB20549@mellanox.co.il>
	<20070312135112.GA18158@elte.hu>
Reply-To: "Michael S. Tsirkin" <mst@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org, Roland Dreier <rdreier@cisco.com>,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:2522 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965871AbXCLOTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 10:19:33 -0400
Received: by mu-out-0910.google.com with SMTP id g7so2056285muf
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 07:19:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070312135112.GA18158@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Quoting Ingo Molnar <mingo@elte.hu>:
> Subject: Re: lockdep question (was Re: IPoIB caused a kernel: BUG: softlockup detected on CPU#0!)
> 
> 
> * Michael S. Tsirkin <mst@mellanox.co.il> wrote:
> 
> > > could you turn on CONFIG_SLAB_DEBUG as well?
> > > 
> > > that should catch certain types of use-after-free accesses, and 
> > > lockdep will also warn if a still locked object is freed.
> > 
> > Hmm, no, this does not look like use-after-free. I enabled 
> > CONFIG_SLAB_DEBUG, and I still see the same message, so the memory was 
> > not overwritten by slab debugger.
> 
> that's still not conclusive - the memory might not have been allocated 
> by slab again to detect it. Your magic-number check definitely shows 
> some sort of corruption going on, right?

Not necessarily in such a direct way.

I currently think we are somehow getting neighbours where
neigh->dev points to a loopback device - that's type 772,
and this seems to make sense.
I printed out the device name and sure enough it is "lo".

Is it true that sticking the following

static int ipoib_neigh_setup_dev(struct net_device *dev,
				 struct neigh_parms *parms)
{
	parms->neigh_destructor = ipoib_neigh_destructor;

	return 0;
}

in dev->neigh_setup, as ipoib does, guarantees that neighbour->dev will point to
the current device for any neighbour which ipoib_neigh_destructor gets?

That's the assumption IPoIB makes, and it seems broken in this instance.

How could that be?

-- 
MST
