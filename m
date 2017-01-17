From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] net: fec: Fixed panic problem with non-tso
Date: Tue, 17 Jan 2017 11:02:26 +0000
Message-ID: <AM4PR0401MB2260E5BE096D7B86EDF4F04FFF7C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuusuke Ashiduka <ashiduka@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50082.outbound.protection.outlook.com ([40.107.5.82]:10445
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750967AbdAQLC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 06:02:29 -0500
In-Reply-To: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuusuke Ashiduka <ashiduka@jp.fujitsu.com> Sent: Tuesday, January 17,=
 2017 3:48 PM
>To: Andy Duan <fugang.duan@nxp.com>
>Cc: netdev@vger.kernel.org; Yuusuke Ashiduka <ashiduka@jp.fujitsu.com>
>Subject: [PATCH] net: fec: Fixed panic problem with non-tso
>
>If highmem and 2GB or more of memory are valid, "this_frag-> page.p"
>indicates the highmem area, so the result of page_address() is NULL and pa=
nic
>occurs.
>
>This commit fixes this by using the skb_frag_dma_map() helper, which takes
>care of mapping the skb fragment properly. Additionally, the type of mappi=
ng
>is now tracked, so it can be unmapped using dma_unmap_page or
>dma_unmap_single when appropriate.
>---
> drivers/net/ethernet/freescale/fec.h      |  1 +
> drivers/net/ethernet/freescale/fec_main.c | 48
>+++++++++++++++++++++++--------
> 2 files changed, 37 insertions(+), 12 deletions(-)
>
The patch itself seems fine.
The driver doesn't support skb from highmem, if to support highmem, it shou=
ld add frag_skb (highmem) support for tso and non-tso.
In driver net/core/tso.c, it also add highmem support, right ?=20

Thanks.

>diff --git a/drivers/net/ethernet/freescale/fec.h
>b/drivers/net/ethernet/freescale/fec.h
>index 5ea740b4cf14..5b187e8aacf0 100644
>--- a/drivers/net/ethernet/freescale/fec.h
>+++ b/drivers/net/ethernet/freescale/fec.h
>@@ -463,6 +463,7 @@ struct bufdesc_prop {  struct fec_enet_priv_tx_q {
> 	struct bufdesc_prop bd;
> 	unsigned char *tx_bounce[TX_RING_SIZE];
>+	int tx_page_mapping[TX_RING_SIZE];
> 	struct  sk_buff *tx_skbuff[TX_RING_SIZE];
>
> 	unsigned short tx_stop_threshold;
>diff --git a/drivers/net/ethernet/freescale/fec_main.c
>b/drivers/net/ethernet/freescale/fec_main.c
>index 38160c2bebcb..b1562107e337 100644
>--- a/drivers/net/ethernet/freescale/fec_main.c
>+++ b/drivers/net/ethernet/freescale/fec_main.c
>@@ -60,6 +60,7 @@
> #include <linux/if_vlan.h>
> #include <linux/pinctrl/consumer.h>
> #include <linux/prefetch.h>
>+#include <linux/highmem.h>
> #include <soc/imx/cpuidle.h>
>
> #include <asm/cacheflush.h>
>@@ -377,20 +378,28 @@ fec_enet_txq_submit_frag_skb(struct
>fec_enet_priv_tx_q *txq,
> 			ebdp->cbd_esc =3D cpu_to_fec32(estatus);
> 		}
>
>-		bufaddr =3D page_address(this_frag->page.p) + this_frag-
>>page_offset;
>-
> 		index =3D fec_enet_get_bd_index(bdp, &txq->bd);
>-		if (((unsigned long) bufaddr) & fep->tx_align ||
>+		txq->tx_page_mapping[index] =3D 0;
>+		if (this_frag->page_offset & fep->tx_align ||
> 			fep->quirks & FEC_QUIRK_SWAP_FRAME) {
>+			bufaddr =3D kmap_atomic(this_frag->page.p) +
>+						this_frag->page_offset;
> 			memcpy(txq->tx_bounce[index], bufaddr, frag_len);
>+			kunmap_atomic(bufaddr);
> 			bufaddr =3D txq->tx_bounce[index];
>
> 			if (fep->quirks & FEC_QUIRK_SWAP_FRAME)
> 				swap_buffer(bufaddr, frag_len);
>+			addr =3D dma_map_single(&fep->pdev->dev,
>+					      bufaddr,
>+					      frag_len,
>+					      DMA_TO_DEVICE);
>+		} else {
>+			txq->tx_page_mapping[index] =3D 1;
>+			addr =3D skb_frag_dma_map(&fep->pdev->dev,
>this_frag, 0,
>+						frag_len, DMA_TO_DEVICE);
> 		}
>
>-		addr =3D dma_map_single(&fep->pdev->dev, bufaddr, frag_len,
>-				      DMA_TO_DEVICE);
> 		if (dma_mapping_error(&fep->pdev->dev, addr)) {
> 			if (net_ratelimit())
> 				netdev_err(ndev, "Tx DMA memory map
>failed\n"); @@ -411,8 +420,16 @@ fec_enet_txq_submit_frag_skb(struct
>fec_enet_priv_tx_q *txq,
> 	bdp =3D txq->bd.cur;
> 	for (i =3D 0; i < frag; i++) {
> 		bdp =3D fec_enet_get_nextdesc(bdp, &txq->bd);
>-		dma_unmap_single(&fep->pdev->dev, fec32_to_cpu(bdp-
>>cbd_bufaddr),
>-				 fec16_to_cpu(bdp->cbd_datlen),
>DMA_TO_DEVICE);
>+		if (txq->tx_page_mapping[index])
>+			dma_unmap_page(&fep->pdev->dev,
>+				       fec32_to_cpu(bdp->cbd_bufaddr),
>+				       fec16_to_cpu(bdp->cbd_datlen),
>+				       DMA_TO_DEVICE);
>+		else
>+			dma_unmap_single(&fep->pdev->dev,
>+					 fec32_to_cpu(bdp->cbd_bufaddr),
>+					 fec16_to_cpu(bdp->cbd_datlen),
>+					 DMA_TO_DEVICE);
> 	}
> 	return ERR_PTR(-ENOMEM);
> }
>@@ -1201,11 +1218,18 @@ fec_enet_tx_queue(struct net_device *ndev, u16
>queue_id)
>
> 		skb =3D txq->tx_skbuff[index];
> 		txq->tx_skbuff[index] =3D NULL;
>-		if (!IS_TSO_HEADER(txq, fec32_to_cpu(bdp->cbd_bufaddr)))
>-			dma_unmap_single(&fep->pdev->dev,
>-					 fec32_to_cpu(bdp->cbd_bufaddr),
>-					 fec16_to_cpu(bdp->cbd_datlen),
>-					 DMA_TO_DEVICE);
>+		if (!IS_TSO_HEADER(txq, fec32_to_cpu(bdp->cbd_bufaddr)))
>{
>+			if (txq->tx_page_mapping[index])
>+				dma_unmap_page(&fep->pdev->dev,
>+					       fec32_to_cpu(bdp->cbd_bufaddr),
>+					       fec16_to_cpu(bdp->cbd_datlen),
>+					       DMA_TO_DEVICE);
>+			else
>+				dma_unmap_single(&fep->pdev->dev,
>+						 fec32_to_cpu(bdp-
>>cbd_bufaddr),
>+						 fec16_to_cpu(bdp-
>>cbd_datlen),
>+						 DMA_TO_DEVICE);
>+		}
> 		bdp->cbd_bufaddr =3D cpu_to_fec32(0);
> 		if (!skb)
> 			goto skb_done;
>--
>2.11.0
