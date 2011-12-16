From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 3/6] tg3: Implement adaptive interrupt coalescing
Date: Fri, 16 Dec 2011 10:19:46 -0800
Message-ID: <d0e4b4c1a9bf2c12ae3aae205e2411a5359e5b77.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Cc: Javier Martinez Canillas <martinez.javier@gmail.com>,
	Robin Getz <rgetz@blackfin.uclinux.org>,
	Matt Mackall <mpm@selenic.com>, Ying Cai <ycai@google.com>,
	David Decotigny <decot@googlers.com>
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f74.google.com ([209.85.213.74]:40311 "EHLO
	mail-yw0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760199Ab1LPSZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 13:25:40 -0500
Received: by yhjj51 with SMTP id j51so537704yhj.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 10:25:40 -0800 (PST)
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
In-Reply-To: <cover.1324059527.git.decot@googlers.com>
References: <cover.1324059527.git.decot@googlers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Cai <ycai@google.com>

Implement adaptive coalescing in the tg3 driver. On an opteron-based
test system, interrupt rate can be reduced from 40K intrs/sec to less
than 10K intrs/sec on netperf tests, with netperf performances gaining
2 to 14% (depending on the tests).

Example with 200 netperf streams in parallel for 100s, irq/s measured
at the netperf client host, netperf figure is cumulative on all 200
streams:

Without this patch:
TCP_RR       netperf=284208               eth0 irq/s=55141.9
TCP_CRR      netperf=32204.5              eth0 irq/s=15727.7
TCP_MAERTS   netperf=944.68               eth0 irq/s=16255.5
pktgen loopback (pkt_size 60) 484718 pps

With patch:
TCP_RR       netperf=317511  (111.72%)    eth0 irq/s=8307.77 (15.07%)
TCP_CRR      netperf=35890.1 (111.44%)    eth0 irq/s=4390.89 (27.92%)
TCP_MAERTS   netperf=971.64  (102.85%)    eth0 irq/s=8135.58 (50.05%)
pktgen loopback (pkt_size 60) 552185 pps (113.92%)



Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  174 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/tg3.h |   37 ++++++++
 2 files changed, 211 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a65b419..9deb6a6 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -52,6 +52,7 @@
 #include <linux/io.h>
 #include <asm/byteorder.h>
 #include <linux/uaccess.h>
+#include <linux/jiffies.h>
 
 #ifdef CONFIG_SPARC
 #include <asm/idprom.h>
@@ -413,6 +414,9 @@ static const struct {
 #define TG3_NUM_TEST	ARRAY_SIZE(ethtool_test_keys)
 
 
+static inline void tg3_full_lock(struct tg3 *tp, int irq_sync);
+static inline void tg3_full_unlock(struct tg3 *tp);
+
 static void tg3_write32(struct tg3 *tp, u32 off, u32 val)
 {
 	writel(val, tp->regs + off);
@@ -5503,6 +5507,168 @@ static void tg3_recycle_rx(struct tg3_napi *tnapi,
 	src_map->data = NULL;
 }
 
+static inline int tg3_coal_adaptive_init(struct tg3 *tp)
+{
+	tp->ad.rx_jiffies         = jiffies;
+	tp->ad.rx_interval        = 0;
+	tp->ad.rx_frames          = 0;
+	tp->ad.rx_average_frames  = 0;
+	tp->ad.rx_reg_frames      = TG3_COAL_RX_FRAMES;
+	tp->ad.rx_adaptive_mode   = TG3_COAL_ADAPTIVE_MODE;
+	tp->ad.rx_frames_high     = TG3_COAL_ADAPTIVE_MAX_FRAMES;
+	tp->ad.rx_usecs_high      = TG3_COAL_ADAPTIVE_MAX_USECS;
+	tp->ad.rx_sample_interval = msecs_to_jiffies(TG3_COAL_ADAPTIVE_SAMPLE);
+
+	/* over-write tg3 stored coalescing values. Using 2.6.11 tg3
+	 * adaptive coalescing values
+	 */
+	tp->coal.rx_coalesce_usecs = TG3_COAL_RX_TICKS;
+	tp->coal.tx_coalesce_usecs = TG3_COAL_TX_TICKS;
+	tp->coal.rx_max_coalesced_frames = TG3_COAL_RX_FRAMES;
+	tp->coal.tx_max_coalesced_frames = TG3_COAL_TX_FRAMES;
+	tp->coal.rx_max_coalesced_frames_irq = TG3_COAL_RX_FRAMES;
+
+	return 0;
+}
+
+static int tg3_coal_adaptive_set(struct net_device *dev,
+				 struct ethtool_coalesce *cmd)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	int i = 0;
+
+	tg3_full_lock(tp, 0);
+	/* changing adaptive coalescing resets the rx frames coalescing to
+	 * the default value. turning off adaptive coalescing, means use the
+	 * default behavior, while turning it on means starts computing now....
+	 * note that this is done before setting any hardcoded values, thus
+	 * allowing a single call to turn off adaptive coalescing and setting
+	 * a new value for hard coded (static) coalescing
+	 */
+
+	/* reset host coalescing engine. */
+	tw32(HOSTCC_MODE, 0);
+	for (i = 0; i < 2000; i++) {
+		if (!(tr32(HOSTCC_MODE) & HOSTCC_MODE_ENABLE))
+			break;
+		udelay(10);
+	}
+
+	if (tp->ad.rx_adaptive_mode != cmd->use_adaptive_rx_coalesce) {
+		tp->ad.rx_jiffies  = jiffies;
+		tp->ad.rx_frames   = 0;
+		tp->ad.rx_interval = 0;
+		tp->ad.rx_average_frames = 0;
+	}
+
+	tp->ad.rx_adaptive_mode   = cmd->use_adaptive_rx_coalesce;
+	tp->ad.rx_usecs_high      = cmd->rx_coalesce_usecs_high;
+	tp->ad.rx_frames_high     = cmd->rx_max_coalesced_frames_high;
+	tp->ad.rx_sample_interval = msecs_to_jiffies(cmd->rate_sample_interval);
+
+	tw32(HOSTCC_MODE, HOSTCC_MODE_ENABLE | tp->coalesce_mode);
+
+	tg3_full_unlock(tp);
+
+	return 0;
+}
+
+static int tg3_coal_adaptive_get(struct net_device *dev,
+				 struct ethtool_coalesce *cmd)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (tp->ad.rx_adaptive_mode) {
+		tg3_full_lock(tp, 0);
+
+		cmd->rx_coalesce_usecs       = tr32(HOSTCC_RXCOL_TICKS);
+		cmd->rx_max_coalesced_frames = tr32(HOSTCC_RXMAX_FRAMES);
+
+		cmd->tx_coalesce_usecs       = tr32(HOSTCC_TXCOL_TICKS);
+		cmd->tx_max_coalesced_frames = tr32(HOSTCC_TXMAX_FRAMES);
+
+		cmd->rx_max_coalesced_frames_irq = tr32(HOSTCC_RXCOAL_MAXF_INT);
+		cmd->tx_max_coalesced_frames_irq = tr32(HOSTCC_TXCOAL_MAXF_INT);
+
+		cmd->use_adaptive_rx_coalesce     = tp->ad.rx_adaptive_mode;
+		cmd->rx_coalesce_usecs_high       = tp->ad.rx_usecs_high;
+		cmd->rx_max_coalesced_frames_high = tp->ad.rx_frames_high;
+		cmd->rate_sample_interval         = jiffies_to_msecs(
+		    tp->ad.rx_sample_interval);
+
+		tg3_full_unlock(tp);
+	}
+	return 0;
+}
+
+static inline int tg3_coal_adaptive_rx(struct tg3 *tp, int received)
+{
+	unsigned long cur_jiffies = jiffies;
+
+	unsigned long diff = cur_jiffies - tp->ad.rx_jiffies;
+
+	tp->ad.rx_interval += diff;
+
+	tp->ad.rx_jiffies  = cur_jiffies;
+	tp->ad.rx_frames  += received;
+
+	if ((tp->ad.rx_interval >= tp->ad.rx_sample_interval) &&
+	    (0 != tp->ad.rx_interval)) {
+		unsigned long rx_rate;
+
+		/* average packet per ms   */
+		tp->ad.rx_frames /= jiffies_to_msecs(tp->ad.rx_interval);
+		/* apply coalescing factor */
+		tp->ad.rx_frames >>= TG3_COAL_FACTOR_EXP;
+
+		/* compute a running average of the packet rate
+		 * the goal of the running average is to provide a faster
+		 * response to lowering rate compare to slowly increasing rate.
+		 *
+		 * if the new sample interval rate as decreased from the running
+		 * average, set the register coalescing to new sample interval
+		 * rate. else, average the new rate with the running average
+		 */
+		tp->ad.rx_average_frames += tp->ad.rx_frames;
+		tp->ad.rx_average_frames >>= 1;
+
+		if (tp->ad.rx_frames <= tp->ad.rx_average_frames)
+			rx_rate = tp->ad.rx_frames;
+		else
+			rx_rate = tp->ad.rx_average_frames;
+
+		/* adjust based on max values. Also do not set a '0' value in
+		 * the average frames, always set the average to at least one
+		 * frame. From the BCM documentation it is recommended to set
+		 * the register value to get an interrupt for every rx packet.
+		 * we could use 0, which would disable coalescing and should
+		 * have the same result.
+		 */
+		if (rx_rate > tp->ad.rx_frames_high)
+			rx_rate = tp->ad.rx_frames_high;
+		else if (0 == rx_rate)
+			rx_rate = 1;
+
+		if (rx_rate != tp->ad.rx_reg_frames) {
+			unsigned long rx_usecs;
+			rx_usecs = rx_rate *  TG3_COAL_TICK_PER_FRAME;
+			if (rx_usecs > tp->ad.rx_usecs_high)
+				rx_usecs = tp->ad.rx_usecs_high;
+
+			tw32(HOSTCC_RXCOL_TICKS, rx_usecs);
+			tw32(HOSTCC_RXMAX_FRAMES, rx_rate);
+			tw32(HOSTCC_RXCOAL_MAXF_INT, rx_rate);
+			tp->ad.rx_reg_frames = rx_rate;
+		}
+
+		tp->ad.rx_frames   = 0;
+		tp->ad.rx_interval = 0;
+
+	}
+
+	return 0;
+}
+
 /* The RX ring scheme is composed of multiple rings which post fresh
  * buffers to the chip, and one special ring the chip uses to report
  * status back to the host.
@@ -5679,6 +5845,9 @@ next_pkt_nopost:
 		}
 	}
 
+	if (TG3_COAL_ADAPTIVE_ON == tp->ad.rx_adaptive_mode)
+		tg3_coal_adaptive_rx(tp, received);
+
 	/* ACK the status ring. */
 	tnapi->rx_rcb_ptr = sw_idx;
 	tw32_rx_mbox(tnapi->consmbox, sw_idx);
@@ -11866,6 +12035,7 @@ static int tg3_get_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	struct tg3 *tp = netdev_priv(dev);
 
 	memcpy(ec, &tp->coal, sizeof(*ec));
+	tg3_coal_adaptive_get(dev, ec);
 	return 0;
 }
 
@@ -11915,6 +12085,8 @@ static int tg3_set_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 	tp->coal.tx_max_coalesced_frames_irq = ec->tx_max_coalesced_frames_irq;
 	tp->coal.stats_block_coalesce_usecs = ec->stats_block_coalesce_usecs;
 
+	tg3_coal_adaptive_set(dev, ec);
+
 	if (netif_running(dev)) {
 		tg3_full_lock(tp, 0);
 		__tg3_set_coalesce(tp, &tp->coal);
@@ -15319,6 +15491,8 @@ static void __devinit tg3_init_coal(struct tg3 *tp)
 		ec->tx_coalesce_usecs_irq = 0;
 		ec->stats_block_coalesce_usecs = 0;
 	}
+
+	tg3_coal_adaptive_init(tp);
 }
 
 static const struct net_device_ops tg3_netdev_ops = {
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index aea8f72..695cf14 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3211,6 +3211,43 @@ struct tg3 {
 
 	struct ethtool_coalesce		coal;
 
+	struct {
+		unsigned long  rx_jiffies;	  /* last read jiffies */
+		unsigned long  rx_interval;	  /* rcv interval in jiffies */
+		unsigned long  rx_reg_frames;	  /* current register value */
+		unsigned long  rx_frames;	  /* received frame in interval*/
+		unsigned long  rx_average_frames; /* computed received average */
+		unsigned int   rx_adaptive_mode;  /* adaptive mode on/off */
+		unsigned long  rx_frames_high;	  /* max coalescing frame in */
+						  /* adaptive mode */
+		unsigned long  rx_usecs_high;	  /* max usecs in adaptive  */
+						  /* mode */
+		unsigned long  rx_sample_interval;/* adaptive sample rate */
+						  /* in jiffies (msecs) */
+	} ad; /* adaptive coalescing */
+
+#define TG3_COAL_ADAPTIVE_ON	1
+#define TG3_COAL_ADAPTIVE_OFF	0
+#define TG3_COAL_ADAPTIVE_MODE	TG3_COAL_ADAPTIVE_ON
+
+/* Ticks are in TG3 register units and not in system units */
+#define TG3_COAL_FACTOR_EXP	3 /* coalescence factor, num irq per ms max. */
+				  /* this is the exponent of a power of two.  */
+
+#define TG3_COAL_TICK_PER_FRAME	10 /* tick per frame, num of us per tick */
+				   /* per frame. Used tg3 ms tick unit */
+
+#define TG3_COAL_ADAPTIVE_MAX_FRAMES	32
+#define TG3_COAL_ADAPTIVE_MAX_USECS	(TG3_COAL_ADAPTIVE_MAX_FRAMES \
+					 << TG3_COAL_TICK_PER_FRAME)
+
+#define TG3_COAL_ADAPTIVE_SAMPLE	10 /* ms samples */
+
+#define TG3_COAL_TX_FRAMES	32  /* must be <= to 1/2 TG3_TX_RING_SIZE */
+#define TG3_COAL_TX_TICKS	(TG3_COAL_TX_FRAMES * TG3_COAL_TICK_PER_FRAME)
+#define TG3_COAL_RX_FRAMES	1
+#define TG3_COAL_RX_TICKS	(TG3_COAL_RX_FRAMES * TG3_COAL_TICK_PER_FRAME)
+
 	/* firmware info */
 	const char			*fw_needed;
 	const struct firmware		*fw;
-- 
1.7.3.1
