From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 7/9] amd-xgbe: Do traffic class setup when
 called through dcbnl
Date: Fri, 12 Feb 2016 08:33:24 -0600
Message-ID: <20160212143324.23973.64877.stgit@tlendack-t1.amdoffice.net>
References: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0077.outbound.protection.outlook.com ([207.46.100.77]:16320
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750959AbcBLOsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:48:46 -0500
In-Reply-To: <20160212143215.23973.1043.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the netdev traffic class setup is only performed when invoked
through the ndo_setup_tc interface. However, the same setup should be
performed when the dcbnl interface (ieee_setets) is invoked. Rework the
netdev traffic class setup to be invokable through either interface and
also provide the priority to traffic class mapping if available.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dcb.c |   39 ++++++++++++++++++++++--------
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   33 +++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   21 ++--------------
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    6 +++--
 4 files changed, 69 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c b/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
index a6b9899..895d356 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
@@ -6,7 +6,7 @@
  *
  * License 1: GPLv2
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  *
  * This file is free software; you may copy, redistribute and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -56,7 +56,7 @@
  *
  * License 2: Modified BSD
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -146,6 +146,7 @@ static int xgbe_dcb_ieee_setets(struct net_device *netdev,
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 	unsigned int i, tc_ets, tc_ets_weight;
+	u8 max_tc = 0;
 
 	tc_ets = 0;
 	tc_ets_weight = 0;
@@ -157,12 +158,9 @@ static int xgbe_dcb_ieee_setets(struct net_device *netdev,
 		netif_dbg(pdata, drv, netdev, "PRIO%u: TC=%hhu\n", i,
 			  ets->prio_tc[i]);
 
-		if ((ets->tc_tx_bw[i] || ets->tc_tsa[i]) &&
-		    (i >= pdata->hw_feat.tc_cnt))
-				return -EINVAL;
-
-		if (ets->prio_tc[i] >= pdata->hw_feat.tc_cnt)
-			return -EINVAL;
+		max_tc = max_t(u8, max_tc, ets->prio_tc[i]);
+		if ((ets->tc_tx_bw[i] || ets->tc_tsa[i]))
+			max_tc = max_t(u8, max_tc, i);
 
 		switch (ets->tc_tsa[i]) {
 		case IEEE_8021QAZ_TSA_STRICT:
@@ -171,15 +169,28 @@ static int xgbe_dcb_ieee_setets(struct net_device *netdev,
 			tc_ets = 1;
 			tc_ets_weight += ets->tc_tx_bw[i];
 			break;
-
 		default:
+			netif_err(pdata, drv, netdev,
+				  "unsupported TSA algorithm (%hhu)\n",
+				  ets->tc_tsa[i]);
 			return -EINVAL;
 		}
 	}
 
+	/* Check maximum traffic class requested */
+	if (max_tc >= pdata->hw_feat.tc_cnt) {
+		netif_err(pdata, drv, netdev,
+			  "exceeded number of supported traffic classes\n");
+		return -EINVAL;
+	}
+
 	/* Weights must add up to 100% */
-	if (tc_ets && (tc_ets_weight != 100))
+	if (tc_ets && (tc_ets_weight != 100)) {
+		netif_err(pdata, drv, netdev,
+			  "sum of ETS algorithm weights is not 100 (%u)\n",
+			  tc_ets_weight);
 		return -EINVAL;
+	}
 
 	if (!pdata->ets) {
 		pdata->ets = devm_kzalloc(pdata->dev, sizeof(*pdata->ets),
@@ -188,6 +199,7 @@ static int xgbe_dcb_ieee_setets(struct net_device *netdev,
 			return -ENOMEM;
 	}
 
+	pdata->num_tcs = max_tc + 1;
 	memcpy(pdata->ets, ets, sizeof(*pdata->ets));
 
 	pdata->hw_if.config_dcb_tc(pdata);
@@ -221,6 +233,13 @@ static int xgbe_dcb_ieee_setpfc(struct net_device *netdev,
 		  "cap=%hhu, en=%#hhx, mbc=%hhu, delay=%hhu\n",
 		  pfc->pfc_cap, pfc->pfc_en, pfc->mbc, pfc->delay);
 
+	/* Check PFC for supported number of traffic classes */
+	if (pfc->pfc_en & ~((1 << pdata->hw_feat.tc_cnt) - 1)) {
+		netif_err(pdata, drv, netdev,
+			  "PFC requested for unsupported traffic class\n");
+		return -EINVAL;
+	}
+
 	if (!pdata->pfc) {
 		pdata->pfc = devm_kzalloc(pdata->dev, sizeof(*pdata->pfc),
 					  GFP_KERNEL);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 93661bc..92bc031 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1328,6 +1328,36 @@ static int xgbe_config_tstamp(struct xgbe_prv_data *pdata,
 	return 0;
 }
 
+static void xgbe_config_tc(struct xgbe_prv_data *pdata)
+{
+	unsigned int offset, queue, prio;
+	u8 i;
+
+	netdev_reset_tc(pdata->netdev);
+	if (!pdata->num_tcs)
+		return;
+
+	netdev_set_num_tc(pdata->netdev, pdata->num_tcs);
+
+	for (i = 0, queue = 0, offset = 0; i < pdata->num_tcs; i++) {
+		while ((queue < pdata->tx_q_count) &&
+		       (pdata->q2tc_map[queue] == i))
+			queue++;
+
+		netif_dbg(pdata, drv, pdata->netdev, "TC%u using TXq%u-%u\n",
+			  i, offset, queue - 1);
+		netdev_set_tc_queue(pdata->netdev, i, queue - offset, offset);
+		offset = queue;
+	}
+
+	if (!pdata->ets)
+		return;
+
+	for (prio = 0; prio < IEEE_8021QAZ_MAX_TCS; prio++)
+		netdev_set_prio_tc_map(pdata->netdev, prio,
+				       pdata->ets->prio_tc[prio]);
+}
+
 static void xgbe_config_dcb_tc(struct xgbe_prv_data *pdata)
 {
 	struct ieee_ets *ets = pdata->ets;
@@ -1389,6 +1419,8 @@ static void xgbe_config_dcb_tc(struct xgbe_prv_data *pdata)
 			break;
 		}
 	}
+
+	xgbe_config_tc(pdata);
 }
 
 static void xgbe_config_dcb_pfc(struct xgbe_prv_data *pdata)
@@ -2913,6 +2945,7 @@ void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *hw_if)
 	hw_if->get_tx_tstamp = xgbe_get_tx_tstamp;
 
 	/* For Data Center Bridging config */
+	hw_if->config_tc = xgbe_config_tc;
 	hw_if->config_dcb_tc = xgbe_config_dcb_tc;
 	hw_if->config_dcb_pfc = xgbe_config_dcb_pfc;
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index b0ff700..fb0a5f0 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1629,27 +1629,12 @@ static void xgbe_poll_controller(struct net_device *netdev)
 static int xgbe_setup_tc(struct net_device *netdev, u8 tc)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
-	unsigned int offset, queue;
-	u8 i;
 
-	if (tc && (tc != pdata->hw_feat.tc_cnt))
+	if (tc > pdata->hw_feat.tc_cnt)
 		return -EINVAL;
 
-	if (tc) {
-		netdev_set_num_tc(netdev, tc);
-		for (i = 0, queue = 0, offset = 0; i < tc; i++) {
-			while ((queue < pdata->tx_q_count) &&
-			       (pdata->q2tc_map[queue] == i))
-				queue++;
-
-			netif_dbg(pdata, drv, netdev, "TC%u using TXq%u-%u\n",
-				  i, offset, queue - 1);
-			netdev_set_tc_queue(netdev, i, queue - offset, offset);
-			offset = queue;
-		}
-	} else {
-		netdev_reset_tc(netdev);
-	}
+	pdata->num_tcs = tc;
+	pdata->hw_if.config_tc(pdata);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index e234b99..ca28354 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -6,7 +6,7 @@
  *
  * License 1: GPLv2
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  *
  * This file is free software; you may copy, redistribute and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -56,7 +56,7 @@
  *
  * License 2: Modified BSD
  *
- * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * Copyright (c) 2014-2016 Advanced Micro Devices, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -673,6 +673,7 @@ struct xgbe_hw_if {
 	u64 (*get_tx_tstamp)(struct xgbe_prv_data *);
 
 	/* For Data Center Bridging config */
+	void (*config_tc)(struct xgbe_prv_data *);
 	void (*config_dcb_tc)(struct xgbe_prv_data *);
 	void (*config_dcb_pfc)(struct xgbe_prv_data *);
 
@@ -880,6 +881,7 @@ struct xgbe_prv_data {
 	struct ieee_pfc *pfc;
 	unsigned int q2tc_map[XGBE_MAX_QUEUES];
 	unsigned int prio2q_map[IEEE_8021QAZ_MAX_TCS];
+	u8 num_tcs;
 
 	/* Hardware features of the device */
 	struct xgbe_hw_features hw_feat;
