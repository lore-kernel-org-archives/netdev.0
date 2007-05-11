From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 05/13] Blackfin: on-chip ethernet MAC controller driver
Date: Fri, 11 May 2007 17:16:57 -0400
Message-ID: <4644DD49.9040306@garzik.org>
References: <200705110552.l4B5qrPn007804@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org, bryan.wu@analog.com,
	luke.yang@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42962 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760049AbXEKVRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 17:17:02 -0400
In-Reply-To: <200705110552.l4B5qrPn007804@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> +/* pointers to maintain transmit list */
> +static struct net_dma_desc_tx *tx_list_head;
> +static struct net_dma_desc_tx *tx_list_tail;
> +static struct net_dma_desc_rx *rx_list_head;
> +static struct net_dma_desc_rx *rx_list_tail;
> +static struct net_dma_desc_rx *current_rx_ptr;
> +static struct net_dma_desc_tx *current_tx_ptr;
> +static struct net_dma_desc_tx *tx_desc;
> +static struct net_dma_desc_rx *rx_desc;

these should not be global variables.  At a minimum, they should (a) be 
in a per-interface (or per-device) private structure or (b) encapsulated 
in a structure, then exported as a single global variable.


> +static int desc_list_init(void)
> +{
> +	struct net_dma_desc_tx *tmp_desc_tx;
> +	struct net_dma_desc_rx *tmp_desc_rx;
> +	int i;
> +	struct sk_buff *new_skb;
> +#if !defined(CONFIG_BFIN_MAC_USE_L1)
> +	dma_addr_t dma_handle;
> +#endif
> +
> +	tx_desc =
> +	    bfin_mac_alloc(&dma_handle,
> +			   sizeof(struct net_dma_desc_tx) *
> +			   CONFIG_BFIN_TX_DESC_NUM);
> +	if (tx_desc == NULL)
> +		goto init_error;
> +
> +	rx_desc =
> +	    bfin_mac_alloc(&dma_handle,
> +			   sizeof(struct net_dma_desc_rx) *
> +			   CONFIG_BFIN_RX_DESC_NUM);
> +	if (rx_desc == NULL)
> +		goto init_error;
> +
> +	/* init tx_list */
> +	for (i = 0; i < CONFIG_BFIN_TX_DESC_NUM; i++) {
> +
> +		tmp_desc_tx = tx_desc + i;
> +
> +		if (i == 0) {
> +			tx_list_head = tmp_desc_tx;
> +			tx_list_tail = tmp_desc_tx;
> +		}
> +
> +		tmp_desc_tx->desc_a.start_addr =
> +		    (unsigned long)tmp_desc_tx->packet;
> +		tmp_desc_tx->desc_a.x_count = 0;
> +		tmp_desc_tx->desc_a.config.b_DMA_EN = 0;	/* disabled */
> +		tmp_desc_tx->desc_a.config.b_WNR = 0;		/* read from memory */
> +		tmp_desc_tx->desc_a.config.b_WDSIZE = 2;	/* wordsize is 32 bits */
> +		tmp_desc_tx->desc_a.config.b_NDSIZE = 6;	/* 6 half words is desc size. */
> +		tmp_desc_tx->desc_a.config.b_FLOW = 7;		/* large desc flow */
> +		tmp_desc_tx->desc_a.next_dma_desc = &(tmp_desc_tx->desc_b);
> +
> +		tmp_desc_tx->desc_b.start_addr =
> +		    (unsigned long)(&(tmp_desc_tx->status));
> +		tmp_desc_tx->desc_b.x_count = 0;
> +		tmp_desc_tx->desc_b.config.b_DMA_EN = 1;	/* enabled */
> +		tmp_desc_tx->desc_b.config.b_WNR = 1;		/* write to memory */
> +		tmp_desc_tx->desc_b.config.b_WDSIZE = 2;	/* wordsize is 32 bits */
> +		tmp_desc_tx->desc_b.config.b_DI_EN = 0;		/* disable interrupt */
> +		tmp_desc_tx->desc_b.config.b_NDSIZE = 6;
> +		tmp_desc_tx->desc_b.config.b_FLOW = 7;		/* stop mode */
> +		tmp_desc_tx->skb = NULL;
> +		tx_list_tail->desc_b.next_dma_desc = &(tmp_desc_tx->desc_a);
> +		tx_list_tail->next = tmp_desc_tx;

should be using dma mapping


> +		tx_list_tail = tmp_desc_tx;
> +	}
> +	tx_list_tail->next = tx_list_head;	/* tx_list is a circle */
> +	tx_list_tail->desc_b.next_dma_desc = &(tx_list_head->desc_a);
> +	current_tx_ptr = tx_list_head;

why do you use a list rather than an array like other drivers?


> +	/* init rx_list */
> +	for (i = 0; i < CONFIG_BFIN_RX_DESC_NUM; i++) {
> +
> +		tmp_desc_rx = rx_desc + i;
> +
> +		if (i == 0) {
> +			rx_list_head = tmp_desc_rx;
> +			rx_list_tail = tmp_desc_rx;
> +		}
> +
> +		/* allocat a new skb for next time receive */
> +		new_skb = dev_alloc_skb(PKT_BUF_SZ + 2);

use NET_IP_ALIGN


> +		if (!new_skb) {
> +			printk(KERN_NOTICE CARDNAME
> +			       ": init: low on mem - packet dropped\n");
> +			goto init_error;
> +		}
> +		skb_reserve(new_skb, 2);

ditto


> +		tmp_desc_rx->skb = new_skb;
> +		/* since RXDWA is enabled */
> +		tmp_desc_rx->desc_a.start_addr =
> +		    (unsigned long)new_skb->data - 2;
> +		tmp_desc_rx->desc_a.x_count = 0;
> +		tmp_desc_rx->desc_a.config.b_DMA_EN = 1;	/* enabled */
> +		tmp_desc_rx->desc_a.config.b_WNR = 1;		/* Write to memory */
> +		tmp_desc_rx->desc_a.config.b_WDSIZE = 2;	/* wordsize is 32 bits */
> +		tmp_desc_rx->desc_a.config.b_NDSIZE = 6;	/* 6 half words is desc size. */
> +		tmp_desc_rx->desc_a.config.b_FLOW = 7;		/* large desc flow */
> +		tmp_desc_rx->desc_a.next_dma_desc = &(tmp_desc_rx->desc_b);
> +
> +		tmp_desc_rx->desc_b.start_addr =
> +		    (unsigned long)(&(tmp_desc_rx->status));
> +		tmp_desc_rx->desc_b.x_count = 0;
> +		tmp_desc_rx->desc_b.config.b_DMA_EN = 1;	/* enabled */
> +		tmp_desc_rx->desc_b.config.b_WNR = 1;		/* Write to memory */
> +		tmp_desc_rx->desc_b.config.b_WDSIZE = 2;	/* wordsize is 32 bits */
> +		tmp_desc_rx->desc_b.config.b_NDSIZE = 6;
> +		tmp_desc_rx->desc_b.config.b_DI_EN = 1;		/* enable interrupt */
> +		tmp_desc_rx->desc_b.config.b_FLOW = 7;		/* large mode */
> +		rx_list_tail->desc_b.next_dma_desc = &(tmp_desc_rx->desc_a);

should be using dma mapping


> +		rx_list_tail->next = tmp_desc_rx;
> +		rx_list_tail = tmp_desc_rx;
> +	}
> +	rx_list_tail->next = rx_list_head;	/* rx_list is a circle */
> +	rx_list_tail->desc_b.next_dma_desc = &(rx_list_head->desc_a);
> +	current_rx_ptr = rx_list_head;
> +
> +	return 0;
> +
> +      init_error:
> +	desc_list_free();
> +	printk(KERN_ERR CARDNAME ": kmalloc failed\n");
> +	return -ENOMEM;

fix indentation

> +/* Wait until the previous MDC/MDIO transaction has completed */
> +static void poll_mdc_done(void)
> +{
> +	/* poll the STABUSY bit */
> +	while ((bfin_read_EMAC_STAADD()) & STABUSY) {
> +	};
> +}

no infinite loops

no empty loops (at a minimum, must use cpu_relax())


> +/* Read an off-chip register in a PHY through the MDC/MDIO port */
> +static u16 read_phy_reg(u16 PHYAddr, u16 RegAddr)
> +{
> +	poll_mdc_done();
> +	bfin_write_EMAC_STAADD(SET_PHYAD(PHYAddr) | SET_REGAD(RegAddr) | STABUSY);	/* read mode */

remove the ALL CAPS from function names


> +	poll_mdc_done();
> +
> +	return (u16) bfin_read_EMAC_STADAT();

unneeded cast


> +/* Write an off-chip register in a PHY through the MDC/MDIO port */
> +static void raw_write_phy_reg(u16 PHYAddr, u16 RegAddr, u32 Data)
> +{
> +	bfin_write_EMAC_STADAT(Data);
> +
> +	bfin_write_EMAC_STAADD(SET_PHYAD(PHYAddr) | SET_REGAD(RegAddr) | STAOP | STABUSY);	/* write mode */
> +
> +	poll_mdc_done();
> +}
> +
> +static void write_phy_reg(u16 PHYAddr, u16 RegAddr, u32 Data)
> +{
> +	poll_mdc_done();
> +	raw_write_phy_reg(PHYAddr, RegAddr, Data);
> +}
> +
> +/* set up the phy */
> +static void bf537mac_setphy(struct net_device *dev)
> +{
> +	u16 phydat;
> +	u32 sysctl;
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +
> +	pr_debug("start settting up phy\n");
> +
> +	/* Program PHY registers */
> +	phydat = 0;
> +
> +	/* issue a reset */
> +	raw_write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, 0x8000);
> +
> +	/* wait half a second */
> +	udelay(500);

must read after write, to ensure propagation to bus before delay

otherwise, delay can happen /in parallel/ with write posting


> +	phydat = read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
> +
> +	/* advertise flow control supported */
> +	phydat = read_phy_reg(lp->PhyAddr, PHYREG_ANAR);
> +	phydat |= (1 << 10);
> +	write_phy_reg(lp->PhyAddr, PHYREG_ANAR, phydat);
> +
> +	phydat = 0;
> +	if (lp->Negotiate) {
> +		phydat |= 0x1000;	/* enable auto negotiation */
> +	} else {
> +		if (lp->FullDuplex) {
> +			phydat |= (1 << 8);	/* full duplex */
> +		} else {
> +			phydat &= (~(1 << 8));	/* half duplex */
> +		}
> +		if (!lp->Port10) {
> +			phydat |= (1 << 13);	/* 100 Mbps */
> +		} else {
> +			phydat &= (~(1 << 13));	/* 10 Mbps */
> +		}
> +	}

remove braces around single-line C statements

use defines from linux/mii.h where appropriate

create named constants rather than using magic numbers like "1 << 14", i.e.:

	enum {
		phy_dat_10mbps		= (1 << 13),
	};


> +	if (lp->Loopback) {
> +		phydat |= (1 << 14);	/* enable TX->RX loopback */
> +#if 0
> +		write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, phydat);
> +#endif
> +	}
> +
> +	write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, phydat);
> +	udelay(500);

udelay after write


> +	phydat = read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
> +	/* check for SMSC PHY */
> +	if ((read_phy_reg(lp->PhyAddr, PHYREG_PHYID1) == 0x7)
> +	    && ((read_phy_reg(lp->PhyAddr, PHYREG_PHYID2) & 0xfff0) == 0xC0A0)) {
> +		/* we have SMSC PHY so reqest interrupt on link down condition */
> +		write_phy_reg(lp->PhyAddr, 30, 0x0ff);	/* enable interrupts */
> +		/* enable PHY_INT */
> +		sysctl = bfin_read_EMAC_SYSCTL();
> +		sysctl |= 0x1;
> +#if 0
> +		bfin_write_EMAC_SYSCTL(sysctl);
> +#endif
> +	}
> +}
> +
> +/**************************************************************************/
> +void setup_system_regs(struct net_device *dev)
> +{
> +	int PHYADDR;
> +	unsigned short sysctl, phydat;
> +	u32 opmode;
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +	int count = 0;
> +
> +	PHYADDR = lp->PhyAddr;
> +
> +	/* Enable PHY output */
> +	if (!(bfin_read_VR_CTL() & PHYCLKOE))
> +		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
> +
> +	/* MDC  = 2.5 MHz */
> +	sysctl = SET_MDCDIV(24);
> +	/* Odd word alignment for Receive Frame DMA word */
> +	/* Configure checksum support and rcve frame word alignment */
> +#if defined(BFIN_MAC_CSUM_OFFLOAD)
> +	sysctl |= RXDWA | RXCKS;
> +#else
> +	sysctl |= RXDWA;
> +#endif
> +	bfin_write_EMAC_SYSCTL(sysctl);
> +	/* auto negotiation on  */
> +	/* full duplex          */
> +	/* 100 Mbps             */
> +	phydat = PHY_ANEG_EN | PHY_DUPLEX | PHY_SPD_SET;
> +	write_phy_reg(PHYADDR, PHYREG_MODECTL, phydat);
> +
> +	/* test if full duplex supported */
> +	do {
> +		msleep(100);
> +		phydat = read_phy_reg(PHYADDR, PHYREG_MODESTAT);
> +		if (count > 30) {
> +			printk(KERN_NOTICE CARDNAME
> +			       ": Link is down, please check your network connection\n");
> +			break;
> +		}
> +		count++;
> +	} while (!(phydat & 0x0004));

kill magic numbers


> +	phydat = read_phy_reg(PHYADDR, PHYREG_ANLPAR);
> +
> +	if ((phydat & 0x0100) || (phydat & 0x0040)) {

ditto


> +		opmode = FDMODE;
> +	} else {
> +		opmode = 0;
> +		printk(KERN_INFO CARDNAME ": Network is set to half duplex\n");
> +	}
> +
> +#if defined(CONFIG_BFIN_MAC_RMII)
> +	opmode |= RMII; /* For Now only 100MBit are supported */
> +#endif
> +
> +	bfin_write_EMAC_OPMODE(opmode);
> +
> +#if 0
> +	bfin_write_EMAC_MMC_CTL(RSTC | CROLL | MMCE);
> +#endif
> +	bfin_write_EMAC_MMC_CTL(RSTC | CROLL);
> +
> +	/* Initialize the TX DMA channel registers */
> +	bfin_write_DMA2_X_COUNT(0);
> +	bfin_write_DMA2_X_MODIFY(4);
> +	bfin_write_DMA2_Y_COUNT(0);
> +	bfin_write_DMA2_Y_MODIFY(0);
> +
> +	/* Initialize the RX DMA channel registers */
> +	bfin_write_DMA1_X_COUNT(0);
> +	bfin_write_DMA1_X_MODIFY(4);
> +	bfin_write_DMA1_Y_COUNT(0);
> +	bfin_write_DMA1_Y_MODIFY(0);
> +}
> +
> +void setup_mac_addr(u8 * mac_addr)
> +{
> +	/* this depends on a little-endian machine */
> +	bfin_write_EMAC_ADDRLO(*(u32 *) & mac_addr[0]);
> +	bfin_write_EMAC_ADDRHI(*(u16 *) & mac_addr[4]);

please make endian-neutral


> +static void adjust_tx_list(void)
> +{
> +	if (tx_list_head->status.status_word != 0
> +	    && current_tx_ptr != tx_list_head) {
> +		goto adjust_head;	/* released something, just return; */
> +	}
> +
> +	/* if nothing released, check wait condition */
> +	/* current's next can not be the head, otherwise the dma will not stop as we want */
> +	if (current_tx_ptr->next->next == tx_list_head) {
> +		while (tx_list_head->status.status_word == 0) {
> +			udelay(10);
> +			if (tx_list_head->status.status_word != 0
> +			    || !(bfin_read_DMA2_IRQ_STATUS() & 0x08)) {
> +				goto adjust_head;

infinite loop


> +			}
> +		}
> +		if (tx_list_head->status.status_word != 0) {
> +			goto adjust_head;
> +		}

remove braces


> +	}
> +
> +	return;
> +
> +      adjust_head:
> +	do {
> +		tx_list_head->desc_a.config.b_DMA_EN = 0;
> +		tx_list_head->status.status_word = 0;
> +		if (tx_list_head->skb) {
> +			dev_kfree_skb(tx_list_head->skb);
> +			tx_list_head->skb = NULL;
> +		} else {
> +			printk(KERN_ERR CARDNAME
> +			       ": no sk_buff in a transmitted frame!\n");
> +		}
> +		tx_list_head = tx_list_head->next;
> +	} while (tx_list_head->status.status_word != 0
> +		 && current_tx_ptr != tx_list_head);
> +	return;
> +
> +}
> +
> +static int bf537mac_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +	unsigned int data;
> +
> +	current_tx_ptr->skb = skb;
> +	/* Is skb->data always 16-bit aligned? Do we need to memcpy((char *)(tail->packet + 2),skb->data,len)? */
> +	if ((((unsigned int)(skb->data)) & 0x02) == 2) {
> +		/* move skb->data to current_tx_ptr payload */
> +		data = (unsigned int)(skb->data) - 2;
> +		*((unsigned short *)data) = (unsigned short)(skb->len);
> +		current_tx_ptr->desc_a.start_addr = (unsigned long)data;
> +		blackfin_dcache_flush_range(data, (data + (skb->len)) + 2);	/* this is important! */
> +
> +	} else {
> +		*((unsigned short *)(current_tx_ptr->packet)) =
> +		    (unsigned short)(skb->len);
> +		memcpy((char *)(current_tx_ptr->packet + 2), skb->data,
> +		       (skb->len));
> +		current_tx_ptr->desc_a.start_addr =
> +		    (unsigned long)current_tx_ptr->packet;
> +		if (current_tx_ptr->status.status_word != 0)
> +			current_tx_ptr->status.status_word = 0;
> +		blackfin_dcache_flush_range((unsigned int)current_tx_ptr->
> +					    packet,
> +					    (unsigned int)(current_tx_ptr->
> +							   packet + skb->len) +
> +					    2);
> +	}

maybe you need skb_copy_and_csum_dev() ?

the above code is a mess



> +	current_tx_ptr->desc_a.config.b_DMA_EN = 1;	/* enable this packet's dma */
> +
> +	if (bfin_read_DMA2_IRQ_STATUS() & 0x08) {	/* tx dma is running, just return */
> +		goto out;
> +	} else {
> +		/* tx dma is not running */
> +		bfin_write_DMA2_NEXT_DESC_PTR(&(current_tx_ptr->desc_a));
> +		/* dma enabled, read from memory, size is 6 */
> +		bfin_write_DMA2_CONFIG(*((unsigned short *)(&(current_tx_ptr->desc_a.config))));
> +		/* Turn on the EMAC tx */
> +		bfin_write_EMAC_OPMODE(bfin_read_EMAC_OPMODE() | TE);
> +	}

this is blatantly racy


> +      out:
> +	adjust_tx_list();
> +	current_tx_ptr = current_tx_ptr->next;
> +	dev->trans_start = jiffies;
> +	lp->stats.tx_packets++;
> +	lp->stats.tx_bytes += (skb->len);
> +	return 0;
> +}
> +
> +static void bf537mac_rx(struct net_device *dev)
> +{
> +	struct sk_buff *skb, *new_skb;
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +	unsigned short len;
> +
> +	/* allocat a new skb for next time receive */
> +	skb = current_rx_ptr->skb;
> +	new_skb = dev_alloc_skb(PKT_BUF_SZ + 2);

NET_IP_ALIGN


> +	if (!new_skb) {
> +		printk(KERN_NOTICE CARDNAME
> +		       ": rx: low on mem - packet dropped\n");
> +		lp->stats.rx_dropped++;
> +		goto out;
> +	}
> +	/* reserve 2 bytes for RXDWA padding */
> +	skb_reserve(new_skb, 2);

ditto


> +	current_rx_ptr->skb = new_skb;
> +	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
> +
> +#if 0
> +	int i;
> +	if (len >= 64) {
> +		for (i=0;i<len;i++) {
> +			printk("%.2x-",((unsigned char *)pkt)[i]);
> +			if (((i%8)==0) && (i!=0)) printk("\n");
> +		}
> +	printk("\n");
> +	}
> +#endif

remove all this #if 0 code


> +	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
> +	skb_put(skb, len);
> +	blackfin_dcache_invalidate_range((unsigned long)skb->head,
> +					 (unsigned long)skb->tail);
> +
> +	dev->last_rx = jiffies;
> +	skb->dev = dev;

not needed due to next line of code:

> +	skb->protocol = eth_type_trans(skb, dev);


> +#if defined(BFIN_MAC_CSUM_OFFLOAD)
> +	skb->csum = current_rx_ptr->status.ip_payload_csum;
> +	skb->ip_summed = CHECKSUM_PARTIAL;
> +#endif
> +
> +	netif_rx(skb);
> +	lp->stats.rx_packets++;
> +	lp->stats.rx_bytes += len;
> +	current_rx_ptr->status.status_word = 0x00000000;
> +	current_rx_ptr = current_rx_ptr->next;

look into NAPI


> +      out:

fix indentation

> +static void bf537mac_set_multicast_list(struct net_device *dev)
> +{
> +	u32 sysctl;
> +
> +	if (dev->flags & IFF_PROMISC) {
> +		printk(KERN_INFO "%s: set to promisc mode\n", dev->name);
> +		sysctl = bfin_read_EMAC_OPMODE();
> +		sysctl |= RAF;
> +		bfin_write_EMAC_OPMODE(sysctl);
> +	} else if (dev->flags & IFF_ALLMULTI || dev->mc_count > 16) {
> +		/* accept all multicast */
> +		sysctl = bfin_read_EMAC_OPMODE();
> +		sysctl |= PAM;
> +		bfin_write_EMAC_OPMODE(sysctl);
> +	} else if (dev->mc_count) {
> +		/* set multicast */

obvious bug:  INSERT CODE HERE




> +#if 0
> +	dev->ethtool_ops = &bf537mac_ethtool_ops;
> +#endif

implement this

even the most basic GDRVINFO ioctl, which takes all of two seconds to do


> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	dev->poll_controller = bf537mac_poll;
> +#endif
> +
> +	/* fill in some of the fields */
> +	lp->version = 1;
> +	lp->PhyAddr = 0x01;
> +	lp->CLKIN = 25;
> +	lp->FullDuplex = 0;
> +	lp->Negotiate = 1;
> +	lp->FlowControl = 0;
> +	spin_lock_init(&lp->lock);
> +
> +	/* set the GPIO pins to Ethernet mode */
> +	setup_pin_mux();
> +
> +	/* now, enable interrupts */
> +	/* register irq handler */
> +	if (request_irq
> +	    (IRQ_MAC_RX, bf537mac_interrupt, IRQF_DISABLED | IRQF_SHARED,
> +	     "BFIN537_MAC_RX", dev)) {
> +		printk(KERN_WARNING CARDNAME
> +		       ": Unable to attach BlackFin MAC RX interrupt\n");
> +		return -EBUSY;
> +	}
> +
> +	/* Enable PHY output early */
> +	if (!(bfin_read_VR_CTL() & PHYCLKOE))
> +		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
> +
> +	retval = register_netdev(dev);
> +	if (retval == 0) {
> +		/* now, print out the card info, in a short format.. */
> +		printk(KERN_INFO "Blackfin mac net device registered\n");
> +	}
> +
> +      err_out:
> +	return retval;

if register_netdev() fails, you must unregister irq


> +static int bfin_mac_probe(struct platform_device *pdev)
> +{
> +	struct net_device *ndev;
> +
> +	ndev = alloc_etherdev(sizeof(struct bf537mac_local));
> +
> +	if (!ndev) {
> +		printk(KERN_WARNING CARDNAME ": could not allocate device\n");
> +		return -ENOMEM;
> +	}
> +
> +	if (bf537mac_probe(ndev) != 0) {
> +		platform_set_drvdata(pdev, NULL);

pointless, you haven't set drvdata yet


> +		free_netdev(ndev);
> +		printk(KERN_WARNING CARDNAME ": not found\n");
> +		return -ENODEV;
> +	}
> +
> +	SET_MODULE_OWNER(ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);

move this code to with the rest of the net device init code


> +	platform_set_drvdata(pdev, ndev);
> +
> +	return 0;
> +}
> +
> +static int bfin_mac_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +
> +	platform_set_drvdata(pdev, NULL);

do this after you unregister netdev and irq


> +	unregister_netdev(ndev);
> +
> +	free_irq(IRQ_MAC_RX, ndev);
> +
> +	free_netdev(ndev);
> +
> +	return 0;
> +}
> +
> +static int bfin_mac_suspend(struct platform_device *pdev, pm_message_t state)
> +{
> +	return 0;
> +}
> +
> +static int bfin_mac_resume(struct platform_device *pdev)
> +{
> +	return 0;
> +}

NAK obviously broken suspend/resume


> diff -puN /dev/null drivers/net/bfin_mac.h
> --- /dev/null
> +++ a/drivers/net/bfin_mac.h

delete this header, move it to the top of the C source file

