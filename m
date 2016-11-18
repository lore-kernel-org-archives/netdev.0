From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH net-next] cadence: Add hardware PTP support.
Date: Fri, 18 Nov 2016 10:47:08 +0000
Message-ID: <1479466028-29914-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Harini Katakam <harinikatakamlinux@gmail.com>,
        Andrei Pistirica <Andrei.Pistirica@microchip.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
---
 Documentation/devicetree/bindings/net/macb.txt |   1 +
 drivers/net/ethernet/cadence/macb.c            | 742 ++++++++++++++++++++++++-
 drivers/net/ethernet/cadence/macb.h            | 217 +++++++-
 3 files changed, 950 insertions(+), 10 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index 1506e94..27966ae 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -22,6 +22,7 @@ Required properties:
 	Required elements: 'pclk', 'hclk'
 	Optional elements: 'tx_clk'
 	Optional elements: 'rx_clk' applies to cdns,zynqmp-gem
+	Optional elements: 'tsu_clk'
 - clocks: Phandles to input clocks.
 
 Optional properties for PHY child node:
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e1847ce..8481e4a 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -32,7 +32,10 @@
 #include <linux/of_gpio.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
-
+#include <linux/ptp_clock_kernel.h>
+#include <linux/clocksource.h>
+#include <linux/net_tstamp.h>
+#include <linux/timecounter.h>
 #include "macb.h"
 
 #define MACB_RX_BUFFER_SIZE	128
@@ -665,6 +668,81 @@ static void macb_tx_error_task(struct work_struct *work)
 	spin_unlock_irqrestore(&bp->lock, flags);
 }
 
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+static int macb_hw_timestamp(struct macb *bp, u32 dma_desc_ts_1, u32 dma_desc_ts_2, struct timespec64 *ts)
+{
+	struct timespec64 tsu;
+
+	ts->tv_sec = (MACB_BFEXT(DMA_TS_MSB_SEC, dma_desc_ts_2) << MACB_DMA_TS_LSB_SEC_SIZE) |
+			MACB_BFEXT(DMA_TS_LSB_SEC, dma_desc_ts_1);
+	ts->tv_nsec = MACB_BFEXT(DMA_TS_NSEC, dma_desc_ts_1);
+
+	/* TSU overlaping workaround
+	 * The timestamp only contains lower few bits of seconds,
+	 * so add value from 1588 timer
+	 */
+	macb_ptp_time_get(bp, &tsu);
+
+	/* If the top bit is set in the timestamp,
+	 * but not in 1588 timer, it has rolled over,
+	 * so subtract max size
+	 */
+	if ((ts->tv_sec & (MACB_DMA_TS_SEC_TOP >> 1)) && 
+		!(tsu.tv_sec & (MACB_DMA_TS_SEC_TOP >> 1)))
+		ts->tv_sec -= MACB_DMA_TS_SEC_TOP;
+
+	ts->tv_sec += ((~MACB_DMA_TS_SEC_MASK) & (tsu.tv_sec));
+
+	return 0;
+}
+
+static void macb_tstamp_tx(struct macb *bp, struct sk_buff *skb, struct macb_dma_desc *desc)
+{
+	struct skb_shared_hwtstamps shhwtstamps;
+	struct timespec64 ts;
+
+	if(MACB_BFEXT(DMA_TX_TS_VALID, desc->ctrl)) {
+		macb_hw_timestamp(bp, desc->dma_desc_ts_1, desc->dma_desc_ts_2, &ts);
+		memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+		shhwtstamps.hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
+		skb_tstamp_tx(skb, &shhwtstamps);
+	}
+}
+
+static void macb_tx_timestamp_flush(struct work_struct *work)
+{
+	struct macb_queue *queue = container_of(work, struct macb_queue, tx_timestamp_task);
+	struct macb_tx_timestamp *tx_timestamp;
+	unsigned long head = smp_load_acquire(&queue->tx_tstamp_head);
+	unsigned long tail = queue->tx_tstamp_tail;
+
+	while (CIRC_CNT(head, tail, PTP_TS_BUFFER_SIZE)) {
+		tx_timestamp = &queue->tx_timestamps[tail];
+		macb_tstamp_tx(queue->bp, tx_timestamp->skb, &tx_timestamp->desc);
+		/* cleanup */
+		dev_kfree_skb_any(tx_timestamp->skb);
+		smp_store_release(&queue->tx_tstamp_tail, (tail + 1) & (PTP_TS_BUFFER_SIZE - 1));
+		tail = queue->tx_tstamp_tail;
+	}
+}
+
+static int macb_tx_timestamp_add(struct macb_queue *queue, struct sk_buff *skb, struct macb_dma_desc *desc)
+{
+	struct macb_tx_timestamp *tx_timestamp;
+	unsigned long head = queue->tx_tstamp_head;
+	unsigned long tail = ACCESS_ONCE(queue->tx_tstamp_tail);
+
+	if (CIRC_SPACE(head, tail, PTP_TS_BUFFER_SIZE) == 0)
+		return -ENOMEM;
+
+	tx_timestamp = &queue->tx_timestamps[head];
+	tx_timestamp->skb = skb;
+	memcpy(&tx_timestamp->desc, desc, sizeof(tx_timestamp->desc));
+	smp_store_release(&queue->tx_tstamp_head, (head + 1) & (PTP_TS_BUFFER_SIZE - 1));
+	return 0;
+}
+#endif
+
 static void macb_tx_interrupt(struct macb_queue *queue)
 {
 	unsigned int tail;
@@ -712,6 +790,16 @@ static void macb_tx_interrupt(struct macb_queue *queue)
 				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
 					    macb_tx_ring_wrap(bp, tail),
 					    skb->data);
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+				if (bp->ptp_hw_support)
+					if (macb_tx_timestamp_add(queue, skb, desc) == 0) {
+						 /* skb now belongs to timestamp buffer
+						 * and will be removed later
+						 */
+						tx_skb->skb = NULL;
+						schedule_work(&queue->tx_timestamp_task);
+					}
+#endif
 				bp->stats.tx_packets++;
 				bp->stats.tx_bytes += skb->len;
 			}
@@ -876,6 +964,17 @@ static int gem_rx(struct macb *bp, int budget)
 		bp->stats.rx_packets++;
 		bp->stats.rx_bytes += skb->len;
 
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+		if (bp->ptp_hw_support) {
+			struct timespec64 ts;
+
+			if (MACB_BFEXT(DMA_RX_TS_VALID, desc->addr)) {
+				macb_hw_timestamp(bp, desc->dma_desc_ts_1, desc->dma_desc_ts_2, &ts);
+				skb_hwtstamps(skb)->hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
+			}
+		}
+#endif
+
 #if defined(DEBUG) && defined(VERBOSE_DEBUG)
 		netdev_vdbg(bp->dev, "received skb of length %u, csum: %08x\n",
 			    skb->len, skb->csum);
@@ -1103,6 +1202,9 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 	struct macb *bp = queue->bp;
 	struct net_device *dev = bp->dev;
 	u32 status, ctrl;
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+	struct timespec64 ts;
+#endif
 
 	status = queue_readl(queue, ISR);
 
@@ -1195,6 +1297,87 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 				queue_writel(queue, ISR, MACB_BIT(HRESP));
 		}
 
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+		if (status & MACB_BIT(PTP_DELAY_REQ_FRAME_RECEIVED)) {
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				queue_writel(queue, ISR, MACB_BIT(PTP_DELAY_REQ_FRAME_RECEIVED));
+			if (macb_ptp_time_frame_rx_get(bp, &ts) != 0) {
+				ts.tv_sec = 0;
+				ts.tv_nsec = 0;
+			}
+			macb_ptp_event(bp, &ts);
+		}
+
+		if (status & MACB_BIT(PTP_SYNC_FRAME_RECEIVED)) {
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				queue_writel(queue, ISR, MACB_BIT(PTP_SYNC_FRAME_RECEIVED));
+			if (macb_ptp_time_frame_rx_get(bp, &ts) != 0) {
+				ts.tv_sec = 0;
+				ts.tv_nsec = 0;
+			}
+			macb_ptp_event(bp, &ts);
+		}
+
+		if (status & MACB_BIT(PTP_DELAY_REQ_FRAME_TRANSMITTED)) {
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				queue_writel(queue, ISR, MACB_BIT(PTP_DELAY_REQ_FRAME_TRANSMITTED));
+			if (macb_ptp_time_frame_tx_get(bp, &ts) != 0) {
+				ts.tv_sec = 0;
+				ts.tv_nsec = 0;
+			}
+			macb_ptp_event(bp, &ts);
+		}
+
+		if (status & MACB_BIT(PTP_SYNC_FRAME_TRANSMITTED)) {
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				queue_writel(queue, ISR, MACB_BIT(PTP_SYNC_FRAME_TRANSMITTED));
+			if (macb_ptp_time_frame_tx_get(bp, &ts) != 0) {
+				ts.tv_sec = 0;
+				ts.tv_nsec = 0;
+			}
+			macb_ptp_event(bp, &ts);
+		}
+
+		if (status & MACB_BIT(PTP_PDELAY_REQ_FRAME_RECEIVED)) {
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				queue_writel(queue, ISR, MACB_BIT(PTP_PDELAY_REQ_FRAME_RECEIVED));
+			if (macb_ptp_time_peer_frame_rx_get(bp, &ts) != 0) {
+				ts.tv_sec = 0;
+				ts.tv_nsec = 0;
+			}
+			macb_ptp_event(bp, &ts);
+		}
+
+		if (status & MACB_BIT(PTP_PDELAY_RESP_FRAME_RECEIVED)) {
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				queue_writel(queue, ISR, MACB_BIT(PTP_PDELAY_RESP_FRAME_RECEIVED));
+			if (macb_ptp_time_peer_frame_rx_get(bp, &ts) != 0) {
+				ts.tv_sec = 0;
+				ts.tv_nsec = 0;
+			}
+			macb_ptp_event(bp, &ts);
+		}
+
+		if (status & MACB_BIT(PTP_PDELAY_REQ_FRAME_TRANSMITTED)) {
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				queue_writel(queue, ISR, MACB_BIT(PTP_PDELAY_REQ_FRAME_TRANSMITTED));
+			if (macb_ptp_time_peer_frame_tx_get(bp, &ts) != 0) {
+				ts.tv_sec = 0;
+				ts.tv_nsec = 0;
+			}
+			macb_ptp_event(bp, &ts);
+		}
+
+		if (status & MACB_BIT(PTP_PDELAY_RESP_FRAME_TRANSMITTED)) {
+			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
+				queue_writel(queue, ISR, MACB_BIT(PTP_PDELAY_RESP_FRAME_TRANSMITTED));
+			if (macb_ptp_time_peer_frame_tx_get(bp, &ts) != 0) {
+				ts.tv_sec = 0;
+				ts.tv_nsec = 0;
+			}
+			macb_ptp_event(bp, &ts);
+		}
+#endif
 		status = queue_readl(queue, ISR);
 	}
 
@@ -1422,7 +1605,10 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Make newly initialized descriptor visible to hardware */
 	wmb();
 
-	skb_tx_timestamp(skb);
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+	if (!bp->ptp_hw_support)
+#endif
+		skb_tx_timestamp(skb);
 
 	macb_writel(bp, NCR, macb_readl(bp, NCR) | MACB_BIT(TSTART));
 
@@ -1752,6 +1938,9 @@ static void macb_configure_dma(struct macb *bp)
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 		dmacfg |= GEM_BIT(ADDR64);
 #endif
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+		dmacfg |= GEM_BIT(RX_EXTENDED_MODE) | GEM_BIT(TX_EXTENDED_MODE);
+#endif
 		netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n",
 			   dmacfg);
 		gem_writel(bp, DMACFG, dmacfg);
@@ -1763,7 +1952,7 @@ static void macb_init_hw(struct macb *bp)
 	struct macb_queue *queue;
 	unsigned int q;
 
-	u32 config;
+	u32 config, ier;
 
 	macb_reset_hw(bp);
 	macb_set_hwaddr(bp);
@@ -1808,10 +1997,21 @@ static void macb_init_hw(struct macb *bp)
 #endif
 
 		/* Enable interrupts */
-		queue_writel(queue, IER,
-			     MACB_RX_INT_FLAGS |
-			     MACB_TX_INT_FLAGS |
-			     MACB_BIT(HRESP));
+		ier = MACB_RX_INT_FLAGS |
+			MACB_TX_INT_FLAGS |
+			MACB_BIT(HRESP);
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+		if (bp->ptp_hw_support)
+			ier |= MACB_BIT(PTP_DELAY_REQ_FRAME_TRANSMITTED) |
+				MACB_BIT(PTP_SYNC_FRAME_TRANSMITTED) |
+				MACB_BIT(PTP_PDELAY_REQ_FRAME_TRANSMITTED) |
+				MACB_BIT(PTP_PDELAY_RESP_FRAME_TRANSMITTED) |
+				MACB_BIT(PTP_DELAY_REQ_FRAME_RECEIVED) |
+				MACB_BIT(PTP_SYNC_FRAME_RECEIVED) |
+				MACB_BIT(PTP_PDELAY_REQ_FRAME_RECEIVED) |
+				MACB_BIT(PTP_PDELAY_RESP_FRAME_RECEIVED);
+#endif
+		queue_writel(queue, IER, ier);
 	}
 
 	/* Enable TX and RX */
@@ -2183,6 +2383,34 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		regs_buff[13] = gem_readl(bp, DMACFG);
 }
 
+int macb_get_ts_info(struct net_device *dev, struct ethtool_ts_info *ts_info)
+{
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+	struct macb *bp = netdev_priv(dev);
+
+	if (bp->ptp_hw_support) {
+		ts_info->phc_index = ptp_clock_index(bp->ptp_clock);
+		ts_info->so_timestamping =
+			SOF_TIMESTAMPING_TX_SOFTWARE |
+			SOF_TIMESTAMPING_RX_SOFTWARE |
+			SOF_TIMESTAMPING_TX_HARDWARE |
+			SOF_TIMESTAMPING_RX_HARDWARE |
+			SOF_TIMESTAMPING_RAW_HARDWARE |
+			SOF_TIMESTAMPING_SOFTWARE;
+		ts_info->tx_types =
+			(1 << HWTSTAMP_TX_ONESTEP_SYNC) |
+			(1 << HWTSTAMP_TX_OFF) |
+			(1 << HWTSTAMP_TX_ON);
+		ts_info->rx_filters =
+			(1 << HWTSTAMP_FILTER_NONE) |
+			(1 << HWTSTAMP_FILTER_ALL);
+		return 0;
+	}
+	else
+#endif
+		return ethtool_op_get_ts_info(dev, ts_info);
+}
+
 static void macb_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct macb *bp = netdev_priv(netdev);
@@ -2283,7 +2511,7 @@ static const struct ethtool_ops gem_ethtool_ops = {
 	.get_regs_len		= macb_get_regs_len,
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
-	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_ts_info		= macb_get_ts_info,
 	.get_ethtool_stats	= gem_get_ethtool_stats,
 	.get_strings		= gem_get_ethtool_strings,
 	.get_sset_count		= gem_get_sset_count,
@@ -2293,6 +2521,100 @@ static const struct ethtool_ops gem_ethtool_ops = {
 	.set_ringparam		= macb_set_ringparam,
 };
 
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+int macb_get_ts(struct net_device *dev, struct ifreq *rq)
+{
+	struct macb *bp = netdev_priv(dev);
+	struct hwtstamp_config *tstamp_config = &bp->tstamp_config;
+
+	if (!bp->ptp_hw_support)
+		return -EFAULT;
+	if (copy_to_user(rq->ifr_data, tstamp_config, sizeof(*tstamp_config)))
+		return -EFAULT;
+	else
+		return 0;
+}
+
+int macb_set_ts(struct net_device *dev, struct ifreq *rq)
+{
+	struct macb *bp = netdev_priv(dev);
+	struct hwtstamp_config *tstamp_config = &bp->tstamp_config;
+
+	struct timespec64 ts;
+	struct incrementspec incr_spec;
+
+	enum macb_bd_control tx_bd_control;
+	enum macb_bd_control rx_bd_control;
+
+	if (!bp->ptp_hw_support)
+		return -EFAULT;
+
+	if (copy_from_user(tstamp_config, rq->ifr_data, sizeof(*tstamp_config)))
+		return -EFAULT;
+
+	switch (tstamp_config->tx_type) {
+	case HWTSTAMP_TX_OFF:
+		break;
+	case HWTSTAMP_TX_ONESTEP_SYNC:
+		if (macb_ptp_set_one_step_sync(bp, 1) != 0)
+			return -ERANGE;
+	case HWTSTAMP_TX_ON:
+		tx_bd_control = TSTAMP_ALL_FRAMES;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (tstamp_config->rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		rx_bd_control =  TSTAMP_ALL_PTP_FRAMES;
+		tstamp_config->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_ALL:
+		rx_bd_control = TSTAMP_ALL_FRAMES;
+		tstamp_config->rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
+	default:
+		tstamp_config->rx_filter = HWTSTAMP_FILTER_NONE;
+		return -ERANGE;
+	}
+
+	/* 1. get current system time */
+	ts = ns_to_timespec64(ktime_to_ns(ktime_get_real()));
+
+	/* 2. set ptp timer */
+	macb_ptp_time_set(bp, &ts);
+
+	/* 3. set PTP timer increment value to BASE_INCREMENT */
+	incr_spec.sub_ns = bp->tsu_incr.sub_ns;
+	incr_spec.ns = bp->tsu_incr.ns;
+	macb_ptp_increment_set(bp, &incr_spec);
+
+	if (macb_ptp_set_tstamp_mode(bp, tx_bd_control, rx_bd_control) != 0)
+		return -ERANGE;
+
+	if (copy_to_user(rq->ifr_data, tstamp_config, sizeof(*tstamp_config)))
+		return -EFAULT;
+	else
+		return 0;
+}
+#endif
+
 static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct phy_device *phydev = dev->phydev;
@@ -2303,6 +2625,13 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!phydev)
 		return -ENODEV;
 
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+	if (cmd == SIOCGHWTSTAMP)
+		return macb_get_ts(dev, rq);
+
+	if (cmd == SIOCSHWTSTAMP)
+		return macb_set_ts(dev, rq);
+#endif
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
@@ -3147,6 +3476,17 @@ static int macb_probe(struct platform_device *pdev)
 		    macb_is_gem(bp) ? "GEM" : "MACB", macb_readl(bp, MID),
 		    dev->base_addr, dev->irq, dev->dev_addr);
 
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+	/* Enable PTP */
+	bp->ptp_hw_support = false;
+	if (GEM_BFEXT(TSU, gem_readl(bp, DCFG5))) {
+		err = macb_ptp_init(pdev);
+		if (err)
+			dev_err(&pdev->dev, "Cannot initialize ptp.\n");
+		else
+			bp->ptp_hw_support = true;
+	}
+#endif
 	return 0;
 
 err_out_unregister_mdio:
@@ -3245,6 +3585,392 @@ static int __maybe_unused macb_resume(struct device *dev)
 	return 0;
 }
 
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+int macb_ptp_init(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct macb *bp = netdev_priv(dev);
+	u64 tsu_f, temp;
+	unsigned int q;
+	struct macb_queue *queue;
+
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
+		queue->tx_tstamp_head = 0;
+		queue->tx_tstamp_tail = 0;
+		INIT_WORK(&queue->tx_timestamp_task, macb_tx_timestamp_flush);
+	}
+
+	snprintf(bp->ptp_clock_info.name, 16, "macb_ptp");
+	bp->ptp_clock_info.max_adj   = (64E6);
+	bp->ptp_clock_info.n_alarm   = 1;
+	bp->ptp_clock_info.n_ext_ts  = 1;
+	bp->ptp_clock_info.n_per_out = 0;
+	bp->ptp_clock_info.n_pins    = 0;
+	bp->ptp_clock_info.pps	     = 1;
+	bp->ptp_clock_info.adjfreq   = macb_ptp_adjfreq;
+	bp->ptp_clock_info.adjtime   = macb_ptp_adjtime;
+	bp->ptp_clock_info.gettime64 = macb_ptp_gettime;
+	bp->ptp_clock_info.settime64 = macb_ptp_settime;
+	bp->ptp_clock_info.enable    = macb_ptp_enable;
+
+	bp->ptp_clock = ptp_clock_register(&bp->ptp_clock_info, &pdev->dev);
+
+	bp->tsu_clk = devm_clk_get(&pdev->dev, "tsu_clk");
+	if (!IS_ERR(bp->tsu_clk)) {
+		tsu_f = clk_get_rate(bp->tsu_clk);
+	}
+	/* try pclk instead */
+	else if (!IS_ERR(bp->pclk)) {
+		bp->tsu_clk = bp->pclk;
+		tsu_f = clk_get_rate(bp->tsu_clk);
+	} else
+		return -ENOTSUPP;
+
+	bp->tsu_incr.ns = div_u64(NSEC_PER_SEC, tsu_f);
+	temp = (NSEC_PER_SEC - ((u64)bp->tsu_incr.ns * tsu_f));
+	temp *= (1 << MACB_SUB_NS_INCR_SIZE);
+	bp->tsu_incr.sub_ns = div_u64(temp, tsu_f);
+
+	return 0;
+}
+
+void macb_ptp_stop(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct macb *bp = netdev_priv(dev);
+
+	if (bp->ptp_clock)
+		ptp_clock_unregister(bp->ptp_clock);
+}
+
+/* Interface of Linux PTP Framework */
+
+int macb_ptp_adjfreq(struct ptp_clock_info *ptp_clock_info, s32 ppb)
+{
+	struct incrementspec incr_spec;
+	struct macb *bp = container_of(ptp_clock_info, struct macb, ptp_clock_info);
+	u64 period, temp;
+	bool neg_adj = false;
+	unsigned long flags;
+
+	if (!ptp_clock_info)
+		return -EINVAL;
+
+	if (ppb < 0) {
+		neg_adj = true;
+		ppb = -ppb;
+	}
+
+	/* Adjustment is relative to base frequency */
+	incr_spec.sub_ns = bp->tsu_incr.sub_ns;
+	incr_spec.ns = bp->tsu_incr.ns;
+
+	/* scaling */
+	period = ((u64) incr_spec.ns << MACB_SUB_NS_INCR_SIZE) + incr_spec.sub_ns;
+	temp = (u64)ppb * period;
+	/* Divide with rounding, equivalent to floating dividing:
+	 * (temp / NSEC_PER_SEC) + 0.5
+	 */
+	temp = div_u64(temp + (NSEC_PER_SEC >> 1), NSEC_PER_SEC);
+
+	period = neg_adj ? (period - temp) : (period + temp);
+
+	incr_spec.ns = (period >> MACB_SUB_NS_INCR_SIZE) & ((1 << MACB_NUM_INCS_SIZE) - 1);
+	incr_spec.sub_ns = period & ((1 << MACB_SUB_NS_INCR_SIZE) - 1);
+
+	spin_lock_irqsave(&bp->lock, flags);
+	macb_ptp_increment_set(bp, &incr_spec);
+
+	spin_unlock_irqrestore(&bp->lock, flags);
+	return 0;
+}
+
+int macb_ptp_adjtime(struct ptp_clock_info *ptp_clock_info, s64 delta)
+{
+
+	u64 ts_nsec;
+	struct timespec64 ts;
+	struct macb *bp = container_of(ptp_clock_info, struct macb, ptp_clock_info);
+
+	if (!ptp_clock_info)
+		return -EINVAL;
+
+	if (delta >= -TSU_NSEC_MAX_VAL && delta <= TSU_NSEC_MAX_VAL) {
+		macb_ptp_time_adjust(bp, (s32)delta);
+	} else {
+		macb_ptp_time_get(bp, &ts);
+
+		ts_nsec = ts.tv_nsec + ts.tv_sec * NSEC_PER_SEC;
+		ts_nsec += delta;
+
+		ts.tv_sec = div_u64(ts_nsec, NSEC_PER_SEC);
+		ts.tv_nsec = ts_nsec - ts.tv_sec * NSEC_PER_SEC;
+
+		macb_ptp_time_set(bp, &ts);
+	}
+
+	return 0;
+}
+
+
+int macb_ptp_gettime(struct ptp_clock_info *ptp_clock_info, struct timespec64 *ts)
+{
+	struct macb *bp = container_of(ptp_clock_info, struct macb, ptp_clock_info);
+
+	if (!ptp_clock_info || !ts)
+		return -EINVAL;
+
+	macb_ptp_time_get(bp, ts);
+	return 0;
+}
+
+int macb_ptp_settime(struct ptp_clock_info *ptp_clock_info, const struct timespec64 *ts)
+{
+	struct macb *bp = container_of(ptp_clock_info, struct macb, ptp_clock_info);
+
+	if (!ptp_clock_info || !ts)
+		return -EINVAL;
+
+	macb_ptp_time_set(bp, ts);
+	return 0;
+}
+
+int macb_ptp_enable(struct ptp_clock_info *ptp_clock_info,
+		    struct ptp_clock_request *request, int on)
+{
+	struct macb *bp = container_of(ptp_clock_info, struct macb, ptp_clock_info);
+	u32 mask;
+
+	if (!ptp_clock_info || !request)
+		return -EINVAL;
+
+	switch (request->type) {
+	case PTP_CLK_REQ_EXTTS:	/* Toggle TSU match interrupt */
+		mask = macb_readl(bp, IMR) | (1 << MACB_TSU_TIMER_COMPARISON_INTERRUPT_OFFSET);
+		if (on)
+			macb_writel(bp, IER, mask);
+		else
+			macb_writel(bp, IDR, mask);
+		break;
+	case PTP_CLK_REQ_PEROUT: /* Toggle Periodic output */
+		return -EOPNOTSUPP;
+		/* break; */
+	case PTP_CLK_REQ_PPS:	/* Toggle TSU periodic (second) interrupt */
+		mask = macb_readl(bp, IMR) | (1 << MACB_TSU_SECONDS_REGISTER_INCREMENT_OFFSET);
+		if (on)
+			macb_writel(bp, IER, mask);
+		else
+			macb_writel(bp, IDR, mask);
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
+
+
+/* End of Interface of Linux PTP Framework */
+
+int macb_ptp_increment_get(struct macb *bp, struct incrementspec *incr_spec)
+{
+	u32 sub_ns_reg;
+	u32 ns_reg;
+
+	if (!bp || !incr_spec)
+		return -EINVAL;
+
+	sub_ns_reg = macb_readl(bp, TSU_TIMER_INCR_SUB_NSEC);
+	ns_reg = macb_readl(bp, TSU_TIMER_INCR);
+
+	incr_spec->sub_ns = MACB_BFEXT(SUB_NS_INCR_MSB, sub_ns_reg) << MACB_SUB_NS_INCR_LSB_SIZE | MACB_BFEXT(SUB_NS_INCR_LSB, sub_ns_reg);
+	incr_spec->ns = MACB_BFEXT(NS_INCREMENT, ns_reg);
+
+	return 0;
+}
+
+int macb_ptp_increment_set(struct macb *bp, struct incrementspec *incr_spec)
+{
+	u32 sub_ns_reg;
+	u32 ns_reg;
+
+	if (!bp || !incr_spec)
+		return -EINVAL;
+
+	sub_ns_reg = MACB_BF(SUB_NS_INCR_LSB, incr_spec->sub_ns)
+			| (((incr_spec->sub_ns & ~((1 << MACB_SUB_NS_INCR_LSB_SIZE) - 1)) >> MACB_SUB_NS_INCR_LSB_SIZE));
+	ns_reg = incr_spec->ns;
+
+	/* tsu_timer_incr register must be written after the tsu_timer_incr_sub_ns register
+	 * and the write operation will cause the value written to the tsu_timer_incr_sub_ns
+	 * register to take effect.
+	 */
+	macb_writel(bp, TSU_TIMER_INCR_SUB_NSEC, sub_ns_reg);
+	macb_writel(bp, TSU_TIMER_INCR, ns_reg);
+
+	return 0;
+}
+
+int macb_ptp_time_adjust(struct macb *bp, s32 delta)
+{
+	bool subtract = 0;
+	u32 val = 0;
+
+	if (!bp)
+		return -EINVAL;
+
+	if ((delta < -TSU_NSEC_MAX_VAL) || (delta > TSU_NSEC_MAX_VAL))
+		return -EINVAL;
+
+	if (delta < 0) {
+		subtract = 1;
+		delta = -delta;
+	}
+
+	val = (subtract << MACB_ADD_SUBTRACT_OFFSET) | delta;
+
+	macb_writel(bp, TSU_TIMER_ADJUST, val);
+
+	return 0;
+}
+
+int macb_ptp_time_get(struct macb *bp, struct timespec64 *ts)
+{
+	long first, second;
+	u32 sec, msb_sec;
+
+	if (!bp || !ts)
+		return -EINVAL;
+
+	first = macb_readl(bp, TSU_TMR_NSEC);
+	sec = macb_readl(bp, TSU_TMR_SEC);
+	msb_sec = macb_readl(bp, TSU_TMR_MSB_SEC);
+	second = macb_readl(bp, TSU_TMR_NSEC);
+
+	/* test for nsec rollover */
+	if (first > second) {
+		/* if so, use later read & re-read seconds
+		 * (assume all done within 1s)
+		 */
+		ts->tv_nsec = macb_readl(bp, TSU_TMR_NSEC);
+		sec = macb_readl(bp, TSU_TMR_SEC);
+		msb_sec = macb_readl(bp, TSU_TMR_MSB_SEC);
+	} else
+		ts->tv_nsec = first;
+
+	ts->tv_sec = (((u64)msb_sec << MACB_TIMER_LSB_SEC_SIZE) | sec)
+			& TSU_SEC_MAX_VAL;
+
+	return 0;
+}
+
+int macb_ptp_time_set(struct macb *bp, const struct timespec64 *ts)
+{
+	if (!bp || !ts)
+		return -EINVAL;
+
+	macb_writel(bp, TSU_TMR_MSB_SEC, (ts->tv_sec >> MACB_TIMER_LSB_SEC_SIZE)
+			& ((1 << MACB_TIMER_MSB_SEC_SIZE) - 1));
+	/* write lower bits 2nd, for synchronised secs update */
+	macb_writel(bp, TSU_TMR_SEC, ts->tv_sec & (((u64)1 << MACB_TIMER_LSB_SEC_SIZE) - 1));
+	macb_writel(bp, TSU_TMR_NSEC, ts->tv_nsec);
+
+	return 0;
+}
+
+int macb_ptp_time_peer_frame_tx_get(struct macb *bp, struct timespec64 *ts)
+{
+	if (!bp || !ts)
+		return -EINVAL;
+
+	ts->tv_sec = (((u64)macb_readl(bp, TSU_PEER_TX_MSB_SEC) << 32) |
+		macb_readl(bp, TSU_PEER_TX_SEC)) & TSU_SEC_MAX_VAL;
+	ts->tv_nsec = macb_readl(bp, TSU_PEER_TX_NSEC);
+
+	return 0;
+}
+
+int macb_ptp_time_peer_frame_rx_get(struct macb *bp, struct timespec64 *ts)
+{
+	if (!bp || !ts)
+		return -EINVAL;
+
+	ts->tv_sec = (((u64)macb_readl(bp, TSU_PEER_RX_MSB_SEC) << 32) |
+		macb_readl(bp, TSU_PEER_RX_SEC)) & TSU_SEC_MAX_VAL;
+	ts->tv_nsec = macb_readl(bp, TSU_PEER_RX_NSEC);
+
+	return 0;
+}
+
+int macb_ptp_time_frame_tx_get(struct macb *bp, struct timespec64 *ts)
+{
+	if (!bp || !ts)
+		return -EINVAL;
+
+	ts->tv_sec = (((u64)macb_readl(bp, TSU_PTP_TX_MSB_SEC) << 32) |
+		macb_readl(bp, TSU_PTP_TX_SEC)) & TSU_SEC_MAX_VAL;
+	ts->tv_nsec = macb_readl(bp, TSU_PTP_TX_NSEC);
+
+	return 0;
+}
+
+int macb_ptp_time_frame_rx_get(struct macb *bp, struct timespec64 *ts)
+{
+	if (!bp || !ts)
+		return -EINVAL;
+
+	ts->tv_sec = (((u64)macb_readl(bp, TSU_PTP_RX_MSB_SEC) << 32) |
+		      macb_readl(bp, TSU_PTP_RX_SEC)) & TSU_SEC_MAX_VAL;
+	ts->tv_nsec = macb_readl(bp, TSU_PTP_RX_NSEC);
+
+	return 0;
+}
+
+int macb_ptp_event(struct macb *bp, struct timespec64 *ts)
+{
+	struct ptp_clock_event event;
+
+	event.type = PTP_CLOCK_EXTTS;
+	event.index = 0;
+	event.timestamp = ts->tv_sec * NSEC_PER_SEC + ts->tv_nsec;
+
+	ptp_clock_event(bp->ptp_clock, &event);
+
+	return 0;
+}
+
+int macb_ptp_set_one_step_sync(struct macb *bp, u8 enable)
+{
+	u32 reg_val;
+
+	if (!bp)
+		return -EINVAL;
+	if (enable < 0 || enable > 1)
+		return -EINVAL;
+
+	reg_val = macb_readl(bp, NCR);
+
+	if (enable)
+		macb_writel(bp, NCR, reg_val | MACB_BIT(ONE_STEP_SYNC_MODE));
+	else
+		macb_writel(bp, NCR, reg_val & ~MACB_BIT(ONE_STEP_SYNC_MODE));
+
+	return 0;
+}
+
+int macb_ptp_set_tstamp_mode(struct macb *bp,
+			     enum macb_bd_control tx_bd_control,
+			     enum macb_bd_control rx_bd_control)
+{
+	if (!bp)
+		return -EINVAL;
+
+	macb_writel(bp, TX_BD_CONTROL, MACB_BF(TX_BD_TS_MODE, tx_bd_control));
+	macb_writel(bp, RX_BD_CONTROL, MACB_BF(RX_BD_TS_MODE, rx_bd_control));
+
+	return 0;
+}
+#endif
+
 static SIMPLE_DEV_PM_OPS(macb_pm_ops, macb_suspend, macb_resume);
 
 static struct platform_driver macb_driver = {
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 1216950..1381f0a 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -66,8 +66,32 @@
 #define MACB_USRIO		0x00c0
 #define MACB_WOL		0x00c4
 #define MACB_MID		0x00fc
-#define MACB_TBQPH		0x04C8
-#define MACB_RBQPH		0x04D4
+
+#define MACB_TSU_PTP_TX_MSB_SEC		0x00e8	/* PTP Event Frame Transmitted Seconds Register 47:32 */
+#define MACB_TSU_PTP_RX_MSB_SEC		0x00ec	/* PTP Event Frame Received Seconds Register 47:32 */
+#define MACB_TSU_PEER_TX_MSB_SEC	0x00f0	/* PTP Peer Event Frame Transmitted Seconds Register 47:32 */
+#define MACB_TSU_PEER_RX_MSB_SEC	0x00f4	/* PTP Peer Event Frame Received Seconds Register 47:32 */
+#define MACB_TSU_TIMER_INCR_SUB_NSEC	0x01bc	/* Sub-nanoseconds increment */
+#define MACB_TSU_TIMER_INCR		0x01dc	/* Nanoseconds increment */
+#define MACB_TSU_TMR_MSB_SEC		0x01c0	/* Upper second count of Time Stamp Unit */
+#define MACB_TSU_TMR_SEC		0x01d0	/* Lower second count of Time Stamp Unit */
+#define MACB_TSU_TMR_NSEC		0x01d4	/* Nanosecond count of Time Stamp Unit */
+#define MACB_TSU_TIMER_ADJUST		0x01d8	/* Nanosecond Adjust Register */
+#define MACB_TSU_TIMER_INCR_SUB_NSEC	0x01bc	/* Sub-nanosecond Adjust Register */
+#define MACB_TSU_TIMER_INCR		0x01dc	/* Nanosecond Adjust Register */
+#define MACB_TSU_PTP_TX_SEC		0x01e0	/* PTP Event Frame Transmitted Seconds Register 31:0 */
+#define MACB_TSU_PTP_TX_NSEC		0x01e4	/* PTP Event Frame Transmitted Nanoseconds Register */
+#define MACB_TSU_PTP_RX_SEC		0x01e8	/* PTP Event Frame Received Seconds Register 31:0 */
+#define MACB_TSU_PTP_RX_NSEC		0x01ec	/* PTP Event Frame Received Nanoseconds Register */
+#define MACB_TSU_PEER_TX_SEC		0x01f0	/* PTP Peer Event Frame Transmitted Seconds Register 31:0 */
+#define MACB_TSU_PEER_TX_NSEC		0x01f4	/* PTP Peer Event Frame Transmitted Nanoseconds Register */
+#define MACB_TSU_PEER_RX_SEC		0x01f8	/* PTP Peer Event Frame Received Seconds Register 31:0 */
+#define MACB_TSU_PEER_RX_NSEC		0x01fc	/* PTP Peer Event Frame Received Nanoseconds Register */
+
+#define MACB_TX_BD_CONTROL 	0x04cc /* TX Buffer Descriptor control register */
+#define MACB_RX_BD_CONTROL 	0x04d0 /* RX Buffer Descriptor control register */
+#define MACB_TBQPH		0x04c8
+#define MACB_RBQPH		0x04d4
 
 /* GEM register offsets. */
 #define GEM_NCFGR		0x0004 /* Network Config */
@@ -174,6 +198,8 @@
 #define MACB_NCR_TPF_SIZE	1
 #define MACB_TZQ_OFFSET		12 /* Transmit zero quantum pause frame */
 #define MACB_TZQ_SIZE		1
+#define MACB_ONE_STEP_SYNC_MODE_OFFSET 24 /* Enable One Step Synchro Mode */
+#define MACB_ONE_STEP_SYNC_MODE_SIZE 1
 
 /* Bitfields in NCFGR */
 #define MACB_SPD_OFFSET		0 /* Speed */
@@ -252,6 +278,10 @@
 #define GEM_RXBS_SIZE		8
 #define GEM_DDRP_OFFSET		24 /* disc_when_no_ahb */
 #define GEM_DDRP_SIZE		1
+#define GEM_RX_EXTENDED_MODE_OFFSET	28 /* RX extended Buffer Descriptor mode */
+#define GEM_RX_EXTENDED_MODE_SIZE	1
+#define GEM_TX_EXTENDED_MODE_OFFSET	29 /* TX extended Buffer Descriptor mode */
+#define GEM_TX_EXTENDED_MODE_SIZE	1
 #define GEM_ADDR64_OFFSET	30 /* Address bus width - 64b or 32b */
 #define GEM_ADDR64_SIZE		1
 
@@ -319,6 +349,26 @@
 #define MACB_PTZ_SIZE		1
 #define MACB_WOL_OFFSET		14 /* Enable wake-on-lan interrupt */
 #define MACB_WOL_SIZE		1
+#define MACB_PTP_DELAY_REQ_FRAME_RECEIVED_OFFSET	18	/* PTP delay_req frame received */
+#define MACB_PTP_DELAY_REQ_FRAME_RECEIVED_SIZE		1
+#define MACB_PTP_SYNC_FRAME_RECEIVED_OFFSET		19	/* PTP sync frame received */
+#define MACB_PTP_SYNC_FRAME_RECEIVED_SIZE		1
+#define MACB_PTP_DELAY_REQ_FRAME_TRANSMITTED_OFFSET	20	/* PTP delay_req frame transmitted */
+#define MACB_PTP_DELAY_REQ_FRAME_TRANSMITTED_SIZE	1
+#define MACB_PTP_SYNC_FRAME_TRANSMITTED_OFFSET		21	/* PTP sync frame transmitted */
+#define MACB_PTP_SYNC_FRAME_TRANSMITTED_SIZE		1
+#define MACB_PTP_PDELAY_REQ_FRAME_RECEIVED_OFFSET	22	/* PTP pdelay_req frame received */
+#define MACB_PTP_PDELAY_REQ_FRAME_RECEIVED_SIZE		1
+#define MACB_PTP_PDELAY_RESP_FRAME_RECEIVED_OFFSET	23	/* PTP pdelay_resp frame received */
+#define MACB_PTP_PDELAY_RESP_FRAME_RECEIVED_SIZE	1
+#define MACB_PTP_PDELAY_REQ_FRAME_TRANSMITTED_OFFSET	24	/* PTP pdelay_req frame transmitted */
+#define MACB_PTP_PDELAY_REQ_FRAME_TRANSMITTED_SIZE	1
+#define MACB_PTP_PDELAY_RESP_FRAME_TRANSMITTED_OFFSET	25	/* PTP pdelay_resp frame transmitted */
+#define MACB_PTP_PDELAY_RESP_FRAME_TRANSMITTED_SIZE	1
+#define MACB_TSU_SECONDS_REGISTER_INCREMENT_OFFSET	26	/* TSU periodic (second) interrup */
+#define MACB_TSU_SECONDS_REGISTER_INCREMENT_SIZE	1
+#define MACB_TSU_TIMER_COMPARISON_INTERRUPT_OFFSET	29	/* TSU match interrupt */
+#define MACB_TSU_TIMER_COMPARISON_INTERRUPT_SIZE	1
 
 /* Bitfields in MAN */
 #define MACB_DATA_OFFSET	0 /* data */
@@ -382,6 +432,10 @@
 #define GEM_TX_PKT_BUFF_OFFSET			21
 #define GEM_TX_PKT_BUFF_SIZE			1
 
+/* Bitfields in DCFG5. */
+#define GEM_TSU_OFFSET				8
+#define GEM_TSU_SIZE				1
+
 /* Constants for CLK */
 #define MACB_CLK_DIV8				0
 #define MACB_CLK_DIV16				1
@@ -402,6 +456,74 @@
 #define MACB_MAN_READ				2
 #define MACB_MAN_CODE				2
 
+/* Constants for TSU */
+/* MACB_TSU_TIMER_INCR_SUB_NSEC */
+#define MACB_SUB_NS_INCR_MSB_OFFSET	0 /* sub-ns MSB [23:8] which the 1588 timer will be incremented each clock cycle */
+#define MACB_SUB_NS_INCR_MSB_SIZE	16
+#define MACB_SUB_NS_INCR_LSB_OFFSET	24 /* sub-ns MSB [7:0] which the 1588 timer will be incremented each clock cycle */
+#define MACB_SUB_NS_INCR_LSB_SIZE	8
+#define MACB_SUB_NS_INCR_SIZE 		(MACB_SUB_NS_INCR_MSB_SIZE + MACB_SUB_NS_INCR_LSB_SIZE)
+
+/* MACB_TSU_TIMER_INCR */
+#define MACB_NS_INCREMENT_OFFSET	0 /* ns [7:0] which the 1588 timer will be incremented each clock cycle */
+#define MACB_NS_INCREMENT_SIZE		8
+#define MACB_ALT_NS_INCR_OFFSET		8 /* Alternative nanoseconds count */
+#define MACB_ALT_NS_INCR_SIZE		8
+#define MACB_NUM_INCS_OFFSET		16 /* Number of incs before alt inc */
+#define MACB_NUM_INCS_SIZE		8
+
+/* MACB_TSU_TIMER_ADJUST */
+#define MACB_INCREMENT_VALUE_OFFSET	0 /* Timer increment value */
+#define MACB_INCREMENT_VALUE_SIZE	30
+#define MACB_ADD_SUBTRACT_OFFSET	31 /* Write as one to subtract from the 1588 timer */
+#define MACB_ADD_SUBTRACT_SIZE		1
+
+/* MACB_TSU_TIMER_MSB_SEC */
+#define MACB_TIMER_MSB_SEC_OFFSET	0 /* TSU timer value (s). MSB [47:32] of seconds timer count */
+#define MACB_TIMER_MSB_SEC_SIZE		16
+
+/* MACB_TSU_TIMER_SEC */
+#define MACB_TIMER_LSB_SEC_OFFSET	0 /* TSU timer value (s). LSB [31:0] of seconds timer count */
+#define MACB_TIMER_LSB_SEC_SIZE		32
+
+/* MACB_TSU_TIMER_NSEC */
+#define MACB_TIMER_NSEC_OFFSET		0 /* TSU timer value (ns) */
+#define MACB_TIMER_NSEC_SIZE		30
+
+/* Transmit DMA buffer descriptor Word 1 */
+#define MACB_DMA_TX_TS_VALID_OFFSET	23 /* timestamp has been captured in the Buffer Descriptor */
+#define MACB_DMA_TX_TS_VALID_SIZE	1
+
+/* Receive DMA buffer descriptor Word 0 */
+#define MACB_DMA_RX_TS_VALID_OFFSET	2 /* indicates a valid timestamp in the Buffer Descriptor */
+#define MACB_DMA_RX_TS_VALID_SIZE	1
+
+/* DMA buffer descriptor Word 2 (32 bit addressing) or Word 4 (64 bit addressing) */
+#define MACB_DMA_TS_LSB_SEC_OFFSET	30 /* Timestamp seconds[1:0]  */
+#define MACB_DMA_TS_LSB_SEC_SIZE	2
+#define MACB_DMA_TS_NSEC_OFFSET		0 /* Timestamp nanosecs [29:0] */
+#define MACB_DMA_TS_NSEC_SIZE		30
+
+/* DMA buffer descriptor Word 3 (32 bit addressing) or Word 5 (64 bit addressing) */
+
+/* New hardware supports 12 bit precision of timestamp in DMA buffer descriptor.
+ * Old hardware supports only 6 bit precision but it is enough for PTP.
+ * Less accuracy is used always instead of checking hardware version.
+ */
+#define MACB_DMA_TS_MSB_SEC_OFFSET	0 /* Timestamp seconds[5:2] */
+#define MACB_DMA_TS_MSB_SEC_SIZE	4
+#define MACB_DMA_TS_SEC_WIDTH 		(MACB_DMA_TS_MSB_SEC_SIZE + MACB_DMA_TS_LSB_SEC_SIZE)
+#define MACB_DMA_TS_SEC_TOP 		(1 << MACB_DMA_TS_SEC_WIDTH)
+#define MACB_DMA_TS_SEC_MASK 		(MACB_DMA_TS_SEC_TOP - 1)
+
+/* Constants for TX_BD_CONTROL */
+#define MACB_TX_BD_TS_MODE_OFFSET	4 /* TX Descriptor Timestamp Insertion mode */
+#define MACB_TX_BD_TS_MODE_SIZE		2
+
+/* Constants for RX_BD_CONTROL */
+#define MACB_RX_BD_TS_MODE_OFFSET 	4 /* RX Descriptor Timestamp Insertion mode */
+#define MACB_RX_BD_TS_MODE_SIZE 	2
+
 /* Capability mask bits */
 #define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x00000001
 #define MACB_CAPS_USRIO_HAS_CLKEN		0x00000002
@@ -449,6 +571,8 @@
 #define queue_readl(queue, reg)		(queue)->bp->macb_reg_readl((queue)->bp, (queue)->reg)
 #define queue_writel(queue, reg, value)	(queue)->bp->macb_reg_writel((queue)->bp, (queue)->reg, (value))
 
+#define PTP_TS_BUFFER_SIZE		128 /* must be power of 2 */
+
 /* Conditional GEM/MACB macros.  These perform the operation to the correct
  * register dependent on whether the device is a GEM or a MACB.  For registers
  * and bitfields that are common across both devices, use macb_{read,write}l
@@ -483,7 +607,18 @@ struct macb_dma_desc {
 	u32     addrh;
 	u32     resvd;
 #endif
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+	u32	dma_desc_ts_1;
+	u32	dma_desc_ts_2;
+#endif
+};
+
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+struct macb_tx_timestamp {
+	struct sk_buff *skb;
+	struct macb_dma_desc desc;
 };
+#endif
 
 /* DMA descriptor bitfields */
 #define MACB_RX_USED_OFFSET			0
@@ -794,8 +929,22 @@ struct macb_queue {
 	struct macb_tx_skb	*tx_skb;
 	dma_addr_t		tx_ring_dma;
 	struct work_struct	tx_error_task;
+
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+	/* PTP support */
+	struct work_struct 	tx_timestamp_task;
+	unsigned int 		tx_tstamp_head, tx_tstamp_tail;
+	struct macb_tx_timestamp tx_timestamps[PTP_TS_BUFFER_SIZE];
+#endif
 };
 
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+struct incrementspec {
+	u32 sub_ns;
+	u32 ns;
+};
+#endif
+
 struct macb {
 	void __iomem		*regs;
 	bool			native_io;
@@ -860,8 +1009,72 @@ struct macb {
 	unsigned int		jumbo_max_len;
 
 	u32			wol;
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+	/* PTP support */
+	bool ptp_hw_support;
+	struct ptp_clock_info ptp_clock_info;
+	struct ptp_clock *ptp_clock;
+	struct clk *tsu_clk;
+	struct incrementspec tsu_incr;
+	struct hwtstamp_config tstamp_config;
+#endif
+};
+
+#if IS_ENABLED(CONFIG_PTP_1588_CLOCK)
+#define MACB_TIMER_SEC_SIZE  (MACB_TIMER_MSB_SEC_SIZE + MACB_TIMER_LSB_SEC_SIZE)
+#define TSU_SEC_MAX_VAL (((u64)1 << MACB_TIMER_SEC_SIZE) - 1)
+#define TSU_NSEC_MAX_VAL ((1 << MACB_TIMER_NSEC_SIZE) - 1)
+
+enum macb_bd_control {
+	TSTAMP_DISABLED,
+	TSTAMP_FRAME_PTP_EVENT_ONLY,
+	TSTAMP_ALL_PTP_FRAMES,
+	TSTAMP_ALL_FRAMES,
 };
 
+int macb_ptp_init(struct platform_device *pdev);
+void macb_ptp_stop(struct platform_device *pdev);
+
+int macb_ptp_verify(struct ptp_clock_info *ptp_clock_info, unsigned int pin,
+		    enum ptp_pin_function func, unsigned int chan);
+
+/* Following functions implement interface functions of Linux PTP
+ * Framework.
+ */
+int macb_ptp_adjfreq(struct ptp_clock_info *ptp_clock_info, s32 ppb);
+int macb_ptp_adjtime(struct ptp_clock_info *ptp_clock_info, s64 delta);
+int macb_ptp_gettime(struct ptp_clock_info *ptp_clock_info,
+		     struct timespec64 *ts);
+int macb_ptp_settime(struct ptp_clock_info *ptp_clock_info,
+		     const struct timespec64 *ts);
+int macb_ptp_enable(struct ptp_clock_info *ptp_clock_info,
+		    struct ptp_clock_request *request, int on);
+
+/* Low level functions used by above interface. */
+int macb_ptp_time_get(struct macb *bp, struct timespec64 *ts);
+int macb_ptp_time_set(struct macb *bp, const struct timespec64 *ts);
+
+int macb_ptp_increment_get(struct macb *bp, struct incrementspec *incr_spec);
+int macb_ptp_increment_set(struct macb *bp, struct incrementspec *incr_spec);
+int macb_ptp_time_adjust(struct macb *bp, s32 delta);
+
+/* Timestamp reading functions */
+int macb_ptp_time_peer_frame_tx_get(struct macb *bp, struct timespec64 *ts);
+int macb_ptp_time_peer_frame_rx_get(struct macb *bp, struct timespec64 *ts);
+int macb_ptp_time_frame_tx_get(struct macb *bp, struct timespec64 *ts);
+int macb_ptp_time_frame_rx_get(struct macb *bp, struct timespec64 *ts);
+
+/* Event reporting functions */
+int macb_ptp_event(struct macb *bp, struct timespec64 *ts);
+
+/* Hardware configuratio functions */
+int macb_ptp_set_one_step_sync(struct macb *bp, u8 enable);
+int macb_ptp_set_tstamp_mode(struct macb *bp,
+			     enum macb_bd_control tx_bd_control,
+			     enum macb_bd_control rx_bd_control);
+
+#endif
+
 static inline bool macb_is_gem(struct macb *bp)
 {
 	return !!(bp->caps & MACB_CAPS_MACB_IS_GEM);
-- 
2.4.5
