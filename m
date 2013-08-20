From: Andy King <acking@vmware.com>
Subject: [PATCH] VMXNET3: Add support for virtual IOMMU
Date: Tue, 20 Aug 2013 10:33:32 -0700
Message-ID: <1377020012-1839-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, Andy King <acking@vmware.com>, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

We can't just do virt_to_phys() on memory that we pass to the device and
expect it to work in presence of a virtual IOMMU.  We need to add IOMMU
mappings for such DMAs to work correctly.  Fix that with
pci_alloc_consistent() where possible, or pci_map_single() where the
mapping is short-lived or we don't control the allocation (netdev).

Also fix two small bugs:
1) use after free of rq->buf_info in vmxnet3_rq_destroy()
2) a cpu_to_le32() that should have been a cpu_to_le64()

Acked-by: George Zhang <georgezhang@vmware.com>
Acked-by: Aditya Sarwade <asarwade@vmware.com>
Signed-off-by: Andy King <acking@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   89 ++++++++++++++++++++++++++-----------
 drivers/net/vmxnet3/vmxnet3_int.h |   10 +++-
 2 files changed, 71 insertions(+), 28 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 55a62ca..7ca9ec9 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -446,8 +446,12 @@ vmxnet3_tq_destroy(struct vmxnet3_tx_queue *tq,
 				    tq->comp_ring.base, tq->comp_ring.basePA);
 		tq->comp_ring.base = NULL;
 	}
-	kfree(tq->buf_info);
-	tq->buf_info = NULL;
+	if (tq->buf_info) {
+		pci_free_consistent(adapter->pdev,
+				    tq->tx_ring.size * sizeof(tq->buf_info[0]),
+				    tq->buf_info, tq->buf_info_pa);
+		tq->buf_info = NULL;
+	}
 }
 
 
@@ -496,6 +500,8 @@ static int
 vmxnet3_tq_create(struct vmxnet3_tx_queue *tq,
 		  struct vmxnet3_adapter *adapter)
 {
+	size_t sz;
+
 	BUG_ON(tq->tx_ring.base || tq->data_ring.base ||
 	       tq->comp_ring.base || tq->buf_info);
 
@@ -525,10 +531,12 @@ vmxnet3_tq_create(struct vmxnet3_tx_queue *tq,
 		goto err;
 	}
 
-	tq->buf_info = kcalloc(tq->tx_ring.size, sizeof(tq->buf_info[0]),
-			       GFP_KERNEL);
+	sz = tq->tx_ring.size * sizeof(tq->buf_info[0]);
+	tq->buf_info = pci_alloc_consistent(adapter->pdev, sz,
+					    &tq->buf_info_pa);
 	if (!tq->buf_info)
 		goto err;
+	memset(tq->buf_info, 0, sz);
 
 	return 0;
 
@@ -1400,8 +1408,6 @@ static void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
 	}
 
 
-	kfree(rq->buf_info[0]);
-
 	for (i = 0; i < 2; i++) {
 		if (rq->rx_ring[i].base) {
 			pci_free_consistent(adapter->pdev, rq->rx_ring[i].size
@@ -1419,6 +1425,13 @@ static void vmxnet3_rq_destroy(struct vmxnet3_rx_queue *rq,
 				    rq->comp_ring.base, rq->comp_ring.basePA);
 		rq->comp_ring.base = NULL;
 	}
+
+	if (rq->buf_info[0]) {
+		size_t sz = sizeof(struct vmxnet3_rx_buf_info) *
+			(rq->rx_ring[0].size + rq->rx_ring[1].size);
+		pci_free_consistent(adapter->pdev, sz, rq->buf_info[0],
+				    rq->buf_info_pa);
+	}
 }
 
 
@@ -1522,10 +1535,11 @@ vmxnet3_rq_create(struct vmxnet3_rx_queue *rq, struct vmxnet3_adapter *adapter)
 
 	sz = sizeof(struct vmxnet3_rx_buf_info) * (rq->rx_ring[0].size +
 						   rq->rx_ring[1].size);
-	bi = kzalloc(sz, GFP_KERNEL);
+	bi = pci_alloc_consistent(adapter->pdev, sz, &rq->buf_info_pa);
 	if (!bi)
 		goto err;
 
+	memset(bi, 0, sz);
 	rq->buf_info[0] = bi;
 	rq->buf_info[1] = bi + rq->rx_ring[0].size;
 
@@ -2005,6 +2019,7 @@ vmxnet3_set_mc(struct net_device *netdev)
 	struct Vmxnet3_RxFilterConf *rxConf =
 					&adapter->shared->devRead.rxFilterConf;
 	u8 *new_table = NULL;
+	dma_addr_t new_table_pa = 0;
 	u32 new_mode = VMXNET3_RXM_UCAST;
 
 	if (netdev->flags & IFF_PROMISC) {
@@ -2028,8 +2043,11 @@ vmxnet3_set_mc(struct net_device *netdev)
 				new_mode |= VMXNET3_RXM_MCAST;
 				rxConf->mfTableLen = cpu_to_le16(
 					netdev_mc_count(netdev) * ETH_ALEN);
-				rxConf->mfTablePA = cpu_to_le64(virt_to_phys(
-						    new_table));
+				new_table_pa = pci_map_single(adapter->pdev,
+							new_table,
+							rxConf->mfTableLen,
+							PCI_DMA_TODEVICE);
+				rxConf->mfTablePA = cpu_to_le64(new_table_pa);
 			} else {
 				netdev_info(netdev, "failed to copy mcast list"
 					    ", setting ALL_MULTI\n");
@@ -2056,7 +2074,11 @@ vmxnet3_set_mc(struct net_device *netdev)
 			       VMXNET3_CMD_UPDATE_MAC_FILTERS);
 	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
-	kfree(new_table);
+	if (new_table) {
+		pci_unmap_single(adapter->pdev, new_table_pa,
+				 rxConf->mfTableLen, PCI_DMA_TODEVICE);
+		kfree(new_table);
+	}
 }
 
 void
@@ -2096,7 +2118,7 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 	devRead->misc.driverInfo.vmxnet3RevSpt = cpu_to_le32(1);
 	devRead->misc.driverInfo.uptVerSpt = cpu_to_le32(1);
 
-	devRead->misc.ddPA = cpu_to_le64(virt_to_phys(adapter));
+	devRead->misc.ddPA = cpu_to_le64(adapter->adapter_pa);
 	devRead->misc.ddLen = cpu_to_le32(sizeof(struct vmxnet3_adapter));
 
 	/* set up feature flags */
@@ -2125,7 +2147,7 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		tqc->txRingBasePA   = cpu_to_le64(tq->tx_ring.basePA);
 		tqc->dataRingBasePA = cpu_to_le64(tq->data_ring.basePA);
 		tqc->compRingBasePA = cpu_to_le64(tq->comp_ring.basePA);
-		tqc->ddPA           = cpu_to_le64(virt_to_phys(tq->buf_info));
+		tqc->ddPA           = cpu_to_le64(tq->buf_info_pa);
 		tqc->txRingSize     = cpu_to_le32(tq->tx_ring.size);
 		tqc->dataRingSize   = cpu_to_le32(tq->data_ring.size);
 		tqc->compRingSize   = cpu_to_le32(tq->comp_ring.size);
@@ -2143,8 +2165,7 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		rqc->rxRingBasePA[0] = cpu_to_le64(rq->rx_ring[0].basePA);
 		rqc->rxRingBasePA[1] = cpu_to_le64(rq->rx_ring[1].basePA);
 		rqc->compRingBasePA  = cpu_to_le64(rq->comp_ring.basePA);
-		rqc->ddPA            = cpu_to_le64(virt_to_phys(
-							rq->buf_info));
+		rqc->ddPA            = cpu_to_le64(rq->buf_info_pa);
 		rqc->rxRingSize[0]   = cpu_to_le32(rq->rx_ring[0].size);
 		rqc->rxRingSize[1]   = cpu_to_le32(rq->rx_ring[1].size);
 		rqc->compRingSize    = cpu_to_le32(rq->comp_ring.size);
@@ -2184,8 +2205,9 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 				i, adapter->num_rx_queues);
 
 		devRead->rssConfDesc.confVer = 1;
-		devRead->rssConfDesc.confLen = sizeof(*rssConf);
-		devRead->rssConfDesc.confPA  = virt_to_phys(rssConf);
+		devRead->rssConfDesc.confLen = cpu_to_le32(sizeof(*rssConf));
+		devRead->rssConfDesc.confPA =
+			cpu_to_le64(adapter->rss_conf_pa);
 	}
 
 #endif /* VMXNET3_RSS */
@@ -2948,6 +2970,9 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 
 	spin_lock_init(&adapter->cmd_lock);
+	adapter->adapter_pa = pci_map_single(adapter->pdev, adapter,
+					     sizeof(struct vmxnet3_adapter),
+					     PCI_DMA_TODEVICE);
 	adapter->shared = pci_alloc_consistent(adapter->pdev,
 					       sizeof(struct Vmxnet3_DriverShared),
 					       &adapter->shared_pa);
@@ -2974,7 +2999,9 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	adapter->rqd_start = (struct Vmxnet3_RxQueueDesc *)(adapter->tqd_start +
 							    adapter->num_tx_queues);
 
-	adapter->pm_conf = kmalloc(sizeof(struct Vmxnet3_PMConf), GFP_KERNEL);
+	adapter->pm_conf = pci_alloc_consistent(adapter->pdev,
+						sizeof(struct Vmxnet3_PMConf),
+						&adapter->pm_conf_pa);
 	if (adapter->pm_conf == NULL) {
 		err = -ENOMEM;
 		goto err_alloc_pm;
@@ -2982,7 +3009,9 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 
 #ifdef VMXNET3_RSS
 
-	adapter->rss_conf = kmalloc(sizeof(struct UPT1_RSSConf), GFP_KERNEL);
+	adapter->rss_conf = pci_alloc_consistent(adapter->pdev,
+						 sizeof(struct UPT1_RSSConf),
+						 &adapter->rss_conf_pa);
 	if (adapter->rss_conf == NULL) {
 		err = -ENOMEM;
 		goto err_alloc_rss;
@@ -3077,10 +3106,12 @@ err_ver:
 	vmxnet3_free_pci_resources(adapter);
 err_alloc_pci:
 #ifdef VMXNET3_RSS
-	kfree(adapter->rss_conf);
+	pci_free_consistent(adapter->pdev, sizeof(struct UPT1_RSSConf),
+			    adapter->rss_conf, adapter->rss_conf_pa);
 err_alloc_rss:
 #endif
-	kfree(adapter->pm_conf);
+	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_PMConf),
+			    adapter->pm_conf, adapter->pm_conf_pa);
 err_alloc_pm:
 	pci_free_consistent(adapter->pdev, size, adapter->tqd_start,
 			    adapter->queue_desc_pa);
@@ -3088,6 +3119,8 @@ err_alloc_queue_desc:
 	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_DriverShared),
 			    adapter->shared, adapter->shared_pa);
 err_alloc_shared:
+	pci_unmap_single(adapter->pdev, adapter->adapter_pa,
+			 sizeof(struct vmxnet3_adapter), PCI_DMA_TODEVICE);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 	return err;
@@ -3118,9 +3151,11 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 	vmxnet3_free_intr_resources(adapter);
 	vmxnet3_free_pci_resources(adapter);
 #ifdef VMXNET3_RSS
-	kfree(adapter->rss_conf);
+	pci_free_consistent(adapter->pdev, sizeof(struct UPT1_RSSConf),
+			    adapter->rss_conf, adapter->rss_conf_pa);
 #endif
-	kfree(adapter->pm_conf);
+	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_PMConf),
+			    adapter->pm_conf, adapter->pm_conf_pa);
 
 	size = sizeof(struct Vmxnet3_TxQueueDesc) * adapter->num_tx_queues;
 	size += sizeof(struct Vmxnet3_RxQueueDesc) * num_rx_queues;
@@ -3128,6 +3163,8 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 			    adapter->queue_desc_pa);
 	pci_free_consistent(adapter->pdev, sizeof(struct Vmxnet3_DriverShared),
 			    adapter->shared, adapter->shared_pa);
+	pci_unmap_single(adapter->pdev, adapter->adapter_pa,
+			 sizeof(struct vmxnet3_adapter), PCI_DMA_TODEVICE);
 	free_netdev(netdev);
 }
 
@@ -3227,8 +3264,8 @@ skip_arp:
 	adapter->shared->devRead.pmConfDesc.confVer = cpu_to_le32(1);
 	adapter->shared->devRead.pmConfDesc.confLen = cpu_to_le32(sizeof(
 								  *pmConf));
-	adapter->shared->devRead.pmConfDesc.confPA = cpu_to_le64(virt_to_phys(
-								 pmConf));
+	adapter->shared->devRead.pmConfDesc.confPA
+		= cpu_to_le64(adapter->pm_conf_pa);
 
 	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
@@ -3265,8 +3302,8 @@ vmxnet3_resume(struct device *device)
 	adapter->shared->devRead.pmConfDesc.confVer = cpu_to_le32(1);
 	adapter->shared->devRead.pmConfDesc.confLen = cpu_to_le32(sizeof(
 								  *pmConf));
-	adapter->shared->devRead.pmConfDesc.confPA = cpu_to_le64(virt_to_phys(
-								 pmConf));
+	adapter->shared->devRead.pmConfDesc.confPA =
+		cpu_to_le64(adapter->pm_conf_pa);
 
 	netif_device_attach(netdev);
 	pci_set_power_state(pdev, PCI_D0);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 3541814..ca8d595 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -70,10 +70,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.1.30.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.1.31.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01011E00
+#define VMXNET3_DRIVER_VERSION_NUM      0x01011F00
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
@@ -229,6 +229,7 @@ struct vmxnet3_tx_queue {
 	spinlock_t                      tx_lock;
 	struct vmxnet3_cmd_ring         tx_ring;
 	struct vmxnet3_tx_buf_info      *buf_info;
+	dma_addr_t                       buf_info_pa;
 	struct vmxnet3_tx_data_ring     data_ring;
 	struct vmxnet3_comp_ring        comp_ring;
 	struct Vmxnet3_TxQueueCtrl      *shared;
@@ -277,6 +278,7 @@ struct vmxnet3_rx_queue {
 	u32 qid;            /* rqID in RCD for buffer from 1st ring */
 	u32 qid2;           /* rqID in RCD for buffer from 2nd ring */
 	struct vmxnet3_rx_buf_info     *buf_info[2];
+	dma_addr_t                      buf_info_pa;
 	struct Vmxnet3_RxQueueCtrl            *shared;
 	struct vmxnet3_rq_driver_stats  stats;
 } __attribute__((__aligned__(SMP_CACHE_BYTES)));
@@ -353,6 +355,10 @@ struct vmxnet3_adapter {
 	unsigned long  state;    /* VMXNET3_STATE_BIT_xxx */
 
 	int share_intr;
+
+	dma_addr_t adapter_pa;
+	dma_addr_t pm_conf_pa;
+	dma_addr_t rss_conf_pa;
 };
 
 #define VMXNET3_WRITE_BAR0_REG(adapter, reg, val)  \
-- 
1.7.4.1
