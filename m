From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 5/6] qlge: Make adapter drop frame errors and pass up csum errors.
Date: Mon,  5 Jul 2010 15:19:41 -0700
Message-ID: <1278368382-23887-6-git-send-email-ron.mercer@qlogic.com>
References: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:42713 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755115Ab0GEXFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 19:05:19 -0400
In-Reply-To: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Statistics are available and the driver doesn't need the actual frame.
This TCP/UDP and IP headers checksum errors will still be passed to the
driver.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   30 ++++++++++++++++++++++++++++--
 1 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index a41b6b5..dd9e86c 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -574,6 +574,22 @@ static int ql_set_routing_reg(struct ql_adapter *qdev, u32 index, u32 mask,
 			    (RT_IDX_ALL_ERR_SLOT << RT_IDX_IDX_SHIFT);/* index */
 			break;
 		}
+	case RT_IDX_IP_CSUM_ERR: /* Pass up IP CSUM error frames. */
+		{
+			value = RT_IDX_DST_DFLT_Q | /* dest */
+				RT_IDX_TYPE_NICQ | /* type */
+				(RT_IDX_IP_CSUM_ERR_SLOT <<
+				RT_IDX_IDX_SHIFT); /* index */
+			break;
+		}
+	case RT_IDX_TU_CSUM_ERR: /* Pass up TCP/UDP CSUM error frames. */
+		{
+			value = RT_IDX_DST_DFLT_Q | /* dest */
+				RT_IDX_TYPE_NICQ | /* type */
+				(RT_IDX_TCP_UDP_CSUM_ERR_SLOT <<
+				RT_IDX_IDX_SHIFT); /* index */
+			break;
+		}
 	case RT_IDX_BCAST:	/* Pass up Broadcast frames to default Q. */
 		{
 			value = RT_IDX_DST_DFLT_Q |	/* dest */
@@ -3587,10 +3603,20 @@ static int ql_route_initialize(struct ql_adapter *qdev)
 	if (status)
 		return status;
 
-	status = ql_set_routing_reg(qdev, RT_IDX_ALL_ERR_SLOT, RT_IDX_ERR, 1);
+	status = ql_set_routing_reg(qdev, RT_IDX_IP_CSUM_ERR_SLOT,
+						RT_IDX_IP_CSUM_ERR, 1);
+	if (status) {
+		netif_err(qdev, ifup, qdev->ndev,
+			"Failed to init routing register "
+			"for IP CSUM error packets.\n");
+		goto exit;
+	}
+	status = ql_set_routing_reg(qdev, RT_IDX_TCP_UDP_CSUM_ERR_SLOT,
+						RT_IDX_TU_CSUM_ERR, 1);
 	if (status) {
 		netif_err(qdev, ifup, qdev->ndev,
-			  "Failed to init routing register for error packets.\n");
+			"Failed to init routing register "
+			"for TCP/UDP CSUM error packets.\n");
 		goto exit;
 	}
 	status = ql_set_routing_reg(qdev, RT_IDX_BCAST_SLOT, RT_IDX_BCAST, 1);
-- 
1.6.0.2

