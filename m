From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 1/7] NET: brocade/bna/bnad.c: fix 32-bit DMA mask handling
Date: Tue, 11 Jun 2013 00:09:42 +0100
Message-ID: <E1UmBDa-0006Jt-CE@rmk-PC.arm.linux.org.uk>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
Cc: Rasesh Mody <rmody@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:41433 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab3FJXJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 19:09:45 -0400
In-Reply-To: <20130610230849.GF18614@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fallback to 32-bit DMA mask is rather odd:
	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) &&
	    !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
		*using_dac = true;
	} else {
		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
		if (err) {
			err = dma_set_coherent_mask(&pdev->dev,
						    DMA_BIT_MASK(32));
			if (err)
				goto release_regions;
		}

This means we only try and set the coherent DMA mask if we failed to
set a 32-bit DMA mask, and only if both fail do we fail the driver.
Adjust this so that if either setting fails, we fail the driver - and
thereby end up properly setting both the DMA mask and the coherent
DMA mask in the fallback case.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/brocade/bna/bnad.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 07f7ef0..15feb8b 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3302,12 +3302,11 @@ bnad_pci_init(struct bnad *bnad,
 		*using_dac = true;
 	} else {
 		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
-		if (err) {
+		if (!err)
 			err = dma_set_coherent_mask(&pdev->dev,
 						    DMA_BIT_MASK(32));
-			if (err)
-				goto release_regions;
-		}
+		if (err)
+			goto release_regions;
 		*using_dac = false;
 	}
 	pci_set_master(pdev);
-- 
1.7.4.4
