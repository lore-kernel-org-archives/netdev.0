From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v7 09/11] net/mlx4_en: add xdp forwarding and data write
 support
Date: Wed, 13 Jul 2016 10:30:01 -0700
Message-ID: <20160713172959.GA7650@gmail.com>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
 <1468272598-21390-10-git-send-email-bblanco@plumgrid.com>
 <CALzJLG8Jv3eYyPLkmrkj-_9w160KcO87jsv3z5an4U1VYkg7PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [209.85.192.170] ([209.85.192.170]:34559 "EHLO
	mail-pf0-f170.google.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751947AbcGMRas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 13:30:48 -0400
Received: by mail-pf0-f170.google.com with SMTP id h14so20556561pfe.1
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 10:30:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALzJLG8Jv3eYyPLkmrkj-_9w160KcO87jsv3z5an4U1VYkg7PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 06:25:28PM +0300, Saeed Mahameed wrote:
> On Tue, Jul 12, 2016 at 12:29 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> > A user will now be able to loop packets back out of the same port using
> > a bpf program attached to xdp hook. Updates to the packet contents from
> > the bpf program is also supported.
> >
> > For the packet write feature to work, the rx buffers are now mapped as
> > bidirectional when the page is allocated. This occurs only when the xdp
> > hook is active.
> >
> > When the program returns a TX action, enqueue the packet directly to a
> > dedicated tx ring, so as to avoid completely any locking. This requires
> > the tx ring to be allocated 1:1 for each rx ring, as well as the tx
> > completion running in the same softirq.
> >
> > Upon tx completion, this dedicated tx ring recycles pages without
> > unmapping directly back to the original rx ring. In steady state tx/drop
> > workload, effectively 0 page allocs/frees will occur.
> >
> > Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  15 ++-
> >  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  19 +++-
> >  drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  14 +++
> >  drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 126 +++++++++++++++++++++++-
> >  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  14 ++-
> >  5 files changed, 181 insertions(+), 7 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > index d3d51fa..10642b1 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> > @@ -1694,6 +1694,11 @@ static int mlx4_en_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
> >         return err;
> >  }
> >
> > +static int mlx4_en_max_tx_channels(struct mlx4_en_priv *priv)
> > +{
> > +       return (MAX_TX_RINGS - priv->rsv_tx_rings) / MLX4_EN_NUM_UP;
> > +}
> > +
> 
> MAX_TX_RING is a software limitation made to limit netdev real_num_tx
> queues for CX3 internal cache utilization,
> in your case the netdev doesn't care about xdp_tx rings, the
> accounting you added in this patch adds a  lot of
> complications and it would be better to have clear separation between
> the two types of tx_rings, in terms of the holding/managing data
> structure.
> 
> I suggest here to leave priv->tx_ring untouched. i.e, don't store the
> xdp_tx rings at the end of it, i.e  priv->tx_ring should only reflect
> the
> netdev real tx queues.
> 
> In case of priv->porg is active, we can allocate and store xdp tx ring
> per rx ring, this tx ring will be allocated and activated
> once the rx ring is created and activated, and store this dedicated tx
> ring  in the rx_ring it self.
> 
> i.e :
> struct mlx4_en_rx_ring {
> [...]
> struct mlx4_en_tx_ring *xdp_tx;
> struct mlx4_en_cq *xdp_tx_cq;
> [...]
> }
> 
> for this the following changes are required.
> 
> @ mlx4_en_create_rx_ring
> [...] // Create the RX ring
> 
> /* create CQ for xdp tx ring */
> node = cpu_to_node(i % num_online_cpus());
> 
> mlx4_en_create_cq(priv, &rx_ring->xdp_tx_cq, prof->tx_ring_size, i, TX, node)
> 
> /* create xdp tx ring */
> mlx4_en_create_tx_ring(priv, &rx_ring->xdp_tx, prof->tx_ring_size,
> TXBB_SIZE, node, -1)
> 
> @mlx4_en_start/stop_port
> /* Configure tx cq's and rings */
> // You will need to configure xdp tx rings same as priv->rx_ring_num rings
> 
> @mlx4_en_poll_tx_cq
> This Also will require a new NAPI handler for xdp rings to replace the
> following line @mlx4_en_poll_tx_cq
> - struct mlx4_en_tx_ring *ring = priv->tx_ring[cq->ring];
> with
> + struct mlx4_en_tx_ring *ring = priv->rx_ring[cq->ring].xdp_tx;
> 
> Or just change cq->ring from ring index to the actual ring pointer.
> 
> Bottom line, my suggestion also started to look complicated :).. but
> still it would look cleaner to separate between netdev rings and xdp
> rings.
> 
I considered this at first too, but it seemed the worse option to me at
the time. There would be a lot of copy/paste as well as new code to
review.
> 
> >  static void mlx4_en_get_channels(struct net_device *dev,
> >                                  struct ethtool_channels *channel)
> >  {
> > @@ -1705,7 +1710,7 @@ static void mlx4_en_get_channels(struct net_device *dev,
> >         channel->max_tx = MLX4_EN_MAX_TX_RING_P_UP;
> >
> >         channel->rx_count = priv->rx_ring_num;
> > -       channel->tx_count = priv->tx_ring_num / MLX4_EN_NUM_UP;
> > +       channel->tx_count = priv->num_tx_rings_p_up;
> >  }
> >
> >  static int mlx4_en_set_channels(struct net_device *dev,
> > @@ -1717,7 +1722,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
> >         int err = 0;
> >
> >         if (channel->other_count || channel->combined_count ||
> > -           channel->tx_count > MLX4_EN_MAX_TX_RING_P_UP ||
> > +           channel->tx_count > mlx4_en_max_tx_channels(priv) ||
> >             channel->rx_count > MAX_RX_RINGS ||
> >             !channel->tx_count || !channel->rx_count)
> >                 return -EINVAL;
> > @@ -1731,7 +1736,8 @@ static int mlx4_en_set_channels(struct net_device *dev,
> >         mlx4_en_free_resources(priv);
> >
> >         priv->num_tx_rings_p_up = channel->tx_count;
> > -       priv->tx_ring_num = channel->tx_count * MLX4_EN_NUM_UP;
> > +       priv->tx_ring_num = channel->tx_count * MLX4_EN_NUM_UP +
> > +                                                       priv->rsv_tx_rings;
> >         priv->rx_ring_num = channel->rx_count;
> >
> >         err = mlx4_en_alloc_resources(priv);
> > @@ -1740,7 +1746,8 @@ static int mlx4_en_set_channels(struct net_device *dev,
> >                 goto out;
> >         }
> >
> > -       netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
> > +       netif_set_real_num_tx_queues(dev, priv->tx_ring_num -
> > +                                                       priv->rsv_tx_rings);
> >         netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
> >
> >         if (dev->num_tc)
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > index 0417023..3257db7 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > @@ -1636,7 +1636,7 @@ int mlx4_en_start_port(struct net_device *dev)
> >                 /* Configure ring */
> >                 tx_ring = priv->tx_ring[i];
> >                 err = mlx4_en_activate_tx_ring(priv, tx_ring, cq->mcq.cqn,
> > -                       i / priv->num_tx_rings_p_up);
> > +                       i / (priv->tx_ring_num / MLX4_EN_NUM_UP));
> >                 if (err) {
> >                         en_err(priv, "Failed allocating Tx ring\n");
> >                         mlx4_en_deactivate_cq(priv, cq);
> > @@ -2022,6 +2022,16 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
> >                         goto err;
> >         }
> >
> > +       /* When rsv_tx_rings is non-zero, each rx ring will have a
> > +        * corresponding tx ring, with the tx completion event for that ring
> > +        * recycling buffers into the cache.
> > +        */
> > +       for (i = 0; i < priv->rsv_tx_rings; i++) {
> > +               int j = (priv->tx_ring_num - priv->rsv_tx_rings) + i;
> > +
> > +               priv->tx_ring[j]->recycle_ring = priv->rx_ring[i];
> > +       }
> > +
> >  #ifdef CONFIG_RFS_ACCEL
> >         priv->dev->rx_cpu_rmap = mlx4_get_cpu_rmap(priv->mdev->dev, priv->port);
> >  #endif
> > @@ -2534,9 +2544,12 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
> >         struct mlx4_en_priv *priv = netdev_priv(dev);
> >         struct mlx4_en_dev *mdev = priv->mdev;
> >         struct bpf_prog *old_prog;
> > +       int rsv_tx_rings;
> >         int port_up = 0;
> >         int err;
> >
> > +       rsv_tx_rings = prog ? ALIGN(priv->rx_ring_num, MLX4_EN_NUM_UP) : 0;
> > +
> >         /* No need to reconfigure buffers when simply swapping the
> >          * program for a new one.
> >          */
> > @@ -2561,6 +2574,10 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
> >
> >         mlx4_en_free_resources(priv);
> >
> > +       priv->rsv_tx_rings = rsv_tx_rings;
> > +       priv->tx_ring_num = priv->num_tx_rings_p_up * MLX4_EN_NUM_UP +
> > +                                                       priv->rsv_tx_rings;
> > +
> >         old_prog = xchg(&priv->prog, prog);
> >         if (old_prog)
> >                 bpf_prog_put(old_prog);
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > index f26306c..9215940 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> > @@ -779,7 +779,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >         struct mlx4_en_rx_alloc *frags;
> >         struct mlx4_en_rx_desc *rx_desc;
> >         struct bpf_prog *prog;
> > +       int doorbell_pending;
> >         struct sk_buff *skb;
> > +       int tx_index;
> >         int index;
> >         int nr;
> >         unsigned int length;
> > @@ -796,6 +798,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >                 return polled;
> >
> >         prog = READ_ONCE(priv->prog);
> > +       doorbell_pending = 0;
> > +       tx_index = (priv->tx_ring_num - priv->rsv_tx_rings) + cq->ring;
> >
> >         /* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
> >          * descriptor offset can be deduced from the CQE index instead of
> > @@ -894,6 +898,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
> >                         switch (act) {
> >                         case XDP_PASS:
> >                                 break;
> > +                       case XDP_TX:
> > +                               if (!mlx4_en_xmit_frame(frags, dev,
> > +                                                       length, tx_index,
> > +                                                       &doorbell_pending))
> > +                                       goto consumed;
> > +                               break;
> >                         default:
> >                                 bpf_warn_invalid_xdp_action(act);
> >                         case XDP_ABORTED:
> > @@ -1064,6 +1074,9 @@ consumed:
> >         }
> >
> >  out:
> > +       if (doorbell_pending)
> > +               mlx4_en_xmit_doorbell(priv->tx_ring[tx_index]);
> > +
> 
> If in this napi cycle we had at least one packet that went through
> XDP_PASS (mlx4_en_xmit_frame) you must hit doorbell here,
You mean XDP_TX?
> otherwise if no packet will be forwarded later, this packet will never
> be really sent and it will wait in HW forever.
> 
> The idea is correct to hit the doorbell only at the end of
> mlx4_en_process_rx_cq cycle to batch tx descriptors and send them in
> one batch,
Up to a budget of 8
> but you must hit doorbell at the end of the cycle. you can't just
> assume more RX packets will come in the future to hit the doorbell for
> you.
I don't assume that. If you look at the code, either:
xmit_frame rings the doorbell, in which case doorbell_pending <- 0
or
xmit_frame doesn't ring the doorbell, in which case doorbell_pending++
So how is a packet left in the ring unannounced?
> 
> >         AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
> >         mlx4_cq_set_ci(&cq->mcq);
> >         wmb(); /* ensure HW sees CQ consumer before we post new buffers */
> > @@ -1143,6 +1156,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
> >          * This only works when num_frags == 1.
> >          */
> >         if (priv->prog) {
> > +               dma_dir = PCI_DMA_BIDIRECTIONAL;
> >                 /* This will gain efficient xdp frame recycling at the expense
> >                  * of more costly truesize accounting
> >                  */
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > index c29191e..ba7b5eb 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > @@ -274,10 +274,28 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
> >         struct mlx4_en_tx_desc *tx_desc = ring->buf + index * TXBB_SIZE;
> >         struct mlx4_wqe_data_seg *data = (void *) tx_desc + tx_info->data_offset;
> >         void *end = ring->buf + ring->buf_size;
> > -       struct sk_buff *skb = tx_info->skb;
> >         int nr_maps = tx_info->nr_maps;
> > +       struct sk_buff *skb;
> >         int i;
> >
> > +       if (ring->recycle_ring) {
> > +               struct mlx4_en_rx_alloc frame = {
> > +                       .page = tx_info->page,
> > +                       .dma = tx_info->map0_dma,
> > +                       .page_offset = 0,
> > +                       .page_size = PAGE_SIZE,
> > +               };
> > +
> > +               if (!mlx4_en_rx_recycle(ring->recycle_ring, &frame)) {
> > +                       dma_unmap_page(priv->ddev, tx_info->map0_dma,
> > +                                      PAGE_SIZE, priv->frag_info[0].dma_dir);
> > +                       put_page(tx_info->page);
> > +               }
> > +               return tx_info->nr_txbb;
> > +       }
> 
> This condition will be checked always even for non XDP rings and when
> XDP is not enabled.
> can't we just figure a way not to have this for non XDP rings ?
> other than having a separate napi handler i don't see a way to do this.
> on the other hand, new NAPI handler would introduce a lot of code duplication.
Yes I considered a separate napi handler, but again that would be more
code duplication than it's worth, IMO.
> 
> > +
> > +       skb = tx_info->skb;
> > +
> >         /* We do not touch skb here, so prefetch skb->users location
> >          * to speedup consume_skb()
> >          */
> > @@ -476,6 +494,9 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
> >         ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
> >         ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
> >
> > +       if (ring->recycle_ring)
> > +               return done < budget;
> > +
> >         netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
> >
> >         /* Wakeup Tx queue if this stopped, and ring is not full.
> > @@ -1055,3 +1076,106 @@ tx_drop:
> >         return NETDEV_TX_OK;
> >  }
> >
> > +netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
> > +                              struct net_device *dev, unsigned int length,
> > +                              int tx_ind, int *doorbell_pending)
> > +{
> > +       struct mlx4_en_priv *priv = netdev_priv(dev);
> > +       union mlx4_wqe_qpn_vlan qpn_vlan = {};
> > +       struct mlx4_en_tx_ring *ring;
> > +       struct mlx4_en_tx_desc *tx_desc;
> > +       struct mlx4_wqe_data_seg *data;
> > +       struct mlx4_en_tx_info *tx_info;
> > +       int index, bf_index;
> > +       bool send_doorbell;
> > +       int nr_txbb = 1;
> > +       bool stop_queue;
> > +       dma_addr_t dma;
> > +       int real_size;
> > +       __be32 op_own;
> > +       u32 ring_cons;
> > +       bool bf_ok;
> > +
> > +       BUILD_BUG_ON_MSG(ALIGN(CTRL_SIZE + DS_SIZE, TXBB_SIZE) != TXBB_SIZE,
> > +                        "mlx4_en_xmit_frame requires minimum size tx desc");
> > +
> > +       ring = priv->tx_ring[tx_ind];
> > +
> > +       if (!priv->port_up)
> > +               goto tx_drop;
> > +
> > +       if (mlx4_en_is_tx_ring_full(ring))
> > +               goto tx_drop;
> > +
> > +       /* fetch ring->cons far ahead before needing it to avoid stall */
> > +       ring_cons = READ_ONCE(ring->cons);
> > +
> > +       index = ring->prod & ring->size_mask;
> > +       tx_info = &ring->tx_info[index];
> > +
> > +       bf_ok = ring->bf_enabled;
> > +
> > +       /* Track current inflight packets for performance analysis */
> > +       AVG_PERF_COUNTER(priv->pstats.inflight_avg,
> > +                        (u32)(ring->prod - ring_cons - 1));
> > +
> > +       bf_index = ring->prod;
> > +       tx_desc = ring->buf + index * TXBB_SIZE;
> > +       data = &tx_desc->data;
> > +
> > +       dma = frame->dma;
> > +
> > +       tx_info->page = frame->page;
> > +       frame->page = NULL;
> > +       tx_info->map0_dma = dma;
> > +       tx_info->map0_byte_count = length;
> > +       tx_info->nr_txbb = nr_txbb;
> > +       tx_info->nr_bytes = max_t(unsigned int, length, ETH_ZLEN);
> > +       tx_info->data_offset = (void *)data - (void *)tx_desc;
> > +       tx_info->ts_requested = 0;
> > +       tx_info->nr_maps = 1;
> > +       tx_info->linear = 1;
> > +       tx_info->inl = 0;
> > +
> > +       dma_sync_single_for_device(priv->ddev, dma, length, PCI_DMA_TODEVICE);
> > +
> > +       data->addr = cpu_to_be64(dma);
> > +       data->lkey = ring->mr_key;
> > +       dma_wmb();
> > +       data->byte_count = cpu_to_be32(length);
> > +
> > +       /* tx completion can avoid cache line miss for common cases */
> > +       tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
> > +
> > +       op_own = cpu_to_be32(MLX4_OPCODE_SEND) |
> > +               ((ring->prod & ring->size) ?
> > +                cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
> > +
> > +       ring->packets++;
> > +       ring->bytes += tx_info->nr_bytes;
> > +       AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, length);
> > +
> > +       ring->prod += nr_txbb;
> > +
> > +       stop_queue = mlx4_en_is_tx_ring_full(ring);
> > +       send_doorbell = stop_queue ||
> > +                               *doorbell_pending > MLX4_EN_DOORBELL_BUDGET;
> > +       bf_ok &= send_doorbell;
> 
> you missed here one important condition for blue flame, there is max
> size for sending a BF request.
> 
> bf_ok &= desc_size <= MAX_BF;
We have single frag only, so this would be redundant, since it is always
true.
> 
> The doorbell accounting here is redundant, and you should always
> request for doorbell.
If we have a doorbell on every packet, performance will suck. The
variable is not if _this_ packet needs a doorbell, its the number of
outstanding packets/doorbells. The loop in mlx4_en_process_rx_cq will
always catch the remainder if doorbell_pending is non-zero.
> 
> > +
> > +       real_size = ((CTRL_SIZE + nr_txbb * DS_SIZE) / 16) & 0x3f;
> > +
> > +       if (bf_ok)
> > +               qpn_vlan.bf_qpn = ring->doorbell_qpn | cpu_to_be32(real_size);
> > +       else
> > +               qpn_vlan.fence_size = real_size;
> > +
> > +       mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, TXBB_SIZE, bf_index,
> > +                             op_own, bf_ok, send_doorbell);
> > +       *doorbell_pending = send_doorbell ? 0 : *doorbell_pending + 1;
> 
> Why not to set doorbell to 1 here ? how do you know more packets will
> be forwarded ?
I don't know, but that's not how the logic works.
> 
> > +
> > +       return NETDEV_TX_OK;
> > +
> > +tx_drop:
> > +       ring->tx_dropped++;
> > +       return NETDEV_TX_BUSY;
> > +}
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> > index 0e0ecd1..7309308 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> > +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> > @@ -132,6 +132,7 @@ enum {
> >                                          MLX4_EN_NUM_UP)
> >
> >  #define MLX4_EN_DEFAULT_TX_WORK                256
> > +#define MLX4_EN_DOORBELL_BUDGET                8
> >
> >  /* Target number of packets to coalesce with interrupt moderation */
> >  #define MLX4_EN_RX_COAL_TARGET 44
> > @@ -219,7 +220,10 @@ enum cq_type {
> >
> >
> >  struct mlx4_en_tx_info {
> > -       struct sk_buff *skb;
> > +       union {
> > +               struct sk_buff *skb;
> > +               struct page *page;
> > +       };
> >         dma_addr_t      map0_dma;
> >         u32             map0_byte_count;
> >         u32             nr_txbb;
> > @@ -298,6 +302,7 @@ struct mlx4_en_tx_ring {
> >         __be32                  mr_key;
> >         void                    *buf;
> >         struct mlx4_en_tx_info  *tx_info;
> > +       struct mlx4_en_rx_ring  *recycle_ring;
> >         u8                      *bounce_buf;
> >         struct mlx4_qp_context  context;
> >         int                     qpn;
> > @@ -604,6 +609,7 @@ struct mlx4_en_priv {
> >         struct hwtstamp_config hwtstamp_config;
> >         u32 counter_index;
> >         struct bpf_prog *prog;
> > +       int rsv_tx_rings;
> >
> >  #ifdef CONFIG_MLX4_EN_DCB
> >  #define MLX4_EN_DCB_ENABLED    0x3
> > @@ -678,6 +684,12 @@ void mlx4_en_tx_irq(struct mlx4_cq *mcq);
> >  u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
> >                          void *accel_priv, select_queue_fallback_t fallback);
> >  netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
> > +netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
> > +                              struct net_device *dev, unsigned int length,
> > +                              int tx_ind, int *doorbell_pending);
> > +void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring);
> > +bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
> > +                       struct mlx4_en_rx_alloc *frame);
> >
> >  int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
> >                            struct mlx4_en_tx_ring **pring,
> > --
> > 2.8.2
> >
