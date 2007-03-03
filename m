From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 9/9] I/OAT: fix I/OAT for kexec
Date: Fri, 02 Mar 2007 18:24:34 -0800
Message-ID: <20070303022434.31033.78320.stgit@gitlost.site>
References: <20070303022238.31033.84558.stgit@gitlost.site>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1466 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992912AbXCCCjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 21:39:12 -0500
In-Reply-To: <20070303022238.31033.84558.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Under kexec, I/OAT initialization breaks over busy resources because the
previous kernel did not release them.

I'm not sure this fix can be considered a complete one but it works for me.
 I guess something similar to the *_remove method should occur there..

Signed-off-by: Dan Aloni <da-x@monatomic.org>
Signed-off-by: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/dma/ioatdma.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
index cbf93ca..1d259e5 100644
--- a/drivers/dma/ioatdma.c
+++ b/drivers/dma/ioatdma.c
@@ -41,6 +41,7 @@
 
 /* internal functions */
 static int __devinit ioat_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
+static void ioat_shutdown(struct pci_dev *pdev);
 static void __devexit ioat_remove(struct pci_dev *pdev);
 
 static int enumerate_dma_channels(struct ioat_device *device)
@@ -557,6 +558,7 @@ static struct pci_driver ioat_pci_drv = {
 	.name 	= "ioatdma",
 	.id_table = ioat_pci_tbl,
 	.probe	= ioat_probe,
+	.shutdown = ioat_shutdown,
 	.remove	= __devexit_p(ioat_remove),
 };
 
@@ -781,9 +783,20 @@ err_request_regions:
 err_set_dma_mask:
 	pci_disable_device(pdev);
 err_enable_device:
+
+	printk(KERN_ERR "Intel(R) I/OAT DMA Engine initialization failed\n");
+
 	return err;
 }
 
+static void ioat_shutdown(struct pci_dev *pdev)
+{
+	struct ioat_device *device;
+	device = pci_get_drvdata(pdev);
+
+	dma_async_device_unregister(&device->common);
+}
+
 static void __devexit ioat_remove(struct pci_dev *pdev)
 {
 	struct ioat_device *device;

