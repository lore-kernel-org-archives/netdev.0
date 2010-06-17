From: James Bottomley <JBottomley@Novell.com>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Wed, 16 Jun 2010 23:20:38 -0500
Message-ID: <1276748438.2847.1190.camel@mulgrave.site>
References: <C27F8246C663564A84BB7AB3439772421B79CBCA1C@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Mike Frysinger' <vapier@gentoo.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B79CBCA1C@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-06-16 at 20:53 -0700, Michael Chan wrote:
> Mike Frysinger wrote:
> 
> > On Wed, Jun 16, 2010 at 9:13 PM, James Bottomley wrote:
> > > I'm not quite sure whose fault this one is.
> > >
> > > However, this code in bnx2.c:
> > >
> > >                if (!get_dma_ops(&pdev->dev)->sync_single_for_cpu) {
> > >                        next_rx_buf =
> > >                                &rxr->rx_buf_ring[
> > >                                        RX_RING_IDX(NEXT_RX_BD(sw_cons))];
> > >                        prefetch(next_rx_buf->desc);
> > >                }
> > >
> > > Looks remarkably fragile: what exactly is it trying to do?
> 
> If sync_single is not defined, that means the CPU has a consistent
> view of next_rx_buf and so it makes sense to prefetch it.

That's not entirely a correct statement.  Many architectures make a DMA
area coherent by turning off the CPU cache over it.  In that case,
prefetching makes absolutely no sense (although it usually works but is
a nop).

> > > The commit that causes the problem:
> > >
> > > commit a33fa66bcf365ffe5b79d1ae1d3582cc261ae56e
> > > Author: Michael Chan <mchan@broadcom.com>
> > > Date:   Thu May 6 08:58:13 2010 +0000
> > >
> > >    bnx2: Add prefetches to rx path.
> > >
> > > Looks fairly innocuous by the description.
> > >
> > > Should parisc have a get_dma_ops()?  We don't need one
> > because our dma
> > > ops are per platform not per bus.
> >
> > looks like it'll be broken on more than just parisc:
> > $ grep get_dma_ops arch/*/include/asm/ -rl | cut -d/ -f 2
> > alpha
> > ia64
> > microblaze
> > powerpc
> > sh
> > sparc
> > x86
> 
> Most of these archs use the dma functions in:
> 
> <asm-genric/dma-mapping-common.h>
> 
> so it's not a problem.

Parisc begs to differ.

Plus you're making assumptions about the contents of the ops structure
which is an internal architecture object ... that's bound to run into
portability problems even if we make it compile on all platform.

> I think I'll send in a patch to remove that part of the code
> from bnx2.c for now.

I think that's the best solution.

James


