From: Quentin Lambert <lambert.quentin@gmail.com>
Subject: [PATCH v2 1/1] atm: remove deprecated use of pci api
Date: Mon, 12 Jan 2015 17:10:42 +0100
Message-ID: <20150112161042.GA11374@sloth>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace occurences of the pci api by appropriate call to the dma api.

A simplified version of the semantic patch that finds this problem is as
follows: (http://coccinelle.lip6.fr)

@deprecated@
idexpression id;
position p;
@@

(
  pci_dma_supported@p ( id, ...)
|
  pci_alloc_consistent@p ( id, ...)
)

@bad1@
idexpression id;
position deprecated.p;
@@
...when != &id->dev
   when != pci_get_drvdata ( id )
   when != pci_enable_device ( id )
(
  pci_dma_supported@p ( id, ...)
|
  pci_alloc_consistent@p ( id, ...)
)

@depends on !bad1@
idexpression id;
expression direction;
position deprecated.p;
@@

(
- pci_dma_supported@p ( id,
+ dma_supported ( &id->dev,
...
+ , GFP_ATOMIC
  )
|
- pci_alloc_consistent@p ( id,
+ dma_alloc_coherent ( &id->dev,
...
+ , GFP_ATOMIC
  )
)

Signed-off-by: Quentin Lambert <lambert.quentin@gmail.com>
---
 drivers/atm/eni.c       | 8 +++++---
 drivers/atm/he.c        | 2 +-
 drivers/atm/lanai.c     | 9 +++++----
 drivers/atm/nicstar.c   | 4 ++--
 drivers/atm/solos-pci.c | 2 +-
 drivers/atm/zatm.c      | 8 +++++---
 6 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index c7fab3e..a128020 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -2246,7 +2246,8 @@ static int eni_init_one(struct pci_dev *pci_dev,
 		goto err_disable;
 
 	zero = &eni_dev->zero;
-	zero->addr = pci_alloc_consistent(pci_dev, ENI_ZEROES_SIZE, &zero->dma);
+	zero->addr = dma_alloc_coherent(&pci_dev->dev, ENI_ZEROES_SIZE,
+					&zero->dma, GFP_ATOMIC);
 	if (!zero->addr)
 		goto err_kfree;
 
@@ -2277,7 +2278,8 @@ err_eni_release:
 err_unregister:
 	atm_dev_deregister(dev);
 err_free_consistent:
-	pci_free_consistent(pci_dev, ENI_ZEROES_SIZE, zero->addr, zero->dma);
+	dma_free_coherent(&pci_dev->dev, ENI_ZEROES_SIZE, zero->addr,
+			  zero->dma);
 err_kfree:
 	kfree(eni_dev);
 err_disable:
@@ -2302,7 +2304,7 @@ static void eni_remove_one(struct pci_dev *pdev)
 
 	eni_do_release(dev);
 	atm_dev_deregister(dev);
-	pci_free_consistent(pdev, ENI_ZEROES_SIZE, zero->addr, zero->dma);
+	dma_free_coherent(&pdev->dev, ENI_ZEROES_SIZE, zero->addr, zero->dma);
 	kfree(ed);
 	pci_disable_device(pdev);
 }
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index c39702b..69a2598 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -359,7 +359,7 @@ static int he_init_one(struct pci_dev *pci_dev,
 
 	if (pci_enable_device(pci_dev))
 		return -EIO;
-	if (pci_set_dma_mask(pci_dev, DMA_BIT_MASK(32)) != 0) {
+	if (dma_set_mask(&pci_dev->dev, DMA_BIT_MASK(32)) != 0) {
 		printk(KERN_WARNING "he: no suitable dma available\n");
 		err = -EIO;
 		goto init_one_failure;
diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 93eaf8d..70fe734 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -346,7 +346,8 @@ static void lanai_buf_allocate(struct lanai_buffer *buf,
 		 * everything, but the way the lanai uses DMA memory would
 		 * make that a terrific pain.  This is much simpler.
 		 */
-		buf->start = pci_alloc_consistent(pci, size, &buf->dmaaddr);
+		buf->start = dma_alloc_coherent(&pci->dev, size, &buf->dmaaddr,
+						GFP_ATOMIC);
 		if (buf->start != NULL) {	/* Success */
 			/* Lanai requires 256-byte alignment of DMA bufs */
 			APRINTK((buf->dmaaddr & ~0xFFFFFF00) == 0,
@@ -372,7 +373,7 @@ static void lanai_buf_deallocate(struct lanai_buffer *buf,
 	struct pci_dev *pci)
 {
 	if (buf->start != NULL) {
-		pci_free_consistent(pci, lanai_buf_size(buf),
+		dma_free_coherent(&pci->dev, lanai_buf_size(buf),
 		    buf->start, buf->dmaaddr);
 		buf->start = buf->end = buf->ptr = NULL;
 	}
@@ -1953,12 +1954,12 @@ static int lanai_pci_start(struct lanai_dev *lanai)
 		return -ENXIO;
 	}
 	pci_set_master(pci);
-	if (pci_set_dma_mask(pci, DMA_BIT_MASK(32)) != 0) {
+	if (dma_set_mask(&pci->dev, DMA_BIT_MASK(32)) != 0) {
 		printk(KERN_WARNING DEV_LABEL
 		    "(itf %d): No suitable DMA available.\n", lanai->number);
 		return -EBUSY;
 	}
-	if (pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(32)) != 0) {
+	if (dma_set_coherent_mask(&pci->dev, DMA_BIT_MASK(32)) != 0) {
 		printk(KERN_WARNING DEV_LABEL
 		    "(itf %d): No suitable DMA available.\n", lanai->number);
 		return -EBUSY;
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 9988ac9..aabb528 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -370,8 +370,8 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 		ns_init_card_error(card, error);
 		return error;
 	}
-        if ((pci_set_dma_mask(pcidev, DMA_BIT_MASK(32)) != 0) ||
-	    (pci_set_consistent_dma_mask(pcidev, DMA_BIT_MASK(32)) != 0)) {
+	if ((dma_set_mask(&pcidev->dev, DMA_BIT_MASK(32)) != 0) ||
+	    (dma_set_coherent_mask(&pcidev->dev, DMA_BIT_MASK(32)) != 0)) {
                 printk(KERN_WARNING
 		       "nicstar%d: No suitable DMA available.\n", i);
 		error = 2;
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 21b0bc6..48531b8 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1210,7 +1210,7 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		goto out;
 	}
 
-	err = pci_set_dma_mask(dev, DMA_BIT_MASK(32));
+	err = dma_set_mask(&dev->dev, DMA_BIT_MASK(32));
 	if (err) {
 		dev_warn(&dev->dev, "Failed to set 32-bit DMA mask\n");
 		goto out;
diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 969c3c2..b6456b1 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1306,7 +1306,8 @@ static int zatm_start(struct atm_dev *dev)
 
 		if (!mbx_entries[i])
 			continue;
-		mbx = pci_alloc_consistent(pdev, 2*MBX_SIZE(i), &mbx_dma);
+		mbx = dma_alloc_coherent(&pdev->dev, 2*MBX_SIZE(i), &mbx_dma,
+					 GFP_ATOMIC);
 		if (!mbx) {
 			error = -ENOMEM;
 			goto out;
@@ -1318,7 +1319,8 @@ static int zatm_start(struct atm_dev *dev)
 		if (((unsigned long)mbx ^ mbx_dma) & 0xffff) {
 			printk(KERN_ERR DEV_LABEL "(itf %d): system "
 			       "bus incompatible with driver\n", dev->number);
-			pci_free_consistent(pdev, 2*MBX_SIZE(i), mbx, mbx_dma);
+			dma_free_coherent(&pdev->dev, 2*MBX_SIZE(i), mbx,
+					  mbx_dma);
 			error = -ENODEV;
 			goto out;
 		}
@@ -1354,7 +1356,7 @@ out_tx:
 	kfree(zatm_dev->tx_map);
 out:
 	while (i-- > 0) {
-		pci_free_consistent(pdev, 2*MBX_SIZE(i), 
+		dma_free_coherent(&pdev->dev, 2*MBX_SIZE(i),
 				    (void *)zatm_dev->mbx_start[i],
 				    zatm_dev->mbx_dma[i]);
 	}
-- 
1.9.1
