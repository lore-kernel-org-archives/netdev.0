From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v2 4/7] Driver: Vmxnet3: Add Receive Data Ring support
Date: Thu, 19 May 2016 23:53:09 -0700
Message-ID: <1463727192-4543-5-git-send-email-skhare@vmware.com>
References: <1463727192-4543-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463727192-4543-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Receive Data Ring buffer length is configurable via ethtool -G ethX rx-mini

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_defs.h    |  14 +++-
 drivers/net/vmxnet3/vmxnet3_drv.c     | 153 +++++++++++++++++++++++++++-------
 drivers/net/vmxnet3/vmxnet3_ethtool.c |  48 ++++++++---
 drivers/net/vmxnet3/vmxnet3_int.h     |  23 ++++-
 4 files changed, 193 insertions(+), 45 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index 701d989..f3b31c2 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -174,6 +174,8 @@ struct Vmxnet3_TxDataDesc {
 	u8		data[VMXNET3_HDR_COPY_SIZE];
 };
 
+typedef u8 Vmxnet3_RxDataDesc;
+
 #define VMXNET3_TCD_GEN_SHIFT	31
 #define VMXNET3_TCD_GEN_SIZE	1
 #define VMXNET3_TCD_TXIDX_SHIFT	0
@@ -382,6 +384,10 @@ union Vmxnet3_GenericDesc {
 #define VMXNET3_TXDATA_DESC_SIZE_ALIGN 64
 #define VMXNET3_TXDATA_DESC_SIZE_MASK  (VMXNET3_TXDATA_DESC_SIZE_ALIGN - 1)
 
+/* Rx Data Ring buffer size must be a multiple of 64 */
+#define VMXNET3_RXDATA_DESC_SIZE_ALIGN 64
+#define VMXNET3_RXDATA_DESC_SIZE_MASK  (VMXNET3_RXDATA_DESC_SIZE_ALIGN - 1)
+
 /* Max ring size */
 #define VMXNET3_TX_RING_MAX_SIZE   4096
 #define VMXNET3_TC_RING_MAX_SIZE   4096
@@ -392,6 +398,8 @@ union Vmxnet3_GenericDesc {
 #define VMXNET3_TXDATA_DESC_MIN_SIZE 128
 #define VMXNET3_TXDATA_DESC_MAX_SIZE 2048
 
+#define VMXNET3_RXDATA_DESC_MAX_SIZE 2048
+
 /* a list of reasons for queue stop */
 
 enum {
@@ -488,12 +496,14 @@ struct Vmxnet3_RxQueueConf {
 	__le64		rxRingBasePA[2];
 	__le64		compRingBasePA;
 	__le64		ddPA;            /* driver data */
-	__le64		reserved;
+	__le64		rxDataRingBasePA;
 	__le32		rxRingSize[2];   /* # of rx desc */
 	__le32		compRingSize;    /* # of rx comp desc */
 	__le32		ddLen;           /* size of driver data */
 	u8		intrIdx;
-	u8		_pad[7];
+	u8		_pad1[1];
+	__le16		rxDataRingDescSize;  /* size of rx data ring buffer */
+	u8		_pad2[4];
 };
 
 
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 58632b1..a6dc7c7 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1284,9 +1284,10 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			 */
 			break;
 		}
-		BUG_ON(rcd->rqID != rq->qid && rcd->rqID != rq->qid2);
+		BUG_ON(rcd->rqID != rq->qid && rcd->rqID != rq->qid2 &&
+		       rcd->rqID != rq->dataRingQid);
 		idx = rcd->rxdIdx;
-		ring_idx = rcd->rqID < adapter->num_rx_queues ? 0 : 1;
+		ring_idx = VMXNET3_GET_RING_IDX(adapter, rcd->rqID);
 		ring = rq->rx_ring + ring_idx;
 		vmxnet3_getRxDesc(rxd, &rq->rx_ring[ring_idx].base[idx].rxd,
 				  &rxCmdDesc);
@@ -1301,8 +1302,12 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 		}
 
 		if (rcd->sop) { /* first buf of the pkt */
+			bool rxDataRingUsed;
+			u16 len;
+
 			BUG_ON(rxd->btype != VMXNET3_RXD_BTYPE_HEAD ||
-			       rcd->rqID != rq->qid);
+			       (rcd->rqID != rq->qid &&
+				rcd->rqID != rq->dataRingQid));
 
 			BUG_ON(rbi->buf_type != VMXNET3_RX_BUF_SKB);
 			BUG_ON(ctx->skb != NULL || rbi->skb == NULL);
@@ -1318,8 +1323,12 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 
 			skip_page_frags = false;
 			ctx->skb = rbi->skb;
+
+			rxDataRingUsed =
+				VMXNET3_RX_DATA_RING(adapter, rcd->rqID);
+			len = rxDataRingUsed ? rcd->len : rbi->len;
 			new_skb = netdev_alloc_skb_ip_align(adapter->netdev,
-							    rbi->len);
+							    len);
 			if (new_skb == NULL) {
 				/* Skb allocation failed, do not handover this
 				 * skb to stack. Reuse it. Drop the existing pkt
@@ -1330,25 +1339,48 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 				skip_page_frags = true;
 				goto rcd_done;
 			}
-			new_dma_addr = dma_map_single(&adapter->pdev->dev,
-						      new_skb->data, rbi->len,
-						      PCI_DMA_FROMDEVICE);
-			if (dma_mapping_error(&adapter->pdev->dev,
-					      new_dma_addr)) {
-				dev_kfree_skb(new_skb);
-				/* Skb allocation failed, do not handover this
-				 * skb to stack. Reuse it. Drop the existing pkt
-				 */
-				rq->stats.rx_buf_alloc_failure++;
-				ctx->skb = NULL;
-				rq->stats.drop_total++;
-				skip_page_frags = true;
-				goto rcd_done;
-			}
 
-			dma_unmap_single(&adapter->pdev->dev, rbi->dma_addr,
-					 rbi->len,
-					 PCI_DMA_FROMDEVICE);
+			if (rxDataRingUsed) {
+				size_t sz;
+
+				BUG_ON(rcd->len > rq->data_ring.desc_size);
+
+				ctx->skb = new_skb;
+				sz = rcd->rxdIdx * rq->data_ring.desc_size;
+				memcpy(new_skb->data,
+				       &rq->data_ring.base[sz], rcd->len);
+			} else {
+				ctx->skb = rbi->skb;
+
+				new_dma_addr =
+					dma_map_single(&adapter->pdev->dev,
+						       new_skb->data, rbi->len,
+						       PCI_DMA_FROMDEVICE);
+				if (dma_mapping_error(&adapter->pdev->dev,
+						      new_dma_addr)) {
+					dev_kfree_skb(new_skb);
+					/* Skb allocation failed, do not
+					 * handover this skb to stack. Reuse
+					 * it. Drop the existing pkt.
+					 */
+					rq->stats.rx_buf_alloc_failure++;
+					ctx->skb = NULL;
+					rq->stats.drop_total++;
+					skip_page_frags = true;
+					goto rcd_done;
+				}
+
+				dma_unmap_single(&adapter->pdev->dev,
+						 rbi->dma_addr,
+						 rbi->len,
+						 PCI_DMA_FROMDEVICE);
+
+				/* Immediate refill */
+				rbi->skb = new_skb;
+				rbi->dma_addr = new_dma_addr;
+				rxd->addr = cpu_to_le64(rbi->dma_addr);
+				rxd->len = rbi->len;
+			}
 
 #ifdef VMXNET3_RSS
 			if (rcd->rssType != VMXNET3_RCD_RSS_TYPE_NONE &&
@@ -1359,11 +1391,6 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 #endif
 			skb_put(ctx->skb, rcd->len);
 
-			/* Immediate refill */
-			rbi->skb = new_skb;
-			rbi->dma_addr = new_dma_addr;
-			rxd->addr = cpu_to_le64(rbi->dma_addr);
-			rxd->len = rbi->len;
 			if (VMXNET3_VERSION_GE_2(adapter) &&
 			    rcd->type == VMXNET3_CDTYPE_RXCOMP_LRO) {
 				struct Vmxnet3_RxCompDescExt *rcdlro;
@@ -1590,6 +1617,13 @@ static void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
 		rq->buf_info[i] = NULL;
 	}
 
+	if (rq->data_ring.base) {
+		dma_free_coherent(&adapter->pdev->dev,
+				  rq->rx_ring[0].size * rq->data_ring.desc_size,
+				  rq->data_ring.base, rq->data_ring.basePA);
+		rq->data_ring.base = NULL;
+	}
+
 	if (rq->comp_ring.base) {
 		dma_free_coherent(&adapter->pdev->dev, rq->comp_ring.size
 				  * sizeof(struct Vmxnet3_RxCompDesc),
@@ -1605,6 +1639,25 @@ static void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
 	}
 }
 
+void
+vmxnet3_rq_destroy_all_rxdataring(struct vmxnet3_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct vmxnet3_rx_queue *rq = &adapter->rx_queue[i];
+
+		if (rq->data_ring.base) {
+			dma_free_coherent(&adapter->pdev->dev,
+					  (rq->rx_ring[0].size *
+					  rq->data_ring.desc_size),
+					  rq->data_ring.base,
+					  rq->data_ring.basePA);
+			rq->data_ring.base = NULL;
+			rq->data_ring.desc_size = 0;
+		}
+	}
+}
 
 static int
 vmxnet3_rq_init(struct vmxnet3_rx_queue *rq,
@@ -1698,6 +1751,22 @@ vmxnet3_rq_create(struct vmxnet3_rx_queue *rq, struct vmxnet3_adapter *adapter)
 		}
 	}
 
+	if ((adapter->rxdataring_enabled) && (rq->data_ring.desc_size != 0)) {
+		sz = rq->rx_ring[0].size * rq->data_ring.desc_size;
+		rq->data_ring.base =
+			dma_alloc_coherent(&adapter->pdev->dev, sz,
+					   &rq->data_ring.basePA,
+					   GFP_KERNEL);
+		if (!rq->data_ring.base) {
+			netdev_err(adapter->netdev,
+				   "rx data ring will be disabled\n");
+			adapter->rxdataring_enabled = false;
+		}
+	} else {
+		rq->data_ring.base = NULL;
+		rq->data_ring.desc_size = 0;
+	}
+
 	sz = rq->comp_ring.size * sizeof(struct Vmxnet3_RxCompDesc);
 	rq->comp_ring.base = dma_alloc_coherent(&adapter->pdev->dev, sz,
 						&rq->comp_ring.basePA,
@@ -1730,6 +1799,8 @@ vmxnet3_rq_create_all(struct vmxnet3_adapter *adapter)
 {
 	int i, err = 0;
 
+	adapter->rxdataring_enabled = VMXNET3_VERSION_GE_3(adapter);
+
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		err = vmxnet3_rq_create(&adapter->rx_queue[i], adapter);
 		if (unlikely(err)) {
@@ -1739,6 +1810,10 @@ vmxnet3_rq_create_all(struct vmxnet3_adapter *adapter)
 			goto err_out;
 		}
 	}
+
+	if (!adapter->rxdataring_enabled)
+		vmxnet3_rq_destroy_all_rxdataring(adapter);
+
 	return err;
 err_out:
 	vmxnet3_rq_destroy_all(adapter);
@@ -2046,10 +2121,9 @@ vmxnet3_request_irqs(struct vmxnet3_adapter *adapter)
 			struct vmxnet3_rx_queue *rq = &adapter->rx_queue[i];
 			rq->qid = i;
 			rq->qid2 = i + adapter->num_rx_queues;
+			rq->dataRingQid = i + 2 * adapter->num_rx_queues;
 		}
 
-
-
 		/* init our intr settings */
 		for (i = 0; i < intr->num_intrs; i++)
 			intr->mod_levels[i] = UPT1_IML_ADAPTIVE;
@@ -2362,6 +2436,12 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 					(rqc->rxRingSize[0] +
 					 rqc->rxRingSize[1]));
 		rqc->intrIdx         = rq->comp_ring.intr_idx;
+		if (VMXNET3_VERSION_GE_3(adapter)) {
+			rqc->rxDataRingBasePA =
+				cpu_to_le64(rq->data_ring.basePA);
+			rqc->rxDataRingDescSize =
+				cpu_to_le16(rq->data_ring.desc_size);
+		}
 	}
 
 #ifdef VMXNET3_RSS
@@ -2692,7 +2772,7 @@ vmxnet3_adjust_rx_ring_size(struct vmxnet3_adapter *adapter)
 int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter, u32 tx_ring_size,
 		      u32 rx_ring_size, u32 rx_ring2_size,
-		      u16 txdata_desc_size)
+		      u16 txdata_desc_size, u16 rxdata_desc_size)
 {
 	int err = 0, i;
 
@@ -2718,12 +2798,15 @@ vmxnet3_create_queues(struct vmxnet3_adapter *adapter, u32 tx_ring_size,
 	adapter->rx_queue[0].rx_ring[0].size = rx_ring_size;
 	adapter->rx_queue[0].rx_ring[1].size = rx_ring2_size;
 	vmxnet3_adjust_rx_ring_size(adapter);
+
+	adapter->rxdataring_enabled = VMXNET3_VERSION_GE_3(adapter);
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct vmxnet3_rx_queue *rq = &adapter->rx_queue[i];
 		/* qid and qid2 for rx queues will be assigned later when num
 		 * of rx queues is finalized after allocating intrs */
 		rq->shared = &adapter->rqd_start[i].ctrl;
 		rq->adapter = adapter;
+		rq->data_ring.desc_size = rxdata_desc_size;
 		err = vmxnet3_rq_create(rq, adapter);
 		if (err) {
 			if (i == 0) {
@@ -2741,6 +2824,10 @@ vmxnet3_create_queues(struct vmxnet3_adapter *adapter, u32 tx_ring_size,
 			}
 		}
 	}
+
+	if (!adapter->rxdataring_enabled)
+		vmxnet3_rq_destroy_all_rxdataring(adapter);
+
 	return err;
 queue_err:
 	vmxnet3_tq_destroy_all(adapter);
@@ -2785,7 +2872,8 @@ vmxnet3_open(struct net_device *netdev)
 				    adapter->tx_ring_size,
 				    adapter->rx_ring_size,
 				    adapter->rx_ring2_size,
-				    adapter->txdata_desc_size);
+				    adapter->txdata_desc_size,
+				    adapter->rxdata_desc_size);
 	if (err)
 		goto queue_err;
 
@@ -3260,6 +3348,9 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	vmxnet3_declare_features(adapter, dma64);
 
+	adapter->rxdata_desc_size = VMXNET3_VERSION_GE_3(adapter) ?
+		VMXNET3_DEF_RXDATA_DESC_SIZE : 0;
+
 	if (adapter->num_tx_queues == adapter->num_rx_queues)
 		adapter->share_intr = VMXNET3_INTR_BUDDYSHARE;
 	else
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 3b70cfe..38f7c79 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -430,11 +430,10 @@ vmxnet3_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
 		buf[j++] = rq->rx_ring[1].next2comp;
 		buf[j++] = rq->rx_ring[1].gen;
 
-		/* receive data ring */
-		buf[j++] = 0;
-		buf[j++] = 0;
-		buf[j++] = 0;
-		buf[j++] = 0;
+		buf[j++] = VMXNET3_GET_ADDR_LO(rq->data_ring.basePA);
+		buf[j++] = VMXNET3_GET_ADDR_HI(rq->data_ring.basePA);
+		buf[j++] = rq->rx_ring[0].size;
+		buf[j++] = rq->data_ring.desc_size;
 
 		buf[j++] = VMXNET3_GET_ADDR_LO(rq->comp_ring.basePA);
 		buf[j++] = VMXNET3_GET_ADDR_HI(rq->comp_ring.basePA);
@@ -503,12 +502,14 @@ vmxnet3_get_ringparam(struct net_device *netdev,
 
 	param->rx_max_pending = VMXNET3_RX_RING_MAX_SIZE;
 	param->tx_max_pending = VMXNET3_TX_RING_MAX_SIZE;
-	param->rx_mini_max_pending = 0;
+	param->rx_mini_max_pending = VMXNET3_VERSION_GE_3(adapter) ?
+		VMXNET3_RXDATA_DESC_MAX_SIZE : 0;
 	param->rx_jumbo_max_pending = VMXNET3_RX_RING2_MAX_SIZE;
 
 	param->rx_pending = adapter->rx_ring_size;
 	param->tx_pending = adapter->tx_ring_size;
-	param->rx_mini_pending = 0;
+	param->rx_mini_pending = VMXNET3_VERSION_GE_3(adapter) ?
+		adapter->rxdata_desc_size : 0;
 	param->rx_jumbo_pending = adapter->rx_ring2_size;
 }
 
@@ -519,6 +520,7 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	u32 new_tx_ring_size, new_rx_ring_size, new_rx_ring2_size;
+	u16 new_rxdata_desc_size;
 	u32 sz;
 	int err = 0;
 
@@ -541,6 +543,15 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 		return -EOPNOTSUPP;
 	}
 
+	if (VMXNET3_VERSION_GE_3(adapter)) {
+		if (param->rx_mini_pending < 0 ||
+		    param->rx_mini_pending > VMXNET3_RXDATA_DESC_MAX_SIZE) {
+			return -EINVAL;
+		}
+	} else if (param->rx_mini_pending != 0) {
+		return -EINVAL;
+	}
+
 	/* round it up to a multiple of VMXNET3_RING_SIZE_ALIGN */
 	new_tx_ring_size = (param->tx_pending + VMXNET3_RING_SIZE_MASK) &
 							~VMXNET3_RING_SIZE_MASK;
@@ -567,9 +578,19 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 	new_rx_ring2_size = min_t(u32, new_rx_ring2_size,
 				  VMXNET3_RX_RING2_MAX_SIZE);
 
+	/* rx data ring buffer size has to be a multiple of
+	 * VMXNET3_RXDATA_DESC_SIZE_ALIGN
+	 */
+	new_rxdata_desc_size =
+		(param->rx_mini_pending + VMXNET3_RXDATA_DESC_SIZE_MASK) &
+		~VMXNET3_RXDATA_DESC_SIZE_MASK;
+	new_rxdata_desc_size = min_t(u16, new_rxdata_desc_size,
+				     VMXNET3_RXDATA_DESC_MAX_SIZE);
+
 	if (new_tx_ring_size == adapter->tx_ring_size &&
 	    new_rx_ring_size == adapter->rx_ring_size &&
-	    new_rx_ring2_size == adapter->rx_ring2_size) {
+	    new_rx_ring2_size == adapter->rx_ring2_size &&
+	    new_rxdata_desc_size == adapter->rxdata_desc_size) {
 		return 0;
 	}
 
@@ -591,8 +612,8 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 
 		err = vmxnet3_create_queues(adapter, new_tx_ring_size,
 					    new_rx_ring_size, new_rx_ring2_size,
-					    adapter->txdata_desc_size);
-
+					    adapter->txdata_desc_size,
+					    new_rxdata_desc_size);
 		if (err) {
 			/* failed, most likely because of OOM, try default
 			 * size */
@@ -601,11 +622,15 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 			new_rx_ring_size = VMXNET3_DEF_RX_RING_SIZE;
 			new_rx_ring2_size = VMXNET3_DEF_RX_RING2_SIZE;
 			new_tx_ring_size = VMXNET3_DEF_TX_RING_SIZE;
+			new_rxdata_desc_size = VMXNET3_VERSION_GE_3(adapter) ?
+				VMXNET3_DEF_RXDATA_DESC_SIZE : 0;
+
 			err = vmxnet3_create_queues(adapter,
 						    new_tx_ring_size,
 						    new_rx_ring_size,
 						    new_rx_ring2_size,
-						    adapter->txdata_desc_size);
+						    adapter->txdata_desc_size,
+						    new_rxdata_desc_size);
 			if (err) {
 				netdev_err(netdev, "failed to create queues "
 					   "with default sizes. Closing it\n");
@@ -621,6 +646,7 @@ vmxnet3_set_ringparam(struct net_device *netdev,
 	adapter->tx_ring_size = new_tx_ring_size;
 	adapter->rx_ring_size = new_rx_ring_size;
 	adapter->rx_ring2_size = new_rx_ring2_size;
+	adapter->rxdata_desc_size = new_rxdata_desc_size;
 
 out:
 	clear_bit(VMXNET3_STATE_BIT_RESETTING, &adapter->state);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 6da7797..62d7d45 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -272,15 +272,23 @@ struct vmxnet3_rq_driver_stats {
 	u64 rx_buf_alloc_failure;
 };
 
+struct vmxnet3_rx_data_ring {
+	Vmxnet3_RxDataDesc *base;
+	dma_addr_t basePA;
+	u16 desc_size;
+};
+
 struct vmxnet3_rx_queue {
 	char			name[IFNAMSIZ + 8]; /* To identify interrupt */
 	struct vmxnet3_adapter	  *adapter;
 	struct napi_struct        napi;
 	struct vmxnet3_cmd_ring   rx_ring[2];
+	struct vmxnet3_rx_data_ring data_ring;
 	struct vmxnet3_comp_ring  comp_ring;
 	struct vmxnet3_rx_ctx     rx_ctx;
 	u32 qid;            /* rqID in RCD for buffer from 1st ring */
 	u32 qid2;           /* rqID in RCD for buffer from 2nd ring */
+	u32 dataRingQid;    /* rqID in RCD for buffer from data ring */
 	struct vmxnet3_rx_buf_info     *buf_info[2];
 	dma_addr_t                      buf_info_pa;
 	struct Vmxnet3_RxQueueCtrl            *shared;
@@ -366,6 +374,9 @@ struct vmxnet3_adapter {
 
 	/* Size of buffer in the data ring */
 	u16 txdata_desc_size;
+	u16 rxdata_desc_size;
+
+	bool rxdataring_enabled;
 
 	struct work_struct work;
 
@@ -405,9 +416,19 @@ struct vmxnet3_adapter {
 #define VMXNET3_DEF_RX_RING_SIZE    256
 #define VMXNET3_DEF_RX_RING2_SIZE   128
 
+#define VMXNET3_DEF_RXDATA_DESC_SIZE 128
+
 #define VMXNET3_MAX_ETH_HDR_SIZE    22
 #define VMXNET3_MAX_SKB_BUF_SIZE    (3*1024)
 
+#define VMXNET3_GET_RING_IDX(adapter, rqID)		\
+	((rqID >= adapter->num_rx_queues &&		\
+	 rqID < 2 * adapter->num_rx_queues) ? 1 : 0)	\
+
+#define VMXNET3_RX_DATA_RING(adapter, rqID)		\
+	(rqID >= 2 * adapter->num_rx_queues &&		\
+	rqID < 3 * adapter->num_rx_queues)		\
+
 int
 vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter);
 
@@ -432,7 +453,7 @@ vmxnet3_set_features(struct net_device *netdev, netdev_features_t features);
 int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
 		      u32 tx_ring_size, u32 rx_ring_size, u32 rx_ring2_size,
-		      u16 txdata_desc_size);
+		      u16 txdata_desc_size, u16 rxdata_desc_size);
 
 void vmxnet3_set_ethtool_ops(struct net_device *netdev);
 
-- 
2.8.2
