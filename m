From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 07/10] ibmvnic: Correct crq and resource releasing
Date: Wed, 19 Apr 2017 13:45:04 -0400
Message-ID: <20170419174504.37372.71081.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60833 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934630AbdDSN4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:56:13 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3JDrfUM126926
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:56:08 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29x752xg7f-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 09:56:07 -0400
Received: from localhost
        by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 19 Apr 2017 09:56:06 -0400
In-Reply-To: <20170419174015.37372.48544.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not be releasing the crq's when calling close for the
adapter, these need to remain open to facilitate operations such
as updating the mac address. The crq's should be released in the
adpaters remove routine.

Additionally, we need to call release_reources from remove. This
corrects the scenario of trying to remove an adapter that has only
been probed.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 18673e2..a8b3c57 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -601,9 +601,6 @@ static void release_resources(struct ibmvnic_adapter *adapter)
 	release_tx_pools(adapter);
 	release_rx_pools(adapter);
 
-	release_sub_crqs(adapter);
-	release_crq_queue(adapter);
-
 	release_stats_token(adapter);
 	release_error_buffers(adapter);
 }
@@ -3300,8 +3297,14 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 static int ibmvnic_remove(struct vio_dev *dev)
 {
 	struct net_device *netdev = dev_get_drvdata(&dev->dev);
+	struct ibmvnic_adapter *adapter = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
+
+	release_resources(adapter);
+	release_sub_crqs(adapter);
+	release_crq_queue(adapter);
+
 	free_netdev(netdev);
 	dev_set_drvdata(&dev->dev, NULL);
 
