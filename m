From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 10/46] net: jme: convert to generic DMA API
Date: Mon, 11 Jul 2011 02:52:49 +0200 (CEST)
Message-ID: <2e396909aee3b267ce7333760012cf8af822e1a6.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43670 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239Ab1GKAwv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:51 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also fixes bad pci_dma_map_page() usage and missing RX unmaps.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/jme.c |   37 ++++++++++++-------------------------
 1 files changed, 12 insertions(+), 25 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 6b2a5e7..ad69dae 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -759,11 +759,8 @@ jme_make_new_rx_buf(struct jme_adapter *jme, int i=
)
=20
 	rxbi->skb =3D skb;
 	rxbi->len =3D skb_tailroom(skb);
-	rxbi->mapping =3D pci_map_page(jme->pdev,
-					virt_to_page(skb->data),
-					offset_in_page(skb->data),
-					rxbi->len,
-					PCI_DMA_FROMDEVICE);
+	rxbi->mapping =3D dma_map_single(&jme->pdev->dev, skb->data,
+					rxbi->len, DMA_FROM_DEVICE);
=20
 	return 0;
 }
@@ -776,10 +773,10 @@ jme_free_rx_buf(struct jme_adapter *jme, int i)
 	rxbi +=3D i;
=20
 	if (rxbi->skb) {
-		pci_unmap_page(jme->pdev,
+		dma_unmap_single(&jme->pdev->dev,
 				 rxbi->mapping,
 				 rxbi->len,
-				 PCI_DMA_FROMDEVICE);
+				 DMA_FROM_DEVICE);
 		dev_kfree_skb(rxbi->skb);
 		rxbi->skb =3D NULL;
 		rxbi->mapping =3D 0;
@@ -1022,17 +1019,12 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme,=
 int idx)
 	rxbi +=3D idx;
=20
 	skb =3D rxbi->skb;
-	pci_dma_sync_single_for_cpu(jme->pdev,
-					rxbi->mapping,
-					rxbi->len,
-					PCI_DMA_FROMDEVICE);
+	dma_unmap_single(&jme->pdev->dev, rxbi->mapping, rxbi->len,
+			 DMA_FROM_DEVICE);
=20
 	if (unlikely(jme_make_new_rx_buf(jme, idx))) {
-		pci_dma_sync_single_for_device(jme->pdev,
-						rxbi->mapping,
-						rxbi->len,
-						PCI_DMA_FROMDEVICE);
-
+		rxbi->mapping =3D dma_map_single(&jme->pdev->dev, skb->data,
+						rxbi->len, DMA_FROM_DEVICE);
 		++(NET_STAT(jme).rx_dropped);
 	} else {
 		framesize =3D le16_to_cpu(rxdesc->descwb.framesize)
@@ -1476,10 +1468,10 @@ jme_tx_clean_tasklet(unsigned long arg)
 				ttxbi =3D txbi + ((i + j) & (mask));
 				txdesc[(i + j) & (mask)].dw[0] =3D 0;
=20
-				pci_unmap_page(jme->pdev,
+				dma_unmap_page(&jme->pdev->dev,
 						 ttxbi->mapping,
 						 ttxbi->len,
-						 PCI_DMA_TODEVICE);
+						 DMA_TO_DEVICE);
=20
 				ttxbi->mapping =3D 0;
 				ttxbi->len =3D 0;
@@ -1883,16 +1875,11 @@ jme_fill_tx_map(struct pci_dev *pdev,
 {
 	dma_addr_t dmaaddr;
=20
-	dmaaddr =3D pci_map_page(pdev,
+	dmaaddr =3D dma_map_page(&pdev->dev,
 				page,
 				page_offset,
 				len,
-				PCI_DMA_TODEVICE);
-
-	pci_dma_sync_single_for_device(pdev,
-				       dmaaddr,
-				       len,
-				       PCI_DMA_TODEVICE);
+				DMA_TO_DEVICE);
=20
 	txdesc->dw[0] =3D 0;
 	txdesc->dw[1] =3D 0;
--=20
1.7.5.4

