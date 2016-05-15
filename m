From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 7/9] bnxt_en: Simplify and improve unsupported SFP+ module reporting.
Date: Sat, 14 May 2016 20:29:46 -0400
Message-ID: <1463272188-30025-8-git-send-email-michael.chan@broadcom.com>
References: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35763 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbcEOAaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 20:30:05 -0400
Received: by mail-pf0-f171.google.com with SMTP id 77so54527474pfv.2
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 17:30:05 -0700 (PDT)
In-Reply-To: <1463272188-30025-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code is more complicated than necessary and can only report
unsupported SFP+ module if it is plugged in after the device is up.

Rename bnxt_port_module_event() to bnxt_get_port_module_status().  We
already have the current module_status in the link_info structure, so
just check that and report any unsupported SFP+ module status.  Delete
the unnecessary last_port_module_event.  Call this function at the
end of bnxt_open to report unsupported module already plugged in.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 66 ++++++++++++++-----------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 -
 2 files changed, 30 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 0a83fd8..6def145 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1263,15 +1263,6 @@ next_rx_no_prod:
 	((data) &				\
 	 HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_PORT_ID_MASK)
 
-#define BNXT_EVENT_POLICY_MASK	\
-	HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_MASK
-
-#define BNXT_EVENT_POLICY_SFT	\
-	HWRM_ASYNC_EVENT_CMPL_PORT_CONN_NOT_ALLOWED_EVENT_DATA1_ENFORCEMENT_POLICY_SFT
-
-#define BNXT_GET_EVENT_POLICY(data)	\
-	(((data) & BNXT_EVENT_POLICY_MASK) >> BNXT_EVENT_POLICY_SFT)
-
 static int bnxt_async_event_process(struct bnxt *bp,
 				    struct hwrm_async_event_cmpl *cmpl)
 {
@@ -1310,9 +1301,6 @@ static int bnxt_async_event_process(struct bnxt *bp,
 		if (bp->pf.port_id != port_id)
 			break;
 
-		bp->link_info.last_port_module_event =
-			BNXT_GET_EVENT_POLICY(data1);
-
 		set_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event);
 		break;
 	}
@@ -4725,6 +4713,33 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	return 0;
 }
 
+static void bnxt_get_port_module_status(struct bnxt *bp)
+{
+	struct bnxt_link_info *link_info = &bp->link_info;
+	struct hwrm_port_phy_qcfg_output *resp = &link_info->phy_qcfg_resp;
+	u8 module_status;
+
+	if (bnxt_update_link(bp, true))
+		return;
+
+	module_status = link_info->module_status;
+	switch (module_status) {
+	case PORT_PHY_QCFG_RESP_MODULE_STATUS_DISABLETX:
+	case PORT_PHY_QCFG_RESP_MODULE_STATUS_PWRDOWN:
+	case PORT_PHY_QCFG_RESP_MODULE_STATUS_WARNINGMSG:
+		netdev_warn(bp->dev, "Unqualified SFP+ module detected on port %d\n",
+			    bp->pf.port_id);
+		if (bp->hwrm_spec_code >= 0x10201) {
+			netdev_warn(bp->dev, "Module part number %s\n",
+				    resp->phy_vendor_partnumber);
+		}
+		if (module_status == PORT_PHY_QCFG_RESP_MODULE_STATUS_DISABLETX)
+			netdev_warn(bp->dev, "TX is disabled\n");
+		if (module_status == PORT_PHY_QCFG_RESP_MODULE_STATUS_PWRDOWN)
+			netdev_warn(bp->dev, "SFP+ module is shutdown\n");
+	}
+}
+
 static void
 bnxt_hwrm_set_pause_common(struct bnxt *bp, struct hwrm_port_phy_cfg_input *req)
 {
@@ -5017,7 +5032,8 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	/* Enable TX queues */
 	bnxt_tx_enable(bp);
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
-	bnxt_update_link(bp, true);
+	/* Poll link status and check for SFP+ module status */
+	bnxt_get_port_module_status(bp);
 
 	return 0;
 
@@ -5552,28 +5568,6 @@ bnxt_restart_timer:
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 }
 
-static void bnxt_port_module_event(struct bnxt *bp)
-{
-	struct bnxt_link_info *link_info = &bp->link_info;
-	struct hwrm_port_phy_qcfg_output *resp = &link_info->phy_qcfg_resp;
-
-	if (bnxt_update_link(bp, true))
-		return;
-
-	if (link_info->last_port_module_event != 0) {
-		netdev_warn(bp->dev, "Unqualified SFP+ module detected on port %d\n",
-			    bp->pf.port_id);
-		if (bp->hwrm_spec_code >= 0x10201) {
-			netdev_warn(bp->dev, "Module part number %s\n",
-				    resp->phy_vendor_partnumber);
-		}
-	}
-	if (link_info->last_port_module_event == 1)
-		netdev_warn(bp->dev, "TX is disabled\n");
-	if (link_info->last_port_module_event == 3)
-		netdev_warn(bp->dev, "Shutdown SFP+ module\n");
-}
-
 static void bnxt_cfg_ntp_filters(struct bnxt *);
 
 static void bnxt_sp_task(struct work_struct *work)
@@ -5622,7 +5616,7 @@ static void bnxt_sp_task(struct work_struct *work)
 	}
 
 	if (test_and_clear_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event))
-		bnxt_port_module_event(bp);
+		bnxt_get_port_module_status(bp);
 
 	if (test_and_clear_bit(BNXT_PERIODIC_STATS_SP_EVENT, &bp->sp_event))
 		bnxt_hwrm_port_qstats(bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 408bb00..9933e35 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -848,7 +848,6 @@ struct bnxt_link_info {
 	u32			advertising;
 	bool			force_link_chng;
 
-	u8			last_port_module_event;
 	/* a copy of phy_qcfg output used to report link
 	 * info to VF
 	 */
-- 
1.8.3.1
