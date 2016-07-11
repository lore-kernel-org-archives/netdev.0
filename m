From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v6 04/12] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Mon, 11 Jul 2016 14:49:06 -0700
Message-ID: <20160711214904.GC22729@gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-5-git-send-email-bblanco@plumgrid.com>
 <CALzJLG8+LzX_sELAC-TVszeWXZFbCKVJ+rJnDT50fqN5PodEAA@mail.gmail.com>
 <57d2eb82-1992-b6fb-0727-b3b0d8983765@gmail.com>
 <20160710160540.GB6657@gmail.com>
 <CALzJLG846VMsOWuAvT=6Kcdu_p+ixUX=tTyV-DgAEXYpXszBgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tariq Toukan <ttoukan.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
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
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36742 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbcGKVtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 17:49:10 -0400
Received: by mail-pa0-f45.google.com with SMTP id hu1so26077007pad.3
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 14:49:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALzJLG846VMsOWuAvT=6Kcdu_p+ixUX=tTyV-DgAEXYpXszBgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 02:48:17PM +0300, Saeed Mahameed wrote:
[...]
> 
> yes, we need something like:
> 
> +static inline void
> +mlx4_en_sync_dma(struct mlx4_en_priv *priv,
> +                struct mlx4_en_rx_desc *rx_desc,
> +                int length)
> +{
> +       dma_addr_t dma;
> +
> +       /* Sync dma addresses from HW descriptor */
> +       for (nr = 0; nr < priv->num_frags; nr++) {
> +               struct mlx4_en_frag_info *frag_info = &priv->frag_info[nr];
> +
> +               if (length <= frag_info->frag_prefix_size)
> +                       break;
> +
> +               dma = be64_to_cpu(rx_desc->data[nr].addr);
> +               dma_sync_single_for_cpu(priv->ddev, dma, frag_info->frag_size,
> +                                       DMA_FROM_DEVICE);
> +       }
> +}
> 
> 
> @@ -790,6 +808,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev,
> struct mlx4_en_cq *cq, int bud
>                         goto next;
>                 }
> 
> +               length = be32_to_cpu(cqe->byte_cnt);
> +               length -= ring->fcs_del;
> +
> +               mlx4_en_sync_dma(priv,rx_desc, length);
>                  /* data is available continue processing the packet */
> 
> and make sure to remove all explicit dma_sync_single_for_cpu calls.

I see. At first glance, this may work, but introduces some changes in
the driver that may be unwanted. For instance, the dma sync cost is now
being paid even in the case where no skb will be allocated. So, under
memory pressure, it might cause extra work which would slow down your
ability to recover from the stress.

Let's keep discussing it, but in the context of a standalone cleanup.
