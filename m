From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 1/6] bnx2x: dcb - send all unmapped priorities to same
 COS as L2
Date: Sun, 24 Jul 2011 17:09:43 +0300
Message-ID: <1311516583.23243.20.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>, ariele@broadcom.com
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1790 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752831Ab1GXOLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2011 10:11:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a result of DCBX negotiation some priorities maybe untouched and still 
unmapped to any COS; instead of sending them to COS0 we assign them
to the same COS as L2 traffic - to avoid collisions with storage class of
service. 

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_dcb.c |   39 +++++++++++++++++++++++++++++++++------
 1 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index d028794..a4ea35f 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -19,15 +19,13 @@
 #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/errno.h>
+#include <linux/rtnetlink.h>
+#include <net/dcbnl.h>
 
 #include "bnx2x.h"
 #include "bnx2x_cmn.h"
 #include "bnx2x_dcb.h"
 
-#ifdef BCM_DCBNL
-#include <linux/rtnetlink.h>
-#endif
-
 /* forward declarations of dcbx related functions */
 static int bnx2x_dcbx_stop_hw_tx(struct bnx2x *bp);
 static void bnx2x_pfc_set_pfc(struct bnx2x *bp);
@@ -333,6 +331,32 @@ static void  bnx2x_dcbx_get_pfc_feature(struct bnx2x *bp,
 	}
 }
 
+/* maps unmapped priorities to to the same COS as L2 */
+static void bnx2x_dcbx_map_nw(struct bnx2x *bp)
+{
+	int i;
+	u32 unmapped = (1 << MAX_PFC_PRIORITIES) - 1; /* all ones */
+	u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
+	u32 nw_prio = 1 << ttp[LLFC_TRAFFIC_TYPE_NW];
+	struct bnx2x_dcbx_cos_params *cos_params =
+			bp->dcbx_port_params.ets.cos_params;
+
+	/* get unmapped priorities by clearing mapped bits */
+	for (i = 0; i < LLFC_DRIVER_TRAFFIC_TYPE_MAX; i++)
+		unmapped &= ~(1 << ttp[i]);
+
+	/* find cos for nw prio and extend it with unmapped */
+	for (i = 0; i < ARRAY_SIZE(bp->dcbx_port_params.ets.cos_params); i++) {
+		if (cos_params[i].pri_bitmask & nw_prio) {
+			/* extend the bitmask with unmapped */
+			DP(NETIF_MSG_LINK,
+			   "cos %d extended with 0x%08x", i, unmapped);
+			cos_params[i].pri_bitmask |= unmapped;
+			break;
+		}
+	}
+}
+
 static void bnx2x_get_dcbx_drv_param(struct bnx2x *bp,
 				     struct dcbx_features *features,
 				     u32 error)
@@ -342,6 +366,8 @@ static void bnx2x_get_dcbx_drv_param(struct bnx2x *bp,
 	bnx2x_dcbx_get_pfc_feature(bp, &features->pfc, error);
 
 	bnx2x_dcbx_get_ets_feature(bp, &features->ets, error);
+
+	bnx2x_dcbx_map_nw(bp);
 }
 
 #define DCBX_LOCAL_MIB_MAX_TRY_READ		(100)
@@ -682,6 +708,8 @@ static inline void bnx2x_dcbx_update_tc_mapping(struct bnx2x *bp)
 			if (bp->dcbx_port_params.ets.cos_params[cos].pri_bitmask
 			    & (1 << prio)) {
 				bp->prio_to_cos[prio] = cos;
+				DP(NETIF_MSG_LINK,
+				   "tx_mapping %d --> %d\n", prio, cos);
 			}
 		}
 	}
@@ -749,7 +777,7 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 		DP(NETIF_MSG_LINK, "BNX2X_DCBX_STATE_TX_RELEASED\n");
 		bnx2x_fw_command(bp, DRV_MSG_CODE_DCBX_PMF_DRV_OK, 0);
 #ifdef BCM_DCBNL
-		/**
+		/*
 		 * Send a notification for the new negotiated parameters
 		 */
 		dcbnl_cee_notify(bp->dev, RTM_GETDCB, DCB_CMD_CEE_GET, 0, 0);
@@ -1732,7 +1760,6 @@ static void bnx2x_dcbx_fill_cos_params(struct bnx2x *bp,
 							  pri_join_mask,
 							  num_of_dif_pri);
 
-
 	for (i = 0; i < cos_data.num_of_cos ; i++) {
 		struct bnx2x_dcbx_cos_params *p =
 			&bp->dcbx_port_params.ets.cos_params[i];
-- 
1.7.2.2





