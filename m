From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V2 16/16] net: fec: don't set cbd_bufaddr unless no mapping error
Date: Wed, 24 Feb 2016 17:36:59 -0700
Message-ID: <1456360619-24390-17-git-send-email-troy.kisky@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33503 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758996AbcBYAkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 19:40:41 -0500
Received: by mail-pf0-f172.google.com with SMTP id q63so22268248pfb.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 16:40:41 -0800 (PST)
In-Reply-To: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not assigning cbd_bufaddr on error will prevent trying to
unmap the error in case the FEC is reset.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 1d71b2e..c443a96 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -600,7 +600,7 @@ fec_enet_txq_put_hdr_tso(struct fec_enet_priv_tx_q *txq,
 	int hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	struct bufdesc_ex *ebdp = container_of(bdp, struct bufdesc_ex, desc);
 	void *bufaddr;
-	unsigned long dmabuf;
+	dma_addr_t dmabuf;
 	unsigned int estatus = 0;
 
 	bufaddr = txq->tso_hdrs + index * TSO_HEADER_SIZE;
@@ -1298,17 +1298,21 @@ fec_enet_new_rxbdp(struct net_device *ndev, struct bufdesc *bdp, struct sk_buff
 {
 	struct  fec_enet_private *fep = netdev_priv(ndev);
 	int off;
+	dma_addr_t dmabuf;
 
 	off = ((unsigned long)skb->data) & fep->rx_align;
 	if (off)
 		skb_reserve(skb, fep->rx_align + 1 - off);
 
-	bdp->cbd_bufaddr = cpu_to_fec32(dma_map_single(&fep->pdev->dev, skb->data, FEC_ENET_RX_FRSIZE - fep->rx_align, DMA_FROM_DEVICE));
-	if (dma_mapping_error(&fep->pdev->dev, fec32_to_cpu(bdp->cbd_bufaddr))) {
+	dmabuf = dma_map_single(&fep->pdev->dev, skb->data,
+				FEC_ENET_RX_FRSIZE - fep->rx_align,
+				DMA_FROM_DEVICE);
+	if (dma_mapping_error(&fep->pdev->dev, dmabuf)) {
 		if (net_ratelimit())
 			netdev_err(ndev, "Rx DMA memory map failed\n");
 		return -ENOMEM;
 	}
+	bdp->cbd_bufaddr = cpu_to_fec32(dmabuf);
 
 	return 0;
 }
-- 
2.5.0
