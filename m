From: Roger Luethi <rl@hellgate.ch>
Subject: [PATCH] via-rhine: Disable device in error path
Date: Tue, 18 Mar 2014 18:14:01 +0100
Message-ID: <20140318171401.GA1184@hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Huqiu Liu <liuhq11@mails.tsinghua.edu.cn>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zhhdzmsp-smta16.bluewin.ch ([195.186.227.132]:58713 "EHLO
	zhhdzmsp-smta16.bluewin.ch" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751573AbaCRRVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:21:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, via-rhine fails to call pci_disable_device() for errors
in rhine_init_one().

Reported-by: Huqiu Liu <liuhq11@mails.tsinghua.edu.cn>
Signed-off-by: Roger Luethi <rl@hellgate.ch>
---
 drivers/net/ethernet/via/via-rhine.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index ef312bc..6ac20a6 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -923,7 +923,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc) {
 		dev_err(&pdev->dev,
 			"32-bit PCI DMA addresses not supported by the card!?\n");
-		goto err_out;
+		goto err_out_pci_disable;
 	}
 
 	/* sanity check */
@@ -931,7 +931,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	    (pci_resource_len(pdev, 1) < io_size)) {
 		rc = -EIO;
 		dev_err(&pdev->dev, "Insufficient PCI resources, aborting\n");
-		goto err_out;
+		goto err_out_pci_disable;
 	}
 
 	pioaddr = pci_resource_start(pdev, 0);
@@ -942,7 +942,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev = alloc_etherdev(sizeof(struct rhine_private));
 	if (!dev) {
 		rc = -ENOMEM;
-		goto err_out;
+		goto err_out_pci_disable;
 	}
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -1084,6 +1084,8 @@ err_out_free_res:
 	pci_release_regions(pdev);
 err_out_free_netdev:
 	free_netdev(dev);
+err_out_pci_disable:
+	pci_disable_device(pdev);
 err_out:
 	return rc;
 }
-- 
1.7.10.4
