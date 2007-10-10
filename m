From: Mark Brown <broonie@sirena.org.uk>
Subject: [PATCH] natsemi: Check return value for pci_enable_device()
Date: Wed, 10 Oct 2007 17:11:12 +0100
Message-ID: <1192032672-4676-1-git-send-email-broonie@sirena.org.uk>
References: <1192010744-12204-1-git-send-email-broonie@sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@sirena.org.uk>
To: Jeff Garzik <jgarzik@pobox.com>, thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:3308 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933AbXJJQL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 12:11:27 -0400
In-Reply-To: <1192010744-12204-1-git-send-email-broonie@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_enable_device() is __must_check so do that in natsemi_resume().

Signed-off-by: Mark Brown <broonie@sirena.org.uk>
---
 drivers/net/natsemi.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index b881786..50e1ec6 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -3314,13 +3314,19 @@ static int natsemi_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct netdev_private *np = netdev_priv(dev);
+	int ret = 0;
 
 	rtnl_lock();
 	if (netif_device_present(dev))
 		goto out;
 	if (netif_running(dev)) {
 		BUG_ON(!np->hands_off);
-		pci_enable_device(pdev);
+		ret = pci_enable_device(pdev);
+		if (ret < 0) {
+			dev_err(&pdev->dev,
+				"pci_enable_device() failed: %d\n", ret);
+			goto out;
+		}
 	/*	pci_power_on(pdev); */
 
 		napi_enable(&np->napi);
@@ -3340,7 +3346,7 @@ static int natsemi_resume (struct pci_dev *pdev)
 	netif_device_attach(dev);
 out:
 	rtnl_unlock();
-	return 0;
+	return ret;
 }
 
 #endif /* CONFIG_PM */
-- 
1.5.3.4

