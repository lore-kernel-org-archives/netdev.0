From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [PATCH 2/2] can: xilinx: fix bug in bus error handling
Date: Thu, 22 Oct 2015 10:16:03 +0530
Message-ID: <1445489163-11045-2-git-send-email-appanad__49468.8057843179$1445490170$gmane$org@xilinx.com>
References: <1445489163-11045-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>
To: <anirudh@xilinx.com>, <wg@grandegger.com>, <mkl@pengutronix.de>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<appanad@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445489163-11045-1-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simply resetting the peripheral on bus off condition is not enough,
Because we also need to re-initialize the whole device.
This patch fixes this issue.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
 drivers/net/can/xilinx_can.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 055d6f3..9aeb85f 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -529,6 +529,8 @@ static int xcan_rx(struct net_device *ndev)
 	return 1;
 }
 
+static void xcan_chip_stop(struct net_device *ndev);
+
 /**
  * xcan_err_interrupt - error frame Isr
  * @ndev:	net_device pointer
@@ -558,8 +560,9 @@ static void xcan_err_interrupt(struct net_device *ndev, u32 isr)
 	if (isr & XCAN_IXR_BSOFF_MASK) {
 		priv->can.state = CAN_STATE_BUS_OFF;
 		priv->can.can_stats.bus_off++;
-		/* Leave device in Config Mode in bus-off state */
-		priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_RESET_MASK);
+		/* Re-initialize the whole device in bus-off state */
+		xcan_chip_stop(ndev);
+		xcan_chip_start(ndev);
 		can_bus_off(ndev);
 		if (skb)
 			cf->can_id |= CAN_ERR_BUSOFF;
-- 
2.1.2
