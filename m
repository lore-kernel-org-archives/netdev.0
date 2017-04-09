From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/7] ibmvnic: Add is_up flag to avoid transmits
 when driver is down
Date: Sun, 09 Apr 2017 00:11:32 -0400
Message-ID: <20170409041132.47642.81315.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170409040328.47642.33535.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com, muvic@linux.vnet.ibm.com
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:38169 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751125AbdDIEWW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 00:22:22 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v394Ik18172721
        for <netdev@vger.kernel.org>; Sun, 9 Apr 2017 00:22:22 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29qa365f64-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 09 Apr 2017 00:22:21 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Sun, 9 Apr 2017 00:22:21 -0400
In-Reply-To: <20170409040328.47642.33535.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

There are brief windows when handling events such as failover where we
could attempt to transmit packets between receiving the transport event
notification and handling the reset in the workqueue.

This patch introduces an is_up flag so we can avoid transmit attempts at
these times.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   16 ++++++++++------
 drivers/net/ethernet/ibm/ibmvnic.h |    1 +
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 7ba43cf..2722f07 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -664,6 +664,7 @@ static int ibmvnic_open(struct net_device *netdev)
 
 	netif_tx_start_all_queues(netdev);
 	adapter->is_closed = false;
+	adapter->is_up = true;
 
 	return 0;
 
@@ -857,18 +858,19 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	int index = 0;
 	int ret = 0;
 
+	if (adapter->migrated || !adapter->is_up) {
+		tx_send_failed++;
+		tx_dropped++;
+		ret = NETDEV_TX_BUSY;
+		goto out;
+	}
+
 	tx_pool = &adapter->tx_pool[queue_num];
 	tx_scrq = adapter->tx_scrq[queue_num];
 	txq = netdev_get_tx_queue(netdev, skb_get_queue_mapping(skb));
 	handle_array = (u64 *)((u8 *)(adapter->login_rsp_buf) +
 				   be32_to_cpu(adapter->login_rsp_buf->
 					       off_txsubm_subcrqs));
-	if (adapter->migrated) {
-		tx_send_failed++;
-		tx_dropped++;
-		ret = NETDEV_TX_BUSY;
-		goto out;
-	}
 
 	index = tx_pool->free_map[tx_pool->consumer_index];
 	offset = index * adapter->req_mtu;
@@ -2913,11 +2915,13 @@ static void ibmvnic_handle_crq(union ibmvnic_crq *crq,
 		if (gen_crq->cmd == IBMVNIC_PARTITION_MIGRATED) {
 			dev_info(dev, "Re-enabling adapter\n");
 			adapter->migrated = true;
+			adapter->is_up = false;
 			schedule_work(&adapter->ibmvnic_xport);
 		} else if (gen_crq->cmd == IBMVNIC_DEVICE_FAILOVER) {
 			dev_info(dev, "Backing device failover detected\n");
 			netif_carrier_off(netdev);
 			adapter->failover = true;
+			adapter->is_up = false;
 		} else {
 			/* The adapter lost the connection */
 			dev_err(dev, "Virtual Adapter failed (rc=%d)\n",
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index b0d0b89..0a8f9a0 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -1022,4 +1022,5 @@ struct ibmvnic_adapter {
 	struct tasklet_struct tasklet;
 	bool failover;
 	bool is_closed;
+	bool is_up;
 };
