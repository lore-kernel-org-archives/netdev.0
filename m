From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Fri, 20 May 2016 02:31:45 +0200
Message-ID: <20160520003145.GA22420@electric-eye.fr.zoreil.com>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
 <20160518000153.GA21757@electric-eye.fr.zoreil.com>
 <573CD09D.1060307@gmx.de>
 <20160518225529.GA18671@electric-eye.fr.zoreil.com>
 <573E2D0C.604@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <573E2D0C.604-Mmb7MZpHnFY@public.gmane.org>
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

Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org> :
[...]
> 2. requires a smp_wmb, while 3. requires a rmb(). AFAIK the mb() implies all we need, 
> the dma_rmb() for 1., the smp_wmb() for 2. and the rmb() for 3. 

A revalidation of tx_dirty is still needed (see below) despite the rmb()
for 3. The rmb() for 3. is close to useless.

> >> 2. On multi processor systems: ensures that txbd_curr is updated (this is paired
> >>     with the smp_mb() at the end of tx_clean).
> > 
> > Smells like using barrier side-effects to control smp coherency. It isn't
> > the recommended style.
> > 
> 
> As I wrote above, the mb() implies the smp_wmb() so this is a regular pairing
> of smp_wmb() in xmit and smb_mb() in tx_clean, nothing uncommon.

Since you are quoting Documentation/memory-barriers.txt:
[...]
CPU MEMORY BARRIERS
-------------------
[...]
Mandatory barriers should not be used to control SMP effects, since mandatory
barriers impose unnecessary overhead on both SMP and UP systems.

> >> -		if ((info & FOR_EMAC) || !txbd->data || !skb)
> >> +		if (info & FOR_EMAC) {
> >> +			/* Make sure we see consistent values for info, skb
> >> +			 * and data.
> >> +			 */
> >> +			smp_rmb();
> >>  			break;
> >> +		}
> > 
> > ?
> > 
> > smp_rmb should appear before the variables you want coherency for.
> 
> I dont think so. Please take a look into the memory barriers documentation.

> There is an example that is pretty close to the situation that we have in this driver:
> 
> http://lxr.free-electrons.com/source/Documentation/memory-barriers.txt#L1819
> 
> In that example the barrier is also _between_ the variables that are to be
> ordered, not before. 

Err, which barrier ?

- dma_rmb() ?
  The device (obviously) set the 'status' member of the descriptor.
  dma_rmb() ensures that device-initiated DMA is complete for the 'data'
  member as well.

- dma_wmb() ?
  It ensures that the updated 'data' member will be set before any
  DMA resulting from the change of descriptor ownership takes place.

- wmb() ?
  It ensures that the previous write to descriptor (coherent memory)
  completes before write is posted to I/O mailbox.

None of these is "pretty close" to the "smp_rmb() before return" situation.

> >> -	skb_tx_timestamp(skb);
> >> +	/* Make sure info is set after data and skb with respect to
> >> +	 * other tx_clean().
> >> +	 */
> >> +	smp_wmb();
> >>  
> >>  	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
> > 
> > Afaik smp_wmb() does not imply wmb(). So priv->txbd[*txbd_curr].data and
> > *info (aka priv->txbd[*txbd_curr].info) are not necessarily written in
> > an orderly manner.
> 
> Right, as I already wrote above I changed the smp barriers to mandatory ones.
> 
> > 
> >>  
> >> -	/* Make sure info word is set */
> >> -	wmb();
> >> -
> >> -	priv->tx_buff[*txbd_curr].skb = skb;
> >> -
> >>  	/* Increment index to point to the next BD */
> >>  	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
> > 
> > With this change it's possible that tx_clean() reads new value for
> > tx_curr and old value (0) for *info.
> 
> Even if this could happen, what is the problem? I cant see an issue
> that results from such a scenario.

tx_clean() misunderstands the 0 in *info as a descriptor updated by the
device. tx_clean() thus kfrees the skb before the device DMAed from it.

[...]
> > Xmit thread                        | Clean thread
> > 
> > mb();
> > 
> > arc_emac_tx_avail() test with old
> > tx_dirty - tx_clean has not issued
> > any mb yet - and new tx_curr
> > 
> >                                      smp_mb();
> > 
> >                                      if (netif_queue_stopped(ndev) && ...
> >                                              netif_wake_queue(ndev);
> > 
> > netif_stop_queue()
> > 
> > -> queue stopped.
> > 
> 
> Again, the mb() we have now implies the smb_mb() we had before. So nothing
> changed except that we can be sure to see the new value for tx_dirty at
> our first attempt.

Nothing changed except you removed the revalidation part !

The smp_mb() we had before wasn't about seeing tx_dirty in the xmit thread
but about balancing the (read) barrier in the cleaning thread so that the
latter stood a chance to see the new (tx thread updated) tx_curr.

Consider the two lines below:

	if (!arc_emac_tx_avail(priv))
		netif_stop_queue(ndev);

Nothing prevents a complete run of the cleaning thread between these
two lines. It may or it may not happen but there is one thing sure:
mb() before arc_emac_tx_avail() can't tell the future.

[...]
> New patch is below. 

The arc_emac_tx_clean() change is wrong.

tx_drity revalidation is still needed in arc_emac_tx after netif_stop_queue.

A barrier is still missing in arc_emac_tx between descriptor release and
tx_curr increase.

-- 
Ueimor
