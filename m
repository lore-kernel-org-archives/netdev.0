From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 3c59x: use netdev_alloc_skb
Date: Thu, 07 Aug 2008 02:24:25 -0400
Message-ID: <489A9519.8000703@pobox.com>
References: <20080725120722.1f2668a1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53838 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290AbYHGGY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:24:29 -0400
In-Reply-To: <20080725120722.1f2668a1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Fix possible bug where end of receive buffer could be overwritten.
> The allocation needs to allow for the reserved space. This would only happen
> if device received packet greater than Ethernet standard MTU.
> 
> Change this driver to use netdev_alloc_skb rather than setting skb->dev
> directly. For the initial allocation it doesn't need to be GFP_ATOMIC.
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/3c59x.c	2008-07-25 11:53:43.000000000 -0700
> +++ b/drivers/net/3c59x.c	2008-07-25 12:06:00.000000000 -0700
> @@ -1692,12 +1692,14 @@ vortex_open(struct net_device *dev)
>  			vp->rx_ring[i].next = cpu_to_le32(vp->rx_ring_dma + sizeof(struct boom_rx_desc) * (i+1));
>  			vp->rx_ring[i].status = 0;	/* Clear complete bit. */
>  			vp->rx_ring[i].length = cpu_to_le32(PKT_BUF_SZ | LAST_FRAG);
> -			skb = dev_alloc_skb(PKT_BUF_SZ);
> +
> +			skb = __netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN,
> +						 GFP_KERNEL);
>  			vp->rx_skbuff[i] = skb;
>  			if (skb == NULL)
>  				break;			/* Bad news!  */
> -			skb->dev = dev;			/* Mark as being used by this device. */
> -			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
> +
> +			skb_reserve(skb, NET_IP_ALIGN);	/* Align IP on 16 byte boundaries */
>  			vp->rx_ring[i].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, PKT_BUF_SZ, PCI_DMA_FROMDEVICE));
>  		}
>  		if (i != RX_RING_SIZE) {
> @@ -2538,7 +2540,7 @@ boomerang_rx(struct net_device *dev)
>  		struct sk_buff *skb;
>  		entry = vp->dirty_rx % RX_RING_SIZE;
>  		if (vp->rx_skbuff[entry] == NULL) {
> -			skb = dev_alloc_skb(PKT_BUF_SZ);
> +			skb = netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN);
>  			if (skb == NULL) {
>  				static unsigned long last_jif;
>  				if (time_after(jiffies, last_jif + 10 * HZ)) {
> @@ -2549,8 +2551,8 @@ boomerang_rx(struct net_device *dev)
>  					mod_timer(&vp->rx_oom_timer, RUN_AT(HZ * 1));
>  				break;			/* Bad news!  */
>  			}
> -			skb->dev = dev;			/* Mark as being used by this device. */
> -			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
> +
> +			skb_reserve(skb, NET_IP_ALIGN);
>  			vp->rx_ring[entry].addr = cpu_to_le32(pci_map_single(VORTEX_PCI(vp), skb->data, PKT_BUF_SZ, PCI_DMA_FROMDEVICE));

applied


