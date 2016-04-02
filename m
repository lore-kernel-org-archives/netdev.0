From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Sat, 2 Apr 2016 10:23:31 +0200
Message-ID: <20160402102331.5aa3b3c2@redhat.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, gerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbcDBIXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2016 04:23:38 -0400
In-Reply-To: <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


First of all, I'm very happy to see people start working on this!
Thanks you Brenden!

On Fri,  1 Apr 2016 18:21:57 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> Add support for the BPF_PROG_TYPE_PHYS_DEV hook in mlx4 driver.  Since
> bpf programs require a skb context to navigate the packet, build a
> percpu fake skb with the minimal fields. This avoids the costly
> allocation for packets that end up being dropped.
> 
> Since mlx4 is so far the only user of this pseudo skb, the build
> function is defined locally.
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
[...]
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 86bcfe5..03fe005 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
[...]
> @@ -764,6 +765,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  	if (budget <= 0)
>  		return polled;
>  
> +	prog = READ_ONCE(priv->prog);
> +
>  	/* We assume a 1:1 mapping between CQEs and Rx descriptors, so Rx
>  	 * descriptor offset can be deduced from the CQE index instead of
>  	 * reading 'cqe->index' */
> @@ -840,6 +843,21 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
>  			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
>  
> +		/* A bpf program gets first chance to drop the packet. It may
> +		 * read bytes but not past the end of the frag. A non-zero
> +		 * return indicates packet should be dropped.
> +		 */
> +		if (prog) {
> +			struct ethhdr *ethh;
> +

I think you need to DMA sync RX-page before you can safely access
packet data in page (on all arch's).

> +			ethh = (struct ethhdr *)(page_address(frags[0].page) +
> +						 frags[0].page_offset);
> +			if (mlx4_call_bpf(prog, ethh, length)) {

AFAIK length here covers all the frags[n].page, thus potentially
causing the BPF program to access memory out of bound (crash).

Having several page fragments is AFAIK an optimization for jumbo-frames
on PowerPC (which is a bit annoying for you use-case ;-)).


> +				priv->stats.rx_dropped++;
> +				goto next;
> +			}
> +		}
> +



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
