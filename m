From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v6 04/12] net/mlx4_en: add support for fast rx drop bpf program
Date: Sat, 9 Jul 2016 17:07:36 +0300
Message-ID: <CAJ3xEMjjG2ZZe=qBsRaFuk-j8Akj38Uk6+Nw1xuZya=R7FOJ7Q@mail.gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com> <1467944124-14891-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33011 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbcGIOHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 10:07:43 -0400
Received: by mail-oi0-f66.google.com with SMTP id w141so13006315oia.0
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 07:07:43 -0700 (PDT)
In-Reply-To: <1467944124-14891-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2016 at 5:15 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.
>
> In tc/socket bpf programs, helpers linearize skb fragments as needed
> when the program touchs the packet data. However, in the pursuit of

nit, for the next version touchs --> touches

> speed, XDP programs will not be allowed to use these slower functions,
> especially if it involves allocating an skb.


[...]

> @@ -835,6 +838,34 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>                 l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
>                         (cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
>
> +               /* A bpf program gets first chance to drop the packet. It may
> +                * read bytes but not past the end of the frag.
> +                */
> +               if (prog) {
> +                       struct xdp_buff xdp;
> +                       dma_addr_t dma;
> +                       u32 act;
> +
> +                       dma = be64_to_cpu(rx_desc->data[0].addr);
> +                       dma_sync_single_for_cpu(priv->ddev, dma,
> +                                               priv->frag_info[0].frag_size,
> +                                               DMA_FROM_DEVICE);
> +
> +                       xdp.data = page_address(frags[0].page) +
> +                                                       frags[0].page_offset;
> +                       xdp.data_end = xdp.data + length;
> +
> +                       act = bpf_prog_run_xdp(prog, &xdp);
> +                       switch (act) {
> +                       case XDP_PASS:
> +                               break;
> +                       default:
> +                               bpf_warn_invalid_xdp_action(act);
> +                       case XDP_DROP:
> +                               goto next;
> +                       }
> +               }


(probably a nit too, but wanted to make sure we don't miss something
here) is the default case preceding the DROP one in purpose? any
special reason to do that?
