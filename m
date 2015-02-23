From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 5/9] be2net: refactor error detect/recovery function
Date: Mon, 23 Feb 2015 04:20:12 -0500
Message-ID: <1424683216-29611-6-git-send-email-sathya.perla@emulex.com>
References: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:32982 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbbBWJRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:17:17 -0500
In-Reply-To: <1424683216-29611-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Currently when an error is detected, the queue resources are being cleaned up
in the recovery routine. The resources are better cleaned up in the error
detection routine itself (similar to EEH code.)
So, this patch re-factors error processing logic to follow the following sequence:
	- check if there is an error in adapter
	- if error,
		- cleanup resources
		- attempt recovery

The patch renames lancer_recover_func() to be_err_recover() as this
routine will be used in the future for error recovery on Skyhawk too.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 31 ++++++++++++++++-------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 74ba995..034ce70 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2844,12 +2844,12 @@ void be_detect_error(struct be_adapter *adapter)
 			sliport_err2 = ioread32(adapter->db +
 						SLIPORT_ERROR2_OFFSET);
 			adapter->hw_error = true;
+			error_detected = true;
 			/* Do not log error messages if its a FW reset */
 			if (sliport_err1 == SLIPORT_ERROR_FW_RESET1 &&
 			    sliport_err2 == SLIPORT_ERROR_FW_RESET2) {
 				dev_info(dev, "Firmware update in progress\n");
 			} else {
-				error_detected = true;
 				dev_err(dev, "Error detected in the card\n");
 				dev_err(dev, "ERR: sliport status 0x%x\n",
 					sliport_status);
@@ -4903,8 +4903,9 @@ static void be_netdev_init(struct net_device *netdev)
 	netdev->ethtool_ops = &be_ethtool_ops;
 }
 
-static int lancer_recover_func(struct be_adapter *adapter)
+static int be_err_recover(struct be_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	struct device *dev = &adapter->pdev->dev;
 	int status;
 
@@ -4912,23 +4913,20 @@ static int lancer_recover_func(struct be_adapter *adapter)
 	if (status)
 		goto err;
 
-	if (netif_running(adapter->netdev))
-		be_close(adapter->netdev);
-
-	be_clear(adapter);
-
 	be_clear_all_error(adapter);
 
 	status = be_setup(adapter);
 	if (status)
 		goto err;
 
-	if (netif_running(adapter->netdev)) {
-		status = be_open(adapter->netdev);
+	if (netif_running(netdev)) {
+		status = be_open(netdev);
 		if (status)
 			goto err;
 	}
 
+	netif_device_attach(netdev);
+
 	dev_err(dev, "Adapter recovery successful\n");
 	return 0;
 err:
@@ -4945,18 +4943,23 @@ static void be_err_detection_task(struct work_struct *work)
 	struct be_adapter *adapter =
 				container_of(work, struct be_adapter,
 					     be_err_detection_work.work);
+	struct net_device *netdev = adapter->netdev;
 	int status = 0;
 
 	be_detect_error(adapter);
 
-	if (adapter->hw_error && lancer_chip(adapter)) {
+	if (adapter->hw_error) {
 		rtnl_lock();
-		netif_device_detach(adapter->netdev);
+		netif_device_detach(netdev);
+		if (netif_running(netdev))
+			be_close(netdev);
 		rtnl_unlock();
 
-		status = lancer_recover_func(adapter);
-		if (!status)
-			netif_device_attach(adapter->netdev);
+		be_clear(adapter);
+
+		/* As of now error recovery support is in Lancer only */
+		if (lancer_chip(adapter))
+			status = be_err_recover(adapter);
 	}
 
 	/* In Lancer, for all errors other than provisioning error (-EAGAIN),
-- 
2.2.0
