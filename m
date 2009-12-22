From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] wireless: adf702x: new driver for ADF7020/21 parts
Date: Tue, 22 Dec 2009 16:02:09 +0000
Message-ID: <1261497729.2845.8.camel@achroite.uk.solarflarecom.com>
References: <1261447929-17106-1-git-send-email-vapier@gentoo.org>
	 <1261453449.25157.367.camel@localhost>
	 <8A42379416420646B9BFAC9682273B6D0EF11F8A@limkexm3.ad.analog.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org
To: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10790 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbZLVQCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 11:02:13 -0500
In-Reply-To: <8A42379416420646B9BFAC9682273B6D0EF11F8A@limkexm3.ad.analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-12-22 at 11:46 +0000, Hennerich, Michael wrote:
[...]
> >
> >> +	unsigned rx:1;
> >> +	unsigned rx_size;
> >> +	u32 *rx_buf;
> >> +	u32 *tx_buf;
> >> +
> >> +	/* Base reg base of SPORT controller */
> >> +	volatile struct sport_register *sport;
> >
> >MMIO pointers should normally be declared like:
> >
> >	struct sport_register __iomem *sport;
> >
> >and used with readl, writel etc.
> 
> Well SPORT is a SoC peripheral it's mapped into Blackfin System MMR space.
> Our versions of readX writeX are implemented for off-chip peripherals.
> If you take a look at Blackfin io.h you will notice that we disable global interrupts, 
> to avoid killed and reissued reads. This is not necessary for the System MMR space.   
> 
> Preferably I like to keep this as is, but I could also change it to use the 
> Blackfin MMR accessor functions bfin_read{32,16} bfin_write{32,16}  

I don't know any specifics of the Blackfin architecture, so you should
probably do what you think best!

[...]
> >> +static irqreturn_t adf702x_rx_interrupt(int irq, void *dev_id)
> >> +{
> >[...]
> >> +			lp->rx_size = adf702x_getrxsize(lp, offset);
> >> +			if (offset == 1) {
> >> +				set_dma_x_count(lp->dma_ch_rx, lp->rx_size);
> >> +				set_dma_start_addr(lp->dma_ch_rx,
> >> +					(unsigned long)lp->rx_buf);
> >> +			} else {
> >> +				lp->rx_buf[0] = lp->rx_buf[3];
> >> +				set_dma_x_count(lp->dma_ch_rx, lp->rx_size - 1);
> >> +				set_dma_start_addr(lp->dma_ch_rx,
> >> +					(unsigned long)&lp->rx_buf[1]);
> >> +			}
> >> +			enable_dma(lp->dma_ch_rx);
> >> +			SSYNC();
> >
> >Is this some odd kind of memory barrier?
> 
> Well - it's an instruction that ensures that the write buffers are flushed and all instructions executed. 

I suspect you only need a write memory barrier here (wmb()) not a
pipeline flush.

[...]
> >> +	ndev->mtu = 576;
> >
> >Even though you use Ethernet frames?
> 
> We could stick with the default MTU - but it would worsen the overall response time.
[...]

Do what you think is best; I was just checking that you have a good
reason for this.

Ben,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

