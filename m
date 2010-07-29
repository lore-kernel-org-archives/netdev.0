From: Dan Carpenter <error27@gmail.com>
Subject: [patch] dnet: fixup error handling in initialization
Date: Thu, 29 Jul 2010 10:27:29 +0200
Message-ID: <20100729082729.GS26313@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Frans Pop <elendil@planet.nl>,
	Richard Cochran <richard.cochran@omicron.at>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54838 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408Ab0G2I2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 04:28:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were two problems here.  We returned success if dnet_mii_init()
failed and there was a release_mem_region() missing.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 4ea7141..7c07575 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -854,7 +854,7 @@ static int __devinit dnet_probe(struct platform_device *pdev)
 	dev = alloc_etherdev(sizeof(*bp));
 	if (!dev) {
 		dev_err(&pdev->dev, "etherdev alloc failed, aborting.\n");
-		goto err_out;
+		goto err_out_release_mem;
 	}
 
 	/* TODO: Actually, we have some interesting features... */
@@ -911,7 +911,8 @@ static int __devinit dnet_probe(struct platform_device *pdev)
 	if (err)
 		dev_warn(&pdev->dev, "Cannot register PHY board fixup.\n");
 
-	if (dnet_mii_init(bp) != 0)
+	err = dnet_mii_init(bp);
+	if (err)
 		goto err_out_unregister_netdev;
 
 	dev_info(&pdev->dev, "Dave DNET at 0x%p (0x%08x) irq %d %pM\n",
@@ -936,6 +937,8 @@ err_out_iounmap:
 	iounmap(bp->regs);
 err_out_free_dev:
 	free_netdev(dev);
+err_out_release_mem:
+	release_mem_region(mem_base, mem_size);
 err_out:
 	return err;
 }
