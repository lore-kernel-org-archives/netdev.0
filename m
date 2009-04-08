From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 09/11] netxen: enable rss for NX2031
Date: Wed,  8 Apr 2009 01:50:46 -0700
Message-ID: <1239180648-29842-10-git-send-email-dhananjay@netxen.com>
References: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net, Amit Kumar Salecha <amit@netxen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:49851 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762499AbZDHIu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 04:50:58 -0400
In-Reply-To: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable multiple rx rings for older NX2031 chip, firmware 3.4.336
or newer supports this feature.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h          |   27 +++++--
 drivers/net/netxen/netxen_nic_ctx.c      |  127 ++++++++++++++++++++++--------
 drivers/net/netxen/netxen_nic_main.c     |   21 ++++-
 drivers/net/netxen/netxen_nic_phan_reg.h |    5 +-
 4 files changed, 137 insertions(+), 43 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f13fd02..ebd6c2e 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -195,6 +195,8 @@
 #define MAX_JUMBO_RCV_DESCRIPTORS	1024
 #define MAX_LRO_RCV_DESCRIPTORS		8
 #define NETXEN_CTX_SIGNATURE	0xdee0
+#define NETXEN_CTX_SIGNATURE_V2	0x0002dee0
+#define NETXEN_CTX_RESET	0xbad0
 #define NETXEN_RCV_PRODUCER(ringid)	(ringid)
 
 #define PHAN_PEG_RCV_INITIALIZED	0xff01
@@ -234,12 +236,19 @@ typedef u32 netxen_ctx_msg;
 #define netxen_set_msg_opcode(config_word, val)	\
 	((config_word) &= ~(0xf<<28), (config_word) |= (val & 0xf) << 28)
 
-struct netxen_rcv_context {
-	__le64 rcv_ring_addr;
-	__le32 rcv_ring_size;
+struct netxen_rcv_ring {
+	__le64 addr;
+	__le32 size;
 	__le32 rsrvd;
 };
 
+struct netxen_sts_ring {
+	__le64 addr;
+	__le32 size;
+	__le16 msi_index;
+	__le16 rsvd;
+} ;
+
 struct netxen_ring_ctx {
 
 	/* one command ring */
@@ -249,13 +258,18 @@ struct netxen_ring_ctx {
 	__le32 rsrvd;
 
 	/* three receive rings */
-	struct netxen_rcv_context rcv_ctx[3];
+	struct netxen_rcv_ring rcv_rings[NUM_RCV_DESC_RINGS];
 
-	/* one status ring */
 	__le64 sts_ring_addr;
 	__le32 sts_ring_size;
 
 	__le32 ctx_id;
+
+	__le64 rsrvd_2[3];
+	__le32 sts_ring_count;
+	__le32 rsrvd_3;
+	struct netxen_sts_ring sts_rings[NUM_STS_DESC_RINGS];
+
 } __attribute__ ((aligned(64)));
 
 /*
@@ -1219,7 +1233,8 @@ struct netxen_adapter {
 
 	u8 mc_enabled;
 	u8 max_mc_count;
-	u16 resv2;
+	u8 rss_supported;
+	u8 resv2;
 	u32 resv3;
 
 	u8 has_link_events;
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 32f4839..fd82adf 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -441,7 +441,19 @@ static struct netxen_recv_crb recv_crb_registers[] = {
 			NETXEN_NIC_REG(0x120)
 		},
 		/* crb_sts_consumer: */
-		NETXEN_NIC_REG(0x138),
+		{
+			NETXEN_NIC_REG(0x138),
+			NETXEN_NIC_REG_2(0x000),
+			NETXEN_NIC_REG_2(0x004),
+			NETXEN_NIC_REG_2(0x008),
+		},
+		/* sw_int_mask */
+		{
+			CRB_SW_INT_MASK_0,
+			NETXEN_NIC_REG_2(0x044),
+			NETXEN_NIC_REG_2(0x048),
+			NETXEN_NIC_REG_2(0x04c),
+		},
 	},
 	/* Instance 1 */
 	{
@@ -454,7 +466,19 @@ static struct netxen_recv_crb recv_crb_registers[] = {
 			NETXEN_NIC_REG(0x164)
 		},
 		/* crb_sts_consumer: */
-		NETXEN_NIC_REG(0x17c),
+		{
+			NETXEN_NIC_REG(0x17c),
+			NETXEN_NIC_REG_2(0x020),
+			NETXEN_NIC_REG_2(0x024),
+			NETXEN_NIC_REG_2(0x028),
+		},
+		/* sw_int_mask */
+		{
+			CRB_SW_INT_MASK_1,
+			NETXEN_NIC_REG_2(0x064),
+			NETXEN_NIC_REG_2(0x068),
+			NETXEN_NIC_REG_2(0x06c),
+		},
 	},
 	/* Instance 2 */
 	{
@@ -467,7 +491,19 @@ static struct netxen_recv_crb recv_crb_registers[] = {
 			NETXEN_NIC_REG(0x208)
 		},
 		/* crb_sts_consumer: */
-		NETXEN_NIC_REG(0x220),
+		{
+			NETXEN_NIC_REG(0x220),
+			NETXEN_NIC_REG_2(0x03c),
+			NETXEN_NIC_REG_2(0x03c),
+			NETXEN_NIC_REG_2(0x03c),
+		},
+		/* sw_int_mask */
+		{
+			CRB_SW_INT_MASK_2,
+			NETXEN_NIC_REG_2(0x03c),
+			NETXEN_NIC_REG_2(0x03c),
+			NETXEN_NIC_REG_2(0x03c),
+		},
 	},
 	/* Instance 3 */
 	{
@@ -480,7 +516,19 @@ static struct netxen_recv_crb recv_crb_registers[] = {
 			NETXEN_NIC_REG(0x24c)
 		},
 		/* crb_sts_consumer: */
-		NETXEN_NIC_REG(0x264),
+		{
+			NETXEN_NIC_REG(0x264),
+			NETXEN_NIC_REG_2(0x03c),
+			NETXEN_NIC_REG_2(0x03c),
+			NETXEN_NIC_REG_2(0x03c),
+		},
+		/* sw_int_mask */
+		{
+			CRB_SW_INT_MASK_3,
+			NETXEN_NIC_REG_2(0x03c),
+			NETXEN_NIC_REG_2(0x03c),
+			NETXEN_NIC_REG_2(0x03c),
+		},
 	},
 };
 
@@ -492,40 +540,50 @@ netxen_init_old_ctx(struct netxen_adapter *adapter)
 	struct nx_host_sds_ring *sds_ring;
 	struct nx_host_tx_ring *tx_ring;
 	int ring;
-	int func_id = adapter->portnum;
+	int port = adapter->portnum;
+	struct netxen_ring_ctx *hwctx = adapter->ctx_desc;
+	u32 signature;
 
 	tx_ring = &adapter->tx_ring;
-	adapter->ctx_desc->cmd_ring_addr = cpu_to_le64(tx_ring->phys_addr);
-	adapter->ctx_desc->cmd_ring_size = cpu_to_le32(tx_ring->num_desc);
+	hwctx->cmd_ring_addr = cpu_to_le64(tx_ring->phys_addr);
+	hwctx->cmd_ring_size = cpu_to_le32(tx_ring->num_desc);
 
 	recv_ctx = &adapter->recv_ctx;
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 
-		adapter->ctx_desc->rcv_ctx[ring].rcv_ring_addr =
+		hwctx->rcv_rings[ring].addr =
 			cpu_to_le64(rds_ring->phys_addr);
-		adapter->ctx_desc->rcv_ctx[ring].rcv_ring_size =
+		hwctx->rcv_rings[ring].size =
 			cpu_to_le32(rds_ring->num_desc);
 	}
-	sds_ring = &recv_ctx->sds_rings[0];
-	adapter->ctx_desc->sts_ring_addr = cpu_to_le64(sds_ring->phys_addr);
-	adapter->ctx_desc->sts_ring_size = cpu_to_le32(sds_ring->num_desc);
 
-	NXWR32(adapter, CRB_CTX_ADDR_REG_LO(func_id),
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+
+		if (ring == 0) {
+			hwctx->sts_ring_addr = cpu_to_le64(sds_ring->phys_addr);
+			hwctx->sts_ring_size = cpu_to_le32(sds_ring->num_desc);
+		}
+		hwctx->sts_rings[ring].addr = cpu_to_le64(sds_ring->phys_addr);
+		hwctx->sts_rings[ring].size = cpu_to_le32(sds_ring->num_desc);
+		hwctx->sts_rings[ring].msi_index = cpu_to_le16(ring);
+	}
+	hwctx->sts_ring_count = cpu_to_le32(adapter->max_sds_rings);
+
+	signature = (adapter->max_sds_rings > 1) ?
+		NETXEN_CTX_SIGNATURE_V2 : NETXEN_CTX_SIGNATURE;
+
+	NXWR32(adapter, CRB_CTX_ADDR_REG_LO(port),
 			lower32(adapter->ctx_desc_phys_addr));
-	NXWR32(adapter, CRB_CTX_ADDR_REG_HI(func_id),
+	NXWR32(adapter, CRB_CTX_ADDR_REG_HI(port),
 			upper32(adapter->ctx_desc_phys_addr));
-	NXWR32(adapter, CRB_CTX_SIGNATURE_REG(func_id),
-			NETXEN_CTX_SIGNATURE | func_id);
+	NXWR32(adapter, CRB_CTX_SIGNATURE_REG(port),
+			signature | port);
 	return 0;
 }
 
-static uint32_t sw_int_mask[4] = {
-	CRB_SW_INT_MASK_0, CRB_SW_INT_MASK_1,
-	CRB_SW_INT_MASK_2, CRB_SW_INT_MASK_3
-};
-
 int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 {
 	void *addr;
@@ -538,6 +596,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 
 	struct pci_dev *pdev = adapter->pdev;
 	struct net_device *netdev = adapter->netdev;
+	int port = adapter->portnum;
 
 	addr = pci_alloc_consistent(pdev,
 			sizeof(struct netxen_ring_ctx) + sizeof(uint32_t),
@@ -549,7 +608,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	}
 	memset(addr, 0, sizeof(struct netxen_ring_ctx));
 	adapter->ctx_desc = (struct netxen_ring_ctx *)addr;
-	adapter->ctx_desc->ctx_id = cpu_to_le32(adapter->portnum);
+	adapter->ctx_desc->ctx_id = cpu_to_le32(port);
 	adapter->ctx_desc->cmd_consumer_offset =
 		cpu_to_le64(adapter->ctx_desc_phys_addr +
 			sizeof(struct netxen_ring_ctx));
@@ -586,8 +645,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 
 		if (adapter->fw_major < 4)
 			rds_ring->crb_rcv_producer =
-				recv_crb_registers[adapter->portnum].
-				crb_rcv_producer[ring];
+				recv_crb_registers[port].crb_rcv_producer[ring];
 	}
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
@@ -604,6 +662,12 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 			goto err_out_free;
 		}
 		sds_ring->desc_head = (struct status_desc *)addr;
+
+		sds_ring->crb_sts_consumer =
+			recv_crb_registers[port].crb_sts_consumer[ring];
+
+		sds_ring->crb_intr_mask =
+			recv_crb_registers[port].sw_int_mask[ring];
 	}
 
 
@@ -615,19 +679,11 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		if (err)
 			goto err_out_free;
 	} else {
-		sds_ring = &recv_ctx->sds_rings[0];
-		sds_ring->crb_sts_consumer =
-			recv_crb_registers[adapter->portnum].crb_sts_consumer;
-
-		recv_ctx->sds_rings[0].crb_intr_mask =
-				sw_int_mask[adapter->portnum];
-
 		err = netxen_init_old_ctx(adapter);
 		if (err) {
 			netxen_free_hw_resources(adapter);
 			return err;
 		}
-
 	}
 
 	return 0;
@@ -645,9 +701,16 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 	struct nx_host_tx_ring *tx_ring;
 	int ring;
 
+	int port = adapter->portnum;
+
 	if (adapter->fw_major >= 4) {
 		nx_fw_cmd_destroy_tx_ctx(adapter);
 		nx_fw_cmd_destroy_rx_ctx(adapter);
+	} else {
+		netxen_api_lock(adapter);
+		NXWR32(adapter, CRB_CTX_SIGNATURE_REG(port),
+				NETXEN_CTX_RESET | port);
+		netxen_api_unlock(adapter);
 	}
 
 	if (adapter->ctx_desc != NULL) {
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 1c85b74..56c16c7 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -175,7 +175,8 @@ netxen_napi_add(struct netxen_adapter *adapter, struct net_device *netdev)
 	struct nx_host_sds_ring *sds_ring;
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
-	if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
+	if ((adapter->flags & NETXEN_NIC_MSIX_ENABLED) &&
+			adapter->rss_supported)
 		adapter->max_sds_rings = (num_online_cpus() >= 4) ? 4 : 2;
 	else
 		adapter->max_sds_rings = 1;
@@ -288,10 +289,22 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 	else if (adapter->ahw.port_type == NETXEN_NIC_GBE)
 		adapter->num_rxd = MAX_RCV_DESCRIPTORS_1G;
 
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+	adapter->msix_supported = 0;
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		adapter->msix_supported = !!use_msi_x;
-	else
-		adapter->msix_supported = 0;
+		adapter->rss_supported = !!use_msi_x;
+	} else if (adapter->fw_version >= NETXEN_VERSION_CODE(3, 4, 336)) {
+		switch (adapter->ahw.board_type) {
+		case NETXEN_BRDTYPE_P2_SB31_10G:
+		case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
+		case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
+			adapter->msix_supported = !!use_msi_x;
+			adapter->rss_supported = !!use_msi_x;
+			break;
+		default:
+			break;
+		}
+	}
 
 	adapter->num_txd = MAX_CMD_DESCRIPTORS_HOST;
 	adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS;
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index ecd622e..845dcf4 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -36,6 +36,8 @@
  */
 #define NIC_CRB_BASE               NETXEN_CAM_RAM(0x200)
 #define NETXEN_NIC_REG(X)             (NIC_CRB_BASE+(X))
+#define NIC_CRB_BASE_2             NETXEN_CAM_RAM(0x700)
+#define NETXEN_NIC_REG_2(X)         (NIC_CRB_BASE_2+(X))
 
 #define CRB_PHAN_CNTRL_LO_OFFSET    NETXEN_NIC_REG(0x00)
 #define CRB_PHAN_CNTRL_HI_OFFSET    NETXEN_NIC_REG(0x04)
@@ -160,7 +162,8 @@
 
 struct netxen_recv_crb {
 	u32 crb_rcv_producer[NUM_RCV_DESC_RINGS];
-	u32 crb_sts_consumer;
+	u32 crb_sts_consumer[NUM_STS_DESC_RINGS];
+	u32 sw_int_mask[NUM_STS_DESC_RINGS];
 };
 
 /*
-- 
1.6.0.2

