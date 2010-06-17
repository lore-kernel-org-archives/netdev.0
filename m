From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: bnx2 fails to compile on parisc because of missing
 get_dma_ops()
Date: Thu, 17 Jun 2010 21:13:44 +0900
Message-ID: <20100617211203O.fujita.tomonori@lab.ntt.co.jp>
References: <AANLkTilSfOwwT87mgDcWBogL4gPnM7VBTOALKpZv_upN@mail.gmail.com>
	<C27F8246C663564A84BB7AB3439772421B79CBCA1C@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, JBottomley@Novell.com, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp
To: mchan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B79CBCA1C@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Jun 2010 20:53:57 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> > > The commit that causes the problem:
> > >
> > > commit a33fa66bcf365ffe5b79d1ae1d3582cc261ae56e
> > > Author: Michael Chan <mchan@broadcom.com>
> > > Date:   Thu May 6 08:58:13 2010 +0000
> > >
> > >    bnx2: Add prefetches to rx path.
> > >
> > > Looks fairly innocuous by the description.
> > >
> > > Should parisc have a get_dma_ops()?  We don't need one
> > because our dma
> > > ops are per platform not per bus.
> >
> > looks like it'll be broken on more than just parisc:
> > $ grep get_dma_ops arch/*/include/asm/ -rl | cut -d/ -f 2
> > alpha
> > ia64
> > microblaze
> > powerpc
> > sh
> > sparc
> > x86
> 
> Most of these archs use the dma functions in:
> 
> <asm-genric/dma-mapping-common.h>
> 
> so it's not a problem.

No, it's wrong assumption. asm-genric/dma-mapping-common.h is the
helper code to simplify architecture's DMA core code. Some
architecture uses it and some don't.

You can't expect every architectures to use it.


> I think I'll send in a patch to remove that part of the code
> from bnx2.c for now.

Yeah. I'm not sure you already sent a patch.

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 17 Jun 2010 13:06:15 +0900
Subject: [PATCH] bnx2: fix dma_get_ops compilation breakage

This removes dma_get_ops() prefetch optimization in bnx2.

bnx2 uses dma_get_ops() to see if dma_sync_single_for_cpu() is
noop. bnx2 does prefetch if it's noop.

But dma_get_ops() isn't available on all the architectures (only the
architectures that uses dma_map_ops struct have it). Using
dma_get_ops() in drivers leads to compilation breakage on many
archtectures.

Currently, we don't have a way to see if dma_sync_single_for_cpu() is
noop. If it can improve the performance notably, we can add the new
DMA API for it.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/bnx2.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 949d7a9..b3305fc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3073,7 +3073,6 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	u16 hw_cons, sw_cons, sw_ring_cons, sw_prod, sw_ring_prod;
 	struct l2_fhdr *rx_hdr;
 	int rx_pkt = 0, pg_ring_used = 0;
-	struct pci_dev *pdev = bp->pdev;
 
 	hw_cons = bnx2_get_hw_rx_cons(bnapi);
 	sw_cons = rxr->rx_cons;
@@ -3086,7 +3085,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	while (sw_cons != hw_cons) {
 		unsigned int len, hdr_len;
 		u32 status;
-		struct sw_bd *rx_buf, *next_rx_buf;
+		struct sw_bd *rx_buf;
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
 		u16 vtag = 0;
@@ -3098,13 +3097,6 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		rx_buf = &rxr->rx_buf_ring[sw_ring_cons];
 		skb = rx_buf->skb;
 		prefetchw(skb);
-
-		if (!get_dma_ops(&pdev->dev)->sync_single_for_cpu) {
-			next_rx_buf =
-				&rxr->rx_buf_ring[
-					RX_RING_IDX(NEXT_RX_BD(sw_cons))];
-			prefetch(next_rx_buf->desc);
-		}
 		rx_buf->skb = NULL;
 
 		dma_addr = dma_unmap_addr(rx_buf, mapping);
-- 
1.5.6.5
