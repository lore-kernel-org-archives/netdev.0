From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v4 1/1] net: ethernet: davinci_cpdma: Add boundary for
 rx and tx descriptors
Date: Thu, 17 Jan 2013 15:00:03 +0530
Message-ID: <50F7C49B.5040304@ti.com>
References: <1358381405-7247-1-git-send-email-mugunthanvnm@ti.com> <50F7B832.6030307@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<s.hauer@pengutronix.de>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:42411 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759317Ab3AQJa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 04:30:28 -0500
In-Reply-To: <50F7B832.6030307@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian

On 1/17/2013 2:07 PM, Christian Riesch wrote:
> Hi,
>
> On 2013-01-17 01:10, Mugunthan V N wrote:
>> When there is heavy transmission traffic in the CPDMA, then Rx 
>> descriptors
>> memory is also utilized as tx desc memory looses all rx descriptors 
>> and the
>> driver stops working then.
>>
>> This patch adds boundary for tx and rx descriptors in bd ram dividing 
>> the
>> descriptor memory to ensure that during heavy transmission tx doesn't 
>> use
>> rx descriptors.
>>
>> This patch is already applied to davinci_emac driver, since CPSW and
>> davici_dmac shares the same CPDMA, moving the boundry seperation from
>> Davinci EMAC driver to CPDMA driver which was done in the following
>> commit
>>
>> commit 86d8c07ff2448eb4e860e50f34ef6ee78e45c40c
>> Author: Sascha Hauer <s.hauer@pengutronix.de>
>> Date:   Tue Jan 3 05:27:47 2012 +0000
>>
>>      net/davinci: do not use all descriptors for tx packets
>>
>>      The driver uses a shared pool for both rx and tx descriptors.
>>      During open it queues fixed number of 128 descriptors for receive
>>      packets. For each received packet it tries to queue another
>>      descriptor. If this fails the descriptor is lost for rx.
>>      The driver has no limitation on tx descriptors to use, so it
>>      can happen during a nmap / ping -f attack that the driver
>>      allocates all descriptors for tx and looses all rx descriptors.
>>      The driver stops working then.
>>      To fix this limit the number of tx descriptors used to half of
>>      the descriptors available, the rx path uses the other half.
>>
>>      Tested on a custom board using nmap / ping -f to the board from
>>      two different hosts.
>>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>> ---
>> Changes from v3
>> * Changed multiline commenting as per networking style
>>
>>   drivers/net/ethernet/ti/cpsw.c          |    9 ++++++
>>   drivers/net/ethernet/ti/davinci_cpdma.c |   51 
>> ++++++++++++++++++++++++++-----
>>   drivers/net/ethernet/ti/davinci_cpdma.h |    1 +
>>   drivers/net/ethernet/ti/davinci_emac.c  |   13 ++++----
>>   4 files changed, 61 insertions(+), 13 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c 
>> b/drivers/net/ethernet/ti/cpsw.c
>> index 3772804..b35e6a7 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -374,6 +374,9 @@ void cpsw_tx_handler(void *token, int len, int 
>> status)
>>       struct net_device    *ndev = skb->dev;
>>       struct cpsw_priv    *priv = netdev_priv(ndev);
>>
>> +    /* Check whether the queue is stopped due to stalled tx dma, if the
>> +     * queue is stopped then start the queue as we have free desc 
>> for tx
>> +     */
>>       if (unlikely(netif_queue_stopped(ndev)))
>>           netif_start_queue(ndev);
>>       cpts_tx_timestamp(&priv->cpts, skb);
>> @@ -736,6 +739,12 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct 
>> sk_buff *skb,
>>           goto fail;
>>       }
>>
>> +    /* If there is no more tx desc left free then we need to
>> +     * tell the kernel to stop sending us tx frames.
>> +     */
>> +    if (unlikely(cpdma_check_free_tx_desc(priv->txch)))
>> +        netif_stop_queue(ndev);
>> +
>>       return NETDEV_TX_OK;
>>   fail:
>>       priv->stats.tx_dropped++;
>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c 
>> b/drivers/net/ethernet/ti/davinci_cpdma.c
>> index 4995673..4f6d82f 100644
>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>> @@ -105,13 +105,13 @@ struct cpdma_ctlr {
>>   };
>>
>>   struct cpdma_chan {
>> +    struct cpdma_desc __iomem    *head, *tail;
>> +    void __iomem            *hdp, *cp, *rxfree;
>>       enum cpdma_state        state;
>>       struct cpdma_ctlr        *ctlr;
>>       int                chan_num;
>>       spinlock_t            lock;
>> -    struct cpdma_desc __iomem    *head, *tail;
>>       int                count;
>> -    void __iomem            *hdp, *cp, *rxfree;
>
> I still do not see any benefit from this rearranging here.
This is just code cleanup and doesn't provide any benefit.
>
>>       u32                mask;
>>       cpdma_handler_fn        handler;
>>       enum dma_data_direction        dir;
>> @@ -217,17 +217,29 @@ desc_from_phys(struct cpdma_desc_pool *pool, 
>> dma_addr_t dma)
>>   }
>>
>>   static struct cpdma_desc __iomem *
>> -cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc)
>> +cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc, bool 
>> is_rx)
>>   {
>>       unsigned long flags;
>>       int index;
>> +    int desc_start;
>> +    int desc_end;
>>       struct cpdma_desc __iomem *desc = NULL;
>>
>>       spin_lock_irqsave(&pool->lock, flags);
>>
>> -    index = bitmap_find_next_zero_area(pool->bitmap, pool->num_desc, 0,
>> -                       num_desc, 0);
>> -    if (index < pool->num_desc) {
>> +    if (is_rx) {
>> +        desc_start = 0;
>> +        desc_end = pool->num_desc/2;
>> +        index = bitmap_find_next_zero_area(pool->bitmap,
>> +                pool->num_desc/2, 0, num_desc, 0);
>
> Duplicate calls of bitmap_find_next_zero_area, see a few lines below.
Will fix this in next patch version
>
>> +     } else {
>> +        desc_start = pool->num_desc/2;
>> +        desc_end = pool->num_desc;
>> +    }
>> +
>> +    index = bitmap_find_next_zero_area(pool->bitmap,
>> +                desc_end, desc_start, num_desc, 0);
>> +    if (index < desc_end) {
>>           bitmap_set(pool->bitmap, index, num_desc);
>>           desc = pool->iomap + pool->desc_size * index;
>>           pool->used_desc++;
>> @@ -660,6 +672,7 @@ int cpdma_chan_submit(struct cpdma_chan *chan, 
>> void *token, void *data,
>>       unsigned long            flags;
>>       u32                mode;
>>       int                ret = 0;
>> +    bool                            is_rx;
>>
>>       spin_lock_irqsave(&chan->lock, flags);
>>
>> @@ -668,7 +681,8 @@ int cpdma_chan_submit(struct cpdma_chan *chan, 
>> void *token, void *data,
>>           goto unlock_ret;
>>       }
>>
>> -    desc = cpdma_desc_alloc(ctlr->pool, 1);
>> +    is_rx = (chan->rxfree != 0);
>
> I guess you should use is_rx_chan() here.
Will change this to MACRO.
>
>> +    desc = cpdma_desc_alloc(ctlr->pool, 1, is_rx);
>>       if (!desc) {
>>           chan->stats.desc_alloc_fail++;
>>           ret = -ENOMEM;
>> @@ -704,6 +718,29 @@ unlock_ret:
>>   }
>>   EXPORT_SYMBOL_GPL(cpdma_chan_submit);
>>
>> +bool cpdma_check_free_tx_desc(struct cpdma_chan *chan)
>> +{
>> +    unsigned long flags;
>> +    int index;
>> +    bool ret;
>> +    struct cpdma_ctlr    *ctlr = chan->ctlr;
>> +    struct cpdma_desc_pool    *pool = ctlr->pool;
>> +
>> +    spin_lock_irqsave(&pool->lock, flags);
>> +
>> +    index = bitmap_find_next_zero_area(pool->bitmap,
>> +                pool->num_desc, pool->num_desc/2, 1, 0);
>
> I still wonder if using two separate descriptor pools for rx and tx 
> would be a nicer implementation. In this case you could just use 
> bitmap_full here, right? And the two pools would have separate 
> spinlocks, so rx could not lock tx and vice versa (but as I wrote in 
> an earlier email, I am a newbie here, so I don't know if this would be 
> beneficial).
>
I don't think having two separate pool with separate lock will improve 
performance, i have not seen any issues using one pool with one lock.

Regards
Mugunthan V N
