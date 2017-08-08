From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Clean up resources on probe failure
Date: Tue, 08 Aug 2017 14:28:45 -0500
Message-ID: <20170808192845.17535.99639.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:41818 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752261AbdHHOlz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 10:41:55 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78EdUxH093598
        for <netdev@vger.kernel.org>; Tue, 8 Aug 2017 10:41:55 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c7evh25ta-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 10:41:54 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 8 Aug 2017 10:41:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that any resources allocated during probe are released if the
probe of the driver fails.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 5932160..24f536b 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3827,31 +3827,35 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 
 	do {
 		rc = ibmvnic_init(adapter);
-		if (rc && rc != EAGAIN) {
-			free_netdev(netdev);
-			return rc;
-		}
+		if (rc && rc != EAGAIN)
+			goto ibmvnic_init_fail;
 	} while (rc == EAGAIN);
 
 	netdev->mtu = adapter->req_mtu - ETH_HLEN;
 
 	rc = device_create_file(&dev->dev, &dev_attr_failover);
-	if (rc) {
-		free_netdev(netdev);
-		return rc;
-	}
+	if (rc)
+		goto ibmvnic_init_fail;
 
 	rc = register_netdev(netdev);
 	if (rc) {
 		dev_err(&dev->dev, "failed to register netdev rc=%d\n", rc);
-		device_remove_file(&dev->dev, &dev_attr_failover);
-		free_netdev(netdev);
-		return rc;
+		goto ibmvnic_register_fail;
 	}
 	dev_info(&dev->dev, "ibmvnic registered\n");
 
 	adapter->state = VNIC_PROBED;
 	return 0;
+
+ibmvnic_register_fail:
+	device_remove_file(&dev->dev, &dev_attr_failover);
+	
+ibmvnic_init_fail:
+	release_sub_crqs(adapter);
+	release_crq_queue(adapter);
+	free_netdev(netdev);
+
+	return rc;
 }
 
 static int ibmvnic_remove(struct vio_dev *dev)
