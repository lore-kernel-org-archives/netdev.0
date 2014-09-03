From: Frank Li <Frank.Li@freescale.com>
Subject: [Patch net-next 05/11] net:fec: Disable enet-avb MAC instead of reset MAC
Date: Thu, 4 Sep 2014 04:38:11 +0800
Message-ID: <1409776697-1536-6-git-send-email-Frank.Li@freescale.com>
References: <1409776697-1536-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, Fugang Duan <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0142.outbound.protection.outlook.com ([207.46.163.142]:45115
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755858AbaICVAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 17:00:00 -0400
In-Reply-To: <1409776697-1536-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>

For i.MX6SX enet use AXI bus, reset MAC will make system bus dead
if ENET-AXI bus has pending access (AHB bus should not have such issue).
So, disable enet with AVB MAC instead of reset MAC itself.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f973a92..5dab6a6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -948,9 +948,16 @@ fec_restart(struct net_device *ndev)
 	u32 ecntl = 0x2; /* ETHEREN */
 	int i;
 
-	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
-	udelay(10);
+	/* Whack a reset.  We should wait for this.
+	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
+	 * instead of reset MAC itself.
+	 */
+	if (id_entry && id_entry->driver_data & FEC_QUIRK_HAS_AVB) {
+		writel(0, fep->hwp + FEC_ECNTRL);
+	} else {
+		writel(1, fep->hwp + FEC_ECNTRL);
+		udelay(10);
+	}
 
 	/*
 	 * enet-mac reset will reset mac address registers too,
@@ -1122,9 +1129,16 @@ fec_stop(struct net_device *ndev)
 			netdev_err(ndev, "Graceful transmit stop did not complete!\n");
 	}
 
-	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
-	udelay(10);
+	/* Whack a reset.  We should wait for this.
+	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
+	 * instead of reset MAC itself.
+	 */
+	if (id_entry && id_entry->driver_data & FEC_QUIRK_HAS_AVB) {
+		writel(0, fep->hwp + FEC_ECNTRL);
+	} else {
+		writel(1, fep->hwp + FEC_ECNTRL);
+		udelay(10);
+	}
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 
-- 
1.9.1
