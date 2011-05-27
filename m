From: "Guan Xuetao" <gxt@mprc.pku.edu.cn>
Subject: RE: [PATCH 2/6] unicore32: add pkunity-v3 mac/net driver (umal)
Date: Fri, 27 May 2011 12:27:24 +0800
Message-ID: <006b01cc1c26$62159ba0$2640d2e0$@mprc.pku.edu.cn>
References: <cover.1306408804.git.gxt@mprc.pku.edu.cn>	 <556924396ee34f4af94a2f03767973f1cec35e22.1306408804.git.gxt@mprc.pku.edu.cn> <1306432569.17233.123.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <arnd@arndb.de>, <linux-kernel@vger.kernel.org>,
	<linux-arch@vger.kernel.org>, <greg@kroah.com>,
	<netdev@vger.kernel.org>
To: "'Ben Hutchings'" <bhutchings@solarflare.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1306432569.17233.123.camel@localhost>
Content-Language: zh-cn
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> Sent: Friday, May 27, 2011 1:56 AM
> To: GuanXuetao
> Cc: arnd@arndb.de; linux-kernel@vger.kernel.org; linux-arch@vger.kernel.org; greg@kroah.com; netdev@vger.kernel.org
> Subject: Re: [PATCH 2/6] unicore32: add pkunity-v3 mac/net driver (umal)
> 
> On Thu, 2011-05-26 at 11:36 +0000, GuanXuetao wrote:
> [...]
> > --- /dev/null
> > +++ b/drivers/net/mac-puv3.c
> [...]
> > +/**********************************************************************
> > + *  Simple types
> > + ********************************************************************* */
> > +enum umal_speed {
> > +	umal_speed_none = 0,
> > +	umal_speed_10 = SPEED_10,
> > +	umal_speed_100 = SPEED_100,
> > +	umal_speed_1000 = SPEED_1000,
> > +};
> 
> Just use the numbers directly: 0, 10, 100, 1000.
Applied.
> 
> [...]
> > +#define ETHER_ADDR_LEN		6
> 
> This is already called ETH_ALEN.
Applied.
> 
> [...]
> > +/**********************************************************************
> > + *  DMA Descriptor structure
> > + ********************************************************************* */
> > +struct umaldmadscr {
> > +	dma_addr_t   PacketStartAddr;
> > +	int          PacketSize;
> > +	dma_addr_t   NextDescriptor;
> > +	struct umaldmadscr *NextDescriptor_Virt;
> > +};
> 
> Linux naming convention for structure fields is words_with_underscores
> not TitleCase.
Ok, thanks.
> 
> [...]
> > +/**********************************************************************
> > + *  UMAL_MII_RESET(bus)
> > + *
> > + *  Reset MII bus.
> > + *
> > + *  Input parameters:
> > + *	   bus     - MDIO bus handle
> > + *
> > + *  Return value:
> > + *	   0 if ok
> > + ********************************************************************* */
> 
> Function documentation comments must follow the kernel-doc format.
Ok, thanks.
> 
> [...]
> > +static int umaldma_add_rcvbuffer(struct umal_softc *sc, struct umaldma *d,
> > +		struct sk_buff *sb)
> > +{
> [...]
> > +	/*
> > +	 * Allocate a sk_buff if we don't already have one.
> > +	 * If we do have an sk_buff, reset it so that it's empty.
> > +	 *
> > +	 * Note: sk_buffs don't seem to be guaranteed to have any sort
> > +	 * of alignment when they are allocated.  Therefore, allocate enough
> > +	 * extra space to make sure that:
> > +	 *
> > +	 *    1. the data does not start in the middle of a cache line.
> > +	 *    2. The data does not end in the middle of a cache line
> > +	 *    3. The buffer can be aligned such that the IP addresses are
> > +	 *       naturally aligned.
> > +	 *
> > +	 *  Remember, the SOCs MAC writes whole cache lines at a time,
> > +	 *  without reading the old contents first.  So, if the sk_buff's
> > +	 *  data portion starts in the middle of a cache line, the SOC
> > +	 *  DMA will trash the beginning (and ending) portions.
> > +	 */
> > +	if (sb == NULL) {
> > +		sb_new = netdev_alloc_skb(dev, ENET_PACKET_SIZE +
> > +		       SMP_CACHE_BYTES * 2 + NET_IP_ALIGN);
> > +		if (sb_new == NULL) {
> > +			pr_info("%s: sk_buff allocation failed\n",
> > +			       d->umaldma_eth->umal_dev->name);
> > +			return -ENOBUFS;
> 
> Surely -ENOMEM.
Applied.
> 
> > +		}
> > +		skb_reserve(sb_new, 2);
> 
> This presumably needs to be:
> 
> 		skb_reserve(sb_new, SMP_CACHE_BYTES + NET_IP_ALIGN);
> 
> unless you assume that the skb allocator will always ensure cache line
> alignment (in which case, why use padding of SMP_CACHE_BYTES * 2?).
Applied, thanks.
Each packet address needs to be added by NET_IP_ALIGN.
And I think that SMP_CACHE_BYTES is also necessary to guarantee correctness
when invalidate dma cache lines.
> 
> [...]
> > +static void umaldma_tx_process(struct umal_softc *sc, struct umaldma *d,
> > +		int poll)
> > +{
> > +	struct net_device *dev = sc->umal_dev;
> > +	int curidx;
> > +	int hwidx;
> > +	struct umaldmadscr *dsc;
> > +	struct sk_buff *sb;
> > +	unsigned long flags;
> > +	int packets_handled = 0;
> > +	unsigned int int_status;
> > +
> > +	spin_lock_irqsave(&(sc->umal_lock), flags);
> > +
> > +	if (!netif_device_present(dev))
> > +		return;
> [...]
> 
> This returns with the lock held!
Applied, thanks.
> 
> (This is not by any means a thorough review.)
> 
> Ben.
> 
> --
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
Thanks Ben.
I will submit next version after correcting the coding-style.

Guan Xuetao 
