From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next 2/3] qlcnic: fix unsupported CDRP command error message.
Date: Wed,  6 Jun 2012 13:35:07 -0400
Message-ID: <1339004108-7356-3-git-send-email-anirban.chakraborty@qlogic.com>
References: <1339004108-7356-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53783 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757571Ab2FFRuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 13:50:52 -0400
In-Reply-To: <1339004108-7356-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Add debug messages for FW CDRP command failure.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h     |    4 +++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |   34 +++++++++++++++++++---
 2 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 520ff03..df4552f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -612,7 +612,11 @@ struct qlcnic_recv_context {
 #define QLCNIC_CDRP_CMD_GET_MAC_STATS		0x00000037
 
 #define QLCNIC_RCODE_SUCCESS		0
+#define QLCNIC_RCODE_INVALID_ARGS	6
 #define QLCNIC_RCODE_NOT_SUPPORTED	9
+#define QLCNIC_RCODE_NOT_PERMITTED	10
+#define QLCNIC_RCODE_NOT_IMPL		15
+#define QLCNIC_RCODE_INVALID		16
 #define QLCNIC_RCODE_TIMEOUT		17
 #define QLCNIC_DESTROY_CTX_RESET	0
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index cfa174d..b8ead69 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -53,12 +53,39 @@ qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
 	rsp = qlcnic_poll_rsp(adapter);
 
 	if (rsp == QLCNIC_CDRP_RSP_TIMEOUT) {
-		dev_err(&pdev->dev, "card response timeout.\n");
+		dev_err(&pdev->dev, "CDRP response timeout.\n");
 		cmd->rsp.cmd = QLCNIC_RCODE_TIMEOUT;
 	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
 		cmd->rsp.cmd = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
-		dev_err(&pdev->dev, "failed card response code:0x%x\n",
+		switch (cmd->rsp.cmd) {
+		case QLCNIC_RCODE_INVALID_ARGS:
+			dev_err(&pdev->dev, "CDRP invalid args: 0x%x.\n",
 				cmd->rsp.cmd);
+			break;
+		case QLCNIC_RCODE_NOT_SUPPORTED:
+		case QLCNIC_RCODE_NOT_IMPL:
+			dev_err(&pdev->dev,
+				"CDRP command not supported: 0x%x.\n",
+				cmd->rsp.cmd);
+			break;
+		case QLCNIC_RCODE_NOT_PERMITTED:
+			dev_err(&pdev->dev,
+				"CDRP requested action not permitted: 0x%x.\n",
+				cmd->rsp.cmd);
+			break;
+		case QLCNIC_RCODE_INVALID:
+			dev_err(&pdev->dev,
+				"CDRP invalid or unknown cmd received: 0x%x.\n",
+				cmd->rsp.cmd);
+			break;
+		case QLCNIC_RCODE_TIMEOUT:
+			dev_err(&pdev->dev, "CDRP command timeout: 0x%x.\n",
+				cmd->rsp.cmd);
+			break;
+		default:
+			dev_err(&pdev->dev, "CDRP command failed: 0x%x.\n",
+				cmd->rsp.cmd);
+		}
 	} else if (rsp == QLCNIC_CDRP_RSP_OK) {
 		cmd->rsp.cmd = QLCNIC_RCODE_SUCCESS;
 		if (cmd->rsp.arg2)
@@ -957,9 +984,6 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 		mac_stats->mac_rx_jabber = le64_to_cpu(stats->mac_rx_jabber);
 		mac_stats->mac_rx_dropped = le64_to_cpu(stats->mac_rx_dropped);
 		mac_stats->mac_rx_crc_error = le64_to_cpu(stats->mac_rx_crc_error);
-	} else {
-		dev_info(&adapter->pdev->dev,
-			"%s: Get mac stats failed =%d.\n", __func__, err);
 	}
 
 	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
-- 
1.7.4.1
