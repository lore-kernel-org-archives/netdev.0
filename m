From: Elad Kanfi <eladkan@mellanox.com>
Subject: [PATCH 2/2] net: nps_enet: code reuse
Date: Wed, 13 Jul 2016 16:58:07 +0300
Message-ID: <1468418287-26512-3-git-send-email-eladkan@mellanox.com>
References: <1468418287-26512-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eladkan@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <netdev@vger.kernel.org>,
	<noamca@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0063.outbound.protection.outlook.com ([104.47.2.63]:11744
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751079AbcGNDgm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 23:36:42 -0400
In-Reply-To: <1468418287-26512-1-git-send-email-eladkan@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Kanfi <eladkan@mellanox.com>

Add inline function that checks if there is a pending tx packet.

Signed-off-by: Elad Kanfi <eladkan@mellanox.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index b182e2a..25faa3d 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -24,6 +24,14 @@
 
 #define DRV_NAME			"nps_mgt_enet"
 
+static inline bool nps_enet_is_tx_pending(struct nps_enet_priv *priv)
+{
+	u32 tx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
+	u32 tx_ctrl_ct = (tx_ctrl_value & TX_CTL_CT_MASK) >> TX_CTL_CT_SHIFT;
+
+	return (!tx_ctrl_ct && priv->tx_skb);
+}
+
 static void nps_enet_clean_rx_fifo(struct net_device *ndev, u32 frame_len)
 {
 	struct nps_enet_priv *priv = netdev_priv(ndev);
@@ -141,12 +149,11 @@ static void nps_enet_tx_handler(struct net_device *ndev)
 {
 	struct nps_enet_priv *priv = netdev_priv(ndev);
 	u32 tx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
-	u32 tx_ctrl_ct = (tx_ctrl_value & TX_CTL_CT_MASK) >> TX_CTL_CT_SHIFT;
 	u32 tx_ctrl_et = (tx_ctrl_value & TX_CTL_ET_MASK) >> TX_CTL_ET_SHIFT;
 	u32 tx_ctrl_nt = (tx_ctrl_value & TX_CTL_NT_MASK) >> TX_CTL_NT_SHIFT;
 
 	/* Check if we got TX */
-	if (!priv->tx_skb || tx_ctrl_ct)
+	if (!nps_enet_is_tx_pending(priv))
 		return;
 
 	/* Ack Tx ctrl register */
@@ -184,9 +191,6 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 	work_done = nps_enet_rx_handler(ndev);
 	if (work_done < budget) {
 		u32 buf_int_enable_value = 0;
-		u32 tx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
-		u32 tx_ctrl_ct =
-			(tx_ctrl_value & TX_CTL_CT_MASK) >> TX_CTL_CT_SHIFT;
 
 		napi_complete(napi);
 
@@ -205,8 +209,7 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 		 * the two code lines below will solve this situation by
 		 * re-adding ourselves to the poll list.
 		 */
-
-		if (priv->tx_skb && !tx_ctrl_ct) {
+		if (nps_enet_is_tx_pending(priv)) {
 			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
 			napi_reschedule(napi);
 		}
@@ -231,11 +234,9 @@ static irqreturn_t nps_enet_irq_handler(s32 irq, void *dev_instance)
 	struct net_device *ndev = dev_instance;
 	struct nps_enet_priv *priv = netdev_priv(ndev);
 	u32 rx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_RX_CTL);
-	u32 tx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
-	u32 tx_ctrl_ct = (tx_ctrl_value & TX_CTL_CT_MASK) >> TX_CTL_CT_SHIFT;
 	u32 rx_ctrl_cr = (rx_ctrl_value & RX_CTL_CR_MASK) >> RX_CTL_CR_SHIFT;
 
-	if ((!tx_ctrl_ct && priv->tx_skb) || rx_ctrl_cr)
+	if (nps_enet_is_tx_pending(priv) || rx_ctrl_cr)
 		if (likely(napi_schedule_prep(&priv->napi))) {
 			nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE, 0);
 			__napi_schedule(&priv->napi);
-- 
1.7.1
