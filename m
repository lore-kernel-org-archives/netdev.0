From: Fugang Duan <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec_main: dma_map() only the length of the skb
Date: Wed, 27 Nov 2013 13:08:18 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE01899801@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <Fabio.Estevam@freescale.com>,
	Frank Li <frank.li@freescale.net>,
	Jim Baxter <jim_baxter@mentor.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0250.outbound.messaging.microsoft.com ([213.199.154.250]:7102
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750972Ab3K0NIZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Nov 2013 08:08:25 -0500
In-Reply-To: <1385556253-4130-1-git-send-email-bigeasy@linutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Data: Wednesday, November 27, 2013 8:44 PM

>To: netdev@vger.kernel.org
>Cc: David S. Miller; Estevam Fabio-R49496; Frank Li; Duan Fugang-B38611; Jim
>Baxter; Marek Szyprowski; Sebastian Andrzej Siewior
>Subject: [PATCH] net: fec_main: dma_map() only the length of the skb
>
>On tx submit the driver always dma_map_single() FEC_ENET_TX_FRSIZE (=2048)
>bytes. This works because we don't overwrite any memory after the data buffer,
>we remove it from cache if it was there. So we hurt performace in case the
>mapping of a smaller area makes a difference.
>There is also a bug: If the data area starts shortly before the end of RAM say
>0xc7fffa10 and the RAM ends at 0xc8000000 then we have enough space to fit the
>data area (according to skb->len) but we would map beyond end of ram if we are
>using 2048. In v2.6.31 (against which kernel this patch
>made) there is the following check in dma_cache_maint():
>
>|BUG_ON(!virt_addr_valid(start) || !virt_addr_valid(start + size - 1));
>
>Since the area starting at 0xc8000000 is no longer virt_addr_valid() we
>BUG() during dma_map_single(). The BUG() statement was removed in v3.5-rc1 as
>per 2dc6a016 ("ARM: dma-mapping: use asm-generic/dma-mapping-common.h").
>
>This patch was tested on v2.6.31 and then forward-ported and compile tested
>only against the net tree. I think it is still worth fixing mainline even after
>the BUG() statement is gone.
>
>Cc: Marek Szyprowski <m.szyprowski@samsung.com>
>Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
>---
>It would be nice if someone could test this on current kernel.
>Is this worth pushing stable?
>
>Marek: Was there a special reason why the check was removed? Would it make
>sense to bring it back say under CONFIG_DMA_DEBUG?
>
> drivers/net/ethernet/freescale/fec_main.c | 8 ++++----
> 1 file changed, 4 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/ethernet/freescale/fec_main.c
>b/drivers/net/ethernet/freescale/fec_main.c
>index 4cbebf3..29d8dc4 100644
>--- a/drivers/net/ethernet/freescale/fec_main.c
>+++ b/drivers/net/ethernet/freescale/fec_main.c
>@@ -385,7 +385,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device
>*ndev)
> 	 * data.
> 	 */
> 	bdp->cbd_bufaddr = dma_map_single(&fep->pdev->dev, bufaddr,
>-			FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
>+			skb->len, DMA_TO_DEVICE);
> 	if (dma_mapping_error(&fep->pdev->dev, bdp->cbd_bufaddr)) {
> 		bdp->cbd_bufaddr = 0;
> 		fep->tx_skbuff[index] = NULL;
>@@ -779,11 +779,11 @@ fec_enet_tx(struct net_device *ndev)
> 		else
> 			index = bdp - fep->tx_bd_base;
>
>-		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr,
>-				FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
>+		skb = fep->tx_skbuff[index];
>+		dma_unmap_single(&fep->pdev->dev, bdp->cbd_bufaddr, skb->len,
>+				DMA_TO_DEVICE);
> 		bdp->cbd_bufaddr = 0;
>
>-		skb = fep->tx_skbuff[index];
>
> 		/* Check for errors. */
> 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
>--
>1.8.4.4
>
In fact, there have one memory copy for enet as below since enet have 16 bytes data buffer alignment request.
if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
                memcpy(fep->tx_bounce[index], skb->data, skb->len);
                bufaddr = fep->tx_bounce[index];
}

So, the bug you describe at commit log shouldn't exist.

Anyway, it is better to use the real packet size for the mapping.


I will do overnight stress test for the patch tomorrow.

Thanks,
Andy
