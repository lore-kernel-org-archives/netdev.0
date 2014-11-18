From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 14/17] can: m_can: fix not set can_dlc for remote frame
Date: Tue, 18 Nov 2014 21:37:44 +0100
Message-ID: <1416343067-9810-15-git-send-email-mkl@pengutronix.de>
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

The original code missed to set the cf->can_dlc in the RTR case, so add it.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/m_can/m_can.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 214160b4c314..98f7e0ea7f6a 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -330,7 +330,7 @@ static void m_can_read_fifo(const struct net_device *dev, struct can_frame *cf,
 			    u32 rxfs)
 {
 	struct m_can_priv *priv = netdev_priv(dev);
-	u32 id, fgi;
+	u32 id, fgi, dlc;
 
 	/* calculate the fifo get index for where to read data */
 	fgi = (rxfs & RXFS_FGI_MASK) >> RXFS_FGI_OFF;
@@ -340,11 +340,12 @@ static void m_can_read_fifo(const struct net_device *dev, struct can_frame *cf,
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
2.1.3

