From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 4/5] bnx2x: extend DCBx support
Date: Tue, 16 Feb 2016 18:08:00 +0200
Message-ID: <1455638881-2527-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:26991 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933120AbcBPQIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 11:08:51 -0500
In-Reply-To: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for default application priority.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c | 57 +++++++++++++++++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h |  5 ++-
 2 files changed, 47 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 7ccf668..2c6ba04 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -195,6 +195,7 @@ static void bnx2x_dcbx_get_ap_feature(struct bnx2x *bp,
 				   u32 error) {
 	u8 index;
 	u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
+	u8 iscsi_pri_found = 0, fcoe_pri_found = 0;
 
 	if (GET_FLAGS(error, DCBX_LOCAL_APP_ERROR))
 		DP(BNX2X_MSG_DCB, "DCBX_LOCAL_APP_ERROR\n");
@@ -210,29 +211,57 @@ static void bnx2x_dcbx_get_ap_feature(struct bnx2x *bp,
 
 		bp->dcbx_port_params.app.enabled = true;
 
+		/* Use 0 as the default application priority for all. */
 		for (index = 0 ; index < LLFC_DRIVER_TRAFFIC_TYPE_MAX; index++)
 			ttp[index] = 0;
 
-		if (app->default_pri < MAX_PFC_PRIORITIES)
-			ttp[LLFC_TRAFFIC_TYPE_NW] = app->default_pri;
-
 		for (index = 0 ; index < DCBX_MAX_APP_PROTOCOL; index++) {
 			struct dcbx_app_priority_entry *entry =
 							app->app_pri_tbl;
+			enum traffic_type type = MAX_TRAFFIC_TYPE;
 
 			if (GET_FLAGS(entry[index].appBitfield,
-				     DCBX_APP_SF_ETH_TYPE) &&
-			   ETH_TYPE_FCOE == entry[index].app_id)
-				bnx2x_dcbx_get_ap_priority(bp,
-						entry[index].pri_bitmap,
-						LLFC_TRAFFIC_TYPE_FCOE);
+				      DCBX_APP_SF_DEFAULT) &&
+			    GET_FLAGS(entry[index].appBitfield,
+				      DCBX_APP_SF_ETH_TYPE)) {
+				type = LLFC_TRAFFIC_TYPE_NW;
+			} else if (GET_FLAGS(entry[index].appBitfield,
+					     DCBX_APP_SF_PORT) &&
+				   TCP_PORT_ISCSI == entry[index].app_id) {
+				type = LLFC_TRAFFIC_TYPE_ISCSI;
+				iscsi_pri_found = 1;
+			} else if (GET_FLAGS(entry[index].appBitfield,
+					     DCBX_APP_SF_ETH_TYPE) &&
+				   ETH_TYPE_FCOE == entry[index].app_id) {
+				type = LLFC_TRAFFIC_TYPE_FCOE;
+				fcoe_pri_found = 1;
+			}
 
-			if (GET_FLAGS(entry[index].appBitfield,
-				     DCBX_APP_SF_PORT) &&
-			   TCP_PORT_ISCSI == entry[index].app_id)
-				bnx2x_dcbx_get_ap_priority(bp,
-						entry[index].pri_bitmap,
-						LLFC_TRAFFIC_TYPE_ISCSI);
+			if (type == MAX_TRAFFIC_TYPE)
+				continue;
+
+			bnx2x_dcbx_get_ap_priority(bp,
+						   entry[index].pri_bitmap,
+						   type);
+		}
+
+		/* If we have received a non-zero default application
+		 * priority, then use that for applications which are
+		 * not configured with any priority.
+		 */
+		if (ttp[LLFC_TRAFFIC_TYPE_NW] != 0) {
+			if (!iscsi_pri_found) {
+				ttp[LLFC_TRAFFIC_TYPE_ISCSI] =
+					ttp[LLFC_TRAFFIC_TYPE_NW];
+				DP(BNX2X_MSG_DCB,
+				   "ISCSI is using default priority.\n");
+			}
+			if (!fcoe_pri_found) {
+				ttp[LLFC_TRAFFIC_TYPE_FCOE] =
+					ttp[LLFC_TRAFFIC_TYPE_NW];
+				DP(BNX2X_MSG_DCB,
+				   "FCoE is using default priority.\n");
+			}
 		}
 	} else {
 		DP(BNX2X_MSG_DCB, "DCBX_LOCAL_APP_DISABLED\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 27aa080..dd9d6e6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1831,10 +1831,13 @@ struct dcbx_app_priority_entry {
 #elif defined(__LITTLE_ENDIAN)
 	u8 appBitfield;
 	#define DCBX_APP_ENTRY_VALID         0x01
-	#define DCBX_APP_ENTRY_SF_MASK       0x30
+	#define DCBX_APP_ENTRY_SF_MASK       0xF0
 	#define DCBX_APP_ENTRY_SF_SHIFT      4
+	#define DCBX_APP_ENTRY_VALID         0x01
 	#define DCBX_APP_SF_ETH_TYPE         0x10
 	#define DCBX_APP_SF_PORT             0x20
+	#define DCBX_APP_SF_UDP              0x40
+	#define DCBX_APP_SF_DEFAULT          0x80
 	u8  pri_bitmap;
 	u16  app_id;
 #endif
-- 
1.9.3
