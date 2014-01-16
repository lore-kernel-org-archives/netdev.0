From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/2] r6040: use ETH_ZLEN instead of MISR for
 SKB length checking
Date: Thu, 16 Jan 2014 17:33:24 +0000
Message-ID: <1389893604.11912.47.camel@bwh-desktop.uk.level5networks.com>
References: <1389819866-32142-1-git-send-email-florian@openwrt.org>
	 <1389819866-32142-3-git-send-email-florian@openwrt.org>
	 <1389857001.19462.33.camel@deadeye.wl.decadent.org.uk>
	 <063D6719AE5E284EB5DD2968C1650D6D45D812@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Ben Hutchings' <ben@decadent.org.uk>,
	Florian Fainelli <florian@openwrt.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32644 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaAPRd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 12:33:29 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D45D812@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 09:10 +0000, David Laight wrote:
> From: Ben Hutchings
> > On Wed, 2014-01-15 at 13:04 -0800, Florian Fainelli wrote:
> > > Ever since this driver was merged the following code was included:
> ...
> > > -	if (skb->len < MISR)
> > > -		descptr->len = MISR;
> > > +	if (skb->len < ETH_ZLEN)
> > > +		descptr->len = ETH_ZLEN;
> > 
> > It looks like this is just increasing the TX descriptor length so the
> > packet is tail-padded with whatever happens to come next in the skb.
> > This is absolutely incorrect behaviour and may leak sensitive
> > information.
> 
> And possibly page fault if the data is right at the end of a page.

If the CPU was accessing it, it would be fine as the skb linear area
ends with struct skb_shared_info.  (sfc actually takes advantage of that
in efx_enqueue_skb_pio() which can add padding (*not* transmitted) to
ensure that the CPU does write-combining.)

But the NIC, if it's connected through an IOMMU, might get a page fault
due to the incorrect length of the DMA mapping.

> > Presumably it is necessary to pad the frame because the MAC is too lame
> > to do it, and the correct way to do that is using skb_padto(skb,
> > ETH_ZLEN).  But this may fail as it might have to allocate memory
> 
> Alternatively use two ring entries with the 'more' bit set on
> the first one and transmit the padding from a permanently allocated
> and dma-mapped block of zeros.
> Assuming the hardware support SG transmit and doesn't have a
> constraint on the length of the first fragment.

Do you see NETIF_F_SG in this driver?

Ben.

> Or have a pre-allocated an dma-mapped array of short buffers (one
> for each ring slot) and copy short packets into the array instead
> of dma-mapping the skb data.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
