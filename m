From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/3] dp83640: enable six external events and one periodic output
Date: Tue, 20 Sep 2011 13:43:14 +0200
Message-ID: <a381a1a852768c99c1734d42aff4c9d1b14aaeb1.1316518332.git.richard.cochran@omicron.at>
References: <cover.1316518332.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55213 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755111Ab1ITLnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 07:43:03 -0400
Received: by eya28 with SMTP id 28so124723eya.19
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2011 04:43:02 -0700 (PDT)
In-Reply-To: <cover.1316518332.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1316518332.git.richard.cochran@omicron.at>
References: <cover.1316518332.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables six external event channels and one periodic output.
One GPIO is reserved for synchronizing multiple PHYs. The assignment
of GPIO functions can be changed via a module parameter.

The code supports multiple simultaneous events by inducing a PTP clock
event for every channel marked in the PHY's extended status word.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/dp83640.c |  135 ++++++++++++++++++++++++++++++++++++++------
 1 files changed, 116 insertions(+), 19 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index edd7304..d3c6a2e 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -35,16 +35,15 @@
 #define LAYER4		0x02
 #define LAYER2		0x01
 #define MAX_RXTS	64
-#define N_EXT_TS	1
+#define N_EXT_TS	6
 #define PSF_PTPVER	2
 #define PSF_EVNT	0x4000
 #define PSF_RX		0x2000
 #define PSF_TX		0x1000
 #define EXT_EVENT	1
-#define EXT_GPIO	1
-#define CAL_EVENT	2
-#define CAL_GPIO	9
-#define CAL_TRIGGER	2
+#define CAL_EVENT	7
+#define CAL_TRIGGER	7
+#define PER_TRIGGER	6
 
 /* phyter seems to miss the mark by 16 ns */
 #define ADJTIME_FIX	16
@@ -131,16 +130,30 @@ struct dp83640_clock {
 
 /* globals */
 
+enum {
+	CALIBRATE_GPIO,
+	PEROUT_GPIO,
+	EXTTS0_GPIO,
+	EXTTS1_GPIO,
+	EXTTS2_GPIO,
+	EXTTS3_GPIO,
+	EXTTS4_GPIO,
+	EXTTS5_GPIO,
+	GPIO_TABLE_SIZE
+};
+
 static int chosen_phy = -1;
-static ushort cal_gpio = 4;
+static ushort gpio_tab[GPIO_TABLE_SIZE] = {
+	1, 2, 3, 4, 8, 9, 10, 11
+};
 
 module_param(chosen_phy, int, 0444);
-module_param(cal_gpio, ushort, 0444);
+module_param_array(gpio_tab, ushort, NULL, 0444);
 
 MODULE_PARM_DESC(chosen_phy, \
 	"The address of the PHY to use for the ancillary clock features");
-MODULE_PARM_DESC(cal_gpio, \
-	"Which GPIO line to use for synchronizing multiple PHYs");
+MODULE_PARM_DESC(gpio_tab, \
+	"Which GPIO line to use for which purpose: cal,perout,extts1,...,extts6");
 
 /* a list of clocks and a mutex to protect it */
 static LIST_HEAD(phyter_clocks);
@@ -235,6 +248,61 @@ static u64 phy2txts(struct phy_txts *p)
 	return ns;
 }
 
+static void periodic_output(struct dp83640_clock *clock,
+			    struct ptp_clock_request *clkreq, bool on)
+{
+	struct dp83640_private *dp83640 = clock->chosen;
+	struct phy_device *phydev = dp83640->phydev;
+	u32 sec, nsec, period;
+	u16 gpio, ptp_trig, trigger, val;
+
+	gpio = on ? gpio_tab[PEROUT_GPIO] : 0;
+	trigger = PER_TRIGGER;
+
+	ptp_trig = TRIG_WR |
+		(trigger & TRIG_CSEL_MASK) << TRIG_CSEL_SHIFT |
+		(gpio & TRIG_GPIO_MASK) << TRIG_GPIO_SHIFT |
+		TRIG_PER |
+		TRIG_PULSE;
+
+	val = (trigger & TRIG_SEL_MASK) << TRIG_SEL_SHIFT;
+
+	if (!on) {
+		val |= TRIG_DIS;
+		mutex_lock(&clock->extreg_lock);
+		ext_write(0, phydev, PAGE5, PTP_TRIG, ptp_trig);
+		ext_write(0, phydev, PAGE4, PTP_CTL, val);
+		mutex_unlock(&clock->extreg_lock);
+		return;
+	}
+
+	sec = clkreq->perout.start.sec;
+	nsec = clkreq->perout.start.nsec;
+	period = clkreq->perout.period.sec * 1000000000UL;
+	period += clkreq->perout.period.nsec;
+
+	mutex_lock(&clock->extreg_lock);
+
+	ext_write(0, phydev, PAGE5, PTP_TRIG, ptp_trig);
+
+	/*load trigger*/
+	val |= TRIG_LOAD;
+	ext_write(0, phydev, PAGE4, PTP_CTL, val);
+	ext_write(0, phydev, PAGE4, PTP_TDR, nsec & 0xffff);   /* ns[15:0] */
+	ext_write(0, phydev, PAGE4, PTP_TDR, nsec >> 16);      /* ns[31:16] */
+	ext_write(0, phydev, PAGE4, PTP_TDR, sec & 0xffff);    /* sec[15:0] */
+	ext_write(0, phydev, PAGE4, PTP_TDR, sec >> 16);       /* sec[31:16] */
+	ext_write(0, phydev, PAGE4, PTP_TDR, period & 0xffff); /* ns[15:0] */
+	ext_write(0, phydev, PAGE4, PTP_TDR, period >> 16);    /* ns[31:16] */
+
+	/*enable trigger*/
+	val &= ~TRIG_LOAD;
+	val |= TRIG_EN;
+	ext_write(0, phydev, PAGE4, PTP_CTL, val);
+
+	mutex_unlock(&clock->extreg_lock);
+}
+
 /* ptp clock methods */
 
 static int ptp_dp83640_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
@@ -338,19 +406,30 @@ static int ptp_dp83640_enable(struct ptp_clock_info *ptp,
 	struct dp83640_clock *clock =
 		container_of(ptp, struct dp83640_clock, caps);
 	struct phy_device *phydev = clock->chosen->phydev;
-	u16 evnt;
+	int index;
+	u16 evnt, event_num, gpio_num;
 
 	switch (rq->type) {
 	case PTP_CLK_REQ_EXTTS:
-		if (rq->extts.index != 0)
+		index = rq->extts.index;
+		if (index < 0 || index >= N_EXT_TS)
 			return -EINVAL;
-		evnt = EVNT_WR | (EXT_EVENT & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
+		event_num = EXT_EVENT + index;
+		evnt = EVNT_WR | (event_num & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
 		if (on) {
-			evnt |= (EXT_GPIO & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
+			gpio_num = gpio_tab[EXTTS0_GPIO + index];
+			evnt |= (gpio_num & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
 			evnt |= EVNT_RISE;
 		}
 		ext_write(0, phydev, PAGE5, PTP_EVNT, evnt);
 		return 0;
+
+	case PTP_CLK_REQ_PEROUT:
+		if (rq->perout.index != 0)
+			return -EINVAL;
+		periodic_output(clock, rq, on);
+		return 0;
+
 	default:
 		break;
 	}
@@ -441,9 +520,10 @@ static void recalibrate(struct dp83640_clock *clock)
 	struct list_head *this;
 	struct dp83640_private *tmp;
 	struct phy_device *master = clock->chosen->phydev;
-	u16 cfg0, evnt, ptp_trig, trigger, val;
+	u16 cal_gpio, cfg0, evnt, ptp_trig, trigger, val;
 
 	trigger = CAL_TRIGGER;
+	cal_gpio = gpio_tab[CALIBRATE_GPIO];
 
 	mutex_lock(&clock->extreg_lock);
 
@@ -542,11 +622,17 @@ static void recalibrate(struct dp83640_clock *clock)
 
 /* time stamping methods */
 
+static inline u16 exts_chan_to_edata(int ch)
+{
+	return 1 << ((ch + EXT_EVENT) * 2);
+}
+
 static int decode_evnt(struct dp83640_private *dp83640,
 		       void *data, u16 ests)
 {
 	struct phy_txts *phy_txts;
 	struct ptp_clock_event event;
+	int i, parsed;
 	int words = (ests >> EVNT_TS_LEN_SHIFT) & EVNT_TS_LEN_MASK;
 	u16 ext_status = 0;
 
@@ -568,14 +654,25 @@ static int decode_evnt(struct dp83640_private *dp83640,
 		dp83640->edata.ns_lo = phy_txts->ns_lo;
 	}
 
+	if (ext_status) {
+		parsed = words + 2;
+	} else {
+		parsed = words + 1;
+		i = ((ests >> EVNT_NUM_SHIFT) & EVNT_NUM_MASK) - EXT_EVENT;
+		ext_status = exts_chan_to_edata(i);
+	}
+
 	event.type = PTP_CLOCK_EXTTS;
-	event.index = 0;
 	event.timestamp = phy2txts(&dp83640->edata);
 
-	ptp_clock_event(dp83640->clock->ptp_clock, &event);
+	for (i = 0; i < N_EXT_TS; i++) {
+		if (ext_status & exts_chan_to_edata(i)) {
+			event.index = i;
+			ptp_clock_event(dp83640->clock->ptp_clock, &event);
+		}
+	}
 
-	words = ext_status ? words + 2 : words + 1;
-	return words * sizeof(u16);
+	return parsed * sizeof(u16);
 }
 
 static void decode_rxts(struct dp83640_private *dp83640,
@@ -740,7 +837,7 @@ static void dp83640_clock_init(struct dp83640_clock *clock, struct mii_bus *bus)
 	clock->caps.max_adj	= 1953124;
 	clock->caps.n_alarm	= 0;
 	clock->caps.n_ext_ts	= N_EXT_TS;
-	clock->caps.n_per_out	= 0;
+	clock->caps.n_per_out	= 1;
 	clock->caps.pps		= 0;
 	clock->caps.adjfreq	= ptp_dp83640_adjfreq;
 	clock->caps.adjtime	= ptp_dp83640_adjtime;
-- 
1.7.2.5
