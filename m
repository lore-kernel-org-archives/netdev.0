From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/1] net: fec: fix crash at mx53 qsb board
Date: Thu, 21 Feb 2013 09:07:28 +0800
Message-ID: <1361408848-14118-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<s.hauer@pengutronix.de>, <festevam@gmail.com>,
	Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe004.messaging.microsoft.com ([213.199.154.142]:20663
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752390Ab3BUCIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 21:08:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unable to handle kernel NULL pointer dereference at virtual address 00000002
pgd = 80004000
[00000002] *pgd=00000000
Internal error: Oops: 5 [#1] SMP ARM
Modules linked in:
CPU: 0    Not tainted  (3.8.0-rc7-next-20130215+ #346)
PC is at fec_enet_interrupt+0xd0/0x348
LR is at fec_enet_interrupt+0xb8/0x348
pc : [<80372b7c>]    lr : [<80372b64>]    psr: 60000193
sp : df855c20  ip : df855c20  fp : df855c74
r10: 00000516  r9 : 1c000000  r8 : 00000000
r7 : 00000000  r6 : 00000000  r5 : 00000000  r4 : df9b7800
r3 : df9b7df4  r2 : 00000000  r1 : 00000000  r0 : df9b7d34

It is possible that issue a irq between request_irq and fec_enet_init.
Irq handle will be called but driver data structure is not ready yet.

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 7c6e890..a860486 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1676,7 +1676,6 @@ static int fec_enet_init(struct net_device *ndev)
 	ndev->netdev_ops = &fec_netdev_ops;
 	ndev->ethtool_ops = &fec_enet_ethtool_ops;
 
-	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
 	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
 
 	/* Init enet descriptors */
@@ -1786,6 +1785,13 @@ fec_probe(struct platform_device *pdev)
 	fep->pdev = pdev;
 	fep->dev_id = dev_id++;
 
+	/*
+	 * disable and clean all irq to avoid unexpected irq happen
+	 * between init driver data structure and request_irq
+	 */
+	writel(0, fep->hwp + FEC_IMASK);
+	writel(0xFFFFFFFF, fep->hwp + FEC_IEVENT);
+
 	fep->bufdesc_ex = 0;
 
 	if (!fep->hwp) {
-- 
1.7.1
