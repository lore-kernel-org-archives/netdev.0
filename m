From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 17/21] [next] qlge: Use new link up/down func FW event handler.
Date: Fri, 23 Jan 2009 07:16:35 -0800
Message-ID: <1232723799-8620-17-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338AbZAWPSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:18:05 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add usage of ql_link_on() and ql_link_off functions for
firmware event handlers.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    2 ++
 drivers/net/qlge/qlge_main.c |    4 ++--
 drivers/net/qlge/qlge_mpi.c  |   23 ++++-------------------
 3 files changed, 8 insertions(+), 21 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 96287d9..a374981 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1542,6 +1542,8 @@ u32 ql_enable_completion_interrupt(struct ql_adapter *qdev, u32 intr);
 void ql_set_ethtool_ops(struct net_device *ndev);
 int ql_read_xgmac_reg64(struct ql_adapter *qdev, u32 reg, u64 *data);
 int ql_cam_route_initialize(struct ql_adapter *qdev);
+void ql_link_on(struct ql_adapter *qdev);
+void ql_link_off(struct ql_adapter *qdev);
 
 #if 1
 #define QL_ALL_DUMP
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index ea9ca3f..af4b64b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -240,7 +240,7 @@ exit:
 	return status;
 }
 
-static void ql_link_on(struct ql_adapter *qdev)
+void ql_link_on(struct ql_adapter *qdev)
 {
 	if (!netif_carrier_ok(qdev->ndev)) {
 		QPRINTK(qdev, LINK, INFO, "Link is Up.\n");
@@ -249,7 +249,7 @@ static void ql_link_on(struct ql_adapter *qdev)
 	}
 }
 
-static void ql_link_off(struct ql_adapter *qdev)
+void ql_link_off(struct ql_adapter *qdev)
 {
 	if (netif_carrier_ok(qdev->ndev)) {
 		QPRINTK(qdev, LINK, INFO, "Link is Down.\n");
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 867baca..fd8cdac 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -78,31 +78,16 @@ static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 		return;
 
 	qdev->link_status = mbcp->mbox_out[1];
-	QPRINTK(qdev, DRV, ERR, "Link Up.\n");
-	QPRINTK(qdev, DRV, INFO, "Link Status = 0x%.08x.\n", mbcp->mbox_out[1]);
-	if (!netif_carrier_ok(qdev->ndev)) {
-		QPRINTK(qdev, LINK, INFO, "Link is Up.\n");
-		netif_carrier_on(qdev->ndev);
-		netif_wake_queue(qdev->ndev);
-	}
+	ql_link_on(qdev);
 }
 
 static void ql_link_down(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
 	mbcp->out_count = 3;
 
-	if (ql_get_mb_sts(qdev, mbcp)) {
-		QPRINTK(qdev, DRV, ERR, "Firmware did not initialize!\n");
-		return;
-	}
-
-	if (netif_carrier_ok(qdev->ndev)) {
-		QPRINTK(qdev, LINK, INFO, "Link is Down.\n");
-		netif_carrier_off(qdev->ndev);
-		netif_stop_queue(qdev->ndev);
-	}
-	QPRINTK(qdev, DRV, ERR, "Link Down.\n");
-	QPRINTK(qdev, DRV, ERR, "Link Status = 0x%.08x.\n", mbcp->mbox_out[1]);
+	if (ql_get_mb_sts(qdev, mbcp))
+		QPRINTK(qdev, DRV, ERR, "Failed to get link status!\n");
+	ql_link_off(qdev);
 }
 
 static void ql_init_fw_done(struct ql_adapter *qdev, struct mbox_params *mbcp)
-- 
1.6.0.2

