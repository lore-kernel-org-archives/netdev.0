From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 08/27] e1000: fix return value not set on error
Date: Fri, 10 Dec 2010 22:17:02 -0800
Message-ID: <1292048241-22026-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dean Nelson <dnelson@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, stable@kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:45662 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751345Ab0LKGSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 01:18:03 -0500
To: davem@davemloft.net
In-Reply-To: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dean Nelson <dnelson@redhat.com>

Dean noticed that 'err' wasn't being set when the "goto err_dma"
statement is executed in the following hunk from the commit. It's value
will be zero as a result of a successful call to e1000_init_hw_struct().

This patch changes the error condition to be correctly propagated.

CC: stable@kernel.org
Signed-off-by:  Dean Nelson <dnelson@redhat.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000/e1000_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 06c7d1c..491bf2a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -971,11 +971,13 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		 */
 		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
 		pci_using_dac = 1;
-	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
-		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
 	} else {
-		pr_err("No usable DMA config, aborting\n");
-		goto err_dma;
+		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (err) {
+			pr_err("No usable DMA config, aborting\n");
+			goto err_dma;
+		}
+		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
 	}
 
 	netdev->netdev_ops = &e1000_netdev_ops;
-- 
1.7.3.2

