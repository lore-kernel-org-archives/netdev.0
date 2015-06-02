From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v5 2/2] Renesas Ethernet AVB PTP clock driver
Date: Tue, 02 Jun 2015 23:44:50 +0300
Message-ID: <1586518.8QGCM8ZFXK@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, masaru.nagai.vx@renesas.com
To: netdev@vger.kernel.org, richardcochran@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ethernet AVB device includes the gPTP  timer, so we can implement a PTP clock
driver.  We're doing that in a separate file, with  the main Ethernet driver
calling the PTP driver's [de]initialization and interrupt handler functions.
Unfortunately, the clock seems tightly coupled with the AVB-DMAC, so when that
one leaves the operation mode, we have to unregister the PTP clock... :-(

Based on the original patches by Masaru Nagai.

Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against David Miller's 'net-next.git' repo.

Changes in version 5:
- resolved rejects, refreshed the patch.

Changes in version 4:
- new patch, split from the main Ethernet driver patch.

 drivers/net/ethernet/renesas/Makefile   |    2 
 drivers/net/ethernet/renesas/ravb.c     |   33 ++
 drivers/net/ethernet/renesas/ravb.h     |   26 ++
 drivers/net/ethernet/renesas/ravb_ptp.c |  357 ++++++++++++++++++++++++++++++++
 4 files changed, 412 insertions(+), 6 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/Makefile
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/Makefile
+++ net-next/drivers/net/ethernet/renesas/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_SH_ETH) += sh_eth.o
-obj-$(CONFIG_RAVB) += ravb.o
+obj-$(CONFIG_RAVB) += ravb.o ravb_ptp.o
Index: net-next/drivers/net/ethernet/renesas/ravb.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb.c
+++ net-next/drivers/net/ethernet/renesas/ravb.c
@@ -28,7 +28,6 @@
 #include <linux/of_irq.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
-#include <linux/platform_device.h>
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
@@ -41,8 +40,7 @@
 		 NETIF_MSG_RX_ERR | \
 		 NETIF_MSG_TX_ERR)
 
-static int ravb_wait(struct net_device *ndev, enum ravb_reg reg, u32 mask,
-		     u32 value)
+int ravb_wait(struct net_device *ndev, enum ravb_reg reg, u32 mask, u32 value)
 {
 	int i;
 
@@ -785,6 +783,9 @@ static irqreturn_t ravb_interrupt(int ir
 		result = IRQ_HANDLED;
 	}
 
+	if (iss & ISS_CGIS)
+		result = ravb_ptp_interrupt(ndev);
+
 	mmiowb();
 	spin_unlock(&priv->lock);
 	return result;
@@ -1124,6 +1125,8 @@ static int ravb_set_ringparam(struct net
 
 	if (netif_running(ndev)) {
 		netif_device_detach(ndev);
+		/* Stop PTP Clock driver */
+		ravb_ptp_stop(ndev);
 		/* Wait for DMA stopping */
 		error = ravb_stop_dma(ndev);
 		if (error) {
@@ -1153,6 +1156,9 @@ static int ravb_set_ringparam(struct net
 
 		ravb_emac_init(ndev);
 
+		/* Initialise PTP Clock driver */
+		ravb_ptp_init(ndev, priv->pdev);
+
 		netif_device_attach(ndev);
 	}
 
@@ -1162,6 +1168,8 @@ static int ravb_set_ringparam(struct net
 static int ravb_get_ts_info(struct net_device *ndev,
 			    struct ethtool_ts_info *info)
 {
+	struct ravb_private *priv = netdev_priv(ndev);
+
 	info->so_timestamping =
 		SOF_TIMESTAMPING_TX_SOFTWARE |
 		SOF_TIMESTAMPING_RX_SOFTWARE |
@@ -1174,7 +1182,7 @@ static int ravb_get_ts_info(struct net_d
 		(1 << HWTSTAMP_FILTER_NONE) |
 		(1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
 		(1 << HWTSTAMP_FILTER_ALL);
-	info->phc_index = -1;
+	info->phc_index = ptp_clock_index(priv->ptp.clock);
 
 	return 0;
 }
@@ -1215,15 +1223,21 @@ static int ravb_open(struct net_device *
 		goto out_free_irq;
 	ravb_emac_init(ndev);
 
+	/* Initialise PTP Clock driver */
+	ravb_ptp_init(ndev, priv->pdev);
+
 	netif_tx_start_all_queues(ndev);
 
 	/* PHY control start */
 	error = ravb_phy_start(ndev);
 	if (error)
-		goto out_free_irq;
+		goto out_ptp_stop;
 
 	return 0;
 
+out_ptp_stop:
+	/* Stop PTP Clock driver */
+	ravb_ptp_stop(ndev);
 out_free_irq:
 	free_irq(ndev->irq, ndev);
 out_napi_off:
@@ -1254,6 +1268,9 @@ static void ravb_tx_timeout_work(struct
 
 	netif_tx_stop_all_queues(ndev);
 
+	/* Stop PTP Clock driver */
+	ravb_ptp_stop(ndev);
+
 	/* Wait for DMA stopping */
 	ravb_stop_dma(ndev);
 
@@ -1264,6 +1281,9 @@ static void ravb_tx_timeout_work(struct
 	ravb_dmac_init(ndev);
 	ravb_emac_init(ndev);
 
+	/* Initialise PTP Clock driver */
+	ravb_ptp_init(ndev, priv->pdev);
+
 	netif_tx_start_all_queues(ndev);
 }
 
@@ -1428,6 +1448,9 @@ static int ravb_close(struct net_device
 	ravb_write(ndev, 0, RIC2);
 	ravb_write(ndev, 0, TIC);
 
+	/* Stop PTP Clock driver */
+	ravb_ptp_stop(ndev);
+
 	/* Set the config mode to stop the AVB-DMAC's processes */
 	if (ravb_stop_dma(ndev) < 0)
 		netdev_err(ndev,
Index: net-next/drivers/net/ethernet/renesas/ravb.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb.h
+++ net-next/drivers/net/ethernet/renesas/ravb.h
@@ -20,6 +20,8 @@
 #include <linux/mdio-bitbang.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/ptp_clock_kernel.h>
 
 #define BE_TX_RING_SIZE	64	/* TX ring size for Best Effort */
 #define BE_RX_RING_SIZE	1024	/* RX ring size for Best Effort */
@@ -744,6 +746,23 @@ struct ravb_tstamp_skb {
 	u16 tag;
 };
 
+struct ravb_ptp_perout {
+	u32 target;
+	u32 period;
+};
+
+#define N_EXT_TS	1
+#define N_PER_OUT	1
+
+struct ravb_ptp {
+	struct ptp_clock *clock;
+	struct ptp_clock_info info;
+	u32 default_addend;
+	u32 current_addend;
+	int extts[N_EXT_TS];
+	struct ravb_ptp_perout perout[N_PER_OUT];
+};
+
 struct ravb_private {
 	struct net_device *ndev;
 	struct platform_device *pdev;
@@ -768,6 +787,7 @@ struct ravb_private {
 	u32 tstamp_rx_ctrl;
 	struct list_head ts_skb_list;
 	u32 ts_skb_tag;
+	struct ravb_ptp ptp;
 	spinlock_t lock;		/* Register access lock */
 	u32 cur_rx[NUM_RX_QUEUE];	/* Consumer ring indices */
 	u32 dirty_rx[NUM_RX_QUEUE];	/* Producer ring indices */
@@ -803,4 +823,10 @@ static inline void ravb_write(struct net
 	iowrite32(data, priv->addr + reg);
 }
 
+int ravb_wait(struct net_device *ndev, enum ravb_reg reg, u32 mask, u32 value);
+
+irqreturn_t ravb_ptp_interrupt(struct net_device *ndev);
+void ravb_ptp_init(struct net_device *ndev, struct platform_device *pdev);
+void ravb_ptp_stop(struct net_device *ndev);
+
 #endif	/* #ifndef __RAVB_H__ */
Index: net-next/drivers/net/ethernet/renesas/ravb_ptp.c
===================================================================
--- /dev/null
+++ net-next/drivers/net/ethernet/renesas/ravb_ptp.c
@@ -0,0 +1,357 @@
+/* PTP 1588 clock using the Renesas Ethernet AVB
+ *
+ * Copyright (C) 2013-2015 Renesas Electronics Corporation
+ * Copyright (C) 2015 Renesas Solutions Corp.
+ * Copyright (C) 2015 Cogent Embedded, Inc. <source@cogentembedded.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ */
+
+#include "ravb.h"
+
+static int ravb_ptp_tcr_request(struct ravb_private *priv, u32 request)
+{
+	struct net_device *ndev = priv->ndev;
+	int error;
+
+	error = ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);
+	if (error)
+		return error;
+
+	ravb_write(ndev, ravb_read(ndev, GCCR) | request, GCCR);
+	return ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);
+}
+
+/* Caller must hold the lock */
+static int ravb_ptp_time_read(struct ravb_private *priv, struct timespec64 *ts)
+{
+	struct net_device *ndev = priv->ndev;
+	int error;
+
+	error = ravb_ptp_tcr_request(priv, GCCR_TCR_CAPTURE);
+	if (error)
+		return error;
+
+	ts->tv_nsec = ravb_read(ndev, GCT0);
+	ts->tv_sec  = ravb_read(ndev, GCT1) |
+		((s64)ravb_read(ndev, GCT2) << 32);
+
+	return 0;
+}
+
+/* Caller must hold the lock */
+static int ravb_ptp_time_write(struct ravb_private *priv,
+				const struct timespec64 *ts)
+{
+	struct net_device *ndev = priv->ndev;
+	int error;
+	u32 gccr;
+
+	error = ravb_ptp_tcr_request(priv, GCCR_TCR_RESET);
+	if (error)
+		return error;
+
+	gccr = ravb_read(ndev, GCCR);
+	if (gccr & GCCR_LTO)
+		return -EBUSY;
+	ravb_write(ndev, ts->tv_nsec, GTO0);
+	ravb_write(ndev, ts->tv_sec,  GTO1);
+	ravb_write(ndev, (ts->tv_sec >> 32) & 0xffff, GTO2);
+	ravb_write(ndev, gccr | GCCR_LTO, GCCR);
+
+	return 0;
+}
+
+/* Caller must hold the lock */
+static int ravb_ptp_update_compare(struct ravb_private *priv, u32 ns)
+{
+	struct net_device *ndev = priv->ndev;
+	/* When the comparison value (GPTC.PTCV) is in range of
+	 * [x-1 to x+1] (x is the configured increment value in
+	 * GTI.TIV), it may happen that a comparison match is
+	 * not detected when the timer wraps around.
+	 */
+	u32 gti_ns_plus_1 = (priv->ptp.current_addend >> 20) + 1;
+	u32 gccr;
+
+	if (ns < gti_ns_plus_1)
+		ns = gti_ns_plus_1;
+	else if (ns > 0 - gti_ns_plus_1)
+		ns = 0 - gti_ns_plus_1;
+
+	gccr = ravb_read(ndev, GCCR);
+	if (gccr & GCCR_LPTC)
+		return -EBUSY;
+	ravb_write(ndev, ns, GPTC);
+	ravb_write(ndev, gccr | GCCR_LPTC, GCCR);
+
+	return 0;
+}
+
+/* PTP clock operations */
+static int ravb_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	struct net_device *ndev = priv->ndev;
+	unsigned long flags;
+	u32 diff, addend;
+	bool neg_adj = false;
+	u32 gccr;
+
+	if (ppb < 0) {
+		neg_adj = true;
+		ppb = -ppb;
+	}
+	addend = priv->ptp.default_addend;
+	diff = div_u64((u64)addend * ppb, NSEC_PER_SEC);
+
+	addend = neg_adj ? addend - diff : addend + diff;
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	priv->ptp.current_addend = addend;
+
+	gccr = ravb_read(ndev, GCCR);
+	if (gccr & GCCR_LTI)
+		return -EBUSY;
+	ravb_write(ndev, addend & GTI_TIV, GTI);
+	ravb_write(ndev, gccr | GCCR_LTI, GCCR);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
+
+static int ravb_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	struct timespec64 ts;
+	unsigned long flags;
+	int error;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	error = ravb_ptp_time_read(priv, &ts);
+	if (!error) {
+		u64 now = ktime_to_ns(timespec64_to_ktime(ts));
+
+		ts = ns_to_timespec64(now + delta);
+		error = ravb_ptp_time_write(priv, &ts);
+	}
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return error;
+}
+
+static int ravb_ptp_gettime64(struct ptp_clock_info *ptp, struct timespec64 *ts)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	unsigned long flags;
+	int error;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	error = ravb_ptp_time_read(priv, ts);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return error;
+}
+
+static int ravb_ptp_settime64(struct ptp_clock_info *ptp,
+			      const struct timespec64 *ts)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	unsigned long flags;
+	int error;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	error = ravb_ptp_time_write(priv, ts);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return error;
+}
+
+static int ravb_ptp_extts(struct ptp_clock_info *ptp,
+			  struct ptp_extts_request *req, int on)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	struct net_device *ndev = priv->ndev;
+	unsigned long flags;
+	u32 gic;
+
+	if (req->index)
+		return -EINVAL;
+
+	if (priv->ptp.extts[req->index] == on)
+		return 0;
+	priv->ptp.extts[req->index] = on;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	gic = ravb_read(ndev, GIC);
+	if (on)
+		gic |= GIC_PTCE;
+	else
+		gic &= ~GIC_PTCE;
+	ravb_write(ndev, gic, GIC);
+	mmiowb();
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
+
+static int ravb_ptp_perout(struct ptp_clock_info *ptp,
+			   struct ptp_perout_request *req, int on)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	struct net_device *ndev = priv->ndev;
+	struct ravb_ptp_perout *perout;
+	unsigned long flags;
+	int error = 0;
+	u32 gic;
+
+	if (req->index)
+		return -EINVAL;
+
+	if (on) {
+		u64 start_ns;
+		u64 period_ns;
+
+		start_ns = req->start.sec * NSEC_PER_SEC + req->start.nsec;
+		period_ns = req->period.sec * NSEC_PER_SEC + req->period.nsec;
+
+		if (start_ns > U32_MAX) {
+			netdev_warn(ndev,
+				    "ptp: start value (nsec) is over limit. Maximum size of start is only 32 bits\n");
+			return -ERANGE;
+		}
+
+		if (period_ns > U32_MAX) {
+			netdev_warn(ndev,
+				    "ptp: period value (nsec) is over limit. Maximum size of period is only 32 bits\n");
+			return -ERANGE;
+		}
+
+		spin_lock_irqsave(&priv->lock, flags);
+
+		perout = &priv->ptp.perout[req->index];
+		perout->target = (u32)start_ns;
+		perout->period = (u32)period_ns;
+		error = ravb_ptp_update_compare(priv, (u32)start_ns);
+		if (!error) {
+			/* Unmask interrupt */
+			gic = ravb_read(ndev, GIC);
+			gic |= GIC_PTME;
+			ravb_write(ndev, gic, GIC);
+		}
+	} else	{
+		spin_lock_irqsave(&priv->lock, flags);
+
+		perout = &priv->ptp.perout[req->index];
+		perout->period = 0;
+
+		/* Mask interrupt */
+		gic = ravb_read(ndev, GIC);
+		gic &= ~GIC_PTME;
+		ravb_write(ndev, gic, GIC);
+	}
+	mmiowb();
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return error;
+}
+
+static int ravb_ptp_enable(struct ptp_clock_info *ptp,
+			   struct ptp_clock_request *req, int on)
+{
+	switch (req->type) {
+	case PTP_CLK_REQ_EXTTS:
+		return ravb_ptp_extts(ptp, &req->extts, on);
+	case PTP_CLK_REQ_PEROUT:
+		return ravb_ptp_perout(ptp, &req->perout, on);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static const struct ptp_clock_info ravb_ptp_info = {
+	.owner		= THIS_MODULE,
+	.name		= "ravb clock",
+	.max_adj	= 50000000,
+	.n_ext_ts	= N_EXT_TS,
+	.n_per_out	= N_PER_OUT,
+	.adjfreq	= ravb_ptp_adjfreq,
+	.adjtime	= ravb_ptp_adjtime,
+	.gettime64	= ravb_ptp_gettime64,
+	.settime64	= ravb_ptp_settime64,
+	.enable		= ravb_ptp_enable,
+};
+
+/* Caller must hold the lock */
+irqreturn_t ravb_ptp_interrupt(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	u32 gis = ravb_read(ndev, GIS);
+
+	gis &= ravb_read(ndev, GIC);
+	if (gis & GIS_PTCF) {
+		struct ptp_clock_event event;
+
+		event.type = PTP_CLOCK_EXTTS;
+		event.index = 0;
+		event.timestamp = ravb_read(ndev, GCPT);
+		ptp_clock_event(priv->ptp.clock, &event);
+	}
+	if (gis & GIS_PTMF) {
+		struct ravb_ptp_perout *perout = priv->ptp.perout;
+
+		if (perout->period) {
+			perout->target += perout->period;
+			ravb_ptp_update_compare(priv, perout->target);
+		}
+	}
+
+	if (gis) {
+		ravb_write(ndev, ~gis, GIS);
+		return IRQ_HANDLED;
+	}
+
+	return IRQ_NONE;
+}
+
+void ravb_ptp_init(struct net_device *ndev, struct platform_device *pdev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	unsigned long flags;
+	u32 gccr;
+
+	priv->ptp.info = ravb_ptp_info;
+
+	priv->ptp.default_addend = ravb_read(ndev, GTI);
+	priv->ptp.current_addend = priv->ptp.default_addend;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);
+	gccr = ravb_read(ndev, GCCR) & ~GCCR_TCSS;
+	ravb_write(ndev, gccr | GCCR_TCSS_ADJGPTP, GCCR);
+	mmiowb();
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	priv->ptp.clock = ptp_clock_register(&priv->ptp.info, &pdev->dev);
+}
+
+void ravb_ptp_stop(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	ravb_write(ndev, 0, GIC);
+	ravb_write(ndev, 0, GIS);
+
+	ptp_clock_unregister(priv->ptp.clock);
+}

