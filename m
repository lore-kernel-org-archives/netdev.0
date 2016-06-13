From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/11] bnxt_en: Handle VF_CFG_CHANGE event from firmware.
Date: Mon, 13 Jun 2016 02:25:30 -0400
Message-ID: <1465799138-27529-4-git-send-email-michael.chan@broadcom.com>
References: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33899 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964810AbcFMGZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:25:55 -0400
Received: by mail-pf0-f181.google.com with SMTP id 62so42966758pfd.1
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:25:54 -0700 (PDT)
In-Reply-To: <1465799138-27529-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the VF driver gets this event, the VF configuration has changed (such
as default VLAN).  The VF driver will initiate a silent reset to pick up
the new configuration.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 +++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 1 +
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e30c43b..51f9e38 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -125,6 +125,7 @@ static const u16 bnxt_async_events_arr[] = {
 	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE,
 	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD,
 	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_CONN_NOT_ALLOWED,
+	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_CFG_CHANGE,
 	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_CHANGE,
 };
 
@@ -1358,6 +1359,11 @@ static int bnxt_async_event_process(struct bnxt *bp,
 		set_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event);
 		break;
 	}
+	case HWRM_ASYNC_EVENT_CMPL_EVENT_ID_VF_CFG_CHANGE:
+		if (BNXT_PF(bp))
+			goto async_event_process_exit;
+		set_bit(BNXT_RESET_TASK_SILENT_SP_EVENT, &bp->sp_event);
+		break;
 	default:
 		netdev_err(bp->dev, "unhandled ASYNC event (id 0x%x)\n",
 			   event_id);
@@ -5738,6 +5744,9 @@ static void bnxt_sp_task(struct work_struct *work)
 	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
 		bnxt_reset(bp, false);
 
+	if (test_and_clear_bit(BNXT_RESET_TASK_SILENT_SP_EVENT, &bp->sp_event))
+		bnxt_reset(bp, true);
+
 	if (test_and_clear_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event))
 		bnxt_get_port_module_status(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 2824d65..538eb1c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1018,6 +1018,7 @@ struct bnxt {
 #define BNXT_HWRM_PF_UNLOAD_SP_EVENT	8
 #define BNXT_PERIODIC_STATS_SP_EVENT	9
 #define BNXT_HWRM_PORT_MODULE_SP_EVENT	10
+#define BNXT_RESET_TASK_SILENT_SP_EVENT	11
 
 	struct bnxt_pf_info	pf;
 #ifdef CONFIG_BNXT_SRIOV
-- 
1.8.3.1
