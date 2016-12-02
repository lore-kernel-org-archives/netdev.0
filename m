From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v3 13/13] net: ethernet: ti: cpts: fix overflow check period
Date: Fri, 2 Dec 2016 14:30:23 -0600
Message-ID: <20161202203023.25526-14-grygorii.strashko@ti.com>
References: <20161202203023.25526-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        John Stultz <john.stultz@linaro.org>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:13420 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754217AbcLBUar (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 15:30:47 -0500
In-Reply-To: <20161202203023.25526-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CPTS drivers uses 8sec period for overflow checking with
assumption that CPTS retclk will not exceed 500MHz. But that's not
true on some TI platforms (Kesytone 2). As result, it is possible that
CPTS counter will overflow more than once between two readings.

Hence, fix it by selecting overflow check period dynamically as
max_sec_before_overflow/2, where
 max_sec_before_overflow = max_counter_val / rftclk_freq.

Cc: John Stultz <john.stultz@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 10 +++++++---
 drivers/net/ethernet/ti/cpts.h |  4 +---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 806241b..e9a8b12 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -245,7 +245,7 @@ static void cpts_overflow_check(struct work_struct *work)
 
 	cpts_ptp_gettime(&cpts->info, &ts);
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
-	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
+	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
 }
 
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
@@ -382,8 +382,7 @@ int cpts_register(struct cpts *cpts)
 	}
 	cpts->phc_index = ptp_clock_index(cpts->clock);
 
-	schedule_delayed_work(&cpts->overflow_work, CPTS_OVERFLOW_PERIOD);
-
+	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
 	return 0;
 
 err_ptp:
@@ -427,6 +426,11 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
 	if (maxsec > 10)
 		maxsec = 10;
 
+	/* Calc overflow check period (maxsec / 2) */
+	cpts->ov_check_period = (HZ * maxsec) / 2;
+	dev_info(cpts->dev, "cpts: overflow check period %lu (jiffies)\n",
+		 cpts->ov_check_period);
+
 	if (cpts->cc_mult || cpts->cc.shift)
 		return;
 
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 5da23af..c96eca2 100644
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
 
 void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-- 
2.10.1
