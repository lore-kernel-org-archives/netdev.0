From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net] ibmvnic: Fix releasing of sub-CRQ IRQs in interrupt context
Date: Wed, 26 Oct 2016 13:57:38 -0500
Message-ID: <1477508258-13205-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46652 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751399AbcJZS6m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 14:58:42 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9QItCPA105654
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 14:57:44 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
        by mx0a-001b2d01.pphosted.com with ESMTP id 26avqrcu4a-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 14:57:43 -0400
Received: from localhost
        by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 26 Oct 2016 12:57:43 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
        by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 265DD1FF0025
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 12:57:20 -0600 (MDT)
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
        by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9QIvdiN12648796
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 11:57:39 -0700
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id C49366E040
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 12:57:39 -0600 (MDT)
Received: from tlfalcon-workstation.ibm.com (unknown [9.65.67.139])
        by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTP id 698E56E03D
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 12:57:39 -0600 (MDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Schedule these XPORT event tasks in the shared workqueue
so that IRQs are not freed in an interrupt context when
sub-CRQs are released.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 35 ++++++++++++++++++++++++-----------
 drivers/net/ethernet/ibm/ibmvnic.h |  1 +
 2 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index bfe17d9..4d227d7 100644
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
+	int rc;
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
@@ -3725,6 +3737,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
 	INIT_WORK(&adapter->vnic_crq_init, handle_crq_init_rsp);
+	INIT_WORK(&adapter->ibmvnic_xport, ibmvnic_xport_event);
 
 	spin_lock_init(&adapter->stats_lock);
 
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index bfc84c7..682057d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -1048,5 +1048,6 @@ struct ibmvnic_adapter {
 	u8 map_id;
 
 	struct work_struct vnic_crq_init;
+	struct work_struct ibmvnic_xport;
 	bool failover;
 };
-- 
1.8.3.1
