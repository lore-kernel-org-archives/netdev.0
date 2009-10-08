From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 4/7] qlge: Fix RX multicast filter settings.
Date: Thu,  8 Oct 2009 12:54:40 -0700
Message-ID: <1255031683-3912-5-git-send-email-ron.mercer@qlogic.com>
References: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:40572 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933176AbZJHUCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 16:02:02 -0400
In-Reply-To: <1255031683-3912-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addresses were being added to the filter properly, but were not
being enabled.  This adds enable bit to filter write.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   49 +++++++++++++++++++++++++++++++++--------
 1 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 20c074c..e1203bf 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -320,6 +320,37 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 
 	switch (type) {
 	case MAC_ADDR_TYPE_MULTI_MAC:
+		{
+			u32 upper = (addr[0] << 8) | addr[1];
+			u32 lower = (addr[2] << 24) | (addr[3] << 16) |
+					(addr[4] << 8) | (addr[5]);
+
+			status =
+				ql_wait_reg_rdy(qdev,
+				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
+			if (status)
+				goto exit;
+			ql_write32(qdev, MAC_ADDR_IDX, (offset++) |
+				(index << MAC_ADDR_IDX_SHIFT) |
+				type | MAC_ADDR_E);
+			ql_write32(qdev, MAC_ADDR_DATA, lower);
+			status =
+				ql_wait_reg_rdy(qdev,
+				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
+			if (status)
+				goto exit;
+			ql_write32(qdev, MAC_ADDR_IDX, (offset++) |
+				(index << MAC_ADDR_IDX_SHIFT) |
+				type | MAC_ADDR_E);
+
+			ql_write32(qdev, MAC_ADDR_DATA, upper);
+			status =
+				ql_wait_reg_rdy(qdev,
+				MAC_ADDR_IDX, MAC_ADDR_MW, 0);
+			if (status)
+				goto exit;
+			break;
+		}
 	case MAC_ADDR_TYPE_CAM_MAC:
 		{
 			u32 cam_output;
@@ -365,16 +396,14 @@ static int ql_set_mac_addr_reg(struct ql_adapter *qdev, u8 *addr, u32 type,
 			   and possibly the function id.  Right now we hardcode
 			   the route field to NIC core.
 			 */
-			if (type == MAC_ADDR_TYPE_CAM_MAC) {
-				cam_output = (CAM_OUT_ROUTE_NIC |
-					      (qdev->
-					       func << CAM_OUT_FUNC_SHIFT) |
-						(0 << CAM_OUT_CQ_ID_SHIFT));
-				if (qdev->vlgrp)
-					cam_output |= CAM_OUT_RV;
-				/* route to NIC core */
-				ql_write32(qdev, MAC_ADDR_DATA, cam_output);
-			}
+			cam_output = (CAM_OUT_ROUTE_NIC |
+				      (qdev->
+				       func << CAM_OUT_FUNC_SHIFT) |
+					(0 << CAM_OUT_CQ_ID_SHIFT));
+			if (qdev->vlgrp)
+				cam_output |= CAM_OUT_RV;
+			/* route to NIC core */
+			ql_write32(qdev, MAC_ADDR_DATA, cam_output);
 			break;
 		}
 	case MAC_ADDR_TYPE_VLAN:
-- 
1.6.0.2

