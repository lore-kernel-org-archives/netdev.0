From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH v2 net-next 1/6] qlcnic: fix unsupported CDRP command error message.
Date: Mon, 18 Feb 2013 17:06:13 -0500
Message-ID: <1361225178-4363-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1361225178-4363-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48836 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756989Ab3BRW2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 17:28:08 -0500
In-Reply-To: <1361225178-4363-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Added detailed error messages for FW CDRP command failure

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |   25 +++++++++++++++++++++-
 1 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 4a3bd64..6308d4d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -126,6 +126,7 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 	u32 signature;
 	struct pci_dev *pdev = adapter->pdev;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	const char *fmt;
 
 	signature = qlcnic_get_cmd_signature(ahw);
 
@@ -147,8 +148,28 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
 	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
 		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1));
-		dev_err(&pdev->dev, "failed card response code:0x%x\n",
-			cmd->rsp.arg[0]);
+		switch (cmd->rsp.arg[0]) {
+		case QLCNIC_RCODE_INVALID_ARGS:
+			fmt = "CDRP invalid args: [%d]\n";
+			break;
+		case QLCNIC_RCODE_NOT_SUPPORTED:
+		case QLCNIC_RCODE_NOT_IMPL:
+			fmt = "CDRP command not supported: [%d]\n";
+			break;
+		case QLCNIC_RCODE_NOT_PERMITTED:
+			fmt = "CDRP requested action not permitted: [%d]\n";
+			break;
+		case QLCNIC_RCODE_INVALID:
+			fmt = "CDRP invalid or unknown cmd received: [%d]\n";
+			break;
+		case QLCNIC_RCODE_TIMEOUT:
+			fmt = "CDRP command timeout: [%d]\n";
+			break;
+		default:
+			fmt = "CDRP command failed: [%d]\n";
+			break;
+		}
+		dev_err(&pdev->dev, fmt, cmd->rsp.arg[0]);
 	} else if (rsp == QLCNIC_CDRP_RSP_OK)
 		cmd->rsp.arg[0] = QLCNIC_RCODE_SUCCESS;
 
-- 
1.7.1
