From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Track state of adapter napis
Date: Fri, 5 May 2017 11:31:58 -0500
Message-ID: <47c6bbb6-faa0-b07b-871f-10e804b2152d@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        brking@linux.vnet.ibm.com, muvic@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:45303 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750734AbdEEQcD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 12:32:03 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v45GO7FS091552
        for <netdev@vger.kernel.org>; Fri, 5 May 2017 12:32:03 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a8nedfk1g-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 12:32:03 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Fri, 5 May 2017 12:32:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Track the state of ibmvnic napis. The driver can get into states where it
can be reset when napis are already disabled and attempting to disable them
again will cause the driver to hang.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 4f2d329..594ee6d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -675,8 +675,12 @@ static int __ibmvnic_open(struct net_device *netdev)
 	adapter->state = VNIC_OPENING;
 	replenish_pools(adapter);

-	for (i = 0; i < adapter->req_rx_queues; i++)
-		napi_enable(&adapter->napi[i]);
+	if (adapter->napi_disabled) {
+		for (i = 0; i < adapter->req_rx_queues; i++)
+			napi_enable(&adapter->napi[i]);
+
+		adapter->napi_disabled = false;
+	}

 	/* We're ready to receive frames, enable the sub-crq interrupts and
 	 * set the logical link state to up
@@ -780,9 +784,11 @@ static int __ibmvnic_close(struct net_device *netdev)
 	adapter->state = VNIC_CLOSING;
 	netif_tx_stop_all_queues(netdev);

-	if (adapter->napi) {
+	if (!adapter->napi_disabled) {
 		for (i = 0; i < adapter->req_rx_queues; i++)
 			napi_disable(&adapter->napi[i]);
+
+		adapter->napi_disabled = true;
 	}

 	clean_tx_pools(adapter);
@@ -3540,6 +3546,9 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 		free_netdev(netdev);
 		return rc;
 	}
+
+	adapter->napi_disabled = true;
+
 	dev_info(&dev->dev, "ibmvnic registered\n");

 	adapter->state = VNIC_PROBED;
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 4702b48..12b2400 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -1031,4 +1031,5 @@ struct ibmvnic_adapter {
 	struct list_head rwi_list;
 	struct work_struct ibmvnic_reset;
 	bool resetting;
+	bool napi_disabled;
 };
