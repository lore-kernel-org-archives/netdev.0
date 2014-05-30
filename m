From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 6/8] net: mv643xx_eth: Limit the TSO segments and adjust
 stop/wake thresholds
Date: Fri, 30 May 2014 10:21:33 -0700
Message-ID: <1401470493.3645.129.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
	 <1401468011-10609-7-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:64797 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933202AbaE3RV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 13:21:57 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so1929791pab.33
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 10:21:57 -0700 (PDT)
In-Reply-To: <1401468011-10609-7-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-30 at 13:40 -0300, Ezequiel Garcia wrote:
> Currently small MSS values may require too many TSO descriptors for
> the default queue size. This commit prevents this situation by fixing
> the maximum supported TSO number of segments to 100 and by setting a
> minimum Tx queue size. The minimum Tx queue size is set so that at
> least 2 worst-case skb can be accommodated.
> 
> In addition, the queue stop and wake thresholds values are adjusted
> accordingly. The queue is stopped when there's room for only 1 worst-case
> skb and waked when the number of descriptors is half that value.
> 
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mv643xx_eth.c | 63 ++++++++++++++++++++----------
>  1 file changed, 42 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index 97a60de..2cea86d 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -185,6 +185,10 @@ static char mv643xx_eth_driver_version[] = "1.4";
>  
>  #define TSO_HEADER_SIZE		128
>  
> +/* Max number of allowed TCP segments for software TSO */
> +#define MV643XX_MAX_TSO_SEGS 100
> +#define MV643XX_MAX_SKB_DESCS (MV643XX_MAX_TSO_SEGS * 2 + MAX_SKB_FRAGS)
> +
>  /*
>   * RX/TX descriptors.
>   */
> @@ -348,6 +352,9 @@ struct tx_queue {
>  	int tx_curr_desc;
>  	int tx_used_desc;
>  
> +	int tx_stop_threshold;
> +	int tx_wake_threshold;
> +
>  	char *tso_hdrs;
>  	dma_addr_t tso_hdrs_dma;
>  
> @@ -497,7 +504,7 @@ static void txq_maybe_wake(struct tx_queue *txq)
>  
>  	if (netif_tx_queue_stopped(nq)) {
>  		__netif_tx_lock(nq, smp_processor_id());
> -		if (txq->tx_ring_size - txq->tx_desc_count >= MAX_SKB_FRAGS + 1)
> +		if (txq->tx_desc_count <= txq->tx_wake_threshold)
>  			netif_tx_wake_queue(nq);
>  		__netif_tx_unlock(nq);
>  	}
> @@ -897,7 +904,8 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
>  	}
>  }
>  
> -static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
> +static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb,
> +			  struct net_device *dev)
>  {
>  	struct mv643xx_eth_private *mp = txq_to_mp(txq);
>  	int nr_frags = skb_shinfo(skb)->nr_frags;
> @@ -910,11 +918,15 @@ static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
>  	cmd_sts = 0;
>  	l4i_chk = 0;
>  
> +	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {

I am not sure I understand this part.

You have one skb here, so why are you using MAX_SKB_FRAGS ?

> +		if (net_ratelimit())
> +			netdev_err(dev, "tx queue full?!\n");
> +		return -EBUSY;
> +	}
> +

Also it looks like this part will become dead after the following
patch...
