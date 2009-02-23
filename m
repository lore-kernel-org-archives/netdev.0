From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/5] [net-next] qlge: Clean up mac address and frame route settings.
Date: Mon, 23 Feb 2009 12:42:13 -0800
Message-ID: <1235421737-32296-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:3006 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbZBWUpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 15:45:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting MAC addresses and routing frames to various queues will need to
be done in response to firmware events as well as during initialization.
This change encapsulates the facilities into a single call that can
later me made from other places.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   31 ++++++++++++++++++++++---------
 1 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index fd515af..3a041b6 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2958,6 +2958,24 @@ static int ql_route_initialize(struct ql_adapter *qdev)
 	return status;
 }
 
+static int ql_cam_route_initialize(struct ql_adapter *qdev)
+{
+	int status;
+
+	status = ql_set_mac_addr_reg(qdev, (u8 *) qdev->ndev->perm_addr,
+			     MAC_ADDR_TYPE_CAM_MAC, qdev->func * MAX_CQ);
+	if (status) {
+		QPRINTK(qdev, IFUP, ERR, "Failed to init mac address.\n");
+		return status;
+	}
+
+	status = ql_route_initialize(qdev);
+	if (status)
+		QPRINTK(qdev, IFUP, ERR, "Failed to init routing table.\n");
+
+	return status;
+}
+
 static int ql_adapter_initialize(struct ql_adapter *qdev)
 {
 	u32 value, mask;
@@ -3028,16 +3046,11 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 		return status;
 	}
 
-	status = ql_set_mac_addr_reg(qdev, (u8 *) qdev->ndev->perm_addr,
-				     MAC_ADDR_TYPE_CAM_MAC, qdev->func);
-	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to init mac address.\n");
-		return status;
-	}
-
-	status = ql_route_initialize(qdev);
+	/* Set up the MAC address and frame routing filter. */
+	status = ql_cam_route_initialize(qdev);
 	if (status) {
-		QPRINTK(qdev, IFUP, ERR, "Failed to init routing table.\n");
+		QPRINTK(qdev, IFUP, ERR,
+				"Failed to init CAM/Routing tables.\n");
 		return status;
 	}
 
-- 
1.6.0.2

