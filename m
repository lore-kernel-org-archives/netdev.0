From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH] net: fec: enable hardware checksum only on imx6q-fec
Date: Thu, 9 May 2013 15:08:22 +0800
Message-ID: <1368083302-12516-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jim Baxter <jim_baxter@mentor.com>, <kernel@pengutronix.de>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:6807
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750821Ab3EIHIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 03:08:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4c09eed (net: fec: Enable imx6 enet checksum acceleration.)
enables hardware checksum acceleration unconditionally for all fec
variants.  This is inappropriate, because some variants like imx5 have
no such support on hardware.  Consequently, fec is broken on these
platforms.  Fix it by enabling hardware checksum only on imx6q-fec type
of controllers.

Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
---
 drivers/net/ethernet/freescale/fec_main.c |   20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e25bf83..9ffa428 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -87,6 +87,8 @@
 #define FEC_QUIRK_HAS_GBIT		(1 << 3)
 /* Controller has extend desc buffer */
 #define FEC_QUIRK_HAS_BUFDESC_EX	(1 << 4)
+/* Controller has hardware checksum support */
+#define FEC_QUIRK_HAS_CSUM		(1 << 5)
 
 static struct platform_device_id fec_devtype[] = {
 	{
@@ -105,7 +107,7 @@ static struct platform_device_id fec_devtype[] = {
 	}, {
 		.name = "imx6q-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
-				FEC_QUIRK_HAS_BUFDESC_EX,
+				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM,
 	}, {
 		.name = "mvf-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC,
@@ -1723,6 +1725,8 @@ static const struct net_device_ops fec_netdev_ops = {
 static int fec_enet_init(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
 	struct bufdesc *cbd_base;
 
 	/* Allocate memory for buffer descriptors. */
@@ -1755,12 +1759,14 @@ static int fec_enet_init(struct net_device *ndev)
 	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
 	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
 
-	/* enable hw accelerator */
-	ndev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
-			| NETIF_F_RXCSUM);
-	ndev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
-			| NETIF_F_RXCSUM);
-	fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
+	if (id_entry->driver_data & FEC_QUIRK_HAS_CSUM) {
+		/* enable hw accelerator */
+		ndev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
+				| NETIF_F_RXCSUM);
+		ndev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
+				| NETIF_F_RXCSUM);
+		fep->csum_flags |= FLAG_RX_CSUM_ENABLED;
+	}
 
 	fec_restart(ndev, 0);
 
-- 
1.7.9.5
