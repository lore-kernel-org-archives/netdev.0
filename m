From: Alexander Shiyan <shc_work@mail.ru>
Subject: [PATCH 2/3] can: mcp251x: Convert to devm-* API
Date: Wed, 13 Nov 2013 12:43:15 +0400
Message-ID: <1384332195-15257-1-git-send-email-shc_work@mail.ru>
Cc: netdev@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Alexander Shiyan <shc_work@mail.ru>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace existing resource handling in the driver with managed
device resource, this ensures more consistent error values and
simplifies error paths.

Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
---
 drivers/net/can/mcp251x.c | 19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 3a8d80b..8e133aa 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -1062,15 +1062,17 @@ static int mcp251x_can_probe(struct spi_device *spi)
 
 	/* Allocate non-DMA buffers */
 	if (!mcp251x_enable_dma) {
-		priv->spi_tx_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
+		priv->spi_tx_buf = devm_kzalloc(&spi->dev, SPI_TRANSFER_BUF_LEN,
+						GFP_KERNEL);
 		if (!priv->spi_tx_buf) {
 			ret = -ENOMEM;
-			goto error_tx_buf;
+			goto error_probe;
 		}
-		priv->spi_rx_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
+		priv->spi_rx_buf = devm_kzalloc(&spi->dev, SPI_TRANSFER_BUF_LEN,
+						GFP_KERNEL);
 		if (!priv->spi_rx_buf) {
 			ret = -ENOMEM;
-			goto error_rx_buf;
+			goto error_probe;
 		}
 	}
 
@@ -1103,12 +1105,6 @@ static int mcp251x_can_probe(struct spi_device *spi)
 	return ret;
 
 error_probe:
-	if (!mcp251x_enable_dma)
-		kfree(priv->spi_rx_buf);
-error_rx_buf:
-	if (!mcp251x_enable_dma)
-		kfree(priv->spi_tx_buf);
-error_tx_buf:
 	if (mcp251x_enable_dma)
 		dma_free_coherent(&spi->dev, PAGE_SIZE,
 				  priv->spi_tx_buf, priv->spi_tx_dma);
@@ -1134,9 +1130,6 @@ static int mcp251x_can_remove(struct spi_device *spi)
 	if (mcp251x_enable_dma) {
 		dma_free_coherent(&spi->dev, PAGE_SIZE,
 				  priv->spi_tx_buf, priv->spi_tx_dma);
-	} else {
-		kfree(priv->spi_tx_buf);
-		kfree(priv->spi_rx_buf);
 	}
 
 	mcp251x_power_enable(priv->power, 0);
-- 
1.8.1.5

