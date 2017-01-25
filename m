From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net 2/5] ibmvnic: Fix MTU settings
Date: Wed, 25 Jan 2017 15:02:20 -0600
Message-ID: <1485378143-5084-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, wvoigt@us.ibm.com,
        nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48402 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751725AbdAYVCh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 16:02:37 -0500
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0PKwkcx086461
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 16:02:31 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2870eyf77v-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 16:02:31 -0500
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Wed, 25 Jan 2017 14:02:29 -0700
In-Reply-To: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current driver, the MTU is set to the maximum value
capable for the backing device. This patch sets the MTU to the
default value for a Linux net device. It also corrects a
discrepancy between MTU values received from firmware, which includes
the ethernet header length, and net device MTU values. Finally, it removes
redundant min/max MTU assignments after device initialization.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 48debde2..f95f6a4 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1496,7 +1496,7 @@ static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
 		adapter->req_rx_queues = adapter->opt_rx_comp_queues;
 		adapter->req_rx_add_queues = adapter->max_rx_add_queues;
 
-		adapter->req_mtu = adapter->max_mtu;
+		adapter->req_mtu = adapter->netdev->mtu + ETH_HLEN;
 	}
 
 	total_queues = adapter->req_tx_queues + adapter->req_rx_queues;
@@ -2626,12 +2626,12 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
 		break;
 	case MIN_MTU:
 		adapter->min_mtu = be64_to_cpu(crq->query_capability.number);
-		netdev->min_mtu = adapter->min_mtu;
+		netdev->min_mtu = adapter->min_mtu - ETH_HLEN;
 		netdev_dbg(netdev, "min_mtu = %lld\n", adapter->min_mtu);
 		break;
 	case MAX_MTU:
 		adapter->max_mtu = be64_to_cpu(crq->query_capability.number);
-		netdev->max_mtu = adapter->max_mtu;
+		netdev->max_mtu = adapter->max_mtu - ETH_HLEN;
 		netdev_dbg(netdev, "max_mtu = %lld\n", adapter->max_mtu);
 		break;
 	case MAX_MULTICAST_FILTERS:
@@ -3672,9 +3672,7 @@ static void handle_crq_init_rsp(struct work_struct *work)
 		goto task_failed;
 
 	netdev->real_num_tx_queues = adapter->req_tx_queues;
-	netdev->mtu = adapter->req_mtu;
-	netdev->min_mtu = adapter->min_mtu;
-	netdev->max_mtu = adapter->max_mtu;
+	netdev->mtu = adapter->req_mtu - ETH_HLEN;
 
 	if (adapter->failover) {
 		adapter->failover = false;
@@ -3814,7 +3812,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	}
 
 	netdev->real_num_tx_queues = adapter->req_tx_queues;
-	netdev->mtu = adapter->req_mtu;
+	netdev->mtu = adapter->req_mtu - ETH_HLEN;
 
 	rc = register_netdev(netdev);
 	if (rc) {
-- 
1.8.3.1
