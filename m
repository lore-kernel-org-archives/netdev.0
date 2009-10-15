From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH 2/2] be2net: fix support for PCI hot plug
Date: Thu, 15 Oct 2009 11:51:17 +0530
Message-ID: <20091015062117.GA31504@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:28767 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754267AbZJOGXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 02:23:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before issuing any cmds to the FW, the driver must first wait
till the fW becomes ready. This is needed for PCI hot plug when
the driver can be probed while the card fw is being initialized.

Pls apply to net-2.6 tree.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   25 ++++++++++++++++++-------
 drivers/net/benet/be_main.c |    8 ++++----
 2 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index b57abc0..28a0eda 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -243,15 +243,26 @@ static int be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
 
 int be_cmd_POST(struct be_adapter *adapter)
 {
-	u16 stage, error;
+	u16 stage;
+	int status, timeout = 0;
 
-	error = be_POST_stage_get(adapter, &stage);
-	if (error || stage != POST_STAGE_ARMFW_RDY) {
-		dev_err(&adapter->pdev->dev, "POST failed.\n");
-		return -1;
-	}
+	do {
+		status = be_POST_stage_get(adapter, &stage);
+		if (status) {
+			dev_err(&adapter->pdev->dev, "POST error; stage=0x%x\n",
+				stage);
+			return -1;
+		} else if (stage != POST_STAGE_ARMFW_RDY) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			schedule_timeout(2 * HZ);
+			timeout += 2;
+		} else {
+			return 0;
+		}
+	} while (timeout < 20);
 
-	return 0;
+	dev_err(&adapter->pdev->dev, "POST timeout; stage=0x%x\n", stage);
+	return -1;
 }
 
 static inline void *embedded_payload(struct be_mcc_wrb *wrb)
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 36cb948..1f941f0 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2058,6 +2058,10 @@ static int be_hw_up(struct be_adapter *adapter)
 	if (status)
 		return status;
 
+	status = be_cmd_reset_function(adapter);
+	if (status)
+		return status;
+
 	status = be_cmd_get_fw_ver(adapter, adapter->fw_ver);
 	if (status)
 		return status;
@@ -2111,10 +2115,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status)
 		goto free_netdev;
 
-	status = be_cmd_reset_function(adapter);
-	if (status)
-		goto ctrl_clean;
-
 	status = be_stats_init(adapter);
 	if (status)
 		goto ctrl_clean;
-- 
1.6.0.4

