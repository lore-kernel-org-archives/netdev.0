From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 5/6] netxen: add receive side scaling (rss) support
Date: Fri, 13 Mar 2009 17:52:05 -0700
Message-ID: <1236991926-17892-6-git-send-email-dhananjay@netxen.com>
References: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:47274 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762943AbZCNAwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 20:52:15 -0400
In-Reply-To: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the load balancing capability of firmware
and hardware to spray traffic into different cpus through
separate rx msix interrupts.

The feature is being enabled for NX3031, NX2031 (old) will be
enabled later. This depends on msi-x and compatibility with
msi and legacy is maintained by enabling single rx ring.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   74 ++++++++-----
 drivers/net/netxen/netxen_nic_ctx.c  |  117 ++++++++++++--------
 drivers/net/netxen/netxen_nic_hw.c   |   47 ++++++++
 drivers/net/netxen/netxen_nic_init.c |  201 +++++++++++++++++++++-------------
 drivers/net/netxen/netxen_nic_main.c |  157 ++++++++++++++++++++-------
 5 files changed, 404 insertions(+), 192 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 56fad22..595171d 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -78,16 +78,17 @@
 
 #define PHAN_VENDOR_ID 0x4040
 
-#define RCV_DESC_RINGSIZE	\
-	(sizeof(struct rcv_desc) * adapter->num_rxd)
-#define STATUS_DESC_RINGSIZE	\
-	(sizeof(struct status_desc) * adapter->num_rxd)
-#define LRO_DESC_RINGSIZE	\
-	(sizeof(rcvDesc_t) * adapter->num_lro_rxd)
-#define TX_RINGSIZE	\
-	(sizeof(struct netxen_cmd_buffer) * adapter->num_txd)
-#define RCV_BUFFSIZE	\
+#define RCV_DESC_RINGSIZE(rds_ring)	\
+	(sizeof(struct rcv_desc) * (rds_ring)->num_desc)
+#define RCV_BUFF_RINGSIZE(rds_ring)	\
 	(sizeof(struct netxen_rx_buffer) * rds_ring->num_desc)
+#define STATUS_DESC_RINGSIZE(sds_ring)	\
+	(sizeof(struct status_desc) * (sds_ring)->num_desc)
+#define TX_BUFF_RINGSIZE(adapter)	\
+	(sizeof(struct netxen_cmd_buffer) * adapter->num_txd)
+#define TX_DESC_RINGSIZE(adapter)	\
+	(sizeof(struct cmd_desc_type0) * adapter->num_txd)
+
 #define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
 
 #define NETXEN_RCV_PRODUCER_OFFSET	0
@@ -188,7 +189,8 @@
 /* Host writes the following to notify that it has done the init-handshake */
 #define PHAN_INITIALIZE_ACK	0xf00f
 
-#define NUM_RCV_DESC_RINGS	3	/* No of Rcv Descriptor contexts */
+#define NUM_RCV_DESC_RINGS	3
+#define NUM_STS_DESC_RINGS	4
 
 #define RCV_RING_NORMAL	0
 #define RCV_RING_JUMBO	1
@@ -722,7 +724,7 @@ extern char netxen_nic_driver_name[];
 #endif
 
 /* Number of status descriptors to handle per interrupt */
-#define MAX_STATUS_HANDLE	(128)
+#define MAX_STATUS_HANDLE	(64)
 
 /*
  * netxen_skb_frag{} is to contain mapping info for each SG list. This
@@ -827,17 +829,37 @@ struct netxen_adapter_stats {
  */
 struct nx_host_rds_ring {
 	u32 producer;
-	u32 crb_rcv_producer;	/* reg offset */
-	struct rcv_desc *desc_head;	/* address of rx ring in Phantom */
-	struct netxen_rx_buffer *rx_buf_arr;	/* rx buffers for receive   */
-	struct list_head free_list;
+	u32 crb_rcv_producer;
 	u32 num_desc;
 	u32 dma_size;
 	u32 skb_size;
 	u32 flags;
+	struct rcv_desc *desc_head;
+	struct netxen_rx_buffer *rx_buf_arr;
+	struct list_head free_list;
+	spinlock_t lock;
 	dma_addr_t phys_addr;
 };
 
+struct nx_host_sds_ring {
+	u32 consumer;
+	u32 crb_sts_consumer;
+	u32 crb_intr_mask;
+	u32 num_desc;
+
+	struct status_desc *desc_head;
+	struct netxen_adapter *adapter;
+	struct napi_struct napi;
+	struct list_head free_list[NUM_RCV_DESC_RINGS];
+
+	u16 clean_tx;
+	u16 post_rxd;
+	int irq;
+
+	dma_addr_t phys_addr;
+	char name[IFNAMSIZ+4];
+};
+
 /*
  * Receive context. There is one such structure per instance of the
  * receive processing. Any state information that is relevant to
@@ -850,10 +872,7 @@ struct netxen_recv_context {
 	u16 virt_port;
 
 	struct nx_host_rds_ring rds_rings[NUM_RCV_DESC_RINGS];
-	u32 status_rx_consumer;
-	u32 crb_sts_consumer;	/* reg offset */
-	dma_addr_t rcv_status_desc_phys_addr;
-	struct status_desc *rcv_status_desc_head;
+	struct nx_host_sds_ring sds_rings[NUM_STS_DESC_RINGS];
 };
 
 /* New HW context creation */
@@ -1179,13 +1198,13 @@ typedef struct {
 #define NETXEN_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED))
 
-#define MSIX_ENTRIES_PER_ADAPTER	1
+#define MSIX_ENTRIES_PER_ADAPTER	NUM_STS_DESC_RINGS
 #define NETXEN_MSIX_TBL_SPACE		8192
 #define NETXEN_PCI_REG_MSIX_TBL		0x44
 
 #define NETXEN_DB_MAPSIZE_BYTES    	0x1000
 
-#define NETXEN_NETDEV_WEIGHT 120
+#define NETXEN_NETDEV_WEIGHT 128
 #define NETXEN_ADAPTER_UP_MAGIC 777
 #define NETXEN_NIC_PEG_TUNE 0
 
@@ -1200,7 +1219,6 @@ struct netxen_adapter {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	int pci_using_dac;
-	struct napi_struct napi;
 	struct net_device_stats net_stats;
 	int mtu;
 	int portnum;
@@ -1212,7 +1230,6 @@ struct netxen_adapter {
 	nx_mac_list_t	*mac_list;
 
 	struct netxen_legacy_intr_set legacy_intr;
-	u32	crb_intr_mask;
 
 	struct work_struct watchdog_task;
 	struct timer_list watchdog_timer;
@@ -1227,6 +1244,7 @@ struct netxen_adapter {
 	u32 last_cmd_consumer;
 	u32 crb_addr_cmd_producer;
 	u32 crb_addr_cmd_consumer;
+	spinlock_t tx_clean_lock;
 
 	u32 num_txd;
 	u32 num_rxd;
@@ -1234,6 +1252,7 @@ struct netxen_adapter {
 	u32 num_lro_rxd;
 
 	int max_rds_rings;
+	int max_sds_rings;
 
 	u32 flags;
 	u32 irq;
@@ -1243,8 +1262,7 @@ struct netxen_adapter {
 	u32 fw_major;
 	u32 fw_version;
 
-	u8 msix_supported;
-	u8 max_possible_rss_rings;
+	int msix_supported;
 	struct msix_entry msix_entries[MSIX_ENTRIES_PER_ADAPTER];
 
 	struct netxen_adapter_stats stats;
@@ -1447,14 +1465,16 @@ void netxen_initialize_adapter_ops(struct netxen_adapter *adapter);
 int netxen_init_firmware(struct netxen_adapter *adapter);
 void netxen_nic_clear_stats(struct netxen_adapter *adapter);
 void netxen_watchdog_task(struct work_struct *work);
-void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid);
+void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
+		struct nx_host_rds_ring *rds_ring);
 int netxen_process_cmd_ring(struct netxen_adapter *adapter);
-int netxen_process_rcv_ring(struct netxen_adapter *adapter, int max);
+int netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max);
 void netxen_p2_nic_set_multi(struct net_device *netdev);
 void netxen_p3_nic_set_multi(struct net_device *netdev);
 void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
 int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32);
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
+int netxen_config_rss(struct netxen_adapter *adapter, int enable);
 
 int nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 2e66335..9234473 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -169,6 +169,7 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 	nx_cardrsp_rds_ring_t *prsp_rds;
 	nx_cardrsp_sds_ring_t *prsp_sds;
 	struct nx_host_rds_ring *rds_ring;
+	struct nx_host_sds_ring *sds_ring;
 
 	dma_addr_t hostrq_phys_addr, cardrsp_phys_addr;
 	u64 phys_addr;
@@ -181,9 +182,8 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
-	/* only one sds ring for now */
 	nrds_rings = adapter->max_rds_rings;
-	nsds_rings = 1;
+	nsds_rings = adapter->max_sds_rings;
 
 	rq_size =
 		SIZEOF_HOSTRQ_RX(nx_hostrq_rx_ctx_t, nrds_rings, nsds_rings);
@@ -239,11 +239,14 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 	prq_sds = (nx_hostrq_sds_ring_t *)(prq->data +
 			le32_to_cpu(prq->sds_ring_offset));
 
-	prq_sds[0].host_phys_addr =
-		cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
-	prq_sds[0].ring_size = cpu_to_le32(adapter->num_rxd);
-	/* only one msix vector for now */
-	prq_sds[0].msi_index = cpu_to_le16(0);
+	for (i = 0; i < nsds_rings; i++) {
+
+		sds_ring = &recv_ctx->sds_rings[i];
+
+		prq_sds[i].host_phys_addr = cpu_to_le64(sds_ring->phys_addr);
+		prq_sds[i].ring_size = cpu_to_le32(sds_ring->num_desc);
+		prq_sds[i].msi_index = cpu_to_le16(i);
+	}
 
 	phys_addr = hostrq_phys_addr;
 	err = netxen_issue_cmd(adapter,
@@ -272,11 +275,16 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 
 	prsp_sds = ((nx_cardrsp_sds_ring_t *)
 			&prsp->data[le32_to_cpu(prsp->sds_ring_offset)]);
-	reg = le32_to_cpu(prsp_sds[0].host_consumer_crb);
-	recv_ctx->crb_sts_consumer = NETXEN_NIC_REG(reg - 0x200);
 
-	reg = le32_to_cpu(prsp_sds[0].interrupt_crb);
-	adapter->crb_intr_mask = NETXEN_NIC_REG(reg - 0x200);
+	for (i = 0; i < le16_to_cpu(prsp->num_sds_rings); i++) {
+		sds_ring = &recv_ctx->sds_rings[i];
+
+		reg = le32_to_cpu(prsp_sds[i].host_consumer_crb);
+		sds_ring->crb_sts_consumer = NETXEN_NIC_REG(reg - 0x200);
+
+		reg = le32_to_cpu(prsp_sds[i].interrupt_crb);
+		sds_ring->crb_intr_mask = NETXEN_NIC_REG(reg - 0x200);
+	}
 
 	recv_ctx->state = le32_to_cpu(prsp->host_ctx_state);
 	recv_ctx->context_id = le16_to_cpu(prsp->context_id);
@@ -488,6 +496,7 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
+	struct nx_host_sds_ring *sds_ring;
 	int ring;
 	int func_id = adapter->portnum;
 
@@ -506,10 +515,9 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 		adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
 			cpu_to_le32(rds_ring->num_desc);
 	}
-	adapter->ctx_desc->sts_ring_addr =
-		cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
-	adapter->ctx_desc->sts_ring_size =
-		cpu_to_le32(adapter->num_rxd);
+	sds_ring = &recv_ctx->sds_rings[0];
+	adapter->ctx_desc->sts_ring_addr = cpu_to_le64(sds_ring->phys_addr);
+	adapter->ctx_desc->sts_ring_size = cpu_to_le32(sds_ring->num_desc);
 
 	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_LO(func_id),
 			lower32(adapter->ctx_desc_phys_addr));
@@ -534,6 +542,10 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	int ring;
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
+	struct nx_host_sds_ring *sds_ring;
+
+	struct pci_dev *pdev = adapter->pdev;
+	struct net_device *netdev = adapter->netdev;
 
 	err = netxen_receive_peg_ready(adapter);
 	if (err) {
@@ -542,12 +554,12 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		return err;
 	}
 
-	addr = pci_alloc_consistent(adapter->pdev,
+	addr = pci_alloc_consistent(pdev,
 			sizeof(struct netxen_ring_ctx) + sizeof(uint32_t),
 			&adapter->ctx_desc_phys_addr);
 
 	if (addr == NULL) {
-		DPRINTK(ERR, "failed to allocate hw context\n");
+		dev_err(&pdev->dev, "failed to allocate hw context\n");
 		return -ENOMEM;
 	}
 	memset(addr, 0, sizeof(struct netxen_ring_ctx));
@@ -560,14 +572,13 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		(__le32 *)(((char *)addr) + sizeof(struct netxen_ring_ctx));
 
 	/* cmd desc ring */
-	addr = pci_alloc_consistent(adapter->pdev,
-			sizeof(struct cmd_desc_type0) *
-			adapter->num_txd,
+	addr = pci_alloc_consistent(pdev,
+			TX_DESC_RINGSIZE(adapter),
 			&hw->cmd_desc_phys_addr);
 
 	if (addr == NULL) {
-		printk(KERN_ERR "%s failed to allocate tx desc ring\n",
-				netxen_nic_driver_name);
+		dev_err(&pdev->dev, "%s: failed to allocate tx desc ring\n",
+				netdev->name);
 		return -ENOMEM;
 	}
 
@@ -576,15 +587,14 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	recv_ctx = &adapter->recv_ctx;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		/* rx desc ring */
 		rds_ring = &recv_ctx->rds_rings[ring];
 		addr = pci_alloc_consistent(adapter->pdev,
-				RCV_DESC_RINGSIZE,
+				RCV_DESC_RINGSIZE(rds_ring),
 				&rds_ring->phys_addr);
 		if (addr == NULL) {
-			printk(KERN_ERR "%s failed to allocate rx "
-				"desc ring[%d]\n",
-				netxen_nic_driver_name, ring);
+			dev_err(&pdev->dev,
+				"%s: failed to allocate rds ring [%d]\n",
+				netdev->name, ring);
 			err = -ENOMEM;
 			goto err_out_free;
 		}
@@ -596,22 +606,22 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 				crb_rcv_producer[ring];
 	}
 
-	/* status desc ring */
-	addr = pci_alloc_consistent(adapter->pdev,
-			STATUS_DESC_RINGSIZE,
-			&recv_ctx->rcv_status_desc_phys_addr);
-	if (addr == NULL) {
-		printk(KERN_ERR "%s failed to allocate sts desc ring\n",
-				netxen_nic_driver_name);
-		err = -ENOMEM;
-		goto err_out_free;
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+
+		addr = pci_alloc_consistent(adapter->pdev,
+				STATUS_DESC_RINGSIZE(sds_ring),
+				&sds_ring->phys_addr);
+		if (addr == NULL) {
+			dev_err(&pdev->dev,
+				"%s: failed to allocate sds ring [%d]\n",
+				netdev->name, ring);
+			err = -ENOMEM;
+			goto err_out_free;
+		}
+		sds_ring->desc_head = (struct status_desc *)addr;
 	}
-	recv_ctx->rcv_status_desc_head = (struct status_desc *)addr;
 
-	if (adapter->fw_major < 4)
-		recv_ctx->crb_sts_consumer =
-			recv_crb_registers[adapter->portnum].
-			crb_sts_consumer;
 
 	if (adapter->fw_major >= 4) {
 		adapter->intr_scheme = INTR_SCHEME_PERPORT;
@@ -624,12 +634,16 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		if (err)
 			goto err_out_free;
 	} else {
+		sds_ring = &recv_ctx->sds_rings[0];
+		sds_ring->crb_sts_consumer =
+			recv_crb_registers[adapter->portnum].crb_sts_consumer;
 
 		adapter->intr_scheme = adapter->pci_read_normalize(adapter,
 				CRB_NIC_CAPABILITIES_FW);
 		adapter->msi_mode = adapter->pci_read_normalize(adapter,
 				CRB_NIC_MSI_MODE_FW);
-		adapter->crb_intr_mask = sw_int_mask[adapter->portnum];
+		recv_ctx->sds_rings[0].crb_intr_mask =
+				sw_int_mask[adapter->portnum];
 
 		err = netxen_init_old_ctx(adapter);
 		if (err) {
@@ -650,6 +664,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
+	struct nx_host_sds_ring *sds_ring;
 	int ring;
 
 	if (adapter->fw_major >= 4) {
@@ -681,19 +696,23 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 
 		if (rds_ring->desc_head != NULL) {
 			pci_free_consistent(adapter->pdev,
-					RCV_DESC_RINGSIZE,
+					RCV_DESC_RINGSIZE(rds_ring),
 					rds_ring->desc_head,
 					rds_ring->phys_addr);
 			rds_ring->desc_head = NULL;
 		}
 	}
 
-	if (recv_ctx->rcv_status_desc_head != NULL) {
-		pci_free_consistent(adapter->pdev,
-				STATUS_DESC_RINGSIZE,
-				recv_ctx->rcv_status_desc_head,
-				recv_ctx->rcv_status_desc_phys_addr);
-		recv_ctx->rcv_status_desc_head = NULL;
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+
+		if (sds_ring->desc_head != NULL) {
+			pci_free_consistent(adapter->pdev,
+				STATUS_DESC_RINGSIZE(sds_ring),
+				sds_ring->desc_head,
+				sds_ring->phys_addr);
+			sds_ring->desc_head = NULL;
+		}
 	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index cea7300..c89c791 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -670,6 +670,53 @@ int netxen_config_intr_coalesce(struct netxen_adapter *adapter)
 	return rv;
 }
 
+#define RSS_HASHTYPE_IP_TCP	0x3
+
+int netxen_config_rss(struct netxen_adapter *adapter, int enable)
+{
+	nx_nic_req_t req;
+	u64 word;
+	int i, rv;
+
+	u64 key[] = { 0xbeac01fa6a42b73bULL, 0x8030f20c77cb2da3ULL,
+			0xae7b30b4d0ca2bcbULL, 0x43a38fb04167253dULL,
+			0x255b0ec26d5a56daULL };
+
+
+	memset(&req, 0, sizeof(nx_nic_req_t));
+	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
+
+	word = NX_NIC_H2C_OPCODE_CONFIG_RSS | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	/*
+	 * RSS request:
+	 * bits 3-0: hash_method
+	 *      5-4: hash_type_ipv4
+	 *	7-6: hash_type_ipv6
+	 *	  8: enable
+	 *        9: use indirection table
+	 *    47-10: reserved
+	 *    63-48: indirection table mask
+	 */
+	word =  ((u64)(RSS_HASHTYPE_IP_TCP & 0x3) << 4) |
+		((u64)(RSS_HASHTYPE_IP_TCP & 0x3) << 6) |
+		((u64)(enable & 0x1) << 8) |
+		((0x7ULL) << 48);
+	req.words[0] = cpu_to_le64(word);
+	for (i = 0; i < 5; i++)
+		req.words[i+1] = cpu_to_le64(key[i]);
+
+
+	rv = netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0) {
+		printk(KERN_ERR "%s: could not configure RSS\n",
+				adapter->netdev->name);
+	}
+
+	return rv;
+}
+
 /*
  * netxen_nic_change_mtu - Change the Maximum Transfer Unit
  * @returns 0 on success, negative on failure
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 1b8f79f..0759c35 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -50,7 +50,8 @@ static unsigned int crb_addr_xform[NETXEN_MAX_CRB_XFORM];
 #define NETXEN_NIC_XDMA_RESET 0x8000ff
 
 static void
-netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ringid);
+netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
+		struct nx_host_rds_ring *rds_ring);
 
 static void crb_addr_transform_setup(void)
 {
@@ -222,19 +223,21 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
 	struct nx_host_rds_ring *rds_ring;
+	struct nx_host_sds_ring *sds_ring;
 	struct netxen_rx_buffer *rx_buf;
 	int ring, i, num_rx_bufs;
 
 	struct netxen_cmd_buffer *cmd_buf_arr;
 	struct net_device *netdev = adapter->netdev;
 
-	cmd_buf_arr = (struct netxen_cmd_buffer *)vmalloc(TX_RINGSIZE);
+	cmd_buf_arr =
+		(struct netxen_cmd_buffer *)vmalloc(TX_BUFF_RINGSIZE(adapter));
 	if (cmd_buf_arr == NULL) {
 		printk(KERN_ERR "%s: Failed to allocate cmd buffer ring\n",
 		       netdev->name);
 		return -ENOMEM;
 	}
-	memset(cmd_buf_arr, 0, TX_RINGSIZE);
+	memset(cmd_buf_arr, 0, TX_BUFF_RINGSIZE(adapter));
 	adapter->cmd_buf_arr = cmd_buf_arr;
 
 	recv_ctx = &adapter->recv_ctx;
@@ -275,7 +278,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 
 		}
 		rds_ring->rx_buf_arr = (struct netxen_rx_buffer *)
-			vmalloc(RCV_BUFFSIZE);
+			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
 			printk(KERN_ERR "%s: Failed to allocate "
 				"rx buffer ring %d\n",
@@ -283,7 +286,7 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			/* free whatever was already allocated */
 			goto err_out;
 		}
-		memset(rds_ring->rx_buf_arr, 0, RCV_BUFFSIZE);
+		memset(rds_ring->rx_buf_arr, 0, RCV_BUFF_RINGSIZE(rds_ring));
 		INIT_LIST_HEAD(&rds_ring->free_list);
 		/*
 		 * Now go through all of them, set reference handles
@@ -298,6 +301,19 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 			rx_buf->state = NETXEN_BUFFER_FREE;
 			rx_buf++;
 		}
+		spin_lock_init(&rds_ring->lock);
+	}
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		sds_ring->irq = adapter->msix_entries[ring].vector;
+		sds_ring->clean_tx = (ring == 0);
+		sds_ring->post_rxd = (ring == 0);
+		sds_ring->adapter = adapter;
+		sds_ring->num_desc = adapter->num_rxd;
+
+		for (i = 0; i < NUM_RCV_DESC_RINGS; i++)
+			INIT_LIST_HEAD(&sds_ring->free_list[i]);
 	}
 
 	return 0;
@@ -793,6 +809,40 @@ int netxen_receive_peg_ready(struct netxen_adapter *adapter)
 	return 0;
 }
 
+static int
+netxen_alloc_rx_skb(struct netxen_adapter *adapter,
+		struct nx_host_rds_ring *rds_ring,
+		struct netxen_rx_buffer *buffer)
+{
+	struct sk_buff *skb;
+	dma_addr_t dma;
+	struct pci_dev *pdev = adapter->pdev;
+
+	buffer->skb = dev_alloc_skb(rds_ring->skb_size);
+	if (!buffer->skb)
+		return 1;
+
+	skb = buffer->skb;
+
+	if (!adapter->ahw.cut_through)
+		skb_reserve(skb, 2);
+
+	dma = pci_map_single(pdev, skb->data,
+			rds_ring->dma_size, PCI_DMA_FROMDEVICE);
+
+	if (pci_dma_mapping_error(pdev, dma)) {
+		dev_kfree_skb_any(skb);
+		buffer->skb = NULL;
+		return 1;
+	}
+
+	buffer->skb = skb;
+	buffer->dma = dma;
+	buffer->state = NETXEN_BUFFER_BUSY;
+
+	return 0;
+}
+
 static struct sk_buff *netxen_process_rxbuf(struct netxen_adapter *adapter,
 		struct nx_host_rds_ring *rds_ring, u16 index, u16 cksum)
 {
@@ -817,14 +867,12 @@ static struct sk_buff *netxen_process_rxbuf(struct netxen_adapter *adapter,
 	skb->dev = adapter->netdev;
 
 	buffer->skb = NULL;
-
 no_skb:
 	buffer->state = NETXEN_BUFFER_FREE;
-	list_add_tail(&buffer->list, &rds_ring->free_list);
 	return skb;
 }
 
-static void
+static struct netxen_rx_buffer *
 netxen_process_rcv(struct netxen_adapter *adapter,
 		int ring, int index, int length, int cksum, int pkt_offset)
 {
@@ -835,13 +883,13 @@ netxen_process_rcv(struct netxen_adapter *adapter,
 	struct nx_host_rds_ring *rds_ring = &recv_ctx->rds_rings[ring];
 
 	if (unlikely(index > rds_ring->num_desc))
-		return;
+		return NULL;
 
 	buffer = &rds_ring->rx_buf_arr[index];
 
 	skb = netxen_process_rxbuf(adapter, rds_ring, index, cksum);
 	if (!skb)
-		return;
+		return buffer;
 
 	if (length > rds_ring->skb_size)
 		skb_put(skb, rds_ring->skb_size);
@@ -858,21 +906,31 @@ netxen_process_rcv(struct netxen_adapter *adapter,
 
 	adapter->stats.no_rcv++;
 	adapter->stats.rxbytes += length;
+
+	return buffer;
 }
 
+#define netxen_merge_rx_buffers(list, head) \
+	do { list_splice_tail_init(list, head); } while (0);
+
 int
-netxen_process_rcv_ring(struct netxen_adapter *adapter, int max)
+netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max)
 {
-	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
-	struct status_desc *desc_head = recv_ctx->rcv_status_desc_head;
+	struct netxen_adapter *adapter = sds_ring->adapter;
+
+	struct list_head *cur;
+
 	struct status_desc *desc;
-	u32 consumer = recv_ctx->status_rx_consumer;
+	struct netxen_rx_buffer *rxbuf;
+
+	u32 consumer = sds_ring->consumer;
+
 	int count = 0;
 	u64 sts_data;
 	int opcode, ring, index, length, cksum, pkt_offset;
 
 	while (count < max) {
-		desc = &desc_head[consumer];
+		desc = &sds_ring->desc_head[consumer];
 		sts_data = le64_to_cpu(desc->status_desc_data);
 
 		if (!(sts_data & STATUS_OWNER_HOST))
@@ -889,22 +947,41 @@ netxen_process_rcv_ring(struct netxen_adapter *adapter, int max)
 		cksum  = netxen_get_sts_status(sts_data);
 		pkt_offset = netxen_get_sts_pkt_offset(sts_data);
 
-		netxen_process_rcv(adapter, ring, index,
+		rxbuf = netxen_process_rcv(adapter, ring, index,
 				length, cksum, pkt_offset);
 
+		if (rxbuf)
+			list_add_tail(&rxbuf->list, &sds_ring->free_list[ring]);
+
 		desc->status_desc_data = cpu_to_le64(STATUS_OWNER_PHANTOM);
 
-		consumer = get_next_index(consumer, adapter->num_rxd);
+		consumer = get_next_index(consumer, sds_ring->num_desc);
 		count++;
 	}
 
-	for (ring = 0; ring < adapter->max_rds_rings; ring++)
-		netxen_post_rx_buffers_nodb(adapter, ring);
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		struct nx_host_rds_ring *rds_ring =
+			&adapter->recv_ctx.rds_rings[ring];
+
+		if (!list_empty(&sds_ring->free_list[ring])) {
+			list_for_each(cur, &sds_ring->free_list[ring]) {
+				rxbuf = list_entry(cur,
+						struct netxen_rx_buffer, list);
+				netxen_alloc_rx_skb(adapter, rds_ring, rxbuf);
+			}
+			spin_lock(&rds_ring->lock);
+			netxen_merge_rx_buffers(&sds_ring->free_list[ring],
+						&rds_ring->free_list);
+			spin_unlock(&rds_ring->lock);
+		}
+
+		netxen_post_rx_buffers_nodb(adapter, rds_ring);
+	}
 
 	if (count) {
-		recv_ctx->status_rx_consumer = consumer;
+		sds_ring->consumer = consumer;
 		adapter->pci_write_normalize(adapter,
-				recv_ctx->crb_sts_consumer, consumer);
+				sds_ring->crb_sts_consumer, consumer);
 	}
 
 	return count;
@@ -921,6 +998,9 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	struct netxen_skb_frag *frag;
 	int done = 0;
 
+	if (!spin_trylock(&adapter->tx_clean_lock))
+		return 1;
+
 	last_consumer = adapter->last_cmd_consumer;
 	barrier(); /* cmd_consumer can change underneath */
 	consumer = le32_to_cpu(*(adapter->cmd_consumer));
@@ -976,63 +1056,46 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	barrier(); /* cmd_consumer can change underneath */
 	consumer = le32_to_cpu(*(adapter->cmd_consumer));
 	done = (last_consumer == consumer);
+	spin_unlock(&adapter->tx_clean_lock);
 
 	return (done);
 }
 
 void
-netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid)
+netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
+	struct nx_host_rds_ring *rds_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
-	struct sk_buff *skb;
-	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
-	struct nx_host_rds_ring *rds_ring = NULL;
-	uint producer;
 	struct rcv_desc *pdesc;
 	struct netxen_rx_buffer *buffer;
-	int count = 0;
+	int producer, count = 0;
 	netxen_ctx_msg msg = 0;
-	dma_addr_t dma;
 	struct list_head *head;
 
-	rds_ring = &recv_ctx->rds_rings[ringid];
-
 	producer = rds_ring->producer;
-	head = &rds_ring->free_list;
 
+	spin_lock(&rds_ring->lock);
+	head = &rds_ring->free_list;
 	while (!list_empty(head)) {
 
-		skb = dev_alloc_skb(rds_ring->skb_size);
-		if (unlikely(!skb)) {
-			break;
-		}
-
-		if (!adapter->ahw.cut_through)
-			skb_reserve(skb, 2);
+		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
 
-		dma = pci_map_single(pdev, skb->data,
-				rds_ring->dma_size, PCI_DMA_FROMDEVICE);
-		if (pci_dma_mapping_error(pdev, dma)) {
-			dev_kfree_skb_any(skb);
-			break;
+		if (!buffer->skb) {
+			if (netxen_alloc_rx_skb(adapter, rds_ring, buffer))
+				break;
 		}
 
 		count++;
-		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
 		list_del(&buffer->list);
 
-		buffer->skb = skb;
-		buffer->state = NETXEN_BUFFER_BUSY;
-		buffer->dma = dma;
-
 		/* make a rcv descriptor  */
 		pdesc = &rds_ring->desc_head[producer];
-		pdesc->addr_buffer = cpu_to_le64(dma);
+		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
 		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
 		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 
 		producer = get_next_index(producer, rds_ring->num_desc);
 	}
+	spin_unlock(&rds_ring->lock);
 
 	if (count) {
 		rds_ring->producer = producer;
@@ -1061,48 +1124,31 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid)
 }
 
 static void
-netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ringid)
+netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
+		struct nx_host_rds_ring *rds_ring)
 {
-	struct pci_dev *pdev = adapter->pdev;
-	struct sk_buff *skb;
-	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
-	struct nx_host_rds_ring *rds_ring = NULL;
-	u32 producer;
 	struct rcv_desc *pdesc;
 	struct netxen_rx_buffer *buffer;
-	int count = 0;
+	int producer, count = 0;
 	struct list_head *head;
-	dma_addr_t dma;
-
-	rds_ring = &recv_ctx->rds_rings[ringid];
 
 	producer = rds_ring->producer;
+	if (!spin_trylock(&rds_ring->lock))
+		return;
+
 	head = &rds_ring->free_list;
 	while (!list_empty(head)) {
 
-		skb = dev_alloc_skb(rds_ring->skb_size);
-		if (unlikely(!skb)) {
-			break;
-		}
-
-		if (!adapter->ahw.cut_through)
-			skb_reserve(skb, 2);
+		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
 
-		dma = pci_map_single(pdev, skb->data,
-				rds_ring->dma_size, PCI_DMA_FROMDEVICE);
-		if (pci_dma_mapping_error(pdev, dma)) {
-			dev_kfree_skb_any(skb);
-			break;
+		if (!buffer->skb) {
+			if (netxen_alloc_rx_skb(adapter, rds_ring, buffer))
+				break;
 		}
 
 		count++;
-		buffer = list_entry(head->next, struct netxen_rx_buffer, list);
 		list_del(&buffer->list);
 
-		buffer->skb = skb;
-		buffer->state = NETXEN_BUFFER_BUSY;
-		buffer->dma = dma;
-
 		/* make a rcv descriptor  */
 		pdesc = &rds_ring->desc_head[producer];
 		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
@@ -1119,6 +1165,7 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter, uint32_t ringid)
 				(producer - 1) & (rds_ring->num_desc - 1));
 			wmb();
 	}
+	spin_unlock(&rds_ring->lock);
 }
 
 void netxen_nic_clear_stats(struct netxen_adapter *adapter)
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 00eaeee..274d1e0 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -135,20 +135,71 @@ static uint32_t msi_tgt_status[8] = {
 
 static struct netxen_legacy_intr_set legacy_intr[] = NX_LEGACY_INTR_CONFIG;
 
-static inline void netxen_nic_disable_int(struct netxen_adapter *adapter)
+static inline void netxen_nic_disable_int(struct nx_host_sds_ring *sds_ring)
 {
-	adapter->pci_write_normalize(adapter, adapter->crb_intr_mask, 0);
+	struct netxen_adapter *adapter = sds_ring->adapter;
+
+	adapter->pci_write_normalize(adapter, sds_ring->crb_intr_mask, 0);
 }
 
-static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
+static inline void netxen_nic_enable_int(struct nx_host_sds_ring *sds_ring)
 {
-	adapter->pci_write_normalize(adapter, adapter->crb_intr_mask, 0x1);
+	struct netxen_adapter *adapter = sds_ring->adapter;
+
+	adapter->pci_write_normalize(adapter, sds_ring->crb_intr_mask, 0x1);
 
 	if (!NETXEN_IS_MSI_FAMILY(adapter))
 		adapter->pci_write_immediate(adapter,
 				adapter->legacy_intr.tgt_mask_reg, 0xfbff);
 }
 
+static void
+netxen_napi_add(struct netxen_adapter *adapter, struct net_device *netdev)
+{
+	int ring;
+	struct nx_host_sds_ring *sds_ring;
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+
+	if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
+		adapter->max_sds_rings = (num_online_cpus() >= 4) ? 4 : 2;
+	else
+		adapter->max_sds_rings = 1;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		netif_napi_add(netdev, &sds_ring->napi,
+				netxen_nic_poll, NETXEN_NETDEV_WEIGHT);
+	}
+}
+
+static void
+netxen_napi_enable(struct netxen_adapter *adapter)
+{
+	int ring;
+	struct nx_host_sds_ring *sds_ring;
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		napi_enable(&sds_ring->napi);
+		netxen_nic_enable_int(sds_ring);
+	}
+}
+
+static void
+netxen_napi_disable(struct netxen_adapter *adapter)
+{
+	int ring;
+	struct nx_host_sds_ring *sds_ring;
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		netxen_nic_disable_int(sds_ring);
+		napi_disable(&sds_ring->napi);
+	}
+}
+
 static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
 {
 	struct pci_dev *pdev = adapter->pdev;
@@ -226,7 +277,6 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS;
 	adapter->num_lro_rxd = MAX_LRO_RCV_DESCRIPTORS;
 
-	adapter->max_possible_rss_rings = 1;
 	return;
 }
 
@@ -447,6 +497,7 @@ request_msi:
 			dev_info(&pdev->dev, "using msi interrupts\n");
 		} else
 			dev_info(&pdev->dev, "using legacy interrupts\n");
+		adapter->msix_entries[0].vector = pdev->irq;
 	}
 }
 
@@ -671,8 +722,12 @@ static int
 netxen_nic_request_irq(struct netxen_adapter *adapter)
 {
 	irq_handler_t handler;
+	struct nx_host_sds_ring *sds_ring;
+	int err, ring;
+
 	unsigned long flags = IRQF_SAMPLE_RANDOM;
 	struct net_device *netdev = adapter->netdev;
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
 	if ((adapter->msi_mode != MSI_MODE_MULTIFUNC) ||
 		(adapter->intr_scheme != INTR_SCHEME_PERPORT)) {
@@ -693,8 +748,30 @@ netxen_nic_request_irq(struct netxen_adapter *adapter)
 	}
 	adapter->irq = netdev->irq;
 
-	return request_irq(adapter->irq, handler,
-			  flags, netdev->name, adapter);
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		sprintf(sds_ring->name, "%16s[%d]", netdev->name, ring);
+		err = request_irq(sds_ring->irq, handler,
+				  flags, sds_ring->name, sds_ring);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static void
+netxen_nic_free_irq(struct netxen_adapter *adapter)
+{
+	int ring;
+	struct nx_host_sds_ring *sds_ring;
+
+	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		free_irq(sds_ring->irq, sds_ring);
+	}
 }
 
 static int
@@ -719,8 +796,10 @@ netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 	adapter->ahw.linkup = 0;
 	mod_timer(&adapter->watchdog_timer, jiffies);
 
-	napi_enable(&adapter->napi);
-	netxen_nic_enable_int(adapter);
+	netxen_napi_enable(adapter);
+
+	if (adapter->max_sds_rings > 1)
+		netxen_config_rss(adapter, 1);
 
 	return 0;
 }
@@ -730,13 +809,11 @@ netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 {
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
-	napi_disable(&adapter->napi);
+	netxen_napi_disable(adapter);
 
 	if (adapter->stop_port)
 		adapter->stop_port(adapter);
 
-	netxen_nic_disable_int(adapter);
-
 	netxen_release_tx_buffers(adapter);
 
 	FLUSH_SCHEDULED_WORK();
@@ -750,6 +827,7 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	int err, ring;
+	struct nx_host_rds_ring *rds_ring;
 
 	err = netxen_init_firmware(adapter);
 	if (err != 0) {
@@ -788,8 +866,10 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 		netxen_nic_update_cmd_consumer(adapter, 0);
 	}
 
-	for (ring = 0; ring < adapter->max_rds_rings; ring++)
-		netxen_post_rx_buffers(adapter, ring);
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &adapter->recv_ctx.rds_rings[ring];
+		netxen_post_rx_buffers(adapter, ring, rds_ring);
+	}
 
 	err = netxen_nic_request_irq(adapter);
 	if (err) {
@@ -812,8 +892,7 @@ err_out_free_sw:
 static void
 netxen_nic_detach(struct netxen_adapter *adapter)
 {
-	if (adapter->irq)
-		free_irq(adapter->irq, adapter);
+	netxen_nic_free_irq(adapter);
 
 	netxen_release_rx_buffers(adapter);
 	netxen_free_hw_resources(adapter);
@@ -883,14 +962,12 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_free_netdev;
 
 	rwlock_init(&adapter->adapter_lock);
+	spin_lock_init(&adapter->tx_clean_lock);
 
 	err = netxen_setup_pci_map(adapter);
 	if (err)
 		goto err_out_free_netdev;
 
-	netif_napi_add(netdev, &adapter->napi,
-			netxen_nic_poll, NETXEN_NETDEV_WEIGHT);
-
 	/* This will be reset for mezz cards  */
 	adapter->portnum = pci_func_id;
 	adapter->rx_csum = 1;
@@ -963,10 +1040,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netxen_setup_intr(adapter);
 
-	if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
-		netdev->irq = adapter->msix_entries[0].vector;
-	else
-		netdev->irq = pdev->irq;
+	netdev->irq = adapter->msix_entries[0].vector;
+
+	netxen_napi_add(adapter, netdev);
 
 	err = netxen_receive_peg_ready(adapter);
 	if (err)
@@ -1520,13 +1596,11 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 	printk(KERN_ERR "%s %s: transmit timeout, resetting.\n",
 	       netxen_nic_driver_name, adapter->netdev->name);
 
-	netxen_nic_disable_int(adapter);
-	napi_disable(&adapter->napi);
+	netxen_napi_disable(adapter);
 
 	adapter->netdev->trans_start = jiffies;
 
-	napi_enable(&adapter->napi);
-	netxen_nic_enable_int(adapter);
+	netxen_napi_enable(adapter);
 	netif_wake_queue(adapter->netdev);
 }
 
@@ -1564,7 +1638,8 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 
 static irqreturn_t netxen_intr(int irq, void *data)
 {
-	struct netxen_adapter *adapter = data;
+	struct nx_host_sds_ring *sds_ring = data;
+	struct netxen_adapter *adapter = sds_ring->adapter;
 	u32 status = 0;
 
 	status = adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
@@ -1595,7 +1670,7 @@ static irqreturn_t netxen_intr(int irq, void *data)
 
 	/* clear interrupt */
 	if (adapter->fw_major < 4)
-		netxen_nic_disable_int(adapter);
+		netxen_nic_disable_int(sds_ring);
 
 	adapter->pci_write_immediate(adapter,
 			adapter->legacy_intr.tgt_status_reg,
@@ -1604,45 +1679,49 @@ static irqreturn_t netxen_intr(int irq, void *data)
 	adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
 	adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
 
-	napi_schedule(&adapter->napi);
+	napi_schedule(&sds_ring->napi);
 
 	return IRQ_HANDLED;
 }
 
 static irqreturn_t netxen_msi_intr(int irq, void *data)
 {
-	struct netxen_adapter *adapter = data;
+	struct nx_host_sds_ring *sds_ring = data;
+	struct netxen_adapter *adapter = sds_ring->adapter;
 
 	/* clear interrupt */
 	adapter->pci_write_immediate(adapter,
 			msi_tgt_status[adapter->ahw.pci_func], 0xffffffff);
 
-	napi_schedule(&adapter->napi);
+	napi_schedule(&sds_ring->napi);
 	return IRQ_HANDLED;
 }
 
 static irqreturn_t netxen_msix_intr(int irq, void *data)
 {
-	struct netxen_adapter *adapter = data;
+	struct nx_host_sds_ring *sds_ring = data;
 
-	napi_schedule(&adapter->napi);
+	napi_schedule(&sds_ring->napi);
 	return IRQ_HANDLED;
 }
 
 static int netxen_nic_poll(struct napi_struct *napi, int budget)
 {
-	struct netxen_adapter *adapter =
-		container_of(napi, struct netxen_adapter, napi);
+	struct nx_host_sds_ring *sds_ring =
+		container_of(napi, struct nx_host_sds_ring, napi);
+
+	struct netxen_adapter *adapter = sds_ring->adapter;
+
 	int tx_complete;
 	int work_done;
 
 	tx_complete = netxen_process_cmd_ring(adapter);
 
-	work_done = netxen_process_rcv_ring(adapter, budget);
+	work_done = netxen_process_rcv_ring(sds_ring, budget);
 
 	if ((work_done < budget) && tx_complete) {
-		napi_complete(&adapter->napi);
-		netxen_nic_enable_int(adapter);
+		napi_complete(&sds_ring->napi);
+		netxen_nic_enable_int(sds_ring);
 	}
 
 	return work_done;
-- 
1.6.0.2

