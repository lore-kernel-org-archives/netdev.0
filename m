From: Michael Heimpold <mhei@heimpold.de>
Subject: [PATCH net-next 1/2] net: ethernet: enc28j60: support half-duplex SPI controllers
Date: Sat, 23 Apr 2016 23:43:19 +0200
Message-ID: <1461447800-11381-2-git-send-email-mhei@heimpold.de>
References: <1461447800-11381-1-git-send-email-mhei@heimpold.de>
Cc: Michael Heimpold <mhei@heimpold.de>
To: Jonathan Cameron <jic23@kernel.org>,
	"Andrew F . Davis" <afd@ti.com>, Mark Brown <broonie@kernel.org>,
	netdev@vger.kernel.org,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:28841 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbcDWVoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 17:44:07 -0400
In-Reply-To: <1461447800-11381-1-git-send-email-mhei@heimpold.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current spi_read_buf function fails on SPI host masters which
are only half-duplex capable. Splitting the Tx and Rx part solves
this issue.

Tested on Raspberry Pi (full duplex) and I2SE Duckbill (half duplex).

Signed-off-by: Michael Heimpold <mhei@heimpold.de>
---
 drivers/net/ethernet/microchip/enc28j60.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 86ea17e..b723622 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -89,22 +89,26 @@ spi_read_buf(struct enc28j60_net *priv, int len, u8 *data)
 {
 	u8 *rx_buf = priv->spi_transfer_buf + 4;
 	u8 *tx_buf = priv->spi_transfer_buf;
-	struct spi_transfer t = {
+	struct spi_transfer tx = {
 		.tx_buf = tx_buf,
+		.len = SPI_OPLEN,
+	};
+	struct spi_transfer rx = {
 		.rx_buf = rx_buf,
-		.len = SPI_OPLEN + len,
+		.len = len,
 	};
 	struct spi_message msg;
 	int ret;
 
 	tx_buf[0] = ENC28J60_READ_BUF_MEM;
-	tx_buf[1] = tx_buf[2] = tx_buf[3] = 0;	/* don't care */
 
 	spi_message_init(&msg);
-	spi_message_add_tail(&t, &msg);
+	spi_message_add_tail(&tx, &msg);
+	spi_message_add_tail(&rx, &msg);
+
 	ret = spi_sync(priv->spi, &msg);
 	if (ret == 0) {
-		memcpy(data, &rx_buf[SPI_OPLEN], len);
+		memcpy(data, rx_buf, len);
 		ret = msg.status;
 	}
 	if (ret && netif_msg_drv(priv))
-- 
2.5.0
