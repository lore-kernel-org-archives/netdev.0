From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V1 2/3] mlx4: use napi_alloc_skb API to get SKB
 bulk allocations
Date: Mon, 9 May 2016 22:05:27 +0200
Message-ID: <20160509220527.0ccb2b72@redhat.com>
References: <20160509134352.3573.37044.stgit@firesoul>
	<20160509134434.3573.87133.stgit@firesoul>
	<CAKgT0UdcAzpYnqvv8HkMaPoPxLPj5-iJpwzdJWVKX9DfYJoYyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816AbcEIUFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 16:05:32 -0400
In-Reply-To: <CAKgT0UdcAzpYnqvv8HkMaPoPxLPj5-iJpwzdJWVKX9DfYJoYyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 May 2016 09:47:08 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Mon, May 9, 2016 at 6:44 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > Activate the bulk alloc API, simply by changing mlx4 from using
> > netdev_alloc_skb() to using napi_alloc_skb().  
> 
> This patch is just enabling the napi_alloc_skb call.  You don't need
> to call out that it is enabling bulk allocations.  This patch could
> stand on its own without needing to make reference to the bulk
> allocation API because there is enough of a gain from napi_alloc_skb
> replacing netdev_alloc_skb.

Okay, I see you point.
 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/en_rx.c |    7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > index 8ef6875b6cf9..84fd6db5a176 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > @@ -577,14 +577,15 @@ fail:
> >  static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
> >                                       struct mlx4_en_rx_desc *rx_desc,
> >                                       struct mlx4_en_rx_alloc *frags,
> > -                                     unsigned int length)
> > +                                     unsigned int length,
> > +                                     struct napi_struct *napi)  
> 
> Instead of passing the NAPI structure you could just pass the
> mlx4_en_cq pointer to be used by the NAPI alloc function.  In addition
> you might try adding the new parameter before length since that way
> the pointers are in one block followed by integers in a tapering
> length order.

Okay, will adjust.

> >  {
> >         struct sk_buff *skb;
> >         void *va;
> >         int used_frags;
> >         dma_addr_t dma;
> >
> > -       skb = netdev_alloc_skb(priv->dev, SMALL_PACKET_SIZE + NET_IP_ALIGN);
> > +       skb = napi_alloc_skb(napi, SMALL_PACKET_SIZE + NET_IP_ALIGN);  
> 
> The NET_IP_ALIGN is redundant as napi_alloc_skb already takes are of
> adding that and NET_SKB_PAD.

Thanks for catching this.
 
> >         if (!skb) {
> >                 en_dbg(RX_ERR, priv, "Failed allocating skb\n");
> >                 return NULL;
> > @@ -932,7 +933,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >                 }
> >
> >                 /* GRO not possible, complete processing here */
> > -               skb = mlx4_en_rx_skb(priv, rx_desc, frags, length);
> > +               skb = mlx4_en_rx_skb(priv, rx_desc, frags, length, &cq->napi);
> >                 if (!skb) {
> >                         ring->dropped++;
> >                         goto next;
> >  



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
