From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 18:27:45 +0200
Message-ID: <CALzJLG9iCWkk2WTGrkFhZ61Sx5R-JDCxANhLQZPO8E47QGwOmQ@mail.gmail.com>
References: <20140903165943.372b897b@redhat.com> <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
 <20161116131609.4e5726b4@redhat.com> <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
 <20161116234022.2bad179b@redhat.com> <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117091638.5fab8494@redhat.com> <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117144248.23500001@redhat.com> <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117155753.17b76f5a@redhat.com> <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117193021.580589ae@redhat.com> <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161121170351.50a09ee1@redhat.com> <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_G3G-_jFFD0xiAOfR-k69rhb_2ia4LHZroE-oEFxApnQ@mail.gmail.com> <1480520661.18162.177.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:32993 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753283AbcK3Q2I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:28:08 -0500
Received: by mail-lf0-f65.google.com with SMTP id 98so16302787lfs.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 08:28:07 -0800 (PST)
In-Reply-To: <1480520661.18162.177.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 5:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-11-30 at 15:50 +0200, Saeed Mahameed wrote:
>> On Tue, Nov 29, 2016 at 8:58 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Mon, 2016-11-21 at 10:10 -0800, Eric Dumazet wrote:
>> >
>> >
>> >> Not sure it this has been tried before, but the doorbell avoidance could
>> >> be done by the driver itself, because it knows a TX completion will come
>> >> shortly (well... if softirqs are not delayed too much !)
>> >>
>> >> Doorbell would be forced only if :
>> >>
>> >> (    "skb->xmit_more is not set" AND "TX engine is not 'started yet'" )
>> >> OR
>> >> ( too many [1] packets were put in TX ring buffer, no point deferring
>> >> more)
>> >>
>> >> Start the pump, but once it is started, let the doorbells being done by
>> >> TX completion.
>> >>
>> >> ndo_start_xmit and TX completion handler would have to maintain a shared
>> >> state describing if packets were ready but doorbell deferred.
>> >>
>> >>
>> >> Note that TX completion means "if at least one packet was drained",
>> >> otherwise busy polling, constantly calling napi->poll() would force a
>> >> doorbell too soon for devices sharing a NAPI for both RX and TX.
>> >>
>> >> But then, maybe busy poll would like to force a doorbell...
>> >>
>> >> I could try these ideas on mlx4 shortly.
>> >>
>> >>
>> >> [1] limit could be derived from active "ethtool -c" params, eg tx-frames
>> >
>> > I have a WIP, that increases pktgen rate by 75 % on mlx4 when bulking is
>> > not used.
>>
>> Hi Eric, Nice Idea indeed and we need something like this,
>> today we almost don't exploit the TX bulking at all.
>>
>> But please see below, i am not sure different contexts should share
>> the doorbell ringing, it is really risky.
>>
>> >  drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    2
>> >  drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   90 +++++++++++------
>> >  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    4
>> >  include/linux/netdevice.h                    |    1
>> >  net/core/net-sysfs.c                         |   18 +++
>> >  5 files changed, 83 insertions(+), 32 deletions(-)
>> >
>> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> > index 6562f78b07f4..fbea83218fc0 100644
>> > --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> > @@ -1089,7 +1089,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>> >
>> >         if (polled) {
>> >                 if (doorbell_pending)
>> > -                       mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq->ring]);
>> > +                       mlx4_en_xmit_doorbell(dev, priv->tx_ring[TX_XDP][cq->ring]);
>> >
>> >                 mlx4_cq_set_ci(&cq->mcq);
>> >                 wmb(); /* ensure HW sees CQ consumer before we post new buffers */
>> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> > index 4b597dca5c52..affebb435679 100644
>> > --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> > @@ -67,7 +67,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
>> >         ring->size = size;
>> >         ring->size_mask = size - 1;
>> >         ring->sp_stride = stride;
>> > -       ring->full_size = ring->size - HEADROOM - MAX_DESC_TXBBS;
>> > +       ring->full_size = ring->size - HEADROOM - 2*MAX_DESC_TXBBS;
>> >
>> >         tmp = size * sizeof(struct mlx4_en_tx_info);
>> >         ring->tx_info = kmalloc_node(tmp, GFP_KERNEL | __GFP_NOWARN, node);
>> > @@ -193,6 +193,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
>> >         ring->sp_cqn = cq;
>> >         ring->prod = 0;
>> >         ring->cons = 0xffffffff;
>> > +       ring->ncons = 0;
>> >         ring->last_nr_txbb = 1;
>> >         memset(ring->tx_info, 0, ring->size * sizeof(struct mlx4_en_tx_info));
>> >         memset(ring->buf, 0, ring->buf_size);
>> > @@ -227,9 +228,9 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
>> >                        MLX4_QP_STATE_RST, NULL, 0, 0, &ring->sp_qp);
>> >  }
>> >
>> > -static inline bool mlx4_en_is_tx_ring_full(struct mlx4_en_tx_ring *ring)
>> > +static inline bool mlx4_en_is_tx_ring_full(const struct mlx4_en_tx_ring *ring)
>> >  {
>> > -       return ring->prod - ring->cons > ring->full_size;
>> > +       return READ_ONCE(ring->prod) - READ_ONCE(ring->cons) > ring->full_size;
>> >  }
>> >
>> >  static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
>> > @@ -374,6 +375,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
>> >
>> >         /* Skip last polled descriptor */
>> >         ring->cons += ring->last_nr_txbb;
>> > +       ring->ncons += ring->last_nr_txbb;
>> >         en_dbg(DRV, priv, "Freeing Tx buf - cons:0x%x prod:0x%x\n",
>> >                  ring->cons, ring->prod);
>> >
>> > @@ -389,6 +391,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
>> >                                                 !!(ring->cons & ring->size), 0,
>> >                                                 0 /* Non-NAPI caller */);
>> >                 ring->cons += ring->last_nr_txbb;
>> > +               ring->ncons += ring->last_nr_txbb;
>> >                 cnt++;
>> >         }
>> >
>> > @@ -401,6 +404,38 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
>> >         return cnt;
>> >  }
>> >
>> > +void mlx4_en_xmit_doorbell(const struct net_device *dev,
>> > +                          struct mlx4_en_tx_ring *ring)
>> > +{
>> > +
>> > +       if (dev->doorbell_opt & 1) {
>> > +               u32 oval = READ_ONCE(ring->prod_bell);
>> > +               u32 nval = READ_ONCE(ring->prod);
>> > +
>> > +               if (oval == nval)
>> > +                       return;
>> > +
>> > +               /* I can not tell yet if a cmpxchg() is needed or not */
>> > +               if (dev->doorbell_opt & 2)
>> > +                       WRITE_ONCE(ring->prod_bell, nval);
>> > +               else
>> > +                       if (cmpxchg(&ring->prod_bell, oval, nval) != oval)
>> > +                               return;
>> > +       }
>> > +       /* Since there is no iowrite*_native() that writes the
>> > +        * value as is, without byteswapping - using the one
>> > +        * the doesn't do byteswapping in the relevant arch
>> > +        * endianness.
>> > +        */
>> > +#if defined(__LITTLE_ENDIAN)
>> > +       iowrite32(
>> > +#else
>> > +       iowrite32be(
>> > +#endif
>> > +                 ring->doorbell_qpn,
>> > +                 ring->bf.uar->map + MLX4_SEND_DOORBELL);
>> > +}
>> > +
>> >  static bool mlx4_en_process_tx_cq(struct net_device *dev,
>> >                                   struct mlx4_en_cq *cq, int napi_budget)
>> >  {
>> > @@ -496,8 +531,13 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
>> >         wmb();
>> >
>> >         /* we want to dirty this cache line once */
>> > -       ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
>> > -       ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
>> > +       WRITE_ONCE(ring->last_nr_txbb, last_nr_txbb);
>> > +       ring_cons += txbbs_skipped;
>> > +       WRITE_ONCE(ring->cons, ring_cons);
>> > +       WRITE_ONCE(ring->ncons, ring_cons + last_nr_txbb);
>> > +
>> > +       if (dev->doorbell_opt)
>> > +               mlx4_en_xmit_doorbell(dev, ring);
>> >
>> >         if (ring->free_tx_desc == mlx4_en_recycle_tx_desc)
>> >                 return done < budget;
>> > @@ -725,29 +765,14 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
>> >         __iowrite64_copy(dst, src, bytecnt / 8);
>> >  }
>> >
>> > -void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring)
>> > -{
>> > -       wmb();
>>
>> you missed/removed this "wmb()" in the new function, why ? where did
>> you compensate for it ?
>
> I removed it because I had a cmpxchg() there if the barrier was needed.
>

Cool, so the answer is yes, the barrier is needed in order for the HW
to see the last step of
mlx4_en_tx_write_desc where we write the ownership bit (which means
this descriptor is valid for HW processing).
tx_desc->ctrl.owner_opcode = op_own;

ringing the doorbell without this wmb might cause the HW to miss that
last packet.

> My patch is a WIP, where you can set the bit 2 to ask to replace the
> cmpxchg() by a simple write, only for performance testing/comparisons.
>
>
>>
>> > -       /* Since there is no iowrite*_native() that writes the
>> > -        * value as is, without byteswapping - using the one
>> > -        * the doesn't do byteswapping in the relevant arch
>> > -        * endianness.
>> > -        */
>> > -#if defined(__LITTLE_ENDIAN)
>> > -       iowrite32(
>> > -#else
>> > -       iowrite32be(
>> > -#endif
>> > -                 ring->doorbell_qpn,
>> > -                 ring->bf.uar->map + MLX4_SEND_DOORBELL);
>> > -}
>> >
>> >  static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
>> >                                   struct mlx4_en_tx_desc *tx_desc,
>> >                                   union mlx4_wqe_qpn_vlan qpn_vlan,
>> >                                   int desc_size, int bf_index,
>> >                                   __be32 op_own, bool bf_ok,
>> > -                                 bool send_doorbell)
>> > +                                 bool send_doorbell,
>> > +                                 const struct net_device *dev, int nr_txbb)
>> >  {
>> >         tx_desc->ctrl.qpn_vlan = qpn_vlan;
>> >
>> > @@ -761,6 +786,7 @@ static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
>> >
>> >                 wmb();
>> >
>> > +               ring->prod += nr_txbb;
>> >                 mlx4_bf_copy(ring->bf.reg + ring->bf.offset, &tx_desc->ctrl,
>> >                              desc_size);
>> >
>> > @@ -773,8 +799,9 @@ static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
>> >                  */
>> >                 dma_wmb();
>> >                 tx_desc->ctrl.owner_opcode = op_own;
>> > +               ring->prod += nr_txbb;
>> >                 if (send_doorbell)
>> > -                       mlx4_en_xmit_doorbell(ring);
>> > +                       mlx4_en_xmit_doorbell(dev, ring);
>> >                 else
>> >                         ring->xmit_more++;
>> >         }
>> > @@ -1017,8 +1044,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>> >                         op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);
>> >         }
>> >
>> > -       ring->prod += nr_txbb;
>> > -
>> >         /* If we used a bounce buffer then copy descriptor back into place */
>> >         if (unlikely(bounce))
>> >                 tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
>> > @@ -1033,6 +1058,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>> >         }
>> >         send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
>> >
>> > +       /* Doorbell avoidance : We can omit doorbell if we know a TX completion
>> > +        * will happen shortly.
>> > +        */
>> > +       if (send_doorbell &&
>> > +           dev->doorbell_opt &&
>> > +           (s32)(READ_ONCE(ring->prod_bell) - READ_ONCE(ring->ncons)) > 0)
>>
>> Aelexi already expressed his worries about synchronization, and i
>> think here (in this exact line) sits the problem,
>> what about if exactly at this point the TX completion handler just
>> finished and rang the last doorbell,
>> you didn't write the new TX descriptor yet (mlx4_en_tx_write_desc), so
>> the last doorbell from the CQ handler missed it.
>> even if you wrote the TX descriptor before the doorbell decision here,
>> you will need a memory barrier to make sure the HW sees
>> the new packet, which was typically done before ringing the doorbell.
>
>
> My patch is a WIP, meaning it is not completed ;)
>
> Surely we can find a non racy way to handle this.

The question is, can it be done without locking ? Maybe ring the
doorbell every N msecs  just in case.

>
>
>> All in all, this is risky business :),  the right way to go is to
>> force the upper layer to use xmit-more and delay doorbells/use bulking
>> but from the same context
>> (xmit routine).  For example see Achiad's suggestion (attached in
>> Jesper's response), he used stop queue to force the stack to queue up
>> packets (TX bulking)
>> which would set xmit-more and will use the next completion to release
>> the "stopped" ring TXQ rather than hit the doorbell on behalf of it.
>
>
>
> Well, you depend on having a higher level queue like a qdisc.
>
> Some users do not use a qdisc.
> If you stop the queue, they no longer can send anything -> drops.
>

In this case, i think they should implement their own bulking (pktgen
is not a good example)
but XDP can predict if it has more packets to xmit  as long as all of
them fall in the same NAPI cycle.
Others should try and do the same.
