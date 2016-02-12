From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 5/9] amd-xgbe: Enable/disable PFC per traffic
 class
Date: Fri, 12 Feb 2016 08:33:05 -0600
Message-ID: <20160212143305.23973.49474.stgit@tlendack-t1.amdoffice.net>
References: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0061.outbound.protection.outlook.com ([157.56.111.61]:52428
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751117AbcBLOtD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:49:03 -0500
In-Reply-To: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the PFC flow control is enabled on all traffic classes if
one or more traffic classes request it. The PFC enable setting of the
traffic class should be used to determine whether to enable or disable
flow control for the traffic class.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   36 ++++++++++++++++++++++++++++--
 1 file changed, 34 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index f988392..c1620c1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -518,13 +518,45 @@ static int xgbe_disable_tx_flow_control(struct xgbe_prv_data *pdata)
 
 static int xgbe_enable_tx_flow_control(struct xgbe_prv_data *pdata)
 {
+	struct ieee_pfc *pfc = pdata->pfc;
+	struct ieee_ets *ets = pdata->ets;
 	unsigned int max_q_count, q_count;
 	unsigned int reg, reg_val;
 	unsigned int i;
 
 	/* Set MTL flow control */
-	for (i = 0; i < pdata->rx_q_count; i++)
-		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, EHFC, 1);
+	for (i = 0; i < pdata->rx_q_count; i++) {
+		unsigned int ehfc = 0;
+
+		if (pfc && ets) {
+			unsigned int prio;
+
+			for (prio = 0; prio < IEEE_8021QAZ_MAX_TCS; prio++) {
+				unsigned int tc;
+
+				/* Does this queue handle the priority? */
+				if (pdata->prio2q_map[prio] != i)
+					continue;
+
+				/* Get the Traffic Class for this priority */
+				tc = ets->prio_tc[prio];
+
+				/* Check if flow control should be enabled */
+				if (pfc->pfc_en & (1 << tc)) {
+					ehfc = 1;
+					break;
+				}
+			}
+		} else {
+			ehfc = 1;
+		}
+
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, EHFC, ehfc);
+
+		netif_dbg(pdata, drv, pdata->netdev,
+			  "flow control %s for RXq%u\n",
+			  ehfc ? "enabled" : "disabled", i);
+	}
 
 	/* Set MAC flow control */
 	max_q_count = XGMAC_MAX_FLOW_CONTROL_QUEUES;
