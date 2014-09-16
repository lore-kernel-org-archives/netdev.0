From: <Frank.Li@freescale.com>
Subject: [Patch net-next v2 2/4] net: fec: add interrupt coalescence feature support
Date: Wed, 17 Sep 2014 01:58:08 +0800
Message-ID: <1410890290-11248-3-git-send-email-Frank.Li@freescale.com>
References: <1410890290-11248-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	"Fugang Duan" <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0111.outbound.protection.outlook.com ([157.56.110.111]:16928
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755020AbaIPTCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 15:02:24 -0400
In-Reply-To: <1410890290-11248-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>

i.MX6 SX support interrupt coalescence feature
By default, init the interrupt coalescing frame count threshold and
timer threshold.

Supply the ethtool interfaces as below for user tuning to improve
enet performance:
	rx_max_coalesced_frames
	rx_coalesce_usecs
	tx_max_coalesced_frames
	tx_coalesce_usecs

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |  14 ++++
 drivers/net/ethernet/freescale/fec_main.c | 110 ++++++++++++++++++++++++++++++
 2 files changed, 124 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index b7c7722..bd70811 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -335,6 +335,14 @@ struct bufdesc_ex {
 #define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII | FEC_ENET_TS_TIMER)
 #define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK & (~FEC_ENET_RXF))
 
+/* ENET interrupt coalescing macro define */
+#define FEC_ITR_CLK_SEL		(0x1 << 30)
+#define FEC_ITR_EN		(0x1 << 31)
+#define FEC_ITR_ICFT(X)		((X & 0xFF) << 20)
+#define FEC_ITR_ICTT(X)		((X) & 0xFFFF)
+#define FEC_ITR_ICFT_DEFAULT	200  /* Set 200 frame count threshold */
+#define FEC_ITR_ICTT_DEFAULT	1000 /* Set 1000us timer threshold */
+
 #define FEC_VLAN_TAG_LEN       0x04
 #define FEC_ETHTYPE_LEN                0x02
 
@@ -446,6 +454,12 @@ struct fec_enet_private {
 
 	unsigned int tx_align;
 	unsigned int rx_align;
+
+	/* hw interrupt coalesce */
+	unsigned int rx_pkts_itr;
+	unsigned int rx_time_itr;
+	unsigned int tx_pkts_itr;
+	unsigned int tx_time_itr;
 };
 
 void fec_ptp_init(struct platform_device *pdev);
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index d209d2e..3a735ef 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -63,6 +63,7 @@
 #include "fec.h"
 
 static void set_multicast_list(struct net_device *ndev);
+static void fec_enet_itr_coal_init(struct net_device *ndev);
 
 #define DRIVER_NAME	"fec"
 
@@ -1095,6 +1096,10 @@ fec_restart(struct net_device *ndev)
 
 	/* Enable interrupts we wish to service */
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+
+	/* Init the interrupt coalescing */
+	fec_enet_itr_coal_init(ndev);
+
 }
 
 static void
@@ -2234,12 +2239,117 @@ static int fec_enet_nway_reset(struct net_device *dev)
 	return genphy_restart_aneg(phydev);
 }
 
+/* ITR clock source is enet system clock (clk_ahb).
+ * TCTT unit is cycle_ns * 64 cycle
+ * So, the ICTT value = X us / (cycle_ns * 64)
+ */
+static int fec_enet_us_to_itr_clock(struct net_device *ndev, int us)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	return us * (clk_get_rate(fep->clk_ahb) / 64000) / 1000;
+}
+
+/* Set threshold for interrupt coalescing */
+static void fec_enet_itr_coal_set(struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
+	int rx_itr, tx_itr;
+
+	if (!(id_entry->driver_data & FEC_QUIRK_HAS_AVB))
+		return;
+
+	/* Must be greater than zero to avoid unpredictable behavior */
+	if (!fep->rx_time_itr || !fep->rx_pkts_itr ||
+	    !fep->tx_time_itr || !fep->tx_pkts_itr)
+		return;
+
+	/* Select enet system clock as Interrupt Coalescing
+	 * timer Clock Source
+	 */
+	rx_itr = FEC_ITR_CLK_SEL;
+	tx_itr = FEC_ITR_CLK_SEL;
+
+	/* set ICFT and ICTT */
+	rx_itr |= FEC_ITR_ICFT(fep->rx_pkts_itr);
+	rx_itr |= FEC_ITR_ICTT(fec_enet_us_to_itr_clock(ndev, fep->rx_time_itr));
+	tx_itr |= FEC_ITR_ICFT(fep->tx_pkts_itr);
+	tx_itr |= FEC_ITR_ICTT(fec_enet_us_to_itr_clock(ndev, fep->tx_time_itr));
+
+	rx_itr |= FEC_ITR_EN;
+	tx_itr |= FEC_ITR_EN;
+
+	writel(tx_itr, fep->hwp + FEC_TXIC0);
+	writel(rx_itr, fep->hwp + FEC_RXIC0);
+	writel(tx_itr, fep->hwp + FEC_TXIC1);
+	writel(rx_itr, fep->hwp + FEC_RXIC1);
+	writel(tx_itr, fep->hwp + FEC_TXIC2);
+	writel(rx_itr, fep->hwp + FEC_RXIC2);
+}
+
+static int
+fec_enet_get_coalesce(struct net_device *ndev, struct ethtool_coalesce *ec)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
+
+	if (!(id_entry->driver_data & FEC_QUIRK_HAS_AVB))
+		return -EOPNOTSUPP;
+
+	ec->rx_coalesce_usecs = fep->rx_time_itr;
+	ec->rx_max_coalesced_frames = fep->rx_pkts_itr;
+
+	ec->tx_coalesce_usecs = fep->tx_time_itr;
+	ec->tx_max_coalesced_frames = fep->tx_pkts_itr;
+
+	return 0;
+}
+
+static int
+fec_enet_set_coalesce(struct net_device *ndev, struct ethtool_coalesce *ec)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	const struct platform_device_id *id_entry =
+				platform_get_device_id(fep->pdev);
+
+	if (!(id_entry->driver_data & FEC_QUIRK_HAS_AVB))
+		return -EOPNOTSUPP;
+
+	fep->rx_time_itr = ec->rx_coalesce_usecs;
+	fep->rx_pkts_itr = ec->rx_max_coalesced_frames;
+
+	fep->tx_time_itr = ec->tx_coalesce_usecs;
+	fep->tx_pkts_itr = ec->tx_max_coalesced_frames;
+
+	fec_enet_itr_coal_set(ndev);
+
+	return 0;
+}
+
+static void fec_enet_itr_coal_init(struct net_device *ndev)
+{
+	struct ethtool_coalesce ec;
+
+	ec.rx_coalesce_usecs = FEC_ITR_ICTT_DEFAULT;
+	ec.rx_max_coalesced_frames = FEC_ITR_ICFT_DEFAULT;
+
+	ec.tx_coalesce_usecs = FEC_ITR_ICTT_DEFAULT;
+	ec.tx_max_coalesced_frames = FEC_ITR_ICFT_DEFAULT;
+
+	fec_enet_set_coalesce(ndev, &ec);
+}
+
 static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
 	.nway_reset		= fec_enet_nway_reset,
 	.get_link		= ethtool_op_get_link,
+	.get_coalesce		= fec_enet_get_coalesce,
+	.set_coalesce		= fec_enet_set_coalesce,
 #ifndef CONFIG_M5272
 	.get_pauseparam		= fec_enet_get_pauseparam,
 	.set_pauseparam		= fec_enet_set_pauseparam,
-- 
1.9.1
