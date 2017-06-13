From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [RFC/RFT PATCH 3/4] net: ethernet: ti: cpts: add support of cpts HW_TS_PUSH
Date: Tue, 13 Jun 2017 18:16:22 -0500
Message-ID: <20170613231623.28353-4-grygorii.strashko@ti.com>
References: <20170613231623.28353-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613231623.28353-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support of the CPTS HW_TS_PUSH events which are generated
by external low frequency time stamp channels on TI's OMAP CPSW[ and
Keystone 2 platforms]. It supports up to 8 external time stamp channels for
HW_TS_PUSH input pins (the number of supported channel is different for
different SoCs and CPTS versions, check corresponding Data maual before
enabling it). Therefore, new DT property "cpts-ext-ts-inputs" is introduced
for specifying number of available external timestamp channels.

The PTP external timestamp (extts) infrastructure can be used for
HW_TS_PUSH timestamp controlling and reporting.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 Documentation/devicetree/bindings/net/cpsw.txt     |  4 ++
 .../devicetree/bindings/net/keystone-netcp.txt     |  6 +++
 drivers/net/ethernet/ti/cpts.c                     | 57 +++++++++++++++++++++-
 drivers/net/ethernet/ti/cpts.h                     |  4 ++
 4 files changed, 70 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index 7cc15c9..7b2d14d 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -37,6 +37,10 @@ Optional properties:
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
index 04ba1dc..1460da5 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -113,6 +113,12 @@ Optional properties:
 				will only initialize these ports and attach PHY
 				driver to them if needed.
 
+ Properties related to cpts configurations.
+	- cpts-ext-ts-inputs:
+		The number of external time stamp channels.
+		The different CPTS versions might support up 8
+		external time stamp channels. if absent - unsupported.
+
 NetCP interface properties: Interface specification for NetCP sub-modules.
 Required properties:
 - rx-channel:	the navigator packet dma channel name for rx.
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 25191e9..e6f1383 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -39,6 +39,11 @@ struct cpts_skb_cb_data {
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
@@ -181,9 +186,46 @@ static int cpts_ptp_settime(struct ptp_clock_info *ptp,
 	return 0;
 }
 
+/* HW TS */
+static int cpts_extts_enable(struct cpts *cpts, u32 index, int on)
+{
+	u32 v;
+
+	if (index >= cpts->info.n_ext_ts)
+		return -ENXIO;
+
+	if (((cpts->hw_ts_enable & BIT(index)) >> index) == on)
+		return 0;
+
+	mutex_lock(&cpts->ptp_clk_mutex);
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
+	mutex_unlock(&cpts->ptp_clk_mutex);
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
 
@@ -203,12 +245,12 @@ static struct ptp_clock_info cpts_info = {
 
 static void cpts_overflow_check(struct work_struct *work)
 {
-	struct timespec64 ts;
 	struct cpts *cpts = container_of(work, struct cpts, overflow_work.work);
 	struct timespec64 ts;
 	unsigned long flags;
 
 	cpts_ptp_gettime(&cpts->info, &ts);
+
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
 	queue_delayed_work(cpts->workwq, &cpts->overflow_work,
 			   cpts->ov_check_period);
@@ -222,6 +264,7 @@ static void cpts_overflow_check(struct work_struct *work)
 
 static irqreturn_t cpts_misc_interrupt(int irq, void *dev_id)
 {
+	struct ptp_clock_event pevent;
 	struct cpts *cpts = dev_id;
 	unsigned long flags;
 	int i, type = -1;
@@ -264,7 +307,12 @@ static irqreturn_t cpts_misc_interrupt(int irq, void *dev_id)
 			break;
 		case CPTS_EV_ROLL:
 		case CPTS_EV_HALF:
+			break;
 		case CPTS_EV_HW:
+			pevent.timestamp = timecounter_cyc2time(&cpts->tc, event->low);
+			pevent.type = PTP_CLOCK_EXTTS;
+			pevent.index = cpts_event_port(event) - 1;
+			ptp_clock_event(cpts->clock, &pevent);
 			break;
 		default:
 			dev_err(cpts->dev, "unknown event type\n");
@@ -573,6 +621,7 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
 
 	/* Calc overflow check period (maxsec / 2) */
 	cpts->ov_check_period = (HZ * maxsec) / 2;
+
 	dev_info(cpts->dev, "cpts: overflow check period %lu (jiffies)\n",
 		 cpts->ov_check_period);
 
@@ -605,6 +654,9 @@ static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
 	    (!cpts->cc.mult && cpts->cc.shift))
 		goto of_error;
 
+	if (!of_property_read_u32(node, "cpts-ext-ts-inputs", &prop))
+		cpts->ext_ts_inputs = prop;
+
 	return 0;
 
 of_error:
@@ -652,6 +704,9 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	cpts->cc.mask = CLOCKSOURCE_MASK(32);
 	cpts->info = cpts_info;
 
+	if (cpts->ext_ts_inputs)
+		cpts->info.n_ext_ts = cpts->ext_ts_inputs;
+
 	cpts_calc_mult_shift(cpts);
 	/* save cc.mult original value as it can be modified
 	 * by cpts_ptp_adjfreq().
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 28a7cdb..4257c87 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -100,6 +100,8 @@ enum {
 #define CPTS_FIFO_DEPTH 16
 #define CPTS_MAX_EVENTS 32
 
+#define CPTS_EVENT_RX_TX_TIMEOUT 20 /* ms */
+
 struct cpts_event {
 	struct list_head list;
 	unsigned long tmo;
@@ -140,6 +142,8 @@ struct cpts {
 	struct work_struct ts_work;
 	struct sk_buff_head txq;
 	struct sk_buff_head rxq;
+	u32 ext_ts_inputs;
+	u32 hw_ts_enable;
 };
 
 int cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-- 
2.10.1
