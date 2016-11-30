From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 15:50:07 +0200
Message-ID: <CALzJLG_G3G-_jFFD0xiAOfR-k69rhb_2ia4LHZroE-oEFxApnQ@mail.gmail.com>
References: <20140903165943.372b897b@redhat.com> <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
 <20161116131609.4e5726b4@redhat.com> <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
 <20161116234022.2bad179b@redhat.com> <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117091638.5fab8494@redhat.com> <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117144248.23500001@redhat.com> <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117155753.17b76f5a@redhat.com> <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117193021.580589ae@redhat.com> <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161121170351.50a09ee1@redhat.com> <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33281 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754706AbcK3Nua (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 08:50:30 -0500
Received: by mail-lf0-f65.google.com with SMTP id 98so15827139lfs.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 05:50:29 -0800 (PST)
In-Reply-To: <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 8:58 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-11-21 at 10:10 -0800, Eric Dumazet wrote:
>
>
>> Not sure it this has been tried before, but the doorbell avoidance could
>> be done by the driver itself, because it knows a TX completion will come
>> shortly (well... if softirqs are not delayed too much !)
>>
>> Doorbell would be forced only if :
>>
>> (    "skb->xmit_more is not set" AND "TX engine is not 'started yet'" )
>> OR
>> ( too many [1] packets were put in TX ring buffer, no point deferring
>> more)
>>
>> Start the pump, but once it is started, let the doorbells being done by
>> TX completion.
>>
>> ndo_start_xmit and TX completion handler would have to maintain a shared
>> state describing if packets were ready but doorbell deferred.
>>
>>
>> Note that TX completion means "if at least one packet was drained",
>> otherwise busy polling, constantly calling napi->poll() would force a
>> doorbell too soon for devices sharing a NAPI for both RX and TX.
>>
>> But then, maybe busy poll would like to force a doorbell...
>>
>> I could try these ideas on mlx4 shortly.
>>
>>
>> [1] limit could be derived from active "ethtool -c" params, eg tx-frames
>
> I have a WIP, that increases pktgen rate by 75 % on mlx4 when bulking is
> not used.

Hi Eric, Nice Idea indeed and we need something like this,
today we almost don't exploit the TX bulking at all.

But please see below, i am not sure different contexts should share
the doorbell ringing, it is really risky.

>  drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    2
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c   |   90 +++++++++++------
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    4
>  include/linux/netdevice.h                    |    1
>  net/core/net-sysfs.c                         |   18 +++
>  5 files changed, 83 insertions(+), 32 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 6562f78b07f4..fbea83218fc0 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -1089,7 +1089,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>
>         if (polled) {
>                 if (doorbell_pending)
> -                       mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq->ring]);
> +                       mlx4_en_xmit_doorbell(dev, priv->tx_ring[TX_XDP][cq->ring]);
>
>                 mlx4_cq_set_ci(&cq->mcq);
>                 wmb(); /* ensure HW sees CQ consumer before we post new buffers */
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index 4b597dca5c52..affebb435679 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -67,7 +67,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
>         ring->size = size;
>         ring->size_mask = size - 1;
>         ring->sp_stride = stride;
> -       ring->full_size = ring->size - HEADROOM - MAX_DESC_TXBBS;
> +       ring->full_size = ring->size - HEADROOM - 2*MAX_DESC_TXBBS;
>
>         tmp = size * sizeof(struct mlx4_en_tx_info);
>         ring->tx_info = kmalloc_node(tmp, GFP_KERNEL | __GFP_NOWARN, node);
> @@ -193,6 +193,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
>         ring->sp_cqn = cq;
>         ring->prod = 0;
>         ring->cons = 0xffffffff;
> +       ring->ncons = 0;
>         ring->last_nr_txbb = 1;
>         memset(ring->tx_info, 0, ring->size * sizeof(struct mlx4_en_tx_info));
>         memset(ring->buf, 0, ring->buf_size);
> @@ -227,9 +228,9 @@ void mlx4_en_deactivate_tx_ring(struct mlx4_en_priv *priv,
>                        MLX4_QP_STATE_RST, NULL, 0, 0, &ring->sp_qp);
>  }
>
> -static inline bool mlx4_en_is_tx_ring_full(struct mlx4_en_tx_ring *ring)
> +static inline bool mlx4_en_is_tx_ring_full(const struct mlx4_en_tx_ring *ring)
>  {
> -       return ring->prod - ring->cons > ring->full_size;
> +       return READ_ONCE(ring->prod) - READ_ONCE(ring->cons) > ring->full_size;
>  }
>
>  static void mlx4_en_stamp_wqe(struct mlx4_en_priv *priv,
> @@ -374,6 +375,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
>
>         /* Skip last polled descriptor */
>         ring->cons += ring->last_nr_txbb;
> +       ring->ncons += ring->last_nr_txbb;
>         en_dbg(DRV, priv, "Freeing Tx buf - cons:0x%x prod:0x%x\n",
>                  ring->cons, ring->prod);
>
> @@ -389,6 +391,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
>                                                 !!(ring->cons & ring->size), 0,
>                                                 0 /* Non-NAPI caller */);
>                 ring->cons += ring->last_nr_txbb;
> +               ring->ncons += ring->last_nr_txbb;
>                 cnt++;
>         }
>
> @@ -401,6 +404,38 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring)
>         return cnt;
>  }
>
> +void mlx4_en_xmit_doorbell(const struct net_device *dev,
> +                          struct mlx4_en_tx_ring *ring)
> +{
> +
> +       if (dev->doorbell_opt & 1) {
> +               u32 oval = READ_ONCE(ring->prod_bell);
> +               u32 nval = READ_ONCE(ring->prod);
> +
> +               if (oval == nval)
> +                       return;
> +
> +               /* I can not tell yet if a cmpxchg() is needed or not */
> +               if (dev->doorbell_opt & 2)
> +                       WRITE_ONCE(ring->prod_bell, nval);
> +               else
> +                       if (cmpxchg(&ring->prod_bell, oval, nval) != oval)
> +                               return;
> +       }
> +       /* Since there is no iowrite*_native() that writes the
> +        * value as is, without byteswapping - using the one
> +        * the doesn't do byteswapping in the relevant arch
> +        * endianness.
> +        */
> +#if defined(__LITTLE_ENDIAN)
> +       iowrite32(
> +#else
> +       iowrite32be(
> +#endif
> +                 ring->doorbell_qpn,
> +                 ring->bf.uar->map + MLX4_SEND_DOORBELL);
> +}
> +
>  static bool mlx4_en_process_tx_cq(struct net_device *dev,
>                                   struct mlx4_en_cq *cq, int napi_budget)
>  {
> @@ -496,8 +531,13 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
>         wmb();
>
>         /* we want to dirty this cache line once */
> -       ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
> -       ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
> +       WRITE_ONCE(ring->last_nr_txbb, last_nr_txbb);
> +       ring_cons += txbbs_skipped;
> +       WRITE_ONCE(ring->cons, ring_cons);
> +       WRITE_ONCE(ring->ncons, ring_cons + last_nr_txbb);
> +
> +       if (dev->doorbell_opt)
> +               mlx4_en_xmit_doorbell(dev, ring);
>
>         if (ring->free_tx_desc == mlx4_en_recycle_tx_desc)
>                 return done < budget;
> @@ -725,29 +765,14 @@ static void mlx4_bf_copy(void __iomem *dst, const void *src,
>         __iowrite64_copy(dst, src, bytecnt / 8);
>  }
>
> -void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring)
> -{
> -       wmb();

you missed/removed this "wmb()" in the new function, why ? where did
you compensate for it ?

> -       /* Since there is no iowrite*_native() that writes the
> -        * value as is, without byteswapping - using the one
> -        * the doesn't do byteswapping in the relevant arch
> -        * endianness.
> -        */
> -#if defined(__LITTLE_ENDIAN)
> -       iowrite32(
> -#else
> -       iowrite32be(
> -#endif
> -                 ring->doorbell_qpn,
> -                 ring->bf.uar->map + MLX4_SEND_DOORBELL);
> -}
>
>  static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
>                                   struct mlx4_en_tx_desc *tx_desc,
>                                   union mlx4_wqe_qpn_vlan qpn_vlan,
>                                   int desc_size, int bf_index,
>                                   __be32 op_own, bool bf_ok,
> -                                 bool send_doorbell)
> +                                 bool send_doorbell,
> +                                 const struct net_device *dev, int nr_txbb)
>  {
>         tx_desc->ctrl.qpn_vlan = qpn_vlan;
>
> @@ -761,6 +786,7 @@ static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
>
>                 wmb();
>
> +               ring->prod += nr_txbb;
>                 mlx4_bf_copy(ring->bf.reg + ring->bf.offset, &tx_desc->ctrl,
>                              desc_size);
>
> @@ -773,8 +799,9 @@ static void mlx4_en_tx_write_desc(struct mlx4_en_tx_ring *ring,
>                  */
>                 dma_wmb();
>                 tx_desc->ctrl.owner_opcode = op_own;
> +               ring->prod += nr_txbb;
>                 if (send_doorbell)
> -                       mlx4_en_xmit_doorbell(ring);
> +                       mlx4_en_xmit_doorbell(dev, ring);
>                 else
>                         ring->xmit_more++;
>         }
> @@ -1017,8 +1044,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>                         op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);
>         }
>
> -       ring->prod += nr_txbb;
> -
>         /* If we used a bounce buffer then copy descriptor back into place */
>         if (unlikely(bounce))
>                 tx_desc = mlx4_en_bounce_to_desc(priv, ring, index, desc_size);
> @@ -1033,6 +1058,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>         }
>         send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
>
> +       /* Doorbell avoidance : We can omit doorbell if we know a TX completion
> +        * will happen shortly.
> +        */
> +       if (send_doorbell &&
> +           dev->doorbell_opt &&
> +           (s32)(READ_ONCE(ring->prod_bell) - READ_ONCE(ring->ncons)) > 0)

Aelexi already expressed his worries about synchronization, and i
think here (in this exact line) sits the problem,
what about if exactly at this point the TX completion handler just
finished and rang the last doorbell,
you didn't write the new TX descriptor yet (mlx4_en_tx_write_desc), so
the last doorbell from the CQ handler missed it.
even if you wrote the TX descriptor before the doorbell decision here,
you will need a memory barrier to make sure the HW sees
the new packet, which was typically done before ringing the doorbell.

All in all, this is risky business :),  the right way to go is to
force the upper layer to use xmit-more and delay doorbells/use bulking
but from the same context
(xmit routine).  For example see Achiad's suggestion (attached in
Jesper's response), he used stop queue to force the stack to queue up
packets (TX bulking)
which would set xmit-more and will use the next completion to release
the "stopped" ring TXQ rather than hit the doorbell on behalf of it.

> +               send_doorbell = false;
> +
>         real_size = (real_size / 16) & 0x3f;
>
>         bf_ok &= desc_size <= MAX_BF && send_doorbell;
> @@ -1043,7 +1076,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>                 qpn_vlan.fence_size = real_size;
>
>         mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, desc_size, bf_index,
> -                             op_own, bf_ok, send_doorbell);
> +                             op_own, bf_ok, send_doorbell, dev, nr_txbb);
>
>         if (unlikely(stop_queue)) {
>                 /* If queue was emptied after the if (stop_queue) , and before
> @@ -1054,7 +1087,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
>                  */
>                 smp_rmb();
>
> -               ring_cons = ACCESS_ONCE(ring->cons);
>                 if (unlikely(!mlx4_en_is_tx_ring_full(ring))) {
>                         netif_tx_wake_queue(ring->tx_queue);
>                         ring->wake_queue++;
> @@ -1158,8 +1190,6 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
>         rx_ring->xdp_tx++;
>         AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, length);
>
> -       ring->prod += nr_txbb;
> -
>         stop_queue = mlx4_en_is_tx_ring_full(ring);
>         send_doorbell = stop_queue ||
>                                 *doorbell_pending > MLX4_EN_DOORBELL_BUDGET;
> @@ -1173,7 +1203,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
>                 qpn_vlan.fence_size = real_size;
>
>         mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, TXBB_SIZE, bf_index,
> -                             op_own, bf_ok, send_doorbell);
> +                             op_own, bf_ok, send_doorbell, dev, nr_txbb);
>         *doorbell_pending = send_doorbell ? 0 : *doorbell_pending + 1;
>
>         return NETDEV_TX_OK;
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 574bcbb1b38f..c3fd0deda198 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -280,6 +280,7 @@ struct mlx4_en_tx_ring {
>          */
>         u32                     last_nr_txbb;
>         u32                     cons;
> +       u32                     ncons;
>         unsigned long           wake_queue;
>         struct netdev_queue     *tx_queue;
>         u32                     (*free_tx_desc)(struct mlx4_en_priv *priv,
> @@ -290,6 +291,7 @@ struct mlx4_en_tx_ring {
>
>         /* cache line used and dirtied in mlx4_en_xmit() */
>         u32                     prod ____cacheline_aligned_in_smp;
> +       u32                     prod_bell;
>         unsigned int            tx_dropped;
>         unsigned long           bytes;
>         unsigned long           packets;
> @@ -699,7 +701,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
>                                struct mlx4_en_rx_alloc *frame,
>                                struct net_device *dev, unsigned int length,
>                                int tx_ind, int *doorbell_pending);
> -void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring);
> +void mlx4_en_xmit_doorbell(const struct net_device *dev, struct mlx4_en_tx_ring *ring);
>  bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
>                         struct mlx4_en_rx_alloc *frame);
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 4ffcd874cc20..39565b5425a6 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1816,6 +1816,7 @@ struct net_device {
>         DECLARE_HASHTABLE       (qdisc_hash, 4);
>  #endif
>         unsigned long           tx_queue_len;
> +       unsigned long           doorbell_opt;
>         spinlock_t              tx_global_lock;
>         int                     watchdog_timeo;
>
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index b0c04cf4851d..df05f81f5150 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -367,6 +367,23 @@ static ssize_t gro_flush_timeout_store(struct device *dev,
>  }
>  NETDEVICE_SHOW_RW(gro_flush_timeout, fmt_ulong);
>
> +static int change_doorbell_opt(struct net_device *dev, unsigned long val)
> +{
> +       dev->doorbell_opt = val;
> +       return 0;
> +}
> +
> +static ssize_t doorbell_opt_store(struct device *dev,
> +                                 struct device_attribute *attr,
> +                                 const char *buf, size_t len)
> +{
> +       if (!capable(CAP_NET_ADMIN))
> +               return -EPERM;
> +
> +       return netdev_store(dev, attr, buf, len, change_doorbell_opt);
> +}
> +NETDEVICE_SHOW_RW(doorbell_opt, fmt_ulong);
> +
>  static ssize_t ifalias_store(struct device *dev, struct device_attribute *attr,
>                              const char *buf, size_t len)
>  {
> @@ -531,6 +548,7 @@ static struct attribute *net_class_attrs[] = {
>         &dev_attr_phys_port_name.attr,
>         &dev_attr_phys_switch_id.attr,
>         &dev_attr_proto_down.attr,
> +       &dev_attr_doorbell_opt.attr,
>         NULL,
>  };
>  ATTRIBUTE_GROUPS(net_class);
>
>
