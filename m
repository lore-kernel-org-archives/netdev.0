From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net v2 4/4] ibmvnic: Fix passive VNIC server login process
Date: Fri,  8 Jul 2016 02:09:06 -0500
Message-ID: <1467961746-26023-5-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1467961746-26023-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: jallen@linux.vnet.ibm.com, nfont@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57655 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753777AbcGHHJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 03:09:20 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u68794Jb144689
	for <netdev@vger.kernel.org>; Fri, 8 Jul 2016 03:09:19 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2415xn20qp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 03:09:19 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Fri, 8 Jul 2016 01:09:18 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7D71219D8045
	for <netdev@vger.kernel.org>; Fri,  8 Jul 2016 01:08:53 -0600 (MDT)
In-Reply-To: <1467961746-26023-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases, if there is no VNIC server available during the driver
probe, the driver should wait until it receives an initialization
request from the VNIC Server to start the login process. Recent testing
has show that this is incorrectly handled in the current driver.

The proposed solution handles this initialization request by scheduling
a task in the shared workqueue that completes the login process and
registers the net device.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 59 ++++++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/ibm/ibmvnic.h |  2 ++
 2 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 3f13e83..222d56a 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -75,6 +75,7 @@
 #include <linux/uaccess.h>
 #include <asm/firmware.h>
 #include <linux/seq_file.h>
+#include <linux/workqueue.h>
 
 #include "ibmvnic.h"
 
@@ -3253,8 +3254,8 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 			dev_info(dev, "Partner initialized\n");
 			/* Send back a response */
 			rc = ibmvnic_send_crq_init_complete(adapter);
-			if (rc == 0)
-				send_version_xchg(adapter);
+			if (!rc)
+				schedule_work(&adapter->vnic_crq_init);
 			else
 				dev_err(dev, "Can't send initrsp rc=%ld\n", rc);
 			break;
@@ -3606,6 +3607,58 @@ static const struct file_operations ibmvnic_dump_ops = {
 	.release        = single_release,
 };
 
+static void handle_crq_init_rsp(struct work_struct *work)
+{
+	struct ibmvnic_adapter *adapter = container_of(work,
+						       struct ibmvnic_adapter,
+						       vnic_crq_init);
+	struct device *dev = &adapter->vdev->dev;
+	struct net_device *netdev = adapter->netdev;
+	unsigned long timeout = msecs_to_jiffies(30000);
+	int rc;
+
+	send_version_xchg(adapter);
+	reinit_completion(&adapter->init_done);
+	if (!wait_for_completion_timeout(&adapter->init_done, timeout)) {
+		dev_err(dev, "Passive init timeout\n");
+		goto task_failed;
+	}
+
+	while (adapter->renegotiate) {
+		adapter->renegotiate = false;
+		release_sub_crqs_no_irqs(adapter);
+		send_cap_queries(adapter);
+
+		reinit_completion(&adapter->init_done);
+		if (!wait_for_completion_timeout(&adapter->init_done,
+						 timeout)) {
+			dev_err(dev, "Passive init timeout\n");
+			goto task_failed;
+		}
+	}
+
+	rc = init_sub_crq_irqs(adapter);
+	if (rc)
+		goto task_failed;
+
+	netdev->real_num_tx_queues = adapter->req_tx_queues;
+
+	rc = register_netdev(netdev);
+	if (rc) {
+		dev_err(dev,
+			"failed to register netdev rc=%d\n", rc);
+		goto register_failed;
+	}
+	dev_info(dev, "ibmvnic registered\n");
+
+	return;
+
+register_failed:
+	release_sub_crqs(adapter);
+task_failed:
+	dev_err(dev, "Passive initialization was not successful\n");
+}
+
 static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 {
 	unsigned long timeout = msecs_to_jiffies(30000);
@@ -3645,6 +3698,8 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	netdev->ethtool_ops = &ibmvnic_ethtool_ops;
 	SET_NETDEV_DEV(netdev, &dev->dev);
 
+	INIT_WORK(&adapter->vnic_crq_init, handle_crq_init_rsp);
+
 	spin_lock_init(&adapter->stats_lock);
 
 	rc = ibmvnic_init_crq_queue(adapter);
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 0b66a50..e82898f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -1045,4 +1045,6 @@ struct ibmvnic_adapter {
 	u64 opt_rxba_entries_per_subcrq;
 	__be64 tx_rx_desc_req;
 	u8 map_id;
+
+	struct work_struct vnic_crq_init;
 };
-- 
1.8.3.1
