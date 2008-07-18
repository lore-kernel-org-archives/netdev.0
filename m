From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCHv2 09/11] netxen: cut-through rx changes
Date: Fri, 18 Jul 2008 16:44:07 -0700
Message-ID: <1216424649-4597-10-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:55558 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756912AbYGRXoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 19:44:12 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NX3031 supports cut-through operation where ingress packets are
directly dma'ed into host buffers to reduce latency.

This requires larger dma buffers (2kb) and different alignemnt.

The buffer posting logic is changed a bit. The free rx buffers
are maintained in linked list, since the received reference
handles can be out of order. However rx descriptors are still
posted sequentially, indexed by producer.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   38 +++++--
 drivers/net/netxen/netxen_nic_init.c |  191 +++++++++++++++++++++++-----------
 drivers/net/netxen/netxen_nic_main.c |   15 ++--
 3 files changed, 166 insertions(+), 78 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e41f623..705fdf1 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -140,6 +140,7 @@
 #define NX_RX_NORMAL_BUF_MAX_LEN       (NX_MAX_ETHERHDR + NX_ETHERMTU)
 #define NX_P2_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P2_MAX_MTU)
 #define NX_P3_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P3_MAX_MTU)
+#define NX_CT_DEFAULT_RX_BUF_LEN	2048
 
 #define MAX_RX_BUFFER_LENGTH		1760
 #define MAX_RX_JUMBO_BUFFER_LENGTH 	8062
@@ -391,8 +392,8 @@ struct rcv_desc {
 };
 
 /* opcode field in status_desc */
-#define RCV_NIC_PKT	(0xA)
-#define STATUS_NIC_PKT	((RCV_NIC_PKT) << 12)
+#define NETXEN_NIC_RXPKT_DESC  0x04
+#define NETXEN_OLD_RXPKT_DESC  0x3f
 
 /* for status field in status_desc */
 #define STATUS_NEED_CKSUM	(1)
@@ -424,6 +425,8 @@ struct rcv_desc {
 	(((sts_data) >> 28) & 0xFFFF)
 #define netxen_get_sts_prot(sts_data)	\
 	(((sts_data) >> 44) & 0x0F)
+#define netxen_get_sts_pkt_offset(sts_data)	\
+	(((sts_data) >> 48) & 0x1F)
 #define netxen_get_sts_opcode(sts_data)	\
 	(((sts_data) >> 58) & 0x03F)
 
@@ -438,17 +441,30 @@ struct rcv_desc {
 
 struct status_desc {
 	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-27 total_length
-	   28-43 reference_handle, 44-47 protocol, 48-52 unused
+	   28-43 reference_handle, 44-47 protocol, 48-52 pkt_offset
 	   53-55 desc_cnt, 56-57 owner, 58-63 opcode
 	 */
 	__le64 status_desc_data;
-	__le32 hash_value;
-	u8 hash_type;
-	u8 msg_type;
-	u8 unused;
-	/* Bit pattern: 0-6 lro_count indicates frag sequence,
-	   7 last_frag indicates last frag */
-	u8 lro;
+	union {
+		struct {
+			__le32 hash_value;
+			u8 hash_type;
+			u8 msg_type;
+			u8 unused;
+			union {
+				/* Bit pattern: 0-6 lro_count indicates frag
+				 * sequence, 7 last_frag indicates last frag
+				 */
+				u8 lro;
+
+				/* chained buffers */
+				u8 nr_frags;
+			};
+		};
+		struct {
+			__le16 frag_handles[4];
+		};
+	};
 } __attribute__ ((aligned(16)));
 
 enum {
@@ -774,6 +790,7 @@ struct netxen_cmd_buffer {
 
 /* In rx_buffer, we do not need multiple fragments as is a single buffer */
 struct netxen_rx_buffer {
+	struct list_head list;
 	struct sk_buff *skb;
 	u64 dma;
 	u16 ref_handle;
@@ -854,6 +871,7 @@ struct nx_host_rds_ring {
 	u32 dma_size;
 	u32 skb_size;
 	struct netxen_rx_buffer *rx_buf_arr;	/* rx buffers for receive   */
+	struct list_head free_list;
 	int begin_alloc;
 };
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 7b51240..01ab31b 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -262,17 +262,30 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 				rds_ring->max_rx_desc_count =
 					adapter->max_rx_desc_count;
 				rds_ring->flags = RCV_DESC_NORMAL;
-				rds_ring->dma_size = RX_DMA_MAP_LEN;
-				rds_ring->skb_size = MAX_RX_BUFFER_LENGTH;
+				if (adapter->ahw.cut_through) {
+					rds_ring->dma_size =
+						NX_CT_DEFAULT_RX_BUF_LEN;
+					rds_ring->skb_size =
+						NX_CT_DEFAULT_RX_BUF_LEN;
+				} else {
+					rds_ring->dma_size = RX_DMA_MAP_LEN;
+					rds_ring->skb_size =
+						MAX_RX_BUFFER_LENGTH;
+				}
 				break;
 
 			case RCV_DESC_JUMBO:
 				rds_ring->max_rx_desc_count =
 					adapter->max_jumbo_rx_desc_count;
 				rds_ring->flags = RCV_DESC_JUMBO;
-				rds_ring->dma_size = RX_JUMBO_DMA_MAP_LEN;
+				if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+					rds_ring->dma_size =
+						NX_P3_RX_JUMBO_BUF_MAX_LEN;
+				else
+					rds_ring->dma_size =
+						NX_P2_RX_JUMBO_BUF_MAX_LEN;
 				rds_ring->skb_size =
-					MAX_RX_JUMBO_BUFFER_LENGTH;
+					rds_ring->dma_size + NET_IP_ALIGN;
 				break;
 
 			case RCV_RING_LRO:
@@ -294,6 +307,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 				goto err_out;
 			}
 			memset(rds_ring->rx_buf_arr, 0, RCV_BUFFSIZE);
+			INIT_LIST_HEAD(&rds_ring->free_list);
 			rds_ring->begin_alloc = 0;
 			/*
 			 * Now go through all of them, set reference handles
@@ -302,6 +316,8 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			num_rx_bufs = rds_ring->max_rx_desc_count;
 			rx_buf = rds_ring->rx_buf_arr;
 			for (i = 0; i < num_rx_bufs; i++) {
+				list_add_tail(&rx_buf->list,
+						&rds_ring->free_list);
 				rx_buf->ref_handle = i;
 				rx_buf->state = NETXEN_BUFFER_FREE;
 				rx_buf++;
@@ -1137,15 +1153,47 @@ int netxen_receive_peg_ready(struct netxen_adapter *adapter)
 	return 0;
 }
 
+static struct sk_buff *netxen_process_rxbuf(struct netxen_adapter *adapter,
+		struct nx_host_rds_ring *rds_ring, u16 index, u16 cksum)
+{
+	struct netxen_rx_buffer *buffer;
+	struct sk_buff *skb;
+
+	buffer = &rds_ring->rx_buf_arr[index];
+
+	pci_unmap_single(adapter->pdev, buffer->dma, rds_ring->dma_size,
+			PCI_DMA_FROMDEVICE);
+
+	skb = buffer->skb;
+	if (!skb)
+		goto no_skb;
+
+	if (likely(adapter->rx_csum && cksum == STATUS_CKSUM_OK)) {
+		adapter->stats.csummed++;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	} else
+		skb->ip_summed = CHECKSUM_NONE;
+
+	skb->dev = adapter->netdev;
+
+	buffer->skb = NULL;
+
+no_skb:
+	buffer->state = NETXEN_BUFFER_FREE;
+	buffer->lro_current_frags = 0;
+	buffer->lro_expected_frags = 0;
+	list_add_tail(&buffer->list, &rds_ring->free_list);
+	return skb;
+}
+
 /*
  * netxen_process_rcv() send the received packet to the protocol stack.
  * and if the number of receives exceeds RX_BUFFERS_REFILL, then we
  * invoke the routine to send more rx buffers to the Phantom...
  */
 static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
-			       struct status_desc *desc)
+		struct status_desc *desc, struct status_desc *frag_desc)
 {
-	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev = adapter->netdev;
 	u64 sts_data = le64_to_cpu(desc->status_desc_data);
 	int index = netxen_get_sts_refhandle(sts_data);
@@ -1154,8 +1202,8 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	struct sk_buff *skb;
 	u32 length = netxen_get_sts_totallength(sts_data);
 	u32 desc_ctx;
+	u16 pkt_offset = 0, cksum;
 	struct nx_host_rds_ring *rds_ring;
-	int ret;
 
 	desc_ctx = netxen_get_sts_type(sts_data);
 	if (unlikely(desc_ctx >= NUM_RCV_DESC_RINGS)) {
@@ -1191,41 +1239,52 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 		}
 	}
 
-	pci_unmap_single(pdev, buffer->dma, rds_ring->dma_size,
-			 PCI_DMA_FROMDEVICE);
-
-	skb = (struct sk_buff *)buffer->skb;
+	cksum = netxen_get_sts_status(sts_data);
 
-	if (likely(adapter->rx_csum &&
-			netxen_get_sts_status(sts_data) == STATUS_CKSUM_OK)) {
-		adapter->stats.csummed++;
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else
-		skb->ip_summed = CHECKSUM_NONE;
+	skb = netxen_process_rxbuf(adapter, rds_ring, index, cksum);
+	if (!skb)
+		return;
 
-	skb->dev = netdev;
 	if (desc_ctx == RCV_DESC_LRO_CTXID) {
 		/* True length was only available on the last pkt */
 		skb_put(skb, buffer->lro_length);
 	} else {
-		skb_put(skb, length);
+		if (length > rds_ring->skb_size)
+			skb_put(skb, rds_ring->skb_size);
+		else
+			skb_put(skb, length);
+
+		pkt_offset = netxen_get_sts_pkt_offset(sts_data);
+		if (pkt_offset)
+			skb_pull(skb, pkt_offset);
 	}
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
-	ret = netif_receive_skb(skb);
-	netdev->last_rx = jiffies;
-
 	/*
-	 * We just consumed one buffer so post a buffer.
+	 * rx buffer chaining is disabled, walk and free
+	 * any spurious rx buffer chain.
 	 */
-	buffer->skb = NULL;
-	buffer->state = NETXEN_BUFFER_FREE;
-	buffer->lro_current_frags = 0;
-	buffer->lro_expected_frags = 0;
+	if (frag_desc) {
+		u16 i, nr_frags = desc->nr_frags;
+
+		dev_kfree_skb_any(skb);
+		for (i = 0; i < nr_frags; i++) {
+			index = frag_desc->frag_handles[i];
+			skb = netxen_process_rxbuf(adapter,
+					rds_ring, index, cksum);
+			if (skb)
+				dev_kfree_skb_any(skb);
+		}
+		adapter->stats.rxdropped++;
+	} else {
 
-	adapter->stats.no_rcv++;
-	adapter->stats.rxbytes += length;
+		netif_receive_skb(skb);
+		netdev->last_rx = jiffies;
+
+		adapter->stats.no_rcv++;
+		adapter->stats.rxbytes += length;
+	}
 }
 
 /* Process Receive status ring */
@@ -1233,9 +1292,11 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 {
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctxid]);
 	struct status_desc *desc_head = recv_ctx->rcv_status_desc_head;
-	struct status_desc *desc;	/* used to read status desc here */
+	struct status_desc *desc, *frag_desc;
 	u32 consumer = recv_ctx->status_rx_consumer;
 	int count = 0, ring;
+	u64 sts_data;
+	u16 opcode;
 
 	while (count < max) {
 		desc = &desc_head[consumer];
@@ -1244,9 +1305,26 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 				netxen_get_sts_owner(desc));
 			break;
 		}
-		netxen_process_rcv(adapter, ctxid, desc);
+
+		sts_data = le64_to_cpu(desc->status_desc_data);
+		opcode = netxen_get_sts_opcode(sts_data);
+		frag_desc = NULL;
+		if (opcode == NETXEN_NIC_RXPKT_DESC) {
+			if (desc->nr_frags) {
+				consumer = get_next_index(consumer,
+						adapter->max_rx_desc_count);
+				frag_desc = &desc_head[consumer];
+				netxen_set_sts_owner(frag_desc,
+						STATUS_OWNER_PHANTOM);
+			}
+		}
+
+		netxen_process_rcv(adapter, ctxid, desc, frag_desc);
+
 		netxen_set_sts_owner(desc, STATUS_OWNER_PHANTOM);
-		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
+
+		consumer = get_next_index(consumer,
+				adapter->max_rx_desc_count);
 		count++;
 	}
 	for (ring = 0; ring < adapter->max_rds_rings; ring++)
@@ -1348,36 +1426,31 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 	int index = 0;
 	netxen_ctx_msg msg = 0;
 	dma_addr_t dma;
+	struct list_head *head;
 
 	rds_ring = &recv_ctx->rds_rings[ringid];
 
 	producer = rds_ring->producer;
 	index = rds_ring->begin_alloc;
-	buffer = &rds_ring->rx_buf_arr[index];
+	head = &rds_ring->free_list;
+
 	/* We can start writing rx descriptors into the phantom memory. */
-	while (buffer->state == NETXEN_BUFFER_FREE) {
+	while (!list_empty(head)) {
+
 		skb = dev_alloc_skb(rds_ring->skb_size);
 		if (unlikely(!skb)) {
-			/*
-			 * TODO
-			 * We need to schedule the posting of buffers to the pegs.
-			 */
 			rds_ring->begin_alloc = index;
-			DPRINTK(ERR, "netxen_post_rx_buffers: "
-				" allocated only %d buffers\n", count);
 			break;
 		}
 
+		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
+		list_del(&buffer->list);
+
 		count++;	/* now there should be no failure */
 		pdesc = &rds_ring->desc_head[producer];
 
-#if defined(XGB_DEBUG)
-		*(unsigned long *)(skb->head) = 0xc0debabe;
-		if (skb_is_nonlinear(skb)) {
-			printk("Allocated SKB @%p is nonlinear\n");
-		}
-#endif
-		skb_reserve(skb, 2);
+		if (!adapter->ahw.cut_through)
+			skb_reserve(skb, 2);
 		/* This will be setup when we receive the
 		 * buffer after it has been filled  FSL  TBD TBD
 		 * skb->dev = netdev;
@@ -1395,7 +1468,6 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 		producer =
 		    get_next_index(producer, rds_ring->max_rx_desc_count);
 		index = get_next_index(index, rds_ring->max_rx_desc_count);
-		buffer = &rds_ring->rx_buf_arr[index];
 	}
 	/* if we did allocate buffers, then write the count to Phantom */
 	if (count) {
@@ -1439,32 +1511,29 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 	struct netxen_rx_buffer *buffer;
 	int count = 0;
 	int index = 0;
+	struct list_head *head;
 
 	rds_ring = &recv_ctx->rds_rings[ringid];
 
 	producer = rds_ring->producer;
 	index = rds_ring->begin_alloc;
-	buffer = &rds_ring->rx_buf_arr[index];
+	head = &rds_ring->free_list;
 	/* We can start writing rx descriptors into the phantom memory. */
-	while (buffer->state == NETXEN_BUFFER_FREE) {
+	while (!list_empty(head)) {
+
 		skb = dev_alloc_skb(rds_ring->skb_size);
 		if (unlikely(!skb)) {
-			/*
-			 * We need to schedule the posting of buffers to the pegs.
-			 */
 			rds_ring->begin_alloc = index;
-			DPRINTK(ERR, "netxen_post_rx_buffers_nodb: "
-				" allocated only %d buffers\n", count);
 			break;
 		}
+
+		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
+		list_del(&buffer->list);
+
 		count++;	/* now there should be no failure */
 		pdesc = &rds_ring->desc_head[producer];
-		skb_reserve(skb, 2);
-		/*
-		 * This will be setup when we receive the
-		 * buffer after it has been filled
-		 * skb->dev = netdev;
-		 */
+		if (!adapter->ahw.cut_through)
+			skb_reserve(skb, 2);
 		buffer->skb = skb;
 		buffer->state = NETXEN_BUFFER_BUSY;
 		buffer->dma = pci_map_single(pdev, skb->data,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index df48f89..b3c084f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -844,17 +844,18 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		/* Handshake with the card before we register the devices. */
 		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 
-		if (NX_IS_REVISION_P3(revision_id)) {
-			adapter->hw_read_wx(adapter,
-					NETXEN_MIU_MN_CONTROL, &val, 4);
-			adapter->ahw.cut_through = (val & 0x4) ? 1 : 0;
-			dev_info(&pdev->dev, "firmware running in %s mode\n",
-			adapter->ahw.cut_through ? "cut through" : "legacy");
-		}
 	}	/* first_driver */
 
 	netxen_nic_flash_print(adapter);
 
+	if (NX_IS_REVISION_P3(revision_id)) {
+		adapter->hw_read_wx(adapter,
+				NETXEN_MIU_MN_CONTROL, &val, 4);
+		adapter->ahw.cut_through = (val & 0x4) ? 1 : 0;
+		dev_info(&pdev->dev, "firmware running in %s mode\n",
+		adapter->ahw.cut_through ? "cut through" : "legacy");
+	}
+
 	/*
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
-- 
1.5.4.3

