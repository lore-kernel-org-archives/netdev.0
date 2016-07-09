From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH v6 04/12] net/mlx4_en: add support for fast rx drop bpf program
Date: Sat, 9 Jul 2016 22:58:54 +0300
Message-ID: <CALzJLG8+LzX_sELAC-TVszeWXZFbCKVJ+rJnDT50fqN5PodEAA@mail.gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com> <1467944124-14891-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
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
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:34334 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756699AbcGIT7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 15:59:15 -0400
Received: by mail-yw0-f169.google.com with SMTP id i12so62786195ywa.1
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 12:59:14 -0700 (PDT)
In-Reply-To: <1467944124-14891-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2016 at 5:15 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.
>
> In tc/socket bpf programs, helpers linearize skb fragments as needed
> when the program touchs the packet data. However, in the pursuit of
> speed, XDP programs will not be allowed to use these slower functions,
> especially if it involves allocating an skb.
>
> Therefore, disallow MTU settings that would produce a multi-fragment
> packet that XDP programs would fail to access. Future enhancements could
> be done to increase the allowable MTU.
>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 38 ++++++++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 36 +++++++++++++++++++++---
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  5 ++++
>  3 files changed, 75 insertions(+), 4 deletions(-)
>
[...]
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

In case of XDP_PASS we will dma_sync again in the normal path, this
can be improved by doing the dma_sync as soon as we can and once and
for all, regardless of the path the packet is going to take
(XDP_DROP/mlx4_en_complete_rx_desc/mlx4_en_rx_skb).

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

The drop action here (goto next) will release the current rx_desc
buffers and use new ones to refill, I know that the mlx4 rx scheme
will release/allocate new pages once every ~32 packet, but one
improvement can really help here especially for XDP_DROP benchmarks is
to reuse the current rx_desc buffers in case it is going to be
dropped.

Considering if mlx4 rx buffer scheme doesn't allow gaps, Maybe this
can be added later as future improvement for the whole mlx4 rx data
path drop decisions.
