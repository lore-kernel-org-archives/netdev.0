From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 5/6] drivers: net: ethernet: cpts: implement cpts hardware clock
Date: Wed, 17 Oct 2012 04:15:17 +0530
Message-ID: <1350427518-7230-6-git-send-email-mugunthanvnm@ti.com>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Richard Cochran <richardcochran@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:53363 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755609Ab2JPWpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 18:45:31 -0400
In-Reply-To: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement of hardware clock and network packet time stamping
using CPTS module.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/Kconfig  |   10 +
 drivers/net/ethernet/ti/Makefile |    2 +-
 drivers/net/ethernet/ti/cpts.c   |  399 ++++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/cpts.h   |  118 +++++++++++
 4 files changed, 528 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/ti/cpts.c
 create mode 100644 drivers/net/ethernet/ti/cpts.h

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index b26cbda..6db7e6c 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -60,6 +60,16 @@ config TI_CPSW
 	  To compile this driver as a module, choose M here: the module
 	  will be called cpsw.
 
+config TI_CPTS
+	boolean "TI Common Platform Time Sync (CPTS) Support"
+	depends on TI_CPSW && (PTP_1588_CLOCK=y)
+	---help---
+	  This driver supports the Common Platform Time Sync unit of
+	  the CPSW Ethernet Switch.
+
+	  The unit can time stamp PTP UDP/IPv4
+	  and Layer 2 packets, and the driver offers a PTP Hardware Clock.
+
 config TLAN
 	tristate "TI ThunderLAN support"
 	depends on (PCI || EISA)
diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
index 91bd8bb..c65148e 100644
--- a/drivers/net/ethernet/ti/Makefile
+++ b/drivers/net/ethernet/ti/Makefile
@@ -8,4 +8,4 @@ obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
 obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
 obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
 obj-$(CONFIG_TI_CPSW) += ti_cpsw.o
-ti_cpsw-y := cpsw_ale.o cpsw.o
+ti_cpsw-y := cpsw_ale.o cpsw.o cpts.o
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
new file mode 100644
index 0000000..dd2b37b
--- /dev/null
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -0,0 +1,399 @@
+/*
+ * Texas Instruments Common Platform Time Sync PTP Clock Driver
+ *
+ * Copyright (C) 2012 Texas Instruments
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+/*
+ * PTP 1588 clock using the CPTS
+ */
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/ptp_classify.h>
+#include <linux/ptp_clock_kernel.h>
+#include <plat/clock.h>
+#include <linux/clk.h>
+#include <linux/skbuff.h>
+
+#include "cpts.h"
+
+#ifdef CONFIG_TI_CPTS
+
+#define nanosec_to_cptscount(cpts, ns)	(div_u64((ns),			\
+					(cpts)->time_offs_correction))
+#define cptscount_to_nanosec(cpts, ns)	((ns) * (cpts)->time_offs_correction)
+
+static struct sock_filter ptp_filter[] = {
+	PTP_FILTER
+};
+
+void cpts_systime_write(struct cpts_priv *cpts, u64 ns)
+{
+	ns = nanosec_to_cptscount(cpts, ns);
+	writel((u32)(ns & 0xffffffff), &cpts->reg->ts_load_val);
+	writel(CPTS_TS_LOAD_CMD, &cpts->reg->ts_load_en);
+	cpts->tshi = (u32)(ns >> 32);
+}
+
+int cpts_systime_read(struct cpts_priv *cpts, u64 *ns)
+{
+	int ret = 0;
+	int i;
+
+	cpts->time_push = 0;
+	writel(CPTS_TS_PUSH_CMD, &cpts->reg->ts_push);
+	for (i = 0; i < CPTS_EVT_RETRY_COUNT; i++) {
+		cpts_event_fifo_read(cpts);
+		if (cpts->time_push)
+			break;
+	}
+	if (i >= CPTS_EVT_RETRY_COUNT) {
+		*ns = 0;
+		return -EBUSY;
+	}
+
+	*ns = cpts->time_push;
+	return ret;
+}
+
+static int cpts_evt_expired(struct cpts_evts *evt)
+{
+	return time_after(jiffies, evt->timeout);
+}
+
+static void cpts_rx_timestamp_pop(struct cpts_priv *cpts,
+			      struct sk_buff *skb, u32 evt_high)
+{
+	struct skb_shared_hwtstamps *shhwtstamps;
+	struct list_head *this, *next;
+	struct cpts_evts *evt;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cpts->lock, flags);
+	list_for_each_safe(this, next, &cpts->ts_list) {
+		evt = list_entry(this, struct cpts_evts, list);
+		if (evt_high == evt->event_high) {
+			shhwtstamps = skb_hwtstamps(skb);
+			memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+			shhwtstamps->hwtstamp = ns_to_ktime(evt->ts);
+			list_del_init(&evt->list);
+			list_add(&evt->list, &cpts->ts_pool);
+			break;
+		} else if (cpts_evt_expired(evt)) {
+			list_del_init(&evt->list);
+			list_add(&evt->list, &cpts->ts_pool);
+		}
+	}
+	spin_unlock_irqrestore(&cpts->lock, flags);
+}
+
+static void cpts_tx_timestamp_pop(struct cpts_priv *cpts,
+			      struct sk_buff *skb, u32 evt_high)
+{
+	struct skb_shared_hwtstamps shhwtstamps;
+	struct list_head *this, *next;
+	struct cpts_evts *evt;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cpts->lock, flags);
+	list_for_each_safe(this, next, &cpts->ts_list) {
+		evt = list_entry(this, struct cpts_evts, list);
+		if (evt_high == evt->event_high) {
+			memset(&shhwtstamps, 0,
+				sizeof(struct skb_shared_hwtstamps));
+			shhwtstamps.hwtstamp = ns_to_ktime(evt->ts);
+			skb_tstamp_tx(skb, &shhwtstamps);
+			list_del_init(&evt->list);
+			list_add(&evt->list, &cpts->ts_pool);
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&cpts->lock, flags);
+}
+
+/*
+ * PTP clock operations
+ */
+
+static int ptp_cpts_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	unsigned long freq, target_freq, current_freq;
+	int diff;
+	int neg_adj = 0;
+	u64 adj;
+	struct cpts_priv *cpts = container_of(ptp, struct cpts_priv,
+			caps);
+
+	if (IS_ERR(cpts->refclk)) {
+		/* No clock to adjust frequency */
+		return 0;
+	}
+	current_freq = cpts->refclk->recalc(
+			cpts->refclk);
+	freq = cpts->initial_freq;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+
+	adj = freq;
+	adj *= ppb;
+	diff = div_u64(adj, GHZ_COUNTS_PER_SEC);
+	target_freq = (neg_adj ? freq - diff : freq + diff);
+
+	clk_set_rate(cpts->refclk, target_freq);
+
+	return 0;
+}
+
+static int ptp_cpts_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	s64 now;
+	unsigned long flags;
+	struct cpts_priv *cpts = container_of(ptp,
+			struct cpts_priv, caps);
+
+	spin_lock_irqsave(&cpts->lock, flags);
+
+	cpts_systime_read(cpts, &now);
+	now += delta;
+	cpts_systime_write(cpts, now);
+
+	spin_unlock_irqrestore(&cpts->lock, flags);
+
+	return 0;
+}
+
+static int ptp_cpts_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	u64 ns;
+	unsigned long flags;
+	struct cpts_priv *cpts = container_of(ptp,
+			struct cpts_priv, caps);
+
+	spin_lock_irqsave(&cpts->lock, flags);
+
+	cpts_systime_read(cpts, &ns);
+
+	spin_unlock_irqrestore(&cpts->lock, flags);
+
+	*ts = ns_to_timespec(ns);
+	return 0;
+}
+
+static int ptp_cpts_settime(struct ptp_clock_info *ptp,
+			   const struct timespec *ts)
+{
+	u64 ns;
+	unsigned long flags;
+	struct cpts_priv *cpts = container_of(ptp,
+			struct cpts_priv, caps);
+
+	ns = timespec_to_ns(ts);
+
+	spin_lock_irqsave(&cpts->lock, flags);
+
+	cpts_systime_write(cpts, ns);
+
+	spin_unlock_irqrestore(&cpts->lock, flags);
+
+	return 0;
+}
+
+static int ptp_cpts_enable(struct ptp_clock_info *ptp,
+			  struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+static struct ptp_clock_info ptp_cpts_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "CTPS timer",
+	.n_ext_ts	= EXT_TS_INSTANCE_CNT,
+	.pps		= 0,
+	.adjfreq	= ptp_cpts_adjfreq,
+	.adjtime	= ptp_cpts_adjtime,
+	.gettime	= ptp_cpts_gettime,
+	.settime	= ptp_cpts_settime,
+	.enable		= ptp_cpts_enable,
+};
+
+void cpts_event_fifo_read(struct cpts_priv *cpts)
+{
+	while (readl(&cpts->reg->intstat_raw) & 0x01) {
+		u64 ts;
+		u32 event_high;
+		u32 event_tslo;
+		u32 evt_type;
+		struct cpts_evts *evt;
+
+		event_high = readl(&cpts->reg->event_high);
+		event_tslo = readl(&cpts->reg->event_low);
+		writel(CPTS_EVT_POP, &cpts->reg->event_pop);
+
+		if (cpts->first_half && event_tslo & CPTS_CNT_FIRST_HALF)
+			ts = (u64)(cpts->tshi - 1); /* this is misaligned ts */
+		else
+			ts = (u64)(cpts->tshi);
+		ts = (ts << 32) | event_tslo;
+		ts = cptscount_to_nanosec(cpts, ts);
+
+		evt_type = event_high & CPTS_EVT_MASK;
+
+		switch (evt_type) {
+		case CPTS_TS_PUSH:
+			/*Push TS to Read */
+			cpts->time_push = ts;
+			break;
+
+		case CPTS_TS_ROLLOVER:
+			/* Roll over */
+			cpts->tshi++;
+			cpts->first_half = true;
+			break;
+
+		case CPTS_TS_HROLLOVER:
+			/* Half Roll Over */
+			cpts->first_half = false;
+			break;
+
+		case CPTS_TS_HW_PUSH:
+			/* HW TS Push */
+			pr_err("CPTS hwts are not utilized\n");
+			/* TBD */
+			break;
+
+		case CPTS_TS_ETH_RX:
+			/* Ethernet Rx Ts */
+			if (!cpts->enable_rxts)
+				break;
+			evt = list_first_entry(&cpts->ts_pool,
+					       struct cpts_evts, list);
+			list_del_init(&evt->list);
+			evt->event_high = event_high & CPTS_EVT_TS_MASK;
+			evt->ts = ts;
+			list_add_tail(&evt->list, &cpts->ts_list);
+			break;
+
+		case CPTS_TS_ETH_TX:
+			/* Ethernet Tx Ts */
+			if (!cpts->enable_txts)
+				break;
+			evt = list_first_entry(&cpts->ts_pool,
+					       struct cpts_evts, list);
+			list_del_init(&evt->list);
+			evt->event_high = event_high & CPTS_EVT_TS_MASK;
+			evt->ts = ts;
+			list_add_tail(&evt->list, &cpts->ts_list);
+			break;
+		}
+	}
+}
+
+void cpts_rx_timestamp(struct cpts_priv *cpts, struct sk_buff *skb)
+{
+	u32 evt_high = 0;
+	u16 seq_id = 0;
+	u8 evt_type = 0;
+	u32 ptp_class = 0;
+
+	if (!cpts->enable_rxts)
+		return;
+
+	ptp_class = sk_run_filter(skb, ptp_filter);
+	if (ptp_class == PTP_CLASS_NONE)
+		return;
+
+	ptp_get_skb_event(skb, ptp_class, &seq_id, &evt_type);
+	evt_high = seq_id | (evt_type << 16) | CPTS_TS_ETH_RX;
+	cpts_rx_timestamp_pop(cpts, skb, evt_high);
+}
+
+void cpts_tx_timestamp(struct cpts_priv *cpts, struct sk_buff *skb)
+{
+	u32 evt_high = 0;
+	u16 seq_id = 0;
+	u8 evt_type = 0;
+	u32 ptp_class = 0;
+
+	if (!cpts->enable_txts)
+		return;
+
+	ptp_class = sk_run_filter(skb, ptp_filter);
+	if (ptp_class == PTP_CLASS_NONE)
+		return;
+
+	ptp_get_skb_event(skb, ptp_class, &seq_id, &evt_type);
+	evt_high = seq_id | (evt_type << 16) | CPTS_TS_ETH_TX;
+	cpts_tx_timestamp_pop(cpts, skb, evt_high);
+}
+
+void cpts_unregister(struct cpts_priv *cpts)
+{
+	if (!IS_ERR(cpts->refclk)) {
+		clk_disable(cpts->refclk);
+		clk_put(cpts->refclk);
+	}
+	if (!IS_ERR(cpts->ptp_clock))
+		ptp_clock_unregister(cpts->ptp_clock);
+}
+
+int cpts_register(struct device *dev, struct cpts_priv *cpts)
+{
+	int i;
+	u32 reg;
+
+	reg = readl(&cpts->reg->id_ver);
+	if (reg != CPTS_VERSION) {
+		pr_err("cpts: Cannot find CPTS\n");
+		return -ENODEV;
+	}
+
+	if (ptp_filter_init(ptp_filter, ARRAY_SIZE(ptp_filter))) {
+		pr_err("cpts: bad ptp filter\n");
+		return -EINVAL;
+	}
+
+	cpts->refclk = clk_get(NULL, CPTS_REF_CLOCK_NAME);
+	if (IS_ERR(cpts->refclk)) {
+		pr_err("cpts: Could not get %s clk\n", CPTS_REF_CLOCK_NAME);
+		return PTR_ERR(cpts->ptp_clock);
+	}
+	clk_enable(cpts->refclk);
+	spin_lock_init(&cpts->lock);
+
+	INIT_LIST_HEAD(&cpts->ts_list);
+	INIT_LIST_HEAD(&cpts->ts_pool);
+	for (i = 0; i < CPTS_TS_POOL_SIZE; i++)
+		list_add(&cpts->ts_pool_data[i].list, &cpts->ts_pool);
+
+	cpts->initial_freq = cpts->refclk->recalc(cpts->refclk);
+	cpts->time_offs_correction = GHZ_COUNTS_PER_SEC/cpts->initial_freq;
+	cpts->caps = ptp_cpts_caps;
+
+	cpts->ptp_clock = ptp_clock_register(&cpts->caps, dev);
+	if (IS_ERR(cpts->ptp_clock)) {
+		clk_disable(cpts->refclk);
+		clk_put(cpts->refclk);
+		return PTR_ERR(cpts->ptp_clock);
+	}
+
+	pr_info("Found CPTS and initializing...\n");
+	/* Enable CPTS */
+	writel(CPTS_CTRL_EN, &cpts->reg->control);
+	/* Enable CPTS Interrupt */
+	writel(CPTS_INTR_EN, &cpts->reg->int_enable);
+
+	return 0;
+}
+
+#endif
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
new file mode 100644
index 0000000..bc48dc4
--- /dev/null
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -0,0 +1,118 @@
+/*
+ * Texas Instruments Common Platform Time Sync Header
+ *
+ * Copyright (C) 2012 Texas Instruments
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __TI_CPTS_H__
+#define __TI_CPTS_H__
+
+#include <linux/ptp_clock_kernel.h>
+#include <linux/device.h>
+#include <linux/skbuff.h>
+
+#define CPTS_VERSION			0x4e8a0101
+#define CPTS_CTRL_EN			BIT(0)
+#define CPTS_INTR_EN			BIT(0)
+#define CPTS_EVT_POP			BIT(0)
+#define CPTS_TS_PUSH_CMD		BIT(0)
+#define CPTS_TS_LOAD_CMD		BIT(0)
+#define CPTS_TS_PUSH			0x0
+#define CPTS_TS_ROLLOVER		(0x1 << 20)
+#define CPTS_TS_HROLLOVER		(0x2 << 20)
+#define CPTS_TS_HW_PUSH			(0x3 << 20)
+#define CPTS_TS_ETH_RX			(0x4 << 20)
+#define CPTS_TS_ETH_TX			(0x5 << 20)
+#define CPSW_801_1Q_LTYPE		0x88f7
+#define CPSW_SEQ_ID_OFS			0x1e
+#define CPTS_CNT_FIRST_HALF		BIT(31)
+#define CPTS_EVT_MASK			0xf00000
+#define CPTS_EVT_RETRY_COUNT		20
+#define CPTS_INT_MASK			BIT(0)
+#define CPTS_EVT_TS_MASK		0xffffff
+#define GHZ_COUNTS_PER_SEC		1000000000ULL
+
+#define CPTS_TS_POOL_SIZE		32
+
+#define CPTS_READ_TS_MAX_TRY		20
+#define CPTS_REF_CLOCK_NAME		"cpsw_cpts_rft_clk"
+#define EXT_TS_INSTANCE_CNT		4
+/*
+ * CPTS Regs
+ */
+struct cpts_regs {
+	u32	id_ver;
+	u32	control;
+	u32	rftclk_sel;
+	u32	ts_push;
+	u32	ts_load_val;
+	u32	ts_load_en;
+	u32	mem_allign1[2];
+	u32	intstat_raw;
+	u32	intstat_masked;
+	u32	int_enable;
+	u32	mem_allign2;
+	u32	event_pop;
+	u32	event_low;
+	u32	event_high;
+};
+
+/*
+ * CPTS Events
+ */
+struct cpts_evts {
+	struct list_head	list;
+	u32			event_high;
+	u64			ts;
+	unsigned long		timeout;
+};
+
+/*
+ * Time Handle
+ */
+struct cpts_priv {
+	spinlock_t			lock;
+	struct ptp_clock		*ptp_clock;
+	struct ptp_clock_info		caps;
+	struct cpts_regs __iomem	*reg;
+	struct list_head		ts_list;
+	struct list_head		ts_pool;
+	struct cpts_evts		ts_pool_data[CPTS_TS_POOL_SIZE];
+	struct clk			*refclk;
+	u64				time_push;
+	bool				enable_txts;
+	bool				enable_rxts;
+	u32				tshi;
+	bool				first_half;
+	u32				initial_freq;
+	u32				time_offs_correction;
+};
+
+#ifdef CONFIG_TI_CPTS
+
+void cpts_rx_timestamp(struct cpts_priv *cpts, struct sk_buff *skb);
+void cpts_tx_timestamp(struct cpts_priv *cpts, struct sk_buff *skb);
+int cpts_register(struct device *dev, struct cpts_priv *cpts);
+void cpts_unregister(struct cpts_priv *cpts);
+void cpts_event_fifo_read(struct cpts_priv *cpts);
+
+#else
+
+#define cpts_rx_timestamp(cpts, skb)
+#define cpts_tx_timestamp(cpts, skb)
+#define cpts_register(dev, cpts) (-ENODEV)
+#define cpts_unregister(cpts)
+#define cpts_event_fifo_read(cpts)
+
+#endif
+
+#endif
-- 
1.7.0.4
