From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Fri, 22 Jan 2010 14:11:29 +0900
Message-ID: <20100122141018D.fujita.tomonori@lab.ntt.co.jp>
References: <20100120225322.GC3072@del.dom.local>
	<20100122002053X.fujita.tomonori@lab.ntt.co.jp>
	<20100121184158.GA3085@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, alan@lxorguk.ukuu.org.uk,
	davem@davemloft.net, shemminger@linux-foundation.org,
	mbreuer@majjas.com, akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mchan@broadcom.com, pcnet32@verizon.net, romieu@fr.zoreil.com,
	mcarlson@broadcom.com, James.Bottomley@suse.de
To: jarkao2@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751778Ab0AVFMj@vger.kernel.org>
In-Reply-To: <20100121184158.GA3085@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Jan 2010 19:41:58 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Fri, Jan 22, 2010 at 12:22:10AM +0900, FUJITA Tomonori wrote:
> > On Wed, 20 Jan 2010 23:53:22 +0100
> > Jarek Poplawski <jarkao2@gmail.com> wrote:
> > 
> > > On Wed, Jan 20, 2010 at 10:24:14PM +0000, Alan Cox wrote:
> > > > > > Seems like an underlying bug in the DMA api. Maybe it just can't
> > > > > > handle operations on partial mapping.
> > > > > > 
> > > > > > Other drivers with same problem:
> > > > > >   bnx2, cassini, pcnet32, r8169, rrunner, skge, sungem, tg3, 
> > > > > 
> > > > > It seems using the same length (even without pci_unmap_len()) is
> > > > > crucial here, but I hope maintainers (added to CC) will take care.
> > > > 
> > > > The API needs fixing - if you've got a large mapping and you want to sync
> > > > part of it then we need to support that. Now it might well be that the
> > > > implementation on some braindead platform has to sync the entire thing,
> > > > and some implementations entire pages or cache lines.
> > > > 
> > > > You can't fix this in the drivers, they requested a service and they
> > > > don't have enough information nor is it their job to know about all the
> > > > platform specific rules.
> > > 
> > > Yes, the need to repeat some other values if there is a dedicated
> > > structure/pointer could be misleading. Btw, it seems to be a trivial
> > > overlooking since there is dma_sync_single_range() ready to use.
> > 
> > Yeah, dma_sync_single_range() enables you to do a partial sync. But
> > you must be really careful with a partial sync (as DMA-API.txt says).
> 
> Actually, we are trying to establish here (and a few more netdev@
> threads) what exactly the author was worried about. After looking at

James added to Cc,


> some implementations it seems to me this carefullness in observing
> the cache alignment and width is needed only wrt. the 'offset'. But
> then, the way the 'size' is used (or rather not used for anything
> crucial) suggests dma_sync_single_range() with zero offset seems
> completely safe. But then it's equivalent to dma_sync_single() with

Even if 'offset' is zero, 'size' still matters, I think. If 'size' is
not a multiple of the cache line size, it's possible that driver
writers who aren't familiar with cache would be surprised (it depends
on the way their drivers use buffers though).

The easiest way for 'completely safe sync for any driver writers' is
asking for all the sync parameters must be the same as those passed
into the single mapping API. If writes knows what they do, they can do
a partial sync with sync_range API. That's the author intention, I
guess.
