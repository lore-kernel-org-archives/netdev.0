From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 7/7] ibmvnic: Free skb's in cases of failure in
 transmit
Date: Fri, 21 Apr 2017 15:39:16 -0400
Message-ID: <20170421193916.11030.78879.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
References: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49953 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1041432AbdDUS1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:27:37 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3LFmiRp020570
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:50:21 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29ygy25mdj-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:50:20 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 21 Apr 2017 11:50:20 -0400
In-Reply-To: <20170421193627.11030.34813.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

When an error is encountered during transmit we need to free the
skb instead of returning TX_BUSY.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 5a916a2..51bf337 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -908,9 +908,13 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 				   be32_to_cpu(adapter->login_rsp_buf->
 					       off_txsubm_subcrqs));
 	if (adapter->migrated) {
+		if (!netif_subqueue_stopped(netdev, skb))
+			netif_stop_subqueue(netdev, queue_num);
+		dev_kfree_skb_any(skb);
+
 		tx_send_failed++;
 		tx_dropped++;
-		ret = NETDEV_TX_BUSY;
+		ret = NETDEV_TX_OK;
 		goto out;
 	}
 
@@ -976,11 +980,13 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 						    sizeof(tx_buff->indir_arr),
 						    DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, tx_buff->indir_dma)) {
+			dev_kfree_skb_any(skb);
+			tx_buff->skb = NULL;
 			if (!firmware_has_feature(FW_FEATURE_CMO))
 				dev_err(dev, "tx: unable to map descriptor array\n");
 			tx_map_failed++;
 			tx_dropped++;
-			ret = NETDEV_TX_BUSY;
+			ret = NETDEV_TX_OK;
 			goto out;
 		}
 		lpar_rc = send_subcrq_indirect(adapter, handle_array[queue_num],
@@ -999,9 +1005,15 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 		else
 			tx_pool->consumer_index--;
 
+		dev_kfree_skb_any(skb);
+		tx_buff->skb = NULL;
+
+		if (lpar_rc == H_CLOSED)
+			netif_stop_subqueue(netdev, queue_num);
+
 		tx_send_failed++;
 		tx_dropped++;
-		ret = NETDEV_TX_BUSY;
+		ret = NETDEV_TX_OK;
 		goto out;
 	}
 
