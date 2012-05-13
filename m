From: Mike Galbraith <mgalbraith@suse.de>
Subject: Re: [patch] Re: qlge driver corrupting kernel memory
Date: Sun, 13 May 2012 12:16:19 +0200
Message-ID: <1336904179.7390.16.camel@marge.simpson.net>
References: <1336474818.21924.94.camel@marge.simpson.net>
	 <20120508120748.GA3504@oc1711230544.ibm.com>
	 <1336736301.7361.144.camel@marge.simpson.net>
	 <1336903839.7390.13.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47116 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465Ab2EMKQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2012 06:16:26 -0400
In-Reply-To: <1336903839.7390.13.camel@marge.simpson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erm, with a quilt refresh you get the compiling version :)

glge: Fix double pci_free_consistent() upon tx_ring->q allocation failure

Let ql_free_tx_resources() do it's job.  You are not helping.

Signed-off-by: Mike Galbraith <mgalbraith@suse.de>
---
 drivers/net/qlge/qlge_main.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2664,11 +2664,8 @@ static int ql_alloc_tx_resources(struct
 	    pci_alloc_consistent(qdev->pdev, tx_ring->wq_size,
 				 &tx_ring->wq_base_dma);
 
-	if ((tx_ring->wq_base == NULL) ||
-	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
-		QPRINTK(qdev, IFUP, ERR, "tx_ring alloc failed.\n");
-		return -ENOMEM;
-	}
+	if ((tx_ring->wq_base == NULL) || tx_ring->wq_base_dma & WQ_ADDR_ALIGN)
+		goto err;
 	tx_ring->q =
 	    kmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc), GFP_KERNEL);
 	if (tx_ring->q == NULL)
@@ -2676,8 +2673,7 @@ static int ql_alloc_tx_resources(struct
 
 	return 0;
 err:
-	pci_free_consistent(qdev->pdev, tx_ring->wq_size,
-			    tx_ring->wq_base, tx_ring->wq_base_dma);
+	QPRINTK(qdev, IFUP, ERR, "tx_ring alloc failed.\n");
 	return -ENOMEM;
 }
 
