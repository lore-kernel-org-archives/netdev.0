From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 6/7] bnxt_en: Refactor the driver registration function with firmware.
Date: Wed,  7 Dec 2016 00:26:20 -0500
Message-ID: <1481088381-30411-7-git-send-email-michael.chan@broadcom.com>
References: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, selvin.xavier@broadcom.com,
        somnath.kotur@broadcom.com, dledford@redhat.com,
        linux-rdma@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35728 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752537AbcLGF1A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 00:27:00 -0500
Received: by mail-pf0-f178.google.com with SMTP id i88so74646610pfk.2
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 21:27:00 -0800 (PST)
In-Reply-To: <1481088381-30411-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver register function with firmware consists of passing version
information and registering for async events.  To support the RDMA driver,
the async events that we need to register may change.  Separate the
driver register function into 2 parts so that we can just update the
async events for the RDMA driver.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 34 ++++++++++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  2 ++
 2 files changed, 31 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 57285bd..c782942 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3117,27 +3117,46 @@ int hwrm_send_message_silent(struct bnxt *bp, void *msg, u32 msg_len,
 	return rc;
 }
 
-static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
+int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
+				     int bmap_size)
 {
 	struct hwrm_func_drv_rgtr_input req = {0};
-	int i;
 	DECLARE_BITMAP(async_events_bmap, 256);
 	u32 *events = (u32 *)async_events_bmap;
+	int i;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_DRV_RGTR, -1, -1);
 
 	req.enables =
-		cpu_to_le32(FUNC_DRV_RGTR_REQ_ENABLES_OS_TYPE |
-			    FUNC_DRV_RGTR_REQ_ENABLES_VER |
-			    FUNC_DRV_RGTR_REQ_ENABLES_ASYNC_EVENT_FWD);
+		cpu_to_le32(FUNC_DRV_RGTR_REQ_ENABLES_ASYNC_EVENT_FWD);
 
 	memset(async_events_bmap, 0, sizeof(async_events_bmap));
 	for (i = 0; i < ARRAY_SIZE(bnxt_async_events_arr); i++)
 		__set_bit(bnxt_async_events_arr[i], async_events_bmap);
 
+	if (bmap && bmap_size) {
+		for (i = 0; i < bmap_size; i++) {
+			if (test_bit(i, bmap))
+				__set_bit(i, async_events_bmap);
+		}
+	}
+
 	for (i = 0; i < 8; i++)
 		req.async_event_fwd[i] |= cpu_to_le32(events[i]);
 
+	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+}
+
+static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
+{
+	struct hwrm_func_drv_rgtr_input req = {0};
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_DRV_RGTR, -1, -1);
+
+	req.enables =
+		cpu_to_le32(FUNC_DRV_RGTR_REQ_ENABLES_OS_TYPE |
+			    FUNC_DRV_RGTR_REQ_ENABLES_VER);
+
 	req.os_type = cpu_to_le16(FUNC_DRV_RGTR_REQ_OS_TYPE_LINUX);
 	req.ver_maj = DRV_VER_MAJ;
 	req.ver_min = DRV_VER_MIN;
@@ -3146,6 +3165,7 @@ static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
 	if (BNXT_PF(bp)) {
 		DECLARE_BITMAP(vf_req_snif_bmap, 256);
 		u32 *data = (u32 *)vf_req_snif_bmap;
+		int i;
 
 		memset(vf_req_snif_bmap, 0, sizeof(vf_req_snif_bmap));
 		for (i = 0; i < ARRAY_SIZE(bnxt_vf_req_snif); i++)
@@ -7023,6 +7043,10 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto init_err;
 
+	rc = bnxt_hwrm_func_rgtr_async_events(bp, NULL, 0);
+	if (rc)
+		goto init_err;
+
 	/* Get the MAX capabilities for this function */
 	rc = bnxt_hwrm_func_qcaps(bp);
 	if (rc) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index d796836..eec2415 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1240,6 +1240,8 @@ static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
 int _hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message_silent(struct bnxt *, void *, u32, int);
+int bnxt_hwrm_func_rgtr_async_events(struct bnxt *bp, unsigned long *bmap,
+				     int bmap_size);
 int bnxt_hwrm_set_coal(struct bnxt *);
 unsigned int bnxt_get_max_func_stat_ctxs(struct bnxt *bp);
 unsigned int bnxt_get_max_func_cp_rings(struct bnxt *bp);
-- 
1.8.3.1
