From: Phil Sutter <n0-1@freewrt.org>
Subject: Re: [PATCH] korina: Read buffer overflow
Date: Sat, 8 Aug 2009 02:48:09 +0200
Message-ID: <20090808004815.F10394CEAA@orbit.nwl.cc>
References: <4A7C494B.2060204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:41563 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753218AbZHHA6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 20:58:49 -0400
Content-Disposition: inline
In-Reply-To: <4A7C494B.2060204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Aug 07, 2009 at 05:33:31PM +0200, Roel Kluin wrote:
> If the loop breaks with an i of 0, then we read lp->rd_ring[-1].

Indeed.

> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Should we clean up like this? please review
> 
> diff --git a/drivers/net/korina.c b/drivers/net/korina.c
> index b4cf602..b965b2b 100644
> --- a/drivers/net/korina.c
> +++ b/drivers/net/korina.c
> @@ -754,7 +754,7 @@ static void korina_alloc_ring(struct net_device *dev)
>  {
>  	struct korina_private *lp = netdev_priv(dev);
>  	struct sk_buff *skb;
> -	int i;
> +	int i, j;
>  
>  	/* Initialize the transmit descriptors */
>  	for (i = 0; i < KORINA_NUM_TDS; i++) {
> @@ -771,7 +771,7 @@ static void korina_alloc_ring(struct net_device *dev)
>  	for (i = 0; i < KORINA_NUM_RDS; i++) {
>  		skb = dev_alloc_skb(KORINA_RBSIZE + 2);
>  		if (!skb)
> -			break;
> +			goto err_free;

This implies that all KORINA_NUM_TDS receive descriptors need to be
available for the driver to work. 

>  		skb_reserve(skb, 2);
>  		lp->rx_skb[i] = skb;
>  		lp->rd_ring[i].control = DMA_DESC_IOD |
> @@ -790,6 +790,12 @@ static void korina_alloc_ring(struct net_device *dev)
>  	lp->rx_chain_head = 0;
>  	lp->rx_chain_tail = 0;
>  	lp->rx_chain_status = desc_empty;
> +err_free:
> +	for (j = 0; j < i; j++) {
> +		lp->rd_ring[j].control = 0;
> +		dev_kfree_skb_any(lp->rx_skb[j]);
> +		lp->rx_skb[j] = NULL;
> +	}
>  }

Also I guess there should be some error handling, as the driver probably
wont be useful without a single receive descriptor. What do you think
about the following:

| diff --git a/drivers/net/korina.c b/drivers/net/korina.c
| index a2701f5..d1c5276 100644
| --- a/drivers/net/korina.c
| +++ b/drivers/net/korina.c
| @@ -741,7 +741,7 @@ static struct ethtool_ops netdev_ethtool_ops = {
|  	.get_link               = netdev_get_link,
|  };
|  
| -static void korina_alloc_ring(struct net_device *dev)
| +static int korina_alloc_ring(struct net_device *dev)
|  {
|  	struct korina_private *lp = netdev_priv(dev);
|  	struct sk_buff *skb;
| @@ -772,6 +772,13 @@ static void korina_alloc_ring(struct net_device *dev)
|  		lp->rd_ring[i].ca = CPHYSADDR(skb->data);
|  		lp->rd_ring[i].link = CPHYSADDR(&lp->rd_ring[i+1]);
|  	}
| +	if (!i) {
| +		printk(KERN_ERR DRV_NAME "%s: could not allocate a single"
| +				" receive descriptor\n", dev->name)
| +		return 1;
| +	}
| +	printk(KERN_DEBUG DRV_NAME "%s: allocated %d receive descriptors\n",
| +			dev->name, i);
|  
|  	/* loop back receive descriptors, so the last
|  	 * descriptor points to the first one */
| @@ -782,6 +789,8 @@ static void korina_alloc_ring(struct net_device *dev)
|  	lp->rx_chain_head = 0;
|  	lp->rx_chain_tail = 0;
|  	lp->rx_chain_status = desc_empty;
| +
| +	return 0;
|  }
|  
|  static void korina_free_ring(struct net_device *dev)
| @@ -824,7 +833,8 @@ static int korina_init(struct net_device *dev)
|  	writel(ETH_INT_FC_EN, &lp->eth_regs->ethintfc);
|  
|  	/* Allocate rings */
| -	korina_alloc_ring(dev);
| +	if (korina_alloc_ring(dev))
| +		return 1;
|  
|  	writel(0, &lp->rx_dma_regs->dmas);
|  	/* Start Rx DMA */

Greetings, Phil
