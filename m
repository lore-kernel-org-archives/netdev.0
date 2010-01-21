From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 1/2] e1000: Fix DMA mapping error handling on TX
Date: Thu, 21 Jan 2010 22:42:44 +1100
Message-ID: <20100121114244.GC32259@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joh
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45346 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750938Ab0AULqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 06:46:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There were a few issues in the DMA mapping error handling in e1000_tx_map
which I found via fault injection.

If we fail to map the first descriptor count will end up as -1 but the
check of (count >= 0) will still be true since count is unsigned. Instead
of changing count to be signed, just simplify the logic.

Secondly, when we wrap the tx ring we rely on i to go negative, but it
was unsigned.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux.trees.git/drivers/net/e1000/e1000_main.c
===================================================================
--- linux.trees.git.orig/drivers/net/e1000/e1000_main.c	2010-01-21 11:10:00.000000000 +1100
+++ linux.trees.git/drivers/net/e1000/e1000_main.c	2010-01-21 11:12:52.000000000 +1100
@@ -2693,8 +2693,9 @@ static int e1000_tx_map(struct e1000_ada
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
-	unsigned int offset = 0, size, count = 0, i;
+	unsigned int offset = 0, size, count = 0;
 	unsigned int f;
+	int i;
 
 	i = tx_ring->next_to_use;
 
@@ -2802,10 +2803,8 @@ static int e1000_tx_map(struct e1000_ada
 dma_error:
 	dev_err(&pdev->dev, "TX DMA map failed\n");
 	buffer_info->dma = 0;
-	count--;
 
-	while (count >= 0) {
-		count--;
+	while (count--) {
 		i--;
 		if (i < 0)
 			i += tx_ring->count;
