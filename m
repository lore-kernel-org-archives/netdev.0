From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] sgiseeq: replace use of dma_cache_wback_inv
Date: Tue, 4 Sep 2007 14:41:01 +0100
Message-ID: <20070904134101.GA20191@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:52721 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbXIDNlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 09:41:06 -0400
Received: from localhost.localdomain ([127.0.0.1]:10477 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20024736AbXIDNlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2007 14:41:04 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sgiseeq driver is one of the few remaining users of the ancient
cache banging DMA API.  Replaced with the modern days DMA API.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 0fb74cb..eb67b02 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -75,6 +75,7 @@ struct sgiseeq_init_block { /* Note the name ;-) */
 
 struct sgiseeq_private {
 	struct sgiseeq_init_block *srings;
+	dma_addr_t srings_dma;
 
 	/* Ptrs to the descriptors in uncached space. */
 	struct sgiseeq_rx_desc *rx_desc;
@@ -643,13 +644,20 @@ static int __init sgiseeq_probe(struct platform_device *pdev)
 	sp = netdev_priv(dev);
 
 	/* Make private data page aligned */
-	sr = (struct sgiseeq_init_block *) get_zeroed_page(GFP_KERNEL);
+	sr = dma_alloc_coherent(&pdev->dev, sizeof(*sp->srings),
+				&sp->srings_dma, GFP_KERNEL);
 	if (!sr) {
 		printk(KERN_ERR "Sgiseeq: Page alloc failed, aborting.\n");
 		err = -ENOMEM;
 		goto err_out_free_dev;
 	}
 	sp->srings = sr;
+	sp->rx_desc = sp->srings->rxvector;
+	sp->tx_desc = sp->srings->txvector;
+
+	/* A couple calculations now, saves many cycles later. */
+	setup_rx_ring(sp->rx_desc, SEEQ_RX_BUFFERS);
+	setup_tx_ring(sp->tx_desc, SEEQ_TX_BUFFERS);
 
 	memcpy(dev->dev_addr, pd->mac, ETH_ALEN);
 
@@ -662,19 +670,6 @@ static int __init sgiseeq_probe(struct platform_device *pdev)
 	sp->name = sgiseeqstr;
 	sp->mode = SEEQ_RCMD_RBCAST;
 
-	sp->rx_desc = (struct sgiseeq_rx_desc *)
-	              CKSEG1ADDR(ALIGNED(&sp->srings->rxvector[0]));
-	dma_cache_wback_inv((unsigned long)&sp->srings->rxvector,
-	                    sizeof(sp->srings->rxvector));
-	sp->tx_desc = (struct sgiseeq_tx_desc *)
-	              CKSEG1ADDR(ALIGNED(&sp->srings->txvector[0]));
-	dma_cache_wback_inv((unsigned long)&sp->srings->txvector,
-	                    sizeof(sp->srings->txvector));
-
-	/* A couple calculations now, saves many cycles later. */
-	setup_rx_ring(sp->rx_desc, SEEQ_RX_BUFFERS);
-	setup_tx_ring(sp->tx_desc, SEEQ_TX_BUFFERS);
-
 	/* Setup PIO and DMA transfer timing */
 	sp->hregs->pconfig = 0x161;
 	sp->hregs->dconfig = HPC3_EDCFG_FIRQ | HPC3_EDCFG_FEOP |
@@ -732,7 +727,8 @@ static int __exit sgiseeq_remove(struct platform_device *pdev)
 	struct sgiseeq_private *sp = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	free_page((unsigned long) sp->srings);
+	dma_free_coherent(&pdev->dev, sizeof(*sp->srings), sp->srings,
+	                  sp->srings_dma);
 	free_netdev(dev);
 	platform_set_drvdata(pdev, NULL);
 
