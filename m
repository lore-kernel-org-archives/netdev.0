From: Noam Camus <noamc@ezchip.com>
Subject: [v1 1/6] NET: nps_enet: replace use of cause register
Date: Mon, 17 Aug 2015 08:58:34 +0300
Message-ID: <1439791119-26892-2-git-send-email-noamc@ezchip.com>
References: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Alexey.Brodkin@synopsys.com>,
	<vgupta@synopsys.com>, <talz@ezchip.com>,
	Noam Camus <noamc@ezchip.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>

When interrupt is received we read directly from control
register for RX/TX instead of reading cause register
since this register fails to indicate TX done when
TX interrupt is "edge mode".

Signed-off-by: Noam Camus <noamc@ezchip.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |    9 +++++----
 drivers/net/ethernet/ezchip/nps_enet.h |   20 --------------------
 2 files changed, 5 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 24a85b2..0e652b4 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -211,12 +211,13 @@ static irqreturn_t nps_enet_irq_handler(s32 irq, void *dev_instance)
 {
 	struct net_device *ndev = dev_instance;
 	struct nps_enet_priv *priv = netdev_priv(ndev);
-	struct nps_enet_buf_int_cause buf_int_cause;
+	struct nps_enet_rx_ctl rx_ctrl;
+	struct nps_enet_tx_ctl tx_ctrl;
 
-	buf_int_cause.value =
-			nps_enet_reg_get(priv, NPS_ENET_REG_BUF_INT_CAUSE);
+	rx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
+	tx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
 
-	if (buf_int_cause.tx_done || buf_int_cause.rx_rdy)
+	if ((!tx_ctrl.ct && priv->tx_packet_sent) || rx_ctrl.cr)
 		if (likely(napi_schedule_prep(&priv->napi))) {
 			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
 			__napi_schedule(&priv->napi);
diff --git a/drivers/net/ethernet/ezchip/nps_enet.h b/drivers/net/ethernet/ezchip/nps_enet.h
index fc45c9d..6703674 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.h
+++ b/drivers/net/ethernet/ezchip/nps_enet.h
@@ -36,7 +36,6 @@
 #define NPS_ENET_REG_RX_CTL		0x810
 #define NPS_ENET_REG_RX_BUF		0x818
 #define NPS_ENET_REG_BUF_INT_ENABLE	0x8C0
-#define NPS_ENET_REG_BUF_INT_CAUSE	0x8C4
 #define NPS_ENET_REG_GE_MAC_CFG_0	0x1000
 #define NPS_ENET_REG_GE_MAC_CFG_1	0x1004
 #define NPS_ENET_REG_GE_MAC_CFG_2	0x1008
@@ -108,25 +107,6 @@ struct nps_enet_buf_int_enable {
 	};
 };
 
-/* Interrupt cause for data buffer events register */
-struct nps_enet_buf_int_cause {
-	union {
-		/* tx_done: Interrupt in the case when current frame was
-		 *          read from TX buffer.
-		 * rx_rdy:  Interrupt in the case when new frame is ready
-		 *          in RX buffer.
-		 */
-		struct {
-			u32
-			__reserved:30,
-			tx_done:1,
-			rx_rdy:1;
-		};
-
-		u32 value;
-	};
-};
-
 /* Gbps Eth MAC Configuration 0 register */
 struct nps_enet_ge_mac_cfg_0 {
 	union {
-- 
1.7.1
