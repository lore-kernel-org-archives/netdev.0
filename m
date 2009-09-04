From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 29/29] ioat2,
	3: cacheline align software descriptor allocations
Date: Thu, 03 Sep 2009 19:32:57 -0700
Message-ID: <20090904023257.32667.53926.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48840 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932724AbZIDCcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 22:32:55 -0400
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the necessary fields for handling an ioat2,3 ring entry can fit into
one cacheline.  Move ->len prior to ->txd in struct ioat_ring_ent, and
move allocation of these entries to a hw-cache-aligned kmem cache to
reduce the number of cachelines dirtied for descriptor management.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma_v2.c |    5 +++--
 drivers/dma/ioat/dma_v2.h |    3 ++-
 drivers/dma/ioat/pci.c    |   16 +++++++++++++++-
 3 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index 9ea1a47..f0c4876 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -400,11 +400,12 @@ static struct ioat_ring_ent *ioat2_alloc_ring_ent(struct dma_chan *chan, gfp_t f
 		return NULL;
 	memset(hw, 0, sizeof(*hw));
 
-	desc = kzalloc(sizeof(*desc), flags);
+	desc = kmem_cache_alloc(ioat2_cache, flags);
 	if (!desc) {
 		pci_pool_free(dma->dma_pool, hw, phys);
 		return NULL;
 	}
+	memset(desc, 0, sizeof(*desc));
 
 	dma_async_tx_descriptor_init(&desc->txd, chan);
 	desc->txd.tx_submit = ioat2_tx_submit_unlock;
@@ -419,7 +420,7 @@ static void ioat2_free_ring_ent(struct ioat_ring_ent *desc, struct dma_chan *cha
 
 	dma = to_ioatdma_device(chan->device);
 	pci_pool_free(dma->dma_pool, desc->hw, desc->txd.phys);
-	kfree(desc);
+	kmem_cache_free(ioat2_cache, desc);
 }
 
 static struct ioat_ring_ent **ioat2_alloc_ring(struct dma_chan *c, int order, gfp_t flags)
diff --git a/drivers/dma/ioat/dma_v2.h b/drivers/dma/ioat/dma_v2.h
index 9baa3d6..ac00adc 100644
--- a/drivers/dma/ioat/dma_v2.h
+++ b/drivers/dma/ioat/dma_v2.h
@@ -116,8 +116,8 @@ static inline u16 ioat2_xferlen_to_descs(struct ioat2_dma_chan *ioat, size_t len
 
 struct ioat_ring_ent {
 	struct ioat_dma_descriptor *hw;
-	struct dma_async_tx_descriptor txd;
 	size_t len;
+	struct dma_async_tx_descriptor txd;
 	#ifdef DEBUG
 	int id;
 	#endif
@@ -143,4 +143,5 @@ int __devinit ioat2_dma_probe(struct ioatdma_device *dev, int dca);
 int __devinit ioat3_dma_probe(struct ioatdma_device *dev, int dca);
 struct dca_provider * __devinit ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase);
 struct dca_provider * __devinit ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase);
+extern struct kmem_cache *ioat2_cache;
 #endif /* IOATDMA_V2_H */
diff --git a/drivers/dma/ioat/pci.c b/drivers/dma/ioat/pci.c
index c4e4322..61086c6 100644
--- a/drivers/dma/ioat/pci.c
+++ b/drivers/dma/ioat/pci.c
@@ -69,6 +69,8 @@ static int ioat_dca_enabled = 1;
 module_param(ioat_dca_enabled, int, 0644);
 MODULE_PARM_DESC(ioat_dca_enabled, "control support of dca service (default: 1)");
 
+struct kmem_cache *ioat2_cache;
+
 #define DRV_NAME "ioatdma"
 
 static struct pci_driver ioat_pci_driver = {
@@ -168,12 +170,24 @@ static void __devexit ioat_remove(struct pci_dev *pdev)
 
 static int __init ioat_init_module(void)
 {
-	return pci_register_driver(&ioat_pci_driver);
+	int err;
+
+	ioat2_cache = kmem_cache_create("ioat2", sizeof(struct ioat_ring_ent),
+					0, SLAB_HWCACHE_ALIGN, NULL);
+	if (!ioat2_cache)
+		return -ENOMEM;
+
+	err = pci_register_driver(&ioat_pci_driver);
+	if (err)
+		kmem_cache_destroy(ioat2_cache);
+
+	return err;
 }
 module_init(ioat_init_module);
 
 static void __exit ioat_exit_module(void)
 {
 	pci_unregister_driver(&ioat_pci_driver);
+	kmem_cache_destroy(ioat2_cache);
 }
 module_exit(ioat_exit_module);

