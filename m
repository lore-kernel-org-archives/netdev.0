From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next] caif-spi: Bugfix for dump upon device removal
Date: Tue,  6 Dec 2011 18:25:05 +0100
Message-ID: <1323192305-10843-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Erwan Bracq <erwan.bracq@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:45702 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751340Ab1LFRZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 12:25:21 -0500
Received: by lagp5 with SMTP id p5so1725399lag.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 09:25:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Erwan Bracq <erwan.bracq@stericsson.com>

=46ix dump upon device removal, by moving deinitialization from
platform-device-remove to network-interface-uninit.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_spi.c |  176 ++++++++++++++++++++++-------------=
--------
 include/net/caif/caif_spi.h |    4 +-
 2 files changed, 92 insertions(+), 88 deletions(-)

diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 05e791f..761057b 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -226,7 +226,7 @@ static ssize_t dbgfs_frame(struct file *file, char =
__user *user_buf,
 			"Tx data (Len: %d):\n", cfspi->tx_cpck_len);
=20
 	len +=3D print_frame((buf + len), (DEBUGFS_BUF_SIZE - len),
-			   cfspi->xfer.va_tx,
+			   cfspi->xfer.va_tx[0],
 			   (cfspi->tx_cpck_len + SPI_CMD_SZ), 100);
=20
 	len +=3D snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
@@ -599,48 +599,11 @@ static int cfspi_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	return 0;
 }
-static const struct net_device_ops cfspi_ops =3D {
-	.ndo_open =3D cfspi_open,
-	.ndo_stop =3D cfspi_close,
-	.ndo_start_xmit =3D cfspi_xmit
-};
=20
-static void cfspi_setup(struct net_device *dev)
+static int cfspi_init(struct net_device *dev)
 {
+	int res =3D 0;
 	struct cfspi *cfspi =3D netdev_priv(dev);
-	dev->features =3D 0;
-	dev->netdev_ops =3D &cfspi_ops;
-	dev->type =3D ARPHRD_CAIF;
-	dev->flags =3D IFF_NOARP | IFF_POINTOPOINT;
-	dev->tx_queue_len =3D 0;
-	dev->mtu =3D SPI_MAX_PAYLOAD_SIZE;
-	dev->destructor =3D free_netdev;
-	skb_queue_head_init(&cfspi->qhead);
-	skb_queue_head_init(&cfspi->chead);
-	cfspi->cfdev.link_select =3D CAIF_LINK_HIGH_BANDW;
-	cfspi->cfdev.use_frag =3D false;
-	cfspi->cfdev.use_stx =3D false;
-	cfspi->cfdev.use_fcs =3D false;
-	cfspi->ndev =3D dev;
-}
-
-int cfspi_spi_probe(struct platform_device *pdev)
-{
-	struct cfspi *cfspi =3D NULL;
-	struct net_device *ndev;
-	struct cfspi_dev *dev;
-	int res;
-	dev =3D (struct cfspi_dev *)pdev->dev.platform_data;
-
-	ndev =3D alloc_netdev(sizeof(struct cfspi),
-			"cfspi%d", cfspi_setup);
-	if (!ndev)
-		return -ENOMEM;
-
-	cfspi =3D netdev_priv(ndev);
-	netif_stop_queue(ndev);
-	cfspi->ndev =3D ndev;
-	cfspi->pdev =3D pdev;
=20
 	/* Set flow info. */
 	cfspi->flow_off_sent =3D 0;
@@ -656,16 +619,11 @@ int cfspi_spi_probe(struct platform_device *pdev)
 		cfspi->slave_talked =3D false;
 	}
=20
-	/* Assign the SPI device. */
-	cfspi->dev =3D dev;
-	/* Assign the device ifc to this SPI interface. */
-	dev->ifc =3D &cfspi->ifc;
-
 	/* Allocate DMA buffers. */
-	cfspi->xfer.va_tx =3D dma_alloc(&cfspi->xfer.pa_tx);
-	if (!cfspi->xfer.va_tx) {
+	cfspi->xfer.va_tx[0] =3D dma_alloc(&cfspi->xfer.pa_tx[0]);
+	if (!cfspi->xfer.va_tx[0]) {
 		res =3D -ENODEV;
-		goto err_dma_alloc_tx;
+		goto err_dma_alloc_tx_0;
 	}
=20
 	cfspi->xfer.va_rx =3D dma_alloc(&cfspi->xfer.pa_rx);
@@ -714,6 +672,87 @@ int cfspi_spi_probe(struct platform_device *pdev)
 	/* Schedule the work queue. */
 	queue_work(cfspi->wq, &cfspi->work);
=20
+	return 0;
+
+ err_create_wq:
+	dma_free(cfspi->xfer.va_rx, cfspi->xfer.pa_rx);
+ err_dma_alloc_rx:
+	dma_free(cfspi->xfer.va_tx[0], cfspi->xfer.pa_tx[0]);
+ err_dma_alloc_tx_0:
+	return res;
+}
+
+static void cfspi_uninit(struct net_device *dev)
+{
+	struct cfspi *cfspi =3D netdev_priv(dev);
+
+	/* Remove from list. */
+	spin_lock(&cfspi_list_lock);
+	list_del(&cfspi->list);
+	spin_unlock(&cfspi_list_lock);
+
+	cfspi->ndev =3D NULL;
+	/* Free DMA buffers. */
+	dma_free(cfspi->xfer.va_rx, cfspi->xfer.pa_rx);
+	dma_free(cfspi->xfer.va_tx[0], cfspi->xfer.pa_tx[0]);
+	set_bit(SPI_TERMINATE, &cfspi->state);
+	wake_up_interruptible(&cfspi->wait);
+	destroy_workqueue(cfspi->wq);
+	/* Destroy debugfs directory and files. */
+	dev_debugfs_rem(cfspi);
+	return;
+}
+
+static const struct net_device_ops cfspi_ops =3D {
+	.ndo_open =3D cfspi_open,
+	.ndo_stop =3D cfspi_close,
+	.ndo_init =3D cfspi_init,
+	.ndo_uninit =3D cfspi_uninit,
+	.ndo_start_xmit =3D cfspi_xmit
+};
+
+static void cfspi_setup(struct net_device *dev)
+{
+	struct cfspi *cfspi =3D netdev_priv(dev);
+	dev->features =3D 0;
+	dev->netdev_ops =3D &cfspi_ops;
+	dev->type =3D ARPHRD_CAIF;
+	dev->flags =3D IFF_NOARP | IFF_POINTOPOINT;
+	dev->tx_queue_len =3D 0;
+	dev->mtu =3D SPI_MAX_PAYLOAD_SIZE;
+	dev->destructor =3D free_netdev;
+	skb_queue_head_init(&cfspi->qhead);
+	skb_queue_head_init(&cfspi->chead);
+	cfspi->cfdev.link_select =3D CAIF_LINK_HIGH_BANDW;
+	cfspi->cfdev.use_frag =3D false;
+	cfspi->cfdev.use_stx =3D false;
+	cfspi->cfdev.use_fcs =3D false;
+	cfspi->ndev =3D dev;
+}
+
+int cfspi_spi_probe(struct platform_device *pdev)
+{
+	struct cfspi *cfspi =3D NULL;
+	struct net_device *ndev;
+	struct cfspi_dev *dev;
+	int res;
+	dev =3D (struct cfspi_dev *)pdev->dev.platform_data;
+
+	ndev =3D alloc_netdev(sizeof(struct cfspi),
+			"cfspi%d", cfspi_setup);
+	if (!dev)
+		return -ENODEV;
+
+	cfspi =3D netdev_priv(ndev);
+	netif_stop_queue(ndev);
+	cfspi->ndev =3D ndev;
+	cfspi->pdev =3D pdev;
+
+	/* Assign the SPI device. */
+	cfspi->dev =3D dev;
+	/* Assign the device ifc to this SPI interface. */
+	dev->ifc =3D &cfspi->ifc;
+
 	/* Register network device. */
 	res =3D register_netdev(ndev);
 	if (res) {
@@ -723,15 +762,6 @@ int cfspi_spi_probe(struct platform_device *pdev)
 	return res;
=20
  err_net_reg:
-	dev_debugfs_rem(cfspi);
-	set_bit(SPI_TERMINATE, &cfspi->state);
-	wake_up_interruptible(&cfspi->wait);
-	destroy_workqueue(cfspi->wq);
- err_create_wq:
-	dma_free(cfspi->xfer.va_rx, cfspi->xfer.pa_rx);
- err_dma_alloc_rx:
-	dma_free(cfspi->xfer.va_tx, cfspi->xfer.pa_tx);
- err_dma_alloc_tx:
 	free_netdev(ndev);
=20
 	return res;
@@ -739,34 +769,8 @@ int cfspi_spi_probe(struct platform_device *pdev)
=20
 int cfspi_spi_remove(struct platform_device *pdev)
 {
-	struct list_head *list_node;
-	struct list_head *n;
-	struct cfspi *cfspi =3D NULL;
-	struct cfspi_dev *dev;
-
-	dev =3D (struct cfspi_dev *)pdev->dev.platform_data;
-	spin_lock(&cfspi_list_lock);
-	list_for_each_safe(list_node, n, &cfspi_list) {
-		cfspi =3D list_entry(list_node, struct cfspi, list);
-		/* Find the corresponding device. */
-		if (cfspi->dev =3D=3D dev) {
-			/* Remove from list. */
-			list_del(list_node);
-			/* Free DMA buffers. */
-			dma_free(cfspi->xfer.va_rx, cfspi->xfer.pa_rx);
-			dma_free(cfspi->xfer.va_tx, cfspi->xfer.pa_tx);
-			set_bit(SPI_TERMINATE, &cfspi->state);
-			wake_up_interruptible(&cfspi->wait);
-			destroy_workqueue(cfspi->wq);
-			/* Destroy debugfs directory and files. */
-			dev_debugfs_rem(cfspi);
-			unregister_netdev(cfspi->ndev);
-			spin_unlock(&cfspi_list_lock);
-			return 0;
-		}
-	}
-	spin_unlock(&cfspi_list_lock);
-	return -ENODEV;
+	/* Everything is done in cfspi_uninit(). */
+	return 0;
 }
=20
 static void __exit cfspi_exit_module(void)
@@ -777,7 +781,7 @@ static void __exit cfspi_exit_module(void)
=20
 	list_for_each_safe(list_node, n, &cfspi_list) {
 		cfspi =3D list_entry(list_node, struct cfspi, list);
-		platform_device_unregister(cfspi->pdev);
+		unregister_netdev(cfspi->ndev);
 	}
=20
 	/* Destroy sysfs files. */
diff --git a/include/net/caif/caif_spi.h b/include/net/caif/caif_spi.h
index 87c3d11..aa6a485 100644
--- a/include/net/caif/caif_spi.h
+++ b/include/net/caif/caif_spi.h
@@ -55,8 +55,8 @@
 struct cfspi_xfer {
 	u16 tx_dma_len;
 	u16 rx_dma_len;
-	void *va_tx;
-	dma_addr_t pa_tx;
+	void *va_tx[2];
+	dma_addr_t pa_tx[2];
 	void *va_rx;
 	dma_addr_t pa_rx;
 };
--=20
1.7.0.4
