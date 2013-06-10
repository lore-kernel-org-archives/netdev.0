From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 7/7] NET: intel/ixgbevf/ixgbevf_main.c: fix 32-bit DMA mask
 handling
Date: Tue, 11 Jun 2013 00:15:43 +0100
Message-ID: <E1UmBJP-0006KR-5h@rmk-PC.arm.linux.org.uk>
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
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:41507 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250Ab3FJXPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 19:15:46 -0400
In-Reply-To: <20130610230849.GF18614@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fallback to 32-bit DMA mask is rather odd:
	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) &&
	    !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
		pci_using_dac = 1;
	} else {
		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
		if (err) {
			err = dma_set_coherent_mask(&pdev->dev,
						    DMA_BIT_MASK(32));
			if (err) {
				dev_err(&pdev->dev, "No usable DMA "
					"configuration, aborting\n");
				goto err_dma;
			}
		}
		pci_using_dac = 0;
	}
This means we only set the coherent DMA mask in the fallback path if
the DMA mask set failed, which is silly.  This fixes it to set the
coherent DMA mask only if dma_set_mask() succeeded, and to error out
if either fails.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 1f5166a..1ae22e0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3331,14 +3331,13 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pci_using_dac = 1;
 	} else {
 		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
-		if (err) {
+		if (!err)
 			err = dma_set_coherent_mask(&pdev->dev,
 						    DMA_BIT_MASK(32));
-			if (err) {
-				dev_err(&pdev->dev, "No usable DMA "
-					"configuration, aborting\n");
-				goto err_dma;
-			}
+		if (err) {
+			dev_err(&pdev->dev, "No usable DMA "
+				"configuration, aborting\n");
+			goto err_dma;
 		}
 		pci_using_dac = 0;
 	}
-- 
1.7.4.4
