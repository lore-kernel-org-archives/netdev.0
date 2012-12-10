From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/1] net: ethernet: davinci_cpdma: Add boundary for rx
 and tx descriptors
Date: Mon, 10 Dec 2012 16:58:02 +0530
Message-ID: <50C5C742.9020708@ti.com>
References: <1355125052-28448-1-git-send-email-mugunthanvnm@ti.com> <CABkLObp1cZrNR65KJmOJXCB+W_1ZriCJQdL1TEmkJCptXHFDXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <s.hauer@pengutronix.de>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:51346 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823Ab2LJL3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 06:29:18 -0500
In-Reply-To: <CABkLObp1cZrNR65KJmOJXCB+W_1ZriCJQdL1TEmkJCptXHFDXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2012 1:41 PM, Christian Riesch wrote:
> Hi,
>
> On Mon, Dec 10, 2012 at 8:37 AM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
>> When there is heavy transmission traffic in the CPDMA, then Rx descriptors
>> memory is also utilized as tx desc memory this leads to reduced rx desc memory
>> which leads to poor performance.
>>
>> This patch adds boundary for tx and rx descriptors in bd ram dividing the
>> descriptor memory to ensure that during heavy transmission tx doesn't use
>> rx descriptors.
>>
>> This patch is already applied to davinci_emac driver, since CPSW and
>> davici_dmac uses the same CPDMA, moving the boundry seperation from
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
>>   drivers/net/ethernet/ti/davinci_cpdma.c |   20 ++++++++++++++------
>>   drivers/net/ethernet/ti/davinci_emac.c  |    8 --------
>>   2 files changed, 14 insertions(+), 14 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
>> index 4995673..d37f546 100644
>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>> @@ -105,13 +105,13 @@ struct cpdma_ctlr {
>>   };
>>
>>   struct cpdma_chan {
>> +       struct cpdma_desc __iomem       *head, *tail;
>> +       void __iomem                    *hdp, *cp, *rxfree;
>>          enum cpdma_state                state;
>>          struct cpdma_ctlr               *ctlr;
>>          int                             chan_num;
>>          spinlock_t                      lock;
>> -       struct cpdma_desc __iomem       *head, *tail;
>>          int                             count;
>> -       void __iomem                    *hdp, *cp, *rxfree;
> Why?
Its just a code clean-up to have iomem variables at one place.
>
>>          u32                             mask;
>>          cpdma_handler_fn                handler;
>>          enum dma_data_direction         dir;
>> @@ -217,7 +217,7 @@ desc_from_phys(struct cpdma_desc_pool *pool, dma_addr_t dma)
>>   }
>>
>>   static struct cpdma_desc __iomem *
>> -cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc)
>> +cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc, bool is_rx)
>>   {
>>          unsigned long flags;
>>          int index;
>> @@ -225,8 +225,14 @@ cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc)
>>
>>          spin_lock_irqsave(&pool->lock, flags);
>>
>> -       index = bitmap_find_next_zero_area(pool->bitmap, pool->num_desc, 0,
>> -                                          num_desc, 0);
>> +       if (is_rx) {
>> +               index = bitmap_find_next_zero_area(pool->bitmap,
>> +                               pool->num_desc/2, 0, num_desc, 0);
>> +        } else {
>> +               index = bitmap_find_next_zero_area(pool->bitmap,
>> +                               pool->num_desc, pool->num_desc/2, num_desc, 0);
>> +       }
> Would it make sense to use two separate pools for rx and tx instead,
> struct cpdma_desc_pool *rxpool, *txpool? It would result in using
> separate spinlocks for rx and tx, could this be an advantage? (I am a
> newbie in this field...)
I don't think separating pool will give an advantage, the same is 
achieved by separating
the pool into first half and last half.

Regards
Mugunthan V N
