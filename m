From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 5/5] qed: Add support for static dcbx.
Date: Thu, 20 Apr 2017 22:31:20 -0700
Message-ID: <20170421053120.12980-6-sudarsana.kalluru@cavium.com>
References: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0080.outbound.protection.outlook.com ([104.47.42.80]:8990
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1035352AbdDUFcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 01:32:09 -0400
In-Reply-To: <20170421053120.12980-1-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds driver support for static/local dcbx mode. In this mode
adapter brings up the dcbx link with locally configured parameters
instead of performing the dcbx negotiation with the peer. The feature
is useful when peer device/switch doesn't support dcbx.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 24 +++++++++++++++++++-----
 include/linux/qed/qed_if.h                 |  1 +
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index d79831d..8b4ea77 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -673,8 +673,14 @@ static int qed_dcbx_process_mib_info(struct qed_hwfn *p_hwfn)
 		 DCBX_CONFIG_VERSION_CEE);
 	p_operational->cee = val;
 
-	DP_VERBOSE(p_hwfn, QED_MSG_DCB, "Version support: ieee %d, cee %d\n",
-		   p_operational->ieee, p_operational->cee);
+	val = !!(QED_MFW_GET_FIELD(flags, DCBX_CONFIG_VERSION) ==
+		 DCBX_CONFIG_VERSION_STATIC);
+	p_operational->local = val;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_DCB,
+		   "Version support: ieee %d, cee %d, static %d\n",
+		   p_operational->ieee, p_operational->cee,
+		   p_operational->local);
 
 	qed_dcbx_get_common_params(p_hwfn, &p_feat->app,
 				   p_feat->app.app_pri_tbl, &p_feat->ets,
@@ -1226,6 +1232,8 @@ int qed_dcbx_get_config_params(struct qed_hwfn *p_hwfn,
 		p_hwfn->p_dcbx_info->set.ver_num |= DCBX_CONFIG_VERSION_CEE;
 	if (dcbx_info->operational.ieee)
 		p_hwfn->p_dcbx_info->set.ver_num |= DCBX_CONFIG_VERSION_IEEE;
+	if (dcbx_info->operational.local)
+		p_hwfn->p_dcbx_info->set.ver_num |= DCBX_CONFIG_VERSION_STATIC;
 
 	p_hwfn->p_dcbx_info->set.enabled = dcbx_info->operational.enabled;
 	memcpy(&p_hwfn->p_dcbx_info->set.config.params,
@@ -1775,8 +1783,9 @@ static u8 qed_dcbnl_setdcbx(struct qed_dev *cdev, u8 mode)
 
 	DP_VERBOSE(hwfn, QED_MSG_DCB, "new mode = %x\n", mode);
 
-	if (!(mode & DCB_CAP_DCBX_VER_IEEE) && !(mode & DCB_CAP_DCBX_VER_CEE)) {
-		DP_INFO(hwfn, "Allowed mode is cee, ieee or both\n");
+	if (!(mode & DCB_CAP_DCBX_VER_IEEE) &&
+	    !(mode & DCB_CAP_DCBX_VER_CEE) && !(mode & DCB_CAP_DCBX_STATIC)) {
+		DP_INFO(hwfn, "Allowed modes are cee, ieee or static\n");
 		return 1;
 	}
 
@@ -1796,6 +1805,11 @@ static u8 qed_dcbnl_setdcbx(struct qed_dev *cdev, u8 mode)
 		dcbx_set.enabled = true;
 	}
 
+	if (mode & DCB_CAP_DCBX_STATIC) {
+		dcbx_set.ver_num |= DCBX_CONFIG_VERSION_STATIC;
+		dcbx_set.enabled = true;
+	}
+
 	ptt = qed_ptt_acquire(hwfn);
 	if (!ptt)
 		return 1;
@@ -1804,7 +1818,7 @@ static u8 qed_dcbnl_setdcbx(struct qed_dev *cdev, u8 mode)
 
 	qed_ptt_release(hwfn, ptt);
 
-	return 0;
+	return rc;
 }
 
 static u8 qed_dcbnl_getfeatcfg(struct qed_dev *cdev, int featid, u8 *flags)
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index d44933a..9f966be895 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -144,6 +144,7 @@ struct qed_dcbx_operational_params {
 	bool enabled;
 	bool ieee;
 	bool cee;
+	bool local;
 	u32 err;
 };
 
-- 
1.8.3.1
