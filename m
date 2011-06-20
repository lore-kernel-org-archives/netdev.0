From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH 2/2] mv643xx_eth: fix race in trasmit path.
Date: Mon, 20 Jun 2011 16:07:58 +0200
Message-ID: <1308578878.32446.31.camel@sakura.staff.proxad.net>
References: <cover.1308555865.git.richard.cochran@omicron.at>
	 <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, stable@kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:32965 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753834Ab1FTOII (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 10:08:08 -0400
In-Reply-To: <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2011-06-20 at 09:48 +0200, Richard Cochran wrote:

Hi Richard,

> Because the socket buffer is freed in the completion interrupt, it is not
> safe to access it after submitting it to the hardware.

I don't see why.

skb is freed from txq_reclaim() which grabs the tx queue lock before,
(hence the lockless __skb_queue_xxx() in both functions)

What am I missing ?

> Cc: stable@kernel.org
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  drivers/net/mv643xx_eth.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> index a5d9b1c..1b7d2c1 100644
> --- a/drivers/net/mv643xx_eth.c
> +++ b/drivers/net/mv643xx_eth.c
> @@ -859,7 +859,7 @@ no_csum:
>  static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct mv643xx_eth_private *mp = netdev_priv(dev);
> -	int queue;
> +	int length, queue;
>  	struct tx_queue *txq;
>  	struct netdev_queue *nq;
>  
> @@ -881,10 +881,12 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
>  		return NETDEV_TX_OK;
>  	}
>  
> +	length = skb->len;
> +
>  	if (!txq_submit_skb(txq, skb)) {
>  		int entries_left;
>  
> -		txq->tx_bytes += skb->len;
> +		txq->tx_bytes += length;
>  		txq->tx_packets++;
>  
>  		entries_left = txq->tx_ring_size - txq->tx_desc_count;

-- 
Maxime


