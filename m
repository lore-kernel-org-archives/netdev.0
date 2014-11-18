From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 12/17] can: m_can: add missing message RAM initialization
Date: Tue, 18 Nov 2014 21:37:42 +0100
Message-ID: <1416343067-9810-13-git-send-email-mkl@pengutronix.de>
References: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Dong Aisheng <b29396@freescale.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dong Aisheng <b29396@freescale.com>

The M_CAN message RAM is usually equipped with a parity or ECC functionality.
But RAM cells suffer a hardware reset and can therefore hold arbitrary content
at startup - including parity and/or ECC bits.

To prevent the M_CAN controller detecting checksum errors when reading
potentially uninitialized TX message RAM content to transmit CAN frames the TX
message RAM has to be written with (any kind of) initial data.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/m_can/m_can.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index e61886bf1bb3..268ad5064c47 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -1010,7 +1010,7 @@ static int m_can_of_parse_mram(struct platform_device *pdev,
 	struct resource *res;
 	void __iomem *addr;
 	u32 out_val[MRAM_CFG_LEN];
-	int ret;
+	int i, start, end, ret;
 
 	/* message ram could be shared */
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "message_ram");
@@ -1061,6 +1061,15 @@ static int m_can_of_parse_mram(struct platform_device *pdev,
 		priv->mcfg[MRAM_TXE].off, priv->mcfg[MRAM_TXE].num,
 		priv->mcfg[MRAM_TXB].off, priv->mcfg[MRAM_TXB].num);
 
+	/* initialize the entire Message RAM in use to avoid possible
+	 * ECC/parity checksum errors when reading an uninitialized buffer
+	 */
+	start = priv->mcfg[MRAM_SIDF].off;
+	end = priv->mcfg[MRAM_TXB].off +
+		priv->mcfg[MRAM_TXB].num * TXB_ELEMENT_SIZE;
+	for (i = start; i < end; i += 4)
+		writel(0x0, priv->mram_base + i);
+
 	return 0;
 }
 
-- 
2.1.3

