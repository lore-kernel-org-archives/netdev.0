From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH] gianfar: ethernet vanishes after restoring from hibernation
Date: Fri,  9 Nov 2012 09:43:51 -0500
Message-ID: <1352472231-17927-1-git-send-email-paul.gortmaker@windriver.com>
References: <1352181848-24102-1-git-send-email-dongsheng.wang@freescale.com>
Cc: Wang Dongsheng <dongsheng.wang@freescale.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42625 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630Ab2KIOoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 09:44:09 -0500
In-Reply-To: <1352181848-24102-1-git-send-email-dongsheng.wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Dongsheng <dongsheng.wang@freescale.com>

If a gianfar ethernet device is down prior to hibernating a
system, it will no longer be present upon system restore.

For example:

	~# ifconfig eth0 down
	~# echo disk > /sys/power/state

	  <trigger a restore from hibernation>

	~# ifconfig eth0 up
	SIOCSIFFLAGS: No such device

This happens because the restore function bails out early upon
finding devices that were not up at hibernation.  In doing so,
it never gets to the netif_device_attach call at the end of
the restore function.  Adding the netif_device_attach as done
here also makes the gfar_restore code consistent with what is
done in the gfar_resume code.

Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
Signed-off-by: Wang Dongsheng <dongsheng.wang@freescale.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
[v2: expand on details in commit log a bit more, to superceed
 v1 at http://patchwork.ozlabs.org/patch/197412/ ]

 drivers/net/ethernet/freescale/gianfar.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 1d03dcd..19ac096 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1353,8 +1353,11 @@ static int gfar_restore(struct device *dev)
 	struct gfar_private *priv = dev_get_drvdata(dev);
 	struct net_device *ndev = priv->ndev;
 
-	if (!netif_running(ndev))
+	if (!netif_running(ndev)) {
+		netif_device_attach(ndev);
+
 		return 0;
+	}
 
 	gfar_init_bds(ndev);
 	init_registers(ndev);
-- 
1.8.0
