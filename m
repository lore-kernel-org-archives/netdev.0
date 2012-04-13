From: mjr@cs.wisc.edu
Subject: [PATCH] ks8851: Fix missing mutex_lock/unlock
Date: Fri, 13 Apr 2012 12:59:40 -0500
Message-ID: <1334339980-2955-1-git-send-email-mjr@cs.wisc.edu>
Cc: davem@davemloft.net, sboyd@codeaurora.org, ben@simtec.co.uk,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	Matt Renzelmann <mjr@cs.wisc.edu>
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:49806 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474Ab2DMSD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2012 14:03:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Renzelmann <mjr@cs.wisc.edu>

Move the ks8851_rdreg16 call above the call to request_irq and cache
the result for subsequent repeated use.  A spurious interrupt may
otherwise cause a crash.  Thanks to Stephen Boyd, Flavio Leitner, and
Ben Hutchings for feedback.

Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
---
 drivers/net/ethernet/micrel/ks8851.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index c722aa6..e5dc075 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1418,6 +1418,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 	struct net_device *ndev;
 	struct ks8851_net *ks;
 	int ret;
+	unsigned cider;
 
 	ndev = alloc_etherdev(sizeof(struct ks8851_net));
 	if (!ndev)
@@ -1484,8 +1485,8 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 	ks8851_soft_reset(ks, GRR_GSR);
 
 	/* simple check for a valid chip being connected to the bus */
-
-	if ((ks8851_rdreg16(ks, KS_CIDER) & ~CIDER_REV_MASK) != CIDER_ID) {
+	cider = ks8851_rdreg16(ks, KS_CIDER);
+	if ((cider & ~CIDER_REV_MASK) != CIDER_ID) {
 		dev_err(&spi->dev, "failed to read device ID\n");
 		ret = -ENODEV;
 		goto err_id;
@@ -1516,8 +1517,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 	}
 
 	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
-		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
-		    ndev->dev_addr, ndev->irq,
+		    CIDER_REV_GET(cider), ndev->dev_addr, ndev->irq,
 		    ks->rc_ccr & CCR_EEPROM ? "has" : "no");
 
 	return 0;
-- 
1.7.5.4
