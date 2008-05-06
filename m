From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Tue, 6 May 2008 13:50:09 +0100
Message-ID: <20080506125008.GA2217@solarflare.com>
References: <200804301925.m3UJPc72001651@hera.kernel.org> <20080501120858.207b6dd6.akpm@linux-foundation.org> <20080502160530.GN14219@solarflare.com> <20080502110908.93c79d81.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:52897 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753128AbYEFMuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 08:50:52 -0400
Content-Disposition: inline
In-Reply-To: <20080502110908.93c79d81.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Fri, 2 May 2008 17:05:35 +0100 Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > > Oh dear, it found
> > > 
> > > #5617: FILE: drivers/net/sfc/falcon.c:1877:
> > > +               if (*(volatile u32 *)dma_done == FALCON_STATS_DONE)
> > > 
> > > which was naughty of you.  Perhaps this was already discussed in review
> > > with the people who actually know what they're talking about.
> > 
> > There wasn't any specific discussion of this.  Is it wrong?  We want to
> > prevent the compiler from caching *dma_done, which is itself written by DMA.
> 
> Documentation/volatile-considered-harmful.txt has some dicussion.

Looks like we should be using something like:

	while (*dma_done != FALCON_STATS_DONE)
		cpu_relax();

But then how do we time-out?

> > > > +static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
> > > > +					  struct efx_rx_buffer *rx_buf)
> > > > +{
> > > > +	struct efx_nic *efx = rx_queue->efx;
> > > > +	int bytes, space, offset;
> > > > +
> > > > +	bytes = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
> > > > +
> > > > +	/* If there is space left in the previously allocated page,
> > > > +	 * then use it. Otherwise allocate a new one */
> > > > +	rx_buf->page = rx_queue->buf_page;
> > > > +	if (rx_buf->page == NULL) {
> > > > +		dma_addr_t dma_addr;
> > > > +
> > > > +		rx_buf->page = alloc_pages(__GFP_COLD | __GFP_COMP | GFP_ATOMIC,
> > > > +					   efx->rx_buffer_order);
> > > 
> > > I don't think we should be using the open-coded __GFP_COMP here.  That's
> > > more an mm-internal thing.
> > 
> > What's the alternative?
> 
> Just remove the __GFP_COMP, I expect.  __GFP_COMP will ask the page
> allocator to add extra book-keeping info to the pageframe (via
> prep_compound_page()).  I doubt if the driver uses that information.

It looks like this flag was used by mistake, based on past experience with
a driver that needed buffers to be mapped into user space.  The original
author of the RX page-allocation code is away at the moment, so I will
have to wait to ask why he used it.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
