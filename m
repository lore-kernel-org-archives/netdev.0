From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 2/2] can: xilinx: fix RX FIFO overflow error handling
Date: Mon,  7 Aug 2017 15:47:57 +0200
Message-ID: <67efa4531bb8b83d5539c0bc0af32a9c9a523627.1502113674.git.michal.simek@xilinx.com>
References: <21850c76207942f5ae5c225f2627fb068d5234d0.1502113674.git.michal.simek@xilinx.com>
Cc: Andrea Scian <andrea.scian@dave.eu>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
        linux-can@vger.kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
        linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org, monstr@monstr.eu
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <21850c76207942f5ae5c225f2627fb068d5234d0.1502113674.git.michal.simek@xilinx.com>
In-Reply-To: <21850c76207942f5ae5c225f2627fb068d5234d0.1502113674.git.michal.simek@xilinx.com>
References: <21850c76207942f5ae5c225f2627fb068d5234d0.1502113674.git.michal.simek@xilinx.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrea Scian <andrea.scian@dave.eu>

Simply resetting the peripheral on RX FIFO overflow in not enough,
because we also need to re-initialize the whole device.
Also always enable RX FIFO overflow interrupt otherwise we may hang
until another interrupt arrives (this happens if FIFO overrun and just
read from CAN bus with candump)

Signed-off-by: Andrea Scian <andrea.scian@dave.eu>
Reviewed-by: Kedareswara rao Appana <appanad@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/can/xilinx_can.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 05ea2820d27b..2c119d16861e 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -101,6 +101,7 @@ enum xcan_reg {
 #define XCAN_INTR_ALL		(XCAN_IXR_TXOK_MASK | XCAN_IXR_BSOFF_MASK |\
 				 XCAN_IXR_WKUP_MASK | XCAN_IXR_SLP_MASK | \
 				 XCAN_IXR_RXNEMP_MASK | XCAN_IXR_ERROR_MASK | \
+				 XCAN_IXR_RXOFLW_MASK | \
 				 XCAN_IXR_ARBLST_MASK)
 
 /* CAN register bit shift - XCAN_<REG>_<BIT>_SHIFT */
@@ -529,6 +530,8 @@ static int xcan_rx(struct net_device *ndev)
 	return 1;
 }
 
+static void xcan_chip_stop(struct net_device *ndev);
+
 /**
  * xcan_err_interrupt - error frame Isr
  * @ndev:	net_device pointer
@@ -600,7 +603,8 @@ static void xcan_err_interrupt(struct net_device *ndev, u32 isr)
 	if (isr & XCAN_IXR_RXOFLW_MASK) {
 		stats->rx_over_errors++;
 		stats->rx_errors++;
-		priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_RESET_MASK);
+		xcan_chip_stop(ndev);
+		xcan_chip_start(ndev);
 		if (skb) {
 			cf->can_id |= CAN_ERR_CRTL;
 			cf->data[1] |= CAN_ERR_CRTL_RX_OVERFLOW;
-- 
1.9.1

