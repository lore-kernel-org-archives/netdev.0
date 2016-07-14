From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Thu, 14 Jul 2016 09:25:43 +0200
Message-ID: <20160714092543.776f8d8c@redhat.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
	<1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750739AbcGNHZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 03:25:51 -0400
In-Reply-To: <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I would really really like to see the XDP program associated with the
RX ring queues, instead of a single XDP program covering the entire NIC.
(Just move the bpf_prog pointer to struct mlx4_en_rx_ring)

So, why is this so important? It is a fundamental architectural choice.

With a single XDP program per NIC, then we are not better than DPDK,
where a single application monopolize the entire NIC.  Recently netmap
added support for running on a single specific queue[1].  This is the
number one argument our customers give, for not wanting to run DPDK,
because they need to dedicate an entire NIC per high speed application.

As John Fastabend says, his NICs have thousands of queues, and he want
to bind applications to the queues.  This idea of binding queues to
applications, goes all the way back to Van Jacobson's 2006
netchannels[2].  Where creating an application channel allow for lock
free single producer single consumer (SPSC) queue directly into the
application.  A XDP program "locked" to a single RX queue can make
these optimizations, a global XDP programm cannot.


Why this change now, why can't this wait?

I'm starting to see more and more code assuming that a single global
XDP program owns the NIC.  This will be harder and harder to cleanup.
I'm fine with the first patch iteration only supports setting the XDP
program on all RX queue (e.g. returns ENOSUPPORT on specific
queues). Only requesting that this is moved to struct mlx4_en_rx_ring,
and appropriate refcnt handling is done.



On Tue, 12 Jul 2016 00:51:27 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.
> 
> In tc/socket bpf programs, helpers linearize skb fragments as needed
> when the program touches the packet data. However, in the pursuit of
> speed, XDP programs will not be allowed to use these slower functions,
> especially if it involves allocating an skb.
> 
[...]
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 51 ++++++++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 37 +++++++++++++++++--
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  5 +++
>  3 files changed, 89 insertions(+), 4 deletions(-)
> 
[...]
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index c1b3a9c..adfa123 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -743,6 +743,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  	struct mlx4_en_rx_ring *ring = priv->rx_ring[cq->ring];
>  	struct mlx4_en_rx_alloc *frags;
>  	struct mlx4_en_rx_desc *rx_desc;
> +	struct bpf_prog *prog;
>  	struct sk_buff *skb;
>  	int index;
>  	int nr;
> @@ -759,6 +760,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  	if (budget <= 0)
>  		return polled;
>  
> +	prog = READ_ONCE(priv->prog);

prog = READ_ONCE(ring->prog);

>  	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
>  	 * descriptor offset can be deduced from the CQE index instead of
>  	 * reading 'cqe->index' */
> @@ -835,6 +838,35 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
>  			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
>  
> +		/* A bpf program gets first chance to drop the packet. It may
> +		 * read bytes but not past the end of the frag.
> +		 */
> +		if (prog) {
> +			struct xdp_buff xdp;
> +			dma_addr_t dma;
> +			u32 act;
> +
> +			dma = be64_to_cpu(rx_desc->data[0].addr);
> +			dma_sync_single_for_cpu(priv->ddev, dma,
> +						priv->frag_info[0].frag_size,
> +						DMA_FROM_DEVICE);
> +
> +			xdp.data = page_address(frags[0].page) +
> +							frags[0].page_offset;
> +			xdp.data_end = xdp.data + length;
> +
> +			act = bpf_prog_run_xdp(prog, &xdp);
> +			switch (act) {
> +			case XDP_PASS:
> +				break;
> +			default:
> +				bpf_warn_invalid_xdp_action(act);
> +			case XDP_ABORTED:
> +			case XDP_DROP:
> +				goto next;
> +			}
> +		}
[...]

> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index d39bf59..35ecfa2 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
[...]
> @@ -590,6 +594,7 @@ struct mlx4_en_priv {
>  	struct hlist_head mac_hash[MLX4_EN_MAC_HASH_SIZE];
>  	struct hwtstamp_config hwtstamp_config;
>  	u32 counter_index;
> +	struct bpf_prog *prog;

Move to struct mlx4_en_rx_ring.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
