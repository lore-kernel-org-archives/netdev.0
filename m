From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 3/3] net: bcmgenet: fix dmadesc_set()
Date: Mon, 4 Apr 2016 18:11:46 -0700
Message-ID: <CAGXr9JHXbZ2r4ci7V95+-VKmuv3DOgE4i==kUAVJEDbG__h-+w@mail.gmail.com>
References: <1459815001-91703-1-git-send-email-pgynther@google.com>
	<1459815001-91703-3-git-send-email-pgynther@google.com>
	<CAGVrzca5=a3tewe=DGpYZwmk38NTWOjpZFyYxJGJue=OgDGo=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>, opendmb@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:35903 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbcDEBLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 21:11:48 -0400
Received: by mail-vk0-f41.google.com with SMTP id c4so77363737vkb.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 18:11:47 -0700 (PDT)
In-Reply-To: <CAGVrzca5=a3tewe=DGpYZwmk38NTWOjpZFyYxJGJue=OgDGo=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Mon, Apr 4, 2016 at 5:58 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>
> 2016-04-04 17:10 GMT-07:00 Petri Gynther <pgynther@google.com>:
> > dmadesc_set() is used for setting the Tx buffer DMA address, length,
> > and status bits on a Tx ring descriptor when a frame is being Tx'ed.
> >
> > Always set the Tx buffer DMA address first, before updating the length
> > and status bits, i.e. giving the Tx descriptor to the hardware.
>
> Does this fix any real bug you have observed? The hardware won't
> transmit anything until you start writing the correct TDMA producer
> index. Also, dmadesc_set_length_status and dmadesc_set_addr both use
> I/O accessors which use a volatile, so they should not be re-ordered
> relative to each other.
>
> I do agree that the change looks like how it should be done, I am just
> questioning the qualification of this as a fix or not.
>
> Thanks!

You are right. Nothing is transmitted until TDMA producer index is
incremented, and that happens after dmadesc_set() has been called.

So, this is really just a cleanup. Perhaps not worth it, after all.

But I do have a question -- do we need wmb() in bcmgenet_xmit(), just
before we kick the TDMA producer index, to ensure Tx descriptor writes
have been completed?

@@ -1606,6 +1606,7 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff
*skb, struct net_device *dev)

        if (!skb->xmit_more || netif_xmit_stopped(txq)) {
                /* Packets are ready, update producer index */
+               wmb();
                bcmgenet_tdma_ring_writel(priv, ring->index,
                                          ring->prod_index, TDMA_PROD_INDEX);

>
>
> >
> > Signed-off-by: Petri Gynther <pgynther@google.com>
> > ---
> >  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> > index d77cd6d..f7b42b9 100644
> > --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> > +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> > @@ -104,8 +104,8 @@ static inline void dmadesc_set_addr(struct bcmgenet_priv *priv,
> >  static inline void dmadesc_set(struct bcmgenet_priv *priv,
> >                                void __iomem *d, dma_addr_t addr, u32 val)
> >  {
> > -       dmadesc_set_length_status(priv, d, val);
> >         dmadesc_set_addr(priv, d, addr);
> > +       dmadesc_set_length_status(priv, d, val);
> >  }
> >
> >  static inline dma_addr_t dmadesc_get_addr(struct bcmgenet_priv *priv,
> > --
> > 2.8.0.rc3.226.g39d4020
> >
>
>
>
> --
> Florian
