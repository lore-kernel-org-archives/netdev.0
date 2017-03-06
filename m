From: Wenyou Yang <wenyou.yang@atmel.com>
Subject: [PATCH v2] can: m_can: enable transmission of FD frame on latest version
Date: Mon, 6 Mar 2017 10:21:43 +0800
Message-ID: <20170306022143.7695-1-wenyou.yang@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Quentin Schulz <quentin.schulz@free-electrons.com>,
        Wenyou Yang <wenyou.yang@microchip.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Wenyou Yang <wenyou.yang@atmel.com>
To: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enables the transmission of CAN FD frames on M_CAN IP core >= v3.1.x
and with the bit rate switching.

Tested on M_CAN IP 3.1.0 (CREL = 0x31040730) of SAMA5D2 SoC.

Signed-off-by: Wenyou Yang <wenyou.yang@atmel.com>
---
The testing is based on
[RESEND PATCH 1/1] can: m_can: fix bitrate setup on latest silicon
http://lkml.iu.edu/hypermail/linux/kernel/1702.1/05347.html

Changes in v2:
 - Rename TX_BUF_EDL with TX_BUF_FDF.
 - Improve the commit log to avoid misleading.

 drivers/net/can/m_can/m_can.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 246584ed89b6..c2dd2550de40 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -283,8 +283,12 @@ enum m_can_mram_cfg {
 
 /* Tx Buffer Element */
 /* R0 */
+#define TX_BUF_ESI		BIT(31)
 #define TX_BUF_XTD		BIT(30)
 #define TX_BUF_RTR		BIT(29)
+#define TX_BUF_EFC		BIT(23)
+#define TX_BUF_FDF		BIT(21)
+#define TX_BUF_BRS		BIT(20)
 
 /* address offset and element number for each FIFO/Buffer in the Message RAM */
 struct mram_cfg {
@@ -916,7 +920,7 @@ static void m_can_chip_config(struct net_device *dev)
 	}
 
 	if (priv->can.ctrlmode & CAN_CTRLMODE_FD)
-		cccr |= CCCR_CME_CANFD_BRS << CCCR_CME_SHIFT;
+		cccr |= (CCCR_CME_CANFD_BRS | CCCR_CME_CANFD) << CCCR_CME_SHIFT;
 
 	m_can_write(priv, M_CAN_CCCR, cccr);
 	m_can_write(priv, M_CAN_TEST, test);
@@ -1079,6 +1083,7 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
 	struct canfd_frame *cf = (struct canfd_frame *)skb->data;
 	u32 id, cccr;
 	int i;
+	u32 dlc;
 
 	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
@@ -1097,7 +1102,6 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
 
 	/* message ram configuration */
 	m_can_fifo_write(priv, 0, M_CAN_FIFO_ID, id);
-	m_can_fifo_write(priv, 0, M_CAN_FIFO_DLC, can_len2dlc(cf->len) << 16);
 
 	for (i = 0; i < cf->len; i += 4)
 		m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
@@ -1105,20 +1109,29 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
 
 	can_put_echo_skb(skb, dev, 0);
 
+	dlc = can_len2dlc(cf->len) << 16;
+
 	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
 		cccr = m_can_read(priv, M_CAN_CCCR);
 		cccr &= ~(CCCR_CMR_MASK << CCCR_CMR_SHIFT);
 		if (can_is_canfd_skb(skb)) {
-			if (cf->flags & CANFD_BRS)
+			dlc |= TX_BUF_FDF;
+			if (cf->flags & CANFD_ESI)
+				dlc |= TX_BUF_ESI;
+			if (cf->flags & CANFD_BRS) {
+				dlc |= TX_BUF_BRS;
 				cccr |= CCCR_CMR_CANFD_BRS << CCCR_CMR_SHIFT;
-			else
+			} else {
 				cccr |= CCCR_CMR_CANFD << CCCR_CMR_SHIFT;
+			}
 		} else {
 			cccr |= CCCR_CMR_CAN << CCCR_CMR_SHIFT;
 		}
 		m_can_write(priv, M_CAN_CCCR, cccr);
 	}
 
+	m_can_fifo_write(priv, 0, M_CAN_FIFO_DLC, dlc);
+
 	/* enable first TX buffer to start transfer  */
 	m_can_write(priv, M_CAN_TXBTIE, 0x1);
 	m_can_write(priv, M_CAN_TXBAR, 0x1);
-- 
2.11.0

