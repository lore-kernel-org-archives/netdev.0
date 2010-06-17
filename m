From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Thu, 17 Jun 2010 05:54:34 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B79CBCA1F@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20100617211203O.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "vapier@gentoo.org" <vapier@gentoo.org>,
	"JBottomley@Novell.com" <JBottomley@Novell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "'FUJITA Tomonori'" <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20100617211203O.fujita.tomonori@lab.ntt.co.jp>
Content-Language: en-US
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FUJITA Tomonori wrote:

> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Date: Thu, 17 Jun 2010 13:06:15 +0900
> Subject: [PATCH] bnx2: fix dma_get_ops compilation breakage
>
> This removes dma_get_ops() prefetch optimization in bnx2.
>
> bnx2 uses dma_get_ops() to see if dma_sync_single_for_cpu() is
> noop. bnx2 does prefetch if it's noop.
>
> But dma_get_ops() isn't available on all the architectures (only the
> architectures that uses dma_map_ops struct have it). Using
> dma_get_ops() in drivers leads to compilation breakage on many
> archtectures.
>
> Currently, we don't have a way to see if dma_sync_single_for_cpu() is
> noop. If it can improve the performance notably, we can add the new
> DMA API for it.

This prefetch improves performance noticeably when the driver is
handling incoming 64-byte packets at a sustained rate.

>
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Acked-by: Michael Chan <mchan@broadcom.com>

Thanks.

> ---
>  drivers/net/bnx2.c |   10 +---------
>  1 files changed, 1 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 949d7a9..b3305fc 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -3073,7 +3073,6 @@ bnx2_rx_int(struct bnx2 *bp, struct
> bnx2_napi *bnapi, int budget)
>       u16 hw_cons, sw_cons, sw_ring_cons, sw_prod, sw_ring_prod;
>       struct l2_fhdr *rx_hdr;
>       int rx_pkt = 0, pg_ring_used = 0;
> -     struct pci_dev *pdev = bp->pdev;
>
>       hw_cons = bnx2_get_hw_rx_cons(bnapi);
>       sw_cons = rxr->rx_cons;
> @@ -3086,7 +3085,7 @@ bnx2_rx_int(struct bnx2 *bp, struct
> bnx2_napi *bnapi, int budget)
>       while (sw_cons != hw_cons) {
>               unsigned int len, hdr_len;
>               u32 status;
> -             struct sw_bd *rx_buf, *next_rx_buf;
> +             struct sw_bd *rx_buf;
>               struct sk_buff *skb;
>               dma_addr_t dma_addr;
>               u16 vtag = 0;
> @@ -3098,13 +3097,6 @@ bnx2_rx_int(struct bnx2 *bp, struct
> bnx2_napi *bnapi, int budget)
>               rx_buf = &rxr->rx_buf_ring[sw_ring_cons];
>               skb = rx_buf->skb;
>               prefetchw(skb);
> -
> -             if (!get_dma_ops(&pdev->dev)->sync_single_for_cpu) {
> -                     next_rx_buf =
> -                             &rxr->rx_buf_ring[
> -
> RX_RING_IDX(NEXT_RX_BD(sw_cons))];
> -                     prefetch(next_rx_buf->desc);
> -             }
>               rx_buf->skb = NULL;
>
>               dma_addr = dma_unmap_addr(rx_buf, mapping);
> --
> 1.5.6.5
>
>
>

