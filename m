From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 05/21] [next] qlge: Add new function for MAC address and frame routing.
Date: Fri, 23 Jan 2009 07:16:23 -0800
Message-ID: <1232723799-8620-5-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992AbZAWPRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:45 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code needs to be centralized as it will later be called
in response to firmware events.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   31 ++++++++++++++++++++++---------
 1 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 60d3c31..236597d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2996,6 +2996,24 @@ static int ql_route_initialize(struct ql_adapter *qdev)
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
@@ -3066,16 +3084,11 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
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

