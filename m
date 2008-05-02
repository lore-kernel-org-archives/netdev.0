From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: New driver "sfc" for Solarstorm SFC4000 controller.
Date: Fri, 2 May 2008 11:09:08 -0700
Message-ID: <20080502110908.93c79d81.akpm@linux-foundation.org>
References: <200804301925.m3UJPc72001651@hera.kernel.org>
	<20080501120858.207b6dd6.akpm@linux-foundation.org>
	<20080502160530.GN14219@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54259 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758715AbYEBSJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 14:09:12 -0400
In-Reply-To: <20080502160530.GN14219@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 May 2008 17:05:35 +0100 Ben Hutchings <bhutchings@solarflare.com> wrote:

> > Oh dear, it found
> > 
> > #5617: FILE: drivers/net/sfc/falcon.c:1877:
> > +               if (*(volatile u32 *)dma_done == FALCON_STATS_DONE)
> > 
> > which was naughty of you.  Perhaps this was already discussed in review
> > with the people who actually know what they're talking about.
> 
> There wasn't any specific discussion of this.  Is it wrong?  We want to
> prevent the compiler from caching *dma_done, which is itself written by DMA.

Documentation/volatile-considered-harmful.txt has some dicussion.

> ...
> > > +#define EFX_DRIVER_VERSION	"2.2.0136"
> > 
> > I would suggest that you remove this.  It's just not a useful way of
> > establishing what version of the driver your users are running.  We use the
> > kernel version information for this.
>  
> This is common practice for net drivers.  Maybe we are in our own little
> world on netdev?

That would make it easy for a researcher to work out how often we change a
driver versus how often we increment its private version number.

> > > +static inline int efx_init_rx_buffer_page(struct efx_rx_queue *rx_queue,
> > > +					  struct efx_rx_buffer *rx_buf)
> > > +{
> > > +	struct efx_nic *efx = rx_queue->efx;
> > > +	int bytes, space, offset;
> > > +
> > > +	bytes = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
> > > +
> > > +	/* If there is space left in the previously allocated page,
> > > +	 * then use it. Otherwise allocate a new one */
> > > +	rx_buf->page = rx_queue->buf_page;
> > > +	if (rx_buf->page == NULL) {
> > > +		dma_addr_t dma_addr;
> > > +
> > > +		rx_buf->page = alloc_pages(__GFP_COLD | __GFP_COMP | GFP_ATOMIC,
> > > +					   efx->rx_buffer_order);
> > 
> > I don't think we should be using the open-coded __GFP_COMP here.  That's
> > more an mm-internal thing.
> 
> What's the alternative?

Just remove the __GFP_COMP, I expect.  __GFP_COMP will ask the page
allocator to add extra book-keeping info to the pageframe (via
prep_compound_page()).  I doubt if the driver uses that information.


