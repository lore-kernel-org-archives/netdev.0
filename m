From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH v8 net-next 08/17] net: qualcomm: move qcaspi_tx_cmd to qca_spi.c
Date: Mon, 29 May 2017 13:57:16 +0200
Message-ID: <1496059045-13572-9-git-send-email-stefan.wahren@i2se.com>
References: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Jakub Kicinski <kubakici@wp.pl>, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Stefan Wahren <stefan.wahren@i2se.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:60783 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751002AbdE2L5u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 07:57:50 -0400
In-Reply-To: <1496059045-13572-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function qcaspi_tx_cmd() is only called from qca_spi.c. So we better
move it there.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/qca_7k.c  | 24 ------------------------
 drivers/net/ethernet/qualcomm/qca_7k.h  |  1 -
 drivers/net/ethernet/qualcomm/qca_spi.c | 24 ++++++++++++++++++++++++
 3 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/qca_7k.c b/drivers/net/ethernet/qualcomm/qca_7k.c
index e9162e1..ffe7a16 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k.c
+++ b/drivers/net/ethernet/qualcomm/qca_7k.c
@@ -121,27 +121,3 @@ qcaspi_write_register(struct qcaspi *qca, u16 reg, u16 value)
 
 	return ret;
 }
-
-int
-qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd)
-{
-	__be16 tx_data;
-	struct spi_message *msg = &qca->spi_msg1;
-	struct spi_transfer *transfer = &qca->spi_xfer1;
-	int ret;
-
-	tx_data = cpu_to_be16(cmd);
-	transfer->len = sizeof(tx_data);
-	transfer->tx_buf = &tx_data;
-	transfer->rx_buf = NULL;
-
-	ret = spi_sync(qca->spi_dev, msg);
-
-	if (!ret)
-		ret = msg->status;
-
-	if (ret)
-		qcaspi_spi_error(qca);
-
-	return ret;
-}
diff --git a/drivers/net/ethernet/qualcomm/qca_7k.h b/drivers/net/ethernet/qualcomm/qca_7k.h
index 4047f0a..27124c2 100644
--- a/drivers/net/ethernet/qualcomm/qca_7k.h
+++ b/drivers/net/ethernet/qualcomm/qca_7k.h
@@ -67,6 +67,5 @@
 void qcaspi_spi_error(struct qcaspi *qca);
 int qcaspi_read_register(struct qcaspi *qca, u16 reg, u16 *result);
 int qcaspi_write_register(struct qcaspi *qca, u16 reg, u16 value);
-int qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd);
 
 #endif /* _QCA_7K_H */
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 7464628..50adc4f 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -192,6 +192,30 @@ qcaspi_read_legacy(struct qcaspi *qca, u8 *dst, u32 len)
 }
 
 static int
+qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd)
+{
+	__be16 tx_data;
+	struct spi_message *msg = &qca->spi_msg1;
+	struct spi_transfer *transfer = &qca->spi_xfer1;
+	int ret;
+
+	tx_data = cpu_to_be16(cmd);
+	transfer->len = sizeof(tx_data);
+	transfer->tx_buf = &tx_data;
+	transfer->rx_buf = NULL;
+
+	ret = spi_sync(qca->spi_dev, msg);
+
+	if (!ret)
+		ret = msg->status;
+
+	if (ret)
+		qcaspi_spi_error(qca);
+
+	return ret;
+}
+
+static int
 qcaspi_tx_frame(struct qcaspi *qca, struct sk_buff *skb)
 {
 	u32 count;
-- 
2.1.4
