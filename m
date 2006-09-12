From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] pcnet32: reorganize interrupt, tx, and rx processing
Date: Tue, 12 Sep 2006 11:55:31 -0400
Message-ID: <4506D873.8080002@pobox.com>
References: <20060911174602.GA3968@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:16096 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751471AbWILPzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 11:55:42 -0400
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <20060911174602.GA3968@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> Reorganize code to facilitate NAPI changes.
> Tested ia32 and ppc64.
> 
> Signed-off-by: Don Fry <brazilnut@us.ibm.com>

NAK.  This patch should have NO CODE CHANGES, just moving code around.

Mathematically, it should be an equivalent transform.  Thus, we can 
trivially verify that it breaks nothing.


> --- linux-2.6.18-rc6/drivers/net/pcnet32.c.orig	Fri Sep  8 14:02:12 2006
> +++ linux-2.6.18-rc6/drivers/net/pcnet32.c	Mon Sep 11 09:07:13 2006
> @@ -299,7 +299,6 @@ static int pcnet32_probe1(unsigned long,
>  static int pcnet32_open(struct net_device *);
>  static int pcnet32_init_ring(struct net_device *);
>  static int pcnet32_start_xmit(struct sk_buff *, struct net_device *);
> -static int pcnet32_rx(struct net_device *);
>  static void pcnet32_tx_timeout(struct net_device *dev);
>  static irqreturn_t pcnet32_interrupt(int, void *, struct pt_regs *);
>  static int pcnet32_close(struct net_device *);
> @@ -1125,6 +1124,235 @@ static int pcnet32_suspend(struct net_de
>  	return 1;
>  }
>  
> +static int pcnet32_rx_entry(struct net_device *dev,
> +			    struct pcnet32_private *lp,
> +			    struct pcnet32_rx_head *rxp,
> +			    int entry)
> +{
> +	int status = (short)le16_to_cpu(rxp->status) >> 8;
> +	int rx_in_place = 0;
> +	struct sk_buff *skb;
> +	short pkt_len;
> +
> +	if (status != 0x03) {	/* There was an error. */
> +		/*
> +		 * There is a tricky error noted by John Murphy,
> +		 * <murf@perftech.com> to Russ Nelson: Even with full-sized
> +		 * buffers it's possible for a jabber packet to use two
> +		 * buffers, with only the last correctly noting the error.
> +		 */
> +		if (status & 0x01)	/* Only count a general error at the */
> +			lp->stats.rx_errors++;	/* end of a packet. */
> +		if (status & 0x20)
> +			lp->stats.rx_frame_errors++;
> +		if (status & 0x10)
> +			lp->stats.rx_over_errors++;
> +		if (status & 0x08)
> +			lp->stats.rx_crc_errors++;
> +		if (status & 0x04)
> +			lp->stats.rx_fifo_errors++;
> +		return 1;
> +	}
> +
> +	pkt_len = (le32_to_cpu(rxp->msg_length) & 0xfff) - 4;
> +
> +	/* Discard oversize frames. */
> +	if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
> +		if (netif_msg_drv(lp))
> +			printk(KERN_ERR "%s: Impossible packet size %d!\n",
> +			       dev->name, pkt_len);
> +		lp->stats.rx_errors++;
> +		return 1;
> +	}
> +	if (pkt_len < 60) {
> +		if (netif_msg_rx_err(lp))
> +			printk(KERN_ERR "%s: Runt packet!\n", dev->name);
> +		lp->stats.rx_errors++;
> +		return 1;
> +	}
> +
> +	if (pkt_len > rx_copybreak) {
> +		struct sk_buff *newskb;
> +
> +		if ((newskb = dev_alloc_skb(PKT_BUF_SZ))) {
> +			skb_reserve(newskb, 2);
> +			skb = lp->rx_skbuff[entry];
> +			pci_unmap_single(lp->pci_dev,
> +					 lp->rx_dma_addr[entry],
> +					 PKT_BUF_SZ - 2,
> +					 PCI_DMA_FROMDEVICE);
> +			skb_put(skb, pkt_len);
> +			lp->rx_skbuff[entry] = newskb;
> +			newskb->dev = dev;
> +			lp->rx_dma_addr[entry] =
> +			    pci_map_single(lp->pci_dev,
> +					   newskb->data,
> +					   PKT_BUF_SZ - 2,
> +					   PCI_DMA_FROMDEVICE);
> +			rxp->base = le32_to_cpu(lp->rx_dma_addr[entry]);
> +			rx_in_place = 1;
> +		} else
> +			skb = NULL;
> +	} else {
> +		skb = dev_alloc_skb(pkt_len + 2);
> +	}
> +
> +	if (skb == NULL) {
> +		if (netif_msg_drv(lp))
> +			printk(KERN_ERR
> +			       "%s: Memory squeeze, dropping packet.\n",
> +			       dev->name);
> +		lp->stats.rx_dropped++;
> +		return 1;
> +	}
> +	skb->dev = dev;
> +	if (!rx_in_place) {
> +		skb_reserve(skb, 2);	/* 16 byte align */
> +		skb_put(skb, pkt_len);	/* Make room */
> +		pci_dma_sync_single_for_cpu(lp->pci_dev,
> +					    lp->rx_dma_addr[entry],
> +					    PKT_BUF_SZ - 2,
> +					    PCI_DMA_FROMDEVICE);
> +		eth_copy_and_sum(skb,
> +				 (unsigned char *)(lp->rx_skbuff[entry]->data),
> +				 pkt_len, 0);
> +		pci_dma_sync_single_for_device(lp->pci_dev,
> +					       lp->rx_dma_addr[entry],
> +					       PKT_BUF_SZ - 2,
> +					       PCI_DMA_FROMDEVICE);
> +	}
> +	lp->stats.rx_bytes += skb->len;
> +	lp->stats.rx_packets++;
> +	skb->protocol = eth_type_trans(skb, dev);
> +	netif_rx(skb);
> +	dev->last_rx = jiffies;
> +	return 1;

This function returns 1, incrementing npackets, regardless of success or 
failure.


> +static int pcnet32_rx(struct net_device *dev, int quota)

'quota' is an obvious change that doesn't exist in the unpatched driver


> +{
> +	struct pcnet32_private *lp = dev->priv;
> +	int entry = lp->cur_rx & lp->rx_mod_mask;
> +	struct pcnet32_rx_head *rxp = &lp->rx_ring[entry];
> +	int npackets = 0;
> +
> +	/* If we own the next entry, it's a new packet. Send it up. */
> +	while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {

ditto


> +		npackets += pcnet32_rx_entry(dev, lp, rxp, entry);

as noted above, this function always returns 1.


> +		/*
> +		 * The docs say that the buffer length isn't touched, but Andrew
> +		 * Boyd of QNX reports that some revs of the 79C965 clear it.
> +		 */
> +		rxp->buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
> +		wmb();	/* Make sure owner changes after others are visible */
> +		rxp->status = le16_to_cpu(0x8000);
> +		entry = (++lp->cur_rx) & lp->rx_mod_mask;
> +		rxp = &lp->rx_ring[entry];
> +	}
> +
> +	return npackets;
> +}
> +
> @@ -1661,6 +1889,7 @@ pcnet32_probe1(unsigned long ioaddr, int
>  	dev->ethtool_ops = &pcnet32_ethtool_ops;
>  	dev->tx_timeout = pcnet32_tx_timeout;
>  	dev->watchdog_timeo = (5 * HZ);
> +	dev->weight = lp->rx_ring_size / 2;
>  

Another change that belongs in the NAPI patch


> @@ -2262,9 +2491,9 @@ pcnet32_interrupt(int irq, void *dev_id,
>  	struct net_device *dev = dev_id;
>  	struct pcnet32_private *lp;
>  	unsigned long ioaddr;
> -	u16 csr0, rap;
>  	int boguscnt = max_interrupt_work;
> -	int must_restart;
> +	u16 csr0;
> +	irqreturn_t rc = IRQ_HANDLED;
>  
>  	if (!dev) {
>  		if (pcnet32_debug & NETIF_MSG_INTR)
> @@ -2422,183 +2543,27 @@ pcnet32_interrupt(int irq, void *dev_id,
>  				       dev->name, csr0);
>  			/* unlike for the lance, there is no restart needed */
>  		}
> -
> -		if (must_restart) {
> +		pcnet32_rx(dev, dev->weight);

dev->weight is a NAPI thing


> +		if (pcnet32_tx(dev)) {
>  			/* reset the chip to clear the error condition, then restart */
>  			lp->a.reset(ioaddr);
> -			lp->a.write_csr(ioaddr, 4, 0x0915);
> -			pcnet32_restart(dev, 0x0002);
> +			lp->a.write_csr(ioaddr, CSR4, 0x0915);
> +			pcnet32_restart(dev, CSR0_START);
>  			netif_wake_queue(dev);
>  		}
> +		csr0 = lp->a.read_csr(ioaddr, CSR0);
>  	}
>  
> -	/* Set interrupt enable. */
> -	lp->a.write_csr(ioaddr, 0, 0x0040);
> -	lp->a.write_rap(ioaddr, rap);
> +	/*Set interrupt enable. */
> +	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
>  
>  	if (netif_msg_intr(lp))
>  		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
> -		       dev->name, lp->a.read_csr(ioaddr, 0));
> +		       dev->name, lp->a.read_csr(ioaddr, CSR0));

seems like this stuff belongs in patch #3

