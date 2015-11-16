From: Pavel Fedin <p.fedin@samsung.com>
Subject: [PATCH v2] net: thunder: Fix crash upon shutdown after failed probe
Date: Mon, 16 Nov 2015 16:22:26 +0300
Message-ID: <1447680146-8680-1-git-send-email-p.fedin@samsung.com>
Cc: Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>, youngmin.lee@cavium.com,
	kin-yip.liu@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:12231 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbbKPNXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 08:23:46 -0500
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NXW005ULT70QI60@mailout1.w1.samsung.com> for
 netdev@vger.kernel.org; Mon, 16 Nov 2015 13:23:24 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If device probe fails, driver remains bound to the PCI device. However,
driver data has been reset to NULL. This causes crash upon dereferencing
it in nicvf_remove()

Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
---
v1 => v2:
- Do the test in nicvf_remove(), this allows to cover more situations
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index a937772..7f709cb 100644
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
-- 
2.4.4
