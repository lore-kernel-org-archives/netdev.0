From: Andy Duan <fugang.duan@nxp.com>
Subject: [PATCH net-next 1/2] net: fec: add interrupt coalesc quirk flag
Date: Wed, 22 Jun 2016 18:52:35 +0800
Message-ID: <1466592756-11239-2-git-send-email-fugang.duan@nxp.com>
References: <1466592756-11239-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <stephen@networkplumber.org>,
	<fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0086.outbound.protection.outlook.com ([157.56.110.86]:36902
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751878AbcFVL0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 07:26:53 -0400
In-Reply-To: <1466592756-11239-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Different i.MX SOC FEC support different features like :
- i.MX6Q/DL FEC does not support AVB and interrupt coalesc
- i.MX6SX/i.MX7D supports AVB and interrupt coalesc
- i.MX6UL/ULL does not support AVB, but support interrupt coalesc

So, add new quirk flag to judge the supported features.

Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
---
 drivers/net/ethernet/freescale/fec.h      |  2 ++
 drivers/net/ethernet/freescale/fec_main.c | 19 +++++++++----------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index f58f9ea..92fd5c0 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -442,6 +442,8 @@ struct bufdesc_ex {
 #define FEC_QUIRK_SINGLE_MDIO		(1 << 11)
 /* Controller supports RACC register */
 #define FEC_QUIRK_HAS_RACC		(1 << 12)
+/* Controller supports interrupt coalesc */
+#define FEC_QUIRK_HAS_COALESCE		(1 << 13)
 
 struct bufdesc_prop {
 	int qid;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index c36401e..8afef20 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -111,7 +111,7 @@ static struct platform_device_id fec_devtype[] = {
 				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
 				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_HAS_AVB |
 				FEC_QUIRK_ERR007885 | FEC_QUIRK_BUG_CAPTURE |
-				FEC_QUIRK_HAS_RACC,
+				FEC_QUIRK_HAS_RACC | FEC_QUIRK_HAS_COALESCE,
 	}, {
 		/* sentinel */
 	}
@@ -2358,9 +2358,6 @@ static void fec_enet_itr_coal_set(struct net_device *ndev)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	int rx_itr, tx_itr;
 
-	if (!(fep->quirks & FEC_QUIRK_HAS_AVB))
-		return;
-
 	/* Must be greater than zero to avoid unpredictable behavior */
 	if (!fep->rx_time_itr || !fep->rx_pkts_itr ||
 	    !fep->tx_time_itr || !fep->tx_pkts_itr)
@@ -2383,10 +2380,12 @@ static void fec_enet_itr_coal_set(struct net_device *ndev)
 
 	writel(tx_itr, fep->hwp + FEC_TXIC0);
 	writel(rx_itr, fep->hwp + FEC_RXIC0);
-	writel(tx_itr, fep->hwp + FEC_TXIC1);
-	writel(rx_itr, fep->hwp + FEC_RXIC1);
-	writel(tx_itr, fep->hwp + FEC_TXIC2);
-	writel(rx_itr, fep->hwp + FEC_RXIC2);
+	if (fep->quirks & FEC_QUIRK_HAS_AVB) {
+		writel(tx_itr, fep->hwp + FEC_TXIC1);
+		writel(rx_itr, fep->hwp + FEC_RXIC1);
+		writel(tx_itr, fep->hwp + FEC_TXIC2);
+		writel(rx_itr, fep->hwp + FEC_RXIC2);
+	}
 }
 
 static int
@@ -2394,7 +2393,7 @@ fec_enet_get_coalesce(struct net_device *ndev, struct ethtool_coalesce *ec)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
-	if (!(fep->quirks & FEC_QUIRK_HAS_AVB))
+	if (!(fep->quirks & FEC_QUIRK_HAS_COALESCE))
 		return -EOPNOTSUPP;
 
 	ec->rx_coalesce_usecs = fep->rx_time_itr;
@@ -2412,7 +2411,7 @@ fec_enet_set_coalesce(struct net_device *ndev, struct ethtool_coalesce *ec)
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	unsigned int cycle;
 
-	if (!(fep->quirks & FEC_QUIRK_HAS_AVB))
+	if (!(fep->quirks & FEC_QUIRK_HAS_COALESCE))
 		return -EOPNOTSUPP;
 
 	if (ec->rx_max_coalesced_frames > 255) {
-- 
1.9.1
