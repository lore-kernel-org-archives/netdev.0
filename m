From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net 3/3] qed: Clear dcbx memory buffers before the usage.
Date: Mon, 29 Aug 2016 08:29:54 -0400
Message-ID: <1472473794-11933-4-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1472473794-11933-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
        <sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34344 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933015AbcH2NNo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:13:44 -0400
In-Reply-To: <1472473794-11933-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch takes care of clearing the uninitialized buffer before using it.
1. pfc pri-enable bitmap need to be cleared before setting the requested
   enable bits. Without this, the un-touched values will be merged with
   requested values and sent to MFW.
2. The data in app-entry field need to be cleared before using it.
3. Clear the output data buffer used in qed_dcbx_query_params().

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 192a886..ad023fe 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -988,6 +988,7 @@ qed_dcbx_set_pfc_data(struct qed_hwfn *p_hwfn,
 		if (p_params->pfc.prio[i])
 			pfc_map |= BIT(i);
 
+	*pfc &= ~DCBX_PFC_PRI_EN_BITMAP_MASK;
 	*pfc |= (pfc_map << DCBX_PFC_PRI_EN_BITMAP_SHIFT);
 
 	DP_VERBOSE(p_hwfn, QED_MSG_DCB, "pfc = 0x%x\n", *pfc);
@@ -1062,6 +1063,7 @@ qed_dcbx_set_app_data(struct qed_hwfn *p_hwfn,
 
 	for (i = 0; i < DCBX_MAX_APP_PROTOCOL; i++) {
 		entry = &p_app->app_pri_tbl[i].entry;
+		*entry = 0;
 		if (ieee) {
 			*entry &= ~(DCBX_APP_SF_IEEE_MASK | DCBX_APP_SF_MASK);
 			switch (p_params->app_entry[i].sf_ieee) {
@@ -1193,6 +1195,7 @@ int qed_dcbx_get_config_params(struct qed_hwfn *p_hwfn,
 		return -ENOMEM;
 	}
 
+	memset(dcbx_info, 0, sizeof(*dcbx_info));
 	rc = qed_dcbx_query_params(p_hwfn, dcbx_info, QED_DCBX_OPERATIONAL_MIB);
 	if (rc) {
 		kfree(dcbx_info);
@@ -1230,6 +1233,7 @@ static struct qed_dcbx_get *qed_dcbnl_get_dcbx(struct qed_hwfn *hwfn,
 		return NULL;
 	}
 
+	memset(dcbx_info, 0, sizeof(*dcbx_info));
 	if (qed_dcbx_query_params(hwfn, dcbx_info, type)) {
 		kfree(dcbx_info);
 		return NULL;
-- 
1.8.3.1
