From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 07/10] bnxt_en: Add unsupported SFP+ module warnings.
Date: Tue,  5 Apr 2016 04:22:39 -0400
Message-ID: <1459844562-24576-8-git-send-email-michael.chan@broadcom.com>
References: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:3738 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757456AbcDEIWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:22:47 -0400
In-Reply-To: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the PORT_CONN_NOT_ALLOWED async event handling logic.  The driver
will print an appropriate warning to reflect the SFP+ module enforcement
policy done in the firmware.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 55 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  3 ++
 2 files changed, 58 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index dd0b32c..597e472 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -121,6 +121,7 @@ static const u16 bnxt_vf_req_snif[] = {
 static const u16 bnxt_async_events_arr[] = {
 	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE,
 	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD,
+	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_CONN_NOT_ALLOWED,
 };
 
 static bool bnxt_vf_pciid(enum board_idx idx)
@@ -1236,6 +1237,19 @@ next_rx_no_prod:
 	return rc;
 }
 
+#define BNXT_GET_EVENT_PORT(data)	\
+	((data) &				\
+	 HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_PORT_ID_MASK)
+
+#define BNXT_EVENT_POLICY_MASK	\
+	HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_MASK
+
+#define BNXT_EVENT_POLICY_SFT	\
+	HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_SFT
+
+#define BNXT_GET_EVENT_POLICY(data)	\
+	(((data) & BNXT_EVENT_POLICY_MASK) >> BNXT_EVENT_POLICY_SFT)
+
 static int bnxt_async_event_process(struct bnxt *bp,
 				    struct hwrm_async_event_cmpl *cmpl)
 {
@@ -1249,6 +1263,22 @@ static int bnxt_async_event_process(struct bnxt *bp,
 	case HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD:
 		set_bit(BNXT_HWRM_PF_UNLOAD_SP_EVENT, &bp->sp_event);
 		break;
+	case HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_CONN_NOT_ALLOWED: {
+		u32 data1 = le32_to_cpu(cmpl->event_data1);
+		u16 port_id = BNXT_GET_EVENT_PORT(data1);
+
+		if (BNXT_VF(bp))
+			break;
+
+		if (bp->pf.port_id != port_id)
+			break;
+
+		bp->link_info.last_port_module_event =
+			BNXT_GET_EVENT_POLICY(data1);
+
+		set_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event);
+		break;
+	}
 	default:
 		netdev_err(bp->dev, "unhandled ASYNC event (id 0x%x)\n",
 			   event_id);
@@ -5447,6 +5477,28 @@ bnxt_restart_timer:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 }
 
+static void bnxt_port_module_event(struct bnxt *bp)
+{
+	struct bnxt_link_info *link_info = &bp->link_info;
+	struct hwrm_port_phy_qcfg_output *resp = &link_info->phy_qcfg_resp;
+
+	if (bnxt_update_link(bp, true))
+		return;
+
+	if (link_info->last_port_module_event != 0) {
+		netdev_warn(bp->dev, "Unqualified SFP+ module detected on port %d\n",
+			    bp->pf.port_id);
+		if (bp->hwrm_spec_code >= 0x10201) {
+			netdev_warn(bp->dev, "Module part number %s\n",
+				    resp->phy_vendor_partnumber);
+		}
+	}
+	if (link_info->last_port_module_event == 1)
+		netdev_warn(bp->dev, "TX is disabled\n");
+	if (link_info->last_port_module_event == 3)
+		netdev_warn(bp->dev, "Shutdown SFP+ module\n");
+}
+
 static void bnxt_cfg_ntp_filters(struct bnxt *);
 
 static void bnxt_sp_task(struct work_struct *work)
@@ -5494,6 +5546,9 @@ static void bnxt_sp_task(struct work_struct *work)
 		rtnl_unlock();
 	}
 
+	if (test_and_clear_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event))
+		bnxt_port_module_event(bp);
+
 	if (test_and_clear_bit(BNXT_PERIODIC_STATS_SP_EVENT, &bp->sp_event))
 		bnxt_hwrm_port_qstats(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index a981e2c..cc8e38a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -825,6 +825,8 @@ struct bnxt_link_info {
 	u16			req_link_speed;
 	u32			advertising;
 	bool			force_link_chng;
+
+	u8			last_port_module_event;
 	/* a copy of phy_qcfg output used to report link
 	 * info to VF
 	 */
@@ -992,6 +994,7 @@ struct bnxt {
 #define BNXT_RST_RING_SP_EVENT		7
 #define BNXT_HWRM_PF_UNLOAD_SP_EVENT	8
 #define BNXT_PERIODIC_STATS_SP_EVENT	9
+#define BNXT_HWRM_PORT_MODULE_SP_EVENT	10
 
 	struct bnxt_pf_info	pf;
 #ifdef CONFIG_BNXT_SRIOV
-- 
1.8.3.1
