From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: bcmgenet: add support for xmit_more
Date: Mon, 09 Mar 2015 15:10:20 -0700
Message-ID: <1425939020.8261.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425937937-26955-1-git-send-email-f.fainelli@gmail.com>
	 <1425937937-26955-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, pgynther@google.com,
	jaedon.shin@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:40039 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbbCIWKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:10:23 -0400
Received: by igal13 with SMTP id l13so25269185iga.5
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 15:10:21 -0700 (PDT)
In-Reply-To: <1425937937-26955-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 14:52 -0700, Florian Fainelli wrote:
> Delay the update of the TDMA producer index unless this is the last SKB in a
> batch, or the queue is already stopped.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 9b3b8a3db59b..8419826da6a7 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1316,8 +1316,10 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
>  	ring->prod_index += nr_frags + 1;
>  	ring->prod_index &= DMA_P_INDEX_MASK;
>  
> -	bcmgenet_tdma_ring_writel(priv, ring->index,
> -				  ring->prod_index, TDMA_PROD_INDEX);
> +	if (!skb->xmit_more || netif_xmit_stopped(txq))
> +		/* Packets are ready, update producer index */
> +		bcmgenet_tdma_ring_writel(priv, ring->index,
> +					  ring->prod_index, TDMA_PROD_INDEX);
>  
>  	if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
>  		netif_tx_stop_queue(txq);

It seems you have a race here, if you stop the queue right now, while
this skb had skb->xmit_more set.
