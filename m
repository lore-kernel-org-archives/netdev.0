From: Jeppe Ledet-Pedersen <jlp@gomspace.com>
Subject: [PATCH] net: can: xilinx_can: fix extended frame handling
Date: Wed, 29 Apr 2015 17:05:01 +0200
Message-ID: <1430319901-19242-1-git-send-email-jlp@gomspace.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Jeppe Ledet-Pedersen <jlp@gomspace.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using IDR_SRR in RXFIFO_ID to test for the presence of data is only
valid for standard frames. For extended frames the bit is always 1 and
IDR_RTR should be used instead. This patch switches the check to use
CAN_RTR_FLAG which is correctly set when reading the ID.

The patch also changes the DW1/DW2 to be read unconditionally, since
this is necessary to remove the frame from the RXFIFO.

Signed-off-by: Jeppe Ledet-Pedersen <jlp@gomspace.com>
Acked-by: Kedareswara rao Appana <appanad@xilinx.com>
---
 drivers/net/can/xilinx_can.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 6c67643..0b27769 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -509,10 +509,11 @@ static int xcan_rx(struct net_device *ndev)
 			cf->can_id |= CAN_RTR_FLAG;
 	}
 
-	if (!(id_xcan & XCAN_IDR_SRR_MASK)) {
-		data[0] = priv->read_reg(priv, XCAN_RXFIFO_DW1_OFFSET);
-		data[1] = priv->read_reg(priv, XCAN_RXFIFO_DW2_OFFSET);
+	/* DW1/DW2 must always be read to remove message from RXFIFO */
+	data[0] = priv->read_reg(priv, XCAN_RXFIFO_DW1_OFFSET);
+	data[1] = priv->read_reg(priv, XCAN_RXFIFO_DW2_OFFSET);
 
+	if (!(cf->can_id & CAN_RTR_FLAG)) {
 		/* Change Xilinx CAN data format to socketCAN data format */
 		if (cf->can_dlc > 0)
 			*(__be32 *)(cf->data) = cpu_to_be32(data[0]);
-- 
2.1.0
