From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH V5 1/2] can: m_can: fix not set can_dlc for remote frame
Date: Tue, 18 Nov 2014 19:00:54 +0800
Message-ID: <1416308455-29134-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mkl@pengutronix.de>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <b29396@freescale.com>,
	<linux-arm-kernel@lists.infradead.org>
To: <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The original code missed to set the cf->can_dlc in the RTR case, so add it.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
---
 drivers/net/can/m_can/m_can.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 06541f1..2f61676 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -331,7 +331,7 @@ static void m_can_read_fifo(const struct net_device *dev, struct can_frame *cf,
 			    u32 rxfs)
 {
 	struct m_can_priv *priv = netdev_priv(dev);
-	u32 id, fgi;
+	u32 id, fgi, dlc;
 
 	/* calculate the fifo get index for where to read data */
 	fgi = (rxfs & RXFS_FGI_MASK) >> RXFS_FGI_OFF;
@@ -341,11 +341,12 @@ static void m_can_read_fifo(const struct net_device *dev, struct can_frame *cf,
 	else
 		cf->can_id = (id >> 18) & CAN_SFF_MASK;
 
+	dlc = m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
+	cf->can_dlc = get_can_dlc((dlc >> 16) & 0x0F);
+
 	if (id & RX_BUF_RTR) {
 		cf->can_id |= CAN_RTR_FLAG;
 	} else {
-		id = m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
-		cf->can_dlc = get_can_dlc((id >> 16) & 0x0F);
 		*(u32 *)(cf->data + 0) = m_can_fifo_read(priv, fgi,
 							 M_CAN_FIFO_DATA(0));
 		*(u32 *)(cf->data + 4) = m_can_fifo_read(priv, fgi,
-- 
1.9.1

