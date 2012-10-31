From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 3/4] bfin_mac: offer a PTP Hardware Clock.
Date: Wed, 31 Oct 2012 17:27:24 +0100
Message-ID: <6525f9eba3712d3c11744f061b022cc4038d260f.1351696541.git.richardcochran@gmail.com>
References: <cover.1351696541.git.richardcochran@gmail.com>
Cc: <device-drivers-devel@blackfin.uclinux.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>,
	Bob Liu <lliubbo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Sonic Zhang <sonic.zhang@analog.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46216 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935782Ab2JaQ1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 12:27:49 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so839847eek.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 09:27:49 -0700 (PDT)
In-Reply-To: <cover.1351696541.git.richardcochran@gmail.com>
In-Reply-To: <cover.1351696541.git.richardcochran@gmail.com>
References: <cover.1351696541.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BF518 has a PTP time unit that works in a similar way to other MAC
based clocks, like gianfar, ixp46x, and igb. This patch adds support for
using the blackfin as a PHC. Although the blackfin hardware does offer a
few ancillary features, this patch implements only the basic operations.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/adi/Kconfig    |    2 +-
 drivers/net/ethernet/adi/bfin_mac.c |  170 ++++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/adi/bfin_mac.h |    6 ++
 3 files changed, 175 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/adi/Kconfig b/drivers/net/ethernet/adi/Kconfig
index 49a30d3..175c38c 100644
--- a/drivers/net/ethernet/adi/Kconfig
+++ b/drivers/net/ethernet/adi/Kconfig
@@ -61,7 +61,7 @@ config BFIN_RX_DESC_NUM
 
 config BFIN_MAC_USE_HWSTAMP
 	bool "Use IEEE 1588 hwstamp"
-	depends on BFIN_MAC && BF518
+	depends on BFIN_MAC && BF518 && PTP_1588_CLOCK && !(BFIN_MAC=y && PTP_1588_CLOCK=m)
 	default y
 	---help---
 	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 885fa80..f1c458d 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -552,11 +552,13 @@ static int bfin_mac_ethtool_setwol(struct net_device *dev,
 static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
 	struct ethtool_ts_info *info)
 {
+	struct bfin_mac_local *lp = netdev_priv(dev);
+
 	info->so_timestamping =
 		SOF_TIMESTAMPING_TX_HARDWARE |
 		SOF_TIMESTAMPING_RX_HARDWARE |
 		SOF_TIMESTAMPING_RAW_HARDWARE;
-	info->phc_index = -1;
+	info->phc_index = lp->phc_index;
 	info->tx_types =
 		(1 << HWTSTAMP_TX_OFF) |
 		(1 << HWTSTAMP_TX_ON);
@@ -887,7 +889,7 @@ static void bfin_rx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 static void bfin_mac_hwtstamp_init(struct net_device *netdev)
 {
 	struct bfin_mac_local *lp = netdev_priv(netdev);
-	u64 addend;
+	u64 addend, ppb;
 	u32 input_clk, phc_clk;
 
 	/* Initialize hardware timer */
@@ -898,18 +900,175 @@ static void bfin_mac_hwtstamp_init(struct net_device *netdev)
 	bfin_write_EMAC_PTP_ADDEND((u32)addend);
 
 	lp->addend = addend;
+	ppb = 1000000000ULL * input_clk;
+	do_div(ppb, phc_clk);
+	lp->max_ppb = ppb - 1000000000ULL - 1ULL;
 
 	/* Initialize hwstamp config */
 	lp->stamp_cfg.rx_filter = HWTSTAMP_FILTER_NONE;
 	lp->stamp_cfg.tx_type = HWTSTAMP_TX_OFF;
 }
 
+static u64 bfin_ptp_time_read(struct bfin_mac_local *lp)
+{
+	u64 ns;
+	u32 lo, hi;
+
+	lo = bfin_read_EMAC_PTP_TIMELO();
+	hi = bfin_read_EMAC_PTP_TIMEHI();
+
+	ns = ((u64) hi) << 32;
+	ns |= lo;
+	ns <<= lp->shift;
+
+	return ns;
+}
+
+static void bfin_ptp_time_write(struct bfin_mac_local *lp, u64 ns)
+{
+	u32 hi, lo;
+
+	ns >>= lp->shift;
+	hi = ns >> 32;
+	lo = ns & 0xffffffff;
+
+	bfin_write_EMAC_PTP_TIMELO(lo);
+	bfin_write_EMAC_PTP_TIMEHI(hi);
+}
+
+/* PTP Hardware Clock operations */
+
+static int bfin_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	u64 adj;
+	u32 diff, addend;
+	int neg_adj = 0;
+	struct bfin_mac_local *lp =
+		container_of(ptp, struct bfin_mac_local, caps);
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+	addend = lp->addend;
+	adj = addend;
+	adj *= ppb;
+	diff = div_u64(adj, 1000000000ULL);
+
+	addend = neg_adj ? addend - diff : addend + diff;
+
+	bfin_write_EMAC_PTP_ADDEND(addend);
+
+	return 0;
+}
+
+static int bfin_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	s64 now;
+	unsigned long flags;
+	struct bfin_mac_local *lp =
+		container_of(ptp, struct bfin_mac_local, caps);
+
+	spin_lock_irqsave(&lp->phc_lock, flags);
+
+	now = bfin_ptp_time_read(lp);
+	now += delta;
+	bfin_ptp_time_write(lp, now);
+
+	spin_unlock_irqrestore(&lp->phc_lock, flags);
+
+	return 0;
+}
+
+static int bfin_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	u64 ns;
+	u32 remainder;
+	unsigned long flags;
+	struct bfin_mac_local *lp =
+		container_of(ptp, struct bfin_mac_local, caps);
+
+	spin_lock_irqsave(&lp->phc_lock, flags);
+
+	ns = bfin_ptp_time_read(lp);
+
+	spin_unlock_irqrestore(&lp->phc_lock, flags);
+
+	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
+	ts->tv_nsec = remainder;
+	return 0;
+}
+
+static int bfin_ptp_settime(struct ptp_clock_info *ptp,
+			   const struct timespec *ts)
+{
+	u64 ns;
+	unsigned long flags;
+	struct bfin_mac_local *lp =
+		container_of(ptp, struct bfin_mac_local, caps);
+
+	ns = ts->tv_sec * 1000000000ULL;
+	ns += ts->tv_nsec;
+
+	spin_lock_irqsave(&lp->phc_lock, flags);
+
+	bfin_ptp_time_write(lp, ns);
+
+	spin_unlock_irqrestore(&lp->phc_lock, flags);
+
+	return 0;
+}
+
+static int bfin_ptp_enable(struct ptp_clock_info *ptp,
+			  struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+static struct ptp_clock_info bfin_ptp_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "BF518 clock",
+	.max_adj	= 0,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.pps		= 0,
+	.adjfreq	= bfin_ptp_adjfreq,
+	.adjtime	= bfin_ptp_adjtime,
+	.gettime	= bfin_ptp_gettime,
+	.settime	= bfin_ptp_settime,
+	.enable		= bfin_ptp_enable,
+};
+
+static int bfin_phc_init(struct net_device *netdev, struct device *dev)
+{
+	struct bfin_mac_local *lp = netdev_priv(netdev);
+
+	lp->caps = bfin_ptp_caps;
+	lp->caps.max_adj = lp->max_ppb;
+	lp->clock = ptp_clock_register(&lp->caps, dev);
+	if (IS_ERR(lp->clock))
+		return PTR_ERR(lp->clock);
+
+	lp->phc_index = ptp_clock_index(lp->clock);
+	spin_lock_init(&lp->phc_lock);
+
+	return 0;
+}
+
+static void bfin_phc_release(struct bfin_mac_local *lp)
+{
+	ptp_clock_unregister(lp->clock);
+}
+
 #else
 # define bfin_mac_hwtstamp_is_none(cfg) 0
 # define bfin_mac_hwtstamp_init(dev)
 # define bfin_mac_hwtstamp_ioctl(dev, ifr, cmd) (-EOPNOTSUPP)
 # define bfin_rx_hwtstamp(dev, skb)
 # define bfin_tx_hwtstamp(dev, skb)
+# define bfin_phc_init(netdev, dev) 0
+# define bfin_phc_release(lp)
 #endif
 
 static inline void _tx_reclaim_skb(void)
@@ -1544,12 +1703,17 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	}
 
 	bfin_mac_hwtstamp_init(ndev);
+	if (bfin_phc_init(ndev, &pdev->dev)) {
+		dev_err(&pdev->dev, "Cannot register PHC device!\n");
+		goto out_err_phc;
+	}
 
 	/* now, print out the card info, in a short format.. */
 	netdev_info(ndev, "%s, Version %s\n", DRV_DESC, DRV_VERSION);
 
 	return 0;
 
+out_err_phc:
 out_err_reg_ndev:
 	free_irq(IRQ_MAC_RX, ndev);
 out_err_request_irq:
@@ -1568,6 +1732,8 @@ static int __devexit bfin_mac_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct bfin_mac_local *lp = netdev_priv(ndev);
 
+	bfin_phc_release(lp);
+
 	platform_set_drvdata(pdev, NULL);
 
 	lp->mii_bus->priv = NULL;
diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
index 57f042c..7a07ee0 100644
--- a/drivers/net/ethernet/adi/bfin_mac.h
+++ b/drivers/net/ethernet/adi/bfin_mac.h
@@ -11,6 +11,7 @@
 #define _BFIN_MAC_H_
 
 #include <linux/net_tstamp.h>
+#include <linux/ptp_clock_kernel.h>
 #include <linux/timer.h>
 #include <linux/etherdevice.h>
 #include <linux/bfin_mac.h>
@@ -94,7 +95,12 @@ struct bfin_mac_local {
 #if defined(CONFIG_BFIN_MAC_USE_HWSTAMP)
 	u32 addend;
 	unsigned int shift;
+	s32 max_ppb;
 	struct hwtstamp_config stamp_cfg;
+	struct ptp_clock_info caps;
+	struct ptp_clock *clock;
+	int phc_index;
+	spinlock_t phc_lock; /* protects time lo/hi registers */
 #endif
 };
 
-- 
1.7.2.5
