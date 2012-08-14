From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [RFC net-next 4/4] gianfar: Use separate NAPIs for Tx and Rx
 processing
Date: Tue, 14 Aug 2012 19:08:18 +0300
Message-ID: <502A77F2.3070002@freescale.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com> <1344428810-29923-2-git-send-email-claudiu.manoil@freescale.com> <1344428810-29923-3-git-send-email-claudiu.manoil@freescale.com> <1344428810-29923-4-git-send-email-claudiu.manoil@freescale.com> <1344428810-29923-5-git-send-email-claudiu.manoil@freescale.com> <20120814005114.GA29337@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Pankaj Chauhan <pankaj.chauhan@freescale.com>,
	Eric Dumazet <edumazet@google.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.181.185] ([216.32.181.185]:30678 "EHLO
	ch1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751943Ab2HNQJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 12:09:30 -0400
In-Reply-To: <20120814005114.GA29337@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2012 03:51 AM, Paul Gortmaker wrote:
> [[RFC net-next 4/4] gianfar: Use separate NAPIs for Tx and Rx processing] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:
>
>> Add a separate napi poll routine for Tx cleanup, to be triggerred by Tx
>> confirmation interrupts only. Existing poll function is modified to handle
>> only the Rx path processing. This allows parallel processing of Rx and Tx
>> confirmation paths on a smp machine (2 cores).
>> The split also results in simpler/cleaner napi poll function implementations,
>> where each processing path has its own budget, thus improving the fairness b/w
>> the processing paths at the same time.
>>
>> Signed-off-by: Pankaj Chauhan <pankaj.chauhan@freescale.com>
>> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
>> ---
>>   drivers/net/ethernet/freescale/gianfar.c |  154 +++++++++++++++++++++++-------
>>   drivers/net/ethernet/freescale/gianfar.h |   16 +++-
>>   2 files changed, 130 insertions(+), 40 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
>> index 919acb3..2774961 100644
>> --- a/drivers/net/ethernet/freescale/gianfar.c
>> +++ b/drivers/net/ethernet/freescale/gianfar.c
>> @@ -128,12 +128,14 @@ static void free_skb_resources(struct gfar_private *priv);
>>   static void gfar_set_multi(struct net_device *dev);
>>   static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
>>   static void gfar_configure_serdes(struct net_device *dev);
>> -static int gfar_poll(struct napi_struct *napi, int budget);
>> +static int gfar_poll_rx(struct napi_struct *napi, int budget);
>> +static int gfar_poll_tx(struct napi_struct *napi, int budget);
>>   #ifdef CONFIG_NET_POLL_CONTROLLER
>>   static void gfar_netpoll(struct net_device *dev);
>>   #endif
>>   int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit);
>> -static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue);
>> +static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue,
>> +			      int tx_work_limit);
> I'm looking at this in a bit more detail now (was on vacation last wk).
> With the above, you push a work limit down into the clean_tx_ring.
> I'm wondering if the above is implicitly involved in the performance
> difference you see, since...
>
>>   static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
>>   			      int amount_pull, struct napi_struct *napi);
>>   void gfar_halt(struct net_device *dev);
>> @@ -543,16 +545,20 @@ static void disable_napi(struct gfar_private *priv)
>>   {
>>   	int i;
>>   
>> -	for (i = 0; i < priv->num_grps; i++)
>> -		napi_disable(&priv->gfargrp[i].napi);
>> +	for (i = 0; i < priv->num_grps; i++) {
>> +		napi_disable(&priv->gfargrp[i].napi_rx);
>> +		napi_disable(&priv->gfargrp[i].napi_tx);
>> +	}
>>   }
>>   
>>   static void enable_napi(struct gfar_private *priv)
>>   {
>>   	int i;
>>   
>> -	for (i = 0; i < priv->num_grps; i++)
>> -		napi_enable(&priv->gfargrp[i].napi);
>> +	for (i = 0; i < priv->num_grps; i++) {
>> +		napi_enable(&priv->gfargrp[i].napi_rx);
>> +		napi_enable(&priv->gfargrp[i].napi_tx);
>> +	}
>>   }
>>   
>>   static int gfar_parse_group(struct device_node *np,
>> @@ -1028,9 +1034,12 @@ static int gfar_probe(struct platform_device *ofdev)
>>   	dev->ethtool_ops = &gfar_ethtool_ops;
>>   
>>   	/* Register for napi ...We are registering NAPI for each grp */
>> -	for (i = 0; i < priv->num_grps; i++)
>> -		netif_napi_add(dev, &priv->gfargrp[i].napi, gfar_poll,
>> -			       GFAR_DEV_WEIGHT);
>> +	for (i = 0; i < priv->num_grps; i++) {
>> +		netif_napi_add(dev, &priv->gfargrp[i].napi_rx, gfar_poll_rx,
>> +			       GFAR_DEV_RX_WEIGHT);
>> +		netif_napi_add(dev, &priv->gfargrp[i].napi_tx, gfar_poll_tx,
>> +			       GFAR_DEV_TX_WEIGHT);
>> +	}
>>   
>>   	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
>>   		dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
>> @@ -2465,7 +2474,8 @@ static void gfar_align_skb(struct sk_buff *skb)
>>   }
>>   
>>   /* Interrupt Handler for Transmit complete */
>> -static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
>> +static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue,
>> +			      int tx_work_limit)
>>   {
>>   	struct net_device *dev = tx_queue->dev;
>>   	struct netdev_queue *txq;
>> @@ -2490,7 +2500,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
>>   	bdp = tx_queue->dirty_tx;
>>   	skb_dirtytx = tx_queue->skb_dirtytx;
>>   
>> -	while ((skb = tx_queue->tx_skbuff[skb_dirtytx])) {
>> +	while ((skb = tx_queue->tx_skbuff[skb_dirtytx]) && tx_work_limit--) {
> ...code like this provides a new exit point that did not exist before,
> for the case of a massive transmit blast.  Do you have any data on how
> often the work limit is hit?  The old Don Becker ether drivers which
> originally introduced the idea of work limits (on IRQs) used to printk a
> message when they hit it, since ideally it shouldn't be happening all
> the time.
>
> In any case, it might be worth while to split this change out into a
> separate commit; something like:
>
>     gianfar: push transmit cleanup work limit down to clean_tx_ring
>
> The advantage being (1) we can test this change in isolation, and
> (2) it makes your remaining rx/tx separate thread patch smaller and
> easier to review.
Sounds interesting, I think I'll give it a try.
Thanks,
Claudiu
