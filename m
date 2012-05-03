From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net/niu: remove one superfluous dma mask check
Date: Thu,  3 May 2012 20:22:00 +0200
Message-ID: <1336069320-23639-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:52423 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab2ECSUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 14:20:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The idea here seems to be to get a 44bit DMA mask working and if this
fails it should fallback to a 32bit DMA mask. The dma_mask variable is
assigned once to 44bit and never updated. pci_set_dma_mask() and
pci_set_consistent_dma_mask() are both implemented as functions so there
is no evil macro which might update dma_mask. Looking at the assembly, I
see a call to dma_set_mask() followed by dma_supported() and then a jump
passed the second dma_set_mask(). The only way to get to second
dma_set_mask() call is by an error code in the first one.

So I hereby remove the check since it looks superfluous. Please ignore
the path if there is black magic involved.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/sun/niu.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index c99b3b0..703c8cc 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9838,7 +9838,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 			goto err_out_release_parent;
 		}
 	}
-	if (err || dma_mask == DMA_BIT_MASK(32)) {
+	if (err) {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			dev_err(&pdev->dev, "No usable DMA configuration, aborting\n");
-- 
1.7.10
