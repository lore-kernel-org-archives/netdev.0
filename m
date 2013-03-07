From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 4/9] stmmac: add the support for PTP hw clock driver
Date: Thu,  7 Mar 2013 11:50:14 +0100
Message-ID: <1362653419-1047-5-git-send-email-peppe.cavallaro@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-us.st.com ([167.4.1.35]:56682 "EHLO beta.dmz-us.st.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932636Ab3CGLrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:47:09 -0500
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rayagond Kokatanur <rayagond@vayavyalabs.com>

This patch implements PHC (ptp hardware clock) driver for stmmac
driver to support 1588 PTP.

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |    4 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   13 ++
 .../net/ethernet/stmicro/stmmac/stmmac_hwstamp.c   |   50 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   31 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  209 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |    2 +
 7 files changed, 303 insertions(+), 8 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index cc97c07..40ee3df 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -3,7 +3,7 @@ stmmac-$(CONFIG_STMMAC_RING) += ring_mode.o
 stmmac-$(CONFIG_STMMAC_CHAINED) += chain_mode.o
 stmmac-$(CONFIG_STMMAC_PLATFORM) += stmmac_platform.o
 stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
-stmmac-$(CONFIG_STMMAC_USE_HWSTAMP) += stmmac_hwstamp.o
+stmmac-$(CONFIG_STMMAC_USE_HWSTAMP) += stmmac_hwstamp.o stmmac_ptp.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
 	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index df7123a..a10974c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -387,6 +387,10 @@ struct stmmac_hwtimestamp {
 	void (*config_sub_second_increment) (void __iomem *ioaddr);
 	int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
 	int (*config_addend)(void __iomem *ioaddr, u32 addend);
+	int (*adjust_systime)(void __iomem *ioaddr, u32 sec, u32 nsec,
+			      int add_sub);
+	u32 (*get_systime_sec)(void __iomem *ioaddr);
+	u32 (*get_systime_nsec)(void __iomem *ioaddr);
 };
 #endif
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 50b5f26..2d6e2e1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -32,6 +32,10 @@
 #include <linux/pci.h>
 #include "common.h"
 
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+#include <linux/ptp_clock_kernel.h>
+#endif
+
 struct stmmac_priv {
 	/* Frequently used values are kept adjacent for cache effect */
 	struct dma_desc *dma_tx ____cacheline_aligned;
@@ -98,6 +102,9 @@ struct stmmac_priv {
 	int hwts_tx_en;
 	int hwts_rx_en;
 	unsigned int default_addend;
+	struct ptp_clock *ptp_clock;
+	struct ptp_clock_info ptp_clock_ops;
+	spinlock_t ptp_lock;
 #endif
 	int atds;
 };
@@ -111,6 +118,12 @@ extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
 #ifdef CONFIG_STMMAC_USE_HWSTAMP
 extern const struct stmmac_hwtimestamp stmmac_ptp;
+extern int stmmac_adjust_systime(void __iomem *ioaddr, u32 sec, u32 nsec,
+				 int add_sub);
+extern u32 stmmac_get_systime_sec(void __iomem *ioaddr);
+extern u32 stmmac_get_systime_nsec(void __iomem *ioaddr);
+extern int stmmac_ptp_register(struct stmmac_priv *priv);
+extern void stmmac_ptp_unregister(struct stmmac_priv *priv);
 #endif
 int stmmac_freeze(struct net_device *ndev);
 int stmmac_restore(struct net_device *ndev);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
index be9e399..bec2278 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
@@ -121,9 +121,59 @@ static int stmmac_config_addend(void __iomem *ioaddr, u32 addend)
 	return 0;
 }
 
+static int stmmac_adjust_systime(void __iomem *ioaddr, u32 sec, u32 nsec,
+				 int add_sub)
+{
+	u32 value;
+	int limit;
+
+	/* wait for previous(if any) system time adjust/update to complete */
+	limit = 100;
+	while (limit--) {
+		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSUPDT))
+			break;
+		mdelay(10);
+	}
+	if (limit < 0)
+		return -EBUSY;
+
+	writel(sec, ioaddr + PTP_STSUR);
+	writel(((add_sub << PTP_STNSUR_ADDSUB_SHIFT) | nsec),
+		ioaddr + PTP_STNSUR);
+	/* issue command to initialize the system time value */
+	value = readl(ioaddr + PTP_TCR);
+	value |= PTP_TCR_TSUPDT;
+	writel(value, ioaddr + PTP_TCR);
+
+	/* wait for present system time adjust/update to complete */
+	limit = 100;
+	while (limit--) {
+		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSUPDT))
+			break;
+		mdelay(10);
+	}
+	if (limit < 0)
+		return -EBUSY;
+
+	return 0;
+}
+
+static u32 stmmac_get_systime_sec(void __iomem *ioaddr)
+{
+	return readl(ioaddr + PTP_STSR);
+}
+
+static u32 stmmac_get_systime_nsec(void __iomem *ioaddr)
+{
+	return readl(ioaddr + PTP_STNSR);
+}
+
 const struct stmmac_hwtimestamp stmmac_ptp = {
 	.config_hw_tstamping = stmmac_config_hw_tstamping,
 	.init_systime = stmmac_init_systime,
 	.config_sub_second_increment = stmmac_config_sub_second_increment,
 	.config_addend = stmmac_config_addend,
+	.adjust_systime = stmmac_adjust_systime,
+	.get_systime_sec = stmmac_get_systime_sec,
+	.get_systime_nsec = stmmac_get_systime_nsec,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6174f34..009abf8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -474,24 +474,37 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			    sizeof(struct hwtstamp_config)) ? -EFAULT : 0;
 }
 
-static void stmmac_init_ptp(struct stmmac_priv *priv)
+static int stmmac_init_ptp(struct stmmac_priv *priv)
 {
-	if (priv->dma_cap.time_stamp)
-		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
-	if (priv->dma_cap.atime_stamp)
-		pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
+	if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp))
+		return -EOPNOTSUPP;
+
+	if (netif_msg_hw(priv)) {
+		if (priv->dma_cap.time_stamp)
+			pr_debug("IEEE 1588-2002 Time Stamp supported\n");
+		if (priv->dma_cap.atime_stamp)
+			pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
+	}
 
 	priv->hw->ptp = &stmmac_ptp;
 
 	priv->hwts_tx_en = 0;
 	priv->hwts_rx_en = 0;
 
+	return stmmac_ptp_register(priv);
+}
+
+static void stmmac_release_ptp(struct stmmac_priv *priv)
+{
+	stmmac_ptp_unregister(priv);
 }
+
 #else
 #define stmmac_hwtstamp_ioctl(dev, ifr)	(-EOPNOTSUPP)
 #define stmmac_get_rx_hwtstamp(priv, p, skb)
 #define stmmac_get_tx_hwtstamp(priv, p, skb) 0
-#define stmmac_init_ptp(priv)
+#define stmmac_init_ptp(priv) 0
+#define stmmac_release_ptp(priv)
 #endif /* CONFIG_STMMAC_USE_HWSTAMP */
 
 /**
@@ -1301,7 +1314,9 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_mmc_setup(priv);
 
-	stmmac_init_ptp(priv);
+	ret = stmmac_init_ptp(priv);
+	if (ret)
+		pr_warn("%s: failed PTP initialisation\n", __func__);
 
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	ret = stmmac_init_fs(dev);
@@ -1403,6 +1418,8 @@ static int stmmac_release(struct net_device *dev)
 #endif
 	clk_disable_unprepare(priv->stmmac_clk);
 
+	stmmac_release_ptp(priv);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
new file mode 100644
index 0000000..53680bf
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -0,0 +1,209 @@
+/*******************************************************************************
+  PTP 1588 clock using the STMMAC.
+
+  Copyright (C) 2013  Vayavya Labs Pvt Ltd
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Author: Rayagond Kokatanur <rayagond@vayavyalabs.com>
+*******************************************************************************/
+#include "stmmac.h"
+#include "stmmac_ptp.h"
+
+/**
+ * stmmac_adjust_freq
+ *
+ * @ptp: pointer to ptp_clock_info structure
+ * @ppb: desired period change in parts ber billion
+ *
+ * Description: this function will adjust the frequency of hardware clock.
+ */
+static int stmmac_adjust_freq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct stmmac_priv *priv =
+	    container_of(ptp, struct stmmac_priv, ptp_clock_ops);
+	u32 diff, addend;
+	int neg_adj = 0;
+	u64 adj;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+
+	addend = priv->default_addend;
+	adj = addend;
+	adj *= ppb;
+	/* div_u64 will divided the "adj" by "1000000000ULL"
+	 * and return the quotient
+	 */
+	diff = div_u64(adj, 1000000000ULL);
+
+	addend = neg_adj ? (addend - diff) : (addend + diff);
+
+	priv->hw->ptp->config_addend(priv->ioaddr, addend);
+
+	return 0;
+}
+
+/**
+ * stmmac_adjust_time
+ *
+ * @ptp: pointer to ptp_clock_info structure
+ * @delta: desired change in nanoseconds
+ *
+ * Description: this function will shift/adjust the hardware clock time.
+ */
+static int stmmac_adjust_time(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct stmmac_priv *priv =
+	    container_of(ptp, struct stmmac_priv, ptp_clock_ops);
+	unsigned long flags;
+	u32 sec, nsec;
+	u32 quotient, reminder;
+	int neg_adj = 0;
+
+	spin_lock_irqsave(&priv->ptp_lock, flags);
+
+	if (delta < 0) {
+		neg_adj = 1;
+		delta = -delta;
+	}
+
+	quotient = div_u64_rem(delta, 1000000000ULL, &reminder);
+	sec = quotient;
+	nsec = reminder;
+	priv->hw->ptp->adjust_systime(priv->ioaddr, sec, nsec, neg_adj);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
+
+/**
+ * stmmac_get_time
+ *
+ * @ptp: pointer to ptp_clock_info structure
+ * @ts: pointer to hold time/result
+ *
+ * Description: this function will read the current time from the
+ * hardware clock and store it in @ts.
+ */
+static int stmmac_get_time(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	struct stmmac_priv *priv =
+	    container_of(ptp, struct stmmac_priv, ptp_clock_ops);
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->ptp_lock, flags);
+
+	ts->tv_sec = priv->hw->ptp->get_systime_sec(priv->ioaddr);
+	ts->tv_nsec = priv->hw->ptp->get_systime_nsec(priv->ioaddr);
+
+	spin_unlock_irqrestore(&priv->ptp_lock, flags);
+
+	return 0;
+}
+
+/**
+ * stmmac_set_time
+ *
+ * @ptp: pointer to ptp_clock_info structure
+ * @ts: time value to set
+ *
+ * Description: this function will set the current time on the
+ * hardware clock.
+ */
+static int stmmac_set_time(struct ptp_clock_info *ptp,
+			   const struct timespec *ts)
+{
+	struct stmmac_priv *priv =
+	    container_of(ptp, struct stmmac_priv, ptp_clock_ops);
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->ptp_lock, flags);
+
+	priv->hw->ptp->init_systime(priv->ioaddr, ts->tv_sec, ts->tv_nsec);
+
+	spin_unlock_irqrestore(&priv->ptp_lock, flags);
+
+	return 0;
+}
+
+static int stmmac_enable(struct ptp_clock_info *ptp,
+			 struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+/* structure describing a PTP hardware clock */
+static struct ptp_clock_info stmmac_ptp_clock_ops = {
+	.owner = THIS_MODULE,
+	.name = "stmmac_ptp_clock",
+	.max_adj = STMMAC_SYSCLOCK,
+	.n_alarm = 0,
+	.n_ext_ts = 0,
+	.n_per_out = 0,
+	.pps = 0,
+	.adjfreq = stmmac_adjust_freq,
+	.adjtime = stmmac_adjust_time,
+	.gettime = stmmac_get_time,
+	.settime = stmmac_set_time,
+	.enable = stmmac_enable,
+};
+
+/**
+ * stmmac_ptp_register
+ *
+ * @ndev: net device pointer
+ *
+ * Description: this function will register the ptp clock driver
+ * to kernel. It also does some house keeping work.
+ */
+int stmmac_ptp_register(struct stmmac_priv *priv)
+{
+	spin_lock_init(&priv->ptp_lock);
+	priv->ptp_clock_ops = stmmac_ptp_clock_ops;
+
+	priv->ptp_clock = ptp_clock_register(&priv->ptp_clock_ops,
+					     priv->device);
+	if (IS_ERR(priv->ptp_clock)) {
+		priv->ptp_clock = NULL;
+		pr_err("ptp_clock_register() failed on %s\n", priv->dev->name);
+	} else
+		pr_debug("Added PTP HW clock successfully on %s\n",
+			 priv->dev->name);
+
+	return 0;
+}
+
+/**
+ * stmmac_ptp_unregister
+ *
+ * @ndev: net device pointer
+ *
+ * Description: this function will remove/unregister the ptp clock driver
+ * from the kernel.
+ */
+void stmmac_ptp_unregister(struct stmmac_priv *priv)
+{
+	if (priv->ptp_clock) {
+		ptp_clock_unregister(priv->ptp_clock);
+		pr_debug("Removed PTP HW clock successfully on %s\n",
+			 priv->dev->name);
+	}
+}
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
index d557696..3dbc047 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -40,6 +40,8 @@
 #define	PTP_STHWSR	0x0724	/* System Time - Higher Word Seconds Reg */
 #define PTP_TSR		0x0728	/* Timestamp Status */
 
+#define PTP_STNSUR_ADDSUB_SHIFT 31
+
 /* PTP TCR defines */
 #define PTP_TCR_TSENA		0x00000001 /* Timestamp Enable */
 #define PTP_TCR_TSCFUPDT	0x00000002 /* Timestamp Fine/Coarse Update */
-- 
1.7.4.4
