From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/3] media/cobalt: use pci_irq_allocate_vectors
Date: Mon,  9 Jan 2017 21:37:38 +0100
Message-ID: <1483994260-19797-2-git-send-email-hch@lst.de>
References: <1483994260-19797-1-git-send-email-hch@lst.de>
Cc: Mauro Carvalho Chehab <mchehab@s-opensource.com>,
        netdev@vger.kernel.org, linux-media@vger.kernel.org
To: linux-pci@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:37994 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932306AbdAIUhr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:37:47 -0500
In-Reply-To: <1483994260-19797-1-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply the interrupt setup by using the new PCI layer helpers.

Despite using pci_enable_msi_range, this driver was only requesting a
single MSI vector anyway.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/media/pci/cobalt/cobalt-driver.c | 8 ++------
 drivers/media/pci/cobalt/cobalt-driver.h | 2 --
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/media/pci/cobalt/cobalt-driver.c b/drivers/media/pci/cobalt/cobalt-driver.c
index 9796340..d5c911c 100644
--- a/drivers/media/pci/cobalt/cobalt-driver.c
+++ b/drivers/media/pci/cobalt/cobalt-driver.c
@@ -308,9 +308,7 @@ static void cobalt_pci_iounmap(struct cobalt *cobalt, struct pci_dev *pci_dev)
 static void cobalt_free_msi(struct cobalt *cobalt, struct pci_dev *pci_dev)
 {
 	free_irq(pci_dev->irq, (void *)cobalt);
-
-	if (cobalt->msi_enabled)
-		pci_disable_msi(pci_dev);
+	pci_free_irq_vectors(pci_dev);
 }
 
 static int cobalt_setup_pci(struct cobalt *cobalt, struct pci_dev *pci_dev,
@@ -387,14 +385,12 @@ static int cobalt_setup_pci(struct cobalt *cobalt, struct pci_dev *pci_dev,
 	   from being generated. */
 	cobalt_set_interrupt(cobalt, false);
 
-	if (pci_enable_msi_range(pci_dev, 1, 1) < 1) {
+	if (pci_alloc_irq_vectors(pci_dev, 1, 1, PCI_IRQ_MSI) < 1) {
 		cobalt_err("Could not enable MSI\n");
-		cobalt->msi_enabled = false;
 		ret = -EIO;
 		goto err_release;
 	}
 	msi_config_show(cobalt, pci_dev);
-	cobalt->msi_enabled = true;
 
 	/* Register IRQ */
 	if (request_irq(pci_dev->irq, cobalt_irq_handler, IRQF_SHARED,
diff --git a/drivers/media/pci/cobalt/cobalt-driver.h b/drivers/media/pci/cobalt/cobalt-driver.h
index ed00dc9..00f773e 100644
--- a/drivers/media/pci/cobalt/cobalt-driver.h
+++ b/drivers/media/pci/cobalt/cobalt-driver.h
@@ -287,8 +287,6 @@ struct cobalt {
 	u32 irq_none;
 	u32 irq_full_fifo;
 
-	bool msi_enabled;
-
 	/* omnitek dma */
 	int dma_channels;
 	int first_fifo_channel;
-- 
2.1.4
