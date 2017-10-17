From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/3] ibmvnic: Enable TSO support
Date: Tue, 17 Oct 2017 12:36:55 -0500
Message-ID: <1508261816-3145-3-git-send-email-tlfalcon@linux.vnet.ibm.com>
References: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:49488 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1763541AbdJQRhR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 13:37:17 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9HHal7f141051
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:37:16 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dnjrwc8ub-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:37:16 -0400
Received: from localhost
        by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Tue, 17 Oct 2017 11:37:12 -0600
In-Reply-To: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables TSO support. It includes additional
buffers reserved exclusively for large packets. Throughput
is greatly increased with TSO enabled, from about 1 Gb/s to
9 Gb/s on our test systems.

Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmvnic.c | 56 ++++++++++++++++++++++++++++++++------
 drivers/net/ethernet/ibm/ibmvnic.h |  5 ++++
 2 files changed, 53 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index b508877..aedb81c 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -553,6 +553,10 @@ static int reset_tx_pools(struct ibmvnic_adapter *adapter)
 		if (rc)
 			return rc;
 
+		rc = reset_long_term_buff(adapter, &tx_pool->tso_ltb);
+		if (rc)
+			return rc;
+
 		memset(tx_pool->tx_buff, 0,
 		       adapter->req_tx_entries_per_subcrq *
 		       sizeof(struct ibmvnic_tx_buff));
@@ -562,6 +566,7 @@ static int reset_tx_pools(struct ibmvnic_adapter *adapter)
 
 		tx_pool->consumer_index = 0;
 		tx_pool->producer_index = 0;
+		tx_pool->tso_index = 0;
 	}
 
 	return 0;
@@ -581,6 +586,7 @@ static void release_tx_pools(struct ibmvnic_adapter *adapter)
 		tx_pool = &adapter->tx_pool[i];
 		kfree(tx_pool->tx_buff);
 		free_long_term_buff(adapter, &tx_pool->long_term_buff);
+		free_long_term_buff(adapter, &tx_pool->tso_ltb);
 		kfree(tx_pool->free_map);
 	}
 
@@ -625,6 +631,16 @@ static int init_tx_pools(struct net_device *netdev)
 			return -1;
 		}
 
+		/* alloc TSO ltb */
+		if (alloc_long_term_buff(adapter, &tx_pool->tso_ltb,
+					 IBMVNIC_TSO_BUFS *
+					 IBMVNIC_TSO_BUF_SZ)) {
+			release_tx_pools(adapter);
+			return -1;
+		}
+
+		tx_pool->tso_index = 0;
+
 		tx_pool->free_map = kcalloc(adapter->req_tx_entries_per_subcrq,
 					    sizeof(int), GFP_KERNEL);
 		if (!tx_pool->free_map) {
@@ -1201,10 +1217,21 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 		be32_to_cpu(adapter->login_rsp_buf->off_txsubm_subcrqs));
 
 	index = tx_pool->free_map[tx_pool->consumer_index];
-	offset = index * adapter->req_mtu;
-	dst = tx_pool->long_term_buff.buff + offset;
-	memset(dst, 0, adapter->req_mtu);
-	data_dma_addr = tx_pool->long_term_buff.addr + offset;
+
+	if (skb_is_gso(skb)) {
+		offset = tx_pool->tso_index * IBMVNIC_TSO_BUF_SZ;
+		dst = tx_pool->tso_ltb.buff + offset;
+		memset(dst, 0, IBMVNIC_TSO_BUF_SZ);
+		data_dma_addr = tx_pool->tso_ltb.addr + offset;
+		tx_pool->tso_index++;
+		if (tx_pool->tso_index == IBMVNIC_TSO_BUFS)
+			tx_pool->tso_index = 0;
+	} else {
+		offset = index * adapter->req_mtu;
+		dst = tx_pool->long_term_buff.buff + offset;
+		memset(dst, 0, adapter->req_mtu);
+		data_dma_addr = tx_pool->long_term_buff.addr + offset;
+	}
 
 	if (skb_shinfo(skb)->nr_frags) {
 		int cur, i;
@@ -1245,7 +1272,10 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	tx_crq.v1.n_sge = 1;
 	tx_crq.v1.flags1 = IBMVNIC_TX_COMP_NEEDED;
 	tx_crq.v1.correlator = cpu_to_be32(index);
-	tx_crq.v1.dma_reg = cpu_to_be16(tx_pool->long_term_buff.map_id);
+	if (skb_is_gso(skb))
+		tx_crq.v1.dma_reg = cpu_to_be16(tx_pool->tso_ltb.map_id);
+	else
+		tx_crq.v1.dma_reg = cpu_to_be16(tx_pool->long_term_buff.map_id);
 	tx_crq.v1.sge_len = cpu_to_be32(skb->len);
 	tx_crq.v1.ioba = cpu_to_be64(data_dma_addr);
 
@@ -1270,6 +1300,11 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 		tx_crq.v1.flags1 |= IBMVNIC_TX_CHKSUM_OFFLOAD;
 		hdrs += 2;
 	}
+	if (skb_is_gso(skb)) {
+		tx_crq.v1.flags1 |= IBMVNIC_TX_LSO;
+		tx_crq.v1.mss = cpu_to_be16(skb_shinfo(skb)->gso_size);
+		hdrs += 2;
+	}
 	/* determine if l2/3/4 headers are sent to firmware */
 	if ((*hdrs >> 7) & 1 &&
 	    (skb->protocol == htons(ETH_P_IP) ||
@@ -2960,10 +2995,10 @@ static void handle_query_ip_offload_rsp(struct ibmvnic_adapter *adapter)
 	adapter->ip_offload_ctrl.udp_ipv4_chksum = buf->udp_ipv4_chksum;
 	adapter->ip_offload_ctrl.tcp_ipv6_chksum = buf->tcp_ipv6_chksum;
 	adapter->ip_offload_ctrl.udp_ipv6_chksum = buf->udp_ipv6_chksum;
+	adapter->ip_offload_ctrl.large_tx_ipv4 = buf->large_tx_ipv4;
+	adapter->ip_offload_ctrl.large_tx_ipv6 = buf->large_tx_ipv6;
 
-	/* large_tx/rx disabled for now, additional features needed */
-	adapter->ip_offload_ctrl.large_tx_ipv4 = 0;
-	adapter->ip_offload_ctrl.large_tx_ipv6 = 0;
+	/* large_rx disabled for now, additional features needed */
 	adapter->ip_offload_ctrl.large_rx_ipv4 = 0;
 	adapter->ip_offload_ctrl.large_rx_ipv6 = 0;
 
@@ -2979,6 +3014,11 @@ static void handle_query_ip_offload_rsp(struct ibmvnic_adapter *adapter)
 	    (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)))
 		adapter->netdev->features |= NETIF_F_RXCSUM;
 
+	if (buf->large_tx_ipv4)
+		adapter->netdev->features |= NETIF_F_TSO;
+	if (buf->large_tx_ipv6)
+		adapter->netdev->features |= NETIF_F_TSO6;
+
 	memset(&crq, 0, sizeof(crq));
 	crq.control_ip_offload.first = IBMVNIC_CRQ_CMD;
 	crq.control_ip_offload.cmd = CONTROL_IP_OFFLOAD;
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index d02257c..7aa347a 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -39,6 +39,9 @@
 #define IBMVNIC_BUFFS_PER_POOL	100
 #define IBMVNIC_MAX_TX_QUEUES	5
 
+#define IBMVNIC_TSO_BUF_SZ	65536
+#define IBMVNIC_TSO_BUFS	64
+
 struct ibmvnic_login_buffer {
 	__be32 len;
 	__be32 version;
@@ -896,6 +899,8 @@ struct ibmvnic_tx_pool {
 	wait_queue_head_t ibmvnic_tx_comp_q;
 	struct task_struct *work_thread;
 	struct ibmvnic_long_term_buff long_term_buff;
+	struct ibmvnic_long_term_buff tso_ltb;
+	int tso_index;
 };
 
 struct ibmvnic_rx_buff {
-- 
1.8.3.1
