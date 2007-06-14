From: MOKUNO Masakazu <mokuno@sm.sony.co.jp>
Subject: Re: [PATCH]: ps3: gigabit ethernet driver for PS3
Date: Thu, 14 Jun 2007 21:51:35 +0900
Message-ID: <20070614181415.EB53.MOKUNO@sm.sony.co.jp>
References: <20070613154156.71DB.MOKUNO@sm.sony.co.jp> <46705334.5060001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Geoff Levand <geoffrey.levand@am.sony.com>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:53229 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093AbXFNMvq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 08:51:46 -0400
In-Reply-To: <46705334.5060001@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Thanks for your comment.

I'll fix coding style issues.

On Wed, 13 Jun 2007 16:27:32 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> > --- a/drivers/net/Makefile
> > +++ b/drivers/net/Makefile
> > @@ -60,6 +60,8 @@ obj-$(CONFIG_TIGON3) += tg3.o
> >  obj-$(CONFIG_BNX2) += bnx2.o
> >  spidernet-y += spider_net.o spider_net_ethtool.o
> >  obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
> > +obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
> > +ps3_gelic-objs += gelic_net.o
> >  obj-$(CONFIG_TC35815) += tc35815.o
> >  obj-$(CONFIG_SKGE) += skge.o
> >  obj-$(CONFIG_SKY2) += sky2.o
> 
> How about ps3_gige for the driver name.  Ditto DaveM's comments about 
> cleanups here.

This change was made to work around a module load/unload issue we met.
I'll check again what the issue was and try to avoid the changes here.

ps3_gige.{c,ko} is preferred one than gelic_net.{c,ko}?

> > +static void gelic_net_set_descr_status(struct gelic_net_descr *descr,
> > +				       enum gelic_net_descr_status status)
> > +{
> > +	u32 cmd_status;
> > +
> > +	/* read the status */
> > +	cmd_status = descr->dmac_cmd_status;
> > +	/* clean the upper 4 bits */
> > +	cmd_status &= GELIC_NET_DESCR_IND_PROC_MASKO;
> > +	/* add the status to it */
> > +	cmd_status |= ((u32)status) << GELIC_NET_DESCR_IND_PROC_SHIFT;
> > +	/* and write it back */
> > +	descr->dmac_cmd_status = cmd_status;
> > +	wmb();
> 
> does the wmb() actually do anything useful here?

descr points a descriptor that the ethernet hardware checks.
Since dmac_cmd_status is the field that describes the descriptor is free
or invalid etc., the caller of this function usually wants to talk
something to the hardware.  So I do the synchronization here.


> > +static int gelic_net_prepare_rx_descr(struct gelic_net_card *card,
> > +				      struct gelic_net_descr *descr)
> > +{
> > +	int offset;
> > +	unsigned int bufsize;
> > +
> > +	if (gelic_net_get_descr_status(descr) !=  GELIC_NET_DESCR_NOT_IN_USE) {
> > +		dev_info(ctodev(card), "%s: ERROR status \n", __func__);
> > +	}
> > +	/* we need to round up the buffer size to a multiple of 128 */
> > +	bufsize = (GELIC_NET_MAX_MTU + GELIC_NET_RXBUF_ALIGN - 1) &
> > +		(~(GELIC_NET_RXBUF_ALIGN - 1));
> 
> use ALIGN()?
> 

Nice macro! thanks.

> > +	/* and we need to have it 128 byte aligned, therefore we allocate a
> > +	 * bit more */
> > +	descr->skb = netdev_alloc_skb(card->netdev,
> > +		bufsize + GELIC_NET_RXBUF_ALIGN - 1);
> 
> net_device allocation is already rounded.  and combined with the above 
> code snippet, it appears you're aligning twice
> 

Gelic requies buffer whic is both 128 bytes aligned and multiple of 128
bytes in size.
Does netdev_alloc_skb() guarantee to allocate a skb which has 128byte
aligned buffer?

> > +out:
> > +	if (!stop && release && netif_queue_stopped(card->netdev))
> > +		netif_wake_queue(card->netdev);
> 
> shouldn't need to test netif_queued_stopped() before calling 
> netif_wake_queue(), as netif_wake_queue() essentially already does this

OK, I'll fix

> > +
> > +	/* set multicast address */
> > +	for (mc = netdev->mc_list; mc; mc = mc->next) {
> > +		addr = 0;
> > +		p = mc->dmi_addr;
> > +		for (i = 0; i < ETH_ALEN; i++) {
> > +			addr <<= 8;
> > +			addr |= *p++;
> > +		}
> > +		status = lv1_net_add_multicast_address(bus_id(card), dev_id(card),
> > +				addr, 0);
> > +		if (status)
> > +			dev_err(ctodev(card),
> > +				"lv1_net_add_multicast_address failed, %d\n",
> > +				status);
> > +	}
> 
> this seems not to handle the promisc case

gelic_net driver does not support promisc mode, as the hypervisor does
not support it.

> > +static void gelic_net_disable_txdmac(struct gelic_net_card *card)
> > +{
> > +	int status;
> > +
> > +	/* this hvc blocks until the DMA in progress really stopped */
> > +	status = lv1_net_stop_tx_dma(bus_id(card), dev_id(card), 0);
> > +	if (status)
> > +		dev_err(ctodev(card),
> > +			"lv1_net_stop_tx_dma faild, status=%d\n", status);
> > +}
> 
> do we really need all these three-C-statement functions?

Well, lv1_net_zzz_dma() hypervisor calls are self-descriptive. But
considering the future consolidation with spider_net, I think these
symmetry with spider_net would help.

> > +/**
> > + * gelic_net_xmit - transmits a frame over the device
> > + * @skb: packet to send out
> > + * @netdev: interface device structure
> > + *
> > + * returns 0 on success, <0 on failure
> > + */
> > +static int gelic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
> > +{
> > +	struct gelic_net_card *card = netdev_priv(netdev);
> > +	struct gelic_net_descr *descr = NULL;
> > +	int result;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&card->tx_dma_lock, flags);
> > +
> > +	gelic_net_release_tx_chain(card, 0);
> > +	if (!skb)
> > +		goto kick;
> 
> skb will never be NULL here

OK, I'll fix.

> 
> > +static void gelic_net_pass_skb_up(struct gelic_net_descr *descr,
> > +				 struct gelic_net_card *card)
> > +{
> > +	struct sk_buff *skb;
> > +	struct net_device *netdev;
> > +	u32 data_status, data_error;
> > +
> > +	data_status = descr->data_status;
> > +	data_error = descr->data_error;
> > +	netdev = card->netdev;
> > +	/* unmap skb buffer */
> > +	skb = descr->skb;
> > +	dma_unmap_single(ctodev(card), descr->buf_addr, GELIC_NET_MAX_MTU,
> > +			 DMA_BIDIRECTIONAL);
> 
> why BIDIRECTIONAL?

Thanks for your pointing out. I should use DMA_FROM_DEVICE here. I'll
fix other dma mappings for skb buffer.

> 
> 
> > +	skb->dev = netdev;
> 
> shouldn't be needed anymore with netdev_alloc_skb()

I'll remove.

> > +static int gelic_net_change_mtu(struct net_device *netdev, int new_mtu)
> > +{
> > +	/* no need to re-alloc skbs or so -- the max mtu is about 2.3k
> > +	 * and mtu is outbound only anyway */
> > +	if ((new_mtu < GELIC_NET_MIN_MTU) ||
> > +	    (new_mtu > GELIC_NET_MAX_MTU)) {
> > +		return -EINVAL;
> > +	}
> > +	netdev->mtu = new_mtu;
> 
> no RX filter to change?

It seems to be derived from the based code. I don't think gelic has such
filter feature. so that's ok here.  But I'll check it.


Thank you.

--
Masakazu MOKUNO

