From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH 2/3 v2] cnic: Don't take cnic_dev_lock in cnic_alloc_uio_rings()
Date: Mon, 2 Jun 2014 23:08:47 -0700
Message-ID: <1401775728-21043-3-git-send-email-mchan@broadcom.com>
References: <1401775728-21043-1-git-send-email-mchan@broadcom.com>
 <1401775728-21043-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <nhorman@tuxdriver.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:53004 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066AbaFCEsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 00:48:09 -0400
In-Reply-To: <1401775728-21043-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are allocating memory with GFP_KERNEL under spinlock.  Since this is
the only call manipulating the cnic_udev_list and it is always under
rtnl_lock, cnic_dev_lock can be safely removed.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index a0aae72..8da1060 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1039,21 +1039,17 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_uio_dev *udev;
 
-	read_lock(&cnic_dev_lock);
 	list_for_each_entry(udev, &cnic_udev_list, list) {
 		if (udev->pdev == dev->pcidev) {
 			udev->dev = dev;
 			if (__cnic_alloc_uio_rings(udev, pages)) {
 				udev->dev = NULL;
-				read_unlock(&cnic_dev_lock);
 				return -ENOMEM;
 			}
 			cp->udev = udev;
-			read_unlock(&cnic_dev_lock);
 			return 0;
 		}
 	}
-	read_unlock(&cnic_dev_lock);
 
 	udev = kzalloc(sizeof(struct cnic_uio_dev), GFP_ATOMIC);
 	if (!udev)
@@ -1067,9 +1063,7 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 	if (__cnic_alloc_uio_rings(udev, pages))
 		goto err_udev;
 
-	write_lock(&cnic_dev_lock);
 	list_add(&udev->list, &cnic_udev_list);
-	write_unlock(&cnic_dev_lock);
 
 	pci_dev_get(udev->pdev);
 
-- 
1.7.1
