From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net v2 1/2] ibmvnic: Fix releasing of sub-CRQ IRQs in interrupt context
Date: Thu, 27 Oct 2016 12:28:51 -0500
Message-ID: <1477589332-513-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:46914 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934046AbcJ0R26 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 13:28:58 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9RHSg4F138051
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 13:28:58 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
        by mx0b-001b2d01.pphosted.com with ESMTP id 26bnk0a43r-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 13:28:57 -0400
Received: from localhost
        by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 27 Oct 2016 11:28:57 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
        by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9541719D803F
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 11:28:18 -0600 (MDT)
Received: from b03ledav006.gho.boulder.ibm.com (b03ledav006.gho.boulder.ibm.com [9.17.130.237])
        by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9RHSrx47864640
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 10:28:53 -0700
Received: from b03ledav006.gho.boulder.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 23742C6037
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 11:28:52 -0600 (MDT)
Received: from tlfalcon-workstation.ibm.com (unknown [9.65.84.52])
        by b03ledav006.gho.boulder.ibm.com (Postfix) with ESMTP id C28CCC603E
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 11:28:51 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Schedule these XPORT event tasks in the shared workqueue
so that IRQs are not freed in an interrupt context when
sub-CRQs are released.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
v2: correct warnings by kbuild bot
---
 drivers/net/ethernet/ibm/ibmvnic.c | 35 ++++++++++++++++++++++++-----------
 drivers/net/ethernet/ibm/ibmvnic.h |  1 +
 2 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 213162d..a922fb9 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -3232,6 +3232,27 @@ static void ibmvnic_free_inflight(struct ibmvnic_adapter *adapter)
 	spin_unlock_irqrestore(&adapter->inflight_lock, flags);
 }
 
+static void ibmvnic_xport_event(struct work_struct *work)
+{
+	struct ibmvnic_adapter *adapter = container_of(work,
+						       struct ibmvnic_adapter,
+						       ibmvnic_xport);
+	struct device *dev = &adapter->vdev->dev;
+	long rc;
+
+	ibmvnic_free_inflight(adapter);
+	release_sub_crqs(adapter);
+	if (adapter->migrated) {
+		rc = ibmvnic_reenable_crq_queue(adapter);
+		if (rc)
+			dev_err(dev, "Error after enable rc=%ld\n", rc);
+		adapter->migrated = false;
+		rc = ibmvnic_send_crq_init(adapter);
+		if (rc)
+			dev_err(dev, "Error sending init rc=%ld\n", rc);
+	}
+}
+
 static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 			       struct ibmvnic_adapter *adapter)
 {
@@ -3267,15 +3288,7 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 		if (gen_crq->cmd == IBMVNIC_PARTITION_MIGRATED) {
 			dev_info(dev, "Re-enabling adapter\n");
 			adapter->migrated = true;
-			ibmvnic_free_inflight(adapter);
-			release_sub_crqs(adapter);
-			rc = ibmvnic_reenable_crq_queue(adapter);
-			if (rc)
-				dev_err(dev, "Error after enable rc=%ld\n", rc);
-			adapter->migrated = false;
-			rc = ibmvnic_send_crq_init(adapter);
-			if (rc)
-				dev_err(dev, "Error sending init rc=%ld\n", rc);
+			schedule_work(&adapter->ibmvnic_xport);
 		} else if (gen_crq->cmd == IBMVNIC_DEVICE_FAILOVER) {
 			dev_info(dev, "Backing device failover detected\n");
 			netif_carrier_off(netdev);
@@ -3284,8 +3297,7 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 			/* The adapter lost the connection */
 			dev_err(dev, "Virtual Adapter failed (rc=%d)\n",
 				gen_crq->cmd);
-			ibmvnic_free_inflight(adapter);
-			release_sub_crqs(adapter);
+			schedule_work(&adapter->ibmvnic_xport);
 		}
 		return;
 	case IBMVNIC_CRQ_CMD_RSP:
@@ -3726,6 +3738,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
 	INIT_WORK(&adapter->vnic_crq_init, handle_crq_init_rsp);
+	INIT_WORK(&adapter->ibmvnic_xport, ibmvnic_xport_event);
 
 	spin_lock_init(&adapter->stats_lock);
 
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 878e2c0..dd775d9 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -1048,5 +1048,6 @@ struct ibmvnic_adapter {
 	u8 map_id;
 
 	struct work_struct vnic_crq_init;
+	struct work_struct ibmvnic_xport;
 	bool failover;
 };
-- 
2.7.4
