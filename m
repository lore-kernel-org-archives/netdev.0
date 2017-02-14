From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net v2] ibmvnic: Fix initial MTU settings
Date: Tue, 14 Feb 2017 10:22:59 -0600
Message-ID: <1487089379-29498-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: nfont@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:56416 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753676AbdBNQXG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 11:23:06 -0500
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1EGKGKi064578
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 11:23:05 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
        by mx0b-001b2d01.pphosted.com with ESMTP id 28m188kug5-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 11:23:05 -0500
Received: from localhost
        by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Tue, 14 Feb 2017 09:23:04 -0700
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
        by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 5BA3F19D8040
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 09:22:15 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current driver, the MTU is set to the maximum value
capable for the backing device. This decision turned out to
be a mistake as it led to confusion among users. The expected
initial MTU value used for other IBM vNIC capable operating
systems is 1500, with the maximum value (9000) reserved for
when Jumbo frames are enabled. This patch sets the MTU to
the default value for a net device.

It also corrects a discrepancy between MTU values received from
firmware, which includes the ethernet header length, and net
device MTU values.

Finally, it removes redundant min/max MTU assignments after device
initialization.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
v2: included more detailed commit message addressing why
    this patch is needed
---
 drivers/net/ethernet/ibm/ibmvnic.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 752b082..5b66b4f 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -1497,7 +1497,7 @@ static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
 		adapter->req_rx_queues = adapter->opt_rx_comp_queues;
 		adapter->req_rx_add_queues = adapter->max_rx_add_queues;
 
-		adapter->req_mtu = adapter->max_mtu;
+		adapter->req_mtu = adapter->netdev->mtu + ETH_HLEN;
 	}
 
 	total_queues = adapter->req_tx_queues + adapter->req_rx_queues;
@@ -2627,12 +2627,12 @@ static void handle_query_cap_rsp(union ibmvnic_crq *crq,
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
@@ -3657,9 +3657,7 @@ static void handle_crq_init_rsp(struct work_struct *work)
 		goto task_failed;
 
 	netdev->real_num_tx_queues = adapter->req_tx_queues;
-	netdev->mtu = adapter->req_mtu;
-	netdev->min_mtu = adapter->min_mtu;
-	netdev->max_mtu = adapter->max_mtu;
+	netdev->mtu = adapter->req_mtu - ETH_HLEN;
 
 	if (adapter->failover) {
 		adapter->failover = false;
@@ -3799,7 +3797,7 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)
 	}
 
 	netdev->real_num_tx_queues = adapter->req_tx_queues;
-	netdev->mtu = adapter->req_mtu;
+	netdev->mtu = adapter->req_mtu - ETH_HLEN;
 
 	rc = register_netdev(netdev);
 	if (rc) {
-- 
2.7.4
