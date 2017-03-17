From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net 3/4] ibmvnic: Move ibmvnic adapter intialization to its own routine
Date: Fri, 17 Mar 2017 17:13:42 -0500
Message-ID: <1489788823-20980-4-git-send-email-jallen@linux.vnet.ibm.com>
References: <1489788823-20980-1-git-send-email-jallen@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:36368 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751096AbdCRC3S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 22:29:18 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2HMBkRA147088
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:14:08 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0b-001b2d01.pphosted.com with ESMTP id 298dgewcj3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 18:14:08 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Fri, 17 Mar 2017 18:14:07 -0400
In-Reply-To: <1489788823-20980-1-git-send-email-jallen@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intialization of the ibmvnic driver with respect to the virtual
server it connects to should be moved to its own routine. This will
alolow the driver to initiate this process from places outside of
the drivers probe routine.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 110 ++++++++++++++++++++-----------------
 1 file changed, 60 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index b6606d8..f8cc572 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3785,14 +3785,65 @@ static void handle_crq_init_rsp(struct work_struct *work)
 	dev_err(dev, "Passive initialization was not successful\n");
 }
 
-static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
+static int ibmvnic_init(struct ibmvnic_adapter *adapter)
 {
+	struct device *dev = &adapter->vdev->dev;
 	unsigned long timeout = msecs_to_jiffies(30000);
+	struct dentry *ent;
+	char buf[17]; /* debugfs name buf */
+	int rc;
+
+	rc = ibmvnic_init_crq_queue(adapter);
+	if (rc) {
+		dev_err(dev, "Couldn't initialize crq. rc=%d\n", rc);
+		return rc;
+	}
+
+	adapter->stats_token = dma_map_single(dev, &adapter->stats,
+				      sizeof(struct ibmvnic_statistics),
+				      DMA_FROM_DEVICE);
+	if (dma_mapping_error(dev, adapter->stats_token)) {
+		ibmvnic_release_crq_queue(adapter);
+		dev_err(dev, "Couldn't map stats buffer\n");
+		return -ENOMEM;
+	}
+
+	snprintf(buf, sizeof(buf), "ibmvnic_%x", adapter->vdev->unit_address);
+	ent = debugfs_create_dir(buf, NULL);
+	if (!ent || IS_ERR(ent)) {
+		dev_info(dev, "debugfs create directory failed\n");
+		adapter->debugfs_dir = NULL;
+	} else {
+		adapter->debugfs_dir = ent;
+		ent = debugfs_create_file("dump", S_IRUGO,
+					  adapter->debugfs_dir,
+					  adapter->netdev, &ibmvnic_dump_ops);
+		if (!ent || IS_ERR(ent)) {
+			dev_info(dev, "debugfs create dump file failed\n");
+			adapter->debugfs_dump = NULL;
+		} else {
+			adapter->debugfs_dump = ent;
+		}
+	}
+
+	init_completion(&adapter->init_done);
+	ibmvnic_send_crq_init(adapter);
+	if (!wait_for_completion_timeout(&adapter->init_done, timeout)) {
+		dev_err(dev, "Initialization sequence timed out\n");
+		if (adapter->debugfs_dir && !IS_ERR(adapter->debugfs_dir))
+			debugfs_remove_recursive(adapter->debugfs_dir);
+		ibmvnic_release_crq_queue(adapter);
+		return -1;
+	}
+
+	return 0;
+}
+
+static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
+{
 	struct ibmvnic_adapter *adapter;
 	struct net_device *netdev;
 	unsigned char *mac_addr_p;
-	struct dentry *ent;
-	char buf[17]; /* debugfs name buf */
 	int rc;
 
 	dev_dbg(&dev->dev, "entering ibmvnic_probe for UA 0x%x\n",
@@ -3830,69 +3881,28 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 
 	spin_lock_init(&adapter->stats_lock);
 
-	rc = ibmvnic_init_crq_queue(adapter);
-	if (rc) {
-		dev_err(&dev->dev, "Couldn't initialize crq. rc=%d\n", rc);
-		goto free_netdev;
-	}
-
 	INIT_LIST_HEAD(&adapter->errors);
 	INIT_LIST_HEAD(&adapter->inflight);
 	spin_lock_init(&adapter->error_list_lock);
 	spin_lock_init(&adapter->inflight_lock);
 
-	adapter->stats_token = dma_map_single(&dev->dev, &adapter->stats,
-					      sizeof(struct ibmvnic_statistics),
-					      DMA_FROM_DEVICE);
-	if (dma_mapping_error(&dev->dev, adapter->stats_token)) {
-		if (!firmware_has_feature(FW_FEATURE_CMO))
-			dev_err(&dev->dev, "Couldn't map stats buffer\n");
-		rc = -ENOMEM;
-		goto free_crq;
-	}
-
-	snprintf(buf, sizeof(buf), "ibmvnic_%x", dev->unit_address);
-	ent = debugfs_create_dir(buf, NULL);
-	if (!ent || IS_ERR(ent)) {
-		dev_info(&dev->dev, "debugfs create directory failed\n");
-		adapter->debugfs_dir = NULL;
-	} else {
-		adapter->debugfs_dir = ent;
-		ent = debugfs_create_file("dump", S_IRUGO, adapter->debugfs_dir,
-					  netdev, &ibmvnic_dump_ops);
-		if (!ent || IS_ERR(ent)) {
-			dev_info(&dev->dev,
-				 "debugfs create dump file failed\n");
-			adapter->debugfs_dump = NULL;
-		} else {
-			adapter->debugfs_dump = ent;
-		}
+	rc = ibmvnic_init(adapter);
+	if (rc) {
+		free_netdev(netdev);
+		return rc;
 	}
 
-	init_completion(&adapter->init_done);
-	ibmvnic_send_crq_init(adapter);
-	if (!wait_for_completion_timeout(&adapter->init_done, timeout))
-		return 0;
-
 	netdev->mtu = adapter->req_mtu - ETH_HLEN;
 
 	rc = register_netdev(netdev);
 	if (rc) {
 		dev_err(&dev->dev, "failed to register netdev rc=%d\n", rc);
-		goto free_debugfs;
+		free_netdev(netdev);
+		return rc;
 	}
 	dev_info(&dev->dev, "ibmvnic registered\n");
 
 	return 0;
-
-free_debugfs:
-	if (adapter->debugfs_dir && !IS_ERR(adapter->debugfs_dir))
-		debugfs_remove_recursive(adapter->debugfs_dir);
-free_crq:
-	ibmvnic_release_crq_queue(adapter);
-free_netdev:
-	free_netdev(netdev);
-	return rc;
 }
 
 static int ibmvnic_remove(struct vio_dev *dev)
-- 
2.7.4
