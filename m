From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: cpdma: switch to use genalloc
Date: Fri, 24 Jun 2016 11:35:15 +0530
Message-ID: <576CCD9B.2050700@ti.com>
References: <20160623123620.11681-1-grygorii.strashko@ti.com>
 <576BDC64.3030908@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <576BDC64.3030908@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 23 June 2016 06:26 PM, Ivan Khoronzhuk wrote:
> 
> 
> On 23.06.16 15:36, Grygorii Strashko wrote:
>> TI CPDMA currently uses a bitmap for tracking descriptors alloactions
>> allocations, but The genalloc already handles the same and can be used
>> as with special memory (SRAM) as with DMA cherent memory chank
>> (dma_alloc_coherent()). Hence, switch to using genalloc and add
>> desc_num property for each channel for limitation of max number of
>> allowed descriptors for each CPDMA channel. This patch do not affect
>> on net throuput.
>>
>> Cc: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
>> ---
>> Testing
>> TCP window: 256K, bandwidth in Mbits/sec:
>>   host: iperf -s
>>   device: iperf -c  172.22.39.17 -t600 -i5 -d -w128K
>>
>> AM437x-idk, 1Gbps link
>>   before: : 341.60, after: 232+123=355
>> am57xx-beagle-x15, 1Gbps link
>>   before: : 1112.80, after: 814+321=1135
>> am335x-boneblack, 100Mbps link
>>   before: : 162.40, after: 72+93=165
>>
>>   drivers/net/ethernet/ti/davinci_cpdma.c | 136
>> +++++++++++++++-----------------
>>   1 file changed, 62 insertions(+), 74 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c
>> b/drivers/net/ethernet/ti/davinci_cpdma.c
>> index 18bf3a8..03b9882 100644
>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>> @@ -21,7 +21,7 @@
>>   #include <linux/dma-mapping.h>
>>   #include <linux/io.h>
>>   #include <linux/delay.h>
>> -
>> +#include <linux/genalloc.h>
>>   #include "davinci_cpdma.h"
>>
>>   /* DMA Registers */
>> @@ -87,9 +87,8 @@ struct cpdma_desc_pool {
>>       void            *cpumap;    /* dma_alloc map */
>>       int            desc_size, mem_size;
>>       int            num_desc, used_desc;
>> -    unsigned long        *bitmap;
>>       struct device        *dev;
>> -    spinlock_t        lock;
>> +    struct gen_pool        *gen_pool;
>>   };
>>
>>   enum cpdma_state {
>> @@ -117,6 +116,7 @@ struct cpdma_chan {
>>       int                chan_num;
>>       spinlock_t            lock;
>>       int                count;
>> +    u32                desc_num;
>>       u32                mask;
>>       cpdma_handler_fn        handler;
>>       enum dma_data_direction        dir;
>> @@ -145,6 +145,20 @@ struct cpdma_chan {
>>                    (directed << CPDMA_TO_PORT_SHIFT));    \
>>       } while (0)
>>
>> +static void cpdma_desc_pool_destroy(struct cpdma_desc_pool *pool)
>> +{
>> +    if (!pool)
>> +        return;
>> +
>> +    WARN_ON(pool->used_desc);
>> +    if (pool->cpumap) {
>> +        dma_free_coherent(pool->dev, pool->mem_size, pool->cpumap,
>> +                  pool->phys);
>> +    } else {
>> +        iounmap(pool->iomap);
>> +    }
>> +}
>> +
> single if, brackets?

if() has multiple line statement, so brackets are must.

Regards
Mugunthan V N

> 
>>   /*
>>    * Utility constructs for a cpdma descriptor pool.  Some devices
>> (e.g. davinci
>>    * emac) have dedicated on-chip memory for these descriptors.  Some
>> other
>> @@ -155,24 +169,25 @@ static struct cpdma_desc_pool *
>>   cpdma_desc_pool_create(struct device *dev, u32 phys, dma_addr_t
>> hw_addr,
>>                   int size, int align)
>>   {
>> -    int bitmap_size;
>>       struct cpdma_desc_pool *pool;
>> +    int ret;
>>
>>       pool = devm_kzalloc(dev, sizeof(*pool), GFP_KERNEL);
>>       if (!pool)
>> -        goto fail;
>> -
>> -    spin_lock_init(&pool->lock);
>> +        goto gen_pool_create_fail;
>>
>>       pool->dev    = dev;
>>       pool->mem_size    = size;
>>       pool->desc_size    = ALIGN(sizeof(struct cpdma_desc), align);
>>       pool->num_desc    = size / pool->desc_size;
>>
>> -    bitmap_size  = (pool->num_desc / BITS_PER_LONG) * sizeof(long);
>> -    pool->bitmap = devm_kzalloc(dev, bitmap_size, GFP_KERNEL);
>> -    if (!pool->bitmap)
>> -        goto fail;
>> +    pool->gen_pool = devm_gen_pool_create(dev,
>> ilog2(pool->desc_size), -1,
>> +                          "cpdma");
>> +    if (IS_ERR(pool->gen_pool)) {
>> +        dev_err(dev, "pool create failed %ld\n",
>> +            PTR_ERR(pool->gen_pool));
>> +        goto gen_pool_create_fail;
>> +    }
>>
>>       if (phys) {
>>           pool->phys  = phys;
>> @@ -185,24 +200,22 @@ cpdma_desc_pool_create(struct device *dev, u32
>> phys, dma_addr_t hw_addr,
>>           pool->phys = pool->hw_addr; /* assumes no IOMMU, don't use
>> this value */
>>       }
>>
>> -    if (pool->iomap)
>> -        return pool;
>> -fail:
>> -    return NULL;
>> -}
>> -
>> -static void cpdma_desc_pool_destroy(struct cpdma_desc_pool *pool)
>> -{
>> -    if (!pool)
>> -        return;
>> +    if (!pool->iomap)
>> +        goto gen_pool_create_fail;
>>
>> -    WARN_ON(pool->used_desc);
>> -    if (pool->cpumap) {
>> -        dma_free_coherent(pool->dev, pool->mem_size, pool->cpumap,
>> -                  pool->phys);
>> -    } else {
>> -        iounmap(pool->iomap);
>> +    ret = gen_pool_add_virt(pool->gen_pool, (unsigned long)pool->iomap,
>> +                pool->phys, pool->mem_size, -1);
>> +    if (ret < 0) {
>> +        dev_err(dev, "pool add failed %d\n", ret);
>> +        goto gen_pool_add_virt_fail;
>>       }
>> +
>> +    return pool;
>> +
>> +gen_pool_add_virt_fail:
>> +    cpdma_desc_pool_destroy(pool);
>> +gen_pool_create_fail:
>> +    return NULL;
>>   }
>>
>>   static inline dma_addr_t desc_phys(struct cpdma_desc_pool *pool,
>> @@ -210,7 +223,7 @@ static inline dma_addr_t desc_phys(struct
>> cpdma_desc_pool *pool,
>>   {
>>       if (!desc)
>>           return 0;
>> -    return pool->hw_addr + (__force long)desc - (__force
>> long)pool->iomap;
>> +    return gen_pool_virt_to_phys(pool->gen_pool, (unsigned long)desc);
>>   }
>>
>>   static inline struct cpdma_desc __iomem *
>> @@ -220,47 +233,23 @@ desc_from_phys(struct cpdma_desc_pool *pool,
>> dma_addr_t dma)
>>   }
>>
>>   static struct cpdma_desc __iomem *
>> -cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc, bool is_rx)
>> +cpdma_desc_alloc(struct cpdma_desc_pool *pool)
>>   {
>> -    unsigned long flags;
>> -    int index;
>> -    int desc_start;
>> -    int desc_end;
>>       struct cpdma_desc __iomem *desc = NULL;
>>
>> -    spin_lock_irqsave(&pool->lock, flags);
>> -
>> -    if (is_rx) {
>> -        desc_start = 0;
>> -        desc_end = pool->num_desc/2;
>> -     } else {
>> -        desc_start = pool->num_desc/2;
>> -        desc_end = pool->num_desc;
>> -    }
>> -
>> -    index = bitmap_find_next_zero_area(pool->bitmap,
>> -                desc_end, desc_start, num_desc, 0);
>> -    if (index < desc_end) {
>> -        bitmap_set(pool->bitmap, index, num_desc);
>> -        desc = pool->iomap + pool->desc_size * index;
>> +    desc = (struct cpdma_desc __iomem *)gen_pool_alloc(pool->gen_pool,
>> +                               pool->desc_size);
>> +    if (desc)
>>           pool->used_desc++;
>> -    }
>>
>> -    spin_unlock_irqrestore(&pool->lock, flags);
>>       return desc;
>>   }
>>
>>   static void cpdma_desc_free(struct cpdma_desc_pool *pool,
>>                   struct cpdma_desc __iomem *desc, int num_desc)
>>   {
>> -    unsigned long flags, index;
>> -
>> -    index = ((unsigned long)desc - (unsigned long)pool->iomap) /
>> -        pool->desc_size;
>> -    spin_lock_irqsave(&pool->lock, flags);
>> -    bitmap_clear(pool->bitmap, index, num_desc);
>> +    gen_pool_free(pool->gen_pool, (unsigned long)desc, pool->desc_size);
>>       pool->used_desc--;
>> -    spin_unlock_irqrestore(&pool->lock, flags);
>>   }
>>
>>   struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_params *params)
>> @@ -516,6 +505,7 @@ struct cpdma_chan *cpdma_chan_create(struct
>> cpdma_ctlr *ctlr, int chan_num,
>>       chan->state    = CPDMA_STATE_IDLE;
>>       chan->chan_num    = chan_num;
>>       chan->handler    = handler;
>> +    chan->desc_num = ctlr->pool->num_desc / 2;
>>
>>       if (is_rx_chan(chan)) {
>>           chan->hdp    = ctlr->params.rxhdp + offset;
>> @@ -675,7 +665,13 @@ int cpdma_chan_submit(struct cpdma_chan *chan,
>> void *token, void *data,
>>           goto unlock_ret;
>>       }
>>
>> -    desc = cpdma_desc_alloc(ctlr->pool, 1, is_rx_chan(chan));
>> +    if (chan->count >= chan->desc_num)    {
>> +        chan->stats.desc_alloc_fail++;
>> +        ret = -ENOMEM;
>> +        goto unlock_ret;
>> +    }
>> +
>> +    desc = cpdma_desc_alloc(ctlr->pool);
>>       if (!desc) {
>>           chan->stats.desc_alloc_fail++;
>>           ret = -ENOMEM;
>> @@ -721,24 +717,16 @@ EXPORT_SYMBOL_GPL(cpdma_chan_submit);
>>
>>   bool cpdma_check_free_tx_desc(struct cpdma_chan *chan)
>>   {
>> -    unsigned long flags;
>> -    int index;
>> -    bool ret;
>>       struct cpdma_ctlr    *ctlr = chan->ctlr;
>>       struct cpdma_desc_pool    *pool = ctlr->pool;
>> +    unsigned long flags;
>> +    bool    free_tx_desc;
> longer first
> 
>>
>> -    spin_lock_irqsave(&pool->lock, flags);
>> -
>> -    index = bitmap_find_next_zero_area(pool->bitmap,
>> -                pool->num_desc, pool->num_desc/2, 1, 0);
>> -
>> -    if (index < pool->num_desc)
>> -        ret = true;
>> -    else
>> -        ret = false;
>> -
>> -    spin_unlock_irqrestore(&pool->lock, flags);
>> -    return ret;
>> +    spin_lock_irqsave(&chan->lock, flags);
>> +    free_tx_desc = (chan->count < chan->desc_num) &&
>> +             gen_pool_avail(pool->gen_pool);
>> +    spin_unlock_irqrestore(&chan->lock, flags);
>> +    return free_tx_desc;
>>   }
>>   EXPORT_SYMBOL_GPL(cpdma_check_free_tx_desc);
>>
>> @@ -772,7 +760,6 @@ static int __cpdma_chan_process(struct cpdma_chan
>> *chan)
>>       unsigned long            flags;
>>
>>       spin_lock_irqsave(&chan->lock, flags);
>> -
> ?
> 
>>       desc = chan->head;
>>       if (!desc) {
>>           chan->stats.empty_dequeue++;
>> @@ -796,6 +783,7 @@ static int __cpdma_chan_process(struct cpdma_chan
>> *chan)
>>                   CPDMA_DESC_PORT_MASK);
>>
>>       chan->head = desc_from_phys(pool, desc_read(desc, hw_next));
>> +
> ?
> 
>>       chan_write(chan, cp, desc_dma);
>>       chan->count--;
>>       chan->stats.good_dequeue++;
>>
> 
