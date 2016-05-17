From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Tue, 17 May 2016 14:24:56 -0400 (EDT)
Message-ID: <20160517.142456.2247845107325931733.davem@davemloft.net>
References: <20160517152520.GA2750@debian-dorm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wxt@rock-chips.com, romieu@fr.zoreil.com, heiko@sntech.de,
	linux-rockchip@lists.infradead.org, netdev@vger.kernel.org
To: wsy2220@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbcEQSY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 14:24:59 -0400
In-Reply-To: <20160517152520.GA2750@debian-dorm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shuyu Wei <wsy2220@gmail.com>
Date: Tue, 17 May 2016 23:25:20 +0800

> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> index a3a9392..df3dfef 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -153,9 +153,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
>  {
>  	struct arc_emac_priv *priv = netdev_priv(ndev);
>  	struct net_device_stats *stats = &ndev->stats;
> -	unsigned int i;
>  
> -	for (i = 0; i < TX_BD_NUM; i++) {
> +	while (priv->txbd_dirty != priv->txbd_curr) {
>  		unsigned int *txbd_dirty = &priv->txbd_dirty;
>  		struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
>  		struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
> @@ -685,13 +684,15 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
>  	wmb();
>  
>  	skb_tx_timestamp(skb);
> +	priv->tx_buff[*txbd_curr].skb = skb;
> +
> +	dma_wmb();
>  
>  	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
>  
>  	/* Make sure info word is set */
>  	wmb();
>  
> -	priv->tx_buff[*txbd_curr].skb = skb;
>  
>  	/* Increment index to point to the next BD */
>  	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
> 

These memory barriers do not look correct to me.

dma_wmb() is about visibility between CPU reads/writes and device
accesses to a piece of memory.  But what you're concerned about wrt.
the SKB pointer assignment is CPU to CPU accesses.  Therefore something
like smp_wmb() would be appropriate.

And the wmb() looks like it should be a dma_wmb().
