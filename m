From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] sky2: Fix WARNING: at lib/dma-debug.c:902 check_sync
Date: Wed, 3 Feb 2010 10:18:39 +0900
Message-ID: <20100203101817Z.fujita.tomonori@lab.ntt.co.jp>
References: <20100121184158.GA3085@del.dom.local>
	<20100122141018D.fujita.tomonori@lab.ntt.co.jp>
	<20100121.223841.145479578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, jarkao2@gmail.com,
	alan@lxorguk.ukuu.org.uk, shemminger@linux-foundation.org,
	mbreuer@majjas.com, akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mchan@broadcom.com, pcnet32@verizon.net, romieu@fr.zoreil.com,
	mcarlson@broadcom.com, James.Bottomley@suse.de
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100121.223841.145479578.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the late reply,

On Thu, 21 Jan 2010 22:38:41 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Date: Fri, 22 Jan 2010 14:11:29 +0900
> 
> > Even if 'offset' is zero, 'size' still matters, I think. If 'size' is
> > not a multiple of the cache line size, it's possible that driver
> > writers who aren't familiar with cache would be surprised (it depends
> > on the way their drivers use buffers though).
> > 
> > The easiest way for 'completely safe sync for any driver writers' is
> > asking for all the sync parameters must be the same as those passed
> > into the single mapping API. If writes knows what they do, they can do
> > a partial sync with sync_range API. That's the author intention, I
> > guess.
> 
> This is not reasonable.
> 
> You have to think about how people actually use these
> interfaces.
> 
> They have a large buffer, and if they receive a small request they
> want to allocate a smaller buffer, copy into that smaller buffer, and
> give the larger buffer back to the hardware.
> 
> It's an optimization, it performs better this way.
> 
> If you make it so that the DMA sync has to cover the entire large
> buffer, the whole point of the optimization is taken away.

I talked with James. He is ok with changing (or fixing) this API to
enable users to do a partial sync (I'm ok with that too. I just
guessed that he designed the API in such way intentionally not by
mistake).

Can we safely assume that the arch implementations already round
up/down to the safe boundary internally in this API (they should
already)?

As you know, the patch to remove the description of
dma_sync_single/pci_dma_sync_single/dma_sync_sg/pci_dma_sync_pci that
always require a full sync in DMA-API.txt is already -mm so what we
need to do are:

- adding 'a partial sync' description to PCI-DMA-mapping.txt.
- duplicating the similar description to DMA-API.txt.

I don't like two DMA docs. I like to make pci_dma_* API obsolete. We
have the generic DMA API with generic devices so we are always able to
use the API (as you did with sbus_map_*). The majority arch
implementations safely call the bus specific DMA functions via the
generic DMA API. So there are not many things to do. We can just
convert pci_dma_* to dma_* API slowly.

Opinions?
