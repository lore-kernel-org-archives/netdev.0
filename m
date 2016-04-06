From: John Allen <jallen@linux.vnet.ibm.com>
Subject: [PATCH net-next] ibmvnic: Enable use of multiple tx/rx scrqs
Date: Wed, 6 Apr 2016 11:49:55 -0500
Message-ID: <57053E33.6020706@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:35506 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbcDFQuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 12:50:11 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <jallen@linux.vnet.ibm.com>;
	Wed, 6 Apr 2016 10:50:10 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 9777A3E40030
	for <netdev@vger.kernel.org>; Wed,  6 Apr 2016 10:50:08 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u36Go8ZY18088110
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2016 09:50:08 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u36Go6Bv010752
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2016 10:50:08 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enables the use of multiple transmit and receive scrqs allowing the ibmvnic
driver to take advantage of multiqueue functionality. To achieve this, the
driver must implement the process of negotiating the maximum number of
queues allowed by the server. Initially, the driver will attempt to login
with the maximum number of tx and rx queues supported by the server. If
the server fails to allocate the requested number of scrqs, it will return
partial success in the login response. In this case, we must reinitiate
the login process from the request capabilities stage and attempt to login
requesting fewer scrqs.

Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
---
diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
index 21bccf6..6e9b91d 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.c
+++ b/drivers/net/ethernet/ibm/ibmvnic.c
@@ -800,11 +800,12 @@ static int ibmvnic_xmit(struct sk_buff *skb, struct net_device *netdev)
 			ret = NETDEV_TX_BUSY;
 			goto out;
 		}
-		lpar_rc = send_subcrq_indirect(adapter, handle_array[0],
+		lpar_rc = send_subcrq_indirect(adapter, handle_array[queue_num],
 					       (u64)tx_buff->indir_dma,
 					       (u64)num_entries);
 	} else {
-		lpar_rc = send_subcrq(adapter, handle_array[0], &tx_crq);
+		lpar_rc = send_subcrq(adapter, handle_array[queue_num],
+				      &tx_crq);
 	}
 	if (lpar_rc != H_SUCCESS) {
 		dev_err(dev, "tx failed with code %ld\n", lpar_rc);
@@ -989,7 +990,7 @@ restart_poll:
 		netdev->stats.rx_bytes += length;
 		frames_processed++;
 	}
-	replenish_pools(adapter);
+	replenish_rx_pool(adapter, &adapter->rx_pool[scrq_num]);

 	if (frames_processed < budget) {
 		enable_scrq_irq(adapter, adapter->rx_scrq[scrq_num]);
@@ -1426,9 +1427,9 @@ static void init_sub_crqs(struct ibmvnic_adapter *adapter, int retry)
 		    entries_page : adapter->max_rx_add_entries_per_subcrq;

 		/* Choosing the maximum number of queues supported by firmware*/
-		adapter->req_tx_queues = adapter->min_tx_queues;
-		adapter->req_rx_queues = adapter->min_rx_queues;
-		adapter->req_rx_add_queues = adapter->min_rx_add_queues;
+		adapter->req_tx_queues = adapter->max_tx_queues;
+		adapter->req_rx_queues = adapter->max_rx_queues;
+		adapter->req_rx_add_queues = adapter->max_rx_add_queues;

 		adapter->req_mtu = adapter->max_mtu;
 	}
@@ -1776,13 +1777,11 @@ static void send_login(struct ibmvnic_adapter *adapter)
 		goto buf_map_failed;
 	}

-	rsp_buffer_size =
-	    sizeof(struct ibmvnic_login_rsp_buffer) +
-	    sizeof(u64) * (adapter->req_tx_queues +
-			   adapter->req_rx_queues *
-			   adapter->req_rx_add_queues + adapter->
-			   req_rx_add_queues) +
-	    sizeof(u8) * (IBMVNIC_TX_DESC_VERSIONS);
+	rsp_buffer_size = sizeof(struct ibmvnic_login_rsp_buffer) +
+			  sizeof(u64) * adapter->req_tx_queues +
+			  sizeof(u64) * adapter->req_rx_queues +
+			  sizeof(u64) * adapter->req_rx_queues +
+			  sizeof(u8) * IBMVNIC_TX_DESC_VERSIONS;

 	login_rsp_buffer = kmalloc(rsp_buffer_size, GFP_ATOMIC);
 	if (!login_rsp_buffer)
@@ -2401,6 +2400,16 @@ static int handle_login_rsp(union ibmvnic_crq *login_rsp_crq,
 	dma_unmap_single(dev, adapter->login_rsp_buf_token,
 			 adapter->login_rsp_buf_sz, DMA_BIDIRECTIONAL);

+	/* If the number of queues requested can't be allocated by the
+	 * server, the login response will return with code 1. We will need
+	 * to resend the login buffer with fewer queues requested.
+	 */
+	if (login_rsp_crq->generic.rc.code) {
+		adapter->renegotiate = true;
+		complete(&adapter->init_done);
+		return 0;
+	}
+
 	netdev_dbg(adapter->netdev, "Login Response Buffer:\n");
 	for (i = 0; i < (adapter->login_rsp_buf_sz - 1) / 8 + 1; i++) {
 		netdev_dbg(adapter->netdev, "%016lx\n",
@@ -3627,15 +3636,22 @@ static int ibmvnic_probe(struct vio_dev *dev, const struct vio_device_id *id)

 	init_completion(&adapter->init_done);
 	wait_for_completion(&adapter->init_done);
+
+	do {
+		adapter->renegotiate = false;

-	/* needed to pull init_sub_crqs outside of an interrupt context
-	 * because it creates IRQ mappings for the subCRQ queues, causing
-	 * a kernel warning
-	 */
-	init_sub_crqs(adapter, 0);
+		init_sub_crqs(adapter, 0);
+		reinit_completion(&adapter->init_done);
+		wait_for_completion(&adapter->init_done);

-	reinit_completion(&adapter->init_done);
-	wait_for_completion(&adapter->init_done);
+		if (adapter->renegotiate) {
+			release_sub_crqs(adapter);
+			send_cap_queries(adapter);
+
+			reinit_completion(&adapter->init_done);
+			wait_for_completion(&adapter->init_done);
+		}
+	} while (adapter->renegotiate);

 	/* if init_sub_crqs is partially successful, retry */
 	while (!adapter->tx_scrq || !adapter->rx_scrq) {
diff --git a/drivers/net/ethernet/ibm/ibmvnic.h b/drivers/net/ethernet/ibm/ibmvnic.h
index 5af8a79..0b66a50 100644
--- a/drivers/net/ethernet/ibm/ibmvnic.h
+++ b/drivers/net/ethernet/ibm/ibmvnic.h
@@ -980,6 +980,7 @@ struct ibmvnic_adapter {
 	struct ibmvnic_sub_crq_queue **tx_scrq;
 	struct ibmvnic_sub_crq_queue **rx_scrq;
 	int requested_caps;
+	bool renegotiate;

 	/* rx structs */
 	struct napi_struct *napi;
