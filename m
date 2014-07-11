From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH v2] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Fri, 11 Jul 2014 15:47:25 +0530
Message-ID: <53BFB9B5.9010809@gmail.com>
References: <1405073505-12939-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:39940 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbaGKKSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 06:18:37 -0400
Received: by mail-pd0-f180.google.com with SMTP id fp1so1156570pdb.25
        for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 03:18:37 -0700 (PDT)
In-Reply-To: <1405073505-12939-1-git-send-email-sonic.adi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2014 03:41 PM, Sonic Zhang wrote:
> From: Sonic Zhang <sonic.zhang@analog.com>
>
> Ethernet RX DMA buffers are polled in NAPI work queue other than received
> directly in DMA RX interrupt handler.
>
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>
> ---
> v2-changes:
> - avoid test NAPI_STATE_NPSVC bit in net device driver
> ---
>   drivers/net/ethernet/adi/bfin_mac.c | 76 ++++++++++++++++++++++---------------
>   drivers/net/ethernet/adi/bfin_mac.h |  1 +
>   2 files changed, 47 insertions(+), 30 deletions(-)
>
> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
> index 7ae74d4..0bc874e 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -1218,11 +1218,13 @@ out:
>   #define RX_ERROR_MASK (RX_LONG | RX_ALIGN | RX_CRC | RX_LEN | \
>   	RX_FRAG | RX_ADDR | RX_DMAO | RX_PHY | RX_LATE | RX_RANGE)
>   
> -static void bfin_mac_rx(struct net_device *dev)
> +static void bfin_mac_rx(struct napi_struct *napi, int budget)
>   {
> +	struct bfin_mac_local *lp = container_of(napi,
> +				struct bfin_mac_local, napi);
> +	struct net_device *dev = lp->ndev;
>   	struct sk_buff *skb, *new_skb;
>   	unsigned short len;
> -	struct bfin_mac_local *lp __maybe_unused = netdev_priv(dev);
>   #if defined(BFIN_MAC_CSUM_OFFLOAD)
>   	unsigned int i;
>   	unsigned char fcs[ETH_FCS_LEN + 1];
> @@ -1256,7 +1258,7 @@ static void bfin_mac_rx(struct net_device *dev)
>   	current_rx_ptr->skb = new_skb;
>   	current_rx_ptr->desc_a.start_addr = (unsigned long)new_skb->data - 2;
>   
> -	len = (unsigned short)((current_rx_ptr->status.status_word) & RX_FRLEN);
> +	len = (unsigned short)(current_rx_ptr->status.status_word & RX_FRLEN);
>   	/* Deduce Ethernet FCS length from Ethernet payload length */
>   	len -= ETH_FCS_LEN;
>   	skb_put(skb, len);
> @@ -1294,7 +1296,8 @@ static void bfin_mac_rx(struct net_device *dev)
>   	}
>   #endif
>   
> -	netif_rx(skb);
> +	napi_gro_receive(&lp->napi, skb);
> +
>   	dev->stats.rx_packets++;
>   	dev->stats.rx_bytes += len;
>   out:
> @@ -1302,41 +1305,48 @@ out:
>   	current_rx_ptr = current_rx_ptr->next;
>   }
>   
> +static int bfin_mac_poll(struct napi_struct *napi, int budget)
> +{
> +	int i = 0;
> +
> +	while (current_rx_ptr->status.status_word != 0 && i < budget) {
> +		bfin_mac_rx(napi, budget);
> +		i++;
> +	}
> +
> +	if (i < budget) {
> +		napi_complete(napi);
> +		if (!(bfin_read_IPEND() & IRQ_EVX))
> +			enable_irq(IRQ_MAC_RX);
> +	}
> +
> +        return i;

we should use tabs while indenting the code.

> +}
> +
>   /* interrupt routine to handle rx and error signal */
>   static irqreturn_t bfin_mac_interrupt(int irq, void *dev_id)
>   {
> -	struct net_device *dev = dev_id;
> -	int number = 0;
> -
> -get_one_packet:
> -	if (current_rx_ptr->status.status_word == 0) {
> -		/* no more new packet received */
> -		if (number == 0) {
> -			if (current_rx_ptr->next->status.status_word != 0) {
> -				current_rx_ptr = current_rx_ptr->next;
> -				goto real_rx;
> -			}
> -		}
> -		bfin_write_DMA1_IRQ_STATUS(bfin_read_DMA1_IRQ_STATUS() |
> -					   DMA_DONE | DMA_ERR);
> -		return IRQ_HANDLED;
> +	struct bfin_mac_local *lp = netdev_priv(dev_id);
> +	u32 status;
> +
> +	status = bfin_read_DMA1_IRQ_STATUS();
> +
> +	bfin_write_DMA1_IRQ_STATUS(status | DMA_DONE | DMA_ERR);
> +	if ((status & DMA_DONE) && napi_schedule_prep(&lp->napi)) {
> +		disable_irq_nosync(IRQ_MAC_RX);
> +		__napi_schedule(&lp->napi);
>   	}
>   
> -real_rx:
> -	bfin_mac_rx(dev);
> -	number++;
> -	goto get_one_packet;
> +	return IRQ_HANDLED;
>   }
>   
>   #ifdef CONFIG_NET_POLL_CONTROLLER
> -static void bfin_mac_poll(struct net_device *dev)
> +static void bfin_mac_poll_controller(struct net_device *dev)
>   {
>   	struct bfin_mac_local *lp = netdev_priv(dev);
>   
> -	disable_irq(IRQ_MAC_RX);
>   	bfin_mac_interrupt(IRQ_MAC_RX, dev);
>   	tx_reclaim_skb(lp);
> -	enable_irq(IRQ_MAC_RX);
>   }
>   #endif				/* CONFIG_NET_POLL_CONTROLLER */
>   
> @@ -1428,14 +1438,13 @@ static void bfin_mac_timeout(struct net_device *dev)
>   		tx_list_head = tx_list_head->next;
>   	}
>   
> -	if (netif_queue_stopped(lp->ndev))
> -		netif_wake_queue(lp->ndev);
> +	if (netif_queue_stopped(dev))
> +		netif_wake_queue(dev);
>   
>   	bfin_mac_enable(lp->phydev);
>   
>   	/* We can accept TX packets again */
>   	dev->trans_start = jiffies; /* prevent tx timeout */
> -	netif_wake_queue(dev);
>   }
>   
>   static void bfin_mac_multicast_hash(struct net_device *dev)
> @@ -1562,6 +1571,7 @@ static int bfin_mac_open(struct net_device *dev)
>   		return ret;
>   	pr_debug("hardware init finished\n");
>   
> +	napi_enable(&lp->napi);
>   	netif_start_queue(dev);
>   	netif_carrier_on(dev);
>   
> @@ -1579,6 +1589,7 @@ static int bfin_mac_close(struct net_device *dev)
>   	pr_debug("%s: %s\n", dev->name, __func__);
>   
>   	netif_stop_queue(dev);
> +	napi_disable(&lp->napi);
>   	netif_carrier_off(dev);
>   
>   	phy_stop(lp->phydev);
> @@ -1604,7 +1615,7 @@ static const struct net_device_ops bfin_mac_netdev_ops = {
>   	.ndo_validate_addr	= eth_validate_addr,
>   	.ndo_change_mtu		= eth_change_mtu,
>   #ifdef CONFIG_NET_POLL_CONTROLLER
> -	.ndo_poll_controller	= bfin_mac_poll,
> +	.ndo_poll_controller	= bfin_mac_poll_controller,
>   #endif
>   };
>   
> @@ -1689,6 +1700,8 @@ static int bfin_mac_probe(struct platform_device *pdev)
>   	lp->tx_reclaim_timer.data = (unsigned long)lp;
>   	lp->tx_reclaim_timer.function = tx_reclaim_skb_timeout;
>   
> +	netif_napi_add(ndev, &lp->napi, bfin_mac_poll, CONFIG_BFIN_RX_DESC_NUM);
> +
>   	spin_lock_init(&lp->lock);
>   
>   	/* now, enable interrupts */
> @@ -1723,6 +1736,7 @@ out_err_phc:
>   out_err_reg_ndev:
>   	free_irq(IRQ_MAC_RX, ndev);
>   out_err_request_irq:
> +	netif_napi_del(&lp->napi);
>   out_err_mii_probe:
>   	mdiobus_unregister(lp->mii_bus);
>   	mdiobus_free(lp->mii_bus);
> @@ -1743,6 +1757,8 @@ static int bfin_mac_remove(struct platform_device *pdev)
>   
>   	unregister_netdev(ndev);
>   
> +	netif_napi_del(&lp->napi);
> +
>   	free_irq(IRQ_MAC_RX, ndev);
>   
>   	free_netdev(ndev);
> diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
> index 6dec86a..3523f0e 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.h
> +++ b/drivers/net/ethernet/adi/bfin_mac.h
> @@ -80,6 +80,7 @@ struct bfin_mac_local {
>   	int irq_wake_requested;
>   	struct timer_list tx_reclaim_timer;
>   	struct net_device *ndev;
> +	struct napi_struct napi;
>   
>   	/* Data for EMAC_VLAN1 regs */
>   	u16 vlan1_mask, vlan2_mask;


-- 
Regards,
Varka Bhadram.
