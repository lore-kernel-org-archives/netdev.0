From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/11] ibmvnic: Replace is_closed with state field
Date: Sat, 29 Apr 2017 04:15:39 -0400
Message-ID: <20170429081539.13438.65036.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170429080710.13438.39798.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46287 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752733AbdD2E0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 00:26:53 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3T4OLcb080805
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:26:52 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a4kqfr4u5-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 00:26:52 -0400
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Sat, 29 Apr 2017 00:26:51 -0400
In-Reply-To: <20170429080710.13438.39798.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the is_closed flag in the ibmvnic adapter strcut with a
more comprehensive state field that tracks the current state of
the driver.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   20 +++++++++++++-------
 drivers/net/ethernet/ibm/ibmvnic.h |   12 ++++++++++--
 2 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index c67f1d6..40a8ba0 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -669,7 +669,9 @@ static int ibmvnic_open(struct net_device *netdev)
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 	int i, rc;
 
-	if (adapter->is_closed) {
+	adapter->state = VNIC_OPENING;
+
+	if (adapter->state == VNIC_CLOSED) {
 		rc = ibmvnic_init(adapter);
 		if (rc)
 			return rc;
@@ -704,7 +706,7 @@ static int ibmvnic_open(struct net_device *netdev)
 		release_resources(adapter);
 	} else {
 		netif_tx_start_all_queues(netdev);
-		adapter->is_closed = false;
+		adapter->state = VNIC_OPEN;
 	}
 
 	return rc;
@@ -733,7 +735,7 @@ static int ibmvnic_close(struct net_device *netdev)
 	int rc = 0;
 	int i;
 
-	adapter->closing = true;
+	adapter->state = VNIC_CLOSING;
 	disable_sub_crqs(adapter);
 
 	if (adapter->napi) {
@@ -748,8 +750,7 @@ static int ibmvnic_close(struct net_device *netdev)
 
 	release_resources(adapter);
 
-	adapter->is_closed = true;
-	adapter->closing = false;
+	adapter->state = VNIC_CLOSED;
 	return rc;
 }
 
@@ -1860,7 +1861,8 @@ static int pending_scrq(struct ibmvnic_adapter *adapter,
 {
 	union sub_crq *entry = &scrq->msgs[scrq->cur];
 
-	if (entry->generic.first & IBMVNIC_CRQ_CMD_RSP || adapter->closing)
+	if (entry->generic.first & IBMVNIC_CRQ_CMD_RSP ||
+	    adapter->state == VNIC_CLOSING)
 		return 1;
 	else
 		return 0;
@@ -3353,6 +3355,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 		return -ENOMEM;
 
 	adapter = netdev_priv(netdev);
+	adapter->state = VNIC_PROBING;
 	dev_set_drvdata(&dev->dev, netdev);
 	adapter->vdev = dev;
 	adapter->netdev = netdev;
@@ -3380,7 +3383,6 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	}
 
 	netdev->mtu = adapter->req_mtu - ETH_HLEN;
-	adapter->is_closed = false;
 
 	rc = register_netdev(netdev);
 	if (rc) {
@@ -3390,6 +3392,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	}
 	dev_info(&dev->dev, "ibmvnic registered\n");
 
+	adapter->state = VNIC_PROBED;
 	return 0;
 }
 
@@ -3398,12 +3401,15 @@ static int ibmvnic_remove(struct vio_dev *dev)
 	struct net_device *netdev = dev_get_drvdata(&dev->dev);
 	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 
+	adapter->state = VNIC_REMOVING;
 	unregister_netdev(netdev);
 
 	release_resources(adapter);
 	release_sub_crqs(adapter);
 	release_crq_queue(adapter);
 
+	adapter->state = VNIC_REMOVED;
+
 	free_netdev(netdev);
 	dev_set_drvdata(&dev->dev, NULL);
 
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index a69979f..03a866f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -913,6 +913,15 @@ struct ibmvnic_error_buff {
 	__be32 error_id;
 };
 
+enum vnic_state {VNIC_PROBING = 1,
+		 VNIC_PROBED,
+		 VNIC_OPENING,
+		 VNIC_OPEN,
+		 VNIC_CLOSING,
+		 VNIC_CLOSED,
+		 VNIC_REMOVING,
+		 VNIC_REMOVED};
+
 struct ibmvnic_adapter {
 	struct vio_dev *vdev;
 	struct net_device *netdev;
@@ -962,7 +971,6 @@ struct ibmvnic_adapter {
 	u64 promisc;
 
 	struct ibmvnic_tx_pool *tx_pool;
-	bool closing;
 	struct completion init_done;
 	int init_done_rc;
 
@@ -1011,5 +1019,5 @@ struct ibmvnic_adapter {
 	struct work_struct ibmvnic_xport;
 	struct tasklet_struct tasklet;
 	bool failover;
-	bool is_closed;
+	enum vnic_state state;
 };
