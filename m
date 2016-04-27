From: Elad Kanfi <eladkan@mellanox.com>
Subject: [PATCH v2 2/2] net: nps_enet: bug fix - handle lost tx interrupts
Date: Wed, 27 Apr 2016 16:18:30 +0300
Message-ID: <1461763110-15263-3-git-send-email-eladkan@mellanox.com>
References: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <noamca@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <eladkan@mellanox.com>,
	<talz@mellanox.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0081.outbound.protection.outlook.com ([104.47.2.81]:43424
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752147AbcD0OvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 10:51:21 -0400
In-Reply-To: <1461763110-15263-1-git-send-email-eladkan@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Kanfi <eladkan@mellanox.com>

The tx interrupt is of edge type, and in case such interrupt is triggered
while it is masked it will not be handled even after tx interrupts are
re-enabled in the end of NAPI poll.
This will cause tx network to stop in the following scenario:
 * Rx is being handled, hence interrupts are masked.
 * Tx interrupt is triggered after checking if there is some tx to handle
   and before re-enabling the interrupts.
In this situation only rx transaction will release tx requests.

In order to handle the tx that was missed( if there was one ),
a NAPI reschdule was added after enabling the interrupts.

Signed-off-by: Elad Kanfi <eladkan@mellanox.com>

Acked-by: Noam Camus <noamca@mellanox.com>
---
 drivers/net/ethernet/ezchip/nps_enet.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ezchip/nps_enet.c b/drivers/net/ethernet/ezchip/nps_enet.c
index 1373236..31e27a7 100644
--- a/drivers/net/ethernet/ezchip/nps_enet.c
+++ b/drivers/net/ethernet/ezchip/nps_enet.c
@@ -183,6 +183,8 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 	work_done = nps_enet_rx_handler(ndev);
 	if (work_done < budget) {
 		u32 buf_int_enable_value = 0;
+		u32 tx_ctrl_value = nps_enet_reg_get(priv, NPS_ENET_REG_TX_CTL);
+		u32 tx_ctrl_ct = (tx_ctrl_value & TX_CTL_CT_MASK) >> TX_CTL_CT_SHIFT;
 
 		napi_complete(napi);
 
@@ -192,6 +194,18 @@ static int nps_enet_poll(struct napi_struct *napi, int budget)
 
 		nps_enet_reg_set(priv, NPS_ENET_REG_BUF_INT_ENABLE,
 				 buf_int_enable_value);
+
+		/* in case we will get a tx interrupt while interrupts
+		 * are masked, we will lose it since the tx is edge interrupt.
+		 * specifically, while executing the code section above,
+		 * between nps_enet_tx_handler and the interrupts enable, all
+		 * tx requests will be stuck until we will get an rx interrupt.
+		 * the two code lines below will solve this situation by
+		 * re-adding ourselves to the poll list.
+		 */
+
+		if (priv->tx_packet_sent && !tx_ctrl_ct)
+			napi_reschedule(napi);
 	}
 
 	return work_done;
-- 
1.7.1
