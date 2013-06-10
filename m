From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 5/7] NET: intel/ixgb/ixgb_main.c: fix 32-bit DMA mask
 handling
Date: Tue, 11 Jun 2013 00:13:42 +0100
Message-ID: <E1UmBHS-0006KE-Tm@rmk-PC.arm.linux.org.uk>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:41483 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960Ab3FJXNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 19:13:46 -0400
In-Reply-To: <20130610230849.GF18614@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fallback to 32-bit DMA mask is rather odd:
	err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(64));
	if (!err) {
		err = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
		if (!err)
			pci_using_dac = 1;
	} else {
		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
		if (err) {
			err = dma_set_coherent_mask(&pdev->dev,
						    DMA_BIT_MASK(32));
			if (err) {
				pr_err("No usable DMA configuration, aborting\n");
				goto err_dma_mask;
			}
		}
	}
This means we only set the coherent DMA mask in the fallback path if
the DMA mask set failed, which is silly.  This fixes it to set the
coherent DMA mask only if dma_set_mask() succeeded, and to error out
if either fails.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index fce3e92..136829e 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -415,13 +415,12 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			pci_using_dac = 1;
 	} else {
 		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
-		if (err) {
+		if (!err)
 			err = dma_set_coherent_mask(&pdev->dev,
 						    DMA_BIT_MASK(32));
-			if (err) {
-				pr_err("No usable DMA configuration, aborting\n");
-				goto err_dma_mask;
-			}
+		if (err) {
+			pr_err("No usable DMA configuration, aborting\n");
+			goto err_dma_mask;
 		}
 	}
 
-- 
1.7.4.4
