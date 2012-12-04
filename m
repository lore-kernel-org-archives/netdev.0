From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/5 net-next v2] tg3: PTP - Implement the ptp api and
 ethtool functions
Date: Mon, 3 Dec 2012 21:36:58 -0800
Message-ID: <1354599420-3589-3-git-send-email-mchan@broadcom.com>
References: <1354599420-3589-1-git-send-email-mchan@broadcom.com>
 <1354599420-3589-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com,
	richardcochran@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3679 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297Ab2LDFVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 00:21:51 -0500
In-Reply-To: <1354599420-3589-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Carlson <mcarlson@broadcom.com>

This patch adds the ptp_caps structure, ptp api implementation,
reference clock read and register/unregister functions.  All the basic
clock operations as described in Documentation/ptp/ptp.txt are
supported.

Frequency adjustment is performed using hardware with a 24 bit
accumulator and a programmable correction value. On each clk, the
correction value gets added to the accumulator and when it overflows,
the time counter is incremented/decremented and the accumulator reset.

So conversion from ppb to correction value is
	ppb * (1 << 24) / 1000000000

[Re-organized to put the ptp_clock_info struct declaration in one patch,
 added ptp_clock_info.name, and added locking to tg3_ptp_adjtime() based
 on input from Richard Cochran.]

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  146 ++++++++++++++++++++++++++++++++++-
 1 files changed, 145 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 6922596..58af2a1 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -5520,6 +5520,13 @@ static int tg3_setup_phy(struct tg3 *tp, int force_reset)
 }
 
 /* tp->lock must be held */
+static u64 tg3_refclk_read(struct tg3 *tp)
+{
+	u64 stamp = tr32(TG3_EAV_REF_CLCK_LSB);
+	return stamp | (u64)tr32(TG3_EAV_REF_CLCK_MSB) << 32;
+}
+
+/* tp->lock must be held */
 static void tg3_refclk_write(struct tg3 *tp, u64 newval)
 {
 	tw32(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_STOP);
@@ -5528,6 +5535,134 @@ static void tg3_refclk_write(struct tg3 *tp, u64 newval)
 	tw32_f(TG3_EAV_REF_CLCK_CTL, TG3_EAV_REF_CLCK_CTL_RESUME);
 }
 
+static inline void tg3_full_lock(struct tg3 *tp, int irq_sync);
+static inline void tg3_full_unlock(struct tg3 *tp);
+static int tg3_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
+				SOF_TIMESTAMPING_RX_SOFTWARE |
+				SOF_TIMESTAMPING_SOFTWARE    |
+				SOF_TIMESTAMPING_TX_HARDWARE |
+				SOF_TIMESTAMPING_RX_HARDWARE |
+				SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	if (tp->ptp_clock)
+		info->phc_index = ptp_clock_index(tp->ptp_clock);
+	else
+		info->phc_index = -1;
+
+	info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
+
+	info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
+			   (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+			   (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
+			   (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT);
+	return 0;
+}
+
+static int tg3_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
+	bool neg_adj = false;
+	u32 correction = 0;
+
+	if (ppb < 0) {
+		neg_adj = true;
+		ppb = -ppb;
+	}
+
+	/* Frequency adjustment is performed using hardware with a 24 bit
+	 * accumulator and a programmable correction value. On each clk, the
+	 * correction value gets added to the accumulator and when it
+	 * overflows, the time counter is incremented/decremented.
+	 *
+	 * So conversion from ppb to correction value is
+	 *		ppb * (1 << 24) / 1000000000
+	 */
+	correction = div_u64((u64)ppb * (1 << 24), 1000000000ULL) &
+		     TG3_EAV_REF_CLK_CORRECT_MASK;
+
+	tg3_full_lock(tp, 0);
+
+	if (correction)
+		tw32(TG3_EAV_REF_CLK_CORRECT_CTL,
+		     TG3_EAV_REF_CLK_CORRECT_EN |
+		     (neg_adj ? TG3_EAV_REF_CLK_CORRECT_NEG : 0) | correction);
+	else
+		tw32(TG3_EAV_REF_CLK_CORRECT_CTL, 0);
+
+	tg3_full_unlock(tp);
+
+	return 0;
+}
+
+static int tg3_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
+
+	tg3_full_lock(tp, 0);
+	tp->ptp_adjust += delta;
+	tg3_full_unlock(tp);
+
+	return 0;
+}
+
+static int tg3_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	u64 ns;
+	u32 remainder;
+	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
+
+	tg3_full_lock(tp, 0);
+	ns = tg3_refclk_read(tp);
+	ns += tp->ptp_adjust;
+	tg3_full_unlock(tp);
+
+	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
+	ts->tv_nsec = remainder;
+
+	return 0;
+}
+
+static int tg3_ptp_settime(struct ptp_clock_info *ptp,
+			   const struct timespec *ts)
+{
+	u64 ns;
+	struct tg3 *tp = container_of(ptp, struct tg3, ptp_info);
+
+	ns = timespec_to_ns(ts);
+
+	tg3_full_lock(tp, 0);
+	tg3_refclk_write(tp, ns);
+	tp->ptp_adjust = 0;
+	tg3_full_unlock(tp);
+
+	return 0;
+}
+
+static int tg3_ptp_enable(struct ptp_clock_info *ptp,
+			  struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+static const struct ptp_clock_info tg3_ptp_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "tg3 clock",
+	.max_adj	= 250000000,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.pps		= 0,
+	.adjfreq	= tg3_ptp_adjfreq,
+	.adjtime	= tg3_ptp_adjtime,
+	.gettime	= tg3_ptp_gettime,
+	.settime	= tg3_ptp_settime,
+	.enable		= tg3_ptp_enable,
+};
+
 /* tp->lock must be held */
 static void tg3_ptp_init(struct tg3 *tp)
 {
@@ -5537,6 +5672,7 @@ static void tg3_ptp_init(struct tg3 *tp)
 	/* Initialize the hardware clock to the system time. */
 	tg3_refclk_write(tp, ktime_to_ns(ktime_get_real()));
 	tp->ptp_adjust = 0;
+	tp->ptp_info = tg3_ptp_caps;
 }
 
 /* tp->lock must be held */
@@ -5554,6 +5690,7 @@ static void tg3_ptp_fini(struct tg3 *tp)
 	if (!tg3_flag(tp, PTP_CAPABLE) || !tp->ptp_clock)
 		return;
 
+	ptp_clock_unregister(tp->ptp_clock);
 	tp->ptp_clock = NULL;
 	tp->ptp_adjust = 0;
 }
@@ -10598,6 +10735,13 @@ static int tg3_open(struct net_device *dev)
 		pci_set_power_state(tp->pdev, PCI_D3hot);
 	}
 
+	if (tg3_flag(tp, PTP_CAPABLE)) {
+		tp->ptp_clock = ptp_clock_register(&tp->ptp_info,
+						   &tp->pdev->dev);
+		if (IS_ERR(tp->ptp_clock))
+			tp->ptp_clock = NULL;
+	}
+
 	return err;
 }
 
@@ -12767,7 +12911,7 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.set_rxfh_indir		= tg3_set_rxfh_indir,
 	.get_channels		= tg3_get_channels,
 	.set_channels		= tg3_set_channels,
-	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_ts_info		= tg3_get_ts_info,
 };
 
 static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
-- 
1.7.1
