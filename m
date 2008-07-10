From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/6] via-velocity: lean and clean velocity_init_rings
Date: Fri, 11 Jul 2008 00:04:33 +0200
Message-ID: <20080710220433.GC29764@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	=?unknown-8bit?B?U8OpZ3VpZXIgUsOpZ2lz?= <rseguier@e-teleport.net>,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38166 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753008AbYGJWFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:05:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- PCI consistent areas need no memset
- use dev_err instead of plain printk
- avoid a few casts

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/via-velocity.c |   48 +++++++++++++++++++------------------------
 1 files changed, 21 insertions(+), 27 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 117dbea..4ee29da 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1102,47 +1102,41 @@ static int __devinit velocity_get_pci_info(struct velocity_info *vptr, struct pc
 
 static int velocity_init_rings(struct velocity_info *vptr)
 {
-	int i;
-	unsigned int psize;
+	struct velocity_opt *opt = &vptr->options;
+	const unsigned int rx_ring_size = opt->numrx * sizeof(struct rx_desc);
+	const unsigned int tx_ring_size = opt->numtx * sizeof(struct tx_desc);
+	struct pci_dev *pdev = vptr->pdev;
 	dma_addr_t pool_dma;
-	u8 *pool;
-
-	/*
-	 *	Allocate all RD/TD rings a single pool
-	 */
-
-	psize = vptr->options.numrx * sizeof(struct rx_desc) +
-		vptr->options.numtx * sizeof(struct tx_desc) * vptr->num_txq;
+	void *pool;
+	unsigned int i;
 
 	/*
+	 * Allocate all RD/TD rings a single pool.
+	 *
 	 * pci_alloc_consistent() fulfills the requirement for 64 bytes
 	 * alignment
 	 */
-	pool = pci_alloc_consistent(vptr->pdev, psize, &pool_dma);
-
-	if (pool == NULL) {
-		printk(KERN_ERR "%s : DMA memory allocation failed.\n",
-					vptr->dev->name);
+	pool = pci_alloc_consistent(pdev, tx_ring_size * vptr->num_txq +
+				    rx_ring_size, &pool_dma);
+	if (!pool) {
+		dev_err(&pdev->dev, "%s : DMA memory allocation failed.\n",
+			vptr->dev->name);
 		return -ENOMEM;
 	}
 
-	memset(pool, 0, psize);
-
-	vptr->rd_ring = (struct rx_desc *) pool;
-
+	vptr->rd_ring = pool;
 	vptr->rd_pool_dma = pool_dma;
 
-	i = vptr->options.numrx * sizeof(struct rx_desc);
-	pool += i;
-	pool_dma += i;
-	for (i = 0; i < vptr->num_txq; i++) {
-		int offset = vptr->options.numtx * sizeof(struct tx_desc);
+	pool += rx_ring_size;
+	pool_dma += rx_ring_size;
 
+	for (i = 0; i < vptr->num_txq; i++) {
+		vptr->td_rings[i] = pool;
 		vptr->td_pool_dma[i] = pool_dma;
-		vptr->td_rings[i] = (struct tx_desc *) pool;
-		pool += offset;
-		pool_dma += offset;
+		pool += tx_ring_size;
+		pool_dma += tx_ring_size;
 	}
+
 	return 0;
 }
 
-- 
1.5.3.3

