From: Andrei Pistirica <andrei.pistirica@microchip.com>
Subject: [RFC PATCH v2 2/2] macb: Enable 1588 support in SAMA5D2 platform.
Date: Fri, 18 Nov 2016 15:21:52 +0100
Message-ID: <1479478912-14067-2-git-send-email-andrei.pistirica@microchip.com>
References: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <punnaia@xilinx.com>, <michals@xilinx.com>, <anirudh@xilinx.com>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>, <tbultel@pixelsurmer.com>,
        <richardcochran@gmail.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
        <nicolas.ferre@atmel.com>, <harinikatakamlinux@gmail.com>,
        <harini.katakam@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:51196 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753651AbcKROZn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 09:25:43 -0500
In-Reply-To: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware time stamp on the PTP Ethernet packets are received using the
SO_TIMESTAMPING API. Where timers are obtained from the PTP event/peer
registers.

Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
---
Version 2 patch for: https://patchwork.kernel.org/patch/9310991/
Modificaions:
- add PTP caps for SAMA5D2/3/4 platforms
- and cosmetic changes

 drivers/net/ethernet/cadence/macb.c     |  24 +++-
 drivers/net/ethernet/cadence/macb.h     |  13 ++
 drivers/net/ethernet/cadence/macb_ptp.c | 222 ++++++++++++++++++++++++++++++++
 3 files changed, 254 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index d975882..eb66b76 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -697,6 +697,8 @@ static void macb_tx_interrupt(struct macb_queue *queue)
 
 			/* First, update TX stats if needed */
 			if (skb) {
+				macb_ptp_do_txstamp(bp, skb);
+
 				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
 					    macb_tx_ring_wrap(tail), skb->data);
 				bp->stats.tx_packets++;
@@ -853,6 +855,8 @@ static int gem_rx(struct macb *bp, int budget)
 		    GEM_BFEXT(RX_CSUM, ctrl) & GEM_RX_CSUM_CHECKED_MASK)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+		macb_ptp_do_rxstamp(bp, skb);
+
 		bp->stats.rx_packets++;
 		bp->stats.rx_bytes += skb->len;
 
@@ -1946,6 +1950,8 @@ static int macb_open(struct net_device *dev)
 
 	netif_tx_start_all_queues(dev);
 
+	macb_ptp_init(dev);
+
 	return 0;
 }
 
@@ -2204,7 +2210,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
-	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_ts_info		= macb_get_ts_info,
 	.get_ethtool_stats	= gem_get_ethtool_stats,
 	.get_strings		= gem_get_ethtool_strings,
 	.get_sset_count		= gem_get_sset_count,
@@ -2221,7 +2227,14 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_mii_ioctl(phydev, rq, cmd);
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return macb_hwtst_set(dev, rq, cmd);
+	case SIOCGHWTSTAMP:
+		return macb_hwtst_get(dev, rq);
+	default:
+		return phy_mii_ioctl(phydev, rq, cmd);
+	}
 }
 
 static int macb_set_features(struct net_device *netdev,
@@ -2812,7 +2825,7 @@ static const struct macb_config pc302gem_config = {
 };
 
 static const struct macb_config sama5d2_config = {
-	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
+	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII | MACB_CAPS_GEM_HAS_PTP,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
@@ -2820,14 +2833,15 @@ static const struct macb_config sama5d2_config = {
 
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
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 2ee9af8..3ac824a 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -918,8 +918,21 @@ struct macb {
 
 #ifdef CONFIG_MACB_USE_HWSTAMP
 void macb_ptp_init(struct net_device *ndev);
+void macb_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb);
+void macb_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb);
+int macb_ptp_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info);
+#define macb_get_ts_info macb_ptp_get_ts_info
+int macb_hwtst_set(struct net_device *netdev, struct ifreq *ifr, int cmd);
+int macb_hwtst_get(struct net_device *netdev, struct ifreq *ifr);
 #else
 void macb_ptp_init(struct net_device *ndev) { }
+void macb_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb) { }
+void macb_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb) { }
+#define macb_get_ts_info ethtool_op_get_ts_info
+int macb_hwtst_set(struct net_device *netdev, struct ifreq *ifr, int cmd)
+	{ return -EOPNOTSUPP; }
+int macb_hwtst_get(struct net_device *netdev, struct ifreq *ifr)
+	{ return -EOPNOTSUPP; }
 #endif
 
 static inline bool macb_is_gem(struct macb *bp)
diff --git a/drivers/net/ethernet/cadence/macb_ptp.c b/drivers/net/ethernet/cadence/macb_ptp.c
index 81ce3a9..f476b55 100644
--- a/drivers/net/ethernet/cadence/macb_ptp.c
+++ b/drivers/net/ethernet/cadence/macb_ptp.c
@@ -227,3 +227,225 @@ void macb_ptp_init(struct net_device *ndev)
 	dev_info(&bp->pdev->dev, "%s ptp clock registered.\n", GMAC_TIMER_NAME);
 }
 
+/* While the GEM can timestamp PTP packets, it does not mark the RX descriptor
+ * to identify them. UDP packets must be parsed to identify PTP packets.
+ *
+ * Note: Inspired from drivers/net/ethernet/ti/cpts.c
+ */
+static int macb_get_ptp_peer(struct sk_buff *skb, int ptp_class)
+{
+	unsigned int offset = 0;
+	u8 *msgtype, *data = skb->data;
+
+	/* PTP frames are rare! */
+	if (likely(ptp_class == PTP_CLASS_NONE))
+		return -1;
+
+	if (ptp_class & PTP_CLASS_VLAN)
+		offset += VLAN_HLEN;
+
+	switch (ptp_class & PTP_CLASS_PMASK) {
+	case PTP_CLASS_IPV4:
+		offset += ETH_HLEN + IPV4_HLEN(data + offset) + UDP_HLEN;
+	break;
+	case PTP_CLASS_IPV6:
+		offset += ETH_HLEN + IP6_HLEN + UDP_HLEN;
+	break;
+	case PTP_CLASS_L2:
+		offset += ETH_HLEN;
+		break;
+
+	/* something went wrong! */
+	default:
+		return -1;
+	}
+
+	if (skb->len + ETH_HLEN < offset + OFF_PTP_SEQUENCE_ID)
+		return -1;
+
+	if (unlikely(ptp_class & PTP_CLASS_V1))
+		msgtype = data + offset + OFF_PTP_CONTROL;
+	else
+		msgtype = data + offset;
+
+	return (*msgtype) & 0x2;
+}
+
+static void macb_ptp_tx_hwtstamp(struct macb *bp, struct sk_buff *skb,
+					int peer_ev)
+{
+	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
+	struct timespec64 ts;
+	u64 ns;
+
+	/* PTP Peer Event Frame packets */
+	if (peer_ev) {
+		ts.tv_sec = gem_readl(bp, PEFTSL);
+		ts.tv_nsec = gem_readl(bp, PEFTN);
+
+	/* PTP Event Frame packets */
+	} else {
+		ts.tv_sec = gem_readl(bp, EFTSL);
+		ts.tv_nsec = gem_readl(bp, EFTN);
+	}
+	ns = timespec64_to_ns(&ts);
+
+	memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
+	shhwtstamps->hwtstamp = ns_to_ktime(ns);
+	skb_tstamp_tx(skb, skb_hwtstamps(skb));
+}
+
+/* no static since it is called from macb driver! */
+void macb_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb)
+{
+	if (!bp->hwts_tx_en)
+		return;
+
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
+		int class = ptp_classify_raw(skb);
+		int peer;
+
+		peer = macb_get_ptp_peer(skb, class);
+		if (peer < 0)
+			return;
+
+		/* Timestamp this packet */
+		macb_ptp_tx_hwtstamp(bp, skb, peer);
+	}
+}
+
+static void macb_ptp_rx_hwtstamp(struct macb *bp, struct sk_buff *skb,
+					int peer_ev)
+{
+	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
+	struct timespec64 ts;
+	u64 ns;
+
+	if (peer_ev) {
+		/* PTP Peer Event Frame packets */
+		ts.tv_sec = gem_readl(bp, PEFRSL);
+		ts.tv_nsec = gem_readl(bp, PEFRN);
+	} else {
+		/* PTP Event Frame packets */
+		ts.tv_sec = gem_readl(bp, EFRSL);
+		ts.tv_nsec = gem_readl(bp, EFRN);
+	}
+	ns = timespec64_to_ns(&ts);
+
+	memset(shhwtstamps, 0, sizeof(struct skb_shared_hwtstamps));
+	shhwtstamps->hwtstamp = ns_to_ktime(ns);
+}
+
+/* no static since it is called from macb driver! */
+void macb_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb)
+{
+	int class;
+	int peer;
+
+	if (!bp->hwts_rx_en)
+		return;
+
+	__skb_push(skb, ETH_HLEN);
+	class = ptp_classify_raw(skb);
+	__skb_pull(skb, ETH_HLEN);
+
+	peer = macb_get_ptp_peer(skb, class);
+	if (peer < 0)
+		return;
+
+	macb_ptp_rx_hwtstamp(bp, skb, peer);
+}
+
+int macb_ptp_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
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
+int macb_hwtst_set(struct net_device *netdev, struct ifreq *ifr, int cmd)
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
+		priv->hwts_tx_en = 0;
+		break;
+	case HWTSTAMP_TX_ON:
+		priv->hwts_tx_en = 1;
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
+int macb_hwtst_get(struct net_device *netdev, struct ifreq *ifr)
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
-- 
1.9.1
