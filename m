From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 2/2] gianfar: Bundle rx buffer allocation
Date: Tue, 12 Mar 2013 18:44:58 +0200
Message-ID: <513F5B8A.2040204@freescale.com>
References: <1363020877-30223-1-git-send-email-claudiu.manoil@freescale.com> <1363020877-30223-2-git-send-email-claudiu.manoil@freescale.com> <CAP=VYLrfX2AcvP_DLucGEhJ8k0Kgoe7dYyXKN3ohKfXopg8oow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:53862
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932188Ab3CLQpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 12:45:16 -0400
In-Reply-To: <CAP=VYLrfX2AcvP_DLucGEhJ8k0Kgoe7dYyXKN3ohKfXopg8oow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Paul,
Thanks for having a look at this.
(please find my inlined comments)

On 3/11/2013 8:16 PM, Paul Gortmaker wrote:
> On Mon, Mar 11, 2013 at 12:54 PM, Claudiu Manoil
> <claudiu.manoil@freescale.com> wrote:
>> Use a more common and efficient pattern for rx buffer processing.
>> Instead of allocating one new buffer (skb) and processing (cleanning up)
>> the "current" buffer for each iteration, use a more efficient
>> approach that bundles the allocation of several rx buffers at a time.
>> This way the 2 rx jobs (buffer processing & buffer allocation) are
>> more localized along processing iterations.
>
> Aside from it being "more common and efficient", it would be nice
> to have concrete underlying reasons for doing this -- i.e. what sort
> of performance gains are achieved, what sort of additional memory
> pressure can we expect on the older 83xx boards with < 512MB?
>

To probe for how common this design is I think it suffices to do
a search on 'next_to_clean' in the eth drivers. I was referring to
efficiency more in terms of better localizing the buff processing/
cleanup and the buff allocation tasks, and more generally in terms
of a better design (and code).

Memory pressure is a good point, and I think this patch improves this
aspect, because the new buff allocation function (gfar_alloc_rx_buff)
is a best effort one.
Take for instance the previous code (from gfar_init_bds):
for (j = 0; j < rx_queue->rx_ring_size; j++) {
...
	skb = gfar_alloc_skb(ndev);
	if (!skb) {
		netdev_err(ndev, "Can't allocate RX buffers\n");
		return -ENOMEM;
	}
	rx_queue->rx_skbuff[j] = skb;
...
}
It forces the rx rings to be completely filled up with skbs
(netdev_alloc_skb, GPF_ATOMIC), otherwise opening the interface fails.

This can be a problem at least for multi-queue devices (8 rings),
especially if configuring higher MTUs than default.

With the new design this shouldn't be a problem anymore, as buffers are
being allocated during processing as memory becomes available, on a
best effort basis. So this code should be more robust.

>>
>> So, for each Rx ring we have the next_to_clean index which points to
>> the first received buffer and gets updated by the buffer cleanup
>> routine. The next_to_alloc index is updated during buffer allocation.
>> Once a given number of Rx buffers have been cleaned up/ processed,
>> rx allocation is being invoked to refill the cleaned-up BDs with new
>> buffers to accommodate the subsequent Rx packets. This is how the
>> bundling effect is achieved.
>>
>> The number of unused BDs to be refilled with new allocated buffers
>> can be computed based on the next_to_clean and next_to_alloc indexes.
>> The implementation follows a commonly used pattern in other drivers too.
>> gfar_alloc_rx_buff() is now the rx buffer allocation routine, the only
>> method that updates the next_to_alloc index of a given ring. It tries
>> (on a best effort basis) to refill/ alloc the requested number of
>> buffers, and updates next_to_alloc to reflect the actual number of allocated
>> buffers. While it has work to do, the rx cleanup routine requests buffer
>> allocations for a fixed number of buffers (bundle), and when there's
>> nothing left to clean it makes a final request to refill the remaining
>> unused BDs with new buffers before exiting.
>>
>> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
>> ---
>>   drivers/net/ethernet/freescale/gianfar.c |  126 +++++++++++++++---------------
>>   drivers/net/ethernet/freescale/gianfar.h |   14 +++-
>>   2 files changed, 73 insertions(+), 67 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
>> index af91196..f117da6 100644
>> --- a/drivers/net/ethernet/freescale/gianfar.c
>> +++ b/drivers/net/ethernet/freescale/gianfar.c
>> @@ -110,7 +110,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
>>   static void gfar_reset_task(struct work_struct *work);
>>   static void gfar_timeout(struct net_device *dev);
>>   static int gfar_close(struct net_device *dev);
>> -static struct sk_buff *gfar_alloc_skb(struct net_device *dev);
>> +static void gfar_alloc_rx_buff(struct gfar_priv_rx_q *rx_queue,
>> +                              int alloc_cnt);
>>   static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
>>                             struct sk_buff *skb);
>>   static int gfar_set_mac_address(struct net_device *dev);
>> @@ -163,13 +164,12 @@ static void gfar_init_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
>>          bdp->lstatus = lstatus;
>>   }
>>
>> -static int gfar_init_bds(struct net_device *ndev)
>> +static void gfar_init_bds(struct net_device *ndev)
>>   {
>>          struct gfar_private *priv = netdev_priv(ndev);
>>          struct gfar_priv_tx_q *tx_queue = NULL;
>>          struct gfar_priv_rx_q *rx_queue = NULL;
>>          struct txbd8 *txbdp;
>> -       struct rxbd8 *rxbdp;
>>          int i, j;
>>
>>          for (i = 0; i < priv->num_tx_queues; i++) {
>> @@ -196,33 +196,10 @@ static int gfar_init_bds(struct net_device *ndev)
>>
>>          for (i = 0; i < priv->num_rx_queues; i++) {
>>                  rx_queue = priv->rx_queue[i];
>> -               rx_queue->cur_rx = rx_queue->rx_bd_base;
>> -               rx_queue->skb_currx = 0;
>> -               rxbdp = rx_queue->rx_bd_base;
>> -
>> -               for (j = 0; j < rx_queue->rx_ring_size; j++) {
>> -                       struct sk_buff *skb = rx_queue->rx_skbuff[j];
>> -
>> -                       if (skb) {
>> -                               gfar_init_rxbdp(rx_queue, rxbdp,
>> -                                               rxbdp->bufPtr);
>> -                       } else {
>> -                               skb = gfar_alloc_skb(ndev);
>> -                               if (!skb) {
>> -                                       netdev_err(ndev, "Can't allocate RX buffers\n");
>> -                                       return -ENOMEM;
>> -                               }
>> -                               rx_queue->rx_skbuff[j] = skb;
>> -
>> -                               gfar_new_rxbdp(rx_queue, rxbdp, skb);
>> -                       }
>> -
>> -                       rxbdp++;
>> -               }
>> -
>> +               rx_queue->next_to_clean = rx_queue->next_to_alloc = 0;
>> +               gfar_alloc_rx_buff(rx_queue, GFAR_RXBD_UNUSED(rx_queue));
>>          }
>>
>> -       return 0;
>>   }
>>
>>   static int gfar_alloc_skb_resources(struct net_device *ndev)
>> @@ -301,8 +278,7 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
>>                          rx_queue->rx_skbuff[j] = NULL;
>>          }
>>
>> -       if (gfar_init_bds(ndev))
>> -               goto cleanup;
>> +       gfar_init_bds(ndev);
>>
>>          return 0;
>>
>> @@ -1366,10 +1342,7 @@ static int gfar_restore(struct device *dev)
>>                  return 0;
>>          }
>>
>> -       if (gfar_init_bds(ndev)) {
>> -               free_skb_resources(priv);
>> -               return -ENOMEM;
>> -       }
>> +       gfar_init_bds(ndev);
>
> You just removed the only instance where gfar_restore could return
> anything other than zero, hence the return value is now pointless.

I don't think I have a choice here as <struct dev_pm_ops>::restore
returns int. (int (*restore)(struct device *dev))
And gfar_init_bds() is not a point of failure anymore, so there are
no error return codes here.

>>
>>          init_registers(ndev);
>>          gfar_set_mac_address(ndev);
>> @@ -2612,18 +2585,46 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
>>          gfar_init_rxbdp(rx_queue, bdp, buf);
>>   }
>>
>> -static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
>> +/* Best effort Rx buff allocation routine. Updates the next_to_alloc
>> + * index of the given ring with the # of completed skb allocations.
>> + */
>> +static void gfar_alloc_rx_buff(struct gfar_priv_rx_q *rx_queue,
>> +                              int alloc_cnt)
>>   {
>> +       struct net_device *dev = rx_queue->dev;
>>          struct gfar_private *priv = netdev_priv(dev);
>> -       struct sk_buff *skb;
>> +       struct rxbd8 *bdp, *base;
>> +       unsigned int i;
>>
>> -       skb = netdev_alloc_skb(dev, priv->rx_buffer_size + RXBUF_ALIGNMENT);
>> -       if (!skb)
>> -               return NULL;
>> +       i = rx_queue->next_to_alloc;
>> +       base = rx_queue->rx_bd_base;
>> +       bdp = &rx_queue->rx_bd_base[i];
>>
>> -       gfar_align_skb(skb);
>> +       while (alloc_cnt--) {
>> +               struct sk_buff *skb;
>>
>> -       return skb;
>> +               skb = netdev_alloc_skb(dev,
>> +                                      priv->rx_buffer_size + RXBUF_ALIGNMENT);
>> +               if (unlikely(!skb))
>> +                       break; /* try again with the next alloc request */
>> +
>> +               gfar_align_skb(skb);
>> +
>> +               rx_queue->rx_skbuff[i] = skb;
>> +
>> +               /* Setup the new RxBD */
>> +               gfar_new_rxbdp(rx_queue, bdp, skb);
>> +
>> +               /* Update to the next pointer */
>> +               bdp = next_bd(bdp, base, rx_queue->rx_ring_size);
>> +
>> +               if (unlikely(++i == rx_queue->rx_ring_size))
>> +                       i = 0;
>> +       }
>> +
>> +       rx_queue->next_to_alloc = i;
>> +
>> +       return;
>>   }
>>
>>   static inline void count_errors(unsigned short status, struct net_device *dev)
>> @@ -2746,24 +2747,26 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
>>          struct sk_buff *skb;
>>          int pkt_len;
>>          int amount_pull;
>> -       int howmany = 0;
>> +       unsigned int i;
>> +       int howmany = 0, cleaned_cnt = 0;
>
> This could simply be "cleaned".  It is self evident it is a
> counter, just as it is for "howmany".
>

Ok.

>>          struct gfar_private *priv = netdev_priv(dev);
>>
>> +       i = rx_queue->next_to_clean;
>>          /* Get the first full descriptor */
>> -       bdp = rx_queue->cur_rx;
>>          base = rx_queue->rx_bd_base;
>> +       bdp = &rx_queue->rx_bd_base[i];
>>
>>          amount_pull = priv->uses_rxfcb ? GMAC_FCB_LEN : 0;
>>
>>          while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
>> -               struct sk_buff *newskb;
>> -
>>                  rmb();
>>
>> -               /* Add another skb for the future */
>> -               newskb = gfar_alloc_skb(dev);
>> +               skb = rx_queue->rx_skbuff[i];
>> +               rx_queue->rx_skbuff[i] = NULL;
>>
>> -               skb = rx_queue->rx_skbuff[rx_queue->skb_currx];
>> +               cleaned_cnt++;
>> +               if (unlikely(++i == rx_queue->rx_ring_size))
>> +                       i = 0;
>>
>>                  dma_unmap_single(priv->dev, bdp->bufPtr,
>>                                   priv->rx_buffer_size, DMA_FROM_DEVICE);
>> @@ -2772,15 +2775,13 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
>>                               bdp->length > priv->rx_buffer_size))
>>                          bdp->status = RXBD_LARGE;
>>
>> -               /* We drop the frame if we failed to allocate a new buffer */
>> -               if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
>> +               if (unlikely(!(bdp->status & RXBD_LAST) ||
>>                               bdp->status & RXBD_ERR)) {
>>                          count_errors(bdp->status, dev);
>>
>> -                       if (unlikely(!newskb))
>> -                               newskb = skb;
>> -                       else if (skb)
>> -                               dev_kfree_skb(skb);
>> +                       /* discard faulty buffer */
>
> Unclear to me what you mean by "faulty" here -- in the old instance
> it was clear an allocation failure happened.  But now gfar_alloc_rx_buf()
> is void, and I can't immediately see what prevents allocations from
> being retried forever...
>

I think the main reason of this 'if' statement is to catch the faulty
Rx frames (those received with RXBD_ERR or !RXBD_LAST hw indication).
The associated skb (holding the error frame) has no meaning and hence
it is discarded.
Now, the old instance complicates things. It tryies to handle the
'newskb' allocation failure with the same 'if' statement, but if the
current received skb has no errors then count_errors() will be called
for no reason. Then, instead of passing 'skb' to the stack, 'newskb'
will point to 'skb', which holds a valid frame (in this example), in
order to recycle the buffer. The old instance seems hackish.

With the new code however, if buffer allocation fails consistently,
then eventually there will be no new H/W Buffer Descriptors set to
receive frames and the device will simply stop receiveng frames
(the corresponding HW counters will be incremented/ Rx busy interrupts
will occur in this case) until new buffers will be available.

>> +                       dev_kfree_skb(skb);
>> +
>>                  } else {
>>                          /* Increment the number of packets */
>>                          rx_queue->stats.rx_packets++;
>> @@ -2803,21 +2804,20 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
>>
>>                  }
>>
>> -               rx_queue->rx_skbuff[rx_queue->skb_currx] = newskb;
>> -
>> -               /* Setup the new bdp */
>> -               gfar_new_rxbdp(rx_queue, bdp, newskb);
>> +               if (unlikely(cleaned_cnt >= GFAR_RX_BUFF_ALLOC)) {
>> +                       gfar_alloc_rx_buff(rx_queue, cleaned_cnt);
>> +                       cleaned_cnt = 0;
>> +               }
>>
>>                  /* Update to the next pointer */
>>                  bdp = next_bd(bdp, base, rx_queue->rx_ring_size);
>>
>> -               /* update to point at the next skb */
>> -               rx_queue->skb_currx = (rx_queue->skb_currx + 1) &
>> -                                     RX_RING_MOD_MASK(rx_queue->rx_ring_size);
>>          }
>> +       rx_queue->next_to_clean = i;
>>
>> -       /* Update the current rxbd pointer to be the next one */
>> -       rx_queue->cur_rx = bdp;
>> +       cleaned_cnt = GFAR_RXBD_UNUSED(rx_queue);
>> +       if (cleaned_cnt)
>> +               gfar_alloc_rx_buff(rx_queue, cleaned_cnt);
>>
>>          return howmany;
>>   }
>> diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
>> index 63a28d2..9adc1ce 100644
>> --- a/drivers/net/ethernet/freescale/gianfar.h
>> +++ b/drivers/net/ethernet/freescale/gianfar.h
>> @@ -93,6 +93,9 @@ extern const char gfar_driver_version[];
>>   #define DEFAULT_TX_RING_SIZE   256
>>   #define DEFAULT_RX_RING_SIZE   256
>>
>> +/* Rx buffer allocation bundle size */
>> +#define GFAR_RX_BUFF_ALLOC     16
>
> Choice of 16 was made because of .... ?
>
> Any need to ever tune this?
>

Seems a reasonable choice, for it must be less than napi weight
(64) and a power of 2.
I guess the current driver processes around 16 packets on average
per Rx interrupt. We may need to tune this indeed. It could be a
module parameter, but this may be addressed with a separate future
patch.

>> +
>>   #define GFAR_RX_MAX_RING_SIZE   256
>>   #define GFAR_TX_MAX_RING_SIZE   256
>>
>> @@ -964,9 +967,9 @@ struct rx_q_stats {
>>    *     struct gfar_priv_rx_q - per rx queue structure
>>    *     @rxlock: per queue rx spin lock
>>    *     @rx_skbuff: skb pointers
>> - *     @skb_currx: currently use skb pointer
>>    *     @rx_bd_base: First rx buffer descriptor
>> - *     @cur_rx: Next free rx ring entry
>> + *     @next_to_alloc: index of the next buffer to be alloc'd
>> + *     @next_to_clean: index of the next buffer to be cleaned
>>    *     @qindex: index of this queue
>>    *     @dev: back pointer to the dev structure
>>    *     @rx_ring_size: Rx ring size
>> @@ -979,11 +982,11 @@ struct gfar_priv_rx_q {
>>          struct  sk_buff ** rx_skbuff;
>>          dma_addr_t rx_bd_dma_base;
>>          struct  rxbd8 *rx_bd_base;
>> -       struct  rxbd8 *cur_rx;
>> +       u16 next_to_clean;
>> +       u16 next_to_alloc;
>>          struct  net_device *dev;
>>          struct gfar_priv_grp *grp;
>>          struct rx_q_stats stats;
>> -       u16     skb_currx;
>>          u16     qindex;
>>          unsigned int    rx_ring_size;
>>          /* RX Coalescing values */
>> @@ -991,6 +994,9 @@ struct gfar_priv_rx_q {
>>          unsigned long rxic;
>>   };
>>
>> +#define GFAR_RXBD_UNUSED(Q)    ((((Q)->next_to_clean > (Q)->next_to_alloc) ? \
>> +       0 : (Q)->rx_ring_size) + (Q)->next_to_clean - (Q)->next_to_alloc - 1)
>> +
>
> Does this really need to be a macro vs a more readable static inline,
> preferably with some comments on what it does and what criteria it
> is using and why?
>
> Part of my trouble in understanding this patch is probably due to not
> being clear what GFAR_RXBD_UNUSED is telling us.
>
> Also, what boards were tested?  I'm out of office until Wed, so I won't
> be able to test on my sbc8548 until at least then.
>

I guess it can be a static inline too, though constructs like:
gfar_alloc_rx_buff(rx_queue, GFAR_RXBD_UNUSED(rx_queue));
won't be possible in that case.
The comment would be smth. like:
formula to compute the number of RX Buffer Descriptors that
need to be refilled in order to be used for reception (hence
unused).

Same macro may be found in other drivers too. I think it's triky
to explain the fromula in words, but basically if next_to_clean
is next_to_alloc + 1 it means that the BD ring needs no refill.
The BD with index next_to_clean always points to a buffer ready for
Rx (or already holding a frame), whereas index next_to_alloc always
points to a BD that is not ready for Rx (and needs a buffer to be
alloc'd).

I've been testing this code for a while, mostly on p2020 and p1020
boards. (It would be great if you could give it a try on a 8548.)
Regarding performance measurments, they may be not relevant
in case the performance bottleneck is somewhere else in the driver.
Could you perhaps recommend a relevant performance test fost this
change?


Thanks,
Claudiu
