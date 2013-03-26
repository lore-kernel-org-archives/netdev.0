From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 7/8 (v2)] stmmac: add the support for PTP hw clock driver
Date: Tue, 26 Mar 2013 15:43:11 +0100
Message-ID: <1364308992-27929-8-git-send-email-peppe.cavallaro@st.com>
References: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Cc: rayagond@vayavyalabs.com, richardcochran@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:44720 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933497Ab3CZOpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 10:45:11 -0400
In-Reply-To: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rayagond Kokatanur <rayagond@vayavyalabs.com>

This patch implements PHC (ptp hardware clock) driver for stmmac
driver to support 1588 PTP.

V2: added support for FINE method, reduced loop delay and review spinlock.

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |    1 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |    3 +
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    6 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    3 +
 .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  |   40 ++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   34 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c   |  215 ++++++++++++++++++++
 8 files changed, 294 insertions(+), 10 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index f0720d0..f695a50 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -5,6 +5,7 @@ config STMMAC_ETH
 	select MII
 	select PHYLIB
 	select CRC32
+	select PTP_1588_CLOCK
 	---help---
 	  This is the driver for the Ethernet IPs are built around a
 	  Synopsys IP Core and only tested on the STMicroelectronics
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 1aca0e6..356a9dd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -4,4 +4,4 @@ stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
-	      mmc_core.o stmmac_hwtstamp.o $(stmmac-y)
+	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o $(stmmac-y)
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 6fa975c..ad7e20a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -411,6 +411,9 @@ struct stmmac_hwtimestamp {
 	void (*config_sub_second_increment) (void __iomem *ioaddr);
 	int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
 	int (*config_addend)(void __iomem *ioaddr, u32 addend);
+	int (*adjust_systime)(void __iomem *ioaddr, u32 sec, u32 nsec,
+			      int add_sub);
+	u64 (*get_systime)(void __iomem *ioaddr);
 };
 
 struct mac_link {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index a21d1b9..52002e7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -31,6 +31,7 @@
 #include <linux/phy.h>
 #include <linux/pci.h>
 #include "common.h"
+#include <linux/ptp_clock_kernel.h>
 
 struct stmmac_priv {
 	/* Frequently used values are kept adjacent for cache effect */
@@ -103,6 +104,9 @@ struct stmmac_priv {
 	int hwts_rx_en;
 	unsigned int default_addend;
 	u32 adv_ts;
+	struct ptp_clock *ptp_clock;
+	struct ptp_clock_info ptp_clock_ops;
+	spinlock_t ptp_lock;
 };
 
 extern int phyaddr;
@@ -113,6 +117,8 @@ extern void stmmac_set_ethtool_ops(struct net_device *netdev);
 extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
 extern const struct stmmac_hwtimestamp stmmac_ptp;
+extern int stmmac_ptp_register(struct stmmac_priv *priv);
+extern void stmmac_ptp_unregister(struct stmmac_priv *priv);
 int stmmac_freeze(struct net_device *ndev);
 int stmmac_restore(struct net_device *ndev);
 int stmmac_resume(struct net_device *ndev);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 5b340c2..c5f9cb8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -737,6 +737,9 @@ static int stmmac_get_ts_info(struct net_device *dev,
 					SOF_TIMESTAMPING_RX_HARDWARE |
 					SOF_TIMESTAMPING_RAW_HARDWARE;
 
+		if (priv->ptp_clock)
+			info->phc_index = ptp_clock_index(priv->ptp_clock);
+
 		info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
 
 		info->rx_filters = ((1 << HWTSTAMP_FILTER_NONE) |
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
index 380baeb..def7e75 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
@@ -100,9 +100,49 @@ static int stmmac_config_addend(void __iomem *ioaddr, u32 addend)
 	return 0;
 }
 
+static int stmmac_adjust_systime(void __iomem *ioaddr, u32 sec, u32 nsec,
+				 int add_sub)
+{
+	u32 value;
+	int limit;
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
+	limit = 10;
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
+static u64 stmmac_get_systime(void __iomem *ioaddr)
+{
+	u64 ns;
+
+	ns = readl(ioaddr + PTP_STNSR);
+	/* convert sec time value to nanosecond */
+	ns += readl(ioaddr + PTP_STSR) * 1000000000ULL;
+
+	return ns;
+}
+
 const struct stmmac_hwtimestamp stmmac_ptp = {
 	.config_hw_tstamping = stmmac_config_hw_tstamping,
 	.init_systime = stmmac_init_systime,
 	.config_sub_second_increment = stmmac_config_sub_second_increment,
 	.config_addend = stmmac_config_addend,
+	.adjust_systime = stmmac_adjust_systime,
+	.get_systime = stmmac_get_systime,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6906772..6b26d31 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -618,20 +618,32 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 			    sizeof(struct hwtstamp_config)) ? -EFAULT : 0;
 }
 
-static void stmmac_init_ptp(struct stmmac_priv *priv)
+static int stmmac_init_ptp(struct stmmac_priv *priv)
 {
-	if (priv->dma_cap.time_stamp) {
-		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
-		priv->adv_ts = 0;
-	}
-	if (priv->dma_cap.atime_stamp && priv->extend_desc) {
-		pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
-		priv->adv_ts = 1;
+	if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp))
+		return -EOPNOTSUPP;
+
+	if (netif_msg_hw(priv)) {
+		if (priv->dma_cap.time_stamp) {
+			pr_debug("IEEE 1588-2002 Time Stamp supported\n");
+			priv->adv_ts = 0;
+		}
+		if (priv->dma_cap.atime_stamp && priv->extend_desc) {
+			pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
+			priv->adv_ts = 1;
+		}
 	}
 
 	priv->hw->ptp = &stmmac_ptp;
 	priv->hwts_tx_en = 0;
 	priv->hwts_rx_en = 0;
+
+	return stmmac_ptp_register(priv);
+}
+
+static void stmmac_release_ptp(struct stmmac_priv *priv)
+{
+	stmmac_ptp_unregister(priv);
 }
 
 /**
@@ -1567,7 +1579,9 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_mmc_setup(priv);
 
-	stmmac_init_ptp(priv);
+	ret = stmmac_init_ptp(priv);
+	if (ret)
+		pr_warn("%s: failed PTP initialisation\n", __func__);
 
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	ret = stmmac_init_fs(dev);
@@ -1677,6 +1691,8 @@ static int stmmac_release(struct net_device *dev)
 #endif
 	clk_disable_unprepare(priv->stmmac_clk);
 
+	stmmac_release_ptp(priv);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
new file mode 100644
index 0000000..93d4bef
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -0,0 +1,215 @@
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
+	unsigned long flags;
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
+	diff = div_u64(adj, 1000000000ULL);
+	addend = neg_adj ? (addend - diff) : (addend + diff);
+
+	spin_lock_irqsave(&priv->ptp_lock, flags);
+
+	priv->hw->ptp->config_addend(priv->ioaddr, addend);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
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
+	if (delta < 0) {
+		neg_adj = 1;
+		delta = -delta;
+	}
+
+	quotient = div_u64_rem(delta, 1000000000ULL, &reminder);
+	sec = quotient;
+	nsec = reminder;
+
+	spin_lock_irqsave(&priv->ptp_lock, flags);
+
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
+	u64 ns;
+	u32 reminder;
+
+	spin_lock_irqsave(&priv->ptp_lock, flags);
+
+	ns = priv->hw->ptp->get_systime(priv->ioaddr);
+
+	spin_unlock_irqrestore(&priv->ptp_lock, flags);
+
+	ts->tv_sec = div_u64_rem(ns, 1000000000ULL, &reminder);
+	ts->tv_nsec = reminder;
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
+	.max_adj = 62500000,
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
-- 
1.7.4.4
