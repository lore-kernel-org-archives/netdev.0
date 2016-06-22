From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 1/5] be2net: fix definition of be_max_eqs()
Date: Wed, 22 Jun 2016 08:54:53 -0400
Message-ID: <1466600097-1641-2-git-send-email-sathya.perla@broadcom.com>
References: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:62538 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751925AbcFVMzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 08:55:18 -0400
In-Reply-To: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EQs available on a function are shared between NIC and RoCE.
The be_max_eqs() macro was so far being used to refer to the max number of
EQs available for NIC. This has caused some confusion in the code. To fix
this confusion this patch introduces a new macro called be_max_nic_eqs()
to refer to the max number of EQs avialable for NIC only and renames
be_max_eqs() to be_max_func_eqs().

Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  8 ++++++--
 drivers/net/ethernet/emulex/benet/be_main.c | 29 +++++++++++++----------------
 2 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index e1e6c40..f8040ef 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -443,6 +443,7 @@ struct be_resources {
 	u16 max_iface_count;
 	u16 max_mcc_count;
 	u16 max_evt_qs;
+	u16 max_nic_evt_qs;	/* NIC's share of evt qs */
 	u32 if_cap_flags;
 	u32 vf_if_cap_flags;	/* VF if capability flags */
 	u32 flags;
@@ -644,7 +645,10 @@ struct be_adapter {
 #define be_max_txqs(adapter)		(adapter->res.max_tx_qs)
 #define be_max_prio_txqs(adapter)	(adapter->res.max_prio_tx_qs)
 #define be_max_rxqs(adapter)		(adapter->res.max_rx_qs)
-#define be_max_eqs(adapter)		(adapter->res.max_evt_qs)
+/* Max number of EQs available for the function (NIC + RoCE (if enabled)) */
+#define be_max_func_eqs(adapter)	(adapter->res.max_evt_qs)
+/* Max number of EQs available avaialble only for NIC */
+#define be_max_nic_eqs(adapter)		(adapter->res.max_nic_evt_qs)
 #define be_if_cap_flags(adapter)	(adapter->res.if_cap_flags)
 #define be_max_pf_pool_rss_tables(adapter)	\
 				(adapter->pool_res.max_rss_tables)
@@ -654,7 +658,7 @@ static inline u16 be_max_qs(struct be_adapter *adapter)
 	/* If no RSS, need atleast the one def RXQ */
 	u16 num = max_t(u16, be_max_rss(adapter), 1);
 
-	num = min(num, be_max_eqs(adapter));
+	num = min(num, be_max_nic_eqs(adapter));
 	return min_t(u16, num, num_online_cpus());
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3d94789..c67830f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3252,12 +3252,12 @@ static int be_msix_enable(struct be_adapter *adapter)
 	int i, num_vec;
 	struct device *dev = &adapter->pdev->dev;
 
-	/* If RoCE is supported, program the max number of NIC vectors that
-	 * may be configured via set-channels, along with vectors needed for
-	 * RoCe. Else, just program the number we'll use initially.
+	/* If RoCE is supported, program the max number of vectors that
+	 * could be used for NIC and RoCE, else, just program the number
+	 * we'll use initially.
 	 */
 	if (be_roce_supported(adapter))
-		num_vec = min_t(int, 2 * be_max_eqs(adapter),
+		num_vec = min_t(int, be_max_func_eqs(adapter),
 				2 * num_online_cpus());
 	else
 		num_vec = adapter->cfg_num_qs;
@@ -4219,16 +4219,13 @@ static int be_get_resources(struct be_adapter *adapter)
 	struct be_resources res = {0};
 	int status;
 
-	if (BEx_chip(adapter)) {
-		BEx_get_resources(adapter, &res);
-		adapter->res = res;
-	}
-
 	/* For Lancer, SH etc read per-function resource limits from FW.
 	 * GET_FUNC_CONFIG returns per function guaranteed limits.
 	 * GET_PROFILE_CONFIG returns PCI-E related limits PF-pool limits
 	 */
-	if (!BEx_chip(adapter)) {
+	if (BEx_chip(adapter)) {
+		BEx_get_resources(adapter, &res);
+	} else {
 		status = be_cmd_get_func_config(adapter, &res);
 		if (status)
 			return status;
@@ -4237,13 +4234,13 @@ static int be_get_resources(struct be_adapter *adapter)
 		if (res.max_rss_qs && res.max_rss_qs == res.max_rx_qs &&
 		    !(res.if_cap_flags & BE_IF_FLAGS_DEFQ_RSS))
 			res.max_rss_qs -= 1;
-
-		/* If RoCE may be enabled stash away half the EQs for RoCE */
-		if (be_roce_supported(adapter))
-			res.max_evt_qs /= 2;
-		adapter->res = res;
 	}
 
+	/* If RoCE is supported stash away half the EQs for RoCE */
+	res.max_nic_evt_qs = be_roce_supported(adapter) ?
+				res.max_evt_qs / 2 : res.max_evt_qs;
+	adapter->res = res;
+
 	/* If FW supports RSS default queue, then skip creating non-RSS
 	 * queue for non-IP traffic.
 	 */
@@ -4252,7 +4249,7 @@ static int be_get_resources(struct be_adapter *adapter)
 
 	dev_info(dev, "Max: txqs %d, rxqs %d, rss %d, eqs %d, vfs %d\n",
 		 be_max_txqs(adapter), be_max_rxqs(adapter),
-		 be_max_rss(adapter), be_max_eqs(adapter),
+		 be_max_rss(adapter), be_max_nic_eqs(adapter),
 		 be_max_vfs(adapter));
 	dev_info(dev, "Max: uc-macs %d, mc-macs %d, vlans %d\n",
 		 be_max_uc(adapter), be_max_mc(adapter),
-- 
2.4.1
