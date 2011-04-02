From: anirban.chakraborty@qlogic.com
Subject: [PATCH 3/9 net-next-2.6] qlcnic: Cleanup patch
Date: Fri,  1 Apr 2011 17:07:10 -0700
Message-ID: <1301702836-3265-3-git-send-email-anirban.chakraborty@qlogic.com>
References: <1301702836-3265-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: davem@davemloft.com, Dept_NX_Linux_NIC_driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:34113 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1753702Ab1DBAZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 20:25:16 -0400
In-Reply-To: <1301702836-3265-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

 1. Changed adapter structure to move away from embedding hardware and
    receive context structs and use pointers to those objects
 2. Packed all the structs that interface with FW
 3. Removed unused code and structs

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |  126 +++++++++-------------------
 drivers/net/qlcnic/qlcnic_ctx.c     |  135 +++++++++++++++---------------
 drivers/net/qlcnic/qlcnic_ethtool.c |   40 +++++-----
 drivers/net/qlcnic/qlcnic_hw.c      |   56 ++++++------
 drivers/net/qlcnic/qlcnic_init.c    |   26 +++---
 drivers/net/qlcnic/qlcnic_main.c    |  158 ++++++++++++++++++++++-------------
 6 files changed, 268 insertions(+), 273 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index dc44564..15d950a 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -93,8 +93,6 @@
 #define TX_IP_PKT	0x04
 #define TX_TCP_LSO	0x05
 #define TX_TCP_LSO6	0x06
-#define TX_IPSEC	0x07
-#define TX_IPSEC_CMD	0x0a
 #define TX_TCPV6_PKT	0x0b
 #define TX_UDPV6_PKT	0x0c
 
@@ -200,7 +198,7 @@ struct rcv_desc {
 	__le16 reserved;
 	__le32 buffer_length;	/* allocated buffer length (usually 2K) */
 	__le64 addr_buffer;
-};
+} __packed;
 
 /* opcode field in status_desc */
 #define QLCNIC_SYN_OFFLOAD	0x03
@@ -365,12 +363,6 @@ struct qlcnic_skb_frag {
 	u64 length;
 };
 
-struct qlcnic_recv_crb {
-	u32 crb_rcv_producer[NUM_RCV_DESC_RINGS];
-	u32 crb_sts_consumer[NUM_STS_DESC_RINGS];
-	u32 sw_int_mask[NUM_STS_DESC_RINGS];
-};
-
 /*    Following defines are for the state of the buffers    */
 #define	QLCNIC_BUFFER_FREE	0
 #define	QLCNIC_BUFFER_BUSY	1
@@ -387,10 +379,10 @@ struct qlcnic_cmd_buffer {
 
 /* In rx_buffer, we do not need multiple fragments as is a single buffer */
 struct qlcnic_rx_buffer {
-	struct list_head list;
+	u16 ref_handle;
 	struct sk_buff *skb;
+	struct list_head list;
 	u64 dma;
-	u16 ref_handle;
 };
 
 /* Board types */
@@ -494,12 +486,12 @@ struct qlcnic_host_tx_ring {
  * present elsewhere.
  */
 struct qlcnic_recv_context {
+	struct qlcnic_host_rds_ring *rds_rings;
+	struct qlcnic_host_sds_ring *sds_rings;
 	u32 state;
 	u16 context_id;
 	u16 virt_port;
 
-	struct qlcnic_host_rds_ring *rds_rings;
-	struct qlcnic_host_sds_ring *sds_rings;
 };
 
 /* HW context creation */
@@ -538,9 +530,6 @@ struct qlcnic_recv_context {
 #define QLCNIC_CDRP_CMD_DESTROY_RX_CTX          0x00000008
 #define QLCNIC_CDRP_CMD_CREATE_TX_CTX           0x00000009
 #define QLCNIC_CDRP_CMD_DESTROY_TX_CTX          0x0000000a
-#define QLCNIC_CDRP_CMD_SETUP_STATISTICS        0x0000000e
-#define QLCNIC_CDRP_CMD_GET_STATISTICS          0x0000000f
-#define QLCNIC_CDRP_CMD_DELETE_STATISTICS       0x00000010
 #define QLCNIC_CDRP_CMD_SET_MTU                 0x00000012
 #define QLCNIC_CDRP_CMD_READ_PHY		0x00000013
 #define QLCNIC_CDRP_CMD_WRITE_PHY		0x00000014
@@ -549,17 +538,11 @@ struct qlcnic_recv_context {
 #define QLCNIC_CDRP_CMD_SET_FLOW_CTL		0x00000017
 #define QLCNIC_CDRP_CMD_READ_MAX_MTU		0x00000018
 #define QLCNIC_CDRP_CMD_READ_MAX_LRO		0x00000019
-#define QLCNIC_CDRP_CMD_CONFIGURE_TOE		0x0000001a
-#define QLCNIC_CDRP_CMD_FUNC_ATTRIB		0x0000001b
-#define QLCNIC_CDRP_CMD_READ_PEXQ_PARAMETERS	0x0000001c
-#define QLCNIC_CDRP_CMD_GET_LIC_CAPABILITIES	0x0000001d
-#define QLCNIC_CDRP_CMD_READ_MAX_LRO_PER_BOARD	0x0000001e
 #define QLCNIC_CDRP_CMD_MAC_ADDRESS		0x0000001f
 
 #define QLCNIC_CDRP_CMD_GET_PCI_INFO		0x00000020
 #define QLCNIC_CDRP_CMD_GET_NIC_INFO		0x00000021
 #define QLCNIC_CDRP_CMD_SET_NIC_INFO		0x00000022
-#define QLCNIC_CDRP_CMD_RESET_NPAR		0x00000023
 #define QLCNIC_CDRP_CMD_GET_ESWITCH_CAPABILITY	0x00000024
 #define QLCNIC_CDRP_CMD_TOGGLE_ESWITCH		0x00000025
 #define QLCNIC_CDRP_CMD_GET_ESWITCH_STATUS	0x00000026
@@ -597,14 +580,14 @@ struct qlcnic_hostrq_sds_ring {
 	__le32 ring_size;		/* Ring entries */
 	__le16 msi_index;
 	__le16 rsvd;		/* Padding */
-};
+} __packed;
 
 struct qlcnic_hostrq_rds_ring {
 	__le64 host_phys_addr;	/* Ring base addr */
 	__le64 buff_size;		/* Packet buffer size */
 	__le32 ring_size;		/* Ring entries */
 	__le32 ring_kind;		/* Class of ring */
-};
+} __packed;
 
 struct qlcnic_hostrq_rx_ctx {
 	__le64 host_rsp_dma_addr;	/* Response dma'd here */
@@ -625,17 +608,17 @@ struct qlcnic_hostrq_rx_ctx {
 	   - N hostrq_rds_rings
 	   - N hostrq_sds_rings */
 	char data[0];
-};
+} __packed;
 
 struct qlcnic_cardrsp_rds_ring{
 	__le32 host_producer_crb;	/* Crb to use */
 	__le32 rsvd1;		/* Padding */
-};
+} __packed;
 
 struct qlcnic_cardrsp_sds_ring {
 	__le32 host_consumer_crb;	/* Crb to use */
 	__le32 interrupt_crb;	/* Crb to use */
-};
+} __packed;
 
 struct qlcnic_cardrsp_rx_ctx {
 	/* These ring offsets are relative to data[0] below */
@@ -654,7 +637,7 @@ struct qlcnic_cardrsp_rx_ctx {
 	   - N cardrsp_rds_rings
 	   - N cardrs_sds_rings */
 	char data[0];
-};
+} __packed;
 
 #define SIZEOF_HOSTRQ_RX(HOSTRQ_RX, rds_rings, sds_rings)	\
 	(sizeof(HOSTRQ_RX) + 					\
@@ -674,7 +657,7 @@ struct qlcnic_hostrq_cds_ring {
 	__le64 host_phys_addr;	/* Ring base addr */
 	__le32 ring_size;		/* Ring entries */
 	__le32 rsvd;		/* Padding */
-};
+} __packed;
 
 struct qlcnic_hostrq_tx_ctx {
 	__le64 host_rsp_dma_addr;	/* Response dma'd here */
@@ -689,12 +672,12 @@ struct qlcnic_hostrq_tx_ctx {
 	__le16 rsvd3;		/* Padding */
 	struct qlcnic_hostrq_cds_ring cds_ring;	/* Desc of cds ring */
 	u8  reserved[128];	/* future expansion */
-};
+} __packed;
 
 struct qlcnic_cardrsp_cds_ring {
 	__le32 host_producer_crb;	/* Crb to use */
 	__le32 interrupt_crb;	/* Crb to use */
-};
+} __packed;
 
 struct qlcnic_cardrsp_tx_ctx {
 	__le32 host_ctx_state;	/* Starting state */
@@ -703,7 +686,7 @@ struct qlcnic_cardrsp_tx_ctx {
 	u8  virt_port;		/* Virtual/Logical id of port */
 	struct qlcnic_cardrsp_cds_ring cds_ring;	/* Card cds settings */
 	u8  reserved[128];	/* future expansion */
-};
+} __packed;
 
 #define SIZEOF_HOSTRQ_TX(HOSTRQ_TX)	(sizeof(HOSTRQ_TX))
 #define SIZEOF_CARDRSP_TX(CARDRSP_TX)	(sizeof(CARDRSP_TX))
@@ -782,50 +765,20 @@ struct qlcnic_nic_intr_coalesce {
 /*
  * Driver --> Firmware
  */
-#define QLCNIC_H2C_OPCODE_START 			0
-#define QLCNIC_H2C_OPCODE_CONFIG_RSS			1
-#define QLCNIC_H2C_OPCODE_CONFIG_RSS_TBL		2
-#define QLCNIC_H2C_OPCODE_CONFIG_INTR_COALESCE		3
-#define QLCNIC_H2C_OPCODE_CONFIG_LED			4
-#define QLCNIC_H2C_OPCODE_CONFIG_PROMISCUOUS		5
-#define QLCNIC_H2C_OPCODE_CONFIG_L2_MAC 		6
-#define QLCNIC_H2C_OPCODE_LRO_REQUEST			7
-#define QLCNIC_H2C_OPCODE_GET_SNMP_STATS		8
-#define QLCNIC_H2C_OPCODE_PROXY_START_REQUEST		9
-#define QLCNIC_H2C_OPCODE_PROXY_STOP_REQUEST		10
-#define QLCNIC_H2C_OPCODE_PROXY_SET_MTU 		11
-#define QLCNIC_H2C_OPCODE_PROXY_SET_VPORT_MISS_MODE	12
-#define QLCNIC_H2C_OPCODE_GET_FINGER_PRINT_REQUEST	13
-#define QLCNIC_H2C_OPCODE_INSTALL_LICENSE_REQUEST	14
-#define QLCNIC_H2C_OPCODE_GET_LICENSE_CAPABILITY_REQUEST	15
-#define QLCNIC_H2C_OPCODE_GET_NET_STATS 		16
-#define QLCNIC_H2C_OPCODE_PROXY_UPDATE_P2V		17
-#define QLCNIC_H2C_OPCODE_CONFIG_IPADDR 		18
-#define QLCNIC_H2C_OPCODE_PROXY_STOP_DONE		20
-#define QLCNIC_H2C_OPCODE_GET_LINKEVENT 		21
-#define QLCNIC_C2C_OPCODE				22
-#define QLCNIC_H2C_OPCODE_CONFIG_BRIDGING		23
-#define QLCNIC_H2C_OPCODE_CONFIG_HW_LRO 		24
-#define QLCNIC_H2C_OPCODE_LAST				25
+#define QLCNIC_H2C_OPCODE_CONFIG_RSS			0x1
+#define QLCNIC_H2C_OPCODE_CONFIG_INTR_COALESCE		0x3
+#define QLCNIC_H2C_OPCODE_CONFIG_LED			0x4
+#define QLCNIC_H2C_OPCODE_LRO_REQUEST			0x7
+#define QLCNIC_H2C_OPCODE_SET_MAC_RECEIVE_MODE		0xc
+#define QLCNIC_H2C_OPCODE_CONFIG_IPADDR		0x12
+#define QLCNIC_H2C_OPCODE_GET_LINKEVENT		0x15
+#define QLCNIC_H2C_OPCODE_CONFIG_BRIDGING		0x17
+#define QLCNIC_H2C_OPCODE_CONFIG_HW_LRO		0x18
 /*
  * Firmware --> Driver
  */
 
-#define QLCNIC_C2H_OPCODE_START 			128
-#define QLCNIC_C2H_OPCODE_CONFIG_RSS_RESPONSE		129
-#define QLCNIC_C2H_OPCODE_CONFIG_RSS_TBL_RESPONSE	130
-#define QLCNIC_C2H_OPCODE_CONFIG_MAC_RESPONSE		131
-#define QLCNIC_C2H_OPCODE_CONFIG_PROMISCUOUS_RESPONSE	132
-#define QLCNIC_C2H_OPCODE_CONFIG_L2_MAC_RESPONSE	133
-#define QLCNIC_C2H_OPCODE_LRO_DELETE_RESPONSE		134
-#define QLCNIC_C2H_OPCODE_LRO_ADD_FAILURE_RESPONSE	135
-#define QLCNIC_C2H_OPCODE_GET_SNMP_STATS		136
-#define QLCNIC_C2H_OPCODE_GET_FINGER_PRINT_REPLY	137
-#define QLCNIC_C2H_OPCODE_INSTALL_LICENSE_REPLY 	138
-#define QLCNIC_C2H_OPCODE_GET_LICENSE_CAPABILITIES_REPLY 139
-#define QLCNIC_C2H_OPCODE_GET_NET_STATS_RESPONSE	140
 #define QLCNIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	141
-#define QLCNIC_C2H_OPCODE_LAST				142
 
 #define VPORT_MISS_MODE_DROP		0 /* drop all unmatched */
 #define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
@@ -894,7 +847,7 @@ struct qlcnic_nic_req {
 	__le64 qhdr;
 	__le64 req_hdr;
 	__le64 words[6];
-};
+} __packed;
 
 struct qlcnic_mac_req {
 	u8 op;
@@ -905,7 +858,7 @@ struct qlcnic_mac_req {
 struct qlcnic_vlan_req {
 	__le16 vlan_id;
 	__le16 rsvd[3];
-};
+} __packed;
 
 struct qlcnic_ipaddr {
 	__be32 ipv4;
@@ -964,14 +917,14 @@ struct qlcnic_filter_hash {
 };
 
 struct qlcnic_adapter {
-	struct qlcnic_hardware_context ahw;
-
+	struct qlcnic_hardware_context *ahw;
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_tx_ring *tx_ring;
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct list_head mac_list;
 
-	spinlock_t tx_clean_lock;
-	spinlock_t mac_learn_lock;
+	unsigned long state;
+	u32 flags;
 
 	u16 num_txd;
 	u16 num_rxd;
@@ -989,7 +942,6 @@ struct qlcnic_adapter {
 
 	u8 mc_enabled;
 	u8 max_mc_count;
-	u8 rss_supported;
 	u8 fw_wait_cnt;
 	u8 fw_fail_cnt;
 	u8 tx_timeo_cnt;
@@ -1014,7 +966,6 @@ struct qlcnic_adapter {
 
 	u32 fw_hal_version;
 	u32 capabilities;
-	u32 flags;
 	u32 irq;
 	u32 temp;
 
@@ -1039,9 +990,7 @@ struct qlcnic_adapter {
 	struct qlcnic_nic_template *nic_ops;
 
 	struct qlcnic_adapter_stats stats;
-
-	struct qlcnic_recv_context recv_ctx;
-	struct qlcnic_host_tx_ring *tx_ring;
+	struct list_head mac_list;
 
 	void __iomem	*tgt_mask_reg;
 	void __iomem	*tgt_status_reg;
@@ -1056,7 +1005,8 @@ struct qlcnic_adapter {
 
 	struct qlcnic_filter_hash fhash;
 
-	unsigned long state;
+	spinlock_t tx_clean_lock;
+	spinlock_t mac_learn_lock;
 	__le32 file_prd_off;	/*File fw product offset*/
 	u32 fw_version;
 	const struct firmware *fw;
@@ -1078,7 +1028,7 @@ struct qlcnic_info {
 	__le16	min_tx_bw;
 	__le16	max_tx_bw;
 	u8	reserved2[104];
-};
+} __packed;
 
 struct qlcnic_pci_info {
 	__le16	id; /* pci function id */
@@ -1092,7 +1042,7 @@ struct qlcnic_pci_info {
 
 	u8	mac[ETH_ALEN];
 	u8	reserved2[106];
-};
+} __packed;
 
 struct qlcnic_npar_info {
 	u16	pvid;
@@ -1209,7 +1159,7 @@ struct __qlcnic_esw_statistics {
 	__le64 local_frames;
 	__le64 numbytes;
 	__le64 rsvd[3];
-};
+} __packed;
 
 struct qlcnic_esw_statistics {
 	struct __qlcnic_esw_statistics rx;
@@ -1293,7 +1243,7 @@ void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter);
 
 int qlcnic_check_fw_status(struct qlcnic_adapter *adapter);
 void qlcnic_watchdog_task(struct work_struct *work);
-void qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter, u32 ringid,
+void qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_rds_ring *rds_ring);
 int qlcnic_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max);
 void qlcnic_set_multi(struct net_device *netdev);
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 27631f2..050fa5a 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -67,11 +67,11 @@ qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
 int
 qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)
 {
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (recv_ctx->state == QLCNIC_HOST_CTX_STATE_ACTIVE) {
 		if (qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			recv_ctx->context_id,
 			mtu,
@@ -102,12 +102,12 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 	dma_addr_t hostrq_phys_addr, cardrsp_phys_addr;
 	u64 phys_addr;
 
-	int i, nrds_rings, nsds_rings;
+	u8 i, nrds_rings, nsds_rings;
 	size_t rq_size, rsp_size;
 	u32 cap, reg, val, reg2;
 	int err;
 
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	nrds_rings = adapter->max_rds_rings;
 	nsds_rings = adapter->max_sds_rings;
@@ -119,14 +119,14 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 		SIZEOF_CARDRSP_RX(struct qlcnic_cardrsp_rx_ctx, nrds_rings,
 						nsds_rings);
 
-	addr = pci_alloc_consistent(adapter->pdev,
-				rq_size, &hostrq_phys_addr);
+	addr = dma_alloc_coherent(&adapter->pdev->dev, rq_size,
+			&hostrq_phys_addr, GFP_KERNEL);
 	if (addr == NULL)
 		return -ENOMEM;
 	prq = (struct qlcnic_hostrq_rx_ctx *)addr;
 
-	addr = pci_alloc_consistent(adapter->pdev,
-			rsp_size, &cardrsp_phys_addr);
+	addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
+			&cardrsp_phys_addr, GFP_KERNEL);
 	if (addr == NULL) {
 		err = -ENOMEM;
 		goto out_free_rq;
@@ -151,7 +151,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 
 	prq->num_rds_rings = cpu_to_le16(nrds_rings);
 	prq->num_sds_rings = cpu_to_le16(nsds_rings);
-	prq->rds_ring_offset = cpu_to_le32(0);
+	prq->rds_ring_offset = 0;
 
 	val = le32_to_cpu(prq->rds_ring_offset) +
 		(sizeof(struct qlcnic_hostrq_rds_ring) * nrds_rings);
@@ -187,7 +187,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 
 	phys_addr = hostrq_phys_addr;
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			(u32)(phys_addr >> 32),
 			(u32)(phys_addr & 0xffffffff),
@@ -207,7 +207,7 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 		rds_ring = &recv_ctx->rds_rings[i];
 
 		reg = le32_to_cpu(prsp_rds[i].host_producer_crb);
-		rds_ring->crb_rcv_producer = adapter->ahw.pci_base0 + reg;
+		rds_ring->crb_rcv_producer = adapter->ahw->pci_base0 + reg;
 	}
 
 	prsp_sds = ((struct qlcnic_cardrsp_sds_ring *)
@@ -219,8 +219,8 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 		reg = le32_to_cpu(prsp_sds[i].host_consumer_crb);
 		reg2 = le32_to_cpu(prsp_sds[i].interrupt_crb);
 
-		sds_ring->crb_sts_consumer = adapter->ahw.pci_base0 + reg;
-		sds_ring->crb_intr_mask = adapter->ahw.pci_base0 + reg2;
+		sds_ring->crb_sts_consumer = adapter->ahw->pci_base0 + reg;
+		sds_ring->crb_intr_mask = adapter->ahw->pci_base0 + reg2;
 	}
 
 	recv_ctx->state = le32_to_cpu(prsp->host_ctx_state);
@@ -228,19 +228,20 @@ qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
 	recv_ctx->virt_port = prsp->virt_port;
 
 out_free_rsp:
-	pci_free_consistent(adapter->pdev, rsp_size, prsp, cardrsp_phys_addr);
+	dma_free_coherent(&adapter->pdev->dev, rsp_size, prsp,
+		cardrsp_phys_addr);
 out_free_rq:
-	pci_free_consistent(adapter->pdev, rq_size, prq, hostrq_phys_addr);
+	dma_free_coherent(&adapter->pdev->dev, rq_size, prq, hostrq_phys_addr);
 	return err;
 }
 
 static void
 qlcnic_fw_cmd_destroy_rx_ctx(struct qlcnic_adapter *adapter)
 {
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			recv_ctx->context_id,
 			QLCNIC_DESTROY_CTX_RESET,
@@ -274,14 +275,14 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 	*(tx_ring->hw_consumer) = 0;
 
 	rq_size = SIZEOF_HOSTRQ_TX(struct qlcnic_hostrq_tx_ctx);
-	rq_addr = pci_alloc_consistent(adapter->pdev,
-		rq_size, &rq_phys_addr);
+	rq_addr = dma_alloc_coherent(&adapter->pdev->dev, rq_size,
+			&rq_phys_addr, GFP_KERNEL);
 	if (!rq_addr)
 		return -ENOMEM;
 
 	rsp_size = SIZEOF_CARDRSP_TX(struct qlcnic_cardrsp_tx_ctx);
-	rsp_addr = pci_alloc_consistent(adapter->pdev,
-		rsp_size, &rsp_phys_addr);
+	rsp_addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
+			&rsp_phys_addr, GFP_KERNEL);
 	if (!rsp_addr) {
 		err = -ENOMEM;
 		goto out_free_rq;
@@ -313,7 +314,7 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 
 	phys_addr = rq_phys_addr;
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			(u32)(phys_addr >> 32),
 			((u32)phys_addr & 0xffffffff),
@@ -322,7 +323,7 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 
 	if (err == QLCNIC_RCODE_SUCCESS) {
 		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
-		tx_ring->crb_cmd_producer = adapter->ahw.pci_base0 + temp;
+		tx_ring->crb_cmd_producer = adapter->ahw->pci_base0 + temp;
 
 		adapter->tx_context_id =
 			le16_to_cpu(prsp->context_id);
@@ -332,10 +333,11 @@ qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter)
 		err = -EIO;
 	}
 
-	pci_free_consistent(adapter->pdev, rsp_size, rsp_addr, rsp_phys_addr);
+	dma_free_coherent(&adapter->pdev->dev, rsp_size, rsp_addr,
+		rsp_phys_addr);
 
 out_free_rq:
-	pci_free_consistent(adapter->pdev, rq_size, rq_addr, rq_phys_addr);
+	dma_free_coherent(&adapter->pdev->dev, rq_size, rq_addr, rq_phys_addr);
 
 	return err;
 }
@@ -344,7 +346,7 @@ static void
 qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter)
 {
 	if (qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			adapter->tx_context_id,
 			QLCNIC_DESTROY_CTX_RESET,
@@ -361,7 +363,7 @@ qlcnic_fw_cmd_query_phy(struct qlcnic_adapter *adapter, u32 reg, u32 *val)
 {
 
 	if (qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			reg,
 			0,
@@ -378,7 +380,7 @@ int
 qlcnic_fw_cmd_set_phy(struct qlcnic_adapter *adapter, u32 reg, u32 val)
 {
 	return qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			reg,
 			val,
@@ -398,20 +400,19 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 
 	struct pci_dev *pdev = adapter->pdev;
 
-	recv_ctx = &adapter->recv_ctx;
+	recv_ctx = adapter->recv_ctx;
 	tx_ring = adapter->tx_ring;
 
-	tx_ring->hw_consumer = (__le32 *)pci_alloc_consistent(pdev, sizeof(u32),
-						&tx_ring->hw_cons_phys_addr);
+	tx_ring->hw_consumer = (__le32 *) dma_alloc_coherent(&pdev->dev,
+		sizeof(u32), &tx_ring->hw_cons_phys_addr, GFP_KERNEL);
 	if (tx_ring->hw_consumer == NULL) {
 		dev_err(&pdev->dev, "failed to allocate tx consumer\n");
 		return -ENOMEM;
 	}
-	*(tx_ring->hw_consumer) = 0;
 
 	/* cmd desc ring */
-	addr = pci_alloc_consistent(pdev, TX_DESC_RINGSIZE(tx_ring),
-			&tx_ring->phys_addr);
+	addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
+			&tx_ring->phys_addr, GFP_KERNEL);
 
 	if (addr == NULL) {
 		dev_err(&pdev->dev, "failed to allocate tx desc ring\n");
@@ -423,9 +424,9 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
-		addr = pci_alloc_consistent(adapter->pdev,
+		addr = dma_alloc_coherent(&adapter->pdev->dev,
 				RCV_DESC_RINGSIZE(rds_ring),
-				&rds_ring->phys_addr);
+				&rds_ring->phys_addr, GFP_KERNEL);
 		if (addr == NULL) {
 			dev_err(&pdev->dev,
 				"failed to allocate rds ring [%d]\n", ring);
@@ -439,9 +440,9 @@ int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
 
-		addr = pci_alloc_consistent(adapter->pdev,
+		addr = dma_alloc_coherent(&adapter->pdev->dev,
 				STATUS_DESC_RINGSIZE(sds_ring),
-				&sds_ring->phys_addr);
+				&sds_ring->phys_addr, GFP_KERNEL);
 		if (addr == NULL) {
 			dev_err(&pdev->dev,
 				"failed to allocate sds ring [%d]\n", ring);
@@ -501,11 +502,11 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 	struct qlcnic_host_tx_ring *tx_ring;
 	int ring;
 
-	recv_ctx = &adapter->recv_ctx;
+	recv_ctx = adapter->recv_ctx;
 
 	tx_ring = adapter->tx_ring;
 	if (tx_ring->hw_consumer != NULL) {
-		pci_free_consistent(adapter->pdev,
+		dma_free_coherent(&adapter->pdev->dev,
 				sizeof(u32),
 				tx_ring->hw_consumer,
 				tx_ring->hw_cons_phys_addr);
@@ -513,7 +514,7 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 	}
 
 	if (tx_ring->desc_head != NULL) {
-		pci_free_consistent(adapter->pdev,
+		dma_free_coherent(&adapter->pdev->dev,
 				TX_DESC_RINGSIZE(tx_ring),
 				tx_ring->desc_head, tx_ring->phys_addr);
 		tx_ring->desc_head = NULL;
@@ -523,7 +524,7 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 		rds_ring = &recv_ctx->rds_rings[ring];
 
 		if (rds_ring->desc_head != NULL) {
-			pci_free_consistent(adapter->pdev,
+			dma_free_coherent(&adapter->pdev->dev,
 					RCV_DESC_RINGSIZE(rds_ring),
 					rds_ring->desc_head,
 					rds_ring->phys_addr);
@@ -535,7 +536,7 @@ void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
 		sds_ring = &recv_ctx->sds_rings[ring];
 
 		if (sds_ring->desc_head != NULL) {
-			pci_free_consistent(adapter->pdev,
+			dma_free_coherent(&adapter->pdev->dev,
 				STATUS_DESC_RINGSIZE(sds_ring),
 				sds_ring->desc_head,
 				sds_ring->phys_addr);
@@ -551,9 +552,9 @@ int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
 	int err;
 	u32 arg1;
 
-	arg1 = adapter->ahw.pci_func | BIT_8;
+	arg1 = adapter->ahw->pci_func | BIT_8;
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			arg1,
 			0,
@@ -582,15 +583,15 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 	void *nic_info_addr;
 	size_t	nic_size = sizeof(struct qlcnic_info);
 
-	nic_info_addr = pci_alloc_consistent(adapter->pdev,
-		nic_size, &nic_dma_t);
+	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
+				&nic_dma_t, GFP_KERNEL);
 	if (!nic_info_addr)
 		return -ENOMEM;
 	memset(nic_info_addr, 0, nic_size);
 
 	nic_info = (struct qlcnic_info *) nic_info_addr;
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			MSD(nic_dma_t),
 			LSD(nic_dma_t),
@@ -623,7 +624,8 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 		err = -EIO;
 	}
 
-	pci_free_consistent(adapter->pdev, nic_size, nic_info_addr, nic_dma_t);
+	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
+		nic_dma_t);
 	return err;
 }
 
@@ -639,8 +641,8 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 	if (adapter->op_mode != QLCNIC_MGMT_FUNC)
 		return err;
 
-	nic_info_addr = pci_alloc_consistent(adapter->pdev, nic_size,
-			&nic_dma_t);
+	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
+			&nic_dma_t, GFP_KERNEL);
 	if (!nic_info_addr)
 		return -ENOMEM;
 
@@ -659,7 +661,7 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 	nic_info->max_tx_bw = cpu_to_le16(nic->max_tx_bw);
 
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			MSD(nic_dma_t),
 			LSD(nic_dma_t),
@@ -672,7 +674,8 @@ int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
 		err = -EIO;
 	}
 
-	pci_free_consistent(adapter->pdev, nic_size, nic_info_addr, nic_dma_t);
+	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
+		nic_dma_t);
 	return err;
 }
 
@@ -687,15 +690,15 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 	size_t npar_size = sizeof(struct qlcnic_pci_info);
 	size_t pci_size = npar_size * QLCNIC_MAX_PCI_FUNC;
 
-	pci_info_addr = pci_alloc_consistent(adapter->pdev, pci_size,
-			&pci_info_dma_t);
+	pci_info_addr = dma_alloc_coherent(&adapter->pdev->dev, pci_size,
+			&pci_info_dma_t, GFP_KERNEL);
 	if (!pci_info_addr)
 		return -ENOMEM;
 	memset(pci_info_addr, 0, pci_size);
 
 	npar = (struct qlcnic_pci_info *) pci_info_addr;
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			MSD(pci_info_dma_t),
 			LSD(pci_info_dma_t),
@@ -721,7 +724,7 @@ int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
 		err = -EIO;
 	}
 
-	pci_free_consistent(adapter->pdev, pci_size, pci_info_addr,
+	dma_free_coherent(&adapter->pdev->dev, pci_size, pci_info_addr,
 		pci_info_dma_t);
 	return err;
 }
@@ -741,7 +744,7 @@ int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
 	arg1 |= pci_func << 8;
 
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			arg1,
 			0,
@@ -775,14 +778,14 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 		return -ENOMEM;
 
 	if (adapter->op_mode != QLCNIC_MGMT_FUNC &&
-	    func != adapter->ahw.pci_func) {
+	    func != adapter->ahw->pci_func) {
 		dev_err(&adapter->pdev->dev,
 			"Not privilege to query stats for func=%d", func);
 		return -EIO;
 	}
 
-	stats_addr = pci_alloc_consistent(adapter->pdev, stats_size,
-			&stats_dma_t);
+	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
+			&stats_dma_t, GFP_KERNEL);
 	if (!stats_addr) {
 		dev_err(&adapter->pdev->dev, "Unable to allocate memory\n");
 		return -ENOMEM;
@@ -793,7 +796,7 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 	arg1 |= rx_tx << 15 | stats_size << 16;
 
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			arg1,
 			MSD(stats_dma_t),
@@ -816,7 +819,7 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 		esw_stats->numbytes = le64_to_cpu(stats->numbytes);
 	}
 
-	pci_free_consistent(adapter->pdev, stats_size, stats_addr,
+	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
 		stats_dma_t);
 	return err;
 }
@@ -900,7 +903,7 @@ int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
 	arg1 |= BIT_14 | rx_tx << 15;
 
 	return qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			arg1,
 			0,
@@ -921,7 +924,7 @@ __qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
 	u8 pci_func;
 	pci_func = (*arg1 >> 8);
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			*arg1,
 			0,
@@ -999,7 +1002,7 @@ int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
 	}
 
 	err = qlcnic_issue_cmd(adapter,
-			adapter->ahw.pci_func,
+			adapter->ahw->pci_func,
 			adapter->fw_hal_version,
 			arg1,
 			arg2,
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 4c14510..b446045 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -150,10 +150,10 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	int check_sfp_module = 0;
-	u16 pcifn = adapter->ahw.pci_func;
+	u16 pcifn = adapter->ahw->pci_func;
 
 	/* read which mode */
-	if (adapter->ahw.port_type == QLCNIC_GBE) {
+	if (adapter->ahw->port_type == QLCNIC_GBE) {
 		ecmd->supported = (SUPPORTED_10baseT_Half |
 				   SUPPORTED_10baseT_Full |
 				   SUPPORTED_100baseT_Half |
@@ -170,7 +170,7 @@ qlcnic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		ecmd->duplex = adapter->link_duplex;
 		ecmd->autoneg = adapter->link_autoneg;
 
-	} else if (adapter->ahw.port_type == QLCNIC_XGBE) {
+	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
 		u32 val;
 
 		val = QLCRD32(adapter, QLCNIC_PORT_MODE_ADDR);
@@ -201,7 +201,7 @@ skip:
 	ecmd->phy_address = adapter->physical_port;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
-	switch (adapter->ahw.board_type) {
+	switch (adapter->ahw->board_type) {
 	case QLCNIC_BRDTYPE_P3P_REF_QG:
 	case QLCNIC_BRDTYPE_P3P_4_GB:
 	case QLCNIC_BRDTYPE_P3P_4_GB_MM:
@@ -238,7 +238,7 @@ skip:
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
 	case QLCNIC_BRDTYPE_P3P_10G_TP:
-		if (adapter->ahw.port_type == QLCNIC_XGBE) {
+		if (adapter->ahw->port_type == QLCNIC_XGBE) {
 			ecmd->autoneg = AUTONEG_DISABLE;
 			ecmd->supported |= (SUPPORTED_FIBRE | SUPPORTED_TP);
 			ecmd->advertising |=
@@ -256,7 +256,7 @@ skip:
 		break;
 	default:
 		dev_err(&adapter->pdev->dev, "Unsupported board model %d\n",
-			adapter->ahw.board_type);
+			adapter->ahw->board_type);
 		return -EIO;
 	}
 
@@ -288,7 +288,7 @@ qlcnic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	__u32 status;
 
 	/* read which mode */
-	if (adapter->ahw.port_type == QLCNIC_GBE) {
+	if (adapter->ahw->port_type == QLCNIC_GBE) {
 		/* autonegotiation */
 		if (qlcnic_fw_cmd_set_phy(adapter,
 			       QLCNIC_NIU_GB_MII_MGMT_ADDR_AUTONEG,
@@ -340,14 +340,14 @@ static void
 qlcnic_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring;
 	u32 *regs_buff = p;
 	int ring, i = 0, j = 0;
 
 	memset(p, 0, qlcnic_get_regs_len(dev));
 	regs->version = (QLCNIC_ETHTOOL_REGS_VER << 24) |
-		(adapter->ahw.revision_id << 16) | (adapter->pdev)->device;
+		(adapter->ahw->revision_id << 16) | (adapter->pdev)->device;
 
 	regs_buff[0] = (0xcafe0000 | (QLCNIC_DEV_INFO_SIZE & 0xffff));
 	regs_buff[1] = QLCNIC_MGMT_API_VERSION;
@@ -382,7 +382,7 @@ static u32 qlcnic_test_link(struct net_device *dev)
 	u32 val;
 
 	val = QLCRD32(adapter, CRB_XG_STATE_P3P);
-	val = XG_LINK_STATE_P3P(adapter->ahw.pci_func, val);
+	val = XG_LINK_STATE_P3P(adapter->ahw->pci_func, val);
 	return (val == XG_LINK_UP_P3P) ? 0 : 1;
 }
 
@@ -482,7 +482,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 	int port = adapter->physical_port;
 	__u32 val;
 
-	if (adapter->ahw.port_type == QLCNIC_GBE) {
+	if (adapter->ahw->port_type == QLCNIC_GBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return;
 		/* get flow control settings */
@@ -504,7 +504,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 			pause->tx_pause = !(qlcnic_gb_get_gb3_mask(val));
 			break;
 		}
-	} else if (adapter->ahw.port_type == QLCNIC_XGBE) {
+	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_XG_PORTS))
 			return;
 		pause->rx_pause = 1;
@@ -515,7 +515,7 @@ qlcnic_get_pauseparam(struct net_device *netdev,
 			pause->tx_pause = !(qlcnic_xg_get_xg1_mask(val));
 	} else {
 		dev_err(&netdev->dev, "Unknown board type: %x\n",
-					adapter->ahw.port_type);
+					adapter->ahw->port_type);
 	}
 }
 
@@ -528,7 +528,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 	__u32 val;
 
 	/* read mode */
-	if (adapter->ahw.port_type == QLCNIC_GBE) {
+	if (adapter->ahw->port_type == QLCNIC_GBE) {
 		if ((port < 0) || (port > QLCNIC_NIU_MAX_GBE_PORTS))
 			return -EIO;
 		/* set flow control */
@@ -571,7 +571,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 			break;
 		}
 		QLCWR32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, val);
-	} else if (adapter->ahw.port_type == QLCNIC_XGBE) {
+	} else if (adapter->ahw->port_type == QLCNIC_XGBE) {
 		if (!pause->rx_pause || pause->autoneg)
 			return -EOPNOTSUPP;
 
@@ -593,7 +593,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 		QLCWR32(adapter, QLCNIC_NIU_XG_PAUSE_CTL, val);
 	} else {
 		dev_err(&netdev->dev, "Unknown board type: %x\n",
-				adapter->ahw.port_type);
+				adapter->ahw->port_type);
 	}
 	return 0;
 }
@@ -639,8 +639,8 @@ static int qlcnic_irq_test(struct net_device *netdev)
 		goto clear_it;
 
 	adapter->diag_cnt = 0;
-	ret = qlcnic_issue_cmd(adapter, adapter->ahw.pci_func,
-			adapter->fw_hal_version, adapter->portnum,
+	ret = qlcnic_issue_cmd(adapter, adapter->ahw->pci_func,
+			adapter->fw_hal_version, adapter->ahw->pci_func,
 			0, 0, 0x00000011);
 	if (ret)
 		goto done;
@@ -749,14 +749,14 @@ qlcnic_get_ethtool_stats(struct net_device *dev,
 		return;
 
 	memset(&port_stats, 0, sizeof(struct qlcnic_esw_statistics));
-	ret = qlcnic_get_port_stats(adapter, adapter->ahw.pci_func,
+	ret = qlcnic_get_port_stats(adapter, adapter->ahw->pci_func,
 			QLCNIC_QUERY_RX_COUNTER, &port_stats.rx);
 	if (ret)
 		return;
 
 	qlcnic_fill_device_stats(&index, data, &port_stats.rx);
 
-	ret = qlcnic_get_port_stats(adapter, adapter->ahw.pci_func,
+	ret = qlcnic_get_port_stats(adapter, adapter->ahw->pci_func,
 			QLCNIC_QUERY_TX_COUNTER, &port_stats.tx);
 	if (ret)
 		return;
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 616940f..7e3f526 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -457,7 +457,7 @@ int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
 
 	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
 
-	word = QLCNIC_H2C_OPCODE_PROXY_SET_VPORT_MISS_MODE |
+	word = QLCNIC_H2C_OPCODE_SET_MAC_RECEIVE_MODE |
 			((u64)adapter->portnum << 16);
 	req.req_hdr = cpu_to_le64(word);
 
@@ -780,7 +780,7 @@ qlcnic_pci_get_crb_addr_2M(struct qlcnic_adapter *adapter,
 	m = &crb_128M_2M_map[CRB_BLK(off)].sub_block[CRB_SUBBLK(off)];
 
 	if (m->valid && (m->start_128M <= off) && (m->end_128M > off)) {
-		*addr = adapter->ahw.pci_base0 + m->start_2M +
+		*addr = adapter->ahw->pci_base0 + m->start_2M +
 			(off - m->start_128M);
 		return 0;
 	}
@@ -788,7 +788,7 @@ qlcnic_pci_get_crb_addr_2M(struct qlcnic_adapter *adapter,
 	/*
 	 * Not in direct map, use crb window
 	 */
-	*addr = adapter->ahw.pci_base0 + CRB_INDIRECT_2M + (off & MASK(16));
+	*addr = adapter->ahw->pci_base0 + CRB_INDIRECT_2M + (off & MASK(16));
 	return 1;
 }
 
@@ -801,7 +801,7 @@ static int
 qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
 {
 	u32 window;
-	void __iomem *addr = adapter->ahw.pci_base0 + CRB_WINDOW_2M;
+	void __iomem *addr = adapter->ahw->pci_base0 + CRB_WINDOW_2M;
 
 	off -= QLCNIC_PCI_CRBSPACE;
 
@@ -838,13 +838,13 @@ qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 
 	if (rv > 0) {
 		/* indirect access */
-		write_lock_irqsave(&adapter->ahw.crb_lock, flags);
+		write_lock_irqsave(&adapter->ahw->crb_lock, flags);
 		crb_win_lock(adapter);
 		rv = qlcnic_pci_set_crbwindow_2M(adapter, off);
 		if (!rv)
 			writel(data, addr);
 		crb_win_unlock(adapter);
-		write_unlock_irqrestore(&adapter->ahw.crb_lock, flags);
+		write_unlock_irqrestore(&adapter->ahw->crb_lock, flags);
 		return rv;
 	}
 
@@ -869,12 +869,12 @@ qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 
 	if (rv > 0) {
 		/* indirect access */
-		write_lock_irqsave(&adapter->ahw.crb_lock, flags);
+		write_lock_irqsave(&adapter->ahw->crb_lock, flags);
 		crb_win_lock(adapter);
 		if (!qlcnic_pci_set_crbwindow_2M(adapter, off))
 			data = readl(addr);
 		crb_win_unlock(adapter);
-		write_unlock_irqrestore(&adapter->ahw.crb_lock, flags);
+		write_unlock_irqrestore(&adapter->ahw->crb_lock, flags);
 		return data;
 	}
 
@@ -904,9 +904,9 @@ qlcnic_pci_set_window_2M(struct qlcnic_adapter *adapter,
 
 	window = OCM_WIN_P3P(addr);
 
-	writel(window, adapter->ahw.ocm_win_crb);
+	writel(window, adapter->ahw->ocm_win_crb);
 	/* read back to flush */
-	readl(adapter->ahw.ocm_win_crb);
+	readl(adapter->ahw->ocm_win_crb);
 
 	*start = QLCNIC_PCI_OCM0_2M + GET_MEM_OFFS_2M(addr);
 	return 0;
@@ -920,13 +920,13 @@ qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u64 off,
 	int ret;
 	u32 start;
 
-	mutex_lock(&adapter->ahw.mem_lock);
+	mutex_lock(&adapter->ahw->mem_lock);
 
 	ret = qlcnic_pci_set_window_2M(adapter, off, &start);
 	if (ret != 0)
 		goto unlock;
 
-	addr = adapter->ahw.pci_base0 + start;
+	addr = adapter->ahw->pci_base0 + start;
 
 	if (op == 0)	/* read */
 		*data = readq(addr);
@@ -934,7 +934,7 @@ qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u64 off,
 		writeq(*data, addr);
 
 unlock:
-	mutex_unlock(&adapter->ahw.mem_lock);
+	mutex_unlock(&adapter->ahw->mem_lock);
 
 	return ret;
 }
@@ -942,23 +942,23 @@ unlock:
 void
 qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *adapter, u64 off, u64 *data)
 {
-	void __iomem *addr = adapter->ahw.pci_base0 +
+	void __iomem *addr = adapter->ahw->pci_base0 +
 		QLCNIC_PCI_CAMQM_2M_BASE + (off - QLCNIC_PCI_CAMQM);
 
-	mutex_lock(&adapter->ahw.mem_lock);
+	mutex_lock(&adapter->ahw->mem_lock);
 	*data = readq(addr);
-	mutex_unlock(&adapter->ahw.mem_lock);
+	mutex_unlock(&adapter->ahw->mem_lock);
 }
 
 void
 qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *adapter, u64 off, u64 data)
 {
-	void __iomem *addr = adapter->ahw.pci_base0 +
+	void __iomem *addr = adapter->ahw->pci_base0 +
 		QLCNIC_PCI_CAMQM_2M_BASE + (off - QLCNIC_PCI_CAMQM);
 
-	mutex_lock(&adapter->ahw.mem_lock);
+	mutex_lock(&adapter->ahw->mem_lock);
 	writeq(data, addr);
-	mutex_unlock(&adapter->ahw.mem_lock);
+	mutex_unlock(&adapter->ahw->mem_lock);
 }
 
 #define MAX_CTL_CHECK   1000
@@ -997,7 +997,7 @@ qlcnic_pci_mem_write_2M(struct qlcnic_adapter *adapter,
 correct:
 	off8 = off & ~0xf;
 
-	mutex_lock(&adapter->ahw.mem_lock);
+	mutex_lock(&adapter->ahw->mem_lock);
 
 	writel(off8, (mem_crb + MIU_TEST_AGT_ADDR_LO));
 	writel(0, (mem_crb + MIU_TEST_AGT_ADDR_HI));
@@ -1049,7 +1049,7 @@ correct:
 		ret = 0;
 
 done:
-	mutex_unlock(&adapter->ahw.mem_lock);
+	mutex_unlock(&adapter->ahw->mem_lock);
 
 	return ret;
 }
@@ -1091,7 +1091,7 @@ qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
 correct:
 	off8 = off & ~0xf;
 
-	mutex_lock(&adapter->ahw.mem_lock);
+	mutex_lock(&adapter->ahw->mem_lock);
 
 	writel(off8, (mem_crb + MIU_TEST_AGT_ADDR_LO));
 	writel(0, (mem_crb + MIU_TEST_AGT_ADDR_HI));
@@ -1121,7 +1121,7 @@ correct:
 		ret = 0;
 	}
 
-	mutex_unlock(&adapter->ahw.mem_lock);
+	mutex_unlock(&adapter->ahw->mem_lock);
 
 	return ret;
 }
@@ -1145,7 +1145,7 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 	if (qlcnic_rom_fast_read(adapter, offset, &board_type))
 		return -EIO;
 
-	adapter->ahw.board_type = board_type;
+	adapter->ahw->board_type = board_type;
 
 	if (board_type == QLCNIC_BRDTYPE_P3P_4_GB_MM) {
 		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I);
@@ -1164,20 +1164,20 @@ int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
 	case QLCNIC_BRDTYPE_P3P_10G_SFP_QT:
 	case QLCNIC_BRDTYPE_P3P_10G_XFP:
 	case QLCNIC_BRDTYPE_P3P_10000_BASE_T:
-		adapter->ahw.port_type = QLCNIC_XGBE;
+		adapter->ahw->port_type = QLCNIC_XGBE;
 		break;
 	case QLCNIC_BRDTYPE_P3P_REF_QG:
 	case QLCNIC_BRDTYPE_P3P_4_GB:
 	case QLCNIC_BRDTYPE_P3P_4_GB_MM:
-		adapter->ahw.port_type = QLCNIC_GBE;
+		adapter->ahw->port_type = QLCNIC_GBE;
 		break;
 	case QLCNIC_BRDTYPE_P3P_10G_TP:
-		adapter->ahw.port_type = (adapter->portnum < 2) ?
+		adapter->ahw->port_type = (adapter->portnum < 2) ?
 			QLCNIC_XGBE : QLCNIC_GBE;
 		break;
 	default:
 		dev_err(&pdev->dev, "unknown board type %x\n", board_type);
-		adapter->ahw.port_type = QLCNIC_XGBE;
+		adapter->ahw->port_type = QLCNIC_XGBE;
 		break;
 	}
 
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index a7f1d5b..476ea14 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -94,7 +94,7 @@ void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter)
 	struct qlcnic_rx_buffer *rx_buf;
 	int i, ring;
 
-	recv_ctx = &adapter->recv_ctx;
+	recv_ctx = adapter->recv_ctx;
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 		for (i = 0; i < rds_ring->num_desc; ++i) {
@@ -119,7 +119,7 @@ void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter)
 	struct qlcnic_rx_buffer *rx_buf;
 	int i, ring;
 
-	recv_ctx = &adapter->recv_ctx;
+	recv_ctx = adapter->recv_ctx;
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 
@@ -173,7 +173,7 @@ void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
 	struct qlcnic_host_tx_ring *tx_ring;
 	int ring;
 
-	recv_ctx = &adapter->recv_ctx;
+	recv_ctx = adapter->recv_ctx;
 
 	if (recv_ctx->rds_rings == NULL)
 		goto skip_rds;
@@ -226,7 +226,7 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 	}
 	tx_ring->cmd_buf_arr = cmd_buf_arr;
 
-	recv_ctx = &adapter->recv_ctx;
+	recv_ctx = adapter->recv_ctx;
 
 	size = adapter->max_rds_rings * sizeof(struct qlcnic_host_rds_ring);
 	rds_ring = kzalloc(size, GFP_KERNEL);
@@ -864,7 +864,7 @@ nomn:
 	for (i = 0; i < entries; i++) {
 
 		__le32 flags, file_chiprev, offs;
-		u8 chiprev = adapter->ahw.revision_id;
+		u8 chiprev = adapter->ahw->revision_id;
 		u32 flagbit;
 
 		offs = cpu_to_le32(ptab_descr->findex) +
@@ -1394,7 +1394,7 @@ static struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 	return skb;
 }
 
-static int
+static inline int
 qlcnic_check_rx_tagging(struct qlcnic_adapter *adapter, struct sk_buff *skb,
 			u16 *vlan_tag)
 {
@@ -1425,7 +1425,7 @@ qlcnic_process_rcv(struct qlcnic_adapter *adapter,
 		int ring, u64 sts_data0)
 {
 	struct net_device *netdev = adapter->netdev;
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_rx_buffer *buffer;
 	struct sk_buff *skb;
 	struct qlcnic_host_rds_ring *rds_ring;
@@ -1488,7 +1488,7 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 		int ring, u64 sts_data0, u64 sts_data1)
 {
 	struct net_device *netdev = adapter->netdev;
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_rx_buffer *buffer;
 	struct sk_buff *skb;
 	struct qlcnic_host_rds_ring *rds_ring;
@@ -1625,7 +1625,7 @@ skip:
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		struct qlcnic_host_rds_ring *rds_ring =
-			&adapter->recv_ctx.rds_rings[ring];
+			&adapter->recv_ctx->rds_rings[ring];
 
 		if (!list_empty(&sds_ring->free_list[ring])) {
 			list_for_each(cur, &sds_ring->free_list[ring]) {
@@ -1651,12 +1651,13 @@ skip:
 }
 
 void
-qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter, u32 ringid,
+qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter,
 	struct qlcnic_host_rds_ring *rds_ring)
 {
 	struct rcv_desc *pdesc;
 	struct qlcnic_rx_buffer *buffer;
-	int producer, count = 0;
+	int count = 0;
+	u32 producer;
 	struct list_head *head;
 
 	producer = rds_ring->producer;
@@ -1696,7 +1697,8 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 {
 	struct rcv_desc *pdesc;
 	struct qlcnic_rx_buffer *buffer;
-	int producer, count = 0;
+	int  count = 0;
+	uint32_t producer;
 	struct list_head *head;
 
 	if (!spin_trylock(&rds_ring->lock))
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index de6f866..dde7e44 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -113,7 +113,7 @@ static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 MODULE_DEVICE_TABLE(pci, qlcnic_pci_tbl);
 
 
-void
+inline void
 qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring)
 {
@@ -169,7 +169,7 @@ qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (qlcnic_alloc_sds_rings(recv_ctx, adapter->max_sds_rings))
 		return -ENOMEM;
@@ -193,14 +193,14 @@ qlcnic_napi_del(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
 		netif_napi_del(&sds_ring->napi);
 	}
 
-	qlcnic_free_sds_rings(&adapter->recv_ctx);
+	qlcnic_free_sds_rings(adapter->recv_ctx);
 }
 
 static void
@@ -208,7 +208,7 @@ qlcnic_napi_enable(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
 		return;
@@ -225,7 +225,7 @@ qlcnic_napi_disable(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
 		return;
@@ -359,7 +359,7 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	int err, num_msix;
 
-	if (adapter->rss_supported) {
+	if (adapter->msix_supported) {
 		num_msix = (num_online_cpus() >= MSIX_ENTRIES_PER_ADAPTER) ?
 			MSIX_ENTRIES_PER_ADAPTER : 2;
 	} else
@@ -369,7 +369,7 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 
 	adapter->flags &= ~(QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED);
 
-	legacy_intrp = &legacy_intr[adapter->ahw.pci_func];
+	legacy_intrp = &legacy_intr[adapter->ahw->pci_func];
 
 	adapter->int_vec_bit = legacy_intrp->int_vec_bit;
 	adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter,
@@ -391,8 +391,7 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 			adapter->flags |= QLCNIC_MSIX_ENABLED;
 			qlcnic_set_msix_bit(pdev, 1);
 
-			if (adapter->rss_supported)
-				adapter->max_sds_rings = num_msix;
+			adapter->max_sds_rings = num_msix;
 
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
 			return;
@@ -407,7 +406,7 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 	if (use_msi && !pci_enable_msi(pdev)) {
 		adapter->flags |= QLCNIC_MSI_ENABLED;
 		adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter,
-				msi_tgt_status[adapter->ahw.pci_func]);
+				msi_tgt_status[adapter->ahw->pci_func]);
 		dev_info(&pdev->dev, "using msi interrupts\n");
 		adapter->msix_entries[0].vector = pdev->irq;
 		return;
@@ -429,8 +428,8 @@ qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 static void
 qlcnic_cleanup_pci_map(struct qlcnic_adapter *adapter)
 {
-	if (adapter->ahw.pci_base0 != NULL)
-		iounmap(adapter->ahw.pci_base0);
+	if (adapter->ahw->pci_base0 != NULL)
+		iounmap(adapter->ahw->pci_base0);
 }
 
 static int
@@ -500,7 +499,7 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 	u32 ref_count;
 	int i, ret = 1;
 	u32 data = QLCNIC_MGMT_FUNC;
-	void __iomem *priv_op = adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE;
+	void __iomem *priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
 
 	/* If other drivers are not in use set their privilege level */
 	ref_count = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
@@ -512,16 +511,16 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
 			id = i;
 			if (adapter->npars[i].type != QLCNIC_TYPE_NIC ||
-				id == adapter->ahw.pci_func)
+				id == adapter->ahw->pci_func)
 				continue;
 			data |= (qlcnic_config_npars &
 					QLC_DEV_SET_DRV(0xf, id));
 		}
 	} else {
 		data = readl(priv_op);
-		data = (data & ~QLC_DEV_SET_DRV(0xf, adapter->ahw.pci_func)) |
+		data = (data & ~QLC_DEV_SET_DRV(0xf, adapter->ahw->pci_func)) |
 			(QLC_DEV_SET_DRV(QLCNIC_MGMT_FUNC,
-			adapter->ahw.pci_func));
+			adapter->ahw->pci_func));
 	}
 	writel(data, priv_op);
 	qlcnic_api_unlock(adapter);
@@ -539,22 +538,23 @@ qlcnic_check_vf(struct qlcnic_adapter *adapter)
 	u32 op_mode, priv_level;
 
 	/* Determine FW API version */
-	adapter->fw_hal_version = readl(adapter->ahw.pci_base0 + QLCNIC_FW_API);
+	adapter->fw_hal_version = readl(adapter->ahw->pci_base0 +
+					QLCNIC_FW_API);
 
 	/* Find PCI function number */
 	pci_read_config_dword(adapter->pdev, QLCNIC_MSIX_TABLE_OFFSET, &func);
-	msix_base_addr = adapter->ahw.pci_base0 + QLCNIC_MSIX_BASE;
+	msix_base_addr = adapter->ahw->pci_base0 + QLCNIC_MSIX_BASE;
 	msix_base = readl(msix_base_addr);
 	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
-	adapter->ahw.pci_func = func;
+	adapter->ahw->pci_func = func;
 
 	/* Determine function privilege level */
-	priv_op = adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE;
+	priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
 	op_mode = readl(priv_op);
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
 	else
-		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw.pci_func);
+		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw->pci_func);
 
 	if (priv_level == QLCNIC_NON_PRIV_FUNC) {
 		adapter->op_mode = QLCNIC_NON_PRIV_FUNC;
@@ -593,13 +593,14 @@ qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
 
 	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
 
-	adapter->ahw.pci_base0 = mem_ptr0;
-	adapter->ahw.pci_len0 = pci_len0;
+	adapter->ahw->pci_base0 = mem_ptr0;
+	adapter->ahw->pci_len0 = pci_len0;
 
 	qlcnic_check_vf(adapter);
 
-	adapter->ahw.ocm_win_crb = qlcnic_get_ioaddr(adapter,
-		QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(adapter->ahw.pci_func)));
+	adapter->ahw->ocm_win_crb = qlcnic_get_ioaddr(adapter,
+		QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(
+			adapter->ahw->pci_func)));
 
 	return 0;
 }
@@ -641,7 +642,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 
 	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
 			fw_major, fw_minor, fw_build);
-	if (adapter->ahw.port_type == QLCNIC_XGBE) {
+	if (adapter->ahw->port_type == QLCNIC_XGBE) {
 		if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 			adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_VF;
 			adapter->max_rxd = MAX_RCV_DESCRIPTORS_VF;
@@ -653,7 +654,7 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
 		adapter->max_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
 
-	} else if (adapter->ahw.port_type == QLCNIC_GBE) {
+	} else if (adapter->ahw->port_type == QLCNIC_GBE) {
 		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_1G;
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
 		adapter->max_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_1G;
@@ -661,7 +662,6 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 	}
 
 	adapter->msix_supported = !!use_msi_x;
-	adapter->rss_supported = !!use_msi_x;
 
 	adapter->num_txd = MAX_CMD_DESCRIPTORS;
 
@@ -674,7 +674,7 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	int err;
 	struct qlcnic_info nic_info;
 
-	err = qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw.pci_func);
+	err = qlcnic_get_nic_info(adapter, &nic_info, adapter->ahw->pci_func);
 	if (err)
 		return err;
 
@@ -736,7 +736,7 @@ qlcnic_set_eswitch_port_config(struct qlcnic_adapter *adapter)
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
 		return 0;
 
-	esw_cfg.pci_func = adapter->ahw.pci_func;
+	esw_cfg.pci_func = adapter->ahw->pci_func;
 	if (qlcnic_get_eswitch_port_config(adapter, &esw_cfg))
 			return -EIO;
 	qlcnic_set_vlan_config(adapter, &esw_cfg);
@@ -793,14 +793,14 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 	if (adapter->flags & QLCNIC_ADAPTER_INITIALIZED)
 		return 0;
 
-	priv_op = adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE;
+	priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
 	op_mode = readl(priv_op);
-	priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw.pci_func);
+	priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw->pci_func);
 
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
 		priv_level = QLCNIC_MGMT_FUNC;
 	else
-		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw.pci_func);
+		priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw->pci_func);
 
 	if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 		if (priv_level == QLCNIC_MGMT_FUNC) {
@@ -1040,7 +1040,7 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 
 	unsigned long flags = 0;
 	struct net_device *netdev = adapter->netdev;
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
 		handler = qlcnic_tmp_intr;
@@ -1077,7 +1077,7 @@ qlcnic_free_irq(struct qlcnic_adapter *adapter)
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
 
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
@@ -1117,14 +1117,14 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 		return -EIO;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		rds_ring = &adapter->recv_ctx.rds_rings[ring];
-		qlcnic_post_rx_buffers(adapter, ring, rds_ring);
+		rds_ring = &adapter->recv_ctx->rds_rings[ring];
+		qlcnic_post_rx_buffers(adapter, rds_ring);
 	}
 
 	qlcnic_set_multi(netdev);
 	qlcnic_fw_cmd_set_mtu(adapter, netdev->mtu);
 
-	adapter->ahw.linkup = 0;
+	adapter->ahw->linkup = 0;
 
 	if (adapter->max_sds_rings > 1)
 		qlcnic_config_rss(adapter, 1);
@@ -1274,7 +1274,7 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 	clear_bit(__QLCNIC_DEV_UP, &adapter->state);
 	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-			sds_ring = &adapter->recv_ctx.sds_rings[ring];
+			sds_ring = &adapter->recv_ctx->sds_rings[ring];
 			qlcnic_disable_int(sds_ring);
 		}
 	}
@@ -1295,6 +1295,39 @@ out:
 	netif_device_attach(netdev);
 }
 
+static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
+{
+	int err = 0;
+	adapter->ahw = kzalloc(sizeof(struct qlcnic_hardware_context),
+				GFP_KERNEL);
+	if (!adapter->ahw) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to allocate recv ctx resources for adapter\n");
+		err = -ENOMEM;
+		goto err_out;
+	}
+	adapter->recv_ctx = kzalloc(sizeof(struct qlcnic_recv_context),
+				GFP_KERNEL);
+	if (!adapter->recv_ctx) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to allocate recv ctx resources for adapter\n");
+		kfree(adapter->ahw);
+		adapter->ahw = NULL;
+		err = -ENOMEM;
+	}
+err_out:
+	return err;
+}
+
+static void qlcnic_free_adapter_resources(struct qlcnic_adapter *adapter)
+{
+	kfree(adapter->recv_ctx);
+	adapter->recv_ctx = NULL;
+
+	kfree(adapter->ahw);
+	adapter->ahw = NULL;
+}
+
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
@@ -1327,13 +1360,13 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		rds_ring = &adapter->recv_ctx.rds_rings[ring];
-		qlcnic_post_rx_buffers(adapter, ring, rds_ring);
+		rds_ring = &adapter->recv_ctx->rds_rings[ring];
+		qlcnic_post_rx_buffers(adapter, rds_ring);
 	}
 
 	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-			sds_ring = &adapter->recv_ctx.sds_rings[ring];
+			sds_ring = &adapter->recv_ctx->sds_rings[ring];
 			qlcnic_enable_int(sds_ring);
 		}
 	}
@@ -1503,23 +1536,26 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter = netdev_priv(netdev);
 	adapter->netdev  = netdev;
 	adapter->pdev    = pdev;
-	adapter->dev_rst_time = jiffies;
 
+	if (qlcnic_alloc_adapter_resources(adapter))
+		goto err_out_free_netdev;
+
+	adapter->dev_rst_time = jiffies;
 	revision_id = pdev->revision;
-	adapter->ahw.revision_id = revision_id;
+	adapter->ahw->revision_id = revision_id;
 
-	rwlock_init(&adapter->ahw.crb_lock);
-	mutex_init(&adapter->ahw.mem_lock);
+	rwlock_init(&adapter->ahw->crb_lock);
+	mutex_init(&adapter->ahw->mem_lock);
 
 	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
 
 	err = qlcnic_setup_pci_map(adapter);
 	if (err)
-		goto err_out_free_netdev;
+		goto err_out_free_hw;
 
 	/* This will be reset for mezz cards  */
-	adapter->portnum = adapter->ahw.pci_func;
+	adapter->portnum = adapter->ahw->pci_func;
 
 	err = qlcnic_get_board_info(adapter);
 	if (err) {
@@ -1547,7 +1583,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 		pr_info("%s: %s Board Chip rev 0x%x\n",
 				module_name(THIS_MODULE),
-				brd_name, adapter->ahw.revision_id);
+				brd_name, adapter->ahw->revision_id);
 	}
 
 	qlcnic_clear_stats(adapter);
@@ -1562,7 +1598,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
 
-	switch (adapter->ahw.port_type) {
+	switch (adapter->ahw->port_type) {
 	case QLCNIC_GBE:
 		dev_info(&adapter->pdev->dev, "%s: GbE port initialized\n",
 				adapter->netdev->name);
@@ -1587,6 +1623,9 @@ err_out_decr_ref:
 err_out_iounmap:
 	qlcnic_cleanup_pci_map(adapter);
 
+err_out_free_hw:
+	qlcnic_free_adapter_resources(adapter);
+
 err_out_free_netdev:
 	free_netdev(netdev);
 
@@ -1640,6 +1679,7 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 
+	qlcnic_free_adapter_resources(adapter);
 	free_netdev(netdev);
 }
 static int __qlcnic_shutdown(struct pci_dev *pdev)
@@ -2248,16 +2288,16 @@ void qlcnic_advert_link_change(struct qlcnic_adapter *adapter, int linkup)
 {
 	struct net_device *netdev = adapter->netdev;
 
-	if (adapter->ahw.linkup && !linkup) {
+	if (adapter->ahw->linkup && !linkup) {
 		netdev_info(netdev, "NIC Link is down\n");
-		adapter->ahw.linkup = 0;
+		adapter->ahw->linkup = 0;
 		if (netif_running(netdev)) {
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 		}
-	} else if (!adapter->ahw.linkup && linkup) {
+	} else if (!adapter->ahw->linkup && linkup) {
 		netdev_info(netdev, "NIC Link is up\n");
-		adapter->ahw.linkup = 1;
+		adapter->ahw->linkup = 1;
 		if (netif_running(netdev)) {
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
@@ -2493,7 +2533,7 @@ static void qlcnic_poll_controller(struct net_device *netdev)
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	disable_irq(adapter->irq);
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
@@ -3503,7 +3543,7 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 	u8 pci_func;
 	int i;
 
-	op_mode = readl(adapter->ahw.pci_base0 + QLCNIC_DRV_OP_MODE);
+	op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
 
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
@@ -3569,13 +3609,13 @@ qlcnic_sysfs_write_esw_config(struct file *file, struct kobject *kobj,
 			if (qlcnic_config_switch_port(adapter, &esw_cfg[i]))
 				return QL_STATUS_INVALID_PARAM;
 
-		if (adapter->ahw.pci_func != esw_cfg[i].pci_func)
+		if (adapter->ahw->pci_func != esw_cfg[i].pci_func)
 			continue;
 
 		op_mode = esw_cfg[i].op_mode;
 		qlcnic_get_eswitch_port_config(adapter, &esw_cfg[i]);
 		esw_cfg[i].op_mode = op_mode;
-		esw_cfg[i].pci_func = adapter->ahw.pci_func;
+		esw_cfg[i].pci_func = adapter->ahw->pci_func;
 
 		switch (esw_cfg[i].op_mode) {
 		case QLCNIC_PORT_DEFAULTS:
-- 
1.7.1

