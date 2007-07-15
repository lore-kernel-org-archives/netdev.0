From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: [PATCH 1/3] Blackfin ethernet driver: on chip ethernet MAC
	controller driver
Date: Sun, 15 Jul 2007 17:16:56 +0800
Message-ID: <1184491016.3140.52.camel@roc-laptop>
References: <1184438993.3140.23.camel@roc-laptop>
	 <200707142138.36619.mb@bu3sch.de>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, Jeff Garzik <jeff@garzik.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:35304 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbXGOJRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 05:17:09 -0400
In-Reply-To: <200707142138.36619.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-07-14 at 21:38 +0200, Michael Buesch wrote:
> On Saturday 14 July 2007 20:49:53 Bryan Wu wrote:
> > +#if defined(CONFIG_BFIN_MAC_USE_L1)
> > +# define bfin_mac_alloc(dma_handle, size)  l1_data_sram_zalloc(size)
> > +# define bfin_mac_free(dma_handle, ptr)    l1_data_sram_free(ptr)
> > +#else
> > +# define bfin_mac_alloc(dma_handle, size) \
> > +	 dma_alloc_coherent(NULL, size, dma_handle, GFP_DMA)
> 
> You shouldn't be using GFP_DMA here (that's only for legacy ISA-DMA
> memory), but one of GFP_KERNEL or GFP_ATOMIC.
> 

Yes, It should be. Actually, Blackfin dma_alloc_coherent doesn't use the
GFP_DMA flags. 
Just for keepping API compatible, I will change it to GFP_KERNEL.

> > +# define bfin_mac_free(dma_handle, ptr) \
> > +	dma_free_coherent(NULL, sizeof(*ptr), ptr, dma_handle)
> > +#endif
> > +
> 
> > +/* pointers to maintain transmit list */
> > +static struct net_dma_desc_tx *tx_list_head;
> > +static struct net_dma_desc_tx *tx_list_tail;
> > +static struct net_dma_desc_rx *rx_list_head;
> > +static struct net_dma_desc_rx *rx_list_tail;
> > +static struct net_dma_desc_rx *current_rx_ptr;
> > +static struct net_dma_desc_tx *current_tx_ptr;
> > +static struct net_dma_desc_tx *tx_desc;
> > +static struct net_dma_desc_rx *rx_desc;
> 
> Hm, from this I guess only one of these devices is possible
> at a time in the system?
> 
> > +static int desc_list_init(void)
> > +{
> > +	struct net_dma_desc_tx *tmp_desc_tx;
> > +	struct net_dma_desc_rx *tmp_desc_rx;
> > +	int i;
> > +	struct sk_buff *new_skb;
> > +#if !defined(CONFIG_BFIN_MAC_USE_L1)
> > +	dma_addr_t dma_handle;
> > +#endif
> > +
> > +	tx_desc =
> > +	    bfin_mac_alloc(&dma_handle,
> > +			   sizeof(struct net_dma_desc_tx) *
> > +			   CONFIG_BFIN_TX_DESC_NUM);
> > +	if (tx_desc == NULL)
> > +		goto init_error;
> > +
> > +	rx_desc =
> > +	    bfin_mac_alloc(&dma_handle,
> > +			   sizeof(struct net_dma_desc_rx) *
> > +			   CONFIG_BFIN_RX_DESC_NUM);
> 
> You are overriding and throwing dma_handle away, here.
> You might need it later for freeing. (and maybe for other
> purposes, too, like writing the address to a device register?)
> 

You review very carelly, thanks.

In current Blackfin DMA allocation/free, the return value from 
bfin_mac_alloc() is used as the dma_handle, here it is the
tx_desc/rx_desc. 
The "dma_handle" is useless in the following code.

> > +	if (rx_desc == NULL)
> > +		goto init_error;
> > +
> > +	/* init tx_list */
> > +	for (i = 0; i < CONFIG_BFIN_TX_DESC_NUM; i++) {
> > +
> > +		tmp_desc_tx = tx_desc + i;
> > +
> > +		if (i == 0) {
> > +			tx_list_head = tmp_desc_tx;
> > +			tx_list_tail = tmp_desc_tx;
> > +		}
> > +
> > +		tmp_desc_tx->desc_a.start_addr =
> > +		    (unsigned long)tmp_desc_tx->packet;
> > +		tmp_desc_tx->desc_a.x_count = 0;
> > +		/* disabled */
> > +		tmp_desc_tx->desc_a.config.b_DMA_EN = 0;
> > +		/* read from memory */
> > +		tmp_desc_tx->desc_a.config.b_WNR = 0;
> > +		/* wordsize is 32 bits */
> > +		tmp_desc_tx->desc_a.config.b_WDSIZE = 2;
> > +		/* 6 half words is desc size. */
> > +		tmp_desc_tx->desc_a.config.b_NDSIZE = 6;
> > +		/* large desc flow */
> > +		tmp_desc_tx->desc_a.config.b_FLOW = 7;
> > +		tmp_desc_tx->desc_a.next_dma_desc = &(tmp_desc_tx->desc_b);
> > +
> > +		tmp_desc_tx->desc_b.start_addr =
> > +		    (unsigned long)(&(tmp_desc_tx->status));
> > +		tmp_desc_tx->desc_b.x_count = 0;
> > +		/* enabled */
> > +		tmp_desc_tx->desc_b.config.b_DMA_EN = 1;
> > +		/* write to memory */
> > +		tmp_desc_tx->desc_b.config.b_WNR = 1;
> > +		/* wordsize is 32 bits */
> > +		tmp_desc_tx->desc_b.config.b_WDSIZE = 2;
> > +		/* disable interrupt */
> > +		tmp_desc_tx->desc_b.config.b_DI_EN = 0;
> > +		tmp_desc_tx->desc_b.config.b_NDSIZE = 6;
> > +		/* stop mode */
> > +		tmp_desc_tx->desc_b.config.b_FLOW = 7;
> > +		tmp_desc_tx->skb = NULL;
> > +		tx_list_tail->desc_b.next_dma_desc = &(tmp_desc_tx->desc_a);
> > +		tx_list_tail->next = tmp_desc_tx;
> > +
> > +		tx_list_tail = tmp_desc_tx;
> > +	}
> > +	tx_list_tail->next = tx_list_head;	/* tx_list is a circle */
> > +	tx_list_tail->desc_b.next_dma_desc = &(tx_list_head->desc_a);
> > +	current_tx_ptr = tx_list_head;
> > +
> > +	/* init rx_list */
> > +	for (i = 0; i < CONFIG_BFIN_RX_DESC_NUM; i++) {
> > +
> > +		tmp_desc_rx = rx_desc + i;
> > +
> > +		if (i == 0) {
> > +			rx_list_head = tmp_desc_rx;
> > +			rx_list_tail = tmp_desc_rx;
> > +		}
> > +
> > +		/* allocat a new skb for next time receive */
> > +		new_skb = dev_alloc_skb(PKT_BUF_SZ + 2);
> > +		if (!new_skb) {
> > +			printk(KERN_NOTICE CARDNAME
> > +			       ": init: low on mem - packet dropped\n");
> > +			goto init_error;
> > +		}
> > +		skb_reserve(new_skb, 2);
> > +		tmp_desc_rx->skb = new_skb;
> > +		/* since RXDWA is enabled */
> > +		tmp_desc_rx->desc_a.start_addr =
> > +		    (unsigned long)new_skb->data - 2;
> > +		tmp_desc_rx->desc_a.x_count = 0;
> > +		/* enabled */
> > +		tmp_desc_rx->desc_a.config.b_DMA_EN = 1;
> > +		/* Write to memory */
> > +		tmp_desc_rx->desc_a.config.b_WNR = 1;
> > +		/* wordsize is 32 bits */
> > +		tmp_desc_rx->desc_a.config.b_WDSIZE = 2;
> > +		/* 6 half words is desc size. */
> > +		tmp_desc_rx->desc_a.config.b_NDSIZE = 6;
> > +		/* large desc flow */
> > +		tmp_desc_rx->desc_a.config.b_FLOW = 7;
> > +		tmp_desc_rx->desc_a.next_dma_desc = &(tmp_desc_rx->desc_b);
> > +
> > +		tmp_desc_rx->desc_b.start_addr =
> > +		    (unsigned long)(&(tmp_desc_rx->status));
> > +		tmp_desc_rx->desc_b.x_count = 0;
> > +		/* enabled */
> > +		tmp_desc_rx->desc_b.config.b_DMA_EN = 1;
> > +		/* Write to memory */
> > +		tmp_desc_rx->desc_b.config.b_WNR = 1;
> > +		/* wordsize is 32 bits */
> > +		tmp_desc_rx->desc_b.config.b_WDSIZE = 2;
> > +		tmp_desc_rx->desc_b.config.b_NDSIZE = 6;
> > +		/* enable interrupt */
> > +		tmp_desc_rx->desc_b.config.b_DI_EN = 1;
> > +		/* large mode */
> > +		tmp_desc_rx->desc_b.config.b_FLOW = 7;
> > +		rx_list_tail->desc_b.next_dma_desc = &(tmp_desc_rx->desc_a);
> > +
> > +		rx_list_tail->next = tmp_desc_rx;
> > +		rx_list_tail = tmp_desc_rx;
> > +	}
> > +	rx_list_tail->next = rx_list_head;	/* rx_list is a circle */
> > +	rx_list_tail->desc_b.next_dma_desc = &(rx_list_head->desc_a);
> > +	current_rx_ptr = rx_list_head;
> > +
> > +	return 0;
> > +
> > +init_error:
> > +	desc_list_free();
> > +	printk(KERN_ERR CARDNAME ": kmalloc failed\n");
> > +	return -ENOMEM;
> > +}
> > +
> > +static void desc_list_free(void)
> > +{
> > +	struct net_dma_desc_rx *tmp_desc_rx;
> > +	struct net_dma_desc_tx *tmp_desc_tx;
> > +	int i;
> > +#if !defined(CONFIG_BFIN_MAC_USE_L1)
> > +	dma_addr_t dma_handle = 0;
> > +#endif
> > +
> > +	if (tx_desc != NULL) {
> > +		tmp_desc_tx = tx_list_head;
> > +		for (i = 0; i < CONFIG_BFIN_TX_DESC_NUM; i++) {
> > +			if (tmp_desc_tx != NULL) {
> > +				if (tmp_desc_tx->skb) {
> > +					dev_kfree_skb(tmp_desc_tx->skb);
> > +					tmp_desc_tx->skb = NULL;
> > +				}
> > +
> > +			}
> > +			tmp_desc_tx = tmp_desc_tx->next;
> > +		}
> > +		bfin_mac_free(dma_handle, tx_desc);
> 
> dma_handle will always be 0 here. I guess that's a bug.
> Also see my comment on the alloc code, above.
> 

Yes, dma_handle is not used, while tx_desc/rx_desc is.

> > +	}
> > +
> > +	if (rx_desc != NULL) {
> > +		tmp_desc_rx = rx_list_head;
> > +		for (i = 0; i < CONFIG_BFIN_RX_DESC_NUM; i++) {
> > +			if (tmp_desc_rx != NULL) {
> > +				if (tmp_desc_rx->skb) {
> > +					dev_kfree_skb(tmp_desc_rx->skb);
> > +					tmp_desc_rx->skb = NULL;
> > +				}
> > +			}
> > +			tmp_desc_rx = tmp_desc_rx->next;
> > +		}
> > +		bfin_mac_free(dma_handle, rx_desc);
> 
> Same here.
> 
> > +/* Wait until the previous MDC/MDIO transaction has completed */
> > +static void poll_mdc_done(void)
> > +{
> > +	/* poll the STABUSY bit */
> > +	while ((bfin_read_EMAC_STAADD()) & STABUSY) {
> > +	};
> 
> Please add a timeout here, as this could loop forever in case of
> slightly faulty hardware (or firmware, or whatever).
> It's good practice to add a timeout of say 5 seconds to such loops.
> You also might want to sleep between checks (dunno if this is called
> in atomic, though), so an mdelay(10) or something might be desired.
> 
> 

OK, timeout should be added.

> 
> > +/* set up the phy */
> > +static void bf537mac_setphy(struct net_device *dev)
> > +{
> > +	u16 phydat;
> > +	u32 sysctl;
> > +	struct bf537mac_local *lp = netdev_priv(dev);
> > +
> > +	pr_debug("start settting up phy\n");
> 
> settting :)
> 
> > +	/* Program PHY registers */
> > +	phydat = 0;
> 
> No need to zero phydat out, here.
> 
> > +	/* issue a reset */
> > +	raw_write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, 0x8000);
> > +
> > +	/* wait half a second */
> > +	udelay(500);
> 
> First:  500usec != 1/2sec
> Second: 500usec is a lot. You might want to use msleep(1)
>         or msleep(500), if you _really_ want to sleep half a sec.
> 
> > +	phydat = read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
> > +
> > +	/* advertise flow control supported */
> > +	phydat = read_phy_reg(lp->PhyAddr, PHYREG_ANAR);
> > +	phydat |= (1 << 10);
> > +	write_phy_reg(lp->PhyAddr, PHYREG_ANAR, phydat);
> > +
> > +	phydat = 0;
> > +	if (lp->Negotiate) {
> > +		phydat |= 0x1000;	/* enable auto negotiation */
> > +	} else {
> > +		if (lp->FullDuplex) {
> > +			phydat |= (1 << 8);	/* full duplex */
> > +		} else {
> > +			phydat &= (~(1 << 8));	/* half duplex */
> > +		}
> > +		if (!lp->Port10) {
> > +			phydat |= (1 << 13);	/* 100 Mbps */
> > +		} else {
> > +			phydat &= (~(1 << 13));	/* 10 Mbps */
> > +		}
> > +	}
> > +
> > +	if (lp->Loopback) {
> > +		phydat |= (1 << 14);	/* enable TX->RX loopback */
> > +#ifdef DRV_DEBUG
> > +		write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, phydat);
> > +#endif
> > +	}
> > +
> > +	write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, phydat);
> > +	udelay(500);
> 
> See my comment above, about the delay vs sleep.
> 
> > +	phydat = read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
> > +	/* check for SMSC PHY */
> > +	if ((read_phy_reg(lp->PhyAddr, PHYREG_PHYID1) == 0x7) &&
> > +	((read_phy_reg(lp->PhyAddr, PHYREG_PHYID2) & 0xfff0) == 0xC0A0)) {
> 
> Hm, lots of magic values in this function. You should probably
> use #define for better readability.
> 

This is some magic code for PHY ID. In the future, we will rewrite some
code based on kernel phy abstraction layer to support more phy device.

> > +		/*
> > +		 * we have SMSC PHY so reqest interrupt
> > +		 * on link down condition
> > +		 */
> > +
> > +		/* enable interrupts */
> > +		write_phy_reg(lp->PhyAddr, 30, 0x0ff);
> 
> -
> > +		/* enable PHY_INT */
> > +		sysctl = bfin_read_EMAC_SYSCTL();
> > +		sysctl |= 0x1;
> > +#ifdef DRV_DEBUG
> 
> Seems like you can move this #ifdef three lines up.
> 
> > +		bfin_write_EMAC_SYSCTL(sysctl);
> > +#endif
> > +	}
> > +}
> > +
> > +/**************************************************************************/
> > +void setup_system_regs(struct net_device *dev)
> > +{
> > +	int PHYADDR;
> 
> Lowercase, please.
> 
> > +	unsigned short sysctl, phydat;
> > +	u32 opmode;
> > +	struct bf537mac_local *lp = netdev_priv(dev);
> > +	int count = 0;
> > +
> > +	PHYADDR = lp->PhyAddr;
> > +
> > +	/* Enable PHY output */
> > +	if (!(bfin_read_VR_CTL() & PHYCLKOE))
> > +		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
> > +
> > +	/* MDC  = 2.5 MHz */
> > +	sysctl = SET_MDCDIV(24);
> > +	/* Odd word alignment for Receive Frame DMA word */
> > +	/* Configure checksum support and rcve frame word alignment */
> > +#if defined(BFIN_MAC_CSUM_OFFLOAD)
> > +	sysctl |= RXDWA | RXCKS;
> > +#else
> > +	sysctl |= RXDWA;
> > +#endif
> > +	bfin_write_EMAC_SYSCTL(sysctl);
> > +	/* auto negotiation on  */
> > +	/* full duplex          */
> > +	/* 100 Mbps             */
> > +	phydat = PHY_ANEG_EN | PHY_DUPLEX | PHY_SPD_SET;
> > +	write_phy_reg(PHYADDR, PHYREG_MODECTL, phydat);
> > +
> > +	/* test if full duplex supported */
> > +	do {
> > +		msleep(100);
> > +		phydat = read_phy_reg(PHYADDR, PHYREG_MODESTAT);
> > +		if (count > 30) {
> > +			printk(KERN_NOTICE CARDNAME ": Link is down\n");
> > +			printk(KERN_NOTICE CARDNAME
> > +				 "please check your network connection\n");
> > +			break;
> > +		}
> > +		count++;
> > +	} while (!(phydat & 0x0004));
> > +
> > +	phydat = read_phy_reg(PHYADDR, PHYREG_ANLPAR);
> > +
> > +	if ((phydat & 0x0100) || (phydat & 0x0040)) {
> > +		opmode = FDMODE;
> > +	} else {
> > +		opmode = 0;
> > +		printk(KERN_INFO CARDNAME
> > +			": Network is set to half duplex\n");
> > +	}
> > +
> > +#if defined(CONFIG_BFIN_MAC_RMII)
> > +	opmode |= RMII; /* For Now only 100MBit are supported */
> > +#endif
> > +
> > +	bfin_write_EMAC_OPMODE(opmode);
> > +
> > +#ifdef DRV_DEBUG
> > +	bfin_write_EMAC_MMC_CTL(RSTC | CROLL | MMCE);
> > +#endif
> > +	bfin_write_EMAC_MMC_CTL(RSTC | CROLL);
> 
> Is it desired to overwrite it here, or is this a missing #else?
> 
> > +void setup_mac_addr(u8 * mac_addr)
> > +{
> > +	/* this depends on a little-endian machine */
> > +	bfin_write_EMAC_ADDRLO(*(u32 *) & mac_addr[0]);
> > +	bfin_write_EMAC_ADDRHI(*(u16 *) & mac_addr[4]);
> 
> So why not properly code it with leXX_to_cpu?
> It's for free, if it's not needed on your platform.
> 
> > +}
> > +
> > +static void adjust_tx_list(void)
> > +{
> > +	if (tx_list_head->status.status_word != 0
> > +	    && current_tx_ptr != tx_list_head) {
> > +		goto adjust_head;	/* released something, just return; */
> > +	}
> > +
> > +	/*
> > +	 * if nothing released, check wait condition
> > +	 * current's next can not be the head,
> > +	 * otherwise the dma will not stop as we want
> > +	 */
> > +	if (current_tx_ptr->next->next == tx_list_head) {
> > +		while (tx_list_head->status.status_word == 0) {
> > +			udelay(10);
> > +			if (tx_list_head->status.status_word != 0
> > +			    || !(bfin_read_DMA2_IRQ_STATUS() & 0x08)) {
> > +				goto adjust_head;
> > +			}
> 
> Timeout?
> 
> > +		}
> > +		if (tx_list_head->status.status_word != 0) {
> > +			goto adjust_head;
> > +		}
> > +	}
> 
> To me it looks like you are accessing DMA memory without any
> DMA syncing here. Maybe that's not needed on your platform
> and you can access DMA memory directly there, but it's ugly
> and code that properly uses the syncing functions is _much_
> easier to understand.
> 
> > +	return;
> > +
> > +adjust_head:
> > +	do {
> > +		tx_list_head->desc_a.config.b_DMA_EN = 0;
> > +		tx_list_head->status.status_word = 0;
> > +		if (tx_list_head->skb) {
> > +			dev_kfree_skb(tx_list_head->skb);
> > +			tx_list_head->skb = NULL;
> > +		} else {
> > +			printk(KERN_ERR CARDNAME
> > +			       ": no sk_buff in a transmitted frame!\n");
> > +		}
> > +		tx_list_head = tx_list_head->next;
> > +	} while (tx_list_head->status.status_word != 0
> > +		 && current_tx_ptr != tx_list_head);
> > +	return;
> > +
> > +}
> > +
> 
> > +static void bf537mac_rx(struct net_device *dev)
> > +{
> > +	struct sk_buff *skb, *new_skb;
> > +	struct bf537mac_local *lp = netdev_priv(dev);
> > +	unsigned short len;
> > +
> > +	/* allocat a new skb for next time receive */
> 
> Typo, "allocat"
> 
> > +	skb = current_rx_ptr->skb;
> > +	new_skb = dev_alloc_skb(PKT_BUF_SZ + 2);
> > +	if (!new_skb) {
> > +		printk(KERN_NOTICE CARDNAME
> > +		       ": rx: low on mem - packet dropped\n");
> > +		lp->stats.rx_dropped++;
> > +		goto out;
> > +	}
> > +	/* reserve 2 bytes for RXDWA padding */
> > +	skb_reserve(new_skb, 2);
> > +	current_rx_ptr->skb = new_skb;
> > +	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
> > +
> > +#ifdef DRV_DEBUG
> > +	int i;
> 
> This generates a GCC warning.
> 
> > +	if (len >= 64) {
> > +		for (i = 0; i < len; i++) {
> > +			printk(KERN_DEBUG "%.2x-", ((unsigned char *)pkt)[i]);
> 
> Does this even compile? I don't see where "pkt" is defined.
> 
> > +			if (((i % 8) == 0) && (i != 0))
> > +				printk(KERN_DEBUG "\n");
> > +		}
> > +	printk(KERN_DEBUG"\n");
> 
> One more tab indention and a space between KERN_DEBUG and "\n", please.
> 
> > +static void bf537mac_reset(void)
> > +{
> > +	unsigned int opmode;
> > +
> > +	opmode = bfin_read_EMAC_OPMODE();
> > +	opmode &= (~RE);
> > +	opmode &= (~TE);
> > +	/* Turn off the EMAC */
> > +	bfin_write_EMAC_OPMODE(bfin_read_EMAC_OPMODE() & opmode);
> 
> bfin_write_EMAC_OPMODE(opmode);
> would have the same effect, no?
> 
> > +static int __init bf537mac_probe(struct net_device *dev)
> > +{
> > +	struct bf537mac_local *lp = netdev_priv(dev);
> > +	int retval;
> > +
> > +	/* Grab the MAC address in the MAC */
> > +	*(u32 *) (&(dev->dev_addr[0])) = bfin_read_EMAC_ADDRLO();
> > +	*(u16 *) (&(dev->dev_addr[4])) = (u16) bfin_read_EMAC_ADDRHI();
> 
> Endianess broken.
> 
> > +	setup_mac_addr(dev->dev_addr);
> > +
> > +	/* Fill in the fields of the device structure with ethernet values. */
> > +	ether_setup(dev);
> > +
> > +	dev->open = bf537mac_open;
> > +	dev->stop = bf537mac_close;
> > +	dev->hard_start_xmit = bf537mac_hard_start_xmit;
> > +	dev->tx_timeout = bf537mac_timeout;
> > +	dev->get_stats = bf537mac_query_statistics;
> > +	dev->set_multicast_list = bf537mac_set_multicast_list;
> > +#ifdef DVR_DEBUG
> 
> Typo, "DVR".
> But why only use ethtool when debugging?
> 
> > +	dev->ethtool_ops = &bf537mac_ethtool_ops;
> > +#endif
> > +#ifdef CONFIG_NET_POLL_CONTROLLER
> > +	dev->poll_controller = bf537mac_poll;
> > +#endif
> 
> > +	/* Enable PHY output early */
> > +	if (!(bfin_read_VR_CTL() & PHYCLKOE))
> > +		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
> > +
> > +	retval = register_netdev(dev);
> > +	if (retval == 0) {
> > +		/* now, print out the card info, in a short format.. */
> > +		printk(KERN_INFO "Blackfin mac net device registered\n");
> > +	}
> 
> Unwind the allocations above, if registering fails.
> 

In fact, it is safe. Because if registering fails, bf537mac_probe will
return none zero to bfin_mac_probe which will do free_netdev.

> > +
> > +err_out:
> > +	return retval;
> > +}
> 
> 
> > +struct dma_config_reg {
> > +	unsigned short b_DMA_EN:1;  /* Bit 0 : DMA Enable */
> > +	unsigned short b_WNR:1;     /* Bit 1 : DMA Direction */
> > +	unsigned short b_WDSIZE:2;  /* Bit 2 & 3 : DMA Tranfer Word size */
> > +	unsigned short b_DMA2D:1;   /* Bit 4 : DMA Mode 2D or 1D */
> > +	unsigned short b_RESTART:1; /* Bit 5 : Retain the FIFO */
> > +	unsigned short b_DI_SEL:1;  /* Bit 6 : Data Interrupt Timing Select */
> > +	unsigned short b_DI_EN:1;   /* Bit 7 : Data Interrupt Enable */
> > +	unsigned short b_NDSIZE:4;  /* Bit 8 to 11 : Flex descriptor Size */
> > +	unsigned short b_FLOW:3;    /* Bit 12 to 14 : FLOW */
> > +};
> 
> This is most likely not endianess safe.
> 

I will remove the bitfield code first as Jeff described. Mike is right,
as this is on-chip mac controller, it is always little endian.

A new version driver will be sent later for review.

Thanks a lot
- Bryan Wu
