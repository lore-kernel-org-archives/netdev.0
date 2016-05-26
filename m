From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 7/8] qed: Prevent 100g from working in MSI
Date: Thu, 26 May 2016 11:01:23 +0300
Message-ID: <1464249684-976-8-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:7578 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753242AbcEZIBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 04:01:53 -0400
In-Reply-To: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

Adapter can support 100g in both MSIx and INTa, but not in MSI.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c  |  5 +++++
 drivers/net/ethernet/qlogic/qed/qed_main.c | 18 ++++++++++--------
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 2a7c875..579c6d5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -835,6 +835,11 @@ int qed_hw_init(struct qed_dev *cdev,
 	u32 load_code, param;
 	int rc, mfw_rc, i;
 
+	if ((int_mode == QED_INT_MODE_MSI) && (cdev->num_hwfns > 1)) {
+		DP_NOTICE(cdev, "MSI mode is not supported for CMT devices\n");
+		return -EINVAL;
+	}
+
 	if (IS_PF(cdev)) {
 		rc = qed_init_fw_data(cdev, bin_fw_data);
 		if (rc != 0)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 8b22f87..7530646 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -413,15 +413,17 @@ static int qed_set_int_mode(struct qed_dev *cdev, bool force_mode)
 		/* Fallthrough */
 
 	case QED_INT_MODE_MSI:
-		rc = pci_enable_msi(cdev->pdev);
-		if (!rc) {
-			int_params->out.int_mode = QED_INT_MODE_MSI;
-			goto out;
-		}
+		if (cdev->num_hwfns == 1) {
+			rc = pci_enable_msi(cdev->pdev);
+			if (!rc) {
+				int_params->out.int_mode = QED_INT_MODE_MSI;
+				goto out;
+			}
 
-		DP_NOTICE(cdev, "Failed to enable MSI\n");
-		if (force_mode)
-			goto out;
+			DP_NOTICE(cdev, "Failed to enable MSI\n");
+			if (force_mode)
+				goto out;
+		}
 		/* Fallthrough */
 
 	case QED_INT_MODE_INTA:
-- 
1.9.3
