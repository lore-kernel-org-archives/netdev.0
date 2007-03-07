From: Brice Goglin <brice@myri.com>
Subject: [PATCH 4/4] myri10ge: add a wc_enabled flag to myri10ge_priv
Date: Wed, 07 Mar 2007 20:02:32 +0100
Message-ID: <45EF0C48.4020903@myri.com>
References: <45EF0B6C.9070005@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1797 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992475AbXCGTEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 14:04:40 -0500
In-Reply-To: <45EF0B6C.9070005@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a wc_enabled flag in the myri10ge_priv instead of relying
on mtrr >= 0.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-03-07 08:51:54.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-03-07 19:49:37.000000000 +0100
@@ -181,6 +181,7 @@
 	int intr_coal_delay;
 	__be32 __iomem *intr_coal_delay_ptr;
 	int mtrr;
+	int wc_enabled;
 	int wake_queue;
 	int stop_queue;
 	int down_cnt;
@@ -1385,7 +1386,7 @@
 		data[i] = ((unsigned long *)&mgp->stats)[i];
 
 	data[i++] = (unsigned int)mgp->tx.boundary;
-	data[i++] = (unsigned int)(mgp->mtrr >= 0);
+	data[i++] = (unsigned int)mgp->wc_enabled;
 	data[i++] = (unsigned int)mgp->pdev->irq;
 	data[i++] = (unsigned int)mgp->msi_enabled;
 	data[i++] = (unsigned int)mgp->read_dma;
@@ -1749,7 +1750,7 @@
 		goto abort_with_irq;
 	}
 
-	if (myri10ge_wcfifo && mgp->mtrr >= 0) {
+	if (myri10ge_wcfifo && mgp->wc_enabled) {
 		mgp->tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
 		mgp->rx_small.wc_fifo =
 		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_SMALL;
@@ -2850,9 +2851,12 @@
 	mgp->board_span = pci_resource_len(pdev, 0);
 	mgp->iomem_base = pci_resource_start(pdev, 0);
 	mgp->mtrr = -1;
+	mgp->wc_enabled = 0;
 #ifdef CONFIG_MTRR
 	mgp->mtrr = mtrr_add(mgp->iomem_base, mgp->board_span,
 			     MTRR_TYPE_WRCOMB, 1);
+	if (mgp->mtrr >= 0)
+		mgp->wc_enabled = 1;
 #endif
 	/* Hack.  need to get rid of these magic numbers */
 	mgp->sram_size =
@@ -2947,7 +2951,7 @@
 	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
 		 (mgp->msi_enabled ? "MSI" : "xPIC"),
 		 netdev->irq, mgp->tx.boundary, mgp->fw_name,
-		 (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
+		 (mgp->wc_enabled ? "Enabled" : "Disabled"));
 
 	return 0;
 


