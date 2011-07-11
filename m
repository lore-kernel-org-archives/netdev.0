From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 06/46] net/tokenring: 3c359: fix DMA API usage
Date: Mon, 11 Jul 2011 02:52:46 +0200 (CEST)
Message-ID: <24b2e6936782b494815165de6cc7863cee900a69.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43663 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165Ab1GKAwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:50 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX/RX rings should be allocated from DMA coherent memory (driver does
not sync the descriptors in any way).

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/tokenring/3c359.c |   49 +++++++++++++++++++++++++--------=
--------
 drivers/net/tokenring/3c359.h |    4 +-
 2 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c35=
9.c
index b6162fe..d321640 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -672,21 +672,25 @@ static int xl_open(struct net_device *dev)
 	 * Now to set up the Rx and Tx buffer structures
 	 */
 	/* These MUST be on 8 byte boundaries */
-	xl_priv->xl_tx_ring =3D kzalloc((sizeof(struct xl_tx_desc) * XL_TX_RI=
NG_SIZE) + 7, GFP_DMA | GFP_KERNEL);
+	xl_priv->xl_tx_ring =3D dma_alloc_coherent(&xl_priv->pdev->dev,
+		sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE,
+		&xl_priv->tx_ring_dma_addr, GFP_KERNEL);
 	if (xl_priv->xl_tx_ring =3D=3D NULL) {
 		printk(KERN_WARNING "%s: Not enough memory to allocate tx buffers.\n=
",
 				     dev->name);
-		free_irq(dev->irq,dev);
-		return -ENOMEM;
+		goto err_free_irq;
 	}
-	xl_priv->xl_rx_ring =3D kzalloc((sizeof(struct xl_rx_desc) * XL_RX_RI=
NG_SIZE) +7, GFP_DMA | GFP_KERNEL);
+	xl_priv->xl_rx_ring =3D dma_alloc_coherent(&xl_priv->pdev->dev,
+		sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE,
+		&xl_priv->rx_ring_dma_addr, GFP_KERNEL);
 	if (xl_priv->xl_rx_ring =3D=3D NULL) {
 		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers.\n=
",
 				     dev->name);
-		free_irq(dev->irq,dev);
-		kfree(xl_priv->xl_tx_ring);
-		return -ENOMEM;
+		goto err_free_tx;
 	}
+	/* dma_alloc_coherent() should provide for the following */
+	BUG_ON(!IS_ALIGNED((unsigned long)xl_priv->xl_tx_ring, 8));
+	BUG_ON(!IS_ALIGNED((unsigned long)xl_priv->xl_rx_ring, 8));
=20
 	 /* Setup Rx Ring */
 	 for (i=3D0 ; i < XL_RX_RING_SIZE ; i++) {=20
@@ -704,10 +708,7 @@ static int xl_open(struct net_device *dev)
=20
 	if (i=3D=3D0) {=20
 		printk(KERN_WARNING "%s: Not enough memory to allocate rx buffers. A=
dapter disabled\n",dev->name);
-		free_irq(dev->irq,dev) ;=20
-		kfree(xl_priv->xl_tx_ring);
-		kfree(xl_priv->xl_rx_ring);
-		return -EIO ;=20
+		goto err_free_rxtx;
 	}=20
=20
 	xl_priv->rx_ring_no =3D i ;=20
@@ -722,8 +723,6 @@ static int xl_open(struct net_device *dev)
 =09
 	/* Setup Tx Ring */
 =09
-	xl_priv->tx_ring_dma_addr =3D pci_map_single(xl_priv->pdev,xl_priv->x=
l_tx_ring, sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE,PCI_DMA_TODEVICE=
) ;=20
-=09
 	xl_priv->tx_ring_head =3D 1 ;=20
 	xl_priv->tx_ring_tail =3D 255 ; /* Special marker for first packet */
 	xl_priv->free_ring_entries =3D XL_TX_RING_SIZE ;=20
@@ -752,7 +751,18 @@ static int xl_open(struct net_device *dev)
=20
 	netif_start_queue(dev) ; =09
 	return 0;
-=09
+
+err_free_rxtx:
+	dma_free_coherent(&xl_priv->pdev->dev,
+		sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE,
+		xl_priv->xl_rx_ring, xl_priv->rx_ring_dma_addr);
+err_free_tx:
+	dma_free_coherent(&xl_priv->pdev->dev,
+		sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE,
+		xl_priv->xl_tx_ring, xl_priv->tx_ring_dma_addr);
+err_free_irq:
+	free_irq(dev->irq,dev);
+	return -ENOMEM;
 }=09
=20
 static int xl_open_hw(struct net_device *dev)=20
@@ -1060,12 +1070,13 @@ static void xl_freemem(struct net_device *dev)
 	}=20
=20
 	/* unmap ring */
-	pci_unmap_single(xl_priv->pdev,xl_priv->rx_ring_dma_addr, sizeof(stru=
ct xl_rx_desc) * XL_RX_RING_SIZE, PCI_DMA_FROMDEVICE) ;=20
-=09
-	pci_unmap_single(xl_priv->pdev,xl_priv->tx_ring_dma_addr, sizeof(stru=
ct xl_tx_desc) * XL_TX_RING_SIZE, PCI_DMA_TODEVICE) ;=20
+	dma_free_coherent(&xl_priv->pdev->dev,
+		sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE,
+		xl_priv->xl_rx_ring, xl_priv->rx_ring_dma_addr);
=20
-	kfree(xl_priv->xl_rx_ring) ;=20
-	kfree(xl_priv->xl_tx_ring) ;=20
+	dma_free_coherent(&xl_priv->pdev->dev,
+		sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE,
+		xl_priv->xl_tx_ring, xl_priv->tx_ring_dma_addr);
=20
 	return  ;=20
 }
diff --git a/drivers/net/tokenring/3c359.h b/drivers/net/tokenring/3c35=
9.h
index bcb1a6b..baefdd3 100644
--- a/drivers/net/tokenring/3c359.h
+++ b/drivers/net/tokenring/3c359.h
@@ -282,8 +282,8 @@ struct xl_private {
 	unsigned char xl_functional_addr[4] ;=20
 	u16 xl_addr_table_addr, xl_parms_addr ;=20
 	u8 xl_laa[6] ;=20
-	u32 rx_ring_dma_addr ;=20
-	u32 tx_ring_dma_addr ;=20
+	dma_addr_t rx_ring_dma_addr;
+	dma_addr_t tx_ring_dma_addr;
=20
 	/* firmware section */
 	const struct firmware *fw;
--=20
1.7.5.4

