From: Noam Camus <noamc@ezchip.com>
Subject: [v1 2/6] NET: nps_enet: reduce processing latency.
Date: Mon, 17 Aug 2015 08:58:35 +0300
Message-ID: <1439791119-26892-3-git-send-email-noamc@ezchip.com>
References: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
 <1439791119-26892-2-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <Alexey.Brodkin@synopsys.com>,
	<vgupta@synopsys.com>, <talz@ezchip.com>,
	Noam Camus <noamc@ezchip.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439791119-26892-2-git-send-email-noamc@ezchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>

TX handler is minimalistic and there is no need to schedule
a NAPI job.
Tx done will be processed during hardware interrupt context.

Signed-off-by: Noam Camus <noamc@ezchip.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 0e652b4..af72181 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -159,7 +159,7 @@ static void nps_enet_tx_handler(struct net_device *ndev)
 	}
 
 	if (priv->tx_skb) {
-		dev_kfree_skb(priv->tx_skb);
+		dev_kfree_skb_irq(priv->tx_skb);
 		priv->tx_skb = NULL;
 	}
 
@@ -185,7 +185,6 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 
 	buf_int_enable.rx_rdy = NPS_ENET_ENABLE;
 	buf_int_enable.tx_done = NPS_ENET_ENABLE;
-	nps_enet_tx_handler(ndev);
 	work_done = nps_enet_rx_handler(ndev);
 	if (work_done < budget) {
 		napi_complete(napi);
@@ -212,14 +211,18 @@ static irqreturn_t nps_enet_irq_handler(s32 irq, void *dev_instance)
 	struct net_device *ndev = dev_instance;
 	struct nps_enet_priv *priv = netdev_priv(ndev);
 	struct nps_enet_rx_ctl rx_ctrl;
-	struct nps_enet_tx_ctl tx_ctrl;
 
-	rx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
-	tx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
+	nps_enet_tx_handler(ndev);
 
-	if ((!tx_ctrl.ct && priv->tx_packet_sent) || rx_ctrl.cr)
+	rx_ctrl.value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
+	if (rx_ctrl.cr)
 		if (likely(napi_schedule_prep(&priv->napi))) {
-			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
+			struct nps_enet_buf_int_enable buf_int_enable;
+
+			buf_int_enable.rx_rdy = NPS_ENET_DISABLE;
+			buf_int_enable.tx_done = NPS_ENET_ENABLE;
+			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE,
+					 buf_int_enable.value);
 			__napi_schedule(&priv->napi);
 		}
 
-- 
1.7.1
