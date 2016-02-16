From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next PATCH 06/11] RFC: mlx5: RX bulking or bundling of
 packets before calling network stack
Date: Tue, 16 Feb 2016 02:01:53 +0200
Message-ID: <CALzJLG-tpoHJeB-=wad75_CHsqhR6rOWmJGqz31So1QMbV1gsw@mail.gmail.com>
References: <20160202211051.16315.51808.stgit@firesoul>
	<20160202211228.16315.9691.stgit@firesoul>
	<CALzJLG_w1Nr9rtZ_G4n894gvN=XTbfikGfPgNc4+VBAYw2Pyug@mail.gmail.com>
	<20160210212601.41901b91@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Christoph Lameter <cl@linux.com>,
	Tom Herbert <tom@herbertland.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f196.google.com ([209.85.160.196]:35604 "EHLO
	mail-yk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444AbcBPABy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 19:01:54 -0500
Received: by mail-yk0-f196.google.com with SMTP id u9so4594199ykd.2
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 16:01:54 -0800 (PST)
In-Reply-To: <20160210212601.41901b91@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2016 at 10:26 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Tue, 9 Feb 2016 13:57:41 +0200
> Saeed Mahameed <saeedm@dev.mellanox.co.il> wrote:
>
>> On Tue, Feb 2, 2016 at 11:13 PM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> > There are several techniques/concepts combined in this optimization.
>> > It is both a data-cache and instruction-cache optimization.
>> >
>> > First of all, this is primarily about delaying touching
>> > packet-data, which happend in eth_type_trans, until the prefetch
>> > have had time to fetch.  Thus, hopefully avoiding a cache-miss on
>> > packet data.
>> >
>> > Secondly, the instruction-cache optimization is about, not
>> > calling the network stack for every packet, which is pulled out
>> > of the RX ring.  Calling the full stack likely removes/flushes
>> > the instruction cache every time.
>> >
>> > Thus, have two loops, one loop pulling out packet from the RX
>> > ring and starting the prefetching, and the second loop calling
>> > eth_type_trans() and invoking the stack via napi_gro_receive().
>> >
>> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> >
>> >
>> > Notes:
>> > This is the patch that gave a speed up of 6.2Mpps to 12Mpps, when
>> > trying to measure lowest RX level, by dropping the packets in the
>> > driver itself (marked drop point as comment).
>>
>> Indeed looks very promising in respect of instruction-cache
>> optimization, but i have some doubts regarding the data-cache
>> optimizations (prefetch), please see my below questions.
>>
>> We will take this patch and test it in house.
>>
>> >
>> > For now, the ring is emptied upto the budget.  I don't know if it
>> > would be better to chunk it up more?
>>
>> Not sure, according to netdevice.h :
>>
>> /* Default NAPI poll() weight
>>  * Device drivers are strongly advised to not use bigger value
>>  */
>> #define NAPI_POLL_WEIGHT 64
>>
>> we will also compare different budget values with your approach, but I
>> doubt it will be accepted to increase the NAPI_POLL_WEIGHT for mlx5
>> drivers. furthermore increasing NAPI poll budget might cause cache overflow
>> with this approach since you are chunking up all "prefetch(skb->data)"
>> (I didn't do the math yet in regards of cache utilization with this
>> approach).
>
> You misunderstood me... I don't want to increase the NAPI_POLL_WEIGHT.
> I want to keep the 64, but sort of split it up, and e.g. call the stack
> for each 16 packets. Due to cache-size limits...
I see.

>
> One approach could be to compare the HW skb->hash to prev packet, and
> exit loop if they don't match (and call netstack with this bundle).
Sorry i am failing to see how this could help, either way you need an
inner budget of 16 as you said before.
>
>
>> >         mlx5e_handle_csum(netdev, cqe, rq, skb);
>> >
>> > -       skb->protocol = eth_type_trans(skb, netdev);
>> > -
>>
>> mlx5e_handle_csum also access the skb->data in is_first_ethertype_ip
>> function, but i think it is not interesting since this is not the
>> common case,
>> e.g: for the none common case of L4 traffic with no HW checksum
>> offload you won't benefit from this optimization since we access the
>> skb->data to know the L3 header type, and this can be fixed in driver
>> code to check the CQE meta data for these fields instead of accessing
>> the skb->data, but I will need to look further into that.
>
> Okay, understood.  We should look into this too, but not as top priority.
> We can simply move mlx5e_handle_csum() like eth_type_trans().
No, it is not that simple. mlx5e_handle_csum needs the cqe form the
first loop, referencing back to the cqe in the second loop will might
introduce new cache misses as the cqe is already "cold", what i like
in your approach is that you separated between two different flows
(read from device & create SKBs bundle  --> pass bundle to netstack),
now we don't want the "pass bundle to netstack" flow to look back at
device's (cqes/wqes etc..).

Again this is not the main issue for now as it is not the common case,
but we are preparing a patch that fixes the mlx5e_handle_csum to not
look at skb->data at all, we will share it once it is ready.
>
>
>> > @@ -252,7 +257,6 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
>> >                 wqe_counter    = be16_to_cpu(wqe_counter_be);
>> >                 wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
>> >                 skb            = rq->skb[wqe_counter];
>> > -               prefetch(skb->data);
>> >                 rq->skb[wqe_counter] = NULL;
>> >
>> >                 dma_unmap_single(rq->pdev,
>> > @@ -265,16 +269,27 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
>> >                         dev_kfree_skb(skb);
>> >                         goto wq_ll_pop;
>> >                 }
>> > +               prefetch(skb->data);
>>
>> is this optimal for all CPU archs ?
>
> For some CPU ARCHs the prefetch is compile time removed.
>
>> is it ok to use up to 64 cache lines at once ?
>
> That is not the problem, using 64 cache-lines * 64 = 4096 bytes.
> The BIOS/HW sometime also take next cache line => 8092 bytes.
> The problem is also SKB 4x cache-lines clearing = 16384 bytes.
>
> We should of-cause keep this CPU independent, but for Intel SandyBridge
> CPUs the optimal prefetch loop size is likely 10.
>
> Quote from Intels optimization manual:
>  The L1 DCache can handle multiple outstanding cache misses and continue
>  to service incoming stores and loads. Up to 10 requests of missing
>  cache lines can be managed simultaneously using the LFB (Line File Buffers).
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
