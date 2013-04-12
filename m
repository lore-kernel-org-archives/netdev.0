From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Fri, 12 Apr 2013 12:02:55 +0200
Message-ID: <1819986.PZkH8CJNCQ@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1484183.xQu1D8fy8A@linux-5eaq.site> <CACVXFVNyRYzk1Le+QaJr-nnbDCsGqWtx-VJ5X-K6np1+gLzRpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:38561 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab3DLKCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 06:02:11 -0400
In-Reply-To: <CACVXFVNyRYzk1Le+QaJr-nnbDCsGqWtx-VJ5X-K6np1+gLzRpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 12 April 2013 17:42:46 Ming Lei wrote:
> On Fri, Apr 12, 2013 at 2:37 PM, Oliver Neukum <oliver@neukum.org> wrote:
> >> The work will complete when memory is reclaimed, and the rx/tx path is
> >> still working, so memory reclaim can continue and the deadlock may not
> >> be caused, may it?
> >
> > Only if the memory allocation goes to the same interface. If the blocking interface
> > is storage, something bad happens (data loss not deadlock)
> 
> OK, got it, it should be both since reset can't move on, so
> memory reclaim can't complete to satisfy the allocation.
> 
> But I am wondering if it is a case which is worth the consideration.

The remedy is close to trivial, so yes.

> Almost all USB probe() allocate memory with GFP_KERNEL, then
> the similar scenario(data loss only this time) might happen too. Do we
> need to fix all USB drivers?

No. We assume that probing happens before the interfaces are used.
Furthermore, if this turns out to be real, we can reuse your fix for the
general (w.o. work queue) reset case.

> Wrt. the usbnet_status_start() API, looks no good reason to call
> it in another queue context, it should be enough to call it in probe() or
> bind() if init_status() can be put before info->bind() in usbnet_probe().

We are talking about a generic helper. And the fix is really simple.
We just pass mem_flags and all is well. If the API can be made better
at next to no cost, we do it.

> Then looks the mem_flags isn't needed in both cases, and we should
> always take GFP_NOIO inside the API?

We cannot. GFP_ATOMIC may be needed. And no, we atre not going to
unconditionally use GFP_ATOMIC :-;

	Regards
		Oliver
