From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 1/5] netxen: cleanup rx handling
Date: Mon,  9 Mar 2009 11:50:52 -0700
Message-ID: <1236624656-2082-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:43662 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754192AbZCISvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 14:51:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o remove unused rx fragment handling code.
o imporove check for status descriptor ownership.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   16 +-------
 drivers/net/netxen/netxen_nic_init.c |   71 +++++----------------------------
 2 files changed, 13 insertions(+), 74 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index ce2b391..92a0c77 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -392,11 +392,8 @@ struct rcv_desc {
 #define STATUS_CKSUM_OK		(2)
 
 /* owner bits of status_desc */
-#define STATUS_OWNER_HOST	(0x1)
-#define STATUS_OWNER_PHANTOM	(0x2)
-
-#define NETXEN_PROT_IP		(1)
-#define NETXEN_PROT_UNKNOWN	(0)
+#define STATUS_OWNER_HOST	(0x1ULL << 56)
+#define STATUS_OWNER_PHANTOM	(0x2ULL << 56)
 
 /* Note: sizeof(status_desc) should always be a mutliple of 2 */
 
@@ -422,15 +419,6 @@ struct rcv_desc {
 #define netxen_get_sts_opcode(sts_data)	\
 	(((sts_data) >> 58) & 0x03F)
 
-#define netxen_get_sts_owner(status_desc)	\
-	((le64_to_cpu((status_desc)->status_desc_data) >> 56) & 0x03)
-#define netxen_set_sts_owner(status_desc, val)	{ \
-	(status_desc)->status_desc_data = \
-		((status_desc)->status_desc_data & \
-		~cpu_to_le64(0x3ULL << 56)) | \
-		cpu_to_le64((u64)((val) & 0x3) << 56); \
-}
-
 struct status_desc {
 	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
 	   28-43 reference_handle, 44-47 protocol, 48-52 pkt_offset
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index f323cee..f816434 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -838,13 +838,8 @@ no_skb:
 	return skb;
 }
 
-/*
- * netxen_process_rcv() send the received packet to the protocol stack.
- * and if the number of receives exceeds RX_BUFFERS_REFILL, then we
- * invoke the routine to send more rx buffers to the Phantom...
- */
 static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
-		struct status_desc *desc, struct status_desc *frag_desc)
+		struct status_desc *desc)
 {
 	struct net_device *netdev = adapter->netdev;
 	u64 sts_data = le64_to_cpu(desc->status_desc_data);
@@ -859,15 +854,11 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 
 	desc_ctx = netxen_get_sts_type(sts_data);
 	if (unlikely(desc_ctx >= NUM_RCV_DESC_RINGS)) {
-		printk("%s: %s Bad Rcv descriptor ring\n",
-		       netxen_nic_driver_name, netdev->name);
 		return;
 	}
 
 	rds_ring = &recv_ctx->rds_rings[desc_ctx];
 	if (unlikely(index > rds_ring->max_rx_desc_count)) {
-		DPRINTK(ERR, "Got a buffer index:%x Max is %x\n",
-			index, rds_ring->max_rx_desc_count);
 		return;
 	}
 	buffer = &rds_ring->rx_buf_arr[index];
@@ -879,14 +870,6 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 			buffer->lro_length = length;
 		}
 		if (buffer->lro_current_frags != buffer->lro_expected_frags) {
-			if (buffer->lro_expected_frags != 0) {
-				printk("LRO: (refhandle:%x) recv frag. "
-				       "wait for last. flags: %x expected:%d "
-				       "have:%d\n", index,
-				       netxen_get_sts_desc_lro_last_frag(desc),
-				       buffer->lro_expected_frags,
-				       buffer->lro_current_frags);
-			}
 			return;
 		}
 	}
@@ -913,28 +896,10 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
-	/*
-	 * rx buffer chaining is disabled, walk and free
-	 * any spurious rx buffer chain.
-	 */
-	if (frag_desc) {
-		u16 i, nr_frags = desc->nr_frags;
-
-		dev_kfree_skb_any(skb);
-		for (i = 0; i < nr_frags; i++) {
-			index = le16_to_cpu(frag_desc->frag_handles[i]);
-			skb = netxen_process_rxbuf(adapter,
-					rds_ring, index, cksum);
-			if (skb)
-				dev_kfree_skb_any(skb);
-		}
-		adapter->stats.rxdropped++;
-	} else {
-		netif_receive_skb(skb);
+	netif_receive_skb(skb);
 
-		adapter->stats.no_rcv++;
-		adapter->stats.rxbytes += length;
-	}
+	adapter->stats.no_rcv++;
+	adapter->stats.rxbytes += length;
 }
 
 /* Process Receive status ring */
@@ -942,7 +907,7 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 {
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
 	struct status_desc *desc_head = recv_ctx->rcv_status_desc_head;
-	struct status_desc *desc, *frag_desc;
+	struct status_desc *desc;
 	u32 consumer = recv_ctx->status_rx_consumer;
 	int count = 0, ring;
 	u64 sts_data;
@@ -950,41 +915,27 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 
 	while (count < max) {
 		desc = &desc_head[consumer];
-		if (!(netxen_get_sts_owner(desc) & STATUS_OWNER_HOST)) {
-			DPRINTK(ERR, "desc %p ownedby %x\n", desc,
-				netxen_get_sts_owner(desc));
+		sts_data = le64_to_cpu(desc->status_desc_data);
+
+		if (!(sts_data & STATUS_OWNER_HOST))
 			break;
-		}
 
-		sts_data = le64_to_cpu(desc->status_desc_data);
 		opcode = netxen_get_sts_opcode(sts_data);
-		frag_desc = NULL;
-		if (opcode == NETXEN_NIC_RXPKT_DESC) {
-			if (desc->nr_frags) {
-				consumer = get_next_index(consumer,
-						adapter->max_rx_desc_count);
-				frag_desc = &desc_head[consumer];
-				netxen_set_sts_owner(frag_desc,
-						STATUS_OWNER_PHANTOM);
-			}
-		}
 
-		netxen_process_rcv(adapter, ctxid, desc, frag_desc);
+		netxen_process_rcv(adapter, ctxid, desc);
 
-		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
+		desc->status_desc_data = cpu_to_le64(STATUS_OWNER_PHANTOM);
 
 		consumer = get_next_index(consumer,
 				adapter->max_rx_desc_count);
 		count++;
 	}
+
 	for (ring = 0; ring < adapter->max_rds_rings; ring++)
 		netxen_post_rx_buffers_nodb(adapter, ctxid, ring);
 
-	/* update the consumer index in phantom */
 	if (count) {
 		recv_ctx->status_rx_consumer = consumer;
-
-		/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
 				recv_ctx->crb_sts_consumer, consumer);
 	}
-- 
1.6.0.2

