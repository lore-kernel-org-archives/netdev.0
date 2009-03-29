From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 3/3] netxen: refactor transmit code
Date: Sun, 29 Mar 2009 11:10:20 -0700
Message-ID: <1238350220-22941-3-git-send-email-dhananjay@netxen.com>
References: <1238350220-22941-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:37111 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751119AbZC2SK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2009 14:10:27 -0400
In-Reply-To: <1238350220-22941-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o move tx stuff into nx_host_tx_ring structure, this will
  help managing multiple tx rings in future.
o sanitize some variable names

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   43 +++++++++++++---------------
 drivers/net/netxen/netxen_nic_ctx.c  |   49 ++++++++++++-------------------
 drivers/net/netxen/netxen_nic_hw.c   |   37 ++++++++++++------------
 drivers/net/netxen/netxen_nic_init.c |   48 +++++++++++++++++--------------
 drivers/net/netxen/netxen_nic_main.c |   52 ++++++++++++++++-----------------
 5 files changed, 108 insertions(+), 121 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 304254b..6103d81 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -74,10 +74,10 @@
 	(sizeof(struct netxen_rx_buffer) * rds_ring->num_desc)
 #define STATUS_DESC_RINGSIZE(sds_ring)	\
 	(sizeof(struct status_desc) * (sds_ring)->num_desc)
-#define TX_BUFF_RINGSIZE(adapter)	\
-	(sizeof(struct netxen_cmd_buffer) * adapter->num_txd)
-#define TX_DESC_RINGSIZE(adapter)	\
-	(sizeof(struct cmd_desc_type0) * adapter->num_txd)
+#define TX_BUFF_RINGSIZE(tx_ring)	\
+	(sizeof(struct netxen_cmd_buffer) * tx_ring->num_desc)
+#define TX_DESC_RINGSIZE(tx_ring)	\
+	(sizeof(struct cmd_desc_type0) * tx_ring->num_desc)
 
 #define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
 
@@ -639,7 +639,7 @@ extern char netxen_nic_driver_name[];
  */
 struct netxen_skb_frag {
 	u64 dma;
-	ulong length;
+	u64 length;
 };
 
 #define _netxen_set_bits(config_word, start, bits, val)	{\
@@ -704,9 +704,6 @@ struct netxen_hardware_context {
 	u8 linkup;
 	u16 port_type;
 	u16 board_type;
-	/* Address of cmd ring in Phantom */
-	struct cmd_desc_type0 *cmd_desc_head;
-	dma_addr_t cmd_desc_phys_addr;
 };
 
 #define MINIMUM_ETHERNET_FRAME_SIZE	64	/* With FCS */
@@ -752,14 +749,25 @@ struct nx_host_sds_ring {
 	struct napi_struct napi;
 	struct list_head free_list[NUM_RCV_DESC_RINGS];
 
-	u16 clean_tx;
-	u16 post_rxd;
 	int irq;
 
 	dma_addr_t phys_addr;
 	char name[IFNAMSIZ+4];
 };
 
+struct nx_host_tx_ring {
+	u32 producer;
+	__le32 *hw_consumer;
+	u32 sw_consumer;
+	u32 crb_cmd_producer;
+	u32 crb_cmd_consumer;
+	u32 num_desc;
+
+	struct netxen_cmd_buffer *cmd_buf_arr;
+	struct cmd_desc_type0 *desc_head;
+	dma_addr_t phys_addr;
+};
+
 /*
  * Receive context. There is one such structure per instance of the
  * receive processing. Any state information that is relevant to
@@ -1127,12 +1135,6 @@ struct netxen_adapter {
 	u32 curr_window;
 	u32 crb_win;
 	rwlock_t adapter_lock;
-
-	u32 cmd_producer;
-	__le32 *cmd_consumer;
-	u32 last_cmd_consumer;
-	u32 crb_addr_cmd_producer;
-	u32 crb_addr_cmd_consumer;
 	spinlock_t tx_clean_lock;
 
 	u32 num_txd;
@@ -1167,13 +1169,8 @@ struct netxen_adapter {
 
 	struct netxen_adapter_stats stats;
 
-	struct netxen_cmd_buffer *cmd_buf_arr;	/* Command buffers for xmit */
-
-	/*
-	 * Receive instances. These can be either one per port,
-	 * or one per peg, etc.
-	 */
 	struct netxen_recv_context recv_ctx;
+	struct nx_host_tx_ring tx_ring;
 
 	/* Context interface shared between card and host */
 	struct netxen_ring_ctx *ctx_desc;
@@ -1385,7 +1382,7 @@ int netxen_nic_set_mac(struct net_device *netdev, void *p);
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
 
 void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
-		uint32_t crb_producer);
+		struct nx_host_tx_ring *tx_ring, uint32_t crb_producer);
 
 /*
  * NetXen Board information
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 73f6deb..7943351 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -328,6 +328,7 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 	int	err = 0;
 	u64	offset, phys_addr;
 	dma_addr_t	rq_phys_addr, rsp_phys_addr;
+	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
 
 	rq_size = SIZEOF_HOSTRQ_TX(nx_hostrq_tx_ctx_t);
 	rq_addr = pci_alloc_consistent(adapter->pdev,
@@ -367,10 +368,8 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 
 	prq_cds = &prq->cds_ring;
 
-	prq_cds->host_phys_addr =
-		cpu_to_le64(adapter->ahw.cmd_desc_phys_addr);
-
-	prq_cds->ring_size = cpu_to_le32(adapter->num_txd);
+	prq_cds->host_phys_addr = cpu_to_le64(tx_ring->phys_addr);
+	prq_cds->ring_size = cpu_to_le32(tx_ring->num_desc);
 
 	phys_addr = rq_phys_addr;
 	err = netxen_issue_cmd(adapter,
@@ -383,8 +382,7 @@ nx_fw_cmd_create_tx_ctx(struct netxen_adapter *adapter)
 
 	if (err == NX_RCODE_SUCCESS) {
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
-		adapter->crb_addr_cmd_producer =
-			NETXEN_NIC_REG(temp - 0x200);
+		tx_ring->crb_cmd_producer = NETXEN_NIC_REG(temp - 0x200);
 #if 0
 		adapter->tx_state =
 			le32_to_cpu(prsp->host_ctx_state);
@@ -497,13 +495,13 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
 	struct nx_host_sds_ring *sds_ring;
+	struct nx_host_tx_ring *tx_ring;
 	int ring;
 	int func_id = adapter->portnum;
 
-	adapter->ctx_desc->cmd_ring_addr =
-		cpu_to_le64(adapter->ahw.cmd_desc_phys_addr);
-	adapter->ctx_desc->cmd_ring_size =
-		cpu_to_le32(adapter->num_txd);
+	tx_ring = &adapter->tx_ring;
+	adapter->ctx_desc->cmd_ring_addr = cpu_to_le64(tx_ring->phys_addr);
+	adapter->ctx_desc->cmd_ring_size = cpu_to_le32(tx_ring->num_desc);
 
 	recv_ctx = &adapter->recv_ctx;
 
@@ -535,25 +533,17 @@ static uint32_t sw_int_mask[4] = {
 
 int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 {
-	struct netxen_hardware_context *hw = &adapter->ahw;
-	u32 state = 0;
 	void *addr;
 	int err = 0;
 	int ring;
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
 	struct nx_host_sds_ring *sds_ring;
+	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
 
 	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev = adapter->netdev;
 
-	err = netxen_receive_peg_ready(adapter);
-	if (err) {
-		printk(KERN_ERR "Rcv Peg initialization not complete:%x.\n",
-				state);
-		return err;
-	}
-
 	addr = pci_alloc_consistent(pdev,
 			sizeof(struct netxen_ring_ctx) + sizeof(uint32_t),
 			&adapter->ctx_desc_phys_addr);
@@ -568,13 +558,12 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	adapter->ctx_desc->cmd_consumer_offset =
 		cpu_to_le64(adapter->ctx_desc_phys_addr +
 			sizeof(struct netxen_ring_ctx));
-	adapter->cmd_consumer =
+	tx_ring->hw_consumer =
 		(__le32 *)(((char *)addr) + sizeof(struct netxen_ring_ctx));
 
 	/* cmd desc ring */
-	addr = pci_alloc_consistent(pdev,
-			TX_DESC_RINGSIZE(adapter),
-			&hw->cmd_desc_phys_addr);
+	addr = pci_alloc_consistent(pdev, TX_DESC_RINGSIZE(tx_ring),
+			&tx_ring->phys_addr);
 
 	if (addr == NULL) {
 		dev_err(&pdev->dev, "%s: failed to allocate tx desc ring\n",
@@ -582,7 +571,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	hw->cmd_desc_head = (struct cmd_desc_type0 *)addr;
+	tx_ring->desc_head = (struct cmd_desc_type0 *)addr;
 
 	recv_ctx = &adapter->recv_ctx;
 
@@ -658,6 +647,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
 	struct nx_host_sds_ring *sds_ring;
+	struct nx_host_tx_ring *tx_ring;
 	int ring;
 
 	if (adapter->fw_major >= 4) {
@@ -674,13 +664,12 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 		adapter->ctx_desc = NULL;
 	}
 
-	if (adapter->ahw.cmd_desc_head != NULL) {
+	tx_ring = &adapter->tx_ring;
+	if (tx_ring->desc_head != NULL) {
 		pci_free_consistent(adapter->pdev,
-				sizeof(struct cmd_desc_type0) *
-				adapter->num_txd,
-				adapter->ahw.cmd_desc_head,
-				adapter->ahw.cmd_desc_phys_addr);
-		adapter->ahw.cmd_desc_head = NULL;
+				TX_DESC_RINGSIZE(tx_ring),
+				tx_ring->desc_head, tx_ring->phys_addr);
+		tx_ring->desc_head = NULL;
 	}
 
 	recv_ctx = &adapter->recv_ctx;
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index e42e693..b52c55f 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -501,45 +501,44 @@ static int nx_p3_nic_add_mac(struct netxen_adapter *adapter,
 
 static int
 netxen_send_cmd_descs(struct netxen_adapter *adapter,
-		struct cmd_desc_type0 *cmd_desc_arr, int nr_elements)
+		struct cmd_desc_type0 *cmd_desc_arr, int nr_desc)
 {
-	uint32_t i, producer;
+	u32 i, producer, consumer;
 	struct netxen_cmd_buffer *pbuf;
 	struct cmd_desc_type0 *cmd_desc;
-
-	if (nr_elements > MAX_PENDING_DESC_BLOCK_SIZE || nr_elements == 0) {
-		printk(KERN_WARNING "%s: Too many command descriptors in a "
-			      "request\n", __func__);
-		return -EINVAL;
-	}
+	struct nx_host_tx_ring *tx_ring;
 
 	i = 0;
 
+	tx_ring = &adapter->tx_ring;
 	netif_tx_lock_bh(adapter->netdev);
 
-	producer = adapter->cmd_producer;
+	producer = tx_ring->producer;
+	consumer = tx_ring->sw_consumer;
+
+	if (nr_desc > find_diff_among(producer, consumer, tx_ring->num_desc)) {
+		netif_tx_unlock_bh(adapter->netdev);
+		return -EBUSY;
+	}
+
 	do {
 		cmd_desc = &cmd_desc_arr[i];
 
-		pbuf = &adapter->cmd_buf_arr[producer];
+		pbuf = &tx_ring->cmd_buf_arr[producer];
 		pbuf->skb = NULL;
 		pbuf->frag_count = 0;
 
-		/* adapter->ahw.cmd_desc_head[producer] = *cmd_desc; */
-		memcpy(&adapter->ahw.cmd_desc_head[producer],
+		memcpy(&tx_ring->desc_head[producer],
 			&cmd_desc_arr[i], sizeof(struct cmd_desc_type0));
 
-		producer = get_next_index(producer,
-				adapter->num_txd);
+		producer = get_next_index(producer, tx_ring->num_desc);
 		i++;
 
-	} while (i != nr_elements);
-
-	adapter->cmd_producer = producer;
+	} while (i != nr_desc);
 
-	/* write producer index to start the xmit */
+	tx_ring->producer = producer;
 
-	netxen_nic_update_cmd_producer(adapter, adapter->cmd_producer);
+	netxen_nic_update_cmd_producer(adapter, tx_ring, producer);
 
 	netif_tx_unlock_bh(adapter->netdev);
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 0759c35..8e45dcc 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -173,9 +173,10 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 	struct netxen_cmd_buffer *cmd_buf;
 	struct netxen_skb_frag *buffrag;
 	int i, j;
+	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
 
-	cmd_buf = adapter->cmd_buf_arr;
-	for (i = 0; i < adapter->num_txd; i++) {
+	cmd_buf = tx_ring->cmd_buf_arr;
+	for (i = 0; i < tx_ring->num_desc; i++) {
 		buffrag = cmd_buf->frag_array;
 		if (buffrag->dma) {
 			pci_unmap_single(adapter->pdev, buffrag->dma,
@@ -203,6 +204,7 @@ void netxen_free_sw_resources(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
+	struct nx_host_tx_ring *tx_ring;
 	int ring;
 
 	recv_ctx = &adapter->recv_ctx;
@@ -214,8 +216,9 @@ void netxen_free_sw_resources(struct netxen_adapter *adapter)
 		}
 	}
 
-	if (adapter->cmd_buf_arr)
-		vfree(adapter->cmd_buf_arr);
+	tx_ring = &adapter->tx_ring;
+	if (tx_ring->cmd_buf_arr)
+		vfree(tx_ring->cmd_buf_arr);
 	return;
 }
 
@@ -224,21 +227,24 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
 	struct nx_host_sds_ring *sds_ring;
+	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
 	struct netxen_rx_buffer *rx_buf;
 	int ring, i, num_rx_bufs;
 
 	struct netxen_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
 
+	tx_ring->num_desc = adapter->num_txd;
 	cmd_buf_arr =
-		(struct netxen_cmd_buffer *)vmalloc(TX_BUFF_RINGSIZE(adapter));
+		(struct netxen_cmd_buffer *)vmalloc(TX_BUFF_RINGSIZE(tx_ring));
 	if (cmd_buf_arr == NULL) {
-		printk(KERN_ERR "%s: Failed to allocate cmd buffer ring\n",
+		dev_err(&pdev->dev, "%s: failed to allocate cmd buffer ring\n",
 		       netdev->name);
 		return -ENOMEM;
 	}
-	memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(adapter));
-	adapter->cmd_buf_arr = cmd_buf_arr;
+	memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(tx_ring));
+	tx_ring->cmd_buf_arr = cmd_buf_arr;
 
 	recv_ctx = &adapter->recv_ctx;
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
@@ -307,8 +313,6 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
 		sds_ring->irq = adapter->msix_entries[ring].vector;
-		sds_ring->clean_tx = (ring == 0);
-		sds_ring->post_rxd = (ring == 0);
 		sds_ring->adapter = adapter;
 		sds_ring->num_desc = adapter->num_rxd;
 
@@ -990,23 +994,24 @@ netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max)
 /* Process Command status ring */
 int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 {
-	u32 last_consumer, consumer;
+	u32 sw_consumer, hw_consumer;
 	int count = 0, i;
 	struct netxen_cmd_buffer *buffer;
 	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev = adapter->netdev;
 	struct netxen_skb_frag *frag;
 	int done = 0;
+	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
 
 	if (!spin_trylock(&adapter->tx_clean_lock))
 		return 1;
 
-	last_consumer = adapter->last_cmd_consumer;
-	barrier(); /* cmd_consumer can change underneath */
-	consumer = le32_to_cpu(*(adapter->cmd_consumer));
+	sw_consumer = tx_ring->sw_consumer;
+	barrier(); /* hw_consumer can change underneath */
+	hw_consumer = le32_to_cpu(*(tx_ring->hw_consumer));
 
-	while (last_consumer != consumer) {
-		buffer = &adapter->cmd_buf_arr[last_consumer];
+	while (sw_consumer != hw_consumer) {
+		buffer = &tx_ring->cmd_buf_arr[sw_consumer];
 		if (buffer->skb) {
 			frag = &buffer->frag_array[0];
 			pci_unmap_single(pdev, frag->dma, frag->length,
@@ -1024,14 +1029,13 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 			buffer->skb = NULL;
 		}
 
-		last_consumer = get_next_index(last_consumer,
-					       adapter->num_txd);
+		sw_consumer = get_next_index(sw_consumer, tx_ring->num_desc);
 		if (++count >= MAX_STATUS_HANDLE)
 			break;
 	}
 
 	if (count) {
-		adapter->last_cmd_consumer = last_consumer;
+		tx_ring->sw_consumer = sw_consumer;
 		smp_mb();
 		if (netif_queue_stopped(netdev) && netif_running(netdev)) {
 			netif_tx_lock(netdev);
@@ -1053,9 +1057,9 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	 * There is still a possible race condition and the host could miss an
 	 * interrupt. The card has to take care of this.
 	 */
-	barrier(); /* cmd_consumer can change underneath */
-	consumer = le32_to_cpu(*(adapter->cmd_consumer));
-	done = (last_consumer == consumer);
+	barrier(); /* hw_consumer can change underneath */
+	hw_consumer = le32_to_cpu(*(tx_ring->hw_consumer));
+	done = (sw_consumer == hw_consumer);
 	spin_unlock(&adapter->tx_clean_lock);
 
 	return (done);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index b94216b..5599da3 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -107,10 +107,10 @@ static uint32_t crb_cmd_producer[4] = {
 
 void
 netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
-		uint32_t crb_producer)
+		struct nx_host_tx_ring *tx_ring, u32 producer)
 {
 	adapter->pci_write_normalize(adapter,
-			adapter->crb_addr_cmd_producer, crb_producer);
+			tx_ring->crb_cmd_producer, producer);
 }
 
 static uint32_t crb_cmd_consumer[4] = {
@@ -120,10 +120,10 @@ static uint32_t crb_cmd_consumer[4] = {
 
 static inline void
 netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
-		u32 crb_consumer)
+		struct nx_host_tx_ring *tx_ring, u32 consumer)
 {
 	adapter->pci_write_normalize(adapter,
-			adapter->crb_addr_cmd_consumer, crb_consumer);
+			tx_ring->crb_cmd_consumer, consumer);
 }
 
 static uint32_t msi_tgt_status[8] = {
@@ -814,6 +814,7 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	int err, ring;
 	struct nx_host_rds_ring *rds_ring;
+	struct nx_host_tx_ring *tx_ring;
 
 	err = netxen_init_firmware(adapter);
 	if (err != 0) {
@@ -843,13 +844,12 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 	}
 
 	if (adapter->fw_major < 4) {
-		adapter->crb_addr_cmd_producer =
-			crb_cmd_producer[adapter->portnum];
-		adapter->crb_addr_cmd_consumer =
-			crb_cmd_consumer[adapter->portnum];
+		tx_ring = &adapter->tx_ring;
+		tx_ring->crb_cmd_producer = crb_cmd_producer[adapter->portnum];
+		tx_ring->crb_cmd_consumer = crb_cmd_consumer[adapter->portnum];
 
-		netxen_nic_update_cmd_producer(adapter, 0);
-		netxen_nic_update_cmd_consumer(adapter, 0);
+		netxen_nic_update_cmd_producer(adapter, tx_ring, 0);
+		netxen_nic_update_cmd_consumer(adapter, tx_ring, 0);
 	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
@@ -1304,7 +1304,7 @@ static int
 netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct netxen_hardware_context *hw = &adapter->ahw;
+	struct nx_host_tx_ring *tx_ring = &adapter->tx_ring;
 	unsigned int first_seg_len = skb->len - skb->data_len;
 	struct netxen_cmd_buffer *pbuf;
 	struct netxen_skb_frag *buffrag;
@@ -1315,28 +1315,26 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	u32 producer, consumer;
 	int frag_count, no_of_desc;
-	u32 num_txd = adapter->num_txd;
+	u32 num_txd = tx_ring->num_desc;
 	bool is_tso = false;
 
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
 
-	/* There 4 fragments per descriptor */
+	/* 4 fragments per cmd des */
 	no_of_desc = (frag_count + 3) >> 2;
 
-	producer = adapter->cmd_producer;
+	producer = tx_ring->producer;
 	smp_mb();
-	consumer = adapter->last_cmd_consumer;
+	consumer = tx_ring->sw_consumer;
 	if ((no_of_desc+2) > find_diff_among(producer, consumer, num_txd)) {
 		netif_stop_queue(netdev);
 		smp_mb();
 		return NETDEV_TX_BUSY;
 	}
 
-	/* Copy the descriptors into the hardware    */
-	hwdesc = &hw->cmd_desc_head[producer];
+	hwdesc = &tx_ring->desc_head[producer];
 	netxen_clear_cmddesc((u64 *)hwdesc);
-	/* Take skb->data itself */
-	pbuf = &adapter->cmd_buf_arr[producer];
+	pbuf = &tx_ring->cmd_buf_arr[producer];
 
 	is_tso = netxen_tso_check(netdev, hwdesc, skb);
 
@@ -1365,9 +1363,9 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		if ((i & 0x3) == 0) {
 			k = 0;
 			producer = get_next_index(producer, num_txd);
-			hwdesc = &hw->cmd_desc_head[producer];
+			hwdesc = &tx_ring->desc_head[producer];
 			netxen_clear_cmddesc((u64 *)hwdesc);
-			pbuf = &adapter->cmd_buf_arr[producer];
+			pbuf = &tx_ring->cmd_buf_arr[producer];
 			pbuf->skb = NULL;
 		}
 		frag = &skb_shinfo(skb)->frags[i - 1];
@@ -1419,8 +1417,8 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			more_hdr = 0;
 		}
 		/* copy the MAC/IP/TCP headers to the cmd descriptor list */
-		hwdesc = &hw->cmd_desc_head[producer];
-		pbuf = &adapter->cmd_buf_arr[producer];
+		hwdesc = &tx_ring->desc_head[producer];
+		pbuf = &tx_ring->cmd_buf_arr[producer];
 		pbuf->skb = NULL;
 
 		/* copy the first 64 bytes */
@@ -1429,8 +1427,8 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		producer = get_next_index(producer, num_txd);
 
 		if (more_hdr) {
-			hwdesc = &hw->cmd_desc_head[producer];
-			pbuf = &adapter->cmd_buf_arr[producer];
+			hwdesc = &tx_ring->desc_head[producer];
+			pbuf = &tx_ring->cmd_buf_arr[producer];
 			pbuf->skb = NULL;
 			/* copy the next 64 bytes - should be enough except
 			 * for pathological case
@@ -1443,10 +1441,10 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
-	adapter->cmd_producer = producer;
+	tx_ring->producer = producer;
 	adapter->stats.txbytes += skb->len;
 
-	netxen_nic_update_cmd_producer(adapter, adapter->cmd_producer);
+	netxen_nic_update_cmd_producer(adapter, tx_ring, producer);
 
 	adapter->stats.xmitcalled++;
 	netdev->trans_start = jiffies;
-- 
1.6.0.2

