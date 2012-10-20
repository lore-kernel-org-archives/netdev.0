From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 04/14] be2net: Wait till resources are available for VF in error recovery
Date: Sat, 20 Oct 2012 21:32:27 +0530
Message-ID: <cecef26e-3836-4c6c-bd1b-d742d2ae9a87@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22343 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374Ab2JTQDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:03:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After FW error, driver should wait for NO_RESOURCE error to disappear before
proceeding with recovery.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   31 +++++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_hw.h   |    3 ++
 drivers/net/ethernet/emulex/benet/be_main.c |    5 ++-
 3 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 3980b58..9a12c4b 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -452,10 +452,33 @@ int lancer_wait_ready(struct be_adapter *adapter)
 	return status;
 }
 
+static bool lancer_provisioning_error(struct be_adapter *adapter)
+{
+	u32 sliport_status = 0, sliport_err1 = 0, sliport_err2 = 0;
+	sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
+	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
+		sliport_err1 = ioread32(adapter->db +
+					SLIPORT_ERROR1_OFFSET);
+		sliport_err2 = ioread32(adapter->db +
+					SLIPORT_ERROR2_OFFSET);
+
+		if (sliport_err1 == SLIPORT_ERROR_NO_RESOURCE1 &&
+		    sliport_err2 == SLIPORT_ERROR_NO_RESOURCE2)
+			return true;
+	}
+	return false;
+}
+
 int lancer_test_and_set_rdy_state(struct be_adapter *adapter)
 {
 	int status;
 	u32 sliport_status, err, reset_needed;
+	bool resource_error;
+
+	resource_error = lancer_provisioning_error(adapter);
+	if (resource_error)
+		return -1;
+
 	status = lancer_wait_ready(adapter);
 	if (!status) {
 		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
@@ -477,6 +500,14 @@ int lancer_test_and_set_rdy_state(struct be_adapter *adapter)
 			status = -1;
 		}
 	}
+	/* Stop error recovery if error is not recoverable.
+	 * No resource error is temporary errors and will go away
+	 * when PF provisions resources.
+	 */
+	resource_error = lancer_provisioning_error(adapter);
+	if (status == -1 && !resource_error)
+		adapter->eeh_error = true;
+
 	return status;
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index b755f70..4ccbc36 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -59,6 +59,9 @@
 #define PHYSDEV_CONTROL_FW_RESET_MASK	0x00000002
 #define PHYSDEV_CONTROL_INP_MASK	0x40000000
 
+#define SLIPORT_ERROR_NO_RESOURCE1	0x2
+#define SLIPORT_ERROR_NO_RESOURCE2	0x9
+
 /********* Memory BAR register ************/
 #define PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET 	0xfc
 /* Host Interrupt Enable, if set interrupts are enabled although "PCI Interrupt
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 41f935a..7a483fd 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3837,8 +3837,9 @@ static int lancer_recover_func(struct be_adapter *adapter)
 		"Adapter SLIPORT recovery succeeded\n");
 	return 0;
 err:
-	dev_err(&adapter->pdev->dev,
-		"Adapter SLIPORT recovery failed\n");
+	if (adapter->eeh_error)
+		dev_err(&adapter->pdev->dev,
+			"Adapter SLIPORT recovery failed\n");
 
 	return status;
 }
-- 
1.6.0.2
