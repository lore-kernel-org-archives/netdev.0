From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 2/2] be2net: FLR must be first cmd issued to Lancer FW
Date: Mon, 29 Apr 2013 13:52:29 +0530
Message-ID: <78281116-7d1e-4aff-b59c-f9a583fa35ea@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Kalesh AP <kalesh.purayil@emulex.com>,
	"Somnath Kotur" <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:21375 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413Ab3D2IXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 04:23:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Lancer FW requires that the first cmd issued by the host-driver be an FLR.
So, re-order be_probe() to move be_cmd_function_reset() ahead of
be_cmd_fw_init().

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 43d5c1e..1c73491 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4174,23 +4174,23 @@ static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 			goto ctrl_clean;
 	}
 
-	/* tell fw we're ready to fire cmds */
-	status = be_cmd_fw_init(adapter);
-	if (status)
-		goto ctrl_clean;
-
 	if (be_reset_required(adapter)) {
 		status = be_cmd_reset_function(adapter);
 		if (status)
 			goto ctrl_clean;
-	}
 
-	/* Wait for interrupts to quiesce after an FLR */
-	msleep(100);
+		/* Wait for interrupts to quiesce after an FLR */
+		msleep(100);
+	}
 
 	/* Allow interrupts for other ULPs running on NIC function */
 	be_intr_set(adapter, true);
 
+	/* tell fw we're ready to fire cmds */
+	status = be_cmd_fw_init(adapter);
+	if (status)
+		goto ctrl_clean;
+
 	status = be_stats_init(adapter);
 	if (status)
 		goto ctrl_clean;
@@ -4400,12 +4400,12 @@ static void be_eeh_resume(struct pci_dev *pdev)
 
 	pci_save_state(pdev);
 
-	/* tell fw we're ready to fire cmds */
-	status = be_cmd_fw_init(adapter);
+	status = be_cmd_reset_function(adapter);
 	if (status)
 		goto err;
 
-	status = be_cmd_reset_function(adapter);
+	/* tell fw we're ready to fire cmds */
+	status = be_cmd_fw_init(adapter);
 	if (status)
 		goto err;
 
-- 
1.6.0.2
