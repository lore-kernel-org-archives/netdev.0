From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 12/12] ptp: Added a clock driver for the National
 Semiconductor PHYTER.
Date: Tue, 15 Jun 2010 18:10:45 +0200
Message-ID: <37f5015b186bdd51f8451ade042f90c8b39a5cc8.1276615626.git.richard.cochran@omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43726 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754837Ab0FOQJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:09:54 -0400
Received: by mail-fx0-f46.google.com with SMTP id 10so266600fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 09:09:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the PTP clock found on the DP83640. Only the
basic clock operations have been implemented.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/Kconfig   |   11 +++
 drivers/net/phy/dp83640.c |  158 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 168 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 430cab1..507c68a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -79,9 +79,20 @@ config NATIONAL_PHY
 
 config DP83640_PHY
 	tristate "Driver for the National Semiconductor DP83640 PHYTER"
+	depends on PTP_1588_CLOCK
+	depends on NETWORK_PHY_TIMESTAMPING
 	---help---
 	  Supports the DP83640 PHYTER with IEEE 1588 features.
 
+	  This driver adds support for using the DP83640 as a PTP
+	  clock. This clock is only useful if your PTP programs are
+	  getting hardware time stamps on the PTP Ethernet packets
+	  using the SO_TIMESTAMPING API.
+
+	  In order for this to work, your MAC driver must also
+	  implement the the skb_tx_timetamp() and skb_rx_timetamp()
+	  functions.
+
 config STE10XP
 	depends on PHYLIB
 	tristate "Driver for STMicroelectronics STe10Xp PHYs"
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index a3217ea..21eadc3 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/ptp_classify.h>
+#include <linux/ptp_clock_kernel.h>
 
 #include "dp83640_reg.h"
 
@@ -45,10 +46,13 @@ struct rxts {
 };
 
 struct dp83640_private {
+	struct phy_device *phydev;
 	int hwts_tx_en;
 	int hwts_rx_en;
 	int layer;
 	int version;
+	/* protects PTP_TDR register from concurrent access */
+	spinlock_t ptp_tdr_lock;
 	/* protects extended registers from concurrent access */
 	spinlock_t extreg_lock;
 	int page;
@@ -60,6 +64,9 @@ struct dp83640_private {
 
 /* globals */
 
+static struct ptp_clock *dp83640_clock;
+DEFINE_SPINLOCK(clock_lock); /* protects the one and only dp83640_clock */
+
 static struct sock_filter ptp_filter[] = {
 	PTP_FILTER
 };
@@ -99,6 +106,129 @@ static void ext_write(struct phy_device *phydev, int page, u32 regnum, u16 val)
 	spin_unlock(&dp83640->extreg_lock);
 }
 
+static int tdr_write(struct dp83640_private *dp83640,
+		     struct timespec *ts, u16 cmd)
+{
+	struct phy_device *phydev = dp83640->phydev;
+
+	spin_lock(&dp83640->ptp_tdr_lock);
+
+	ext_write(phydev, PAGE4, PTP_TDR, ts->tv_nsec & 0xffff);/* ns[15:0] */
+	ext_write(phydev, PAGE4, PTP_TDR, ts->tv_nsec >> 16);   /* ns[31:16] */
+	ext_write(phydev, PAGE4, PTP_TDR, ts->tv_sec & 0xffff); /* sec[15:0] */
+	ext_write(phydev, PAGE4, PTP_TDR, ts->tv_sec >> 16);    /* sec[31:16] */
+
+	ext_write(phydev, PAGE4, PTP_CTL, cmd);
+
+	spin_unlock(&dp83640->ptp_tdr_lock);
+
+	return 0;
+}
+
+/* ptp clock methods */
+
+static int ptp_dp83640_adjfreq(void *priv, s32 ppb)
+{
+	struct dp83640_private *dp83640 = priv;
+	struct phy_device *phydev = dp83640->phydev;
+	u64 rate;
+	int neg_adj = 0;
+	u16 hi, lo;
+
+	if (!ppb)
+		return 0;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+	rate = ppb;
+	rate <<= 26;
+	rate = div_u64(rate, 1953125);
+
+	hi = (rate >> 16) & PTP_RATE_HI_MASK;
+	if (neg_adj)
+		hi |= PTP_RATE_DIR;
+
+	lo = rate & 0xffff;
+
+	ext_write(phydev, PAGE4, PTP_RATEH, hi);
+	ext_write(phydev, PAGE4, PTP_RATEL, lo);
+
+	return 0;
+}
+
+static int ptp_dp83640_adjtime(void *priv, struct timespec *ts)
+{
+	return tdr_write(priv, ts, PTP_STEP_CLK);
+}
+
+static int ptp_dp83640_gettime(void *priv, struct timespec *ts)
+{
+	struct dp83640_private *dp83640 = priv;
+	struct phy_device *phydev = dp83640->phydev;
+	unsigned int val[4];
+
+	spin_lock(&dp83640->ptp_tdr_lock);
+
+	ext_write(phydev, PAGE4, PTP_CTL, PTP_RD_CLK);
+
+	val[0] = ext_read(phydev, PAGE4, PTP_TDR); /* ns[15:0] */
+	val[1] = ext_read(phydev, PAGE4, PTP_TDR); /* ns[31:16] */
+	val[2] = ext_read(phydev, PAGE4, PTP_TDR); /* sec[15:0] */
+	val[3] = ext_read(phydev, PAGE4, PTP_TDR); /* sec[31:16] */
+
+	spin_unlock(&dp83640->ptp_tdr_lock);
+
+	ts->tv_nsec = val[0] | (val[1] << 16);
+	ts->tv_sec  = val[2] | (val[3] << 16);
+
+	return 0;
+}
+
+static int ptp_dp83640_settime(void *priv, struct timespec *ts)
+{
+	return tdr_write(priv, ts, PTP_LOAD_CLK);
+}
+
+static int ptp_dp83640_gettimer(void *priv, int index, struct itimerspec *ts)
+{
+	/* We do not (yet) offer any ancillary features. */
+	return -EOPNOTSUPP;
+}
+
+static int ptp_dp83640_settimer(void *p, int i, int abs, struct itimerspec *ts)
+{
+	/* We do not (yet) offer any ancillary features. */
+	return -EOPNOTSUPP;
+}
+
+static int ptp_dp83640_enable(void *priv, struct ptp_clock_request *rq, int on)
+{
+	/* We do not (yet) offer any ancillary features. */
+	return -EOPNOTSUPP;
+}
+
+static struct ptp_clock_info ptp_dp83640_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "dp83640 timer",
+	.max_adj	= 1953124,
+	.n_alarm	= 0,
+	.n_ext_ts	= 0,
+	.n_per_out	= 0,
+	.pps		= 0,
+	.priv		= NULL,
+	.adjfreq	= ptp_dp83640_adjfreq,
+	.adjtime	= ptp_dp83640_adjtime,
+	.gettime	= ptp_dp83640_gettime,
+	.settime	= ptp_dp83640_settime,
+	.gettimer	= ptp_dp83640_gettimer,
+	.settimer	= ptp_dp83640_settimer,
+	.enable		= ptp_dp83640_enable,
+};
+
+/* time stamping methods */
+
 static int expired(struct rxts *rxts)
 {
 	return time_after(jiffies, rxts->tmo);
@@ -144,6 +274,7 @@ static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
 static int dp83640_probe(struct phy_device *phydev)
 {
 	struct dp83640_private *dp83640;
+	unsigned long flags;
 	int i;
 
 	if (sk_chk_filter(ptp_filter, ARRAY_SIZE(ptp_filter))) {
@@ -155,8 +286,9 @@ static int dp83640_probe(struct phy_device *phydev)
 	if (!dp83640)
 		return -ENOMEM;
 
+	dp83640->phydev = phydev;
+	spin_lock_init(&dp83640->ptp_tdr_lock);
 	spin_lock_init(&dp83640->extreg_lock);
-
 	INIT_LIST_HEAD(&dp83640->rxts);
 	INIT_LIST_HEAD(&dp83640->pool);
 
@@ -165,12 +297,36 @@ static int dp83640_probe(struct phy_device *phydev)
 
 	phydev->priv = dp83640;
 
+	spin_lock_irqsave(&clock_lock, flags);
+
+	if (!dp83640_clock) {
+		ptp_dp83640_caps.priv = dp83640;
+		dp83640_clock = ptp_clock_register(&ptp_dp83640_caps);
+		if (IS_ERR(dp83640_clock)) {
+			spin_unlock_irqrestore(&clock_lock, flags);
+			kfree(dp83640);
+			return PTR_ERR(dp83640_clock);
+		}
+	}
+	spin_unlock_irqrestore(&clock_lock, flags);
+
 	return 0;
 }
 
 static void dp83640_remove(struct phy_device *phydev)
 {
 	struct dp83640_private *dp83640 = phydev->priv;
+	unsigned long flags;
+
+	spin_lock_irqsave(&clock_lock, flags);
+
+	if (ptp_dp83640_caps.priv == dp83640) {
+		ptp_clock_unregister(dp83640_clock);
+		dp83640_clock = NULL;
+		ptp_dp83640_caps.priv = NULL;
+	}
+	spin_unlock_irqrestore(&clock_lock, flags);
+
 	kfree(dp83640);
 }
 
-- 
1.6.3.3

