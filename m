From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH 3/3] can: m_can: add loopback and monitor mode support
Date: Fri, 27 Jun 2014 18:00:46 +0800
Message-ID: <1403863246-18822-4-git-send-email-b29396@freescale.com>
References: <1403863246-18822-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <wg@grandegger.com>,
	<mkl@pengutronix.de>, <devicetree@vger.kernel.org>
To: <linux-can@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0186.outbound.protection.outlook.com ([207.46.163.186]:1266
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753420AbaF0Lbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2014 07:31:40 -0400
In-Reply-To: <1403863246-18822-1-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add loopback and monitor mode support.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
---
 drivers/net/can/m_can.c |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/m_can.c b/drivers/net/can/m_can.c
index e4aed71..bbe8a7d 100644
--- a/drivers/net/can/m_can.c
+++ b/drivers/net/can/m_can.c
@@ -94,8 +94,12 @@ enum m_can_lec_type {
 	LEC_CRC_ERROR,
 	LEC_UNUSED,
 };
+/* Test Register (TEST) */
+#define TEST_LBCK	BIT(4)
 
 /* CC Control Register(CCCR) */
+#define CCCR_TEST	BIT(7)
+#define CCCR_MON	BIT(5)
 #define CCCR_CCE	BIT(1)
 #define CCCR_INIT	BIT(0)
 
@@ -661,13 +665,13 @@ static int m_can_set_bittiming(struct net_device *dev)
  * - configure rx fifo
  * - accept non-matching frame into fifo 0
  * - configure tx buffer
+ * - configure mode
  * - setup bittiming
- * - TODO:
- *   1) other working modes support like monitor, loopback...
  */
 static void m_can_chip_config(struct net_device *dev)
 {
 	struct m_can_priv *priv = netdev_priv(dev);
+	u32 cccr, test;
 
 	m_can_config_endisable(priv, true);
 
@@ -694,6 +698,22 @@ static void m_can_chip_config(struct net_device *dev)
 	m_can_write(priv, M_CAN_RXF1C, (priv->rxf1_elems << RXFC_FS_OFF) |
 		RXFC_FWM_1 | (priv->mram_off + priv->rxf1_off));
 
+	cccr = m_can_read(priv, M_CAN_CCCR);
+	cccr &= ~(CCCR_TEST | CCCR_MON);
+	test = m_can_read(priv, M_CAN_TEST);
+	test &= ~TEST_LBCK;
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
+		cccr |= CCCR_MON;
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
+		cccr |= CCCR_TEST;
+		test |= TEST_LBCK;
+	}
+
+	m_can_write(priv, M_CAN_CCCR, cccr);
+	m_can_write(priv, M_CAN_TEST, test);
+
 	/* enable all interrupts */
 	m_can_write(priv, M_CAN_IR, IR_ALL_INT);
 	m_can_write(priv, M_CAN_IE, IR_ALL_INT);
-- 
1.7.8
