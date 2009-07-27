From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 05/12] netxen: refactor tso code
Date: Sun, 26 Jul 2009 23:07:40 -0700
Message-ID: <1248674867-18821-6-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33576 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751229AbZG0GHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:48 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o move all tso / checksum offload code into netxen_tso_check().
o optimize the tso header copy into simple loop.
o clean up unnecessary unions from cmd_desc_type0 struct.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   51 +++---------
 drivers/net/netxen/netxen_nic_main.c |  152 ++++++++++++++++------------------
 2 files changed, 84 insertions(+), 119 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 3368af0..3a4cbd5 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -316,56 +316,29 @@ struct netxen_ring_ctx {
 	cpu_to_le16(((_flags) & 0x7f) | (((_opcode) & 0x3f) << 7))
 
 #define netxen_set_tx_frags_len(_desc, _frags, _len) \
-	(_desc)->num_of_buffers_total_length = \
+	(_desc)->nfrags__length = \
 	cpu_to_le32(((_frags) & 0xff) | (((_len) & 0xffffff) << 8))
 
 struct cmd_desc_type0 {
 	u8 tcp_hdr_offset;	/* For LSO only */
 	u8 ip_hdr_offset;	/* For LSO only */
-	/* Bit pattern: 0-6 flags, 7-12 opcode, 13-15 unused */
-	__le16 flags_opcode;
-	/* Bit pattern: 0-7 total number of segments,
-	   8-31 Total size of the packet */
-	__le32 num_of_buffers_total_length;
-	union {
-		struct {
-			__le32 addr_low_part2;
-			__le32 addr_high_part2;
-		};
-		__le64 addr_buffer2;
-	};
+	__le16 flags_opcode;	/* 15:13 unused, 12:7 opcode, 6:0 flags */
+	__le32 nfrags__length;	/* 31:8 total len, 7:0 frag count */
+
+	__le64 addr_buffer2;
 
-	__le16 reference_handle;	/* changed to u16 to add mss */
-	__le16 mss;		/* passed by NDIS_PACKET for LSO */
-	/* Bit pattern 0-3 port, 0-3 ctx id */
-	u8 port_ctxid;
+	__le16 reference_handle;
+	__le16 mss;
+	u8 port_ctxid;		/* 7:4 ctxid 3:0 port */
 	u8 total_hdr_length;	/* LSO only : MAC+IP+TCP Hdr size */
 	__le16 conn_id;		/* IPSec offoad only */
 
-	union {
-		struct {
-			__le32 addr_low_part3;
-			__le32 addr_high_part3;
-		};
-		__le64 addr_buffer3;
-	};
-	union {
-		struct {
-			__le32 addr_low_part1;
-			__le32 addr_high_part1;
-		};
-		__le64 addr_buffer1;
-	};
+	__le64 addr_buffer3;
+	__le64 addr_buffer1;
 
 	__le16 buffer_length[4];
 
-	union {
-		struct {
-			__le32 addr_low_part4;
-			__le32 addr_high_part4;
-		};
-		__le64 addr_buffer4;
-	};
+	__le64 addr_buffer4;
 
 	__le64 unused;
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index fb976cb..381bd8f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1310,13 +1310,18 @@ static int netxen_nic_close(struct net_device *netdev)
 	return 0;
 }
 
-static bool netxen_tso_check(struct net_device *netdev,
-		      struct cmd_desc_type0 *desc, struct sk_buff *skb)
+static void
+netxen_tso_check(struct net_device *netdev,
+		struct nx_host_tx_ring *tx_ring,
+		struct cmd_desc_type0 *first_desc,
+		struct sk_buff *skb)
 {
-	bool tso = false;
 	u8 opcode = TX_ETHER_PKT;
 	__be16 protocol = skb->protocol;
 	u16 flags = 0;
+	u32 producer;
+	int copied, offset, copy_len, hdr_len = 0, tso = 0;
+	struct cmd_desc_type0 *hwdesc;
 
 	if (protocol == cpu_to_be16(ETH_P_8021Q)) {
 		struct vlan_ethhdr *vh = (struct vlan_ethhdr *)skb->data;
@@ -1327,13 +1332,14 @@ static bool netxen_tso_check(struct net_device *netdev,
 	if ((netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
 			skb_shinfo(skb)->gso_size > 0) {
 
-		desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
-		desc->total_hdr_length =
-			skb_transport_offset(skb) + tcp_hdrlen(skb);
+		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+
+		first_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
+		first_desc->total_hdr_length = hdr_len;
 
 		opcode = (protocol == cpu_to_be16(ETH_P_IPV6)) ?
 				TX_TCP_LSO6 : TX_TCP_LSO;
-		tso = true;
+		tso = 1;
 
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u8 l4proto;
@@ -1354,10 +1360,39 @@ static bool netxen_tso_check(struct net_device *netdev,
 				opcode = TX_UDPV6_PKT;
 		}
 	}
-	desc->tcp_hdr_offset = skb_transport_offset(skb);
-	desc->ip_hdr_offset = skb_network_offset(skb);
-	netxen_set_tx_flags_opcode(desc, flags, opcode);
-	return tso;
+	first_desc->tcp_hdr_offset = skb_transport_offset(skb);
+	first_desc->ip_hdr_offset = skb_network_offset(skb);
+	netxen_set_tx_flags_opcode(first_desc, flags, opcode);
+
+	if (!tso)
+		return;
+
+	/* For LSO, we need to copy the MAC/IP/TCP headers into
+	 * the descriptor ring
+	 */
+	producer = tx_ring->producer;
+	copied = 0;
+	offset = 2;
+
+	while (copied < hdr_len) {
+
+		copy_len = min((int)sizeof(struct cmd_desc_type0) - offset,
+				(hdr_len - copied));
+
+		hwdesc = &tx_ring->desc_head[producer];
+		tx_ring->cmd_buf_arr[producer].skb = NULL;
+
+		skb_copy_from_linear_data_offset(skb, copied,
+				 (char *)hwdesc + offset, copy_len);
+
+		copied += copy_len;
+		offset = 0;
+
+		producer = get_next_index(producer, tx_ring->num_desc);
+	}
+
+	tx_ring->producer = producer;
+	barrier();
 }
 
 static void
@@ -1381,9 +1416,8 @@ netxen_clean_tx_dma_mapping(struct pci_dev *pdev,
 static inline void
 netxen_clear_cmddesc(u64 *desc)
 {
-	int i;
-	for (i = 0; i < 8; i++)
-		desc[i] = 0ULL;
+	desc[0] = 0ULL;
+	desc[2] = 0ULL;
 }
 
 static int
@@ -1391,18 +1425,18 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
-	unsigned int first_seg_len = skb->len - skb->data_len;
+	struct skb_frag_struct *frag;
 	struct netxen_cmd_buffer *pbuf;
 	struct netxen_skb_frag *buffrag;
-	struct cmd_desc_type0 *hwdesc;
-	struct pci_dev *pdev = adapter->pdev;
+	struct cmd_desc_type0 *hwdesc, *first_desc;
+	struct pci_dev *pdev;
 	dma_addr_t temp_dma;
 	int i, k;
+	unsigned long offset;
 
 	u32 producer;
-	int frag_count, no_of_desc;
+	int len, frag_count, no_of_desc;
 	u32 num_txd = tx_ring->num_desc;
-	bool is_tso = false;
 
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
 
@@ -1416,32 +1450,30 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	producer = tx_ring->producer;
 
-	hwdesc = &tx_ring->desc_head[producer];
-	netxen_clear_cmddesc((u64 *)hwdesc);
-	pbuf = &tx_ring->cmd_buf_arr[producer];
+	pdev = adapter->pdev;
+	len = skb->len - skb->data_len;
 
-	is_tso = netxen_tso_check(netdev, hwdesc, skb);
+	temp_dma = pci_map_single(pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(pdev, temp_dma))
+		goto drop_packet;
 
+	pbuf = &tx_ring->cmd_buf_arr[producer];
 	pbuf->skb = skb;
 	pbuf->frag_count = frag_count;
-	buffrag = &pbuf->frag_array[0];
-	temp_dma = pci_map_single(pdev, skb->data, first_seg_len,
-				      PCI_DMA_TODEVICE);
-	if (pci_dma_mapping_error(pdev, temp_dma))
-		goto drop_packet;
 
+	buffrag = &pbuf->frag_array[0];
 	buffrag->dma = temp_dma;
-	buffrag->length = first_seg_len;
+	buffrag->length = len;
+
+	first_desc = hwdesc = &tx_ring->desc_head[producer];
+	netxen_clear_cmddesc((u64 *)hwdesc);
 	netxen_set_tx_frags_len(hwdesc, frag_count, skb->len);
 	netxen_set_tx_port(hwdesc, adapter->portnum);
 
-	hwdesc->buffer_length[0] = cpu_to_le16(first_seg_len);
-	hwdesc->addr_buffer1 = cpu_to_le64(buffrag->dma);
+	hwdesc->buffer_length[0] = cpu_to_le16(len);
+	hwdesc->addr_buffer1 = cpu_to_le64(temp_dma);
 
 	for (i = 1, k = 1; i < frag_count; i++, k++) {
-		struct skb_frag_struct *frag;
-		int len, temp_len;
-		unsigned long offset;
 
 		/* move to next desc. if there is a need */
 		if ((i & 0x3) == 0) {
@@ -1452,11 +1484,11 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			pbuf = &tx_ring->cmd_buf_arr[producer];
 			pbuf->skb = NULL;
 		}
+		buffrag = &pbuf->frag_array[i];
 		frag = &skb_shinfo(skb)->frags[i - 1];
 		len = frag->size;
 		offset = frag->page_offset;
 
-		temp_len = len;
 		temp_dma = pci_map_page(pdev, frag->page, offset,
 					len, PCI_DMA_TODEVICE);
 		if (pci_dma_mapping_error(pdev, temp_dma)) {
@@ -1464,11 +1496,10 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			goto drop_packet;
 		}
 
-		buffrag++;
 		buffrag->dma = temp_dma;
-		buffrag->length = temp_len;
+		buffrag->length = len;
 
-		hwdesc->buffer_length[k] = cpu_to_le16(temp_len);
+		hwdesc->buffer_length[k] = cpu_to_le16(len);
 		switch (k) {
 		case 0:
 			hwdesc->addr_buffer1 = cpu_to_le64(temp_dma);
@@ -1483,53 +1514,14 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			hwdesc->addr_buffer4 = cpu_to_le64(temp_dma);
 			break;
 		}
-		frag++;
 	}
-	producer = get_next_index(producer, num_txd);
+	tx_ring->producer = get_next_index(producer, num_txd);
 
-	/* For LSO, we need to copy the MAC/IP/TCP headers into
-	 * the descriptor ring
-	 */
-	if (is_tso) {
-		int hdr_len, first_hdr_len, more_hdr;
-		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		if (hdr_len > (sizeof(struct cmd_desc_type0) - 2)) {
-			first_hdr_len = sizeof(struct cmd_desc_type0) - 2;
-			more_hdr = 1;
-		} else {
-			first_hdr_len = hdr_len;
-			more_hdr = 0;
-		}
-		/* copy the MAC/IP/TCP headers to the cmd descriptor list */
-		hwdesc = &tx_ring->desc_head[producer];
-		pbuf = &tx_ring->cmd_buf_arr[producer];
-		pbuf->skb = NULL;
-
-		/* copy the first 64 bytes */
-		memcpy(((void *)hwdesc) + 2,
-		       (void *)(skb->data), first_hdr_len);
-		producer = get_next_index(producer, num_txd);
-
-		if (more_hdr) {
-			hwdesc = &tx_ring->desc_head[producer];
-			pbuf = &tx_ring->cmd_buf_arr[producer];
-			pbuf->skb = NULL;
-			/* copy the next 64 bytes - should be enough except
-			 * for pathological case
-			 */
-			skb_copy_from_linear_data_offset(skb, first_hdr_len,
-							 hwdesc,
-							 (hdr_len -
-							  first_hdr_len));
-			producer = get_next_index(producer, num_txd);
-		}
-	}
-
-	tx_ring->producer = producer;
-	adapter->stats.txbytes += skb->len;
+	netxen_tso_check(netdev, tx_ring, first_desc, skb);
 
 	netxen_nic_update_cmd_producer(adapter, tx_ring);
 
+	adapter->stats.txbytes += skb->len;
 	adapter->stats.xmitcalled++;
 
 	return NETDEV_TX_OK;
-- 
1.6.0.2

