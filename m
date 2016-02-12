From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 6/9] amd-xgbe: Fix the mapping of priorities to
 traffic classes
Date: Fri, 12 Feb 2016 08:33:16 -0600
Message-ID: <20160212143316.23973.43856.stgit@tlendack-t1.amdoffice.net>
References: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0085.outbound.protection.outlook.com ([157.56.111.85]:7392
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751040AbcBLOsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:48:17 -0500
In-Reply-To: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver is checking the pfc_en field of the ieee_pfc structure to
determine whether to associate a priority with a traffic class. This is
incorrect since the pfc_en field is for determining if PFC is enabled
for a traffic class.

The association of priority to traffic class does not depend on whether
the traffic class is enabled for PFC, so remove that check. Also, the
mapping of priorities to traffic classes should be done when configuring
the traffic classes and not the PFC support so move the priority to traffic
class association from xgbe_config_dcb_pfc to xgbe_config_dcb_tc.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   50 +++++++++++++-----------------
 1 file changed, 21 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index c1620c1..93661bc 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1332,7 +1332,8 @@ static void xgbe_config_dcb_tc(struct xgbe_prv_data *pdata)
 {
 	struct ieee_ets *ets = pdata->ets;
 	unsigned int total_weight, min_weight, weight;
-	unsigned int i;
+	unsigned int mask, reg, reg_val;
+	unsigned int i, prio;
 
 	if (!ets)
 		return;
@@ -1349,6 +1350,25 @@ static void xgbe_config_dcb_tc(struct xgbe_prv_data *pdata)
 		min_weight = 1;
 
 	for (i = 0; i < pdata->hw_feat.tc_cnt; i++) {
+		/* Map the priorities to the traffic class */
+		mask = 0;
+		for (prio = 0; prio < IEEE_8021QAZ_MAX_TCS; prio++) {
+			if (ets->prio_tc[prio] == i)
+				mask |= (1 << prio);
+		}
+		mask &= 0xff;
+
+		netif_dbg(pdata, drv, pdata->netdev, "TC%u PRIO mask=%#x\n",
+			  i, mask);
+		reg = MTL_TCPM0R + (MTL_TCPM_INC * (i / MTL_TCPM_TC_PER_REG));
+		reg_val = XGMAC_IOREAD(pdata, reg);
+
+		reg_val &= ~(0xff << ((i % MTL_TCPM_TC_PER_REG) << 3));
+		reg_val |= (mask << ((i % MTL_TCPM_TC_PER_REG) << 3));
+
+		XGMAC_IOWRITE(pdata, reg, reg_val);
+
+		/* Set the traffic class algorithm */
 		switch (ets->tc_tsa[i]) {
 		case IEEE_8021QAZ_TSA_STRICT:
 			netif_dbg(pdata, drv, pdata->netdev,
@@ -1373,34 +1393,6 @@ static void xgbe_config_dcb_tc(struct xgbe_prv_data *pdata)
 
 static void xgbe_config_dcb_pfc(struct xgbe_prv_data *pdata)
 {
-	struct ieee_pfc *pfc = pdata->pfc;
-	struct ieee_ets *ets = pdata->ets;
-	unsigned int mask, reg, reg_val;
-	unsigned int tc, prio;
-
-	if (!pfc || !ets)
-		return;
-
-	for (tc = 0; tc < pdata->hw_feat.tc_cnt; tc++) {
-		mask = 0;
-		for (prio = 0; prio < IEEE_8021QAZ_MAX_TCS; prio++) {
-			if ((pfc->pfc_en & (1 << prio)) &&
-			    (ets->prio_tc[prio] == tc))
-				mask |= (1 << prio);
-		}
-		mask &= 0xff;
-
-		netif_dbg(pdata, drv, pdata->netdev, "TC%u PFC mask=%#x\n",
-			  tc, mask);
-		reg = MTL_TCPM0R + (MTL_TCPM_INC * (tc / MTL_TCPM_TC_PER_REG));
-		reg_val = XGMAC_IOREAD(pdata, reg);
-
-		reg_val &= ~(0xff << ((tc % MTL_TCPM_TC_PER_REG) << 3));
-		reg_val |= (mask << ((tc % MTL_TCPM_TC_PER_REG) << 3));
-
-		XGMAC_IOWRITE(pdata, reg, reg_val);
-	}
-
 	xgbe_config_flow_control(pdata);
 }
 
