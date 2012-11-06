From: Wang Dongsheng <dongsheng.wang@freescale.com>
Subject: [PATCH] powerpc/gianfar: fix ethernet cannot work after restoring from hibernation
Date: Tue, 6 Nov 2012 14:04:08 +0800
Message-ID: <1352181848-24102-1-git-send-email-dongsheng.wang@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Wang Dongsheng <dongsheng.wang@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:45990
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750878Ab2KFGsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 01:48:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

we should make sure a ethernet has been taken down when system into hibernation
status. when the system restoring form hibernation, the ethernet cannot be
taken up.
eg:
~# ifconfig eth0 down
~# echo disk > /sys/power/state

hibernation restore

~# ifconfig eth0 up
SIOCSIFFLAGS: No such device

Signed-off-by: Wang Dongsheng <dongsheng.wang@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4605f72..487b944 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1345,8 +1345,11 @@ static int gfar_restore(struct device *dev)
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
1.7.5.1
