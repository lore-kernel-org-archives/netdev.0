From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH 3.8-rc] net: mvneta: fix driver operation in SMP context
Date: Mon, 07 Jan 2013 18:14:32 +0100
Message-ID: <50EB0278.4010806@free-electrons.com>
References: <1357576074-24245-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Maen Suleiman <maen@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.32.191]:41069 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab3AGROh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 12:14:37 -0500
In-Reply-To: <1357576074-24245-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2013 05:27 PM, Thomas Petazzoni wrote:
> From: Dmitri Epshtein <dima@marvell.com>
> 
> In order for the driver to behave properly in a SMP context, the same
> transmit queue should be used by the kernel in dev_queue_xmit() and in
> the driver's mvneta_tx() function. To achieve that, the driver now
> implements the ->ndo_select_txq() operation.
> 
> For now, it always returns the same transmit queue, txq_def, until the
> driver is expanded to properly take advantage of the multiqueue
> capabilities of the hardware.
> 
> Without this patch, the network driver crashes the kernel almost
> immediately on Armada XP platforms, if the network load is at least a
> little bit parallel (i.e several threads).
> 
> [Thomas Petazzoni: reword commit message]
> Signed-off-by: Dmitri Epshtein <dima@marvell.com>
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

I have tested this patch on my Armada XP DB board and on the
OpenBlocks AX3 board. I confirmed that it fixes the problem when
multiple thread are used.

You can add my
Tested-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
and also my
Acked-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Or a combination of the two if you prefer!

> ---
> This is 3.8-rc material.
> ---
>  drivers/net/ethernet/marvell/mvneta.c |   17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index b6025c3..af2c421 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -1310,6 +1310,17 @@ static u32 mvneta_skb_tx_csum(struct mvneta_port *pp, struct sk_buff *skb)
>  	return MVNETA_TX_L4_CSUM_NOT;
>  }
>  
> +static u16 mvneta_tx_policy(struct mvneta_port *pp, struct sk_buff *skb)
> +{
> +	return (u16)txq_def;
> +}
> +
> +static u16 mvneta_select_txq(struct net_device *dev, struct sk_buff *skb)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	return mvneta_tx_policy(pp, skb);
> +}
> +
>  /* Returns rx queue pointer (find last set bit) according to causeRxTx
>   * value
>   */
> @@ -1476,7 +1487,8 @@ error:
>  static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct mvneta_port *pp = netdev_priv(dev);
> -	struct mvneta_tx_queue *txq = &pp->txqs[txq_def];
> +	u16 txq_id = mvneta_tx_policy(pp, skb);
> +	struct mvneta_tx_queue *txq = &pp->txqs[txq_id];
>  	struct mvneta_tx_desc *tx_desc;
>  	struct netdev_queue *nq;
>  	int frags = 0;
> @@ -1486,7 +1498,7 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
>  		goto out;
>  
>  	frags = skb_shinfo(skb)->nr_frags + 1;
> -	nq    = netdev_get_tx_queue(dev, txq_def);
> +	nq    = netdev_get_tx_queue(dev, txq_id);
>  
>  	/* Get a descriptor for the first part of the packet */
>  	tx_desc = mvneta_txq_next_desc_get(txq);
> @@ -2550,6 +2562,7 @@ static const struct net_device_ops mvneta_netdev_ops = {
>  	.ndo_change_mtu      = mvneta_change_mtu,
>  	.ndo_tx_timeout      = mvneta_tx_timeout,
>  	.ndo_get_stats64     = mvneta_get_stats64,
> +	.ndo_select_queue    = mvneta_select_txq,
>  };
>  
>  const struct ethtool_ops mvneta_eth_tool_ops = {
> 


-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
