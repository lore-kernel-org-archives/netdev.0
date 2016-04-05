From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 6/9] bnxt_en: Set async event bits when registering with the firmware.
Date: Tue,  5 Apr 2016 14:09:00 -0400
Message-ID: <1459879743-16960-7-git-send-email-michael.chan@broadcom.com>
References: <1459879743-16960-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:34331 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933573AbcDESJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 14:09:16 -0400
In-Reply-To: <1459879743-16960-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the driver only sets bit 0 of the async_event_fwd fields.
To be compatible with the latest spec, we need to set the
appropriate event bits handled by the driver.  We should be handling
link change and PF driver unload events, so these 2 bits should be
set.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 2c3c795..dd0b32c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -118,6 +118,11 @@ static const u16 bnxt_vf_req_snif[] = {
 	HWRM_CFA_L2_FILTER_ALLOC,
 };
 
+static const u16 bnxt_async_events_arr[] = {
+	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE,
+	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD,
+};
+
 static bool bnxt_vf_pciid(enum board_idx idx)
 {
 	return (idx == BCM57304_VF || idx == BCM57404_VF);
@@ -2751,6 +2756,8 @@ static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
 {
 	struct hwrm_func_drv_rgtr_input req = {0};
 	int i;
+	DECLARE_BITMAP(async_events_bmap, 256);
+	u32 *events = (u32 *)async_events_bmap;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_DRV_RGTR, -1, -1);
 
@@ -2759,10 +2766,13 @@ static int bnxt_hwrm_func_drv_rgtr(struct bnxt *bp)
 			    FUNC_DRV_RGTR_REQ_ENABLES_VER |
 			    FUNC_DRV_RGTR_REQ_ENABLES_ASYNC_EVENT_FWD);
 
-	/* TODO: current async event fwd bits are not defined and the firmware
-	 * only checks if it is non-zero to enable async event forwarding
-	 */
-	req.async_event_fwd[0] |= cpu_to_le32(1);
+	memset(async_events_bmap, 0, sizeof(async_events_bmap));
+	for (i = 0; i < ARRAY_SIZE(bnxt_async_events_arr); i++)
+		__set_bit(bnxt_async_events_arr[i], async_events_bmap);
+
+	for (i = 0; i < 8; i++)
+		req.async_event_fwd[i] |= cpu_to_le32(events[i]);
+
 	req.os_type = cpu_to_le16(FUNC_DRV_RGTR_REQ_OS_TYPE_LINUX);
 	req.ver_maj = DRV_VER_MAJ;
 	req.ver_min = DRV_VER_MIN;
-- 
1.8.3.1
