From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 2/5] be2net: remove pci_func field from
	be_adapter struct
Date: Tue, 28 Jul 2009 14:22:23 +0530
Message-ID: <20090728085223.GA4977@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:4482 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750733AbZG1Iwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:52:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pci function is available as PCI_FUNC(pdev->devfn); no need for a
separate field.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |    6 +++++-
 drivers/net/benet/be_cmds.c |    8 ++++----
 drivers/net/benet/be_hw.h   |    3 ---
 drivers/net/benet/be_main.c |    8 ++------
 4 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index d8a157f..beb1313 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -213,7 +213,6 @@ struct be_adapter {
 	u8 __iomem *csr;
 	u8 __iomem *db;		/* Door Bell */
 	u8 __iomem *pcicfg;	/* PCI config space */
-	int pci_func;
 
 	spinlock_t mbox_lock;	/* For serializing mbox cmds to BE card */
 	struct be_dma_mem mbox_mem;
@@ -264,6 +263,11 @@ extern struct ethtool_ops be_ethtool_ops;
 
 #define drvr_stats(adapter)		(&adapter->stats.drvr_stats)
 
+static inline unsigned int be_pci_func(struct be_adapter *adapter)
+{
+	return PCI_FUNC(adapter->pdev->devfn);
+}
+
 #define BE_SET_NETDEV_OPS(netdev, ops)	(netdev->netdev_ops = ops)
 
 #define PAGE_SHIFT_4K		12
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 20278b9..daa2fe8 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -388,7 +388,7 @@ int be_cmd_eq_create(struct be_adapter *adapter,
 	req->num_pages =  cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 
 	AMAP_SET_BITS(struct amap_eq_context, func, req->context,
-			adapter->pci_func);
+			be_pci_func(adapter));
 	AMAP_SET_BITS(struct amap_eq_context, valid, req->context, 1);
 	/* 4byte eqe*/
 	AMAP_SET_BITS(struct amap_eq_context, size, req->context, 0);
@@ -522,7 +522,7 @@ int be_cmd_cq_create(struct be_adapter *adapter,
 	AMAP_SET_BITS(struct amap_cq_context, eventable, ctxt, 1);
 	AMAP_SET_BITS(struct amap_cq_context, eqid, ctxt, eq->id);
 	AMAP_SET_BITS(struct amap_cq_context, armed, ctxt, 1);
-	AMAP_SET_BITS(struct amap_cq_context, func, ctxt, adapter->pci_func);
+	AMAP_SET_BITS(struct amap_cq_context, func, ctxt, be_pci_func(adapter));
 	be_dws_cpu_to_le(ctxt, sizeof(req->context));
 
 	be_cmd_page_addrs_prepare(req->pages, ARRAY_SIZE(req->pages), q_mem);
@@ -565,7 +565,7 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 
 	req->num_pages = PAGES_4K_SPANNED(q_mem->va, q_mem->size);
 
-	AMAP_SET_BITS(struct amap_mcc_context, fid, ctxt, adapter->pci_func);
+	AMAP_SET_BITS(struct amap_mcc_context, fid, ctxt, be_pci_func(adapter));
 	AMAP_SET_BITS(struct amap_mcc_context, valid, ctxt, 1);
 	AMAP_SET_BITS(struct amap_mcc_context, ring_size, ctxt,
 		be_encoded_q_len(mccq->len));
@@ -614,7 +614,7 @@ int be_cmd_txq_create(struct be_adapter *adapter,
 		len_encoded = 0;
 	AMAP_SET_BITS(struct amap_tx_context, tx_ring_size, ctxt, len_encoded);
 	AMAP_SET_BITS(struct amap_tx_context, pci_func_id, ctxt,
-			adapter->pci_func);
+			be_pci_func(adapter));
 	AMAP_SET_BITS(struct amap_tx_context, ctx_valid, ctxt, 1);
 	AMAP_SET_BITS(struct amap_tx_context, cq_id_send, ctxt, cq->id);
 
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index 29c33c7..d28f0c6 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -51,9 +51,6 @@
  * with the OS.
  */
 #define MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK	(1 << 29) /* bit 29 */
-/* PCI physical function number */
-#define MEMBAR_CTRL_INT_CTRL_PFUNC_MASK  	0x7 	/* bits 26 - 28 */
-#define MEMBAR_CTRL_INT_CTRL_PFUNC_SHIFT	26
 
 /********* ISR0 Register offset **********/
 #define CEV_ISR0_OFFSET 			0xC18
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index da5341f..9c8654d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1279,7 +1279,7 @@ static irqreturn_t be_intx(int irq, void *dev)
 	int isr;
 
 	isr = ioread32(adapter->csr + CEV_ISR0_OFFSET +
-			adapter->pci_func * CEV_ISR_SIZE);
+			be_pci_func(adapter) * CEV_ISR_SIZE);
 	if (!isr)
 		return IRQ_NONE;
 
@@ -1446,7 +1446,7 @@ static void be_msix_enable(struct be_adapter *adapter)
 
 static inline int be_msix_vec_get(struct be_adapter *adapter, u32 eq_id)
 {
-	return adapter->msix_entries[eq_id - 8 * adapter->pci_func].vector;
+	return adapter->msix_entries[eq_id - 8 * be_pci_func(adapter)].vector;
 }
 
 static int be_msix_register(struct be_adapter *adapter)
@@ -1743,7 +1743,6 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	struct be_dma_mem *mbox_mem_alloc = &adapter->mbox_mem_alloced;
 	struct be_dma_mem *mbox_mem_align = &adapter->mbox_mem;
 	int status;
-	u32 val;
 
 	status = be_map_pci_bars(adapter);
 	if (status)
@@ -1764,9 +1763,6 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	spin_lock_init(&adapter->mcc_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
 
-	val = ioread32(adapter->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET);
-	adapter->pci_func = (val >> MEMBAR_CTRL_INT_CTRL_PFUNC_SHIFT) &
-					MEMBAR_CTRL_INT_CTRL_PFUNC_MASK;
 	return 0;
 }
 
-- 
1.6.0.4

