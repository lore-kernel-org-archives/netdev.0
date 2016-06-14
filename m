From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v4 3/7] vmxnet3: allow variable length transmit data ring buffer
Date: Tue, 14 Jun 2016 11:52:24 -0700
Message-ID: <1465930348-92164-4-git-send-email-skhare@vmware.com>
References: <1465930348-92164-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Sriram Rangarajan <rangarajans@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465930348-92164-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Sriram Rangarajan <rangarajans@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_defs.h    | 12 +++++++-
 drivers/net/vmxnet3/vmxnet3_drv.c     | 55 ++++++++++++++++++++++++++---------
 drivers/net/vmxnet3/vmxnet3_ethtool.c |  9 +++---
 drivers/net/vmxnet3/vmxnet3_int.h     |  7 ++++-
 4 files changed, 64 insertions(+), 19 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index a26a69d..701d989 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -92,6 +92,7 @@ enum {
 	VMXNET3_CMD_GET_DEV_EXTRA_INFO,
 	VMXNET3_CMD_GET_CONF_INTR,
 	VMXNET3_CMD_GET_RESERVED1,
+	VMXNET3_CMD_GET_TXDATA_DESC_SIZE
 };
 
 /*
@@ -377,6 +378,10 @@ union Vmxnet3_GenericDesc {
 #define VMXNET3_RING_SIZE_ALIGN 32
 #define VMXNET3_RING_SIZE_MASK  (VMXNET3_RING_SIZE_ALIGN - 1)
 
+/* Tx Data Ring buffer size must be a multiple of 64 */
+#define VMXNET3_TXDATA_DESC_SIZE_ALIGN 64
+#define VMXNET3_TXDATA_DESC_SIZE_MASK  (VMXNET3_TXDATA_DESC_SIZE_ALIGN - 1)
+
 /* Max ring size */
 #define VMXNET3_TX_RING_MAX_SIZE   4096
 #define VMXNET3_TC_RING_MAX_SIZE   4096
@@ -384,6 +389,9 @@ union Vmxnet3_GenericDesc {
 #define VMXNET3_RX_RING2_MAX_SIZE  4096
 #define VMXNET3_RC_RING_MAX_SIZE   8192
 
+#define VMXNET3_TXDATA_DESC_MIN_SIZE 128
+#define VMXNET3_TXDATA_DESC_MAX_SIZE 2048
+
 /* a list of reasons for queue stop */
 
 enum {
@@ -470,7 +478,9 @@ struct Vmxnet3_TxQueueConf {
 	__le32		compRingSize; /* # of comp desc */
 	__le32		ddLen;        /* size of driver data */
 	u8		intrIdx;
-	u8		_pad[7];
+	u8		_pad1[1];
+	__le16		txDataRingDescSize;
+	u8		_pad2[4];
 };
 
 
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 507c53d..4e42eb0 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -435,8 +435,8 @@ vmxnet3_tq_destroy(struct vmxnet3_tx_queue *tq,
 		tq->tx_ring.base = NULL;
 	}
 	if (tq->data_ring.base) {
-		dma_free_coherent(&adapter->pdev->dev, tq->data_ring.size *
-				  sizeof(struct Vmxnet3_TxDataDesc),
+		dma_free_coherent(&adapter->pdev->dev,
+				  tq->data_ring.size * tq->txdata_desc_size,
 				  tq->data_ring.base, tq->data_ring.basePA);
 		tq->data_ring.base = NULL;
 	}
@@ -478,8 +478,8 @@ vmxnet3_tq_init(struct vmxnet3_tx_queue *tq,
 	tq->tx_ring.next2fill = tq->tx_ring.next2comp = 0;
 	tq->tx_ring.gen = VMXNET3_INIT_GEN;
 
-	memset(tq->data_ring.base, 0, tq->data_ring.size *
-	       sizeof(struct Vmxnet3_TxDataDesc));
+	memset(tq->data_ring.base, 0,
+	       tq->data_ring.size * tq->txdata_desc_size);
 
 	/* reset the tx comp ring contents to 0 and reset comp ring states */
 	memset(tq->comp_ring.base, 0, tq->comp_ring.size *
@@ -514,10 +514,10 @@ vmxnet3_tq_create(struct vmxnet3_tx_queue *tq,
 	}
 
 	tq->data_ring.base = dma_alloc_coherent(&adapter->pdev->dev,
-			tq->data_ring.size * sizeof(struct Vmxnet3_TxDataDesc),
+			tq->data_ring.size * tq->txdata_desc_size,
 			&tq->data_ring.basePA, GFP_KERNEL);
 	if (!tq->data_ring.base) {
-		netdev_err(adapter->netdev, "failed to allocate data ring\n");
+		netdev_err(adapter->netdev, "failed to allocate tx data ring\n");
 		goto err;
 	}
 
@@ -689,7 +689,7 @@ vmxnet3_map_pkt(struct sk_buff *skb, struct vmxnet3_tx_ctx *ctx,
 	if (ctx->copy_size) {
 		ctx->sop_txd->txd.addr = cpu_to_le64(tq->data_ring.basePA +
 					tq->tx_ring.next2fill *
-					sizeof(struct Vmxnet3_TxDataDesc));
+					tq->txdata_desc_size);
 		ctx->sop_txd->dword[2] = cpu_to_le32(dw2 | ctx->copy_size);
 		ctx->sop_txd->dword[3] = 0;
 
@@ -873,8 +873,9 @@ vmxnet3_parse_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 			ctx->eth_ip_hdr_size = 0;
 			ctx->l4_hdr_size = 0;
 			/* copy as much as allowed */
-			ctx->copy_size = min((unsigned int)VMXNET3_HDR_COPY_SIZE
-					     , skb_headlen(skb));
+			ctx->copy_size = min_t(unsigned int,
+					       tq->txdata_desc_size,
+					       skb_headlen(skb));
 		}
 
 		if (skb->len <= VMXNET3_HDR_COPY_SIZE)
@@ -885,7 +886,7 @@ vmxnet3_parse_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 			goto err;
 	}
 
-	if (unlikely(ctx->copy_size > VMXNET3_HDR_COPY_SIZE)) {
+	if (unlikely(ctx->copy_size > tq->txdata_desc_size)) {
 		tq->stats.oversized_hdr++;
 		ctx->copy_size = 0;
 		return 0;
@@ -2336,6 +2337,7 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		tqc->ddPA           = cpu_to_le64(tq->buf_info_pa);
 		tqc->txRingSize     = cpu_to_le32(tq->tx_ring.size);
 		tqc->dataRingSize   = cpu_to_le32(tq->data_ring.size);
+		tqc->txDataRingDescSize = cpu_to_le32(tq->txdata_desc_size);
 		tqc->compRingSize   = cpu_to_le32(tq->comp_ring.size);
 		tqc->ddLen          = cpu_to_le32(
 					sizeof(struct vmxnet3_tx_buf_info) *
@@ -2689,7 +2691,8 @@ vmxnet3_adjust_rx_ring_size(struct vmxnet3_adapter *adapter)
 
 int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter, u32 tx_ring_size,
-		      u32 rx_ring_size, u32 rx_ring2_size)
+		      u32 rx_ring_size, u32 rx_ring2_size,
+		      u16 txdata_desc_size)
 {
 	int err = 0, i;
 
@@ -2698,6 +2701,7 @@ vmxnet3_create_queues(struct vmxnet3_adapter *adapter, u32 tx_ring_size,
 		tq->tx_ring.size   = tx_ring_size;
 		tq->data_ring.size = tx_ring_size;
 		tq->comp_ring.size = tx_ring_size;
+		tq->txdata_desc_size = txdata_desc_size;
 		tq->shared = &adapter->tqd_start[i].ctrl;
 		tq->stopped = true;
 		tq->adapter = adapter;
@@ -2754,9 +2758,34 @@ vmxnet3_open(struct net_device *netdev)
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		spin_lock_init(&adapter->tx_queue[i].tx_lock);
 
-	err = vmxnet3_create_queues(adapter, adapter->tx_ring_size,
+	if (VMXNET3_VERSION_GE_3(adapter)) {
+		unsigned long flags;
+		u16 txdata_desc_size;
+
+		spin_lock_irqsave(&adapter->cmd_lock, flags);
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				       VMXNET3_CMD_GET_TXDATA_DESC_SIZE);
+		txdata_desc_size = VMXNET3_READ_BAR1_REG(adapter,
+							 VMXNET3_REG_CMD);
+		spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+
+		if ((txdata_desc_size < VMXNET3_TXDATA_DESC_MIN_SIZE) ||
+		    (txdata_desc_size > VMXNET3_TXDATA_DESC_MAX_SIZE) ||
+		    (txdata_desc_size & VMXNET3_TXDATA_DESC_SIZE_MASK)) {
+			adapter->txdata_desc_size =
+				sizeof(struct Vmxnet3_TxDataDesc);
+		} else {
+			adapter->txdata_desc_size = txdata_desc_size;
+		}
+	} else {
+		adapter->txdata_desc_size = sizeof(struct Vmxnet3_TxDataDesc);
+	}
+
+	err = vmxnet3_create_queues(adapter,
+				    adapter->tx_ring_size,
 				    adapter->rx_ring_size,
-				    adapter->rx_ring2_size);
+				    adapter->rx_ring2_size,
+				    adapter->txdata_desc_size);
 	if (err)
 		goto queue_err;
 
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 163e99c..3b70cfe 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -396,8 +396,7 @@ vmxnet3_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
 		buf[j++] = VMXNET3_GET_ADDR_LO(tq->data_ring.basePA);
 		buf[j++] = VMXNET3_GET_ADDR_HI(tq->data_ring.basePA);
 		buf[j++] = tq->data_ring.size;
-		/* transmit data ring buffer size */
-		buf[j++] = VMXNET3_HDR_COPY_SIZE;
+		buf[j++] = tq->txdata_desc_size;
 
 		buf[j++] = VMXNET3_GET_ADDR_LO(tq->comp_ring.basePA);
 		buf[j++] = VMXNET3_GET_ADDR_HI(tq->comp_ring.basePA);
@@ -591,7 +590,8 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 		vmxnet3_rq_destroy_all(adapter);
 
 		err = vmxnet3_create_queues(adapter, new_tx_ring_size,
-			new_rx_ring_size, new_rx_ring2_size);
+					    new_rx_ring_size, new_rx_ring2_size,
+					    adapter->txdata_desc_size);
 
 		if (err) {
 			/* failed, most likely because of OOM, try default
@@ -604,7 +604,8 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 			err = vmxnet3_create_queues(adapter,
 						    new_tx_ring_size,
 						    new_rx_ring_size,
-						    new_rx_ring2_size);
+						    new_rx_ring2_size,
+						    adapter->txdata_desc_size);
 			if (err) {
 				netdev_err(netdev, "failed to create queues "
 					   "with default sizes. Closing it\n");
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index de068e9..94010de 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -241,6 +241,7 @@ struct vmxnet3_tx_queue {
 	int                             num_stop;  /* # of times the queue is
 						    * stopped */
 	int				qid;
+	u16				txdata_desc_size;
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
 
 enum vmxnet3_rx_buf_type {
@@ -363,6 +364,9 @@ struct vmxnet3_adapter {
 	u32 rx_ring_size;
 	u32 rx_ring2_size;
 
+	/* Size of buffer in the data ring */
+	u16 txdata_desc_size;
+
 	struct work_struct work;
 
 	unsigned long  state;    /* VMXNET3_STATE_BIT_xxx */
@@ -427,7 +431,8 @@ vmxnet3_set_features(struct net_device *netdev, netdev_features_t features);
 
 int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
-		      u32 tx_ring_size, u32 rx_ring_size, u32 rx_ring2_size);
+		      u32 tx_ring_size, u32 rx_ring_size, u32 rx_ring2_size,
+		      u16 txdata_desc_size);
 
 void vmxnet3_set_ethtool_ops(struct net_device *netdev);
 
-- 
2.8.2
