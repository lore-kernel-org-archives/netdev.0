From: Andrei Pistirica <andrei.pistirica@microchip.com>
Subject: [RFC PATCH net-next v3 2/2] macb: Enable 1588 support in SAMA5Dx platforms.
Date: Wed, 7 Dec 2016 20:21:52 +0200
Message-ID: <1481134912-2243-2-git-send-email-andrei.pistirica@microchip.com>
References: <1481134912-2243-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <punnaia@xilinx.com>, <michals@xilinx.com>, <anirudh@xilinx.com>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>, <tbultel@pixelsurmer.com>,
        <richardcochran@gmail.com>, <rafalo@cadence.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
        <nicolas.ferre@atmel.com>, <harinikatakamlinux@gmail.com>,
        <harini.katakam@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:61895 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752807AbcLGP0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 10:26:07 -0500
In-Reply-To: <1481134912-2243-1-git-send-email-andrei.pistirica@microchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does the following:
- Enable HW time stamp for the following platforms: SAMA5D2, SAMA5D3 and
  SAMA5D4.
- HW time stamp capabilities are advertised via ethtool and macb ioctl is
  updated accordingly.
- HW time stamp on the PTP Ethernet packets are received using the
  SO_TIMESTAMPING API. Where timers are obtained from the PTP event/peer
  registers.

Note: Patch on net-next, on December 7th.

Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
---
Patch history:

Version 1:
Integration with SAMA5D2 only. This feature wasn't tested on any
other platform that might use cadence/gem.

Patch is not completely ported to the very latest version of net-next,
and it will be after review.

Version 2 modifications:
- add PTP caps for SAMA5D2/3/4 platforms
- and cosmetic changes

Version 3 modifications:
- add support for sama5D2/3/4 platforms using GEM-PTP interface.

 drivers/net/ethernet/cadence/macb.c | 165 ++++++++++++++++++++++++++++++++++--
 1 file changed, 160 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 538544a..e2d4983 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -714,6 +714,8 @@ static void macb_tx_interrupt(struct macb_queue *queue)
 
 			/* First, update TX stats if needed */
 			if (skb) {
+				gem_ptp_do_txstamp(bp, skb);
+
 				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
 					    macb_tx_ring_wrap(bp, tail),
 					    skb->data);
@@ -878,6 +880,8 @@ static int gem_rx(struct macb *bp, int budget)
 		    GEM_BFEXT(RX_CSUM, ctrl) & GEM_RX_CSUM_CHECKED_MASK)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+		gem_ptp_do_rxstamp(bp, skb);
+
 		bp->stats.rx_packets++;
 		bp->stats.rx_bytes += skb->len;
 
@@ -2080,6 +2084,9 @@ static int macb_open(struct net_device *dev)
 
 	netif_tx_start_all_queues(dev);
 
+	if (bp->ptp_info)
+		bp->ptp_info->ptp_init(dev);
+
 	return 0;
 }
 
@@ -2101,6 +2108,9 @@ static int macb_close(struct net_device *dev)
 
 	macb_free_consistent(bp);
 
+	if (bp->ptp_info)
+		bp->ptp_info->ptp_remove(dev);
+
 	return 0;
 }
 
@@ -2374,6 +2384,130 @@ static int macb_set_ringparam(struct net_device *netdev,
 	return 0;
 }
 
+#ifdef CONFIG_MACB_USE_HWSTAMP
+static unsigned int gem_get_tsu_rate(struct macb *bp)
+{
+	/* Note: TSU rate is hardwired to PCLK. */
+	return clk_get_rate(bp->pclk);
+}
+
+static int gem_get_ts_info(struct net_device *dev,
+			   struct ethtool_ts_info *info)
+{
+	struct macb *bp = netdev_priv(dev);
+
+	ethtool_op_get_ts_info(dev, info);
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE |
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+	info->phc_index = -1;
+
+	if (bp->ptp_clock)
+		info->phc_index = ptp_clock_index(bp->ptp_clock);
+
+	return 0;
+}
+
+static int gem_hwtst_set(struct net_device *netdev,
+			 struct ifreq *ifr, int cmd)
+{
+	struct hwtstamp_config config;
+	struct macb *priv = netdev_priv(netdev);
+	u32 regval;
+
+	netdev_vdbg(netdev, "macb_hwtstamp_ioctl\n");
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		priv->hwts_tx_en = false;
+		break;
+	case HWTSTAMP_TX_ON:
+		priv->hwts_tx_en = true;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		if (priv->hwts_rx_en)
+			priv->hwts_rx_en = 0;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
+		regval = macb_readl(priv, NCR);
+		macb_writel(priv, NCR, (regval | MACB_BIT(SRTSM)));
+
+		if (!priv->hwts_rx_en)
+			priv->hwts_rx_en = 1;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
+}
+
+static int gem_hwtst_get(struct net_device *netdev,
+			 struct ifreq *ifr)
+{
+	struct hwtstamp_config config;
+	struct macb *priv = netdev_priv(netdev);
+
+	config.flags = 0;
+	config.tx_type = priv->hwts_tx_en ? HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
+	config.rx_filter = (priv->hwts_rx_en ?
+			    HWTSTAMP_FILTER_ALL : HWTSTAMP_FILTER_NONE);
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
+}
+
+static struct macb_ptp_info gem_ptp_info = {
+	.ptp_init	= gem_ptp_init,
+	.ptp_remove	= gem_ptp_remove,
+	.get_tsu_rate	= gem_get_tsu_rate,
+	.get_ts_info	= gem_get_ts_info,
+	.hwtst_get	= gem_hwtst_get,
+	.hwtst_set	= gem_hwtst_set,
+};
+#endif
+
+static int macb_get_ts_info(struct net_device *netdev,
+			    struct ethtool_ts_info *info)
+{
+	struct macb *bp = netdev_priv(netdev);
+
+	if (bp->ptp_info)
+		return bp->ptp_info->get_ts_info(netdev, info);
+
+	return ethtool_op_get_ts_info(netdev, info);
+}
+
 static const struct ethtool_ops macb_ethtool_ops = {
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
@@ -2391,7 +2525,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
-	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_ts_info		= macb_get_ts_info,
 	.get_ethtool_stats	= gem_get_ethtool_stats,
 	.get_strings		= gem_get_ethtool_strings,
 	.get_sset_count		= gem_get_sset_count,
@@ -2404,6 +2538,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct phy_device *phydev = dev->phydev;
+	struct macb *bp = netdev_priv(dev);
 
 	if (!netif_running(dev))
 		return -EINVAL;
@@ -2411,7 +2546,20 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(phydev, rq, cmd);
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		if (bp->ptp_info)
+			return bp->ptp_info->hwtst_set(dev, rq, cmd);
+
+		return -EOPNOTSUPP;
+	case SIOCGHWTSTAMP:
+		if (bp->ptp_info)
+			return bp->ptp_info->hwtst_get(dev, rq);
+
+		return -EOPNOTSUPP;
+	default:
+		return phy_mii_ioctl(phydev, rq, cmd);
+	}
 }
 
 static int macb_set_features(struct net_device *netdev,
@@ -2485,6 +2633,12 @@ static void macb_configure_caps(struct macb *bp,
 		dcfg = gem_readl(bp, DCFG2);
 		if ((dcfg & (GEM_BIT(RX_PKT_BUFF) | GEM_BIT(TX_PKT_BUFF))) == 0)
 			bp->caps |= MACB_CAPS_FIFO_MODE;
+
+		/* iff HWSTAMP is configure and gem has the capability */
+#ifdef CONFIG_MACB_USE_HWSTAMP
+		if (gem_has_ptp(bp))
+			bp->ptp_info = &gem_ptp_info;
+#endif
 	}
 
 	dev_dbg(&bp->pdev->dev, "Cadence caps 0x%08x\n", bp->caps);
@@ -3041,7 +3195,7 @@ static const struct macb_config pc302gem_config = {
 };
 
 static const struct macb_config sama5d2_config = {
-	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
+	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII | MACB_CAPS_GEM_HAS_PTP,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
@@ -3049,14 +3203,15 @@ static const struct macb_config sama5d2_config = {
 
 static const struct macb_config sama5d3_config = {
 	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE
-	      | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
+	      | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII
+	      | MACB_CAPS_GEM_HAS_PTP,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
 
 static const struct macb_config sama5d4_config = {
-	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
+	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII | MACB_CAPS_GEM_HAS_PTP,
 	.dma_burst_length = 4,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
-- 
2.7.4
