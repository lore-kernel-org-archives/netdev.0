From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 19/21] [next] qlge: Set the MAC addr/frame routing after a firmware event.
Date: Fri, 23 Jan 2009 07:16:37 -0800
Message-ID: <1232723799-8620-19-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743AbZAWPSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:18:14 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After port reset the MAC address and frame route settings are cleared.
This patch caused them to be set when the follow up link event occurs.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h     |    2 ++
 drivers/net/qlge/qlge_mpi.c |   14 ++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)
 mode change 100644 => 100755 drivers/net/qlge/qlge.h

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
old mode 100644
new mode 100755
index a374981..2f3ca60
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1346,6 +1346,8 @@ enum {
 	QL_DMA64 = (1 << 5),
 	QL_PROMISCUOUS = (1 << 6),
 	QL_ALLMULTI = (1 << 7),
+	QL_PORT_CFG = (1 << 8),
+	QL_CAM_RT_SET = (1 << 9),
 };
 
 /* link_status bit definitions */
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index e113263..4e336ef 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -72,12 +72,26 @@ static int ql_get_mb_sts(struct ql_adapter *qdev, struct mbox_params *mbcp)
 
 static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
+	int status = 0;
+
 	mbcp->out_count = 2;
 
 	if (ql_get_mb_sts(qdev, mbcp))
 		return;
 
 	qdev->link_status = mbcp->mbox_out[1];
+	/* If we're coming back from an IDC event
+	 * then set up the CAM and frame routing.
+	 */
+	if (test_bit(QL_CAM_RT_SET, &qdev->flags)) {
+		status = ql_cam_route_initialize(qdev);
+		if (status)
+			QPRINTK(qdev, IFUP, ERR,
+			"Failed to init CAM/Routing tables.\n");
+		else
+			clear_bit(QL_CAM_RT_SET, &qdev->flags);
+	}
+
 	ql_link_on(qdev);
 }
 
-- 
1.6.0.2

