From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 18/51] DMA-API: staging: et131x: replace
	dma_set_mask()+dma_set_coherent_mask() with new helper
Date: Sat, 21 Sep 2013 20:55:31 +0100
Message-ID: <20130921195531.GO12758@n2100.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk> <E1VMm05-0007hG-5T@rmk-PC.arm.linux.org.uk> <1379691728.1681.15.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@driverdev.osuosl.org, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:39743 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab3IUTzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 15:55:45 -0400
Content-Disposition: inline
In-Reply-To: <1379691728.1681.15.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 20, 2013 at 04:42:08PM +0100, Ben Hutchings wrote:
> On Thu, 2013-09-19 at 22:43 +0100, Russell King wrote:
> > +	if (dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64)) ||
> > +	    dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32))) {
> 
> Surely we want && here.

Good catch, exactly right.  Thanks for the review, here's the replacement
patch:

8<====
From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH] DMA-API: staging: et131x: replace
 dma_set_mask()+dma_set_coherent_mask() with new helper

Replace the following sequence:

	dma_set_mask(dev, mask);
	dma_set_coherent_mask(dev, mask);

with a call to the new helper dma_set_mask_and_coherent().

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/staging/et131x/et131x.c |   17 ++---------------
 1 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index f73e58f..61da7ee 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -4797,21 +4797,8 @@ static int et131x_pci_setup(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	/* Check the DMA addressing support of this device */
-	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
-		rc = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
-		if (rc < 0) {
-			dev_err(&pdev->dev,
-			  "Unable to obtain 64 bit DMA for consistent allocations\n");
-			goto err_release_res;
-		}
-	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
-		rc = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
-		if (rc < 0) {
-			dev_err(&pdev->dev,
-			  "Unable to obtain 32 bit DMA for consistent allocations\n");
-			goto err_release_res;
-		}
-	} else {
+	if (dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64)) &&
+	    dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32))) {
 		dev_err(&pdev->dev, "No usable DMA addressing method\n");
 		rc = -EIO;
 		goto err_release_res;
-- 
1.7.4.4
