From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/12] bnxt_en: Add basic WoL infrastructure.
Date: Tue,  4 Apr 2017 18:14:07 -0400
Message-ID: <1491344057-12663-3-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34240 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755144AbdDDWOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:14:39 -0400
Received: by mail-wm0-f43.google.com with SMTP id w204so7040278wmd.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:14:39 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add code to driver probe function to check if the device is WoL capable
and if Magic packet WoL filter is currently set.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 43 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  4 +++
 2 files changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 174ec8f..70cc313 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4532,6 +4532,9 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		pf->max_tx_wm_flows = le32_to_cpu(resp->max_tx_wm_flows);
 		pf->max_rx_em_flows = le32_to_cpu(resp->max_rx_em_flows);
 		pf->max_rx_wm_flows = le32_to_cpu(resp->max_rx_wm_flows);
+		if (resp->flags &
+		    cpu_to_le32(FUNC_QCAPS_RESP_FLAGS_WOL_MAGICPKT_SUPPORTED))
+			bp->flags |= BNXT_FLAG_WOL_CAP;
 	} else {
 #ifdef CONFIG_BNXT_SRIOV
 		struct bnxt_vf_info *vf = &bp->vf;
@@ -5839,6 +5842,44 @@ static int bnxt_hwrm_port_led_qcaps(struct bnxt *bp)
 	return 0;
 }
 
+static u16 bnxt_hwrm_get_wol_fltrs(struct bnxt *bp, u16 handle)
+{
+	struct hwrm_wol_filter_qcfg_input req = {0};
+	struct hwrm_wol_filter_qcfg_output *resp = bp->hwrm_cmd_resp_addr;
+	u16 next_handle = 0;
+	int rc;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_WOL_FILTER_QCFG, -1, -1);
+	req.port_id = cpu_to_le16(bp->pf.port_id);
+	req.handle = cpu_to_le16(handle);
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (!rc) {
+		next_handle = le16_to_cpu(resp->next_handle);
+		if (next_handle != 0) {
+			if (resp->wol_type ==
+			    WOL_FILTER_ALLOC_REQ_WOL_TYPE_MAGICPKT) {
+				bp->wol = 1;
+				bp->wol_filter_id = resp->wol_filter_id;
+			}
+		}
+	}
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return next_handle;
+}
+
+static void bnxt_get_wol_settings(struct bnxt *bp)
+{
+	u16 handle = 0;
+
+	if (!BNXT_PF(bp) || !(bp->flags & BNXT_FLAG_WOL_CAP))
+		return;
+
+	do {
+		handle = bnxt_hwrm_get_wol_fltrs(bp, handle);
+	} while (handle && handle != 0xffff);
+}
+
 static bool bnxt_eee_config_ok(struct bnxt *bp)
 {
 	struct ethtool_eee *eee = &bp->eee;
@@ -7575,6 +7616,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err_pci_clean;
 
+	bnxt_get_wol_settings(bp);
+
 	rc = register_netdev(dev);
 	if (rc)
 		goto init_err_clr_int;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 3cb0777..02de812 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -989,6 +989,7 @@ struct bnxt {
 	#define BNXT_FLAG_UDP_RSS_CAP	0x800
 	#define BNXT_FLAG_EEE_CAP	0x1000
 	#define BNXT_FLAG_NEW_RSS_CAP	0x2000
+	#define BNXT_FLAG_WOL_CAP	0x4000
 	#define BNXT_FLAG_ROCEV1_CAP	0x8000
 	#define BNXT_FLAG_ROCEV2_CAP	0x10000
 	#define BNXT_FLAG_ROCE_CAP	(BNXT_FLAG_ROCEV1_CAP |	\
@@ -1180,6 +1181,9 @@ struct bnxt {
 	u32			lpi_tmr_lo;
 	u32			lpi_tmr_hi;
 
+	u8			wol_filter_id;
+	u8			wol;
+
 	u8			num_leds;
 	struct bnxt_led_info	leds[BNXT_MAX_LED];
 
-- 
1.8.3.1
