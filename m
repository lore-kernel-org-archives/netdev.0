From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next PATCH 06/11] RFC: mlx5: RX bulking or bundling of
 packets before calling network stack
Date: Tue, 9 Feb 2016 13:57:41 +0200
Message-ID: <CALzJLG_w1Nr9rtZ_G4n894gvN=XTbfikGfPgNc4+VBAYw2Pyug@mail.gmail.com>
References: <20160202211051.16315.51808.stgit@firesoul>
	<20160202211228.16315.9691.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Christoph Lameter <cl@linux.com>,
	tom@herbertland.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, Or Gerlitz <ogerlitz@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:36075 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756066AbcBIMPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 07:15:40 -0500
Received: by mail-yw0-f194.google.com with SMTP id h80so373949ywc.3
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 04:15:39 -0800 (PST)
In-Reply-To: <20160202211228.16315.9691.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 2, 2016 at 11:13 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> There are several techniques/concepts combined in this optimization.
> It is both a data-cache and instruction-cache optimization.
>
> First of all, this is primarily about delaying touching
> packet-data, which happend in eth_type_trans, until the prefetch
> have had time to fetch.  Thus, hopefully avoiding a cache-miss on
> packet data.
>
> Secondly, the instruction-cache optimization is about, not
> calling the network stack for every packet, which is pulled out
> of the RX ring.  Calling the full stack likely removes/flushes
> the instruction cache every time.
>
> Thus, have two loops, one loop pulling out packet from the RX
> ring and starting the prefetching, and the second loop calling
> eth_type_trans() and invoking the stack via napi_gro_receive().
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>
>
> Notes:
> This is the patch that gave a speed up of 6.2Mpps to 12Mpps, when
> trying to measure lowest RX level, by dropping the packets in the
> driver itself (marked drop point as comment).
Indeed looks very promising in respect of instruction-cache
optimization, but i have some doubts regarding the data-cache
optimizations (prefetch), please see my below questions.

We will take this patch and test it in house.

>
> For now, the ring is emptied upto the budget.  I don't know if it
> would be better to chunk it up more?
Not sure, according to netdevice.h :

/* Default NAPI poll() weight
 * Device drivers are strongly advised to not use bigger value
 */
#define NAPI_POLL_WEIGHT 64

we will also compare different budget values with your approach, but I
doubt it will be accepted to increase the NAPI_POLL_WEIGHT for mlx5
drivers.
furthermore increasing NAPI poll budget might cause cache overflow
with this approach since you are chunking up all "prefetch(skb->data)"
(I didn't do the math yet in regards of cache utilization with this
approach).

>         mlx5e_handle_csum(netdev, cqe, rq, skb);
>
> -       skb->protocol = eth_type_trans(skb, netdev);
> -
mlx5e_handle_csum also access the skb->data in is_first_ethertype_ip
function, but i think it is not interesting since this is not the
common case,
e.g: for the none common case of L4 traffic with no HW checksum
offload you won't benefit from this optimization since we access the
skb->data to know the L3 header type, and this can be fixed in driver
code to check the CQE meta data for these fields instead of accessing
the skb->data, but I will need to look further into that.

> @@ -252,7 +257,6 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
>                 wqe_counter    = be16_to_cpu(wqe_counter_be);
>                 wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
>                 skb            = rq->skb[wqe_counter];
> -               prefetch(skb->data);
>                 rq->skb[wqe_counter] = NULL;
>
>                 dma_unmap_single(rq->pdev,
> @@ -265,16 +269,27 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
>                         dev_kfree_skb(skb);
>                         goto wq_ll_pop;
>                 }
> +               prefetch(skb->data);
is this optimal for all CPU archs ? is it ok to use up to 64 cache
lines at once ?
