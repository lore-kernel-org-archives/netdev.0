From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v7 09/11] net/mlx4_en: add xdp forwarding and data write support
Date: Wed, 13 Jul 2016 22:16:22 +0300
Message-ID: <CALzJLG9hwv3KJLXJg_v+HLAsqRaxj-+WBWrUmuESbKEzGrtcQA@mail.gmail.com>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
 <1468272598-21390-10-git-send-email-bblanco@plumgrid.com> <CALzJLG8Jv3eYyPLkmrkj-_9w160KcO87jsv3z5an4U1VYkg7PA@mail.gmail.com>
 <20160713172959.GA7650@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34329 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbcGMTQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 15:16:48 -0400
Received: by mail-yw0-f171.google.com with SMTP id i12so52038157ywa.1
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 12:16:42 -0700 (PDT)
In-Reply-To: <20160713172959.GA7650@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 8:30 PM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> On Wed, Jul 13, 2016 at 06:25:28PM +0300, Saeed Mahameed wrote:
>> On Tue, Jul 12, 2016 at 12:29 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
[...]
>>
>> MAX_TX_RING is a software limitation made to limit netdev real_num_tx
>> queues for CX3 internal cache utilization,
>> in your case the netdev doesn't care about xdp_tx rings, the
>> accounting you added in this patch adds a  lot of
>> complications and it would be better to have clear separation between
>> the two types of tx_rings, in terms of the holding/managing data
>> structure.
>>
>> I suggest here to leave priv->tx_ring untouched. i.e, don't store the
>> xdp_tx rings at the end of it, i.e  priv->tx_ring should only reflect
>> the
>> netdev real tx queues.
>>
>> In case of priv->porg is active, we can allocate and store xdp tx ring
>> per rx ring, this tx ring will be allocated and activated
>> once the rx ring is created and activated, and store this dedicated tx
>> ring  in the rx_ring it self.
>>
>> i.e :
>> struct mlx4_en_rx_ring {
>> [...]
>> struct mlx4_en_tx_ring *xdp_tx;
>> struct mlx4_en_cq *xdp_tx_cq;
>> [...]
>> }
>>
>> for this the following changes are required.
>>
>> @ mlx4_en_create_rx_ring
>> [...] // Create the RX ring
>>
>> /* create CQ for xdp tx ring */
>> node = cpu_to_node(i % num_online_cpus());
>>
>> mlx4_en_create_cq(priv, &rx_ring->xdp_tx_cq, prof->tx_ring_size, i, TX, node)
>>
>> /* create xdp tx ring */
>> mlx4_en_create_tx_ring(priv, &rx_ring->xdp_tx, prof->tx_ring_size,
>> TXBB_SIZE, node, -1)
>>
>> @mlx4_en_start/stop_port
>> /* Configure tx cq's and rings */
>> // You will need to configure xdp tx rings same as priv->rx_ring_num rings
>>
>> @mlx4_en_poll_tx_cq
>> This Also will require a new NAPI handler for xdp rings to replace the
>> following line @mlx4_en_poll_tx_cq
>> - struct mlx4_en_tx_ring *ring = priv->tx_ring[cq->ring];
>> with
>> + struct mlx4_en_tx_ring *ring = priv->rx_ring[cq->ring].xdp_tx;
>>
>> Or just change cq->ring from ring index to the actual ring pointer.
>>
>> Bottom line, my suggestion also started to look complicated :).. but
>> still it would look cleaner to separate between netdev rings and xdp
>> rings.
>>
> I considered this at first too, but it seemed the worse option to me at
> the time. There would be a lot of copy/paste as well as new code to
> review.

We can start from a small refactoring patch that moves code around and
extracts the needed helper functions. But it is up to you and Tariq.

it is really non trivial to follow the logic of rsv_tx_rings and
tx_ring_num accounting.

>>
>> If in this napi cycle we had at least one packet that went through
>> XDP_PASS (mlx4_en_xmit_frame) you must hit doorbell here,
> You mean XDP_TX?

yes

>> otherwise if no packet will be forwarded later, this packet will never
>> be really sent and it will wait in HW forever.
>>
>> The idea is correct to hit the doorbell only at the end of
>> mlx4_en_process_rx_cq cycle to batch tx descriptors and send them in
>> one batch,
> Up to a budget of 8
>> but you must hit doorbell at the end of the cycle. you can't just
>> assume more RX packets will come in the future to hit the doorbell for
>> you.
> I don't assume that. If you look at the code, either:
> xmit_frame rings the doorbell, in which case doorbell_pending <- 0
> or
> xmit_frame doesn't ring the doorbell, in which case doorbell_pending++
> So how is a packet left in the ring unannounced?

Ooh, now i see, yeap the logic is good.

>>
>> This condition will be checked always even for non XDP rings and when
>> XDP is not enabled.
>> can't we just figure a way not to have this for non XDP rings ?
>> other than having a separate napi handler i don't see a way to do this.
>> on the other hand, new NAPI handler would introduce a lot of code duplication.
> Yes I considered a separate napi handler, but again that would be more
> code duplication than it's worth, IMO.

Yeah, I agree.

>>
>> > +
>> > +       skb = tx_info->skb;
>> > +
>> >         /* We do not touch skb here, so prefetch skb->users location
>> >          * to speedup consume_skb()
>> >          */
>> > @@ -476,6 +494,9 @@ static bool mlx4_en_process_tx_cq(struct net_device *dev,
>> >         ACCESS_ONCE(ring->last_nr_txbb) = last_nr_txbb;
>> >         ACCESS_ONCE(ring->cons) = ring_cons + txbbs_skipped;
>> >
>> > +       if (ring->recycle_ring)
>> > +               return done < budget;
>> > +
>> >         netdev_tx_completed_queue(ring->tx_queue, packets, bytes);
>> >
>> >         /* Wakeup Tx queue if this stopped, and ring is not full.
>> > @@ -1055,3 +1076,106 @@ tx_drop:
>> >         return NETDEV_TX_OK;
>> >  }
>> >
>> > +netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
>> > +                              struct net_device *dev, unsigned int length,
>> > +                              int tx_ind, int *doorbell_pending)
>> > +{
>> > +       struct mlx4_en_priv *priv = netdev_priv(dev);
>> > +       union mlx4_wqe_qpn_vlan qpn_vlan = {};
>> > +       struct mlx4_en_tx_ring *ring;
>> > +       struct mlx4_en_tx_desc *tx_desc;
>> > +       struct mlx4_wqe_data_seg *data;
>> > +       struct mlx4_en_tx_info *tx_info;
>> > +       int index, bf_index;
>> > +       bool send_doorbell;
>> > +       int nr_txbb = 1;
>> > +       bool stop_queue;
>> > +       dma_addr_t dma;
>> > +       int real_size;
>> > +       __be32 op_own;
>> > +       u32 ring_cons;
>> > +       bool bf_ok;
>> > +
>> > +       BUILD_BUG_ON_MSG(ALIGN(CTRL_SIZE + DS_SIZE, TXBB_SIZE) != TXBB_SIZE,
>> > +                        "mlx4_en_xmit_frame requires minimum size tx desc");
>> > +
>> > +       ring = priv->tx_ring[tx_ind];
>> > +
>> > +       if (!priv->port_up)
>> > +               goto tx_drop;
>> > +
>> > +       if (mlx4_en_is_tx_ring_full(ring))
>> > +               goto tx_drop;
>> > +
>> > +       /* fetch ring->cons far ahead before needing it to avoid stall */
>> > +       ring_cons = READ_ONCE(ring->cons);
>> > +
>> > +       index = ring->prod & ring->size_mask;
>> > +       tx_info = &ring->tx_info[index];
>> > +
>> > +       bf_ok = ring->bf_enabled;
>> > +
>> > +       /* Track current inflight packets for performance analysis */
>> > +       AVG_PERF_COUNTER(priv->pstats.inflight_avg,
>> > +                        (u32)(ring->prod - ring_cons - 1));
>> > +
>> > +       bf_index = ring->prod;
>> > +       tx_desc = ring->buf + index * TXBB_SIZE;
>> > +       data = &tx_desc->data;
>> > +
>> > +       dma = frame->dma;
>> > +
>> > +       tx_info->page = frame->page;
>> > +       frame->page = NULL;
>> > +       tx_info->map0_dma = dma;
>> > +       tx_info->map0_byte_count = length;
>> > +       tx_info->nr_txbb = nr_txbb;
>> > +       tx_info->nr_bytes = max_t(unsigned int, length, ETH_ZLEN);
>> > +       tx_info->data_offset = (void *)data - (void *)tx_desc;
>> > +       tx_info->ts_requested = 0;
>> > +       tx_info->nr_maps = 1;
>> > +       tx_info->linear = 1;
>> > +       tx_info->inl = 0;
>> > +
>> > +       dma_sync_single_for_device(priv->ddev, dma, length, PCI_DMA_TODEVICE);
>> > +
>> > +       data->addr = cpu_to_be64(dma);
>> > +       data->lkey = ring->mr_key;
>> > +       dma_wmb();
>> > +       data->byte_count = cpu_to_be32(length);
>> > +
>> > +       /* tx completion can avoid cache line miss for common cases */
>> > +       tx_desc->ctrl.srcrb_flags = priv->ctrl_flags;
>> > +
>> > +       op_own = cpu_to_be32(MLX4_OPCODE_SEND) |
>> > +               ((ring->prod & ring->size) ?
>> > +                cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
>> > +
>> > +       ring->packets++;
>> > +       ring->bytes += tx_info->nr_bytes;
>> > +       AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, length);
>> > +
>> > +       ring->prod += nr_txbb;
>> > +
>> > +       stop_queue = mlx4_en_is_tx_ring_full(ring);
>> > +       send_doorbell = stop_queue ||
>> > +                               *doorbell_pending > MLX4_EN_DOORBELL_BUDGET;
>> > +       bf_ok &= send_doorbell;
>>
>> you missed here one important condition for blue flame, there is max
>> size for sending a BF request.
>>
>> bf_ok &= desc_size <= MAX_BF;
> We have single frag only, so this would be redundant, since it is always
> true.

We have this one frag assumption all over the mlx4 XDP code, it will
take a series reverse engineering work once we decide to support
larger MTU (more frags). anyway I agree with you.

>>
>> The doorbell accounting here is redundant, and you should always
>> request for doorbell.
> If we have a doorbell on every packet, performance will suck. The
> variable is not if _this_ packet needs a doorbell, its the number of
> outstanding packets/doorbells. The loop in mlx4_en_process_rx_cq will
> always catch the remainder if doorbell_pending is non-zero.
>>
>> > +
>> > +       real_size = ((CTRL_SIZE + nr_txbb * DS_SIZE) / 16) & 0x3f;
>> > +
>> > +       if (bf_ok)
>> > +               qpn_vlan.bf_qpn = ring->doorbell_qpn | cpu_to_be32(real_size);
>> > +       else
>> > +               qpn_vlan.fence_size = real_size;
>> > +
>> > +       mlx4_en_tx_write_desc(ring, tx_desc, qpn_vlan, TXBB_SIZE, bf_index,
>> > +                             op_own, bf_ok, send_doorbell);
>> > +       *doorbell_pending = send_doorbell ? 0 : *doorbell_pending + 1;
>>
>> Why not to set doorbell to 1 here ? how do you know more packets will
>> be forwarded ?
> I don't know, but that's not how the logic works.
I see.


Other than the rings separation, this series looks good to me.
If you and Tariq decide to keep it this way, I am good with it.

Thanks Brenden, superb work.
