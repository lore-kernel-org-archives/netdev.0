From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/5] cnic: Free UIO rings when the device is
 closed.
Date: Sat, 8 Sep 2012 09:01:02 -0700
Message-ID: <1347120065-26492-2-git-send-email-mchan@broadcom.com>
References: <1347120065-26492-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4056 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755302Ab2IHPs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 11:48:27 -0400
In-Reply-To: <1347120065-26492-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will free up unneeded memory.

Reviewed-by: Eddie Wai <eddie.wai@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index ff35894..38be4d9 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -868,6 +868,8 @@ static void cnic_free_resc(struct cnic_dev *dev)
 	if (udev) {
 		udev->dev = NULL;
 		cp->udev = NULL;
+		if (udev->uio_dev == -1)
+			__cnic_free_uio_rings(udev);
 	}
 
 	cnic_free_context(dev);
@@ -1039,6 +1041,11 @@ static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 	list_for_each_entry(udev, &cnic_udev_list, list) {
 		if (udev->pdev == dev->pcidev) {
 			udev->dev = dev;
+			if (__cnic_alloc_uio_rings(udev, pages)) {
+				udev->dev = NULL;
+				read_unlock(&cnic_dev_lock);
+				return -ENOMEM;
+			}
 			cp->udev = udev;
 			read_unlock(&cnic_dev_lock);
 			return 0;
-- 
1.7.1
