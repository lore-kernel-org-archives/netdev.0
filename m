From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v3 04/10] net/fec: improve pm for better suspend/resume
Date: Wed, 5 Jan 2011 22:07:31 +0800
Message-ID: <1294236457-17476-5-git-send-email-shawn.guo@freescale.com>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shawn Guo <shawn.guo@freescale.com>
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:23744 "EHLO
	TX2EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026Ab1AEOGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 09:06:21 -0500
In-Reply-To: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following commit made a fix to use fec_enet_open/fec_enet_close
over fec_enet_init/fec_stop for suspend/resume, because fec_enet_init
does not allow to have a working network interface at resume.

  e3fe8558c7fc182972c3d947d88744482111f304
  net/fec: fix pm to survive to suspend/resume

This fix works for i.mx/mxc fec controller, but fails on mx28 fec
which gets a different interrupt logic design. On i.mx fec, interrupt
can be triggered even bit ETHER_EN of ECR register is not set. But
on mx28 fec, ETHER_EN must be set to get interrupt work. Meanwhile,
MII interrupt is mandatory to resume the driver, because MDIO
read/write changed to interrupt mode by commit below.

  97b72e4320a9aaa4a7f1592ee7d2da7e2c9bd349
  fec: use interrupt for MDIO completion indication

fec_restart/fec_stop comes out as the solution working for both
cases.

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
 drivers/net/fec.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 47a3c7b..8a1c51f 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1372,8 +1372,10 @@ fec_suspend(struct device *dev)
 
 	if (ndev) {
 		fep = netdev_priv(ndev);
-		if (netif_running(ndev))
-			fec_enet_close(ndev);
+		if (netif_running(ndev)) {
+			fec_stop(ndev);
+			netif_device_detach(ndev);
+		}
 		clk_disable(fep->clk);
 	}
 	return 0;
@@ -1388,8 +1390,10 @@ fec_resume(struct device *dev)
 	if (ndev) {
 		fep = netdev_priv(ndev);
 		clk_enable(fep->clk);
-		if (netif_running(ndev))
-			fec_enet_open(ndev);
+		if (netif_running(ndev)) {
+			fec_restart(ndev, fep->full_duplex);
+			netif_device_attach(ndev);
+		}
 	}
 	return 0;
 }
-- 
1.7.1


