From: Francois Romieu <romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Wed, 18 May 2016 02:01:53 +0200
Message-ID: <20160518000153.GA21757@electric-eye.fr.zoreil.com>
References: <20160517152520.GA2750@debian-dorm>
 <20160517.142456.2247845107325931733.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160517.142456.2247845107325931733.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> :
> From: Shuyu Wei <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 17 May 2016 23:25:20 +0800
> 
> > diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> > index a3a9392..df3dfef 100644
> > --- a/drivers/net/ethernet/arc/emac_main.c
> > +++ b/drivers/net/ethernet/arc/emac_main.c
> > @@ -153,9 +153,8 @@ static void arc_emac_tx_clean(struct net_device *ndev)
> >  {
> >  	struct arc_emac_priv *priv = netdev_priv(ndev);
> >  	struct net_device_stats *stats = &ndev->stats;
> > -	unsigned int i;
> >  
> > -	for (i = 0; i < TX_BD_NUM; i++) {
> > +	while (priv->txbd_dirty != priv->txbd_curr) {
> >  		unsigned int *txbd_dirty = &priv->txbd_dirty;
> >  		struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
> >  		struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
> > @@ -685,13 +684,15 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
> >  	wmb();
> >  
> >  	skb_tx_timestamp(skb);
> > +	priv->tx_buff[*txbd_curr].skb = skb;
> > +
> > +	dma_wmb();
> >  
> >  	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
> >  
> >  	/* Make sure info word is set */
> >  	wmb();
> >  
> > -	priv->tx_buff[*txbd_curr].skb = skb;
> >  
> >  	/* Increment index to point to the next BD */
> >  	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
> > 
> 
> These memory barriers do not look correct to me.
> 
> dma_wmb() is about visibility between CPU reads/writes and device
> accesses to a piece of memory.  But what you're concerned about wrt.
> the SKB pointer assignment is CPU to CPU accesses.  Therefore something
> like smp_wmb() would be appropriate.

Something like:

 	skb_tx_timestamp(skb);

	/* CPU write vs device access. Must be done before releasing control
	 * of the descriptor (*info).
	 */
	dma_wmb();

	priv->tx_buff[*txbd_curr].skb = skb;

	/* CPU arc_emac_tx_clean vs CPU arc_emac_tx. Must be done before
	 * index (tx_curr) update. Does not necessarily deserves to be done
	 * before releasing control of the descriptor (*info) due to
	 * descriptor vs index ordering.
	 *
	 * FIXME: missing smp_rmb before the while loop in arc_emac_tx_clean.
	 */
	smp_wmb();

 	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);

	/* local descriptor (*info) update vs index (tx_curr) update. */
 	wmb();

	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;

	smp_mb();	// The driver alreay contains this one.

The smp_wmb() and wmb() could be made side-by-side once *info is
updated but I don't see the adequate idiom to improve the smp_wmb + wmb
combo. :o/

> And the wmb() looks like it should be a dma_wmb().

I see two points against it:
- it could be too late for skb_tx_timestamp().
- arc_emac_tx_clean must not see an index update before the device
  got a chance to acquire the descriptor. arc_emac_tx_clean can't
  tell the difference between an about-to-be-released descriptor
  and a returned-from-device one.

-- 
Ueimor
