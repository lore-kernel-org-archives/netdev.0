From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/7] ibmvnic: Only retrieve error info if present
Date: Fri, 21 Apr 2017 15:38:52 -0400
Message-ID: <20170421193852.11030.51923.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50691 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1162474AbdDUUjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 16:39:51 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3LFmk51139271
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:49:57 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29ycjdrgpx-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:49:57 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 21 Apr 2017 11:49:57 -0400
In-Reply-To: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When handling a fatal error in the driver, there can be additional
error information provided by the vios. This information is not
always present, so only retrieve the additional error information
when present.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   71 ++++++++++++++++++++++++++----------
 1 file changed, 51 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 0f359543..cc34bf9 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -2361,25 +2361,22 @@ static void handle_error_info_rsp(union ibmvnic_crq *crq,
 	kfree(error_buff);
 }
 
-static void handle_error_indication(union ibmvnic_crq *crq,
-				    struct ibmvnic_adapter *adapter)
+static void request_error_information(struct ibmvnic_adapter *adapter,
+				      union ibmvnic_crq *err_crq)
 {
-	int detail_len = be32_to_cpu(crq->error_indication.detail_error_sz);
 	struct device *dev = &adapter->vdev->dev;
+	struct net_device *netdev = adapter->netdev;
 	struct ibmvnic_error_buff *error_buff;
-	union ibmvnic_crq new_crq;
+	unsigned long timeout = msecs_to_jiffies(30000);
+	union ibmvnic_crq crq;
 	unsigned long flags;
-
-	dev_err(dev, "Firmware reports %serror id %x, cause %d\n",
-		crq->error_indication.
-		    flags & IBMVNIC_FATAL_ERROR ? "FATAL " : "",
-		be32_to_cpu(crq->error_indication.error_id),
-		be16_to_cpu(crq->error_indication.error_cause));
+	int rc, detail_len;
 
 	error_buff = kmalloc(sizeof(*error_buff), GFP_ATOMIC);
 	if (!error_buff)
 		return;
 
+	detail_len = be32_to_cpu(err_crq->error_indication.detail_error_sz);
 	error_buff->buff = kmalloc(detail_len, GFP_ATOMIC);
 	if (!error_buff->buff) {
 		kfree(error_buff);
@@ -2389,27 +2386,61 @@ static void handle_error_indication(union ibmvnic_crq *crq,
 	error_buff->dma = dma_map_single(dev, error_buff->buff, detail_len,
 					 DMA_FROM_DEVICE);
 	if (dma_mapping_error(dev, error_buff->dma)) {
-		if (!firmware_has_feature(FW_FEATURE_CMO))
-			dev_err(dev, "Couldn't map error buffer\n");
+		netdev_err(netdev, "Couldn't map error buffer\n");
 		kfree(error_buff->buff);
 		kfree(error_buff);
 		return;
 	}
 
 	error_buff->len = detail_len;
-	error_buff->error_id = crq->error_indication.error_id;
+	error_buff->error_id = err_crq->error_indication.error_id;
 
 	spin_lock_irqsave(&adapter->error_list_lock, flags);
 	list_add_tail(&error_buff->list, &adapter->errors);
 	spin_unlock_irqrestore(&adapter->error_list_lock, flags);
 
-	memset(&new_crq, 0, sizeof(new_crq));
-	new_crq.request_error_info.first = IBMVNIC_CRQ_CMD;
-	new_crq.request_error_info.cmd = REQUEST_ERROR_INFO;
-	new_crq.request_error_info.ioba = cpu_to_be32(error_buff->dma);
-	new_crq.request_error_info.len = cpu_to_be32(detail_len);
-	new_crq.request_error_info.error_id = crq->error_indication.error_id;
-	ibmvnic_send_crq(adapter, &new_crq);
+	memset(&crq, 0, sizeof(crq));
+	crq.request_error_info.first = IBMVNIC_CRQ_CMD;
+	crq.request_error_info.cmd = REQUEST_ERROR_INFO;
+	crq.request_error_info.ioba = cpu_to_be32(error_buff->dma);
+	crq.request_error_info.len = cpu_to_be32(detail_len);
+	crq.request_error_info.error_id = err_crq->error_indication.error_id;
+
+	rc = ibmvnic_send_crq(adapter, &crq);
+	if (rc) {
+		netdev_err(netdev, "failed to request error information\n");
+		goto err_info_fail;
+	}
+
+	if (!wait_for_completion_timeout(&adapter->init_done, timeout)) {
+		netdev_err(netdev, "timeout waiting for error information\n");
+		goto err_info_fail;
+	}
+
+	return;
+
+err_info_fail:
+	spin_lock_irqsave(&adapter->error_list_lock, flags);
+	list_del(&error_buff->list);
+	spin_unlock_irqrestore(&adapter->error_list_lock, flags);
+
+	kfree(error_buff->buff);
+	kfree(error_buff);
+}
+
+static void handle_error_indication(union ibmvnic_crq *crq,
+				    struct ibmvnic_adapter *adapter)
+{
+	struct device *dev = &adapter->vdev->dev;
+
+	dev_err(dev, "Firmware reports %serror id %x, cause %d\n",
+		crq->error_indication.flags
+			& IBMVNIC_FATAL_ERROR ? "FATAL " : "",
+		be32_to_cpu(crq->error_indication.error_id),
+		be16_to_cpu(crq->error_indication.error_cause));
+
+	if (be32_to_cpu(crq->error_indication.error_id))
+		request_error_information(adapter, crq);
 }
 
 static void handle_change_mac_rsp(union ibmvnic_crq *crq,
