From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC patch] driver for the Opencores Ethernet Controller
Date: Mon, 4 Dec 2006 16:02:46 -0800
Message-ID: <20061204160246.5594381e@freekitty>
References: <200612041801.kB4I11F4018165@oogie-boogie.ics.uci.edu>
	<20061204110429.79b70d2e@freekitty>
	<200612042346.kB4NkJJP026630@oogie-boogie.ics.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:39033 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967868AbWLEACv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 19:02:51 -0500
To: Dan Nicolaescu <dann@ics.uci.edu>
In-Reply-To: <200612042346.kB4NkJJP026630@oogie-boogie.ics.uci.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
>   > Indentation. See Documentation style.
>   > What about IRQF_SHARED?
> 
> Not sure, maybe I should make this another driver parameter. On my
> platform is not shared...

The trouble with devices, is that some poor sop clones the hardware to
another board and your assumption is no longer valid.
 
>
>   > > +static int oeth_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   > > +{
>   > > +	struct oeth_private *cep = netdev_priv(dev);
>   > > +	volatile struct oeth_bd *bdp;
>   > > +	unsigned long flags;
>   > > +	u32 len_status;
>   > > +
>   > > +	spin_lock_irqsave(&cep->lock, flags);
>   > > +
>   > > +	if (cep->tx_full) {
>   > > +		/* All transmit buffers are full.  Bail out. */
>   > > +		printk("%s: tx queue full!.\n", dev->name);
>   > > +		print_queue(cep->tx_bd_base, cep->tx_next, OETH_TXBD_NUM);
>   > > +		spin_unlock_irqrestore(&cep->lock, flags);
>   > > +		return 1;
>   > return NETDEV_TX_BUSY.
>   >
>   > you forgot to call stop_queue
> 
> Fixed.
> 
> What should I return in the case below: 
> 
> if (skb->len > OETH_TX_BUFF_SIZE) {
>         printk("%s: tx frame too long!.\n", dev->name);
>         spin_unlock_irqrestore(&cep->lock, flags);
>         return 1;
> }

Drop the skb with dev_kfree_skb_irq() and return NETDEV_TX_OK.
You should net_ratelimit() the message also if you don't want the
machine to hang if you ever get a buggy application.


> Even better, is there a way to make sure the network stack knows that
> it should not try to send packets bigger than OETH_TX_BUFF_SIZE? 
>

dev->mtu is supposed to be followed by protocols, watch out
for vlan's though.

>   > > +
>   > > +	/* Copy data to TX buffer. */
>   > > +	memcpy_hton ((unsigned char *)bdp->addr, skb->data,  skb->len);
>   > 
>   > Use skb_copy_and_csum_dev and you get checksum offload for free.
> 
> Wouldn't that just add (a bit of) overhead? It performs the memcpy, but it also
> checks if the HW is capable of doing the checksum (which it is)... 
> Incidentally the memcpy_hton is just memcpy now.

The cost of copy and checksum is the same as copy on all most hardware.
And does your hardware do IPV6 etc?


>   > > +			cep->stats.rx_dropped++;
>   > > +		}
>   > > +		else {
>   > > +			skb->dev = dev;
>   > > +			OEDRX((printk("RX in ETH buf\n")));
>   > > +			OEDRX((oeth_print_packet((u32*)bdp->addr, pkt_len)));
>   > > +
>   > > +			memcpy_ntoh(skb_put(skb, pkt_len), (unsigned char *)bdp->addr, pkt_len);
>   > 
>   > 
>   > Copying packet in IRQ routine causes long latencies.
> 
> Any suggestions on how else to do this?

You can use NAPI (see 8139too.c) it has similar "issues"
 

>   > > +#if CONFIG_MII
>   > > +static int check_if_running(struct net_device *dev)
>   > > +{
>   > > +	if (!netif_running(dev))
>   > > +		return -EINVAL;
>   > > +	return 0;
>   > > +}
>   > 
>   > Bogus wrapper.
> 
> OK. BTW this is present in 3 more files: hamachi.c, starfire.c and
> sundance.c 

Send the Bunk after it.
