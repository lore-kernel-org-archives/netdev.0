From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/4] bnxt_en: Add async event handling for speed config changes.
Date: Mon, 11 Apr 2016 04:11:14 -0400
Message-ID: <1460362274-21771-5-git-send-email-michael.chan@broadcom.com>
References: <1460362274-21771-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:57523 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbcDKILS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:11:18 -0400
In-Reply-To: <1460362274-21771-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some dual port cards, link speeds on both ports have to be compatible.
Firmware will inform the driver when a certain speed is no longer
supported if the other port has linked up at a certain speed.  Add
logic to handle this event by logging a message and getting the
updated list of supported speeds.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c83a5a1..4645c44 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -122,6 +122,7 @@ static const u16 bnxt_async_events_arr[] = {
 	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE,
 	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD,
 	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PORT_CONN_NOT_ALLOWED,
+	HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_CHANGE,
 };
 
 static bool bnxt_vf_pciid(enum board_idx idx)
@@ -1257,6 +1258,21 @@ static int bnxt_async_event_process(struct bnxt *bp,
 
 	/* TODO CHIMP_FW: Define event id's for link change, error etc */
 	switch (event_id) {
+	case HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_SPEED_CFG_CHANGE: {
+		u32 data1 = le32_to_cpu(cmpl->event_data1);
+		struct bnxt_link_info *link_info = &bp->link_info;
+
+		if (BNXT_VF(bp))
+			goto async_event_process_exit;
+		if (data1 & 0x20000) {
+			u16 fw_speed = link_info->force_link_speed;
+			u32 speed = bnxt_fw_to_ethtool_speed(fw_speed);
+
+			netdev_warn(bp->dev, "Link speed %d no longer supported\n",
+				    speed);
+		}
+		/* fall thru */
+	}
 	case HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE:
 		set_bit(BNXT_LINK_CHNG_SP_EVENT, &bp->sp_event);
 		break;
-- 
1.8.3.1
