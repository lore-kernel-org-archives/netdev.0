From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCHv2 07/11] netxen: add netxen_nic_ctx.c
Date: Fri, 18 Jul 2008 16:44:05 -0700
Message-ID: <1216424649-4597-8-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:55554 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756795AbYGRXoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 19:44:11 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Contains rx and tx ring context management and certain
firmware commands for netxen firmware v4.0.0+.

This patch gathers all HW context management code into
netxen_nic_ctx.c.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/Makefile              |    2 +-
 drivers/net/netxen/netxen_nic.h          |  272 +++++++++++++++++++++++++++++-
 drivers/net/netxen/netxen_nic_ethtool.c  |    4 +-
 drivers/net/netxen/netxen_nic_hw.c       |  243 --------------------------
 drivers/net/netxen/netxen_nic_init.c     |  154 +++++++++--------
 drivers/net/netxen/netxen_nic_main.c     |   21 +--
 drivers/net/netxen/netxen_nic_phan_reg.h |    2 -
 7 files changed, 359 insertions(+), 339 deletions(-)

diff --git a/drivers/net/netxen/Makefile b/drivers/net/netxen/Makefile
index c63a207..8e7c4c9 100644
--- a/drivers/net/netxen/Makefile
+++ b/drivers/net/netxen/Makefile
@@ -32,4 +32,4 @@
 obj-$(CONFIG_NETXEN_NIC) := netxen_nic.o
 
 netxen_nic-y := netxen_nic_hw.o netxen_nic_main.o netxen_nic_init.o \
-	netxen_nic_ethtool.o netxen_nic_niu.o
+	netxen_nic_ethtool.o netxen_nic_niu.o netxen_nic_ctx.o
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 87be0a6..9362190 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -84,7 +84,7 @@
 #define TX_RINGSIZE	\
 	(sizeof(struct netxen_cmd_buffer) * adapter->max_tx_desc_count)
 #define RCV_BUFFSIZE	\
-	(sizeof(struct netxen_rx_buffer) * rcv_desc->max_rx_desc_count)
+	(sizeof(struct netxen_rx_buffer) * rds_ring->max_rx_desc_count)
 #define find_diff_among(a,b,range) ((a)<(b)?((b)-(a)):((b)+(range)-(a)))
 
 #define NETXEN_NETDEV_STATUS		0x1
@@ -303,7 +303,7 @@ struct netxen_ring_ctx {
 #define netxen_set_cmd_desc_port(cmd_desc, var)	\
 	((cmd_desc)->port_ctxid |= ((var) & 0x0F))
 #define netxen_set_cmd_desc_ctxid(cmd_desc, var)	\
-	((cmd_desc)->port_ctxid |= ((var) & 0xF0))
+	((cmd_desc)->port_ctxid |= ((var) << 4 & 0xF0))
 
 #define netxen_set_cmd_desc_flags(cmd_desc, val)	\
 	(cmd_desc)->flags_opcode = ((cmd_desc)->flags_opcode & \
@@ -844,7 +844,7 @@ struct netxen_adapter_stats {
  * Rcv Descriptor Context. One such per Rcv Descriptor. There may
  * be one Rcv Descriptor for normal packets, one for jumbo and may be others.
  */
-struct netxen_rcv_desc_ctx {
+struct nx_host_rds_ring {
 	u32 flags;
 	u32 producer;
 	dma_addr_t phys_addr;
@@ -864,13 +864,270 @@ struct netxen_rcv_desc_ctx {
  * present elsewhere.
  */
 struct netxen_recv_context {
-	struct netxen_rcv_desc_ctx rcv_desc[NUM_RCV_DESC_RINGS];
+	u32 state;
+	u16 context_id;
+	u16 virt_port;
+
+	struct nx_host_rds_ring rds_rings[NUM_RCV_DESC_RINGS];
 	u32 status_rx_consumer;
 	u32 crb_sts_consumer;	/* reg offset */
 	dma_addr_t rcv_status_desc_phys_addr;
 	struct status_desc *rcv_status_desc_head;
 };
 
+/* New HW context creation */
+
+#define NX_OS_CRB_RETRY_COUNT	4000
+#define NX_CDRP_SIGNATURE_MAKE(pcifn, version) \
+	(((pcifn) & 0xff) | (((version) & 0xff) << 8) | (0xcafe << 16))
+
+#define NX_CDRP_CLEAR		0x00000000
+#define NX_CDRP_CMD_BIT		0x80000000
+
+/*
+ * All responses must have the NX_CDRP_CMD_BIT cleared
+ * in the crb NX_CDRP_CRB_OFFSET.
+ */
+#define NX_CDRP_FORM_RSP(rsp)	(rsp)
+#define NX_CDRP_IS_RSP(rsp)	(((rsp) & NX_CDRP_CMD_BIT) == 0)
+
+#define NX_CDRP_RSP_OK		0x00000001
+#define NX_CDRP_RSP_FAIL	0x00000002
+#define NX_CDRP_RSP_TIMEOUT	0x00000003
+
+/*
+ * All commands must have the NX_CDRP_CMD_BIT set in
+ * the crb NX_CDRP_CRB_OFFSET.
+ */
+#define NX_CDRP_FORM_CMD(cmd)	(NX_CDRP_CMD_BIT | (cmd))
+#define NX_CDRP_IS_CMD(cmd)	(((cmd) & NX_CDRP_CMD_BIT) != 0)
+
+#define NX_CDRP_CMD_SUBMIT_CAPABILITIES     0x00000001
+#define NX_CDRP_CMD_READ_MAX_RDS_PER_CTX    0x00000002
+#define NX_CDRP_CMD_READ_MAX_SDS_PER_CTX    0x00000003
+#define NX_CDRP_CMD_READ_MAX_RULES_PER_CTX  0x00000004
+#define NX_CDRP_CMD_READ_MAX_RX_CTX         0x00000005
+#define NX_CDRP_CMD_READ_MAX_TX_CTX         0x00000006
+#define NX_CDRP_CMD_CREATE_RX_CTX           0x00000007
+#define NX_CDRP_CMD_DESTROY_RX_CTX          0x00000008
+#define NX_CDRP_CMD_CREATE_TX_CTX           0x00000009
+#define NX_CDRP_CMD_DESTROY_TX_CTX          0x0000000a
+#define NX_CDRP_CMD_SETUP_STATISTICS        0x0000000e
+#define NX_CDRP_CMD_GET_STATISTICS          0x0000000f
+#define NX_CDRP_CMD_DELETE_STATISTICS       0x00000010
+#define NX_CDRP_CMD_SET_MTU                 0x00000012
+#define NX_CDRP_CMD_MAX                     0x00000013
+
+#define NX_RCODE_SUCCESS		0
+#define NX_RCODE_NO_HOST_MEM		1
+#define NX_RCODE_NO_HOST_RESOURCE	2
+#define NX_RCODE_NO_CARD_CRB		3
+#define NX_RCODE_NO_CARD_MEM		4
+#define NX_RCODE_NO_CARD_RESOURCE	5
+#define NX_RCODE_INVALID_ARGS		6
+#define NX_RCODE_INVALID_ACTION		7
+#define NX_RCODE_INVALID_STATE		8
+#define NX_RCODE_NOT_SUPPORTED		9
+#define NX_RCODE_NOT_PERMITTED		10
+#define NX_RCODE_NOT_READY		11
+#define NX_RCODE_DOES_NOT_EXIST		12
+#define NX_RCODE_ALREADY_EXISTS		13
+#define NX_RCODE_BAD_SIGNATURE		14
+#define NX_RCODE_CMD_NOT_IMPL		15
+#define NX_RCODE_CMD_INVALID		16
+#define NX_RCODE_TIMEOUT		17
+#define NX_RCODE_CMD_FAILED		18
+#define NX_RCODE_MAX_EXCEEDED		19
+#define NX_RCODE_MAX			20
+
+#define NX_DESTROY_CTX_RESET		0
+#define NX_DESTROY_CTX_D3_RESET		1
+#define NX_DESTROY_CTX_MAX		2
+
+/*
+ * Capabilities
+ */
+#define NX_CAP_BIT(class, bit)		(1 << bit)
+#define NX_CAP0_LEGACY_CONTEXT		NX_CAP_BIT(0, 0)
+#define NX_CAP0_MULTI_CONTEXT		NX_CAP_BIT(0, 1)
+#define NX_CAP0_LEGACY_MN		NX_CAP_BIT(0, 2)
+#define NX_CAP0_LEGACY_MS		NX_CAP_BIT(0, 3)
+#define NX_CAP0_CUT_THROUGH		NX_CAP_BIT(0, 4)
+#define NX_CAP0_LRO			NX_CAP_BIT(0, 5)
+#define NX_CAP0_LSO			NX_CAP_BIT(0, 6)
+#define NX_CAP0_JUMBO_CONTIGUOUS	NX_CAP_BIT(0, 7)
+#define NX_CAP0_LRO_CONTIGUOUS		NX_CAP_BIT(0, 8)
+
+/*
+ * Context state
+ */
+#define NX_HOST_CTX_STATE_FREED		0
+#define NX_HOST_CTX_STATE_ALLOCATED	1
+#define NX_HOST_CTX_STATE_ACTIVE	2
+#define NX_HOST_CTX_STATE_DISABLED	3
+#define NX_HOST_CTX_STATE_QUIESCED	4
+#define NX_HOST_CTX_STATE_MAX		5
+
+/*
+ * Rx context
+ */
+
+typedef struct {
+	u64 host_phys_addr;	/* Ring base addr */
+	u32 ring_size;		/* Ring entries */
+	u16 msi_index;
+	u16 rsvd;		/* Padding */
+} nx_hostrq_sds_ring_t;
+
+typedef struct {
+	u64 host_phys_addr;	/* Ring base addr */
+	u64 buff_size;		/* Packet buffer size */
+	u32 ring_size;		/* Ring entries */
+	u32 ring_kind;		/* Class of ring */
+} nx_hostrq_rds_ring_t;
+
+typedef struct {
+	u64 host_rsp_dma_addr;	/* Response dma'd here */
+	u32 capabilities[4];	/* Flag bit vector */
+	u32 host_int_crb_mode;	/* Interrupt crb usage */
+	u32 host_rds_crb_mode;	/* RDS crb usage */
+	/* These ring offsets are relative to data[0] below */
+	u32 rds_ring_offset;	/* Offset to RDS config */
+	u32 sds_ring_offset;	/* Offset to SDS config */
+	u16 num_rds_rings;	/* Count of RDS rings */
+	u16 num_sds_rings;	/* Count of SDS rings */
+	u16 rsvd1;		/* Padding */
+	u16 rsvd2;		/* Padding */
+	u8  reserved[128]; 	/* reserve space for future expansion*/
+	/* MUST BE 64-bit aligned.
+	   The following is packed:
+	   - N hostrq_rds_rings
+	   - N hostrq_sds_rings */
+	char data[0];
+} nx_hostrq_rx_ctx_t;
+
+typedef struct {
+	u32 host_producer_crb;	/* Crb to use */
+	u32 rsvd1;		/* Padding */
+} nx_cardrsp_rds_ring_t;
+
+typedef struct {
+	u32 host_consumer_crb;	/* Crb to use */
+	u32 interrupt_crb;	/* Crb to use */
+} nx_cardrsp_sds_ring_t;
+
+typedef struct {
+	/* These ring offsets are relative to data[0] below */
+	u32 rds_ring_offset;	/* Offset to RDS config */
+	u32 sds_ring_offset;	/* Offset to SDS config */
+	u32 host_ctx_state;	/* Starting State */
+	u32 num_fn_per_port;	/* How many PCI fn share the port */
+	u16 num_rds_rings;	/* Count of RDS rings */
+	u16 num_sds_rings;	/* Count of SDS rings */
+	u16 context_id;		/* Handle for context */
+	u8  phys_port;		/* Physical id of port */
+	u8  virt_port;		/* Virtual/Logical id of port */
+	u8  reserved[128];	/* save space for future expansion */
+	/*  MUST BE 64-bit aligned.
+	   The following is packed:
+	   - N cardrsp_rds_rings
+	   - N cardrs_sds_rings */
+	char data[0];
+} nx_cardrsp_rx_ctx_t;
+
+#define SIZEOF_HOSTRQ_RX(HOSTRQ_RX, rds_rings, sds_rings)	\
+	(sizeof(HOSTRQ_RX) + 					\
+	(rds_rings)*(sizeof(nx_hostrq_rds_ring_t)) +		\
+	(sds_rings)*(sizeof(nx_hostrq_sds_ring_t)))
+
+#define SIZEOF_CARDRSP_RX(CARDRSP_RX, rds_rings, sds_rings) 	\
+	(sizeof(CARDRSP_RX) + 					\
+	(rds_rings)*(sizeof(nx_cardrsp_rds_ring_t)) + 		\
+	(sds_rings)*(sizeof(nx_cardrsp_sds_ring_t)))
+
+/*
+ * Tx context
+ */
+
+typedef struct {
+	u64 host_phys_addr;	/* Ring base addr */
+	u32 ring_size;		/* Ring entries */
+	u32 rsvd;		/* Padding */
+} nx_hostrq_cds_ring_t;
+
+typedef struct {
+	u64 host_rsp_dma_addr;	/* Response dma'd here */
+	u64 cmd_cons_dma_addr;	/*  */
+	u64 dummy_dma_addr;	/*  */
+	u32 capabilities[4];	/* Flag bit vector */
+	u32 host_int_crb_mode;	/* Interrupt crb usage */
+	u32 rsvd1;		/* Padding */
+	u16 rsvd2;		/* Padding */
+	u16 interrupt_ctl;
+	u16 msi_index;
+	u16 rsvd3;		/* Padding */
+	nx_hostrq_cds_ring_t cds_ring;	/* Desc of cds ring */
+	u8  reserved[128];	/* future expansion */
+} nx_hostrq_tx_ctx_t;
+
+typedef struct {
+	u32 host_producer_crb;	/* Crb to use */
+	u32 interrupt_crb;	/* Crb to use */
+} nx_cardrsp_cds_ring_t;
+
+typedef struct {
+	u32 host_ctx_state;	/* Starting state */
+	u16 context_id;		/* Handle for context */
+	u8  phys_port;		/* Physical id of port */
+	u8  virt_port;		/* Virtual/Logical id of port */
+	nx_cardrsp_cds_ring_t cds_ring;	/* Card cds settings */
+	u8  reserved[128];	/* future expansion */
+} nx_cardrsp_tx_ctx_t;
+
+#define SIZEOF_HOSTRQ_TX(HOSTRQ_TX)	(sizeof(HOSTRQ_TX))
+#define SIZEOF_CARDRSP_TX(CARDRSP_TX)	(sizeof(CARDRSP_TX))
+
+/* CRB */
+
+#define NX_HOST_RDS_CRB_MODE_UNIQUE	0
+#define NX_HOST_RDS_CRB_MODE_SHARED	1
+#define NX_HOST_RDS_CRB_MODE_CUSTOM	2
+#define NX_HOST_RDS_CRB_MODE_MAX	3
+
+#define NX_HOST_INT_CRB_MODE_UNIQUE	0
+#define NX_HOST_INT_CRB_MODE_SHARED	1
+#define NX_HOST_INT_CRB_MODE_NORX	2
+#define NX_HOST_INT_CRB_MODE_NOTX	3
+#define NX_HOST_INT_CRB_MODE_NORXTX	4
+
+
+/* MAC */
+
+#define MC_COUNT_P2	16
+#define MC_COUNT_P3	38
+
+#define NETXEN_MAC_NOOP	0
+#define NETXEN_MAC_ADD	1
+#define NETXEN_MAC_DEL	2
+
+typedef struct nx_mac_list_s {
+	struct nx_mac_list_s *next;
+	uint8_t mac_addr[MAX_ADDR_LEN];
+} nx_mac_list_t;
+
+typedef struct {
+	u64 qhdr;
+	u64 req_hdr;
+	u64 words[6];
+} nic_request_t;
+
+typedef struct {
+	u8 op;
+	u8 tag;
+	u8 mac_addr[6];
+} nx_mac_req_t;
+
+
 #define NETXEN_NIC_MSI_ENABLED		0x02
 #define NETXEN_NIC_MSIX_ENABLED		0x04
 #define NETXEN_IS_MSI_FAMILY(adapter) \
@@ -899,11 +1156,13 @@ struct netxen_adapter {
 	int mtu;
 	int portnum;
 	u8 physical_port;
+	u16 tx_context_id;
 
 	uint8_t		mc_enabled;
 	uint8_t		max_mc_count;
 
 	struct netxen_legacy_intr_set legacy_intr;
+	u32	crb_intr_mask;
 
 	struct work_struct watchdog_task;
 	struct timer_list watchdog_timer;
@@ -926,6 +1185,8 @@ struct netxen_adapter {
 	u32 max_jumbo_rx_desc_count;
 	u32 max_lro_rx_desc_count;
 
+	int max_rds_rings;
+
 	u32 flags;
 	u32 irq;
 	int driver_mismatch;
@@ -1144,7 +1405,10 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx,
 int netxen_process_cmd_ring(struct netxen_adapter *adapter);
 u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctx, int max);
 void netxen_nic_set_multi(struct net_device *netdev);
+
+u32 nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, u32 mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
+
 int netxen_nic_set_mac(struct net_device *netdev, void *p);
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 7e49e61..381d55a 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -524,9 +524,9 @@ netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 	ring->rx_jumbo_pending = 0;
 	for (i = 0; i < MAX_RCV_CTX; ++i) {
 		ring->rx_pending += adapter->recv_ctx[i].
-		    rcv_desc[RCV_DESC_NORMAL_CTXID].max_rx_desc_count;
+		    rds_rings[RCV_DESC_NORMAL_CTXID].max_rx_desc_count;
 		ring->rx_jumbo_pending += adapter->recv_ctx[i].
-		    rcv_desc[RCV_DESC_JUMBO_CTXID].max_rx_desc_count;
+		    rds_rings[RCV_DESC_JUMBO_CTXID].max_rx_desc_count;
 	}
 	ring->tx_pending = adapter->max_tx_desc_count;
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index fde8c6f..d46b4df 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -280,80 +280,6 @@ static unsigned crb_hub_agt[64] =
 	0,
 };
 
-struct netxen_recv_crb recv_crb_registers[] = {
-	/*
-	 * Instance 0.
-	 */
-	{
-		/* crb_rcv_producer: */
-		{
-			NETXEN_NIC_REG(0x100),
-			/* Jumbo frames */
-			NETXEN_NIC_REG(0x110),
-			/* LRO */
-			NETXEN_NIC_REG(0x120)
-		},
-		/* crb_sts_consumer: */
-		NETXEN_NIC_REG(0x138),
-	},
-	/*
-	 * Instance 1,
-	 */
-	{
-		/* crb_rcv_producer: */
-		{
-			NETXEN_NIC_REG(0x144),
-			/* Jumbo frames */
-			NETXEN_NIC_REG(0x154),
-			/* LRO */
-			NETXEN_NIC_REG(0x164)
-		},
-		/* crb_sts_consumer: */
-		NETXEN_NIC_REG(0x17c),
-	},
-	/*
-	 * Instance 2,
-	 */
-	{
-		/* crb_rcv_producer: */
-		{
-			NETXEN_NIC_REG(0x1d8),
-			/* Jumbo frames */
-			NETXEN_NIC_REG(0x1f8),
-			/* LRO */
-			NETXEN_NIC_REG(0x208)
-		},
-		/* crb_sts_consumer: */
-		NETXEN_NIC_REG(0x220),
-	},
-	/*
-	 * Instance 3,
-	 */
-	{
-		/* crb_rcv_producer: */
-		{
-			NETXEN_NIC_REG(0x22c),
-			/* Jumbo frames */
-			NETXEN_NIC_REG(0x23c),
-			/* LRO */
-			NETXEN_NIC_REG(0x24c)
-		},
-		/* crb_sts_consumer: */
-		NETXEN_NIC_REG(0x264),
-	},
-};
-
-static u64 ctx_addr_sig_regs[][3] = {
-	{NETXEN_NIC_REG(0x188), NETXEN_NIC_REG(0x18c), NETXEN_NIC_REG(0x1c0)},
-	{NETXEN_NIC_REG(0x190), NETXEN_NIC_REG(0x194), NETXEN_NIC_REG(0x1c4)},
-	{NETXEN_NIC_REG(0x198), NETXEN_NIC_REG(0x19c), NETXEN_NIC_REG(0x1c8)},
-	{NETXEN_NIC_REG(0x1a0), NETXEN_NIC_REG(0x1a4), NETXEN_NIC_REG(0x1cc)}
-};
-#define CRB_CTX_ADDR_REG_LO(FUNC_ID)		(ctx_addr_sig_regs[FUNC_ID][0])
-#define CRB_CTX_ADDR_REG_HI(FUNC_ID)		(ctx_addr_sig_regs[FUNC_ID][2])
-#define CRB_CTX_SIGNATURE_REG(FUNC_ID)		(ctx_addr_sig_regs[FUNC_ID][1])
-
-
 /*  PCI Windowing for DDR regions.  */
 
 #define ADDR_IN_RANGE(addr, low, high)	\
@@ -368,10 +294,6 @@ static u64 ctx_addr_sig_regs[][3] = {
 #define NETXEN_NIU_HDRSIZE	(0x1 << 6)
 #define NETXEN_NIU_TLRSIZE	(0x1 << 5)
 
-#define lower32(x)		((u32)((x) & 0xffffffff))
-#define upper32(x)			\
-	((u32)(((unsigned long long)(x) >> 32) & 0xffffffff))
-
 #define NETXEN_NIC_ZERO_PAUSE_ADDR     0ULL
 #define NETXEN_NIC_UNIT_PAUSE_ADDR     0x200ULL
 #define NETXEN_NIC_EPG_PAUSE_ADDR1     0x2200010000c28001ULL
@@ -556,171 +478,6 @@ int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
 	return 0;
 }
 
-/*
- * check if the firmware has been downloaded and ready to run  and
- * setup the address for the descriptors in the adapter
- */
-int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
-{
-	struct netxen_hardware_context *hw = &adapter->ahw;
-	u32 state = 0;
-	void *addr;
-	int err = 0;
-	int ctx, ring;
-	struct netxen_recv_context *recv_ctx;
-	struct netxen_rcv_desc_ctx *rcv_desc;
-	int func_id = adapter->portnum;
-
-	err = netxen_receive_peg_ready(adapter);
-	if (err) {
-		printk(KERN_ERR "Rcv Peg initialization not complete:%x.\n",
-				state);
-		return err;
-	}
-	adapter->intr_scheme = adapter->pci_read_normalize(adapter,
-			CRB_NIC_CAPABILITIES_FW);
-	adapter->msi_mode = adapter->pci_read_normalize(adapter,
-			CRB_NIC_MSI_MODE_FW);
-
-	addr = pci_alloc_consistent(adapter->pdev,
-			    sizeof(struct netxen_ring_ctx) + sizeof(uint32_t),
-			    &adapter->ctx_desc_phys_addr);
-
-	if (addr == NULL) {
-		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
-		err = -ENOMEM;
-		return err;
-	}
-	memset(addr, 0, sizeof(struct netxen_ring_ctx));
-	adapter->ctx_desc = (struct netxen_ring_ctx *)addr;
-	adapter->ctx_desc->ctx_id = cpu_to_le32(adapter->portnum);
-	adapter->ctx_desc->cmd_consumer_offset =
-	    cpu_to_le64(adapter->ctx_desc_phys_addr +
-			sizeof(struct netxen_ring_ctx));
-	adapter->cmd_consumer = (__le32 *) (((char *)addr) +
-					      sizeof(struct netxen_ring_ctx));
-
-	addr = pci_alloc_consistent(adapter->pdev,
-			    sizeof(struct cmd_desc_type0) *
-			    adapter->max_tx_desc_count,
-			    &hw->cmd_desc_phys_addr);
-
-	if (addr == NULL) {
-		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
-		netxen_free_hw_resources(adapter);
-		return -ENOMEM;
-	}
-
-	adapter->ctx_desc->cmd_ring_addr =
-		cpu_to_le64(hw->cmd_desc_phys_addr);
-	adapter->ctx_desc->cmd_ring_size =
-		cpu_to_le32(adapter->max_tx_desc_count);
-
-	hw->cmd_desc_head = (struct cmd_desc_type0 *)addr;
-
-	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		recv_ctx = &adapter->recv_ctx[ctx];
-
-		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-			rcv_desc = &recv_ctx->rcv_desc[ring];
-			addr = pci_alloc_consistent(adapter->pdev,
-					    RCV_DESC_RINGSIZE,
-					    &rcv_desc->phys_addr);
-			if (addr == NULL) {
-				DPRINTK(ERR, "bad return from "
-					"pci_alloc_consistent\n");
-				netxen_free_hw_resources(adapter);
-				err = -ENOMEM;
-				return err;
-			}
-			rcv_desc->desc_head = (struct rcv_desc *)addr;
-			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr =
-			    cpu_to_le64(rcv_desc->phys_addr);
-			adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
-			    cpu_to_le32(rcv_desc->max_rx_desc_count);
-			rcv_desc->crb_rcv_producer =
-				    recv_crb_registers[adapter->portnum].
-				    crb_rcv_producer[ring];
-		}
-
-		addr = pci_alloc_consistent(adapter->pdev, STATUS_DESC_RINGSIZE,
-				    &recv_ctx->rcv_status_desc_phys_addr);
-		if (addr == NULL) {
-			DPRINTK(ERR, "bad return from"
-				" pci_alloc_consistent\n");
-			netxen_free_hw_resources(adapter);
-			err = -ENOMEM;
-			return err;
-		}
-		recv_ctx->rcv_status_desc_head = (struct status_desc *)addr;
-		adapter->ctx_desc->sts_ring_addr =
-		    cpu_to_le64(recv_ctx->rcv_status_desc_phys_addr);
-		adapter->ctx_desc->sts_ring_size =
-		    cpu_to_le32(adapter->max_rx_desc_count);
-		recv_ctx->crb_sts_consumer =
-			recv_crb_registers[adapter->portnum].crb_sts_consumer;
-
-	}
-	/* Window = 1 */
-
-	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_LO(func_id),
-			lower32(adapter->ctx_desc_phys_addr));
-	adapter->pci_write_normalize(adapter, CRB_CTX_ADDR_REG_HI(func_id),
-			upper32(adapter->ctx_desc_phys_addr));
-	adapter->pci_write_normalize(adapter, CRB_CTX_SIGNATURE_REG(func_id),
-			NETXEN_CTX_SIGNATURE | func_id);
-	return err;
-}
-
-void netxen_free_hw_resources(struct netxen_adapter *adapter)
-{
-	struct netxen_recv_context *recv_ctx;
-	struct netxen_rcv_desc_ctx *rcv_desc;
-	int ctx, ring;
-
-	if (adapter->ctx_desc != NULL) {
-		pci_free_consistent(adapter->pdev,
-				    sizeof(struct netxen_ring_ctx) +
-				    sizeof(uint32_t),
-				    adapter->ctx_desc,
-				    adapter->ctx_desc_phys_addr);
-		adapter->ctx_desc = NULL;
-	}
-
-	if (adapter->ahw.cmd_desc_head != NULL) {
-		pci_free_consistent(adapter->pdev,
-				    sizeof(struct cmd_desc_type0) *
-				    adapter->max_tx_desc_count,
-				    adapter->ahw.cmd_desc_head,
-				    adapter->ahw.cmd_desc_phys_addr);
-		adapter->ahw.cmd_desc_head = NULL;
-	}
-
-	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-		recv_ctx = &adapter->recv_ctx[ctx];
-		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-			rcv_desc = &recv_ctx->rcv_desc[ring];
-
-			if (rcv_desc->desc_head != NULL) {
-				pci_free_consistent(adapter->pdev,
-						    RCV_DESC_RINGSIZE,
-						    rcv_desc->desc_head,
-						    rcv_desc->phys_addr);
-				rcv_desc->desc_head = NULL;
-			}
-		}
-
-		if (recv_ctx->rcv_status_desc_head != NULL) {
-			pci_free_consistent(adapter->pdev,
-					    STATUS_DESC_RINGSIZE,
-					    recv_ctx->rcv_status_desc_head,
-					    recv_ctx->
-					    rcv_status_desc_phys_addr);
-			recv_ctx->rcv_status_desc_head = NULL;
-		}
-	}
-}
-
 void netxen_tso_check(struct netxen_adapter *adapter,
 		      struct cmd_desc_type0 *desc, struct sk_buff *skb)
 {
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 7c3fbc4..d222436 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -158,21 +158,21 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 void netxen_release_rx_buffers(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
-	struct netxen_rcv_desc_ctx *rcv_desc;
+	struct nx_host_rds_ring *rds_ring;
 	struct netxen_rx_buffer *rx_buf;
 	int i, ctxid, ring;
 
 	for (ctxid = 0; ctxid < MAX_RCV_CTX; ++ctxid) {
 		recv_ctx = &adapter->recv_ctx[ctxid];
-		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-			rcv_desc = &recv_ctx->rcv_desc[ring];
-			for (i = 0; i < rcv_desc->max_rx_desc_count; ++i) {
-				rx_buf = &(rcv_desc->rx_buf_arr[i]);
+		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+			rds_ring = &recv_ctx->rds_rings[ring];
+			for (i = 0; i < rds_ring->max_rx_desc_count; ++i) {
+				rx_buf = &(rds_ring->rx_buf_arr[i]);
 				if (rx_buf->state == NETXEN_BUFFER_FREE)
 					continue;
 				pci_unmap_single(adapter->pdev,
 						rx_buf->dma,
-						rcv_desc->dma_size,
+						rds_ring->dma_size,
 						PCI_DMA_FROMDEVICE);
 				if (rx_buf->skb != NULL)
 					dev_kfree_skb_any(rx_buf->skb);
@@ -216,16 +216,16 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 void netxen_free_sw_resources(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
-	struct netxen_rcv_desc_ctx *rcv_desc;
+	struct nx_host_rds_ring *rds_ring;
 	int ctx, ring;
 
 	for (ctx = 0; ctx < MAX_RCV_CTX; ctx++) {
 		recv_ctx = &adapter->recv_ctx[ctx];
-		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-			rcv_desc = &recv_ctx->rcv_desc[ring];
-			if (rcv_desc->rx_buf_arr) {
-				vfree(rcv_desc->rx_buf_arr);
-				rcv_desc->rx_buf_arr = NULL;
+		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+			rds_ring = &recv_ctx->rds_rings[ring];
+			if (rds_ring->rx_buf_arr) {
+				vfree(rds_ring->rx_buf_arr);
+				rds_ring->rx_buf_arr = NULL;
 			}
 		}
 	}
@@ -237,7 +237,7 @@ void netxen_free_sw_resources(struct netxen_adapter *adapter)
 int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
-	struct netxen_rcv_desc_ctx *rcv_desc;
+	struct nx_host_rds_ring *rds_ring;
 	struct netxen_rx_buffer *rx_buf;
 	int ctx, ring, i, num_rx_bufs;
 
@@ -255,52 +255,52 @@ int netxen_alloc_sw_resources(struct netxen_adapter *adapter)
 
 	for (ctx = 0; ctx < MAX_RCV_CTX; ctx++) {
 		recv_ctx = &adapter->recv_ctx[ctx];
-		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
-			rcv_desc = &recv_ctx->rcv_desc[ring];
+		for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+			rds_ring = &recv_ctx->rds_rings[ring];
 			switch (RCV_DESC_TYPE(ring)) {
 			case RCV_DESC_NORMAL:
-				rcv_desc->max_rx_desc_count =
+				rds_ring->max_rx_desc_count =
 					adapter->max_rx_desc_count;
-				rcv_desc->flags = RCV_DESC_NORMAL;
-				rcv_desc->dma_size = RX_DMA_MAP_LEN;
-				rcv_desc->skb_size = MAX_RX_BUFFER_LENGTH;
+				rds_ring->flags = RCV_DESC_NORMAL;
+				rds_ring->dma_size = RX_DMA_MAP_LEN;
+				rds_ring->skb_size = MAX_RX_BUFFER_LENGTH;
 				break;
 
 			case RCV_DESC_JUMBO:
-				rcv_desc->max_rx_desc_count =
+				rds_ring->max_rx_desc_count =
 					adapter->max_jumbo_rx_desc_count;
-				rcv_desc->flags = RCV_DESC_JUMBO;
-				rcv_desc->dma_size = RX_JUMBO_DMA_MAP_LEN;
-				rcv_desc->skb_size =
+				rds_ring->flags = RCV_DESC_JUMBO;
+				rds_ring->dma_size = RX_JUMBO_DMA_MAP_LEN;
+				rds_ring->skb_size =
 					MAX_RX_JUMBO_BUFFER_LENGTH;
 				break;
 
 			case RCV_RING_LRO:
-				rcv_desc->max_rx_desc_count =
+				rds_ring->max_rx_desc_count =
 					adapter->max_lro_rx_desc_count;
-				rcv_desc->flags = RCV_DESC_LRO;
-				rcv_desc->dma_size = RX_LRO_DMA_MAP_LEN;
-				rcv_desc->skb_size = MAX_RX_LRO_BUFFER_LENGTH;
+				rds_ring->flags = RCV_DESC_LRO;
+				rds_ring->dma_size = RX_LRO_DMA_MAP_LEN;
+				rds_ring->skb_size = MAX_RX_LRO_BUFFER_LENGTH;
 				break;
 
 			}
-			rcv_desc->rx_buf_arr = (struct netxen_rx_buffer *)
+			rds_ring->rx_buf_arr = (struct netxen_rx_buffer *)
 				vmalloc(RCV_BUFFSIZE);
-			if (rcv_desc->rx_buf_arr == NULL) {
+			if (rds_ring->rx_buf_arr == NULL) {
 				printk(KERN_ERR "%s: Failed to allocate "
 					"rx buffer ring %d\n",
 					netdev->name, ring);
 				/* free whatever was already allocated */
 				goto err_out;
 			}
-			memset(rcv_desc->rx_buf_arr, 0, RCV_BUFFSIZE);
-			rcv_desc->begin_alloc = 0;
+			memset(rds_ring->rx_buf_arr, 0, RCV_BUFFSIZE);
+			rds_ring->begin_alloc = 0;
 			/*
 			 * Now go through all of them, set reference handles
 			 * and put them in the queues.
 			 */
-			num_rx_bufs = rcv_desc->max_rx_desc_count;
-			rx_buf = rcv_desc->rx_buf_arr;
+			num_rx_bufs = rds_ring->max_rx_desc_count;
+			rx_buf = rds_ring->rx_buf_arr;
 			for (i = 0; i < num_rx_bufs; i++) {
 				rx_buf->ref_handle = i;
 				rx_buf->state = NETXEN_BUFFER_FREE;
@@ -1154,7 +1154,7 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 	struct sk_buff *skb;
 	u32 length = netxen_get_sts_totallength(sts_data);
 	u32 desc_ctx;
-	struct netxen_rcv_desc_ctx *rcv_desc;
+	struct nx_host_rds_ring *rds_ring;
 	int ret;
 
 	desc_ctx = netxen_get_sts_type(sts_data);
@@ -1164,13 +1164,13 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 		return;
 	}
 
-	rcv_desc = &recv_ctx->rcv_desc[desc_ctx];
-	if (unlikely(index > rcv_desc->max_rx_desc_count)) {
+	rds_ring = &recv_ctx->rds_rings[desc_ctx];
+	if (unlikely(index > rds_ring->max_rx_desc_count)) {
 		DPRINTK(ERR, "Got a buffer index:%x Max is %x\n",
-			index, rcv_desc->max_rx_desc_count);
+			index, rds_ring->max_rx_desc_count);
 		return;
 	}
-	buffer = &rcv_desc->rx_buf_arr[index];
+	buffer = &rds_ring->rx_buf_arr[index];
 	if (desc_ctx == RCV_DESC_LRO_CTXID) {
 		buffer->lro_current_frags++;
 		if (netxen_get_sts_desc_lro_last_frag(desc)) {
@@ -1191,7 +1191,7 @@ static void netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 		}
 	}
 
-	pci_unmap_single(pdev, buffer->dma, rcv_desc->dma_size,
+	pci_unmap_single(pdev, buffer->dma, rds_ring->dma_size,
 			 PCI_DMA_FROMDEVICE);
 
 	skb = (struct sk_buff *)buffer->skb;
@@ -1249,7 +1249,7 @@ u32 netxen_process_rcv_ring(struct netxen_adapter *adapter, int ctxid, int max)
 		consumer = (consumer + 1) & (adapter->max_rx_desc_count - 1);
 		count++;
 	}
-	for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++)
+	for (ring = 0; ring < adapter->max_rds_rings; ring++)
 		netxen_post_rx_buffers_nodb(adapter, ctxid, ring);
 
 	/* update the consumer index in phantom */
@@ -1340,7 +1340,7 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 	struct pci_dev *pdev = adapter->pdev;
 	struct sk_buff *skb;
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctx]);
-	struct netxen_rcv_desc_ctx *rcv_desc = NULL;
+	struct nx_host_rds_ring *rds_ring = NULL;
 	uint producer;
 	struct rcv_desc *pdesc;
 	struct netxen_rx_buffer *buffer;
@@ -1349,27 +1349,27 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 	netxen_ctx_msg msg = 0;
 	dma_addr_t dma;
 
-	rcv_desc = &recv_ctx->rcv_desc[ringid];
+	rds_ring = &recv_ctx->rds_rings[ringid];
 
-	producer = rcv_desc->producer;
-	index = rcv_desc->begin_alloc;
-	buffer = &rcv_desc->rx_buf_arr[index];
+	producer = rds_ring->producer;
+	index = rds_ring->begin_alloc;
+	buffer = &rds_ring->rx_buf_arr[index];
 	/* We can start writing rx descriptors into the phantom memory. */
 	while (buffer->state == NETXEN_BUFFER_FREE) {
-		skb = dev_alloc_skb(rcv_desc->skb_size);
+		skb = dev_alloc_skb(rds_ring->skb_size);
 		if (unlikely(!skb)) {
 			/*
 			 * TODO
 			 * We need to schedule the posting of buffers to the pegs.
 			 */
-			rcv_desc->begin_alloc = index;
+			rds_ring->begin_alloc = index;
 			DPRINTK(ERR, "netxen_post_rx_buffers: "
 				" allocated only %d buffers\n", count);
 			break;
 		}
 
 		count++;	/* now there should be no failure */
-		pdesc = &rcv_desc->desc_head[producer];
+		pdesc = &rds_ring->desc_head[producer];
 
 #if defined(XGB_DEBUG)
 		*(unsigned long *)(skb->head) = 0xc0debabe;
@@ -1382,7 +1382,7 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 		 * buffer after it has been filled  FSL  TBD TBD
 		 * skb->dev = netdev;
 		 */
-		dma = pci_map_single(pdev, skb->data, rcv_desc->dma_size,
+		dma = pci_map_single(pdev, skb->data, rds_ring->dma_size,
 				     PCI_DMA_FROMDEVICE);
 		pdesc->addr_buffer = cpu_to_le64(dma);
 		buffer->skb = skb;
@@ -1390,36 +1390,40 @@ void netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ctx, u32 ringid)
 		buffer->dma = dma;
 		/* make a rcv descriptor  */
 		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
-		pdesc->buffer_length = cpu_to_le32(rcv_desc->dma_size);
+		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 		DPRINTK(INFO, "done writing descripter\n");
 		producer =
-		    get_next_index(producer, rcv_desc->max_rx_desc_count);
-		index = get_next_index(index, rcv_desc->max_rx_desc_count);
-		buffer = &rcv_desc->rx_buf_arr[index];
+		    get_next_index(producer, rds_ring->max_rx_desc_count);
+		index = get_next_index(index, rds_ring->max_rx_desc_count);
+		buffer = &rds_ring->rx_buf_arr[index];
 	}
 	/* if we did allocate buffers, then write the count to Phantom */
 	if (count) {
-		rcv_desc->begin_alloc = index;
-		rcv_desc->producer = producer;
+		rds_ring->begin_alloc = index;
+		rds_ring->producer = producer;
 			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
-				rcv_desc->crb_rcv_producer,
-				(producer-1) & (rcv_desc->max_rx_desc_count-1));
+				rds_ring->crb_rcv_producer,
+				(producer-1) & (rds_ring->max_rx_desc_count-1));
+
+		if (adapter->fw_major < 4) {
 			/*
 			 * Write a doorbell msg to tell phanmon of change in
 			 * receive ring producer
+			 * Only for firmware version < 4.0.0
 			 */
 			netxen_set_msg_peg_id(msg, NETXEN_RCV_PEG_DB_ID);
 			netxen_set_msg_privid(msg);
 			netxen_set_msg_count(msg,
 					     ((producer -
-					       1) & (rcv_desc->
+					       1) & (rds_ring->
 						     max_rx_desc_count - 1)));
 			netxen_set_msg_ctxid(msg, adapter->portnum);
 			netxen_set_msg_opcode(msg, NETXEN_RCV_PRODUCER(ringid));
 			writel(msg,
 			       DB_NORMALIZE(adapter,
 					    NETXEN_RCV_PRODUCER_OFFSET));
+		}
 	}
 }
 
@@ -1429,32 +1433,32 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	struct sk_buff *skb;
 	struct netxen_recv_context *recv_ctx = &(adapter->recv_ctx[ctx]);
-	struct netxen_rcv_desc_ctx *rcv_desc = NULL;
+	struct nx_host_rds_ring *rds_ring = NULL;
 	u32 producer;
 	struct rcv_desc *pdesc;
 	struct netxen_rx_buffer *buffer;
 	int count = 0;
 	int index = 0;
 
-	rcv_desc = &recv_ctx->rcv_desc[ringid];
+	rds_ring = &recv_ctx->rds_rings[ringid];
 
-	producer = rcv_desc->producer;
-	index = rcv_desc->begin_alloc;
-	buffer = &rcv_desc->rx_buf_arr[index];
+	producer = rds_ring->producer;
+	index = rds_ring->begin_alloc;
+	buffer = &rds_ring->rx_buf_arr[index];
 	/* We can start writing rx descriptors into the phantom memory. */
 	while (buffer->state == NETXEN_BUFFER_FREE) {
-		skb = dev_alloc_skb(rcv_desc->skb_size);
+		skb = dev_alloc_skb(rds_ring->skb_size);
 		if (unlikely(!skb)) {
 			/*
 			 * We need to schedule the posting of buffers to the pegs.
 			 */
-			rcv_desc->begin_alloc = index;
+			rds_ring->begin_alloc = index;
 			DPRINTK(ERR, "netxen_post_rx_buffers_nodb: "
 				" allocated only %d buffers\n", count);
 			break;
 		}
 		count++;	/* now there should be no failure */
-		pdesc = &rcv_desc->desc_head[producer];
+		pdesc = &rds_ring->desc_head[producer];
 		skb_reserve(skb, 2);
 		/*
 		 * This will be setup when we receive the
@@ -1464,27 +1468,27 @@ static void netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
 		buffer->skb = skb;
 		buffer->state = NETXEN_BUFFER_BUSY;
 		buffer->dma = pci_map_single(pdev, skb->data,
-					     rcv_desc->dma_size,
+					     rds_ring->dma_size,
 					     PCI_DMA_FROMDEVICE);
 
 		/* make a rcv descriptor  */
 		pdesc->reference_handle = cpu_to_le16(buffer->ref_handle);
-		pdesc->buffer_length = cpu_to_le32(rcv_desc->dma_size);
+		pdesc->buffer_length = cpu_to_le32(rds_ring->dma_size);
 		pdesc->addr_buffer = cpu_to_le64(buffer->dma);
 		producer =
-		    get_next_index(producer, rcv_desc->max_rx_desc_count);
-		index = get_next_index(index, rcv_desc->max_rx_desc_count);
-		buffer = &rcv_desc->rx_buf_arr[index];
+		    get_next_index(producer, rds_ring->max_rx_desc_count);
+		index = get_next_index(index, rds_ring->max_rx_desc_count);
+		buffer = &rds_ring->rx_buf_arr[index];
 	}
 
 	/* if we did allocate buffers, then write the count to Phantom */
 	if (count) {
-		rcv_desc->begin_alloc = index;
-		rcv_desc->producer = producer;
+		rds_ring->begin_alloc = index;
+		rds_ring->producer = producer;
 			/* Window = 1 */
 		adapter->pci_write_normalize(adapter,
-			rcv_desc->crb_rcv_producer,
-				(producer-1) & (rcv_desc->max_rx_desc_count-1));
+			rds_ring->crb_rcv_producer,
+				(producer-1) & (rds_ring->max_rx_desc_count-1));
 			wmb();
 	}
 }
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2d0963f..03d796d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -151,22 +151,17 @@ static uint32_t msi_tgt_status[8] = {
 	ISR_INT_TARGET_STATUS_F6, ISR_INT_TARGET_STATUS_F7
 };
 
-static uint32_t sw_int_mask[4] = {
-	CRB_SW_INT_MASK_0, CRB_SW_INT_MASK_1,
-	CRB_SW_INT_MASK_2, CRB_SW_INT_MASK_3
-};
-
 static struct netxen_legacy_intr_set legacy_intr[] = NX_LEGACY_INTR_CONFIG;
 
 static void netxen_nic_disable_int(struct netxen_adapter *adapter)
 {
 	u32 mask = 0x7ff;
 	int retries = 32;
-	int port = adapter->portnum;
 	int pci_fn = adapter->ahw.pci_func;
 
 	if (adapter->msi_mode != MSI_MODE_MULTIFUNC)
-		adapter->pci_write_normalize(adapter, sw_int_mask[port], 0);
+		adapter->pci_write_normalize(adapter,
+				adapter->crb_intr_mask, 0);
 
 	if (adapter->intr_scheme != -1 &&
 	    adapter->intr_scheme != INTR_SCHEME_PERPORT)
@@ -198,7 +193,6 @@ static void netxen_nic_disable_int(struct netxen_adapter *adapter)
 static void netxen_nic_enable_int(struct netxen_adapter *adapter)
 {
 	u32 mask;
-	int port = adapter->portnum;
 
 	DPRINTK(1, INFO, "Entered ISR Enable \n");
 
@@ -219,7 +213,7 @@ static void netxen_nic_enable_int(struct netxen_adapter *adapter)
 		adapter->pci_write_immediate(adapter, ISR_INT_MASK, mask);
 	}
 
-	adapter->pci_write_normalize(adapter, sw_int_mask[port], 0x1);
+	adapter->pci_write_normalize(adapter, adapter->crb_intr_mask, 0x1);
 
 	if (!NETXEN_IS_MSI_FAMILY(adapter)) {
 		mask = 0xbff;
@@ -710,10 +704,13 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->status   &= ~NETXEN_NETDEV_STATUS;
 	adapter->rx_csum = 1;
 	adapter->mc_enabled = 0;
-	if (NX_IS_REVISION_P3(revision_id))
+	if (NX_IS_REVISION_P3(revision_id)) {
 		adapter->max_mc_count = 38;
-	else
+		adapter->max_rds_rings = 2;
+	} else {
 		adapter->max_mc_count = 16;
+		adapter->max_rds_rings = 3;
+	}
 
 	netdev->open		   = netxen_nic_open;
 	netdev->stop		   = netxen_nic_close;
@@ -1081,7 +1078,7 @@ static int netxen_nic_open(struct net_device *netdev)
 		netxen_nic_update_cmd_consumer(adapter, 0);
 
 		for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-			for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++)
+			for (ring = 0; ring < adapter->max_rds_rings; ring++)
 				netxen_post_rx_buffers(adapter, ctx, ring);
 		}
 		if (NETXEN_IS_MSI_FAMILY(adapter))
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 09d0705..a637623 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -161,8 +161,6 @@ struct netxen_recv_crb {
 	u32 crb_sts_consumer;
 };
 
-extern struct netxen_recv_crb recv_crb_registers[];
-
 /*
  * Temperature control.
  */
-- 
1.5.4.3

