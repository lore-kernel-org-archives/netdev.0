From: Sergey Shcherbakov <shchers@gmail.com>
Subject: [PATCH] net: ks8851: Added support for half-duplex SPI
Date: Thu,  9 Mar 2017 02:58:14 +0200
Message-ID: <1489021094-12987-1-git-send-email-shchers@gmail.com>
Cc: davem@davemloft.net, tremyfr@gmail.com, stephen.boyd@linaro.org,
        jarod@redhat.com, Sergey Shcherbakov <shchers@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In original driver was implemented support for half-
and full-duplex modes, but it was not enabled. Instead
of it ks8851_rx_1msg method always returns "true" that
means "full-duplex" mode.

This patch replaces hard-coded functionality with
flexible solution that supports both SPI modes.

Signed-off-by: Sergey Shcherbakov <shchers@gmail.com>
---
 drivers/net/ethernet/micrel/ks8851.c | 41 ++++++++++--------------------------
 1 file changed, 11 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 279ee46..20358f8 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -212,25 +212,6 @@ static void ks8851_wrreg8(struct ks8851_net *ks, unsigned reg, unsigned val)
 }
 
 /**
- * ks8851_rx_1msg - select whether to use one or two messages for spi read
- * @ks: The device structure
- *
- * Return whether to generate a single message with a tx and rx buffer
- * supplied to spi_sync(), or alternatively send the tx and rx buffers
- * as separate messages.
- *
- * Depending on the hardware in use, a single message may be more efficient
- * on interrupts or work done by the driver.
- *
- * This currently always returns true until we add some per-device data passed
- * from the platform code to specify which mode is better.
- */
-static inline bool ks8851_rx_1msg(struct ks8851_net *ks)
-{
-	return true;
-}
-
-/**
  * ks8851_rdreg - issue read register command and return the data
  * @ks: The device state
  * @op: The register address and byte enables in message format.
@@ -251,14 +232,7 @@ static void ks8851_rdreg(struct ks8851_net *ks, unsigned op,
 
 	txb[0] = cpu_to_le16(op | KS_SPIOP_RD);
 
-	if (ks8851_rx_1msg(ks)) {
-		msg = &ks->spi_msg1;
-		xfer = &ks->spi_xfer1;
-
-		xfer->tx_buf = txb;
-		xfer->rx_buf = trx;
-		xfer->len = rxl + 2;
-	} else {
+	if (ks->spidev->master->flags & SPI_MASTER_HALF_DUPLEX) {
 		msg = &ks->spi_msg2;
 		xfer = ks->spi_xfer2;
 
@@ -270,15 +244,22 @@ static void ks8851_rdreg(struct ks8851_net *ks, unsigned op,
 		xfer->tx_buf = NULL;
 		xfer->rx_buf = trx;
 		xfer->len = rxl;
+	} else {
+		msg = &ks->spi_msg1;
+		xfer = &ks->spi_xfer1;
+
+		xfer->tx_buf = txb;
+		xfer->rx_buf = trx;
+		xfer->len = rxl + 2;
 	}
 
 	ret = spi_sync(ks->spidev, msg);
 	if (ret < 0)
 		netdev_err(ks->netdev, "read: spi_sync() failed\n");
-	else if (ks8851_rx_1msg(ks))
-		memcpy(rxb, trx + 2, rxl);
-	else
+	else if (ks->spidev->master->flags & SPI_MASTER_HALF_DUPLEX)
 		memcpy(rxb, trx, rxl);
+	else
+		memcpy(rxb, trx + 2, rxl);
 }
 
 /**
-- 
1.9.1
