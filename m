From: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Thu, 19 May 2016 23:15:56 +0200
Message-ID: <573E2D0C.604@gmx.de>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com> <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160518225529.GA18671-lmTtMILVy1jWQcoT9B9Ug5SCg42XY1Uw0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Francois,

On 19.05.2016 00:55, Francois Romieu wrote:

>> The smp_wmb() in tx function combined with the smp_rmb() in tx_clean ensures
>> that the CPU running tx_clean sees consistent values for info, data and skb 
>> (thus no need to check for validity of all three values any more).
>> The mb() fulfills several tasks:
>> 1. makes sure that DMA writes to descriptor are completed before the HW is
>>     informed.
> 
> "DMA writes" == "CPU writes" ?
> 

I admit that phrasing was unfortunate. What I meant was, that we have to make sure that
the writes to the descriptors which reside in DMA memory have to be completed before
we inform the hardware. This is since the write to the mmio (arc_reg_set(R_STATUS, TXPL_MASK))
may otherwise overtake the writes to the desriptors in DMA and thus the hardware find an
incompletely set up descriptor.
You can find a barrier for this reason in quite a lot drivers. Normally a dma_rmb() would
be sufficient for this, e.g here

http://lxr.free-electrons.com/source/drivers/net/ethernet/marvell/sky2.c#L1139

or here

http://lxr.free-electrons.com/source/drivers/net/ethernet/intel/ixgb/ixgb_main.c#L1468

but we have to use the mb() instead, because we also have to solve issues 2. and 3.:

2. requires a smp_wmb, while 3. requires a rmb(). AFAIK the mb() implies all we need, 
the dma_rmb() for 1., the smp_wmb() for 2. and the rmb() for 3. 

>> 2. On multi processor systems: ensures that txbd_curr is updated (this is paired
>>     with the smp_mb() at the end of tx_clean).
> 
> Smells like using barrier side-effects to control smp coherency. It isn't
> the recommended style.
> 

As I wrote above, the mb() implies the smp_wmb() so this is a regular pairing
of smp_wmb() in xmit and smb_mb() in tx_clean, nothing uncommon.

>> -		if ((info & FOR_EMAC) || !txbd->data || !skb)
>> +		if (info & FOR_EMAC) {
>> +			/* Make sure we see consistent values for info, skb
>> +			 * and data.
>> +			 */
>> +			smp_rmb();
>>  			break;
>> +		}
> 
> ?
> 
> smp_rmb should appear before the variables you want coherency for.

I dont think so. Please take a look into the memory barriers documentation.
There is an example that is pretty close to the situation that we have in this driver:

http://lxr.free-electrons.com/source/Documentation/memory-barriers.txt#L1819

In that example the barrier is also _between_ the variables that are to be ordered, not 
before. 
Also in the example a dma_rmb() is sufficient, because in the sample code only reads to DMA
memory have to be ordered. In our case we want to order between DMA (info) and RAM ("data" and the skb).
However smp barriers are not sufficient (as I used it in the former patch), since we do not only
want to sync CPU-CPU but also CPU-DMA. Please see the new patch I attached in which mandatory 
barriers are used instead. 


>> -	skb_tx_timestamp(skb);
>> +	/* Make sure info is set after data and skb with respect to
>> +	 * other tx_clean().
>> +	 */
>> +	smp_wmb();
>>  
>>  	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
> 
> Afaik smp_wmb() does not imply wmb(). So priv->txbd[*txbd_curr].data and
> *info (aka priv->txbd[*txbd_curr].info) are not necessarily written in
> an orderly manner.

Right, as I already wrote above I changed the smp barriers to mandatory ones.

> 
>>  
>> -	/* Make sure info word is set */
>> -	wmb();
>> -
>> -	priv->tx_buff[*txbd_curr].skb = skb;
>> -
>>  	/* Increment index to point to the next BD */
>>  	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
> 
> With this change it's possible that tx_clean() reads new value for
> tx_curr and old value (0) for *info.

Even if this could happen, what is the problem? I cant see an issue
that results from such a scenario.

>>  	 * of the queue in tx_clean().
>> +	 * 2.Ensure that all values are written to RAM and to DMA
>> +	 * before hardware is informed.
> 
> (I am not sure what "DMA" is supposed to mean here.)
> 

This is about the DMA/mmio race I described above.

>> +	 * 3.Ensure we see the most recent value for tx_dirty.
>>  	 */
>> -	smp_mb();
>> +	mb();
>>  
>> -	if (!arc_emac_tx_avail(priv)) {
>> +	if (!arc_emac_tx_avail(priv))
>>  		netif_stop_queue(ndev);
>> -		/* Refresh tx_dirty */
>> -		smp_mb();
>> -		if (arc_emac_tx_avail(priv))
>> -			netif_start_queue(ndev);
>> -	}
> 
> Xmit thread                        | Clean thread
> 
> mb();
> 
> arc_emac_tx_avail() test with old
> tx_dirty - tx_clean has not issued
> any mb yet - and new tx_curr
> 
>                                      smp_mb();
> 
>                                      if (netif_queue_stopped(ndev) && ...
>                                              netif_wake_queue(ndev);
> 
> netif_stop_queue()
> 
> -> queue stopped.
> 

Again, the mb() we have now implies the smb_mb() we had before. So nothing changed
except that we can be sure to see the new value for tx_dirty at our first attempt.

>> +
>> +	skb_tx_timestamp(skb);
> 
> You don't want to issue skb_tx_timestamp after releasing control of the
> descriptor (*info = ...): skb may be long gone.
> 

Youre right, I replaced the call to skb_tx_timestamp so that should be ok now, too.
New patch is below. 

Regards,
Lino

---
 drivers/net/ethernet/arc/emac_main.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index a3a9392..b986499 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -162,8 +162,13 @@ static void arc_emac_tx_clean(struct net_device *ndev)
 		struct sk_buff *skb = tx_buff->skb;
 		unsigned int info = le32_to_cpu(txbd->info);
 
-		if ((info & FOR_EMAC) || !txbd->data || !skb)
+		if (info & FOR_EMAC) {
+			/* Make sure we see consistent values for info, skb
+			 * and data.
+			 */
+			rmb();
 			break;
+		}
 
 		if (unlikely(info & (DROP | DEFR | LTCL | UFLO))) {
 			stats->tx_errors++;
@@ -680,35 +685,31 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	dma_unmap_len_set(&priv->tx_buff[*txbd_curr], len, len);
 
 	priv->txbd[*txbd_curr].data = cpu_to_le32(addr);
-
-	/* Make sure pointer to data buffer is set */
-	wmb();
+	priv->tx_buff[*txbd_curr].skb = skb;
 
 	skb_tx_timestamp(skb);
 
-	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
-
-	/* Make sure info word is set */
+	/* Make sure info is set after data and skb with respect to
+	 * tx_clean().
+	 */
 	wmb();
 
-	priv->tx_buff[*txbd_curr].skb = skb;
+	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
 
 	/* Increment index to point to the next BD */
 	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
 
-	/* Ensure that tx_clean() sees the new txbd_curr before
+	/* 1.Ensure that tx_clean() sees the new txbd_curr before
 	 * checking the queue status. This prevents an unneeded wake
 	 * of the queue in tx_clean().
+	 * 2.Ensure that all values are written to RAM and to DMA
+	 * before hardware is informed.
+	 * 3.Ensure we see the most recent value for tx_dirty.
 	 */
-	smp_mb();
+	mb();
 
-	if (!arc_emac_tx_avail(priv)) {
+	if (!arc_emac_tx_avail(priv))
 		netif_stop_queue(ndev);
-		/* Refresh tx_dirty */
-		smp_mb();
-		if (arc_emac_tx_avail(priv))
-			netif_start_queue(ndev);
-	}
 
 	arc_reg_set(priv, R_STATUS, TXPL_MASK);
