From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 3/5] Blackfin: on-chip ethernet MAC controller
 driver
Date: Thu, 1 Mar 2007 00:53:15 -0800
Message-ID: <20070301005315.3a37c960.akpm@linux-foundation.org>
References: <1172722514.5264.77.camel@roc-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34798 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933108AbXCAIxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 03:53:42 -0500
In-Reply-To: <1172722514.5264.77.camel@roc-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 01 Mar 2007 12:15:14 +0800 "Wu, Bryan" <bryan.wu@analog.com> wrote:

> Hi folks,
> 
> Here is the blackfin on-chip ethernet MAC controller driver for Linux.
> 
> It's name is blackfin-driver-net-stamp537.patch
> 
> [PATCH] Blackfin: on-chip ethernet MAC controller driver
> 
> This patch implements the driver necessary use the Analog Devices
> Blackfin processor's on-chip ethernet MAC controller.
> 
> ...
>
> +
> +extern void get_bf537_ether_addr(char *addr);

Please don't put extern declarations in .c code.  Put them in a header file
which is included by the file which provides the definition and by all
files which refer to the symbol.

Please review the entire blackfin patchset for more occurrences of this
mistake.

> +static int bf537mac_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct bf537mac_local *lp = netdev_priv(dev);
> +	unsigned int data;
> +
> +	current_tx_ptr->skb = skb;
> +	// Is skb->data always 16-bit aligned? Do we need to memcpy((char *)(tail->packet + 2),skb->data,len)?
> +	if ((((unsigned int)(skb->data)) & 0x02) == 2) {
> +		//move skb->data to current_tx_ptr payload
> +		data = (unsigned int)(skb->data) - 2;
> +		*((unsigned short *)data) = (unsigned short)(skb->len);
> +		current_tx_ptr->desc_a.start_addr = (unsigned long)data;
> +		blackfin_dcache_flush_range(data, (data + (skb->len)) + 2);	//this is important!
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

hm, I'd have thought that networking provided a way of avoiding that
memcpy, but it has been too long..


> +	current_tx_ptr->desc_a.config.b_DMA_EN = 1;	//enable this packet's dma
> +
> +	if (bfin_read_DMA2_IRQ_STATUS() & 0x08) {	//tx dma is running, just return
> +		goto out;
> +	} else {		//tx dma is not running
> +		bfin_write_DMA2_NEXT_DESC_PTR(&(current_tx_ptr->desc_a));
> +		bfin_write_DMA2_CONFIG(*((unsigned short *)(&(current_tx_ptr->desc_a.config))));	// dma enabled, read from memory, size is 6
> +		// Turn on the EMAC tx
> +		bfin_write_EMAC_OPMODE(bfin_read_EMAC_OPMODE() | TE);
> +	}
> +
> +      out:
> +	adjust_tx_list();
> +	current_tx_ptr = current_tx_ptr->next;
> +	dev->trans_start = jiffies;
> +	lp->stats.tx_packets++;
> +	lp->stats.tx_bytes += (skb->len);
> +	return 0;
> +}

