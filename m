From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/4] ibmvnic: Implement per-queue statistics
 reporting
Date: Wed, 2 Aug 2017 16:44:14 -0500
Message-ID: <66ba714b-aed5-d4cd-7db7-00bdfad63b60@linux.vnet.ibm.com>
References: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        Nathan Fontenot <nfont@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:41743 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751166AbdHBVoU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 17:44:20 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v72LcsuS108315
        for <netdev@vger.kernel.org>; Wed, 2 Aug 2017 17:44:20 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c3mbqy8nj-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 17:44:20 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
        Wed, 2 Aug 2017 17:44:19 -0400
In-Reply-To: <f89ddaab-fe27-2b3c-5b3a-3aaac1e60ae3@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add counters to report number of packets, bytes, and dropped packets for
each transmit queue and number of packets, bytes, and interrupts for each
receive queue. Modify ethtool callbacks to report the new statistics.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index a3e694679635..a264c6992328 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -346,6 +346,31 @@ static void replenish_pools(struct ibmvnic_adapter *adapter)
 	}
 }

+static void release_stats_buffers(struct ibmvnic_adapter *adapter)
+{
+	kfree(adapter->tx_stats_buffers);
+	kfree(adapter->rx_stats_buffers);
+}
+
+static int init_stats_buffers(struct ibmvnic_adapter *adapter)
+{
+	adapter->tx_stats_buffers =
+				kcalloc(adapter->req_tx_queues,
+					sizeof(struct ibmvnic_tx_queue_stats),
+					GFP_KERNEL);
+	if (!adapter->tx_stats_buffers)
+		return -ENOMEM;
+
+	adapter->rx_stats_buffers =
+				kcalloc(adapter->req_rx_queues,
+					sizeof(struct ibmvnic_rx_queue_stats),
+					GFP_KERNEL);
+	if (!adapter->rx_stats_buffers)
+		return -ENOMEM;
+
+	return 0;
+}
+
 static void release_stats_token(struct ibmvnic_adapter *adapter)
 {
 	struct device *dev = &adapter->vdev->dev;
@@ -686,6 +711,7 @@ static void release_resources(struct ibmvnic_adapter *adapter)
 	release_rx_pools(adapter);

 	release_stats_token(adapter);
+	release_stats_buffers(adapter);
 	release_error_buffers(adapter);

 	if (adapter->napi) {
@@ -763,6 +789,10 @@ static int init_resources(struct ibmvnic_adapter *adapter)
 	if (rc)
 		return rc;

+	rc = init_stats_buffers(adapter);
+	if (rc)
+		return rc;
+
 	rc = init_stats_token(adapter);
 	if (rc)
 		return rc;
@@ -1245,6 +1275,9 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 	netdev->stats.tx_packets += tx_packets;
 	adapter->tx_send_failed += tx_send_failed;
 	adapter->tx_map_failed += tx_map_failed;
+	adapter->tx_stats_buffers[queue_num].packets += tx_packets;
+	adapter->tx_stats_buffers[queue_num].bytes += tx_bytes;
+	adapter->tx_stats_buffers[queue_num].dropped_packets += tx_dropped;

 	return ret;
 }
@@ -1585,6 +1618,8 @@ static int ibmvnic_poll(struct napi_struct *napi, int budget)
 		napi_gro_receive(napi, skb); /* send it up */
 		netdev->stats.rx_packets++;
 		netdev->stats.rx_bytes += length;
+		adapter->rx_stats_buffers[scrq_num].packets++;
+		adapter->rx_stats_buffers[scrq_num].bytes += length;
 		frames_processed++;
 	}

@@ -1706,6 +1741,7 @@ static void ibmvnic_get_ringparam(struct net_device *netdev,

 static void ibmvnic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
+	struct ibmvnic_adapter *adapter = netdev_priv(dev);
 	int i;

 	if (stringset != ETH_SS_STATS)
@@ -1713,13 +1749,39 @@ static void ibmvnic_get_strings(struct net_device *dev, u32 stringset, u8 *data)

 	for (i = 0; i < ARRAY_SIZE(ibmvnic_stats); i++, data += ETH_GSTRING_LEN)
 		memcpy(data, ibmvnic_stats[i].name, ETH_GSTRING_LEN);
+
+	for (i = 0; i < adapter->req_tx_queues; i++) {
+		snprintf(data, ETH_GSTRING_LEN, "tx%d_packets", i);
+		data += ETH_GSTRING_LEN;
+
+		snprintf(data, ETH_GSTRING_LEN, "tx%d_bytes", i);
+		data += ETH_GSTRING_LEN;
+
+		snprintf(data, ETH_GSTRING_LEN, "tx%d_dropped_packets", i);
+		data += ETH_GSTRING_LEN;
+	}
+
+	for (i = 0; i < adapter->req_rx_queues; i++) {
+		snprintf(data, ETH_GSTRING_LEN, "rx%d_packets", i);
+		data += ETH_GSTRING_LEN;
+
+		snprintf(data, ETH_GSTRING_LEN, "rx%d_bytes", i);
+		data += ETH_GSTRING_LEN;
+
+		snprintf(data, ETH_GSTRING_LEN, "rx%d_interrupts", i);
+		data += ETH_GSTRING_LEN;
+	}
 }

 static int ibmvnic_get_sset_count(struct net_device *dev, int sset)
 {
+	struct ibmvnic_adapter *adapter = netdev_priv(dev);
+
 	switch (sset) {
 	case ETH_SS_STATS:
-		return ARRAY_SIZE(ibmvnic_stats);
+		return ARRAY_SIZE(ibmvnic_stats) +
+		       adapter->req_tx_queues * NUM_TX_STATS +
+		       adapter->req_rx_queues * NUM_RX_STATS;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1730,7 +1792,7 @@ static void ibmvnic_get_ethtool_stats(struct net_device *dev,
 {
 	struct ibmvnic_adapter *adapter = netdev_priv(dev);
 	union ibmvnic_crq crq;
-	int i;
+	int i, j;

 	memset(&crq, 0, sizeof(crq));
 	crq.request_statistics.first = IBMVNIC_CRQ_CMD;
@@ -1746,6 +1808,24 @@ static void ibmvnic_get_ethtool_stats(struct net_device *dev,

 	for (i = 0; i < ARRAY_SIZE(ibmvnic_stats); i++)
 		data[i] = IBMVNIC_GET_STAT(adapter, ibmvnic_stats[i].offset);
+
+	for (j = 0; j < adapter->req_tx_queues; j++) {
+		data[i] = adapter->tx_stats_buffers[j].packets;
+		i++;
+		data[i] = adapter->tx_stats_buffers[j].bytes;
+		i++;
+		data[i] = adapter->tx_stats_buffers[j].dropped_packets;
+		i++;
+	}
+
+	for (j = 0; j < adapter->req_rx_queues; j++) {
+		data[i] = adapter->rx_stats_buffers[j].packets;
+		i++;
+		data[i] = adapter->rx_stats_buffers[j].bytes;
+		i++;
+		data[i] = adapter->rx_stats_buffers[j].interrupts;
+		i++;
+	}
 }

 static const struct ethtool_ops ibmvnic_ethtool_ops = {
@@ -2050,6 +2130,8 @@ static irqreturn_t ibmvnic_interrupt_rx(int irq, void *instance)
 	struct ibmvnic_sub_crq_queue *scrq = instance;
 	struct ibmvnic_adapter *adapter = scrq->adapter;

+	adapter->rx_stats_buffers[scrq->scrq_num].interrupts++;
+
 	if (napi_schedule_prep(&adapter->napi[scrq->scrq_num])) {
 		disable_scrq_irq(adapter, scrq);
 		__napi_schedule(&adapter->napi[scrq->scrq_num]);
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 8eff6e15f4bb..d02257ccc377 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -166,6 +166,20 @@ struct ibmvnic_statistics {
 	u8 reserved[72];
 } __packed __aligned(8);

+#define NUM_TX_STATS 3
+struct ibmvnic_tx_queue_stats {
+	u64 packets;
+	u64 bytes;
+	u64 dropped_packets;
+};
+
+#define NUM_RX_STATS 3
+struct ibmvnic_rx_queue_stats {
+	u64 packets;
+	u64 bytes;
+	u64 interrupts;
+};
+
 struct ibmvnic_acl_buffer {
 	__be32 len;
 	__be32 version;
@@ -956,6 +970,9 @@ struct ibmvnic_adapter {
 	int tx_send_failed;
 	int tx_map_failed;

+	struct ibmvnic_tx_queue_stats *tx_stats_buffers;
+	struct ibmvnic_rx_queue_stats *rx_stats_buffers;
+
 	int phys_link_state;
 	int logical_link_state;
