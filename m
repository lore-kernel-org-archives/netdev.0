From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Fri, 27 Mar 2009 11:23:04 +0100
Message-ID: <OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se> <2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, pku.leo@gmail.com
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:54690 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752699AbZC0KXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2009 06:23:08 -0400
In-Reply-To: <2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pku.leo@gmail.com wrote on 27/03/2009 10:45:12:
> On Fri, Mar 27, 2009 at 1:44 AM, Joakim Tjernlund
> <Joakim.Tjernlund@transmode.se> wrote:
> > The line:
> >  if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
> >       break;
> > in ucc_geth_tx() didn not make sense to me. Rework & cleanup
> > this logic to something understandable.
> > ---
> >
> > Reworked the patch according to Antons comments.
> >
> >  drivers/net/ucc_geth.c |   66 
+++++++++++++++++++++++++++--------------------
> >  1 files changed, 38 insertions(+), 28 deletions(-)
> >
> > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> > index 7fc91aa..465de3a 100644
> > --- a/drivers/net/ucc_geth.c
> > +++ b/drivers/net/ucc_geth.c
> > @@ -161,6 +161,17 @@ static struct ucc_geth_info ugeth_primary_info = 
{
> >
> >  static struct ucc_geth_info ugeth_info[8];
> >
> > +
> > +static inline u32 __iomem *bd2buf(u8 __iomem *bd)
> > +{
> > +       return (u32 __iomem *)(bd+4);
> > +}
> > +
> > +static inline u32 __iomem *bd2status(u8 __iomem *bd)
> > +{
> > +       return (u32 __iomem *)bd;
> > +}
> 
> 
> When the driver was reviewed for upstream merge, I was told to remove
> this kind of thing in favor of direct struct qe_bd access.  So do we
> really have a guideline on this?  Or it's just a matter of personal
> preference?

This is a bit better than the current type casts. Moving over to qe_bd
accesses is a bigger cleanup that will have to be a seperate patch.
I am not sure it is an all win as you probably loose the ability
to read both status and len in one access.

> 
> > +
> >  #ifdef DEBUG
> >  static void mem_disp(u8 *addr, int size)
> >  {
> > @@ -3048,6 +3059,7 @@ static int ucc_geth_start_xmit(struct sk_buff 
*skb, struct net_device *dev)
> >        u8 __iomem *bd;                 /* BD pointer */
> >        u32 bd_status;
> >        u8 txQ = 0;
> > +       int tx_ind;
> >
> >        ugeth_vdbg("%s: IN", __func__);
> >
> > @@ -3057,21 +3069,19 @@ static int ucc_geth_start_xmit(struct sk_buff 
*skb, struct net_device *dev)
> >
> >        /* Start from the next BD that should be filled */
> >        bd = ugeth->txBd[txQ];
> > -       bd_status = in_be32((u32 __iomem *)bd);
> > +       bd_status = in_be32(bd2status(bd));
> >        /* Save the skb pointer so we can free it later */
> > -       ugeth->tx_skbuff[txQ][ugeth->skb_curtx[txQ]] = skb;
> > +       tx_ind = ugeth->skb_curtx[txQ];
> > +       ugeth->tx_skbuff[txQ][tx_ind] = skb;
> >
> >        /* Update the current skb pointer (wrapping if this was the 
last) */
> > -       ugeth->skb_curtx[txQ] =
> > -           (ugeth->skb_curtx[txQ] +
> > -            1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
> > +       tx_ind = (tx_ind + 1) & 
TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
> > +       ugeth->skb_curtx[txQ] = tx_ind;
> >
> >        /* set up the buffer descriptor */
> > -       out_be32(&((struct qe_bd __iomem *)bd)->buf,
> > -                     dma_map_single(&ugeth->dev->dev, skb->data,
> > -                             skb->len, DMA_TO_DEVICE));
> > -
> > -       /* printk(KERN_DEBUG"skb->data is 0x%x\n",skb->data); */
> > +       out_be32(bd2buf(bd),
> > +                dma_map_single(&ugeth->dev->dev, skb->data,
> > +                               skb->len, DMA_TO_DEVICE));
> >
> >        bd_status = (bd_status & T_W) | T_R | T_I | T_L | skb->len;
> >
> > @@ -3088,9 +3098,9 @@ static int ucc_geth_start_xmit(struct sk_buff 
*skb, struct net_device *dev)
> >
> >        /* If the next BD still needs to be cleaned up, then the bds
> >           are full.  We need to tell the kernel to stop sending us 
stuff. */
> > -       if (bd == ugeth->confBd[txQ]) {
> > -               if (!netif_queue_stopped(dev))
> > -                       netif_stop_queue(dev);
> > +
> > +       if (!in_be32(bd2buf(bd))) {
> > +               netif_stop_queue(dev);
> 
> Why does this make more sense?  The BD with a NULL buffer means the
> ring is full?  It's not the normal case.
> 
> >        }
> >
> >        ugeth->txBd[txQ] = bd;
> > @@ -3198,41 +3208,41 @@ static int ucc_geth_tx(struct net_device *dev, 
u8 txQ)
> >        struct ucc_geth_private *ugeth = netdev_priv(dev);
> >        u8 __iomem *bd;         /* BD pointer */
> >        u32 bd_status;
> > +       int tx_ind, num_freed;
> >
> >        bd = ugeth->confBd[txQ];
> > -       bd_status = in_be32((u32 __iomem *)bd);
> > -
> > +       bd_status = in_be32(bd2status(bd));
> > +       tx_ind = ugeth->skb_dirtytx[txQ];
> > +       num_freed = 0;
> >        /* Normal processing. */
> >        while ((bd_status & T_R) == 0) {
> >                /* BD contains already transmitted buffer.   */
> >                /* Handle the transmitted buffer and release */
> >                /* the BD to be used with the current frame  */
> >
> > -               if ((bd == ugeth->txBd[txQ]) && 
(netif_queue_stopped(dev) == 0))
> > -                       break;
> > +               if (bd == ugeth->txBd[txQ])
> > +                       break; /* Queue is empty */
> >
> >                dev->stats.tx_packets++;
> >
> >                /* Free the sk buffer associated with this TxBD */
> > -               dev_kfree_skb(ugeth->
> > -                                 
tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
> > -               ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] = NULL;
> > -               ugeth->skb_dirtytx[txQ] =
> > -                   (ugeth->skb_dirtytx[txQ] +
> > -                    1) & 
TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
> > -
> > -               /* We freed a buffer, so now we can restart 
transmission */
> > -               if (netif_queue_stopped(dev))
> > -                       netif_wake_queue(dev);
> > +               dev_kfree_skb(ugeth->tx_skbuff[txQ][tx_ind]);
> > +               ugeth->tx_skbuff[txQ][tx_ind] = NULL;
> > +               out_be32(bd2buf(bd), 0); /* Mark it free */
> 
> Now I see why you depend on the buffer to judge if the BD ring is
> full.  If you want to do this, make sure it's well documented in code,
> or others will be confused.  And as Anton already commented, in/out
> access is slow.  I think the original way can be fixed if you think
> it's broken, and will have better performance.

The code could use a better comment, but I really think this method
is superior and more robust. The problem is that in/out functions is
much slower than it has to be for QE IO memory.

The original way is broken and I tired to fix it but it always broke
as soon one applied some load.

 Jocke 

