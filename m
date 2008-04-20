From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/2] korina: misc cleanup
Date: Sun, 20 Apr 2008 18:06:13 +0200
Message-ID: <20080420160613.GB26599@electric-eye.fr.zoreil.com>
References: <20080420160531.GA26599@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43160 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753587AbYDTQYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 12:24:25 -0400
Content-Disposition: inline
In-Reply-To: <20080420160531.GA26599@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- useless initialization (korina_ope / korina_restart)
- use a single variable for the status code in korina_probe
  and propagate the error status code from below
- useless checks in korina_remove : the variables are
  necessarily set when korina_probe succeeds

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/korina.c |   35 ++++++++++++++++-------------------
 1 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 305be62..e185763 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -883,7 +883,7 @@ static int korina_init(struct net_device *dev)
 static int korina_restart(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
-	int ret = 0;
+	int ret;
 
 	/*
 	 * Disable interrupts
@@ -987,7 +987,7 @@ static void korina_poll_controller(struct net_device *dev)
 static int korina_open(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
-	int ret = 0;
+	int ret;
 
 	/* Initialize */
 	ret = korina_init(dev);
@@ -1082,7 +1082,7 @@ static int korina_probe(struct platform_device *pdev)
 	struct korina_private *lp;
 	struct net_device *dev;
 	struct resource *r;
-	int retval, err;
+	int rc;
 
 	dev = alloc_etherdev(sizeof(struct korina_private));
 	if (!dev) {
@@ -1106,7 +1106,7 @@ static int korina_probe(struct platform_device *pdev)
 	lp->eth_regs = ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->eth_regs) {
 		printk(KERN_ERR DRV_NAME "cannot remap registers\n");
-		retval = -ENXIO;
+		rc = -ENXIO;
 		goto probe_err_out;
 	}
 
@@ -1114,7 +1114,7 @@ static int korina_probe(struct platform_device *pdev)
 	lp->rx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->rx_dma_regs) {
 		printk(KERN_ERR DRV_NAME "cannot remap Rx DMA registers\n");
-		retval = -ENXIO;
+		rc = -ENXIO;
 		goto probe_err_dma_rx;
 	}
 
@@ -1122,14 +1122,14 @@ static int korina_probe(struct platform_device *pdev)
 	lp->tx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->tx_dma_regs) {
 		printk(KERN_ERR DRV_NAME "cannot remap Tx DMA registers\n");
-		retval = -ENXIO;
+		rc = -ENXIO;
 		goto probe_err_dma_tx;
 	}
 
 	lp->td_ring = kmalloc(TD_RING_SIZE + RD_RING_SIZE, GFP_KERNEL);
 	if (!lp->td_ring) {
 		printk(KERN_ERR DRV_NAME "cannot allocate descriptors\n");
-		retval = -ENOMEM;
+		rc = -ENXIO;
 		goto probe_err_td_ring;
 	}
 
@@ -1166,14 +1166,14 @@ static int korina_probe(struct platform_device *pdev)
 	lp->mii_if.phy_id_mask = 0x1f;
 	lp->mii_if.reg_num_mask = 0x1f;
 
-	err = register_netdev(dev);
-	if (err) {
+	rc = register_netdev(dev);
+	if (rc < 0) {
 		printk(KERN_ERR DRV_NAME
-			": cannot register net device %d\n", err);
-		retval = -EINVAL;
+			": cannot register net device %d\n", rc);
 		goto probe_err_register;
 	}
-	return 0;
+out:
+	return rc;
 
 probe_err_register:
 	kfree(lp->td_ring);
@@ -1185,7 +1185,7 @@ probe_err_dma_rx:
 	iounmap(lp->eth_regs);
 probe_err_out:
 	free_netdev(dev);
-	return retval;
+	goto out;
 }
 
 static int korina_remove(struct platform_device *pdev)
@@ -1193,12 +1193,9 @@ static int korina_remove(struct platform_device *pdev)
 	struct korina_device *bif = platform_get_drvdata(pdev);
 	struct korina_private *lp = netdev_priv(bif->dev);
 
-	if (lp->eth_regs)
-		iounmap(lp->eth_regs);
-	if (lp->rx_dma_regs)
-		iounmap(lp->rx_dma_regs);
-	if (lp->tx_dma_regs)
-		iounmap(lp->tx_dma_regs);
+	iounmap(lp->eth_regs);
+	iounmap(lp->rx_dma_regs);
+	iounmap(lp->tx_dma_regs);
 
 	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(bif->dev);
-- 
1.5.3.3

