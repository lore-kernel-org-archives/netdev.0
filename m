From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/4] bnxt_en: Enhance autoneg support.
Date: Wed, 16 Nov 2016 21:13:08 -0500
Message-ID: <1479348790-6218-3-git-send-email-michael.chan@broadcom.com>
References: <1479348790-6218-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35938 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933368AbcKQCNa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 21:13:30 -0500
Received: by mail-pg0-f52.google.com with SMTP id f188so85427756pgc.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 18:13:29 -0800 (PST)
In-Reply-To: <1479348790-6218-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some dual port NICs, the speed setting on one port can affect the
available speed on the other port.  Add logic to detect these changes
and adjust the advertised speed settings when necessary.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 23 +++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 1332577..4db50e8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1499,6 +1499,7 @@ static int bnxt_async_event_process(struct bnxt *bp,
 			netdev_warn(bp->dev, "Link speed %d no longer supported\n",
 				    speed);
 		}
+		set_bit(BNXT_LINK_SPEED_CHNG_SP_EVENT, &bp->sp_event);
 		/* fall thru */
 	}
 	case HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE:
@@ -5095,6 +5096,7 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	struct hwrm_port_phy_qcfg_input req = {0};
 	struct hwrm_port_phy_qcfg_output *resp = bp->hwrm_cmd_resp_addr;
 	u8 link_up = link_info->link_up;
+	u16 diff;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_PHY_QCFG, -1, -1);
 
@@ -5182,6 +5184,23 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 		link_info->link_up = 0;
 	}
 	mutex_unlock(&bp->hwrm_cmd_lock);
+
+	diff = link_info->support_auto_speeds ^ link_info->advertising;
+	if ((link_info->support_auto_speeds | diff) !=
+	    link_info->support_auto_speeds) {
+		/* An advertised speed is no longer supported, so we need to
+		 * update the advertisement settings.  See bnxt_reset() for
+		 * comments about the rtnl_lock() sequence below.
+		 */
+		clear_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
+		rtnl_lock();
+		link_info->advertising = link_info->support_auto_speeds;
+		if (test_bit(BNXT_STATE_OPEN, &bp->state) &&
+		    (link_info->autoneg & BNXT_AUTONEG_SPEED))
+			bnxt_hwrm_set_link_setting(bp, true, false);
+		set_bit(BNXT_STATE_IN_SP_TASK, &bp->state);
+		rtnl_unlock();
+	}
 	return 0;
 }
 
@@ -6108,6 +6127,10 @@ static void bnxt_sp_task(struct work_struct *work)
 	if (test_and_clear_bit(BNXT_RX_NTP_FLTR_SP_EVENT, &bp->sp_event))
 		bnxt_cfg_ntp_filters(bp);
 	if (test_and_clear_bit(BNXT_LINK_CHNG_SP_EVENT, &bp->sp_event)) {
+		if (test_and_clear_bit(BNXT_LINK_SPEED_CHNG_SP_EVENT,
+				       &bp->sp_event))
+			bnxt_hwrm_phy_qcaps(bp);
+
 		rc = bnxt_update_link(bp, true);
 		if (rc)
 			netdev_err(bp->dev, "SP task can't update link (rc: %x)\n",
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 51b164a..666bc06 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1089,6 +1089,7 @@ struct bnxt {
 #define BNXT_RESET_TASK_SILENT_SP_EVENT	11
 #define BNXT_GENEVE_ADD_PORT_SP_EVENT	12
 #define BNXT_GENEVE_DEL_PORT_SP_EVENT	13
+#define BNXT_LINK_SPEED_CHNG_SP_EVENT	14
 
 	struct bnxt_pf_info	pf;
 #ifdef CONFIG_BNXT_SRIOV
-- 
1.8.3.1
