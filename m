From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: [net-next PATCH v3 1/1] atm: remove deprecated use of pci api
Date: Fri, 16 Jan 2015 08:57:21 -0500
Message-ID: <20150116085721.56aa8075@thirdoffive.cmf.nrl.navy.mil>
References: <20150112161042.GA11374@sloth>
	<20150113.215944.1703977685948196746.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D1CAC79B3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'David Miller'" <davem@davemloft.net>,
	"lambert.quentin@gmail.com" <lambert.quentin@gmail.com>,
	"linux-atm-general@lists.sourceforge.net"
	<linux-atm-general@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC79B3@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
---
 drivers/atm/eni.c       |  33 +++++++------
 drivers/atm/fore200e.c  |  22 +++++----
 drivers/atm/he.c        | 125 +++++++++++++++++++++++++-----------------------
 drivers/atm/he.h        |   4 +-
 drivers/atm/idt77252.c  | 107 ++++++++++++++++++++++-------------------
 drivers/atm/iphase.c    |  54 +++++++++++----------
 drivers/atm/lanai.c     |  14 ++----
 drivers/atm/nicstar.c   |  60 +++++++++++------------
 drivers/atm/solos-pci.c |  26 +++++-----
 drivers/atm/zatm.c      |  17 ++++---
 10 files changed, 243 insertions(+), 219 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index c7fab3e..6339efd 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -354,9 +354,9 @@ static int do_rx_dma(struct atm_vcc *vcc,struct sk_buff *skb,
 	eni_vcc = ENI_VCC(vcc);
 	paddr = 0; /* GCC, shut up */
 	if (skb) {
-		paddr = pci_map_single(eni_dev->pci_dev,skb->data,skb->len,
-		    PCI_DMA_FROMDEVICE);
-		if (pci_dma_mapping_error(eni_dev->pci_dev, paddr))
+		paddr = dma_map_single(&eni_dev->pci_dev->dev,skb->data,skb->len,
+				       DMA_FROM_DEVICE);
+		if (dma_mapping_error(&eni_dev->pci_dev->dev, paddr))
 			goto dma_map_error;
 		ENI_PRV_PADDR(skb) = paddr;
 		if (paddr & 3)
@@ -481,8 +481,8 @@ rx_enqueued++;
 
 trouble:
 	if (paddr)
-		pci_unmap_single(eni_dev->pci_dev,paddr,skb->len,
-		    PCI_DMA_FROMDEVICE);
+		dma_unmap_single(&eni_dev->pci_dev->dev,paddr,skb->len,
+				 DMA_FROM_DEVICE);
 dma_map_error:
 	if (skb) dev_kfree_skb_irq(skb);
 	return -1;
@@ -758,8 +758,8 @@ rx_dequeued++;
 		}
 		eni_vcc->rxing--;
 		eni_vcc->rx_pos = ENI_PRV_POS(skb) & (eni_vcc->words-1);
-		pci_unmap_single(eni_dev->pci_dev,ENI_PRV_PADDR(skb),skb->len,
-		    PCI_DMA_TODEVICE);
+		dma_unmap_single(&eni_dev->pci_dev->dev,ENI_PRV_PADDR(skb),skb->len,
+			         DMA_TO_DEVICE);
 		if (!skb->len) dev_kfree_skb_irq(skb);
 		else {
 			EVENT("pushing (len=%ld)\n",skb->len,0);
@@ -1112,8 +1112,8 @@ DPRINTK("iovcnt = %d\n",skb_shinfo(skb)->nr_frags);
 		    vcc->dev->number);
 		return enq_jam;
 	}
-	paddr = pci_map_single(eni_dev->pci_dev,skb->data,skb->len,
-	    PCI_DMA_TODEVICE);
+	paddr = dma_map_single(&eni_dev->pci_dev->dev,skb->data,skb->len,
+			       DMA_TO_DEVICE);
 	ENI_PRV_PADDR(skb) = paddr;
 	/* prepare DMA queue entries */
 	j = 0;
@@ -1226,8 +1226,8 @@ static void dequeue_tx(struct atm_dev *dev)
 			break;
 		}
 		ENI_VCC(vcc)->txing -= ENI_PRV_SIZE(skb);
-		pci_unmap_single(eni_dev->pci_dev,ENI_PRV_PADDR(skb),skb->len,
-		    PCI_DMA_TODEVICE);
+		dma_unmap_single(&eni_dev->pci_dev->dev,ENI_PRV_PADDR(skb),skb->len,
+				 DMA_TO_DEVICE);
 		if (vcc->pop) vcc->pop(vcc,skb);
 		else dev_kfree_skb_irq(skb);
 		atomic_inc(&vcc->stats->tx);
@@ -2240,13 +2240,18 @@ static int eni_init_one(struct pci_dev *pci_dev,
 	if (rc < 0)
 		goto out;
 
+	rc = dma_set_mask_and_coherent(&pci_dev->dev, DMA_BIT_MASK(32));
+	if (rc < 0)
+		goto out;
+
 	rc = -ENOMEM;
 	eni_dev = kmalloc(sizeof(struct eni_dev), GFP_KERNEL);
 	if (!eni_dev)
 		goto err_disable;
 
 	zero = &eni_dev->zero;
-	zero->addr = pci_alloc_consistent(pci_dev, ENI_ZEROES_SIZE, &zero->dma);
+	zero->addr = dma_alloc_coherent(&pci_dev->dev,
+					ENI_ZEROES_SIZE, &zero->dma, GFP_KERNEL);
 	if (!zero->addr)
 		goto err_kfree;
 
@@ -2277,7 +2282,7 @@ err_eni_release:
 err_unregister:
 	atm_dev_deregister(dev);
 err_free_consistent:
-	pci_free_consistent(pci_dev, ENI_ZEROES_SIZE, zero->addr, zero->dma);
+	dma_free_coherent(&pci_dev->dev, ENI_ZEROES_SIZE, zero->addr, zero->dma);
 err_kfree:
 	kfree(eni_dev);
 err_disable:
@@ -2302,7 +2307,7 @@ static void eni_remove_one(struct pci_dev *pdev)
 
 	eni_do_release(dev);
 	atm_dev_deregister(dev);
-	pci_free_consistent(pdev, ENI_ZEROES_SIZE, zero->addr, zero->dma);
+	dma_free_coherent(&pdev->dev, ENI_ZEROES_SIZE, zero->addr, zero->dma);
 	kfree(ed);
 	pci_disable_device(pdev);
 }
diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index d5d9eaf..75dde90 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -425,7 +425,7 @@ static void fore200e_pca_write(u32 val, volatile u32 __iomem *addr)
 static u32
 fore200e_pca_dma_map(struct fore200e* fore200e, void* virt_addr, int size, int direction)
 {
-    u32 dma_addr = pci_map_single((struct pci_dev*)fore200e->bus_dev, virt_addr, size, direction);
+    u32 dma_addr = dma_map_single(&((struct pci_dev *) fore200e->bus_dev)->dev, virt_addr, size, direction);
 
     DPRINTK(3, "PCI DVMA mapping: virt_addr = 0x%p, size = %d, direction = %d,  --> dma_addr = 0x%08x\n",
 	    virt_addr, size, direction, dma_addr);
@@ -440,7 +440,7 @@ fore200e_pca_dma_unmap(struct fore200e* fore200e, u32 dma_addr, int size, int di
     DPRINTK(3, "PCI DVMA unmapping: dma_addr = 0x%08x, size = %d, direction = %d\n",
 	    dma_addr, size, direction);
 
-    pci_unmap_single((struct pci_dev*)fore200e->bus_dev, dma_addr, size, direction);
+    dma_unmap_single(&((struct pci_dev *) fore200e->bus_dev)->dev, dma_addr, size, direction);
 }
 
 
@@ -449,7 +449,7 @@ fore200e_pca_dma_sync_for_cpu(struct fore200e* fore200e, u32 dma_addr, int size,
 {
     DPRINTK(3, "PCI DVMA sync: dma_addr = 0x%08x, size = %d, direction = %d\n", dma_addr, size, direction);
 
-    pci_dma_sync_single_for_cpu((struct pci_dev*)fore200e->bus_dev, dma_addr, size, direction);
+    dma_sync_single_for_cpu(&((struct pci_dev *) fore200e->bus_dev)->dev, dma_addr, size, direction);
 }
 
 static void
@@ -457,7 +457,7 @@ fore200e_pca_dma_sync_for_device(struct fore200e* fore200e, u32 dma_addr, int si
 {
     DPRINTK(3, "PCI DVMA sync: dma_addr = 0x%08x, size = %d, direction = %d\n", dma_addr, size, direction);
 
-    pci_dma_sync_single_for_device((struct pci_dev*)fore200e->bus_dev, dma_addr, size, direction);
+    dma_sync_single_for_device(&((struct pci_dev *) fore200e->bus_dev)->dev, dma_addr, size, direction);
 }
 
 
@@ -470,9 +470,10 @@ fore200e_pca_dma_chunk_alloc(struct fore200e* fore200e, struct chunk* chunk,
 {
     /* returned chunks are page-aligned */
     chunk->alloc_size = size * nbr;
-    chunk->alloc_addr = pci_alloc_consistent((struct pci_dev*)fore200e->bus_dev,
-					     chunk->alloc_size,
-					     &chunk->dma_addr);
+    chunk->alloc_addr = dma_alloc_coherent(&((struct pci_dev *) fore200e->bus_dev)->dev,
+					   chunk->alloc_size,
+					   &chunk->dma_addr,
+					   GFP_KERNEL);
     
     if ((chunk->alloc_addr == NULL) || (chunk->dma_addr == 0))
 	return -ENOMEM;
@@ -488,7 +489,7 @@ fore200e_pca_dma_chunk_alloc(struct fore200e* fore200e, struct chunk* chunk,
 static void
 fore200e_pca_dma_chunk_free(struct fore200e* fore200e, struct chunk* chunk)
 {
-    pci_free_consistent((struct pci_dev*)fore200e->bus_dev,
+    dma_free_coherent(&((struct pci_dev *) fore200e->bus_dev)->dev,
 			chunk->alloc_size,
 			chunk->alloc_addr,
 			chunk->dma_addr);
@@ -2707,6 +2708,11 @@ static int fore200e_pca_detect(struct pci_dev *pci_dev,
 	err = -EINVAL;
 	goto out;
     }
+
+    if (dma_set_mask_and_coherent(&pci_dev->dev, DMA_BIT_MASK(32))) {
+	err = -EINVAL;
+	goto out;
+    }
     
     fore200e = kzalloc(sizeof(struct fore200e), GFP_KERNEL);
     if (fore200e == NULL) {
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index c39702b..93dca2e 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -359,7 +359,7 @@ static int he_init_one(struct pci_dev *pci_dev,
 
 	if (pci_enable_device(pci_dev))
 		return -EIO;
-	if (pci_set_dma_mask(pci_dev, DMA_BIT_MASK(32)) != 0) {
+	if (dma_set_mask_and_coherent(&pci_dev->dev, DMA_BIT_MASK(32)) != 0) {
 		printk(KERN_WARNING "he: no suitable dma available\n");
 		err = -EIO;
 		goto init_one_failure;
@@ -533,9 +533,9 @@ static void he_init_tx_lbfp(struct he_dev *he_dev)
 
 static int he_init_tpdrq(struct he_dev *he_dev)
 {
-	he_dev->tpdrq_base = pci_zalloc_consistent(he_dev->pci_dev,
-						   CONFIG_TPDRQ_SIZE * sizeof(struct he_tpdrq),
-						   &he_dev->tpdrq_phys);
+	he_dev->tpdrq_base = dma_zalloc_coherent(&he_dev->pci_dev->dev,
+						 CONFIG_TPDRQ_SIZE * sizeof(struct he_tpdrq),
+						 &he_dev->tpdrq_phys, GFP_KERNEL);
 	if (he_dev->tpdrq_base == NULL) {
 		hprintk("failed to alloc tpdrq\n");
 		return -ENOMEM;
@@ -796,16 +796,16 @@ static int he_init_group(struct he_dev *he_dev, int group)
 	}
 
 	/* large buffer pool */
-	he_dev->rbpl_pool = pci_pool_create("rbpl", he_dev->pci_dev,
+	he_dev->rbpl_pool = dma_pool_create("rbpl", &he_dev->pci_dev->dev,
 					    CONFIG_RBPL_BUFSIZE, 64, 0);
 	if (he_dev->rbpl_pool == NULL) {
 		hprintk("unable to create rbpl pool\n");
 		goto out_free_rbpl_virt;
 	}
 
-	he_dev->rbpl_base = pci_zalloc_consistent(he_dev->pci_dev,
-						  CONFIG_RBPL_SIZE * sizeof(struct he_rbp),
-						  &he_dev->rbpl_phys);
+	he_dev->rbpl_base = dma_zalloc_coherent(&he_dev->pci_dev->dev,
+						CONFIG_RBPL_SIZE * sizeof(struct he_rbp),
+						&he_dev->rbpl_phys, GFP_KERNEL);
 	if (he_dev->rbpl_base == NULL) {
 		hprintk("failed to alloc rbpl_base\n");
 		goto out_destroy_rbpl_pool;
@@ -815,7 +815,7 @@ static int he_init_group(struct he_dev *he_dev, int group)
 
 	for (i = 0; i < CONFIG_RBPL_SIZE; ++i) {
 
-		heb = pci_pool_alloc(he_dev->rbpl_pool, GFP_KERNEL|GFP_DMA, &mapping);
+		heb = dma_pool_alloc(he_dev->rbpl_pool, GFP_KERNEL, &mapping);
 		if (!heb)
 			goto out_free_rbpl;
 		heb->mapping = mapping;
@@ -842,9 +842,9 @@ static int he_init_group(struct he_dev *he_dev, int group)
 
 	/* rx buffer ready queue */
 
-	he_dev->rbrq_base = pci_zalloc_consistent(he_dev->pci_dev,
-						  CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq),
-						  &he_dev->rbrq_phys);
+	he_dev->rbrq_base = dma_zalloc_coherent(&he_dev->pci_dev->dev,
+						CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq),
+						&he_dev->rbrq_phys, GFP_KERNEL);
 	if (he_dev->rbrq_base == NULL) {
 		hprintk("failed to allocate rbrq\n");
 		goto out_free_rbpl;
@@ -866,9 +866,9 @@ static int he_init_group(struct he_dev *he_dev, int group)
 
 	/* tx buffer ready queue */
 
-	he_dev->tbrq_base = pci_zalloc_consistent(he_dev->pci_dev,
-						  CONFIG_TBRQ_SIZE * sizeof(struct he_tbrq),
-						  &he_dev->tbrq_phys);
+	he_dev->tbrq_base = dma_zalloc_coherent(&he_dev->pci_dev->dev,
+						CONFIG_TBRQ_SIZE * sizeof(struct he_tbrq),
+						&he_dev->tbrq_phys, GFP_KERNEL);
 	if (he_dev->tbrq_base == NULL) {
 		hprintk("failed to allocate tbrq\n");
 		goto out_free_rbpq_base;
@@ -884,18 +884,18 @@ static int he_init_group(struct he_dev *he_dev, int group)
 	return 0;
 
 out_free_rbpq_base:
-	pci_free_consistent(he_dev->pci_dev, CONFIG_RBRQ_SIZE *
-			sizeof(struct he_rbrq), he_dev->rbrq_base,
-			he_dev->rbrq_phys);
+	dma_free_coherent(&he_dev->pci_dev->dev, CONFIG_RBRQ_SIZE *
+			  sizeof(struct he_rbrq), he_dev->rbrq_base,
+			  he_dev->rbrq_phys);
 out_free_rbpl:
 	list_for_each_entry_safe(heb, next, &he_dev->rbpl_outstanding, entry)
-		pci_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
+		dma_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
 
-	pci_free_consistent(he_dev->pci_dev, CONFIG_RBPL_SIZE *
-			sizeof(struct he_rbp), he_dev->rbpl_base,
-			he_dev->rbpl_phys);
+	dma_free_coherent(&he_dev->pci_dev->dev, CONFIG_RBPL_SIZE *
+			  sizeof(struct he_rbp), he_dev->rbpl_base,
+			  he_dev->rbpl_phys);
 out_destroy_rbpl_pool:
-	pci_pool_destroy(he_dev->rbpl_pool);
+	dma_pool_destroy(he_dev->rbpl_pool);
 out_free_rbpl_virt:
 	kfree(he_dev->rbpl_virt);
 out_free_rbpl_table:
@@ -911,8 +911,11 @@ static int he_init_irq(struct he_dev *he_dev)
 	/* 2.9.3.5  tail offset for each interrupt queue is located after the
 		    end of the interrupt queue */
 
-	he_dev->irq_base = pci_alloc_consistent(he_dev->pci_dev,
-			(CONFIG_IRQ_SIZE+1) * sizeof(struct he_irq), &he_dev->irq_phys);
+	he_dev->irq_base = dma_zalloc_coherent(&he_dev->pci_dev->dev,
+					       (CONFIG_IRQ_SIZE + 1)
+					       * sizeof(struct he_irq),
+					       &he_dev->irq_phys,
+					       GFP_KERNEL);
 	if (he_dev->irq_base == NULL) {
 		hprintk("failed to allocate irq\n");
 		return -ENOMEM;
@@ -1419,10 +1422,10 @@ static int he_start(struct atm_dev *dev)
 
 	he_init_tpdrq(he_dev);
 
-	he_dev->tpd_pool = pci_pool_create("tpd", he_dev->pci_dev,
-		sizeof(struct he_tpd), TPD_ALIGNMENT, 0);
+	he_dev->tpd_pool = dma_pool_create("tpd", &he_dev->pci_dev->dev,
+					   sizeof(struct he_tpd), TPD_ALIGNMENT, 0);
 	if (he_dev->tpd_pool == NULL) {
-		hprintk("unable to create tpd pci_pool\n");
+		hprintk("unable to create tpd dma_pool\n");
 		return -ENOMEM;         
 	}
 
@@ -1459,9 +1462,9 @@ static int he_start(struct atm_dev *dev)
 
 	/* host status page */
 
-	he_dev->hsp = pci_zalloc_consistent(he_dev->pci_dev,
-					    sizeof(struct he_hsp),
-					    &he_dev->hsp_phys);
+	he_dev->hsp = dma_zalloc_coherent(&he_dev->pci_dev->dev,
+					  sizeof(struct he_hsp),
+					  &he_dev->hsp_phys, GFP_KERNEL);
 	if (he_dev->hsp == NULL) {
 		hprintk("failed to allocate host status page\n");
 		return -ENOMEM;
@@ -1558,41 +1561,41 @@ he_stop(struct he_dev *he_dev)
 		free_irq(he_dev->irq, he_dev);
 
 	if (he_dev->irq_base)
-		pci_free_consistent(he_dev->pci_dev, (CONFIG_IRQ_SIZE+1)
-			* sizeof(struct he_irq), he_dev->irq_base, he_dev->irq_phys);
+		dma_free_coherent(&he_dev->pci_dev->dev, (CONFIG_IRQ_SIZE + 1)
+				  * sizeof(struct he_irq), he_dev->irq_base, he_dev->irq_phys);
 
 	if (he_dev->hsp)
-		pci_free_consistent(he_dev->pci_dev, sizeof(struct he_hsp),
-						he_dev->hsp, he_dev->hsp_phys);
+		dma_free_coherent(&he_dev->pci_dev->dev, sizeof(struct he_hsp),
+				  he_dev->hsp, he_dev->hsp_phys);
 
 	if (he_dev->rbpl_base) {
 		list_for_each_entry_safe(heb, next, &he_dev->rbpl_outstanding, entry)
-			pci_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
+			dma_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
 
-		pci_free_consistent(he_dev->pci_dev, CONFIG_RBPL_SIZE
-			* sizeof(struct he_rbp), he_dev->rbpl_base, he_dev->rbpl_phys);
+		dma_free_coherent(&he_dev->pci_dev->dev, CONFIG_RBPL_SIZE
+				  * sizeof(struct he_rbp), he_dev->rbpl_base, he_dev->rbpl_phys);
 	}
 
 	kfree(he_dev->rbpl_virt);
 	kfree(he_dev->rbpl_table);
 
 	if (he_dev->rbpl_pool)
-		pci_pool_destroy(he_dev->rbpl_pool);
+		dma_pool_destroy(he_dev->rbpl_pool);
 
 	if (he_dev->rbrq_base)
-		pci_free_consistent(he_dev->pci_dev, CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq),
-							he_dev->rbrq_base, he_dev->rbrq_phys);
+		dma_free_coherent(&he_dev->pci_dev->dev, CONFIG_RBRQ_SIZE * sizeof(struct he_rbrq),
+				  he_dev->rbrq_base, he_dev->rbrq_phys);
 
 	if (he_dev->tbrq_base)
-		pci_free_consistent(he_dev->pci_dev, CONFIG_TBRQ_SIZE * sizeof(struct he_tbrq),
-							he_dev->tbrq_base, he_dev->tbrq_phys);
+		dma_free_coherent(&he_dev->pci_dev->dev, CONFIG_TBRQ_SIZE * sizeof(struct he_tbrq),
+				  he_dev->tbrq_base, he_dev->tbrq_phys);
 
 	if (he_dev->tpdrq_base)
-		pci_free_consistent(he_dev->pci_dev, CONFIG_TBRQ_SIZE * sizeof(struct he_tbrq),
-							he_dev->tpdrq_base, he_dev->tpdrq_phys);
+		dma_free_coherent(&he_dev->pci_dev->dev, CONFIG_TBRQ_SIZE * sizeof(struct he_tbrq),
+				  he_dev->tpdrq_base, he_dev->tpdrq_phys);
 
 	if (he_dev->tpd_pool)
-		pci_pool_destroy(he_dev->tpd_pool);
+		dma_pool_destroy(he_dev->tpd_pool);
 
 	if (he_dev->pci_dev) {
 		pci_read_config_word(he_dev->pci_dev, PCI_COMMAND, &command);
@@ -1610,7 +1613,7 @@ __alloc_tpd(struct he_dev *he_dev)
 	struct he_tpd *tpd;
 	dma_addr_t mapping;
 
-	tpd = pci_pool_alloc(he_dev->tpd_pool, GFP_ATOMIC|GFP_DMA, &mapping);
+	tpd = dma_pool_alloc(he_dev->tpd_pool, GFP_ATOMIC, &mapping);
 	if (tpd == NULL)
 		return NULL;
 			
@@ -1681,7 +1684,7 @@ he_service_rbrq(struct he_dev *he_dev, int group)
 			if (!RBRQ_HBUF_ERR(he_dev->rbrq_head)) {
 				clear_bit(i, he_dev->rbpl_table);
 				list_del(&heb->entry);
-				pci_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
+				dma_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
 			}
 					
 			goto next_rbrq_entry;
@@ -1774,7 +1777,7 @@ return_host_buffers:
 		++pdus_assembled;
 
 		list_for_each_entry_safe(heb, next, &he_vcc->buffers, entry)
-			pci_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
+			dma_pool_free(he_dev->rbpl_pool, heb, heb->mapping);
 		INIT_LIST_HEAD(&he_vcc->buffers);
 		he_vcc->pdu_len = 0;
 
@@ -1843,10 +1846,10 @@ he_service_tbrq(struct he_dev *he_dev, int group)
 
 		for (slot = 0; slot < TPD_MAXIOV; ++slot) {
 			if (tpd->iovec[slot].addr)
-				pci_unmap_single(he_dev->pci_dev,
+				dma_unmap_single(&he_dev->pci_dev->dev,
 					tpd->iovec[slot].addr,
 					tpd->iovec[slot].len & TPD_LEN_MASK,
-							PCI_DMA_TODEVICE);
+							DMA_TO_DEVICE);
 			if (tpd->iovec[slot].len & TPD_LST)
 				break;
 				
@@ -1861,7 +1864,7 @@ he_service_tbrq(struct he_dev *he_dev, int group)
 
 next_tbrq_entry:
 		if (tpd)
-			pci_pool_free(he_dev->tpd_pool, tpd, TPD_ADDR(tpd->status));
+			dma_pool_free(he_dev->tpd_pool, tpd, TPD_ADDR(tpd->status));
 		he_dev->tbrq_head = (struct he_tbrq *)
 				((unsigned long) he_dev->tbrq_base |
 					TBRQ_MASK(he_dev->tbrq_head + 1));
@@ -1905,7 +1908,7 @@ he_service_rbpl(struct he_dev *he_dev, int group)
 		}
 		he_dev->rbpl_hint = i + 1;
 
-		heb = pci_pool_alloc(he_dev->rbpl_pool, GFP_ATOMIC|GFP_DMA, &mapping);
+		heb = dma_pool_alloc(he_dev->rbpl_pool, GFP_ATOMIC, &mapping);
 		if (!heb)
 			break;
 		heb->mapping = mapping;
@@ -2084,10 +2087,10 @@ __enqueue_tpd(struct he_dev *he_dev, struct he_tpd *tpd, unsigned cid)
 			 */
 			for (slot = 0; slot < TPD_MAXIOV; ++slot) {
 				if (tpd->iovec[slot].addr)
-					pci_unmap_single(he_dev->pci_dev,
+					dma_unmap_single(&he_dev->pci_dev->dev,
 						tpd->iovec[slot].addr,
 						tpd->iovec[slot].len & TPD_LEN_MASK,
-								PCI_DMA_TODEVICE);
+								DMA_TO_DEVICE);
 			}
 			if (tpd->skb) {
 				if (tpd->vcc->pop)
@@ -2096,7 +2099,7 @@ __enqueue_tpd(struct he_dev *he_dev, struct he_tpd *tpd, unsigned cid)
 					dev_kfree_skb_any(tpd->skb);
 				atomic_inc(&tpd->vcc->stats->tx_err);
 			}
-			pci_pool_free(he_dev->tpd_pool, tpd, TPD_ADDR(tpd->status));
+			dma_pool_free(he_dev->tpd_pool, tpd, TPD_ADDR(tpd->status));
 			return;
 		}
 	}
@@ -2550,8 +2553,8 @@ he_send(struct atm_vcc *vcc, struct sk_buff *skb)
 	}
 
 #ifdef USE_SCATTERGATHER
-	tpd->iovec[slot].addr = pci_map_single(he_dev->pci_dev, skb->data,
-				skb_headlen(skb), PCI_DMA_TODEVICE);
+	tpd->iovec[slot].addr = dma_map_single(&he_dev->pci_dev->dev, skb->data,
+				skb_headlen(skb), DMA_TO_DEVICE);
 	tpd->iovec[slot].len = skb_headlen(skb);
 	++slot;
 
@@ -2579,9 +2582,9 @@ he_send(struct atm_vcc *vcc, struct sk_buff *skb)
 			slot = 0;
 		}
 
-		tpd->iovec[slot].addr = pci_map_single(he_dev->pci_dev,
+		tpd->iovec[slot].addr = dma_map_single(&he_dev->pci_dev->dev,
 			(void *) page_address(frag->page) + frag->page_offset,
-				frag->size, PCI_DMA_TODEVICE);
+				frag->size, DMA_TO_DEVICE);
 		tpd->iovec[slot].len = frag->size;
 		++slot;
 
@@ -2589,7 +2592,7 @@ he_send(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	tpd->iovec[slot - 1].len |= TPD_LST;
 #else
-	tpd->address0 = pci_map_single(he_dev->pci_dev, skb->data, skb->len, PCI_DMA_TODEVICE);
+	tpd->address0 = dma_map_single(&he_dev->pci_dev->dev, skb->data, skb->len, DMA_TO_DEVICE);
 	tpd->length0 = skb->len | TPD_LST;
 #endif
 	tpd->status |= TPD_INT;
diff --git a/drivers/atm/he.h b/drivers/atm/he.h
index 110a27d..f3f5367 100644
--- a/drivers/atm/he.h
+++ b/drivers/atm/he.h
@@ -281,7 +281,7 @@ struct he_dev {
 	int irq_peak;
 
 	struct tasklet_struct tasklet;
-	struct pci_pool *tpd_pool;
+	struct dma_pool *tpd_pool;
 	struct list_head outstanding_tpds;
 
 	dma_addr_t tpdrq_phys;
@@ -296,7 +296,7 @@ struct he_dev {
 	struct he_buff **rbpl_virt;
 	unsigned long *rbpl_table;
 	unsigned long rbpl_hint;
-	struct pci_pool *rbpl_pool;
+	struct dma_pool *rbpl_pool;
 	dma_addr_t rbpl_phys;
 	struct he_rbp *rbpl_base, *rbpl_tail;
 	struct list_head rbpl_outstanding;
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 2b24ed0..074616b 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -641,7 +641,8 @@ alloc_scq(struct idt77252_dev *card, int class)
 	scq = kzalloc(sizeof(struct scq_info), GFP_KERNEL);
 	if (!scq)
 		return NULL;
-	scq->base = pci_zalloc_consistent(card->pcidev, SCQ_SIZE, &scq->paddr);
+	scq->base = dma_zalloc_coherent(&card->pcidev->dev, SCQ_SIZE,
+					&scq->paddr, GFP_KERNEL);
 	if (scq->base == NULL) {
 		kfree(scq);
 		return NULL;
@@ -669,12 +670,12 @@ free_scq(struct idt77252_dev *card, struct scq_info *scq)
 	struct sk_buff *skb;
 	struct atm_vcc *vcc;
 
-	pci_free_consistent(card->pcidev, SCQ_SIZE,
-			    scq->base, scq->paddr);
+	dma_free_coherent(&card->pcidev->dev, SCQ_SIZE,
+			  scq->base, scq->paddr);
 
 	while ((skb = skb_dequeue(&scq->transmit))) {
-		pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
-				 skb->len, PCI_DMA_TODEVICE);
+		dma_unmap_single(&card->pcidev->dev, IDT77252_PRV_PADDR(skb),
+				 skb->len, DMA_TO_DEVICE);
 
 		vcc = ATM_SKB(skb)->vcc;
 		if (vcc->pop)
@@ -684,8 +685,8 @@ free_scq(struct idt77252_dev *card, struct scq_info *scq)
 	}
 
 	while ((skb = skb_dequeue(&scq->pending))) {
-		pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
-				 skb->len, PCI_DMA_TODEVICE);
+		dma_unmap_single(&card->pcidev->dev, IDT77252_PRV_PADDR(skb),
+				 skb->len, DMA_TO_DEVICE);
 
 		vcc = ATM_SKB(skb)->vcc;
 		if (vcc->pop)
@@ -800,8 +801,8 @@ drain_scq(struct idt77252_dev *card, struct vc_map *vc)
 	if (skb) {
 		TXPRINTK("%s: freeing skb at %p.\n", card->name, skb);
 
-		pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
-				 skb->len, PCI_DMA_TODEVICE);
+		dma_unmap_single(&card->pcidev->dev, IDT77252_PRV_PADDR(skb),
+				 skb->len, DMA_TO_DEVICE);
 
 		vcc = ATM_SKB(skb)->vcc;
 
@@ -846,8 +847,8 @@ queue_skb(struct idt77252_dev *card, struct vc_map *vc,
 	tbd = &IDT77252_PRV_TBD(skb);
 	vcc = ATM_SKB(skb)->vcc;
 
-	IDT77252_PRV_PADDR(skb) = pci_map_single(card->pcidev, skb->data,
-						 skb->len, PCI_DMA_TODEVICE);
+	IDT77252_PRV_PADDR(skb) = dma_map_single(&card->pcidev->dev, skb->data,
+						 skb->len, DMA_TO_DEVICE);
 
 	error = -EINVAL;
 
@@ -924,8 +925,8 @@ done:
 	return 0;
 
 errout:
-	pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
-			 skb->len, PCI_DMA_TODEVICE);
+	dma_unmap_single(&card->pcidev->dev, IDT77252_PRV_PADDR(skb),
+			 skb->len, DMA_TO_DEVICE);
 	return error;
 }
 
@@ -970,8 +971,8 @@ init_rsq(struct idt77252_dev *card)
 {
 	struct rsq_entry *rsqe;
 
-	card->rsq.base = pci_zalloc_consistent(card->pcidev, RSQSIZE,
-					       &card->rsq.paddr);
+	card->rsq.base = dma_zalloc_coherent(&card->pcidev->dev, RSQSIZE,
+					     &card->rsq.paddr, GFP_KERNEL);
 	if (card->rsq.base == NULL) {
 		printk("%s: can't allocate RSQ.\n", card->name);
 		return -1;
@@ -1001,8 +1002,8 @@ init_rsq(struct idt77252_dev *card)
 static void
 deinit_rsq(struct idt77252_dev *card)
 {
-	pci_free_consistent(card->pcidev, RSQSIZE,
-			    card->rsq.base, card->rsq.paddr);
+	dma_free_coherent(&card->pcidev->dev, RSQSIZE,
+			  card->rsq.base, card->rsq.paddr);
 }
 
 static void
@@ -1057,9 +1058,9 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 
 	vcc = vc->rx_vcc;
 
-	pci_dma_sync_single_for_cpu(card->pcidev, IDT77252_PRV_PADDR(skb),
-				    skb_end_pointer(skb) - skb->data,
-				    PCI_DMA_FROMDEVICE);
+	dma_sync_single_for_cpu(&card->pcidev->dev, IDT77252_PRV_PADDR(skb),
+				skb_end_pointer(skb) - skb->data,
+				DMA_FROM_DEVICE);
 
 	if ((vcc->qos.aal == ATM_AAL0) ||
 	    (vcc->qos.aal == ATM_AAL34)) {
@@ -1180,9 +1181,9 @@ dequeue_rx(struct idt77252_dev *card, struct rsq_entry *rsqe)
 			return;
 		}
 
-		pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
+		dma_unmap_single(&card->pcidev->dev, IDT77252_PRV_PADDR(skb),
 				 skb_end_pointer(skb) - skb->data,
-				 PCI_DMA_FROMDEVICE);
+				 DMA_FROM_DEVICE);
 		sb_pool_remove(card, skb);
 
 		skb_trim(skb, len);
@@ -1254,9 +1255,9 @@ idt77252_rx_raw(struct idt77252_dev *card)
 	head = IDT77252_PRV_PADDR(queue) + (queue->data - queue->head - 16);
 	tail = readl(SAR_REG_RAWCT);
 
-	pci_dma_sync_single_for_cpu(card->pcidev, IDT77252_PRV_PADDR(queue),
-				    skb_end_offset(queue) - 16,
-				    PCI_DMA_FROMDEVICE);
+	dma_sync_single_for_cpu(&card->pcidev->dev, IDT77252_PRV_PADDR(queue),
+				skb_end_offset(queue) - 16,
+				DMA_FROM_DEVICE);
 
 	while (head != tail) {
 		unsigned int vpi, vci;
@@ -1348,11 +1349,11 @@ drop:
 			if (next) {
 				card->raw_cell_head = next;
 				queue = card->raw_cell_head;
-				pci_dma_sync_single_for_cpu(card->pcidev,
-							    IDT77252_PRV_PADDR(queue),
-							    (skb_end_pointer(queue) -
-							     queue->data),
-							    PCI_DMA_FROMDEVICE);
+				dma_sync_single_for_cpu(&card->pcidev->dev,
+							IDT77252_PRV_PADDR(queue),
+							(skb_end_pointer(queue) -
+							 queue->data),
+							DMA_FROM_DEVICE);
 			} else {
 				card->raw_cell_head = NULL;
 				printk("%s: raw cell queue overrun\n",
@@ -1375,8 +1376,8 @@ init_tsq(struct idt77252_dev *card)
 {
 	struct tsq_entry *tsqe;
 
-	card->tsq.base = pci_alloc_consistent(card->pcidev, RSQSIZE,
-					      &card->tsq.paddr);
+	card->tsq.base = dma_alloc_coherent(&card->pcidev->dev, RSQSIZE,
+					    &card->tsq.paddr, GFP_KERNEL);
 	if (card->tsq.base == NULL) {
 		printk("%s: can't allocate TSQ.\n", card->name);
 		return -1;
@@ -1398,8 +1399,8 @@ init_tsq(struct idt77252_dev *card)
 static void
 deinit_tsq(struct idt77252_dev *card)
 {
-	pci_free_consistent(card->pcidev, TSQSIZE,
-			    card->tsq.base, card->tsq.paddr);
+	dma_free_coherent(&card->pcidev->dev, TSQSIZE,
+			  card->tsq.base, card->tsq.paddr);
 }
 
 static void
@@ -1861,9 +1862,9 @@ add_rx_skb(struct idt77252_dev *card, int queue,
 			goto outfree;
 		}
 
-		paddr = pci_map_single(card->pcidev, skb->data,
+		paddr = dma_map_single(&card->pcidev->dev, skb->data,
 				       skb_end_pointer(skb) - skb->data,
-				       PCI_DMA_FROMDEVICE);
+				       DMA_FROM_DEVICE);
 		IDT77252_PRV_PADDR(skb) = paddr;
 
 		if (push_rx_skb(card, skb, queue)) {
@@ -1875,8 +1876,8 @@ add_rx_skb(struct idt77252_dev *card, int queue,
 	return;
 
 outunmap:
-	pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
-			 skb_end_pointer(skb) - skb->data, PCI_DMA_FROMDEVICE);
+	dma_unmap_single(&card->pcidev->dev, IDT77252_PRV_PADDR(skb),
+			 skb_end_pointer(skb) - skb->data, DMA_FROM_DEVICE);
 
 	handle = IDT77252_PRV_POOL(skb);
 	card->sbpool[POOL_QUEUE(handle)].skb[POOL_INDEX(handle)] = NULL;
@@ -1892,15 +1893,15 @@ recycle_rx_skb(struct idt77252_dev *card, struct sk_buff *skb)
 	u32 handle = IDT77252_PRV_POOL(skb);
 	int err;
 
-	pci_dma_sync_single_for_device(card->pcidev, IDT77252_PRV_PADDR(skb),
-				       skb_end_pointer(skb) - skb->data,
-				       PCI_DMA_FROMDEVICE);
+	dma_sync_single_for_device(&card->pcidev->dev, IDT77252_PRV_PADDR(skb),
+				   skb_end_pointer(skb) - skb->data,
+				   DMA_FROM_DEVICE);
 
 	err = push_rx_skb(card, skb, POOL_QUEUE(handle));
 	if (err) {
-		pci_unmap_single(card->pcidev, IDT77252_PRV_PADDR(skb),
+		dma_unmap_single(&card->pcidev->dev, IDT77252_PRV_PADDR(skb),
 				 skb_end_pointer(skb) - skb->data,
-				 PCI_DMA_FROMDEVICE);
+				 DMA_FROM_DEVICE);
 		sb_pool_remove(card, skb);
 		dev_kfree_skb(skb);
 	}
@@ -3058,11 +3059,11 @@ deinit_card(struct idt77252_dev *card)
 		for (j = 0; j < FBQ_SIZE; j++) {
 			skb = card->sbpool[i].skb[j];
 			if (skb) {
-				pci_unmap_single(card->pcidev,
+				dma_unmap_single(&card->pcidev->dev,
 						 IDT77252_PRV_PADDR(skb),
 						 (skb_end_pointer(skb) -
 						  skb->data),
-						 PCI_DMA_FROMDEVICE);
+						 DMA_FROM_DEVICE);
 				card->sbpool[i].skb[j] = NULL;
 				dev_kfree_skb(skb);
 			}
@@ -3076,8 +3077,8 @@ deinit_card(struct idt77252_dev *card)
 	vfree(card->vcs);
 
 	if (card->raw_cell_hnd) {
-		pci_free_consistent(card->pcidev, 2 * sizeof(u32),
-				    card->raw_cell_hnd, card->raw_cell_paddr);
+		dma_free_coherent(&card->pcidev->dev, 2 * sizeof(u32),
+				  card->raw_cell_hnd, card->raw_cell_paddr);
 	}
 
 	if (card->rsq.base) {
@@ -3397,9 +3398,10 @@ static int init_card(struct atm_dev *dev)
 	writel(0, SAR_REG_GP);
 
 	/* Initialize RAW Cell Handle Register  */
-	card->raw_cell_hnd = pci_zalloc_consistent(card->pcidev,
-						   2 * sizeof(u32),
-						   &card->raw_cell_paddr);
+	card->raw_cell_hnd = dma_zalloc_coherent(&card->pcidev->dev,
+						 2 * sizeof(u32),
+						 &card->raw_cell_paddr,
+						 GFP_KERNEL);
 	if (!card->raw_cell_hnd) {
 		printk("%s: memory allocation failure.\n", card->name);
 		deinit_card(card);
@@ -3611,6 +3613,11 @@ static int idt77252_init_one(struct pci_dev *pcidev,
 		return err;
 	}
 
+	if ((err = dma_set_mask_and_coherent(&pcidev->dev, DMA_BIT_MASK(32)))) {
+		printk("idt77252: can't enable DMA for PCI device at %s\n", pci_name(pcidev));
+		return err;
+	}
+
 	card = kzalloc(sizeof(struct idt77252_dev), GFP_KERNEL);
 	if (!card) {
 		printk("idt77252-%d: can't allocate private data\n", index);
diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 4217f29..924f8e2 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -1185,8 +1185,8 @@ static int rx_pkt(struct atm_dev *dev)
 
 	/* Build the DLE structure */  
 	wr_ptr = iadev->rx_dle_q.write;  
-	wr_ptr->sys_pkt_addr = pci_map_single(iadev->pci, skb->data,
-		len, PCI_DMA_FROMDEVICE);
+	wr_ptr->sys_pkt_addr = dma_map_single(&iadev->pci->dev, skb->data,
+					      len, DMA_FROM_DEVICE);
 	wr_ptr->local_pkt_addr = buf_addr;  
 	wr_ptr->bytes = len;	/* We don't know this do we ?? */  
 	wr_ptr->mode = DMA_INT_ENABLE;  
@@ -1306,8 +1306,8 @@ static void rx_dle_intr(struct atm_dev *dev)
           u_short length;
           struct ia_vcc *ia_vcc;
 
-	  pci_unmap_single(iadev->pci, iadev->rx_dle_q.write->sys_pkt_addr,
-	  	len, PCI_DMA_FROMDEVICE);
+	  dma_unmap_single(&iadev->pci->dev, iadev->rx_dle_q.write->sys_pkt_addr,
+			   len, DMA_FROM_DEVICE);
           /* no VCC related housekeeping done as yet. lets see */  
           vcc = ATM_SKB(skb)->vcc;
 	  if (!vcc) {
@@ -1430,8 +1430,8 @@ static int rx_init(struct atm_dev *dev)
   //    spin_lock_init(&iadev->rx_lock); 
   
 	/* Allocate 4k bytes - more aligned than needed (4k boundary) */
-	dle_addr = pci_alloc_consistent(iadev->pci, DLE_TOTAL_SIZE,
-					&iadev->rx_dle_dma);  
+	dle_addr = dma_alloc_coherent(&iadev->pci->dev, DLE_TOTAL_SIZE,
+				      &iadev->rx_dle_dma, GFP_KERNEL);
 	if (!dle_addr)  {  
 		printk(KERN_ERR DEV_LABEL "can't allocate DLEs\n");
 		goto err_out;
@@ -1631,8 +1631,8 @@ static int rx_init(struct atm_dev *dev)
 	return 0;  
 
 err_free_dle:
-	pci_free_consistent(iadev->pci, DLE_TOTAL_SIZE, iadev->rx_dle_q.start,
-			    iadev->rx_dle_dma);  
+	dma_free_coherent(&iadev->pci->dev, DLE_TOTAL_SIZE, iadev->rx_dle_q.start,
+			  iadev->rx_dle_dma);
 err_out:
 	return -ENOMEM;
 }  
@@ -1702,8 +1702,8 @@ static void tx_dle_intr(struct atm_dev *dev)
 
 	    /* Revenge of the 2 dle (skb + trailer) used in ia_pkt_tx() */
 	    if (!((dle - iadev->tx_dle_q.start)%(2*sizeof(struct dle)))) {
-		pci_unmap_single(iadev->pci, dle->sys_pkt_addr, skb->len,
-				 PCI_DMA_TODEVICE);
+		dma_unmap_single(&iadev->pci->dev, dle->sys_pkt_addr, skb->len,
+				 DMA_TO_DEVICE);
 	    }
             vcc = ATM_SKB(skb)->vcc;
             if (!vcc) {
@@ -1917,8 +1917,8 @@ static int tx_init(struct atm_dev *dev)
                                 readw(iadev->seg_reg+SEG_MASK_REG));)  
 
 	/* Allocate 4k (boundary aligned) bytes */
-	dle_addr = pci_alloc_consistent(iadev->pci, DLE_TOTAL_SIZE,
-					&iadev->tx_dle_dma);  
+	dle_addr = dma_alloc_coherent(&iadev->pci->dev, DLE_TOTAL_SIZE,
+				      &iadev->tx_dle_dma, GFP_KERNEL);
 	if (!dle_addr)  {
 		printk(KERN_ERR DEV_LABEL "can't allocate DLEs\n");
 		goto err_out;
@@ -1989,8 +1989,10 @@ static int tx_init(struct atm_dev *dev)
 		goto err_free_tx_bufs;
             }
 	    iadev->tx_buf[i].cpcs = cpcs;
-	    iadev->tx_buf[i].dma_addr = pci_map_single(iadev->pci,
-		cpcs, sizeof(*cpcs), PCI_DMA_TODEVICE);
+	    iadev->tx_buf[i].dma_addr = dma_map_single(&iadev->pci->dev,
+						       cpcs,
+						       sizeof(*cpcs),
+						       DMA_TO_DEVICE);
         }
         iadev->desc_tbl = kmalloc(iadev->num_tx_desc *
                                    sizeof(struct desc_tbl_t), GFP_KERNEL);
@@ -2198,14 +2200,14 @@ err_free_tx_bufs:
 	while (--i >= 0) {
 		struct cpcs_trailer_desc *desc = iadev->tx_buf + i;
 
-		pci_unmap_single(iadev->pci, desc->dma_addr,
-			sizeof(*desc->cpcs), PCI_DMA_TODEVICE);
+		dma_unmap_single(&iadev->pci->dev, desc->dma_addr,
+				 sizeof(*desc->cpcs), DMA_TO_DEVICE);
 		kfree(desc->cpcs);
 	}
 	kfree(iadev->tx_buf);
 err_free_dle:
-	pci_free_consistent(iadev->pci, DLE_TOTAL_SIZE, iadev->tx_dle_q.start,
-			    iadev->tx_dle_dma);  
+	dma_free_coherent(&iadev->pci->dev, DLE_TOTAL_SIZE, iadev->tx_dle_q.start,
+			  iadev->tx_dle_dma);
 err_out:
 	return -ENOMEM;
 }   
@@ -2476,20 +2478,20 @@ static void ia_free_tx(IADEV *iadev)
 	for (i = 0; i < iadev->num_tx_desc; i++) {
 		struct cpcs_trailer_desc *desc = iadev->tx_buf + i;
 
-		pci_unmap_single(iadev->pci, desc->dma_addr,
-			sizeof(*desc->cpcs), PCI_DMA_TODEVICE);
+		dma_unmap_single(&iadev->pci->dev, desc->dma_addr,
+				 sizeof(*desc->cpcs), DMA_TO_DEVICE);
 		kfree(desc->cpcs);
 	}
 	kfree(iadev->tx_buf);
-	pci_free_consistent(iadev->pci, DLE_TOTAL_SIZE, iadev->tx_dle_q.start,
-			    iadev->tx_dle_dma);  
+	dma_free_coherent(&iadev->pci->dev, DLE_TOTAL_SIZE, iadev->tx_dle_q.start,
+			  iadev->tx_dle_dma);
 }
 
 static void ia_free_rx(IADEV *iadev)
 {
 	kfree(iadev->rx_open);
-	pci_free_consistent(iadev->pci, DLE_TOTAL_SIZE, iadev->rx_dle_q.start,
-			  iadev->rx_dle_dma);  
+	dma_free_coherent(&iadev->pci->dev, DLE_TOTAL_SIZE, iadev->rx_dle_q.start,
+			  iadev->rx_dle_dma);
 }
 
 static int ia_start(struct atm_dev *dev)
@@ -3009,8 +3011,8 @@ static int ia_pkt_tx (struct atm_vcc *vcc, struct sk_buff *skb) {
 	/* Build the DLE structure */  
 	wr_ptr = iadev->tx_dle_q.write;  
 	memset((caddr_t)wr_ptr, 0, sizeof(*wr_ptr));  
-	wr_ptr->sys_pkt_addr = pci_map_single(iadev->pci, skb->data,
-		skb->len, PCI_DMA_TODEVICE);
+	wr_ptr->sys_pkt_addr = dma_map_single(&iadev->pci->dev, skb->data,
+					      skb->len, DMA_TO_DEVICE);
 	wr_ptr->local_pkt_addr = (buf_desc_ptr->buf_start_hi << 16) | 
                                                   buf_desc_ptr->buf_start_lo;  
 	/* wr_ptr->bytes = swap_byte_order(total_len); didn't seem to affect?? */
diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 93eaf8d..02fae18 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -346,7 +346,8 @@ static void lanai_buf_allocate(struct lanai_buffer *buf,
 		 * everything, but the way the lanai uses DMA memory would
 		 * make that a terrific pain.  This is much simpler.
 		 */
-		buf->start = pci_alloc_consistent(pci, size, &buf->dmaaddr);
+		buf->start = dma_alloc_coherent(&pci->dev,
+						size, &buf->dmaaddr, GFP_KERNEL);
 		if (buf->start != NULL) {	/* Success */
 			/* Lanai requires 256-byte alignment of DMA bufs */
 			APRINTK((buf->dmaaddr & ~0xFFFFFF00) == 0,
@@ -372,8 +373,8 @@ static void lanai_buf_deallocate(struct lanai_buffer *buf,
 	struct pci_dev *pci)
 {
 	if (buf->start != NULL) {
-		pci_free_consistent(pci, lanai_buf_size(buf),
-		    buf->start, buf->dmaaddr);
+		dma_free_coherent(&pci->dev, lanai_buf_size(buf),
+				  buf->start, buf->dmaaddr);
 		buf->start = buf->end = buf->ptr = NULL;
 	}
 }
@@ -1953,12 +1954,7 @@ static int lanai_pci_start(struct lanai_dev *lanai)
 		return -ENXIO;
 	}
 	pci_set_master(pci);
-	if (pci_set_dma_mask(pci, DMA_BIT_MASK(32)) != 0) {
-		printk(KERN_WARNING DEV_LABEL
-		    "(itf %d): No suitable DMA available.\n", lanai->number);
-		return -EBUSY;
-	}
-	if (pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(32)) != 0) {
+	if (dma_set_mask_and_coherent(&pci->dev, DMA_BIT_MASK(32)) != 0) {
 		printk(KERN_WARNING DEV_LABEL
 		    "(itf %d): No suitable DMA available.\n", lanai->number);
 		return -EBUSY;
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 9988ac9..b7e1cc0 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -252,10 +252,10 @@ static void nicstar_remove_one(struct pci_dev *pcidev)
 			free_scq(card, card->scd2vc[j]->scq, card->scd2vc[j]->tx_vcc);
 	}
 	idr_destroy(&card->idr);
-	pci_free_consistent(card->pcidev, NS_RSQSIZE + NS_RSQ_ALIGNMENT,
-			    card->rsq.org, card->rsq.dma);
-	pci_free_consistent(card->pcidev, NS_TSQSIZE + NS_TSQ_ALIGNMENT,
-			    card->tsq.org, card->tsq.dma);
+	dma_free_coherent(&card->pcidev->dev, NS_RSQSIZE + NS_RSQ_ALIGNMENT,
+			  card->rsq.org, card->rsq.dma);
+	dma_free_coherent(&card->pcidev->dev, NS_TSQSIZE + NS_TSQ_ALIGNMENT,
+			  card->tsq.org, card->tsq.dma);
 	free_irq(card->pcidev->irq, card);
 	iounmap(card->membase);
 	kfree(card);
@@ -370,8 +370,7 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 		ns_init_card_error(card, error);
 		return error;
 	}
-        if ((pci_set_dma_mask(pcidev, DMA_BIT_MASK(32)) != 0) ||
-	    (pci_set_consistent_dma_mask(pcidev, DMA_BIT_MASK(32)) != 0)) {
+        if (dma_set_mask_and_coherent(&pcidev->dev, DMA_BIT_MASK(32)) != 0) {
                 printk(KERN_WARNING
 		       "nicstar%d: No suitable DMA available.\n", i);
 		error = 2;
@@ -535,9 +534,9 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 	writel(0x00000000, card->membase + VPM);
 
 	/* Initialize TSQ */
-	card->tsq.org = pci_alloc_consistent(card->pcidev,
-					     NS_TSQSIZE + NS_TSQ_ALIGNMENT,
-					     &card->tsq.dma);
+	card->tsq.org = dma_alloc_coherent(&card->pcidev->dev,
+					   NS_TSQSIZE + NS_TSQ_ALIGNMENT,
+					   &card->tsq.dma, GFP_KERNEL);
 	if (card->tsq.org == NULL) {
 		printk("nicstar%d: can't allocate TSQ.\n", i);
 		error = 10;
@@ -554,9 +553,9 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 	PRINTK("nicstar%d: TSQ base at 0x%p.\n", i, card->tsq.base);
 
 	/* Initialize RSQ */
-	card->rsq.org = pci_alloc_consistent(card->pcidev,
-					     NS_RSQSIZE + NS_RSQ_ALIGNMENT,
-					     &card->rsq.dma);
+	card->rsq.org = dma_alloc_coherent(&card->pcidev->dev,
+					   NS_RSQSIZE + NS_RSQ_ALIGNMENT,
+					   &card->rsq.dma, GFP_KERNEL);
 	if (card->rsq.org == NULL) {
 		printk("nicstar%d: can't allocate RSQ.\n", i);
 		error = 11;
@@ -874,7 +873,8 @@ static scq_info *get_scq(ns_dev *card, int size, u32 scd)
 	scq = kmalloc(sizeof(scq_info), GFP_KERNEL);
 	if (!scq)
 		return NULL;
-        scq->org = pci_alloc_consistent(card->pcidev, 2 * size, &scq->dma);
+        scq->org = dma_alloc_coherent(&card->pcidev->dev,
+				      2 * size,  &scq->dma, GFP_KERNEL);
 	if (!scq->org) {
 		kfree(scq);
 		return NULL;
@@ -936,10 +936,10 @@ static void free_scq(ns_dev *card, scq_info *scq, struct atm_vcc *vcc)
 			}
 	}
 	kfree(scq->skb);
-	pci_free_consistent(card->pcidev,
-			    2 * (scq->num_entries == VBR_SCQ_NUM_ENTRIES ?
-				 VBR_SCQSIZE : CBR_SCQSIZE),
-			    scq->org, scq->dma);
+	dma_free_coherent(&card->pcidev->dev,
+			  2 * (scq->num_entries == VBR_SCQ_NUM_ENTRIES ?
+			       VBR_SCQSIZE : CBR_SCQSIZE),
+			  scq->org, scq->dma);
 	kfree(scq);
 }
 
@@ -957,11 +957,11 @@ static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
 	handle2 = NULL;
 	addr2 = 0;
 	handle1 = skb;
-	addr1 = pci_map_single(card->pcidev,
+	addr1 = dma_map_single(&card->pcidev->dev,
 			       skb->data,
 			       (NS_PRV_BUFTYPE(skb) == BUF_SM
 				? NS_SMSKBSIZE : NS_LGSKBSIZE),
-			       PCI_DMA_TODEVICE);
+			       DMA_TO_DEVICE);
 	NS_PRV_DMA(skb) = addr1; /* save so we can unmap later */
 
 #ifdef GENERAL_DEBUG
@@ -1670,8 +1670,8 @@ static int ns_send(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	ATM_SKB(skb)->vcc = vcc;
 
-	NS_PRV_DMA(skb) = pci_map_single(card->pcidev, skb->data,
-					 skb->len, PCI_DMA_TODEVICE);
+	NS_PRV_DMA(skb) = dma_map_single(&card->pcidev->dev, skb->data,
+					 skb->len, DMA_TO_DEVICE);
 
 	if (vcc->qos.aal == ATM_AAL5) {
 		buflen = (skb->len + 47 + 8) / 48 * 48;	/* Multiple of 48 */
@@ -1930,10 +1930,10 @@ static void drain_scq(ns_dev * card, scq_info * scq, int pos)
 		XPRINTK("nicstar%d: freeing skb at 0x%p (index %d).\n",
 			card->index, skb, i);
 		if (skb != NULL) {
-			pci_unmap_single(card->pcidev,
+			dma_unmap_single(&card->pcidev->dev,
 					 NS_PRV_DMA(skb),
 					 skb->len,
-					 PCI_DMA_TODEVICE);
+					 DMA_TO_DEVICE);
 			vcc = ATM_SKB(skb)->vcc;
 			if (vcc && vcc->pop != NULL) {
 				vcc->pop(vcc, skb);
@@ -1992,16 +1992,16 @@ static void dequeue_rx(ns_dev * card, ns_rsqe * rsqe)
 		return;
 	}
 	idr_remove(&card->idr, id);
-        pci_dma_sync_single_for_cpu(card->pcidev,
-				    NS_PRV_DMA(skb),
-				    (NS_PRV_BUFTYPE(skb) == BUF_SM
-				     ? NS_SMSKBSIZE : NS_LGSKBSIZE),
-				    PCI_DMA_FROMDEVICE);
-	pci_unmap_single(card->pcidev,
+	dma_sync_single_for_cpu(&card->pcidev->dev,
+				NS_PRV_DMA(skb),
+				(NS_PRV_BUFTYPE(skb) == BUF_SM
+				 ? NS_SMSKBSIZE : NS_LGSKBSIZE),
+				DMA_FROM_DEVICE);
+	dma_unmap_single(&card->pcidev->dev,
 			 NS_PRV_DMA(skb),
 			 (NS_PRV_BUFTYPE(skb) == BUF_SM
 			  ? NS_SMSKBSIZE : NS_LGSKBSIZE),
-			 PCI_DMA_FROMDEVICE);
+			 DMA_FROM_DEVICE);
 	vpi = ns_rsqe_vpi(rsqe);
 	vci = ns_rsqe_vci(rsqe);
 	if (vpi >= 1UL << card->vpibits || vci >= 1UL << card->vcibits) {
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 21b0bc6..74e18b0 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -785,8 +785,8 @@ static void solos_bh(unsigned long card_arg)
 				skb = card->rx_skb[port];
 				card->rx_skb[port] = NULL;
 
-				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr,
-						 RX_DMA_SIZE, PCI_DMA_FROMDEVICE);
+				dma_unmap_single(&card->dev->dev, SKB_CB(skb)->dma_addr,
+						 RX_DMA_SIZE, DMA_FROM_DEVICE);
 
 				header = (void *)skb->data;
 				size = le16_to_cpu(header->size);
@@ -872,8 +872,8 @@ static void solos_bh(unsigned long card_arg)
 			struct sk_buff *skb = alloc_skb(RX_DMA_SIZE, GFP_ATOMIC);
 			if (skb) {
 				SKB_CB(skb)->dma_addr =
-					pci_map_single(card->dev, skb->data,
-						       RX_DMA_SIZE, PCI_DMA_FROMDEVICE);
+					dma_map_single(&card->dev->dev, skb->data,
+						       RX_DMA_SIZE, DMA_FROM_DEVICE);
 				iowrite32(SKB_CB(skb)->dma_addr,
 					  card->config_regs + RX_DMA_ADDR(port));
 				card->rx_skb[port] = skb;
@@ -1069,8 +1069,8 @@ static uint32_t fpga_tx(struct solos_card *card)
 		if (tx_pending & 1) {
 			struct sk_buff *oldskb = card->tx_skb[port];
 			if (oldskb) {
-				pci_unmap_single(card->dev, SKB_CB(oldskb)->dma_addr,
-						 oldskb->len, PCI_DMA_TODEVICE);
+				dma_unmap_single(&card->dev->dev, SKB_CB(oldskb)->dma_addr,
+						 oldskb->len, DMA_TO_DEVICE);
 				card->tx_skb[port] = NULL;
 			}
 			spin_lock(&card->tx_queue_lock);
@@ -1089,8 +1089,8 @@ static uint32_t fpga_tx(struct solos_card *card)
 					data = card->dma_bounce + (BUF_SIZE * port);
 					memcpy(data, skb->data, skb->len);
 				}
-				SKB_CB(skb)->dma_addr = pci_map_single(card->dev, data,
-								       skb->len, PCI_DMA_TODEVICE);
+				SKB_CB(skb)->dma_addr = dma_map_single(&card->dev->dev, data,
+								       skb->len, DMA_TO_DEVICE);
 				card->tx_skb[port] = skb;
 				iowrite32(SKB_CB(skb)->dma_addr,
 					  card->config_regs + TX_DMA_ADDR(port));
@@ -1210,7 +1210,7 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		goto out;
 	}
 
-	err = pci_set_dma_mask(dev, DMA_BIT_MASK(32));
+	err = dma_set_mask_and_coherent(&dev->dev, DMA_BIT_MASK(32));
 	if (err) {
 		dev_warn(&dev->dev, "Failed to set 32-bit DMA mask\n");
 		goto out;
@@ -1411,14 +1411,14 @@ static void atm_remove(struct solos_card *card)
 
 			skb = card->rx_skb[i];
 			if (skb) {
-				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr,
-						 RX_DMA_SIZE, PCI_DMA_FROMDEVICE);
+				dma_unmap_single(&card->dev->dev, SKB_CB(skb)->dma_addr,
+						 RX_DMA_SIZE, DMA_FROM_DEVICE);
 				dev_kfree_skb(skb);
 			}
 			skb = card->tx_skb[i];
 			if (skb) {
-				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr,
-						 skb->len, PCI_DMA_TODEVICE);
+				dma_unmap_single(&card->dev->dev, SKB_CB(skb)->dma_addr,
+						 skb->len, DMA_TO_DEVICE);
 				dev_kfree_skb(skb);
 			}
 			while ((skb = skb_dequeue(&card->tx_queue[i])))
diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 969c3c2..cecfb94 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1306,19 +1306,20 @@ static int zatm_start(struct atm_dev *dev)
 
 		if (!mbx_entries[i])
 			continue;
-		mbx = pci_alloc_consistent(pdev, 2*MBX_SIZE(i), &mbx_dma);
+		mbx = dma_alloc_coherent(&pdev->dev,
+					 2 * MBX_SIZE(i), &mbx_dma, GFP_KERNEL);
 		if (!mbx) {
 			error = -ENOMEM;
 			goto out;
 		}
 		/*
-		 * Alignment provided by pci_alloc_consistent() isn't enough
+		 * Alignment provided by dma_alloc_coherent() isn't enough
 		 * for this device.
 		 */
 		if (((unsigned long)mbx ^ mbx_dma) & 0xffff) {
 			printk(KERN_ERR DEV_LABEL "(itf %d): system "
 			       "bus incompatible with driver\n", dev->number);
-			pci_free_consistent(pdev, 2*MBX_SIZE(i), mbx, mbx_dma);
+			dma_free_coherent(&pdev->dev, 2*MBX_SIZE(i), mbx, mbx_dma);
 			error = -ENODEV;
 			goto out;
 		}
@@ -1354,9 +1355,9 @@ out_tx:
 	kfree(zatm_dev->tx_map);
 out:
 	while (i-- > 0) {
-		pci_free_consistent(pdev, 2*MBX_SIZE(i), 
-				    (void *)zatm_dev->mbx_start[i],
-				    zatm_dev->mbx_dma[i]);
+		dma_free_coherent(&pdev->dev, 2 * MBX_SIZE(i),
+				  (void *)zatm_dev->mbx_start[i],
+				  zatm_dev->mbx_dma[i]);
 	}
 	free_irq(zatm_dev->irq, dev);
 	goto done;
@@ -1608,6 +1609,10 @@ static int zatm_init_one(struct pci_dev *pci_dev,
 	if (ret < 0)
 		goto out_disable;
 
+	ret = dma_set_mask_and_coherent(&pci_dev->dev, DMA_BIT_MASK(32));
+	if (ret < 0)
+		goto out_disable;
+
 	zatm_dev->pci_dev = pci_dev;
 	dev->dev_data = zatm_dev;
 	zatm_dev->copper = (int)ent->driver_data;
-- 
1.9.3
