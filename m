From: Andrei Pistirica <andrei.pistirica@microchip.com>
Subject: [RFC PATCH 2/2] macb: Enable 1588 support in SAMA5D2 platform.
Date: Fri, 2 Sep 2016 14:53:37 +0200
Message-ID: <1472820817-21874-2-git-send-email-andrei.pistirica@microchip.com>
References: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <punnaia@xilinx.com>, <michals@xilinx.com>, <anirudh@xilinx.com>,
        <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>, <tbultel@pixelsurmer.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>, <davem@davemloft.net>,
        <nicolas.ferre@atmel.com>, <harinikatakamlinux@gmail.com>,
        <harini.katakam@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472820817-21874-1-git-send-email-andrei.pistirica@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hardware time stamp on the PTP Ethernet packets are received using the
SO_TIMESTAMPING API. Timers are obtained from the PTP event/peer
gem registers.

Signed-off-by: Andrei Pistirica <andrei.pistirica@microchip.com>
---
Integration with SAMA5D2 only. This feature wasn't tested on any
other platform that might use cadence/gem.

Patch is not completely ported to the very latest version of net-next,
and it will be after review.

 drivers/net/ethernet/cadence/macb.c     |  25 +++-
 drivers/net/ethernet/cadence/macb.h     |  13 ++
 drivers/net/ethernet/cadence/macb_ptp.c | 217 ++++++++++++++++++++++++++++++++
 3 files changed, 254 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 8d54e7b..18f0715 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -697,6 +697,11 @@ static void macb_tx_interrupt(struct macb_queue *queue)
 
 			/* First, update TX stats if needed */
 			if (skb) {
+/* guard the hot-path */
+#ifdef CONFIG_MACB_USE_HWSTAMP
+				if (bp->hwts_tx_en)
+					macb_ptp_do_txstamp(bp, skb);
+#endif
 				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
 					    macb_tx_ring_wrap(tail), skb->data);
 				bp->stats.tx_packets++;
@@ -853,6 +858,11 @@ static int gem_rx(struct macb *bp, int budget)
 		    GEM_BFEXT(RX_CSUM, ctrl) & GEM_RX_CSUM_CHECKED_MASK)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+/* guard the hot-path */
+#ifdef CONFIG_MACB_USE_HWSTAMP
+		if (bp->hwts_rx_en)
+			macb_ptp_do_rxstamp(bp, skb);
+#endif
 		bp->stats.rx_packets++;
 		bp->stats.rx_bytes += skb->len;
 
@@ -1723,6 +1733,11 @@ static void macb_init_hw(struct macb *bp)
 
 	/* Enable TX and RX */
 	macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE));
+
+#ifdef CONFIG_MACB_USE_HWSTAMP
+	bp->hwts_tx_en = 0;
+	bp->hwts_rx_en = 0;
+#endif
 }
 
 /*
@@ -1885,6 +1900,8 @@ static int macb_open(struct net_device *dev)
 
 	netif_tx_start_all_queues(dev);
 
+	macb_ptp_init(dev);
+
 	return 0;
 }
 
@@ -2143,7 +2160,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
-	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_ts_info		= macb_get_ts_info,
 	.get_ethtool_stats	= gem_get_ethtool_stats,
 	.get_strings		= gem_get_ethtool_strings,
 	.get_sset_count		= gem_get_sset_count,
@@ -2157,6 +2174,12 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!netif_running(dev))
 		return -EINVAL;
 
+	if (cmd == SIOCSHWTSTAMP)
+		return macb_hwtst_set(dev, rq, cmd);
+
+	if (cmd == SIOCGHWTSTAMP)
+		return macb_hwtst_get(dev, rq);
+
 	if (!phydev)
 		return -ENODEV;
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 8c3779d..555316a 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -920,8 +920,21 @@ struct macb {
 
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
+	{ return -1; }
+int macb_hwtst_get(struct net_device *netdev, struct ifreq *ifr)
+	{ return -1; }
 #endif
 
 static inline bool macb_is_gem(struct macb *bp)
diff --git a/drivers/net/ethernet/cadence/macb_ptp.c b/drivers/net/ethernet/cadence/macb_ptp.c
index 6d6a6ec..e3f784a 100644
--- a/drivers/net/ethernet/cadence/macb_ptp.c
+++ b/drivers/net/ethernet/cadence/macb_ptp.c
@@ -5,6 +5,7 @@
  * Copyright (C) 2016 Microchip Technology
  *
  * Authors: Harini Katakam <harinik@xilinx.com>
+ *	    Andrei Pistirica <andrei.pistirica@microchip.com>
  *
  * This file is licensed under the terms of the GNU General Public
  * License version 2. This program is licensed "as is" without any
@@ -222,3 +223,219 @@ void macb_ptp_init(struct net_device *ndev)
 
 	dev_info(&bp->pdev->dev, "%s ptp clock registered.\n", GMAC_TIMER_NAME);
 }
+
+/* While the GEM can timestamp PTP packets, it does not mark the RX descriptor
+ * to identify them. This is entirely the wrong place to be parsing UDP
+ * headers, but some minimal effort must be made.
+ *
+ * Note: Inspired from drivers/net/ethernet/ti/cpts.c
+ */
+static inline int macb_get_ptp_peer(struct sk_buff *skb, int ptp_class)
+{
+	unsigned int offset = 0;
+	u8 *msgtype, *data = skb->data;
+
+	if (ptp_class == PTP_CLASS_NONE)
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
+static inline void macb_ptp_tx_hwtstamp(struct macb *bp, struct sk_buff *skb,
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
+inline void macb_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb)
+{
+	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) {
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
+static inline void macb_ptp_rx_hwtstamp(struct macb *bp, struct sk_buff *skb,
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
+inline void macb_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb)
+{
+	int class;
+	int peer;
+
+	/* ffs !!! */
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
