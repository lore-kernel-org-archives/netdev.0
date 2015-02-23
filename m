From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 6/9] be2net: remove code duplication relating to Lancer reset sequence
Date: Mon, 23 Feb 2015 04:20:13 -0500
Message-ID: <1424683216-29611-7-git-send-email-sathya.perla@emulex.com>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:5932 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbbBWJRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:21 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The steps needed for Lancer's reset/initialization sequence are:
	a) wait for SLIPORT_STAUS RDY bit to be set
	b) set the SLIPORT_CONTROL IP bit
	c) repeat step "a"

The code needed for this sequence is already covered by the be_func_init()
routine (with minor modifications.) So, get rid of the
lancer_test_and_set_rdy_state() and lancer_provisioning_error() routines
that unnecessarily duplicate this code. Also fixed the error recovery
function to take care of these changes

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 81 ++++---------------------
 drivers/net/ethernet/emulex/benet/be_main.c | 91 ++++++++++++++---------------
 2 files changed, 55 insertions(+), 117 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 8a8a230..f6db7b3 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -635,73 +635,16 @@ static int lancer_wait_ready(struct be_adapter *adapter)
 	for (i = 0; i < SLIPORT_READY_TIMEOUT; i++) {
 		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
 		if (sliport_status & SLIPORT_STATUS_RDY_MASK)
-			break;
-
-		msleep(1000);
-	}
-
-	if (i == SLIPORT_READY_TIMEOUT)
-		return sliport_status ? : -1;
-
-	return 0;
-}
-
-static bool lancer_provisioning_error(struct be_adapter *adapter)
-{
-	u32 sliport_status = 0, sliport_err1 = 0, sliport_err2 = 0;
-
-	sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
-	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
-		sliport_err1 = ioread32(adapter->db + SLIPORT_ERROR1_OFFSET);
-		sliport_err2 = ioread32(adapter->db + SLIPORT_ERROR2_OFFSET);
-
-		if (sliport_err1 == SLIPORT_ERROR_NO_RESOURCE1 &&
-		    sliport_err2 == SLIPORT_ERROR_NO_RESOURCE2)
-			return true;
-	}
-	return false;
-}
-
-int lancer_test_and_set_rdy_state(struct be_adapter *adapter)
-{
-	int status;
-	u32 sliport_status, err, reset_needed;
-	bool resource_error;
+			return 0;
 
-	resource_error = lancer_provisioning_error(adapter);
-	if (resource_error)
-		return -EAGAIN;
+		if (sliport_status & SLIPORT_STATUS_ERR_MASK &&
+		    !(sliport_status & SLIPORT_STATUS_RN_MASK))
+			return -EIO;
 
-	status = lancer_wait_ready(adapter);
-	if (!status) {
-		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
-		err = sliport_status & SLIPORT_STATUS_ERR_MASK;
-		reset_needed = sliport_status & SLIPORT_STATUS_RN_MASK;
-		if (err && reset_needed) {
-			iowrite32(SLI_PORT_CONTROL_IP_MASK,
-				  adapter->db + SLIPORT_CONTROL_OFFSET);
-
-			/* check if adapter has corrected the error */
-			status = lancer_wait_ready(adapter);
-			sliport_status = ioread32(adapter->db +
-						  SLIPORT_STATUS_OFFSET);
-			sliport_status &= (SLIPORT_STATUS_ERR_MASK |
-						SLIPORT_STATUS_RN_MASK);
-			if (status || sliport_status)
-				status = -1;
-		} else if (err || reset_needed) {
-			status = -1;
-		}
+		msleep(1000);
 	}
-	/* Stop error recovery if error is not recoverable.
-	 * No resource error is temporary errors and will go away
-	 * when PF provisions resources.
-	 */
-	resource_error = lancer_provisioning_error(adapter);
-	if (resource_error)
-		status = -EAGAIN;
 
-	return status;
+	return sliport_status ? : -1;
 }
 
 int be_fw_wait_ready(struct be_adapter *adapter)
@@ -738,7 +681,7 @@ int be_fw_wait_ready(struct be_adapter *adapter)
 
 err:
 	dev_err(dev, "POST timeout; stage=%#x\n", stage);
-	return -1;
+	return -ETIMEDOUT;
 }
 
 static inline struct be_sge *nonembedded_sgl(struct be_mcc_wrb *wrb)
@@ -2130,16 +2073,12 @@ int be_cmd_reset_function(struct be_adapter *adapter)
 	int status;
 
 	if (lancer_chip(adapter)) {
+		iowrite32(SLI_PORT_CONTROL_IP_MASK,
+			  adapter->db + SLIPORT_CONTROL_OFFSET);
 		status = lancer_wait_ready(adapter);
-		if (!status) {
-			iowrite32(SLI_PORT_CONTROL_IP_MASK,
-				  adapter->db + SLIPORT_CONTROL_OFFSET);
-			status = lancer_test_and_set_rdy_state(adapter);
-		}
-		if (status) {
+		if (status)
 			dev_err(&adapter->pdev->dev,
 				"Adapter in non recoverable error\n");
-		}
 		return status;
 	}
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 034ce70..4a29ff1 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4903,18 +4903,54 @@ static void be_netdev_init(struct net_device *netdev)
 	netdev->ethtool_ops = &be_ethtool_ops;
 }
 
+/* If any VFs are already enabled don't FLR the PF */
+static bool be_reset_required(struct be_adapter *adapter)
+{
+	return pci_num_vf(adapter->pdev) ? false : true;
+}
+
+/* Wait for the FW to be ready and perform the required initialization */
+static int be_func_init(struct be_adapter *adapter)
+{
+	int status;
+
+	status = be_fw_wait_ready(adapter);
+	if (status)
+		return status;
+
+	if (be_reset_required(adapter)) {
+		status = be_cmd_reset_function(adapter);
+		if (status)
+			return status;
+
+		/* Wait for interrupts to quiesce after an FLR */
+		msleep(100);
+
+		/* We can clear all errors when function reset succeeds */
+		be_clear_all_error(adapter);
+	}
+
+	/* Tell FW we're ready to fire cmds */
+	status = be_cmd_fw_init(adapter);
+	if (status)
+		return status;
+
+	/* Allow interrupts for other ULPs running on NIC function */
+	be_intr_set(adapter, true);
+
+	return 0;
+}
+
 static int be_err_recover(struct be_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct device *dev = &adapter->pdev->dev;
 	int status;
 
-	status = lancer_test_and_set_rdy_state(adapter);
+	status = be_func_init(adapter);
 	if (status)
 		goto err;
 
-	be_clear_all_error(adapter);
-
 	status = be_setup(adapter);
 	if (status)
 		goto err;
@@ -4927,13 +4963,13 @@ static int be_err_recover(struct be_adapter *adapter)
 
 	netif_device_attach(netdev);
 
-	dev_err(dev, "Adapter recovery successful\n");
+	dev_info(dev, "Adapter recovery successful\n");
 	return 0;
 err:
-	if (status == -EAGAIN)
-		dev_err(dev, "Waiting for resource provisioning\n");
-	else
+	if (be_physfn(adapter))
 		dev_err(dev, "Adapter recovery failed\n");
+	else
+		dev_err(dev, "Re-trying adapter recovery\n");
 
 	return status;
 }
@@ -4962,10 +4998,8 @@ static void be_err_detection_task(struct work_struct *work)
 			status = be_err_recover(adapter);
 	}
 
-	/* In Lancer, for all errors other than provisioning error (-EAGAIN),
-	 * no need to attempt further recovery.
-	 */
-	if (!status || status == -EAGAIN)
+	/* Always attempt recovery on VFs */
+	if (!status || be_virtfn(adapter))
 		be_schedule_err_detection(adapter);
 }
 
@@ -5208,12 +5242,6 @@ static void be_remove(struct pci_dev *pdev)
 	free_netdev(adapter->netdev);
 }
 
-/* If any VFs are already enabled don't FLR the PF */
-static bool be_reset_required(struct be_adapter *adapter)
-{
-	return pci_num_vf(adapter->pdev) ? false : true;
-}
-
 static char *mc_name(struct be_adapter *adapter)
 {
 	char *str = "";	/* default */
@@ -5269,35 +5297,6 @@ static inline char *nic_name(struct pci_dev *pdev)
 	}
 }
 
-/* Wait for the FW to be ready and perform the required initialization */
-static int be_func_init(struct be_adapter *adapter)
-{
-	int status;
-
-	status = be_fw_wait_ready(adapter);
-	if (status)
-		return status;
-
-	if (be_reset_required(adapter)) {
-		status = be_cmd_reset_function(adapter);
-		if (status)
-			return status;
-
-		/* Wait for interrupts to quiesce after an FLR */
-		msleep(100);
-	}
-
-	/* Tell FW we're ready to fire cmds */
-	status = be_cmd_fw_init(adapter);
-	if (status)
-		return status;
-
-	/* Allow interrupts for other ULPs running on NIC function */
-	be_intr_set(adapter, true);
-
-	return 0;
-}
-
 static int be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
 {
 	struct be_adapter *adapter;
-- 
2.2.0
