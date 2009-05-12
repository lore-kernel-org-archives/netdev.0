From: Dan Williams <dan.j.williams@intel.com>
Subject: [git pull] dmaengine fixes  for 2.6.30-rc
Date: Tue, 12 May 2009 15:06:33 -0700
Message-ID: <1242165993.22595.14.camel@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Maciej Sosnowski <maciej.sosnowski@intel.com>,
	Alexander Beregalov <a.beregalov@gmail.com>,
	netdev@vger.kernel.org,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Agustin <gatoguan-os@yahoo.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51083 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751271AbZELWGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2009 18:06:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus, please pull from:

  git://git.kernel.org/pub/scm/linux/kernel/git/djbw/async_tx.git fixes

...to receive:

Ben Nizette (1):
      ipu_idmac: Use disable_irq_nosync() from within irq handlers.

Dan Williams (1):
      dmatest: fix max channels handling

Guennadi Liakhovetski (1):
      dma: fix ipu_idmac.c to not discard the last queued buffer

Maciej Sosnowski (1):
      ioatdma: fix "ioatdma frees DMA memory with wrong function"

 drivers/dma/dmaengine.c     |   17 ++++++++++-----
 drivers/dma/dmatest.c       |    4 +--
 drivers/dma/ioat_dma.c      |   45 ++++++++++++++++++++++++++----------------
 drivers/dma/ipu/ipu_idmac.c |    7 +++--
 include/linux/dmaengine.h   |    6 +++++
 5 files changed, 50 insertions(+), 29 deletions(-)

This resolves bug #13124 on the regressions list, thanks Alexander for
reporting and testing.  The dmatest fix is tagged for -stable.  The
patches for the ipu_idmac driver have the requisite tested-by's and
acks.

Thanks,
Dan

commit ad567ffb32f067b30606071eb568cf637fe42185
Author: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Date:   Tue May 12 09:16:29 2009 +0200

    dma: fix ipu_idmac.c to not discard the last queued buffer
    
    This also fixes the case of a single queued buffer, for example, when taking a
    single frame snapshot with the mx3_camera driver.
    
    Reported-by: Agustin Ferrin Pozuelo <gatoguan-os@yahoo.com>
    Tested-by: Agustin Ferrin Pozuelo <gatoguan-os@yahoo.com>
    Signed-off-by: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

commit 4f005dbe5584fe54c9f6d6d4f0acd3fb29be84da
Author: Maciej Sosnowski <maciej.sosnowski@intel.com>
Date:   Thu Apr 23 12:31:51 2009 +0200

    ioatdma: fix "ioatdma frees DMA memory with wrong function"
    
    as reported by Alexander Beregalov <a.beregalov@gmail.com>
    
    ioatdma 0000:00:08.0: DMA-API: device driver frees DMA memory with
    wrong function [device address=0x000000007f76f800] [size=2000 bytes]
    [map
    ped as single] [unmapped as page]
    
    The ioatdma driver was unmapping all regions
    (either allocated as page or single) using unmap_page.
    This patch lets dma driver recognize if unmap_single or unmap_page should be used.
    It introduces two new dma control flags:
    DMA_COMPL_SRC_UNMAP_SINGLE and DMA_COMPL_DEST_UNMAP_SINGLE.
    They should be set to indicate dma driver to do dma-unmapping as single
    (first one for the source, tha latter for the destination).
    If respective flag is not set, the driver assumes dma-unmapping as page.
    
    Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
    Reported-by: Alexander Beregalov <a.beregalov@gmail.com>
    Tested-by: Alexander Beregalov <a.beregalov@gmail.com>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

commit ca50a51e890b0a62b44b5642c1ba5049909e5a8b
Author: Ben Nizette <bn@niasdigital.com>
Date:   Thu Apr 16 05:54:12 2009 +1000

    ipu_idmac: Use disable_irq_nosync() from within irq handlers.
    
    disable_irq() should wait for all running handlers to complete
    before returning.  As such, if it's used to disable an interrupt
    from that interrupt's handler it will deadlock.  This replaces
    the dangerous instances with the _nosync() variant which doesn't
    have this problem.
    
    Note the 2 handlers in question are only used #ifdef DEBUG so
    I imagine these code paths don't get hit often.
    
    Signed-off-by: Ben Nizette <bn@niasdigital.com>
    Acked-by: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

commit c56c81abe7e684bc6203632d807303eb765690dc
Author: Dan Williams <dan.j.williams@intel.com>
Date:   Wed Apr 8 15:08:23 2009 -0700

    dmatest: fix max channels handling
    
    The check for reaching max_channels is short circuited by 'continuing'
    after successfully adding a channel.
    
    [ Impact: make the 'max_channels' module parameter actually have an effect ]
    
    Cc: <stable@kernel.org>
    Reported-by: Dan Carpenter <error27@gmail.com>
    Signed-off-by: Dan Williams <dan.j.williams@intel.com>

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 92438e9..5a87384 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -804,11 +804,14 @@ dma_async_memcpy_buf_to_buf(struct dma_chan *chan, void *dest,
 	dma_addr_t dma_dest, dma_src;
 	dma_cookie_t cookie;
 	int cpu;
+	unsigned long flags;
 
 	dma_src = dma_map_single(dev->dev, src, len, DMA_TO_DEVICE);
 	dma_dest = dma_map_single(dev->dev, dest, len, DMA_FROM_DEVICE);
-	tx = dev->device_prep_dma_memcpy(chan, dma_dest, dma_src, len,
-					 DMA_CTRL_ACK);
+	flags = DMA_CTRL_ACK |
+		DMA_COMPL_SRC_UNMAP_SINGLE |
+		DMA_COMPL_DEST_UNMAP_SINGLE;
+	tx = dev->device_prep_dma_memcpy(chan, dma_dest, dma_src, len, flags);
 
 	if (!tx) {
 		dma_unmap_single(dev->dev, dma_src, len, DMA_TO_DEVICE);
@@ -850,11 +853,12 @@ dma_async_memcpy_buf_to_pg(struct dma_chan *chan, struct page *page,
 	dma_addr_t dma_dest, dma_src;
 	dma_cookie_t cookie;
 	int cpu;
+	unsigned long flags;
 
 	dma_src = dma_map_single(dev->dev, kdata, len, DMA_TO_DEVICE);
 	dma_dest = dma_map_page(dev->dev, page, offset, len, DMA_FROM_DEVICE);
-	tx = dev->device_prep_dma_memcpy(chan, dma_dest, dma_src, len,
-					 DMA_CTRL_ACK);
+	flags = DMA_CTRL_ACK | DMA_COMPL_SRC_UNMAP_SINGLE;
+	tx = dev->device_prep_dma_memcpy(chan, dma_dest, dma_src, len, flags);
 
 	if (!tx) {
 		dma_unmap_single(dev->dev, dma_src, len, DMA_TO_DEVICE);
@@ -898,12 +902,13 @@ dma_async_memcpy_pg_to_pg(struct dma_chan *chan, struct page *dest_pg,
 	dma_addr_t dma_dest, dma_src;
 	dma_cookie_t cookie;
 	int cpu;
+	unsigned long flags;
 
 	dma_src = dma_map_page(dev->dev, src_pg, src_off, len, DMA_TO_DEVICE);
 	dma_dest = dma_map_page(dev->dev, dest_pg, dest_off, len,
 				DMA_FROM_DEVICE);
-	tx = dev->device_prep_dma_memcpy(chan, dma_dest, dma_src, len,
-					 DMA_CTRL_ACK);
+	flags = DMA_CTRL_ACK;
+	tx = dev->device_prep_dma_memcpy(chan, dma_dest, dma_src, len, flags);
 
 	if (!tx) {
 		dma_unmap_page(dev->dev, dma_src, len, DMA_TO_DEVICE);
diff --git a/drivers/dma/dmatest.c b/drivers/dma/dmatest.c
index a27c0fb..fb7da51 100644
--- a/drivers/dma/dmatest.c
+++ b/drivers/dma/dmatest.c
@@ -531,9 +531,7 @@ static int __init dmatest_init(void)
 		chan = dma_request_channel(mask, filter, NULL);
 		if (chan) {
 			err = dmatest_add_channel(chan);
-			if (err == 0)
-				continue;
-			else {
+			if (err) {
 				dma_release_channel(chan);
 				break; /* add_channel failed, punt */
 			}
diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index e4fc33c..1955ee8 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -1063,22 +1063,31 @@ static void ioat_dma_cleanup_tasklet(unsigned long data)
 static void
 ioat_dma_unmap(struct ioat_dma_chan *ioat_chan, struct ioat_desc_sw *desc)
 {
-	/*
-	 * yes we are unmapping both _page and _single
-	 * alloc'd regions with unmap_page. Is this
-	 * *really* that bad?
-	 */
-	if (!(desc->async_tx.flags & DMA_COMPL_SKIP_DEST_UNMAP))
-		pci_unmap_page(ioat_chan->device->pdev,
-				pci_unmap_addr(desc, dst),
-				pci_unmap_len(desc, len),
-				PCI_DMA_FROMDEVICE);
-
-	if (!(desc->async_tx.flags & DMA_COMPL_SKIP_SRC_UNMAP))
-		pci_unmap_page(ioat_chan->device->pdev,
-				pci_unmap_addr(desc, src),
-				pci_unmap_len(desc, len),
-				PCI_DMA_TODEVICE);
+	if (!(desc->async_tx.flags & DMA_COMPL_SKIP_DEST_UNMAP)) {
+		if (desc->async_tx.flags & DMA_COMPL_DEST_UNMAP_SINGLE)
+			pci_unmap_single(ioat_chan->device->pdev,
+					 pci_unmap_addr(desc, dst),
+					 pci_unmap_len(desc, len),
+					 PCI_DMA_FROMDEVICE);
+		else
+			pci_unmap_page(ioat_chan->device->pdev,
+				       pci_unmap_addr(desc, dst),
+				       pci_unmap_len(desc, len),
+				       PCI_DMA_FROMDEVICE);
+	}
+
+	if (!(desc->async_tx.flags & DMA_COMPL_SKIP_SRC_UNMAP)) {
+		if (desc->async_tx.flags & DMA_COMPL_SRC_UNMAP_SINGLE)
+			pci_unmap_single(ioat_chan->device->pdev,
+					 pci_unmap_addr(desc, src),
+					 pci_unmap_len(desc, len),
+					 PCI_DMA_TODEVICE);
+		else
+			pci_unmap_page(ioat_chan->device->pdev,
+				       pci_unmap_addr(desc, src),
+				       pci_unmap_len(desc, len),
+				       PCI_DMA_TODEVICE);
+	}
 }
 
 /**
@@ -1363,6 +1372,7 @@ static int ioat_dma_self_test(struct ioatdma_device *device)
 	int err = 0;
 	struct completion cmp;
 	unsigned long tmo;
+	unsigned long flags;
 
 	src = kzalloc(sizeof(u8) * IOAT_TEST_SIZE, GFP_KERNEL);
 	if (!src)
@@ -1392,8 +1402,9 @@ static int ioat_dma_self_test(struct ioatdma_device *device)
 				 DMA_TO_DEVICE);
 	dma_dest = dma_map_single(dma_chan->device->dev, dest, IOAT_TEST_SIZE,
 				  DMA_FROM_DEVICE);
+	flags = DMA_COMPL_SRC_UNMAP_SINGLE | DMA_COMPL_DEST_UNMAP_SINGLE;
 	tx = device->common.device_prep_dma_memcpy(dma_chan, dma_dest, dma_src,
-						   IOAT_TEST_SIZE, 0);
+						   IOAT_TEST_SIZE, flags);
 	if (!tx) {
 		dev_err(&device->pdev->dev,
 			"Self-test prep failed, disabling\n");
diff --git a/drivers/dma/ipu/ipu_idmac.c b/drivers/dma/ipu/ipu_idmac.c
index e202a6c..9a5bc1a 100644
--- a/drivers/dma/ipu/ipu_idmac.c
+++ b/drivers/dma/ipu/ipu_idmac.c
@@ -1272,7 +1272,8 @@ static irqreturn_t idmac_interrupt(int irq, void *dev_id)
 	/* Other interrupts do not interfere with this channel */
 	spin_lock(&ichan->lock);
 	if (unlikely(chan_id != IDMAC_SDC_0 && chan_id != IDMAC_SDC_1 &&
-		     ((curbuf >> chan_id) & 1) == ichan->active_buffer)) {
+		     ((curbuf >> chan_id) & 1) == ichan->active_buffer &&
+		     !list_is_last(ichan->queue.next, &ichan->queue))) {
 		int i = 100;
 
 		/* This doesn't help. See comment in ipu_disable_channel() */
@@ -1547,7 +1548,7 @@ static irqreturn_t ic_sof_irq(int irq, void *dev_id)
 	struct idmac_channel *ichan = dev_id;
 	printk(KERN_DEBUG "Got SOF IRQ %d on Channel %d\n",
 	       irq, ichan->dma_chan.chan_id);
-	disable_irq(irq);
+	disable_irq_nosync(irq);
 	return IRQ_HANDLED;
 }
 
@@ -1556,7 +1557,7 @@ static irqreturn_t ic_eof_irq(int irq, void *dev_id)
 	struct idmac_channel *ichan = dev_id;
 	printk(KERN_DEBUG "Got EOF IRQ %d on Channel %d\n",
 	       irq, ichan->dma_chan.chan_id);
-	disable_irq(irq);
+	disable_irq_nosync(irq);
 	return IRQ_HANDLED;
 }
 
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 2e2aa3d..ffefba8 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -78,12 +78,18 @@ enum dma_transaction_type {
  * 	dependency chains
  * @DMA_COMPL_SKIP_SRC_UNMAP - set to disable dma-unmapping the source buffer(s)
  * @DMA_COMPL_SKIP_DEST_UNMAP - set to disable dma-unmapping the destination(s)
+ * @DMA_COMPL_SRC_UNMAP_SINGLE - set to do the source dma-unmapping as single
+ * 	(if not set, do the source dma-unmapping as page)
+ * @DMA_COMPL_DEST_UNMAP_SINGLE - set to do the destination dma-unmapping as single
+ * 	(if not set, do the destination dma-unmapping as page)
  */
 enum dma_ctrl_flags {
 	DMA_PREP_INTERRUPT = (1 << 0),
 	DMA_CTRL_ACK = (1 << 1),
 	DMA_COMPL_SKIP_SRC_UNMAP = (1 << 2),
 	DMA_COMPL_SKIP_DEST_UNMAP = (1 << 3),
+	DMA_COMPL_SRC_UNMAP_SINGLE = (1 << 4),
+	DMA_COMPL_DEST_UNMAP_SINGLE = (1 << 5),
 };
 
 /**


