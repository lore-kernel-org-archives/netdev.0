From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 02/10] qed: Correct DCBx update scheme
Date: Sun, 28 May 2017 18:01:52 +0300
Message-ID: <1495983720-10853-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0058.outbound.protection.outlook.com ([104.47.41.58]:14463
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750838AbdE1PD2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 11:03:28 -0400
In-Reply-To: <1495983720-10853-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

Instead of using a boolean value that propagates to FW configuration,
use the proper firmware HSI values.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c | 15 ++++++++-------
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h |  2 +-
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index efe309e..af34638 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -191,17 +191,19 @@ static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 qed_dcbx_set_params(struct qed_dcbx_results *p_data,
 		    struct qed_hw_info *p_info,
 		    bool enable,
-		    bool update,
 		    u8 prio,
 		    u8 tc,
 		    enum dcbx_protocol_type type,
 		    enum qed_pci_personality personality)
 {
 	/* PF update ramrod data */
-	p_data->arr[type].update = update;
 	p_data->arr[type].enable = enable;
 	p_data->arr[type].priority = prio;
 	p_data->arr[type].tc = tc;
+	if (enable)
+		p_data->arr[type].update = UPDATE_DCB;
+	else
+		p_data->arr[type].update = DONT_UPDATE_DCB_DSCP;
 
 	/* QM reconf data */
 	if (p_info->personality == personality)
@@ -213,7 +215,6 @@ static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 qed_dcbx_update_app_info(struct qed_dcbx_results *p_data,
 			 struct qed_hwfn *p_hwfn,
 			 bool enable,
-			 bool update,
 			 u8 prio, u8 tc, enum dcbx_protocol_type type)
 {
 	struct qed_hw_info *p_info = &p_hwfn->hw_info;
@@ -231,7 +232,7 @@ static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 		personality = qed_dcbx_app_update[i].personality;
 		name = qed_dcbx_app_update[i].name;
 
-		qed_dcbx_set_params(p_data, p_info, enable, update,
+		qed_dcbx_set_params(p_data, p_info, enable,
 				    prio, tc, type, personality);
 	}
 }
@@ -304,7 +305,7 @@ static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 			 */
 			enable = !(type == DCBX_PROTOCOL_ETH);
 
-			qed_dcbx_update_app_info(p_data, p_hwfn, enable, true,
+			qed_dcbx_update_app_info(p_data, p_hwfn, enable,
 						 priority, tc, type);
 		}
 	}
@@ -332,8 +333,8 @@ static bool qed_dcbx_roce_v2_tlv(u32 app_info_bitmap, u16 proto_id, bool ieee)
 		if (p_data->arr[type].update)
 			continue;
 
-		enable = !(type == DCBX_PROTOCOL_ETH);
-		qed_dcbx_update_app_info(p_data, p_hwfn, enable, true,
+		enable = (type == DCBX_PROTOCOL_ETH) ? false : !!dcbx_version;
+		qed_dcbx_update_app_info(p_data, p_hwfn, enable,
 					 priority, tc, type);
 	}
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.h b/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
index 414e262..5feb90e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.h
@@ -52,7 +52,7 @@ enum qed_mib_read_type {
 
 struct qed_dcbx_app_data {
 	bool enable;		/* DCB enabled */
-	bool update;		/* Update indication */
+	u8 update;		/* Update indication */
 	u8 priority;		/* Priority */
 	u8 tc;			/* Traffic Class */
 };
-- 
1.9.3
