From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 8/9] net: ethernet: ti: cpts: fix overflow check period
Date: Wed, 14 Sep 2016 16:02:30 +0300
Message-ID: <20160914130231.3035-9-grygorii.strashko@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:51704 "EHLO comal.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762124AbcINNCy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 09:02:54 -0400
In-Reply-To: <20160914130231.3035-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CPTS drivers uses 8sec period for overflow checking with
assumption that CPTS rftclk will not exceed 500MHz. But that's not
true on some TI's platforms (Kesytone 2). As result, it is possible that
CPTS counter will overflow more than once between two readings.

Hence, fix it by selecting overflow check period dynamically as
max_sec_before_overflow/2, where
 max_sec_before_overflow = max_counter_val / rftclk_freq.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 16 +++++++++++-----
 drivers/net/ethernet/ti/cpts.h |  4 +---
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 8046a21..cbe0974 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -251,7 +251,7 @@ static void cpts_overflow_check(struct work_struct *work)
 	cpts_write32(cpts, TS_PEND_EN, int_enable);
 	cpts_ptp_gettime(&cpts->info, &ts);
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
-	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
+	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
 }
 
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
@@ -391,7 +391,7 @@ int cpts_register(struct cpts *cpts)
 	}
 	cpts->phc_index = ptp_clock_index(cpts->clock);
 
-	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
+	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
 	return 0;
 
 err_ptp:
@@ -427,9 +427,6 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
 	u64 ns;
 	u64 frac;
 
-	if (cpts->cc_mult || cpts->cc.shift)
-		return;
-
 	freq = clk_get_rate(cpts->refclk);
 
 	/* Calc the maximum number of seconds which we can run before
@@ -442,11 +439,20 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
 	else if (maxsec > 600 && cpts->cc.mask > UINT_MAX)
 		maxsec = 600;
 
+	/* Calc overflow check period (maxsec / 2) */
+	cpts->ov_check_period = (HZ * maxsec) / 2;
+	dev_info(cpts->dev, "cpts: overflow check period %lu\n",
+		 cpts->ov_check_period);
+
+	if (cpts->cc_mult || cpts->cc.shift)
+		return;
+
 	clocks_calc_mult_shift(&mult, &shift, freq, NSEC_PER_SEC, maxsec);
 
 	cpts->cc_mult = mult;
 	cpts->cc.mult = mult;
 	cpts->cc.shift = shift;
+
 	/* Check calculations and inform if not precise */
 	frac = 0;
 	ns = cyclecounter_cyc2ns(&cpts->cc, freq, cpts->cc.mask, &frac);
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 47026ec..e0e4a62b 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -97,9 +97,6 @@ enum {
 	CPTS_EV_TX,   /* Ethernet Transmit Event */
 };
 
-/* This covers any input clock up to about 500 MHz. */
-#define CPTS_OVERFLOW_PERIOD (HZ * 8)
-
 #define CPTS_FIFO_DEPTH 16
 #define CPTS_MAX_EVENTS 32
 
@@ -127,6 +124,7 @@ struct cpts {
 	struct list_head events;
 	struct list_head pool;
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
+	unsigned long ov_check_period;
 };
 
 int cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-- 
2.9.3
