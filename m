From: Shuyu Wei <wsy2220@gmail.com>
Subject: Re: [PATCH] ethernet:arc: Fix racing of TX ring buffer
Date: Sun, 15 May 2016 07:10:44 +0800
Message-ID: <20160514231044.GA2968@debian-dorm>
References: <20160514161602.GA3347@debian-dorm>
 <20160514200356.GA14105@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wxt@rock-chips.com, davem@davemloft.net, heiko@sntech.de,
	linux-rockchip@lists.infradead.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36481 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810AbcENXKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 19:10:49 -0400
Received: by mail-pa0-f65.google.com with SMTP id xm6so676125pab.3
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 16:10:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160514200356.GA14105@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2016 at 10:03:56PM +0200, Francois Romieu wrote:
> Shuyu Wei <wsy2220@gmail.com> :
> > The tail of the ring buffer(txbd_dirty) should never go ahead of the
> > head(txbd_curr) or the ring buffer will corrupt. 
> > 
> > This is the root cause of racing.
> 
> No (see below).
> 
> It may suffer from some barrier illness though.
> 
> > Besides, setting the FOR_EMAC flag should be the last step of modifying
> > the buffer descriptor, or possible racing will occur.
> 
> (s/Besides//)
> 
> Yes. Good catch.
> 
> > Signed-off-by: Shuyu Wei <sy.w@outlook.com>
> > ---
> > 
> > diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> > index a3a9392..5ece05b 100644
> > --- a/drivers/net/ethernet/arc/emac_main.c
> > +++ b/drivers/net/ethernet/arc/emac_main.c
> > @@ -155,7 +155,7 @@ static void arc_emac_tx_clean(struct net_device *ndev)
> >         struct net_device_stats *stats = &ndev->stats;
> >         unsigned int i;
> >  
> > -       for (i = 0; i < TX_BD_NUM; i++) {
> > +       for (i = priv->txbd_dirty; i != priv->txbd_curr; i = (i + 1) % TX_BD_NUM) {
> >                 unsigned int *txbd_dirty = &priv->txbd_dirty;
> >                 struct arc_emac_bd *txbd = &priv->txbd[*txbd_dirty];
> >                 struct buffer_state *tx_buff = &priv->tx_buff[*txbd_dirty];
> 
> "i" is only used as a loop counter in arc_emac_tx_clean. It is not even
> used as an index to dereference an array or whatever. Only "priv->txbd_dirty"
> is used.
> 
> arc_emac_tx_clean() checks FOR_EMAC, skb, and dirty tx data. It takes care of
> clearing those itself. Thus, (memory / io barrier considerations apart) it can
> only proceed beyond its own "if ((info & FOR_EMAC) || !txbd->data || !skb)"
> check if arc_emac_tx wrote all of those.
> 
> Where they are used as loop counters, both TX_BD_NUM and txbd_curr - txbd_dirty
> can be considered as hints (please note that unsigned arithmetic can replace
> the "%" sludgehammer here).
> 
> > @@ -686,12 +686,12 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
> >  
> >         skb_tx_timestamp(skb);
> 
> > +       priv->tx_buff[*txbd_curr].skb = skb;
> 
> 	dma_wmb();
> 
> (sync writes to memory before releasing descriptor)
> 
> >         *info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
> >  
> >         /* Make sure info word is set */
> >         wmb();
> 
> arc_emac_tx_clean can run from this point.
> 
> txbd_curr is still not set (and it does need to). So, if you insist
> on txbd_curr appearing in arc_emac_tx_clean::for(...), it's perfectly
> possible to ignore a sent packet.
> 
> I ignored arc_reg_set() at the end of arc_emac_tx(). I have no idea
> if it is posted nor if it forces the chipset to read the descriptors
> (synchronously ?) so part of the sentence above could be wrong.
> 
> You have found a big offender in arc_emac_tx() but the arc_emac_tx_clean()
> part is imho useless, incorrectly understood or misworded.
> 
> -- 
> Ueimor


Hi, Ueimor. Thanks for your reply.

I don't think taking txbd_curr and txbd_dirty only as hints is a good idea.
That could be a big waste, since tx_clean have to go through all the txbds.
I tried your advice, Tx throughput can only reach 5.52MB/s.

Leaving one sent packet in tx_clean is acceptable if we respect to txbd_curr
and txbd_dirty, since the ignored packet will be cleaned when new packets
arrive.

>  for (i = priv->txbd_dirty; i != priv->txbd_curr; i = (i + 1) % TX_BD_NUM) {
In fact, the loop above will always ignore one or two sent packet, the loop
below can free all packets or leave one if txbd_curr is not updated. I
use the above one since it is clearer.

  for (i = priv->txbd_dirty; (i + 1) % TX_BD_NUM != priv->txbd_curr; i = (i + 1) % TX_BD_NUM) {
