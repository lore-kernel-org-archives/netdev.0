From: Pavel Fedin <p.fedin@samsung.com>
Subject: [PATCH] net: thunder: Check for driver data in nicvf_remove()
Date: Mon, 16 Nov 2015 17:51:34 +0300
Message-ID: <1447685494-9836-1-git-send-email-p.fedin@samsung.com>
Cc: Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>, youngmin.lee@cavium.com,
	kin-yip.liu@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:18383 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbbKPOvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 09:51:42 -0500
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NXW006BTXA4H790@mailout1.w1.samsung.com> for
 netdev@vger.kernel.org; Mon, 16 Nov 2015 14:51:40 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases the crash is caused by nicvf_remove() being called from
outside. For example, if we try to feed the device to vfio after the
probe has failed for some reason. So, move the check to better place.

Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 372c39e..7f709cb 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1583,8 +1583,14 @@ err_disable_device:
 static void nicvf_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct nicvf *nic = netdev_priv(netdev);
-	struct net_device *pnetdev = nic->pnicvf->netdev;
+	struct nicvf *nic;
+	struct net_device *pnetdev;
+
+	if (!netdev)
+		return;
+
+	nic = netdev_priv(netdev);
+	pnetdev = nic->pnicvf->netdev;
 
 	/* Check if this Qset is assigned to different VF.
 	 * If yes, clean primary and all secondary Qsets.
@@ -1600,9 +1606,6 @@ static void nicvf_remove(struct pci_dev *pdev)
 
 static void nicvf_shutdown(struct pci_dev *pdev)
 {
-	if (!pci_get_drvdata(pdev))
-		return;
-
 	nicvf_remove(pdev);
 }
 
-- 
2.4.4
