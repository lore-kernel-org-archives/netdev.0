From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 1/4] netxen: fix race in tx ring acccess
Date: Tue,  5 May 2009 22:05:06 -0700
Message-ID: <1241586309-12112-2-git-send-email-dhananjay@netxen.com>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:59283 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751120AbZEFFFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 01:05:12 -0400
In-Reply-To: <1241586309-12112-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the distance check between tx ring producer and consumer that
could lead to tx ring wrap around.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c   |    4 ++--
 drivers/net/netxen/netxen_nic_init.c |    8 ++++----
 drivers/net/netxen/netxen_nic_main.c |    3 ++-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 9f5ced3..23c974a 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -526,7 +526,7 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 	producer = tx_ring->producer;
 	consumer = tx_ring->sw_consumer;
 
-	if (nr_desc > find_diff_among(producer, consumer, tx_ring->num_desc)) {
+	if (nr_desc >= find_diff_among(producer, consumer, tx_ring->num_desc)) {
 		netif_tx_unlock_bh(adapter->netdev);
 		return -EBUSY;
 	}
@@ -752,7 +752,7 @@ int netxen_linkevent_request(struct netxen_adapter *adapter, int enable)
 
 	word = NX_NIC_H2C_OPCODE_GET_LINKEVENT | ((u64)adapter->portnum << 16);
 	req.req_hdr = cpu_to_le64(word);
-	req.words[0] = cpu_to_le64(enable);
+	req.words[0] = cpu_to_le64(enable | (enable << 8));
 
 	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 	if (rv != 0) {
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index d182167..de9ebbd 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1319,10 +1319,11 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 			break;
 	}
 
-	if (count) {
-		tx_ring->sw_consumer = sw_consumer;
+	tx_ring->sw_consumer = sw_consumer;
+
+	if (count && netif_running(netdev)) {
 		smp_mb();
-		if (netif_queue_stopped(netdev) && netif_running(netdev)) {
+		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev)) {
 			netif_tx_lock(netdev);
 			netif_wake_queue(netdev);
 			smp_mb();
@@ -1450,7 +1451,6 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 		rds_ring->producer = producer;
 		NXWR32(adapter, rds_ring->crb_rcv_producer,
 				(producer - 1) & (rds_ring->num_desc - 1));
-			wmb();
 	}
 	spin_unlock(&rds_ring->lock);
 }
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 5d79c19..6a496b1 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -809,6 +809,7 @@ netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
+	smp_mb();
 	netxen_napi_disable(adapter);
 
 	if (adapter->stop_port)
@@ -1340,7 +1341,7 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	producer = tx_ring->producer;
 	smp_mb();
 	consumer = tx_ring->sw_consumer;
-	if ((no_of_desc+2) > find_diff_among(producer, consumer, num_txd)) {
+	if ((no_of_desc+2) >= find_diff_among(producer, consumer, num_txd)) {
 		netif_stop_queue(netdev);
 		smp_mb();
 		return NETDEV_TX_BUSY;
-- 
1.6.0.2

