From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 2/4] bfin_mac: replace sys time stamps with raw ones instead.
Date: Wed, 31 Oct 2012 17:27:23 +0100
Message-ID: <b3bfe20bd4477e751d2e2b543b513d781eb0dd44.1351696541.git.richardcochran@gmail.com>
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
Received: from mail-ea0-f174.google.com ([209.85.215.174]:35420 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935782Ab2JaQ1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 12:27:46 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so626398eaa.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 09:27:45 -0700 (PDT)
In-Reply-To: <cover.1351696541.git.richardcochran@gmail.com>
In-Reply-To: <cover.1351696541.git.richardcochran@gmail.com>
References: <cover.1351696541.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the sys time stamps and timecompare code with simple
raw hardware time stamps in nanosecond resolution. The only tricky bit is
to find a PTP Hardware Clock period slower than the input clock period
and a power of two.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |   91 ++++++++++-------------------------
 drivers/net/ethernet/adi/bfin_mac.h |    7 +--
 2 files changed, 28 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 2349abb..885fa80 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -555,7 +555,7 @@ static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
 	info->so_timestamping =
 		SOF_TIMESTAMPING_TX_HARDWARE |
 		SOF_TIMESTAMPING_RX_HARDWARE |
-		SOF_TIMESTAMPING_SYS_HARDWARE;
+		SOF_TIMESTAMPING_RAW_HARDWARE;
 	info->phc_index = -1;
 	info->tx_types =
 		(1 << HWTSTAMP_TX_OFF) |
@@ -653,6 +653,20 @@ static int bfin_mac_set_mac_address(struct net_device *dev, void *p)
 #ifdef CONFIG_BFIN_MAC_USE_HWSTAMP
 #define bfin_mac_hwtstamp_is_none(cfg) ((cfg) == HWTSTAMP_FILTER_NONE)
 
+static u32 bfin_select_phc_clock(u32 input_clk, unsigned int *shift_result)
+{
+	u32 ipn = 1000000000UL / input_clk;
+	u32 ppn = 1;
+	unsigned int shift = 0;
+
+	while (ppn <= ipn) {
+		ppn <<= 1;
+		shift++;
+	}
+	*shift_result = shift;
+	return 1000000000UL / ppn;
+}
+
 static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 		struct ifreq *ifr, int cmd)
 {
@@ -802,19 +816,7 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 		bfin_read_EMAC_PTP_TXSNAPLO();
 		bfin_read_EMAC_PTP_TXSNAPHI();
 
-		/*
-		 * Set registers so that rollover occurs soon to test this.
-		 */
-		bfin_write_EMAC_PTP_TIMELO(0x00000000);
-		bfin_write_EMAC_PTP_TIMEHI(0xFF800000);
-
 		SSYNC();
-
-		lp->compare.last_update = 0;
-		timecounter_init(&lp->clock,
-				&lp->cycles,
-				ktime_to_ns(ktime_get_real()));
-		timecompare_update(&lp->compare, 0);
 	}
 
 	lp->stamp_cfg = config;
@@ -822,15 +824,6 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 		-EFAULT : 0;
 }
 
-static void bfin_dump_hwtamp(char *s, ktime_t *hw, ktime_t *ts, struct timecompare *cmp)
-{
-	ktime_t sys = ktime_get_real();
-
-	pr_debug("%s %s hardware:%d,%d transform system:%d,%d system:%d,%d, cmp:%lld, %lld\n",
-			__func__, s, hw->tv.sec, hw->tv.nsec, ts->tv.sec, ts->tv.nsec, sys.tv.sec,
-			sys.tv.nsec, cmp->offset, cmp->skew);
-}
-
 static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 {
 	struct bfin_mac_local *lp = netdev_priv(netdev);
@@ -861,15 +854,9 @@ static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 			regval = bfin_read_EMAC_PTP_TXSNAPLO();
 			regval |= (u64)bfin_read_EMAC_PTP_TXSNAPHI() << 32;
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
-			ns = timecounter_cyc2time(&lp->clock,
-					regval);
-			timecompare_update(&lp->compare, ns);
+			ns = regval << lp->shift;
 			shhwtstamps.hwtstamp = ns_to_ktime(ns);
-			shhwtstamps.syststamp =
-				timecompare_transform(&lp->compare, ns);
 			skb_tstamp_tx(skb, &shhwtstamps);
-
-			bfin_dump_hwtamp("TX", &shhwtstamps.hwtstamp, &shhwtstamps.syststamp, &lp->compare);
 		}
 	}
 }
@@ -892,51 +879,25 @@ static void bfin_rx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 
 	regval = bfin_read_EMAC_PTP_RXSNAPLO();
 	regval |= (u64)bfin_read_EMAC_PTP_RXSNAPHI() << 32;
-	ns = timecounter_cyc2time(&lp->clock, regval);
-	timecompare_update(&lp->compare, ns);
+	ns = regval << lp->shift;
 	memset(shhwtstamps, 0, sizeof(*shhwtstamps));
 	shhwtstamps->hwtstamp = ns_to_ktime(ns);
-	shhwtstamps->syststamp = timecompare_transform(&lp->compare, ns);
-
-	bfin_dump_hwtamp("RX", &shhwtstamps->hwtstamp, &shhwtstamps->syststamp, &lp->compare);
-}
-
-/*
- * bfin_read_clock - read raw cycle counter (to be used by time counter)
- */
-static cycle_t bfin_read_clock(const struct cyclecounter *tc)
-{
-	u64 stamp;
-
-	stamp =  bfin_read_EMAC_PTP_TIMELO();
-	stamp |= (u64)bfin_read_EMAC_PTP_TIMEHI() << 32ULL;
-
-	return stamp;
 }
 
-#define PTP_CLK 25000000
-
 static void bfin_mac_hwtstamp_init(struct net_device *netdev)
 {
 	struct bfin_mac_local *lp = netdev_priv(netdev);
-	u64 append;
+	u64 addend;
+	u32 input_clk, phc_clk;
 
 	/* Initialize hardware timer */
-	append = PTP_CLK * (1ULL << 32);
-	do_div(append, get_sclk());
-	bfin_write_EMAC_PTP_ADDEND((u32)append);
-
-	memset(&lp->cycles, 0, sizeof(lp->cycles));
-	lp->cycles.read = bfin_read_clock;
-	lp->cycles.mask = CLOCKSOURCE_MASK(64);
-	lp->cycles.mult = 1000000000 / PTP_CLK;
-	lp->cycles.shift = 0;
-
-	/* Synchronize our NIC clock against system wall clock */
-	memset(&lp->compare, 0, sizeof(lp->compare));
-	lp->compare.source = &lp->clock;
-	lp->compare.target = ktime_get_real;
-	lp->compare.num_samples = 10;
+	input_clk = get_sclk();
+	phc_clk = bfin_select_phc_clock(input_clk, &lp->shift);
+	addend = phc_clk * (1ULL << 32);
+	do_div(addend, input_clk);
+	bfin_write_EMAC_PTP_ADDEND((u32)addend);
+
+	lp->addend = addend;
 
 	/* Initialize hwstamp config */
 	lp->stamp_cfg.rx_filter = HWTSTAMP_FILTER_NONE;
diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
index 960905c..57f042c 100644
--- a/drivers/net/ethernet/adi/bfin_mac.h
+++ b/drivers/net/ethernet/adi/bfin_mac.h
@@ -11,8 +11,6 @@
 #define _BFIN_MAC_H_
 
 #include <linux/net_tstamp.h>
-#include <linux/clocksource.h>
-#include <linux/timecompare.h>
 #include <linux/timer.h>
 #include <linux/etherdevice.h>
 #include <linux/bfin_mac.h>
@@ -94,9 +92,8 @@ struct bfin_mac_local {
 	struct mii_bus *mii_bus;
 
 #if defined(CONFIG_BFIN_MAC_USE_HWSTAMP)
-	struct cyclecounter cycles;
-	struct timecounter clock;
-	struct timecompare compare;
+	u32 addend;
+	unsigned int shift;
 	struct hwtstamp_config stamp_cfg;
 #endif
 };
-- 
1.7.2.5
