From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/1] pch_gbe: replace private tx ring lock with
 common netif_tx_lock
Date: Wed, 27 Apr 2016 10:55:38 +0200
Message-ID: <57207E8A.8030004@cumulusnetworks.com>
References: <20160426224921.GA29558@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36091 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbcD0Izm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 04:55:42 -0400
Received: by mail-wm0-f48.google.com with SMTP id n129so17189649wmn.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 01:55:41 -0700 (PDT)
In-Reply-To: <20160426224921.GA29558@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/2016 12:49 AM, Francois Romieu wrote:
> pch_gbe_tx_ring.tx_lock is only used in the hard_xmit handler and
> in the transmit completion reaper called from NAPI context.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  CONFIG_COMPILE_TESTed
> 
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h      |  2 --
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 10 ++--------
>  2 files changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> index 2a55d6d..8d710a3 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> @@ -481,7 +481,6 @@ struct pch_gbe_buffer {
>  
>  /**
>   * struct pch_gbe_tx_ring - tx ring information
> - * @tx_lock:	spinlock structs
>   * @desc:	pointer to the descriptor ring memory
>   * @dma:	physical address of the descriptor ring
>   * @size:	length of descriptor ring in bytes
> @@ -491,7 +490,6 @@ struct pch_gbe_buffer {
>   * @buffer_info:	array of buffer information structs
>   */
>  struct pch_gbe_tx_ring {
> -	spinlock_t tx_lock;
>  	struct pch_gbe_tx_desc *desc;
>  	dma_addr_t dma;
>  	unsigned int size;
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index ca4add7..5c8e2f1 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -1640,7 +1640,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
>  		   cleaned_count);
>  	if (cleaned_count > 0)  { /*skip this if nothing cleaned*/
>  		/* Recover from running out of Tx resources in xmit_frame */
> -		spin_lock(&tx_ring->tx_lock);
> +		netif_tx_lock(adapter->netdev);
>  		if (unlikely(cleaned && (netif_queue_stopped(adapter->netdev))))
>  		{
>  			netif_wake_queue(adapter->netdev);
> @@ -1652,7 +1652,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
>  
>  		netdev_dbg(adapter->netdev, "next_to_clean : %d\n",
>  			   tx_ring->next_to_clean);
> -		spin_unlock(&tx_ring->tx_lock);
> +		netif_tx_lock(adapter->netdev);

Shouldn't this be netif_tx_unlock ?

>  	}
>  	return cleaned;
>  }
> @@ -1805,7 +1805,6 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
>  
>  	tx_ring->next_to_use = 0;
>  	tx_ring->next_to_clean = 0;
> -	spin_lock_init(&tx_ring->tx_lock);
>  
>  	for (desNo = 0; desNo < tx_ring->count; desNo++) {
>  		tx_desc = PCH_GBE_TX_DESC(*tx_ring, desNo);
> @@ -2135,13 +2134,9 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  {
>  	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
>  	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&tx_ring->tx_lock, flags);
>  
>  	if (unlikely(!PCH_GBE_DESC_UNUSED(tx_ring))) {
>  		netif_stop_queue(netdev);
> -		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
>  		netdev_dbg(netdev,
>  			   "Return : BUSY  next_to use : 0x%08x  next_to clean : 0x%08x\n",
>  			   tx_ring->next_to_use, tx_ring->next_to_clean);
> @@ -2150,7 +2145,6 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  
>  	/* CRC,ITAG no support */
>  	pch_gbe_tx_queue(adapter, tx_ring, skb);
> -	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
>  	return NETDEV_TX_OK;
>  }
>  
> 
