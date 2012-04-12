From: mjr@cs.wisc.edu
Subject: [PATCH] ks8851: Fix missing mutex_lock/unlock
Date: Thu, 12 Apr 2012 15:06:44 -0500
Message-ID: <1334261204-8554-1-git-send-email-mjr@cs.wisc.edu>
Cc: davem@davemloft.net, sboyd@codeaurora.org, ben@simtec.co.uk,
	netdev@vger.kernel.org, Matt Renzelmann <mjr@cs.wisc.edu>
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:47704 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848Ab2DLUNB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 16:13:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Renzelmann <mjr@cs.wisc.edu>

All calls to ks8851_rdreg* and ks8851_wrreg* should be protected with
the driver's lock mutex.  A spurious interrupt may otherwise cause a
crash.

Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
---

Thank you, Mr. Leitner, for providing feedback.  I agree with your
changes and have updated the patch to reflect them.  I apologize for
missing the driver name in the title -- I've updated the patch with
that information as well.  Please let me know if there is anything
else I should fix/change.

 drivers/net/ethernet/micrel/ks8851.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index c722aa6..20237dc 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1417,6 +1417,7 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 {
 	struct net_device *ndev;
 	struct ks8851_net *ks;
+	int result;
 	int ret;
 
 	ndev = alloc_etherdev(sizeof(struct ks8851_net));
@@ -1515,9 +1516,12 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 		goto err_netdev;
 	}
 
+	mutex_lock(&ks->lock);
+	result = CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER));
+	mutex_unlock(&ks->lock);
+
 	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
-		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
-		    ndev->dev_addr, ndev->irq,
+		    result, ndev->dev_addr, ndev->irq,
 		    ks->rc_ccr & CCR_EEPROM ? "has" : "no");
 
 	return 0;
-- 
1.7.5.4
