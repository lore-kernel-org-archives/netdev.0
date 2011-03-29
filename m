From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/2] via-ircc: Pass PCI device pointer to
 dma_{alloc,free}_coherent()
Date: Tue, 29 Mar 2011 04:12:52 +0100
Message-ID: <1301368372.26693.753.camel@localhost>
References: <1301368243.26693.751.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Andrew Buckeridge <andrewb@bgc.com.au>,
	Samuel Ortiz <samuel@sortiz.org>, 619450@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51297 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755505Ab1C2DMz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2011 23:12:55 -0400
In-Reply-To: <1301368243.26693.751.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

via-ircc has been passing a NULL pointer to DMA allocation functions,
which is completely invalid and results in a BUG on PowerPC.  Now
that we always have the device pointer available, pass it in.

Reference: http://bugs.debian.org/619450
Reported-by: Andrew Buckeridge <andrewb@bgc.com.au>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Tested-by: Andrew Buckeridge <andrewb@bgc.com.au> [against 2.6.32]
---
 drivers/net/irda/via-ircc.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index cc6faca..186cd28 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -363,7 +363,7 @@ static __devinit int via_ircc_open(struct pci_dev *pdev, chipio_t * info,
 
 	/* Allocate memory if needed */
 	self->rx_buff.head =
-		dma_alloc_coherent(NULL, self->rx_buff.truesize,
+		dma_alloc_coherent(&pdev->dev, self->rx_buff.truesize,
 				   &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
@@ -372,7 +372,7 @@ static __devinit int via_ircc_open(struct pci_dev *pdev, chipio_t * info,
 	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 
 	self->tx_buff.head =
-		dma_alloc_coherent(NULL, self->tx_buff.truesize,
+		dma_alloc_coherent(&pdev->dev, self->tx_buff.truesize,
 				   &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
@@ -404,10 +404,10 @@ static __devinit int via_ircc_open(struct pci_dev *pdev, chipio_t * info,
 	via_hw_init(self);
 	return 0;
  err_out4:
-	dma_free_coherent(NULL, self->tx_buff.truesize,
+	dma_free_coherent(&pdev->dev, self->tx_buff.truesize,
 			  self->tx_buff.head, self->tx_buff_dma);
  err_out3:
-	dma_free_coherent(NULL, self->rx_buff.truesize,
+	dma_free_coherent(&pdev->dev, self->rx_buff.truesize,
 			  self->rx_buff.head, self->rx_buff_dma);
  err_out2:
 	release_region(self->io.fir_base, self->io.fir_ext);
@@ -441,10 +441,10 @@ static void __devexit via_remove_one(struct pci_dev *pdev)
 		   __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 	if (self->tx_buff.head)
-		dma_free_coherent(NULL, self->tx_buff.truesize,
+		dma_free_coherent(&pdev->dev, self->tx_buff.truesize,
 				  self->tx_buff.head, self->tx_buff_dma);
 	if (self->rx_buff.head)
-		dma_free_coherent(NULL, self->rx_buff.truesize,
+		dma_free_coherent(&pdev->dev, self->rx_buff.truesize,
 				  self->rx_buff.head, self->rx_buff_dma);
 	pci_set_drvdata(pdev, NULL);
 
-- 
1.7.4.1


