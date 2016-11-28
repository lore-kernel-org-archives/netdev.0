From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 3/6] net: ethernet: ti: cpts: add support of cpts HW_TS_PUSH
Date: Mon, 28 Nov 2016 17:04:25 -0600
Message-ID: <20161128230428.6872-4-grygorii.strashko@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:32044 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756037AbcK1XEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 18:04:39 -0500
In-Reply-To: <20161128230428.6872-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support of the CPTS HW_TS_PUSH events which are generated
by external low frequency time stamp channels on TI's OMAP CPSW and
Keystone 2 platforms. It supports up to 8 external time stamp channels for
HW_TS_PUSH input pins (the number of supported channel is different for
different SoCs and CPTS versions, check corresponding Data maual before
enabling it). Therefore, new DT property "cpts-ext-ts-inputs" is introduced
for specifying number of available external timestamp channels.

The PTP external timestamp (extts) infrastructure can be used for
HW_TS_PUSH timestamp controlling and reporting.

This also change overflow polling period when HW_TS_PUSH feature is
enabled - overflow check work will be scheduled more often (every
200ms) for proper HW_TS_PUSH events reporting.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt     |   4 +
 .../devicetree/bindings/net/keystone-netcp.txt     |   4 +
 drivers/net/ethernet/ti/cpts.c                     | 104 ++++++++++++++++++++-
 drivers/net/ethernet/ti/cpts.h                     |   6 ++
 4 files changed, 114 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index ebda7c9..86a2f61 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -38,6 +38,10 @@ Optional properties:
 			  Mult and shift will be calculated basing on CPTS
 			  rftclk frequency if both cpts_clock_shift and
 			  cpts_clock_mult properties are not provided.
+- cpts-ext-ts-inputs	: The number of external time stamp channels.
+			  The different CPTS versions might support up 8
+			  external time stamp channels.
+			  if absent - unsupported.
 
 Slave Properties:
 Required properties:
diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
index ec4a241..1c805319 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -123,6 +123,10 @@ Optional properties:
 
 		Defaults: clock_mult, clock_shift = calculated from
 		CPTS refclk
+	- cpts-ext-ts-inputs:
+		The number of external time stamp channels.
+		The different CPTS versions might support up 8
+		external time stamp channels. if absent - unsupported.
 
 NetCP interface properties: Interface specification for NetCP sub-modules.
 Required properties:
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 9c5b835..2f7641a 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -34,6 +34,11 @@
 #define cpts_read32(c, r)	readl_relaxed(&c->reg->r)
 #define cpts_write32(c, v, r)	writel_relaxed(v, &c->reg->r)
 
+static int cpts_event_port(struct cpts_event *event)
+{
+	return (event->high >> PORT_NUMBER_SHIFT) & PORT_NUMBER_MASK;
+}
+
 static int event_expired(struct cpts_event *event)
 {
 	return time_after(jiffies, event->tmo);
@@ -96,11 +101,15 @@ static int cpts_fifo_read(struct cpts *cpts, int match)
 		}
 
 		event = list_first_entry(&cpts->pool, struct cpts_event, list);
-		event->tmo = jiffies + 2;
+		event->tmo = jiffies +
+			     msecs_to_jiffies(CPTS_EVENT_RX_TX_TIMEOUT);
 		event->high = hi;
 		event->low = lo;
 		type = event_type(event);
 		switch (type) {
+		case CPTS_EV_HW:
+			event->tmo +=
+				msecs_to_jiffies(CPTS_EVENT_HWSTAMP_TIMEOUT);
 		case CPTS_EV_PUSH:
 		case CPTS_EV_RX:
 		case CPTS_EV_TX:
@@ -109,7 +118,6 @@ static int cpts_fifo_read(struct cpts *cpts, int match)
 			break;
 		case CPTS_EV_ROLL:
 		case CPTS_EV_HALF:
-		case CPTS_EV_HW:
 			break;
 		default:
 			pr_err("cpts: unknown event type\n");
@@ -218,9 +226,83 @@ static int cpts_ptp_settime(struct ptp_clock_info *ptp,
 	return 0;
 }
 
+static int cpts_report_ts_events(struct cpts *cpts)
+{
+	struct list_head *this, *next;
+	struct ptp_clock_event pevent;
+	struct cpts_event *event;
+	int reported = 0, ev;
+
+	list_for_each_safe(this, next, &cpts->events) {
+		event = list_entry(this, struct cpts_event, list);
+		ev = event_type(event);
+		if (ev == CPTS_EV_HW) {
+			list_del_init(&event->list);
+			list_add(&event->list, &cpts->pool);
+			/* report the event */
+			pevent.timestamp =
+				timecounter_cyc2time(&cpts->tc, event->low);
+			pevent.type = PTP_CLOCK_EXTTS;
+			pevent.index = cpts_event_port(event) - 1;
+			ptp_clock_event(cpts->clock, &pevent);
+			++reported;
+			continue;
+		}
+	}
+	return reported;
+}
+
+/* HW TS */
+static int cpts_extts_enable(struct cpts *cpts, u32 index, int on)
+{
+	unsigned long flags;
+	u32 v;
+
+	if (index >= cpts->info.n_ext_ts)
+		return -ENXIO;
+
+	if (((cpts->hw_ts_enable & BIT(index)) >> index) == on)
+		return 0;
+
+	spin_lock_irqsave(&cpts->lock, flags);
+
+	v = cpts_read32(cpts, control);
+	if (on) {
+		v |= BIT(8 + index);
+		cpts->hw_ts_enable |= BIT(index);
+	} else {
+		v &= ~BIT(8 + index);
+		cpts->hw_ts_enable &= ~BIT(index);
+	}
+	cpts_write32(cpts, v, control);
+
+	spin_unlock_irqrestore(&cpts->lock, flags);
+
+	if (cpts->hw_ts_enable)
+		/* poll for events faster - evry 200 ms */
+		cpts->ov_check_period =
+			msecs_to_jiffies(CPTS_EVENT_HWSTAMP_TIMEOUT);
+	else
+		cpts->ov_check_period = cpts->ov_check_period_slow;
+
+	mod_delayed_work(system_wq, &cpts->overflow_work,
+			 cpts->ov_check_period);
+
+	return 0;
+}
+
 static int cpts_ptp_enable(struct ptp_clock_info *ptp,
 			   struct ptp_clock_request *rq, int on)
 {
+	struct cpts *cpts = container_of(ptp, struct cpts, info);
+
+	switch (rq->type) {
+	case PTP_CLK_REQ_EXTTS:
+		return cpts_extts_enable(cpts, rq->extts.index, on);
+	default:
+		break;
+	}
+
 	return -EOPNOTSUPP;
 }
 
@@ -240,10 +322,16 @@ static struct ptp_clock_info cpts_info = {
 
 static void cpts_overflow_check(struct work_struct *work)
 {
-	struct timespec64 ts;
 	struct cpts *cpts = container_of(work, struct cpts, overflow_work.work);
+	struct timespec64 ts;
+	unsigned long flags;
 
-	cpts_ptp_gettime(&cpts->info, &ts);
+	spin_lock_irqsave(&cpts->lock, flags);
+	ts = ns_to_timespec64(timecounter_read(&cpts->tc));
+	spin_unlock_irqrestore(&cpts->lock, flags);
+
+	if (cpts->hw_ts_enable)
+		cpts_report_ts_events(cpts);
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
 	schedule_delayed_work(&cpts->overflow_work, cpts->ov_check_period);
 }
@@ -422,6 +510,8 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
 
 	/* Calc overflow check period (maxsec / 2) */
 	cpts->ov_check_period = (HZ * maxsec) / 2;
+	cpts->ov_check_period_slow = cpts->ov_check_period;
+
 	dev_info(cpts->dev, "cpts: overflow check period %lu (jiffies)\n",
 		 cpts->ov_check_period);
 
@@ -468,6 +558,9 @@ static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
 		cpts->rftclk_sel = prop & CPTS_RFTCLK_SEL_MASK;
 	}
 
+	if (!of_property_read_u32(node, "cpts-ext-ts-inputs", &prop))
+		cpts->ext_ts_inputs = prop;
+
 	return 0;
 
 of_error:
@@ -512,6 +605,9 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	cpts->cc.mask = CLOCKSOURCE_MASK(32);
 	cpts->info = cpts_info;
 
+	if (cpts->ext_ts_inputs)
+		cpts->info.n_ext_ts = cpts->ext_ts_inputs;
+
 	cpts_calc_mult_shift(cpts);
 
 	return cpts;
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index c934b61..ad80c95 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -102,6 +102,9 @@ enum {
 #define CPTS_FIFO_DEPTH 16
 #define CPTS_MAX_EVENTS 32
 
+#define CPTS_EVENT_RX_TX_TIMEOUT 20 /* ms */
+#define CPTS_EVENT_HWSTAMP_TIMEOUT 200 /* ms */
+
 struct cpts_event {
 	struct list_head list;
 	unsigned long tmo;
@@ -129,7 +132,10 @@ struct cpts {
 	struct list_head pool;
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
 	unsigned long ov_check_period;
+	unsigned long ov_check_period_slow;
 	u32 rftclk_sel;
+	u32 ext_ts_inputs;
+	u32 hw_ts_enable;
 	u32 caps;
 };
 
-- 
2.10.1
