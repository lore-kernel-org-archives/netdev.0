From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/11] ibmvnic: Reset tx/rx pools on driver reset
Date: Fri, 26 May 2017 10:31:06 -0400
Message-ID: <20170526143106.63648.88664.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
References: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:45972 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1030533AbdEZOmv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:42:51 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QEdOqa085093
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:51 -0400
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2apknx7tvg-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:42:50 -0400
Received: from localhost
        by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:42:49 -0400
In-Reply-To: <20170526142523.63648.62938.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When resetting the ibmvnic driver there is not a need to release
and re-allocate the resources for the tx and rx pools. These
resources can just be reset to avoid the re-allocations.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c |   71 ++++++++++++++++++++++++++++++++++--
 1 file changed, 67 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index b9b0c69..5661a04 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -163,6 +163,16 @@ static long h_reg_sub_crq(unsigned long unit_address, unsigned long token,
 	return rc;
 }
 
+static void reset_long_term_buff(struct ibmvnic_adapter *adapter,
+				 struct ibmvnic_long_term_buff *ltb)
+{
+	memset(ltb->buff, 0, ltb->size);
+
+	init_completion(&adapter->fw_done);
+	send_request_map(adapter, ltb->addr, ltb->size, ltb->map_id);
+	wait_for_completion(&adapter->fw_done);
+}
+
 static int alloc_long_term_buff(struct ibmvnic_adapter *adapter,
 				struct ibmvnic_long_term_buff *ltb, int size)
 {
@@ -352,6 +362,32 @@ static int init_stats_token(struct ibmvnic_adapter *adapter)
 	return 0;
 }
 
+static int reset_rx_pools(struct ibmvnic_adapter *adapter)
+{
+	struct ibmvnic_rx_pool *rx_pool;
+	int rx_scrqs;
+	int i, j;
+
+	rx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_rxadd_subcrqs);
+	for (i = 0; i < rx_scrqs; i++) {
+		rx_pool = &adapter->rx_pool[i];
+
+		reset_long_term_buff(adapter, &rx_pool->long_term_buff);
+
+		for (j = 0; j < rx_pool->size; j++)
+			rx_pool->free_map[j] = j;
+
+		memset(rx_pool->rx_buff, 0,
+		       rx_pool->size * sizeof(struct ibmvnic_rx_buff));
+
+		atomic_set(&rx_pool->available, 0);
+		rx_pool->next_alloc = 0;
+		rx_pool->next_free = 0;
+	}
+
+	return 0;
+}
+
 static void release_rx_pools(struct ibmvnic_adapter *adapter)
 {
 	struct ibmvnic_rx_pool *rx_pool;
@@ -453,6 +489,32 @@ static int init_rx_pools(struct net_device *netdev)
 	return 0;
 }
 
+static int reset_tx_pools(struct ibmvnic_adapter *adapter)
+{
+	struct ibmvnic_tx_pool *tx_pool;
+	int tx_scrqs;
+	int i, j;
+
+	tx_scrqs = be32_to_cpu(adapter->login_rsp_buf->num_txsubm_subcrqs);
+	for (i = 0; i < tx_scrqs; i++) {
+		tx_pool = &adapter->tx_pool[i];
+
+		reset_long_term_buff(adapter, &tx_pool->long_term_buff);
+
+		memset(tx_pool->tx_buff, 0,
+		       adapter->req_tx_entries_per_subcrq *
+		       sizeof(struct ibmvnic_tx_buff));
+
+		for (j = 0; j < adapter->req_tx_entries_per_subcrq; j++)
+			tx_pool->free_map[j] = j;
+
+		tx_pool->consumer_index = 0;
+		tx_pool->producer_index = 0;
+	}
+
+	return 0;
+}
+
 static void release_tx_pools(struct ibmvnic_adapter *adapter)
 {
 	struct ibmvnic_tx_pool *tx_pool;
@@ -1258,7 +1320,6 @@ static int do_reset(struct ibmvnic_adapter *adapter,
 		 */
 		adapter->state = VNIC_PROBED;
 
-		release_resources(adapter);
 		release_sub_crqs(adapter);
 
 		rc = ibmvnic_init(adapter);
@@ -1277,9 +1338,11 @@ static int do_reset(struct ibmvnic_adapter *adapter,
 			return 0;
 		}
 
-		rtnl_lock();
-		rc = init_resources(adapter);
-		rtnl_unlock();
+		rc = reset_tx_pools(adapter);
+		if (rc)
+			return rc;
+
+		rc = reset_rx_pools(adapter);
 		if (rc)
 			return rc;
 
