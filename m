From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 5/7] stmmac: add sysFs support
Date: Mon,  3 Sep 2012 09:47:00 +0200
Message-ID: <1346658422-1925-6-git-send-email-peppe.cavallaro@st.com>
References: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:52867 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755535Ab2ICHra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 03:47:30 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 185071D7
	for <netdev@vger.kernel.org>; Mon,  3 Sep 2012 07:47:24 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CDC712B98
	for <netdev@vger.kernel.org>; Mon,  3 Sep 2012 07:47:24 +0000 (GMT)
In-Reply-To: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the sysFs support.
Some internal driver parameters can be tuned by using some
entries exposed via sysFS. There parameter currently are,
for example, for internal timers used to mitigate the rx/tx
interrupts or for EEE.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |    8 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac-sysfs.c |  157 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    3 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   36 ++---
 5 files changed, 185 insertions(+), 21 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac-sysfs.c

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index c8e8ea6..4450fc6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -6,4 +6,4 @@ stmmac-$(CONFIG_STMMAC_PCI) += stmmac_pci.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
 	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
-	      mmc_core.o $(stmmac-y)
+	      mmc_core.o stmmac-sysfs.o $(stmmac-y)
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 63d4bad..b0b08bc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -169,7 +169,13 @@ struct stmmac_extra_stats {
 #define DMA_HW_FEAT_SAVLANINS	0x08000000 /* Source Addr or VLAN Insertion */
 #define DMA_HW_FEAT_ACTPHYIF	0x70000000 /* Active/selected PHY interface */
 #define DEFAULT_DMA_PBL		8
-#define DEFAULT_DMA_RIWT	0xff	/* Max RI Watchdog Timer count */
+#define MAX_DMA_RIWT		0xff	/* Max RI Watchdog Timer count */
+
+#define	STMMAC_COAL_TX_TIMER		40000
+#define	STMMAC_MAX_COAL_TX_TIMER	100000
+#define STMMAC_TX_MAX_FRAMES		64
+#define STMMAC_DEFAULT_LPI_TIMER	1000
+#define STMMAC_MAX_LPI_TIMER		5000
 
 enum rx_frame_status { /* IPC status */
 	good_frame = 0,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac-sysfs.c b/drivers/net/ethernet/stmicro/stmmac/stmmac-sysfs.c
new file mode 100644
index 0000000..92537a0
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac-sysfs.c
@@ -0,0 +1,157 @@
+/*******************************************************************************
+  STMMAC sysfs module
+
+	Copyright(C) 2012 STMicroelectronics Ltd
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
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+*******************************************************************************/
+
+#include <linux/sysfs.h>
+
+#include "stmmac.h"
+
+/* EEE Timer attribute */
+static ssize_t eee_timer_show(struct device *dev, struct device_attribute *attr,
+			      char *buf)
+{
+	struct stmmac_priv *priv = netdev_priv(to_net_dev(dev));
+
+	return snprintf(buf, PAGE_SIZE, "%u", (u32) priv->eee_timer);
+}
+
+static ssize_t eee_timer_store(struct device *dev,
+			       struct device_attribute *attr, const char *buf,
+			       size_t count)
+{
+	struct stmmac_priv *priv = netdev_priv(to_net_dev(dev));
+
+	int eee_timer;
+
+	sscanf(buf, "%u", &eee_timer);
+
+	if ((eee_timer <= 0) || (eee_timer > STMMAC_MAX_LPI_TIMER))
+		pr_err("stmmac: invalid EEE timer value\n");
+	else
+		priv->eee_timer = eee_timer;
+
+	return count;
+}
+
+/* TX coalesce parameters */
+static ssize_t tx_coal_timer_show(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	struct stmmac_priv *priv = netdev_priv(to_net_dev(dev));
+
+	return snprintf(buf, PAGE_SIZE, "%u", (u32) priv->tx_coal_timer);
+}
+
+static ssize_t tx_coal_timer_store(struct device *dev,
+				   struct device_attribute *attr,
+				   const char *buf, size_t count)
+{
+	struct stmmac_priv *priv = netdev_priv(to_net_dev(dev));
+
+	int tx_coal_timer;
+
+	sscanf(buf, "%u", &tx_coal_timer);
+
+	if ((tx_coal_timer <= 0) || (tx_coal_timer > STMMAC_MAX_COAL_TX_TIMER))
+		pr_err("stmmac: Tx coalesce timer value\n");
+	else
+		priv->tx_coal_timer = tx_coal_timer;
+
+	return count;
+}
+
+static ssize_t tx_coal_frames_show(struct device *dev,
+				   struct device_attribute *attr, char *buf)
+{
+	struct stmmac_priv *priv = netdev_priv(to_net_dev(dev));
+
+	return snprintf(buf, PAGE_SIZE, "%u", (u32) priv->tx_coal_frames);
+}
+
+static ssize_t tx_coal_frames_store(struct device *dev,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
+{
+	struct stmmac_priv *priv = netdev_priv(to_net_dev(dev));
+
+	int tx_coal_frames;
+
+	sscanf(buf, "%u", &tx_coal_frames);
+
+	if ((tx_coal_frames <= 0) || (tx_coal_frames >= STMMAC_TX_MAX_FRAMES))
+		pr_err("stmmac: invalid Tx coalesce value\n");
+	else
+		priv->tx_coal_frames = tx_coal_frames;
+
+	return count;
+}
+
+/* RX coalesce parameters */
+static ssize_t rx_riwt_show(struct device *dev, struct device_attribute *attr,
+			    char *buf)
+{
+	struct stmmac_priv *priv = netdev_priv(to_net_dev(dev));
+
+	return snprintf(buf, PAGE_SIZE, "%u", (u16) priv->rx_riwt);
+}
+
+static ssize_t rx_riwt_store(struct device *dev, struct device_attribute *attr,
+			     const char *buf, size_t count)
+{
+	struct stmmac_priv *priv = netdev_priv(to_net_dev(dev));
+
+	int rx_riwt;
+
+	sscanf(buf, "%u", &rx_riwt);
+
+	if ((rx_riwt <= 0) || (rx_riwt >= MAX_DMA_RIWT)) {
+		pr_err("stmmac: invalid RX WDT timer value\n");
+	} else {
+		priv->rx_riwt = rx_riwt;
+		priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt);
+	}
+
+	return count;
+}
+
+DEVICE_ATTR(eee_timer, 0644, eee_timer_show, eee_timer_store);
+DEVICE_ATTR(tx_coal_timer, 0644, tx_coal_timer_show,
+	    tx_coal_timer_store);
+DEVICE_ATTR(tx_coal_frames, 0644, tx_coal_frames_show,
+	    tx_coal_frames_store);
+DEVICE_ATTR(rx_riwt, 0644, rx_riwt_show, rx_riwt_store);
+
+void stmmac_create_sysfs(struct net_device *dev)
+{
+	int rc;
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	rc = device_create_file(&dev->dev, &dev_attr_tx_coal_timer);
+	rc |= device_create_file(&dev->dev, &dev_attr_tx_coal_frames);
+	if (priv->synopsys_id >= DWMAC_CORE_3_50)
+		rc |= device_create_file(&dev->dev, &dev_attr_rx_riwt);
+	if (priv->eee_enabled)
+		rc |= device_create_file(&dev->dev, &dev_attr_eee_timer);
+	if (rc)
+		pr_err("%s: failed to create the sysfs entries\n", __func__);
+}
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 0f5ab28..05f17184 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -87,11 +87,13 @@ struct stmmac_priv {
 	int lpi_irq;
 	int eee_enabled;
 	int eee_active;
+	int eee_timer;
 	int tx_lpi_timer;
 	struct timer_list txtimer;
 	u32 tx_count_frames;
 	u32 tx_coal_frames;
 	u32 tx_coal_timer;
+	u16 rx_riwt;
 };
 
 extern int phyaddr;
@@ -111,6 +113,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 				     void __iomem *addr);
 void stmmac_disable_eee_mode(struct stmmac_priv *priv);
 bool stmmac_eee_init(struct stmmac_priv *priv);
+void stmmac_create_sysfs(struct net_device *dev);
 
 #ifdef CONFIG_STMMAC_PLATFORM
 extern struct platform_driver stmmac_pltfr_driver;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index bafe694..1895130 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -77,8 +77,6 @@
 
 #define STMMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
 #define JUMBO_LEN	9000
-#define	STMMAC_TX_TM	40000
-#define STMMAC_TX_MAX_FRAMES	64	/* Max coalesced frame */
 
 /* Module parameters */
 #define TX_TIMEO 5000 /* default 5 seconds */
@@ -126,11 +124,8 @@ static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
 				      NETIF_MSG_LINK | NETIF_MSG_IFUP |
 				      NETIF_MSG_IFDOWN | NETIF_MSG_TIMER);
 
-#define STMMAC_DEFAULT_LPI_TIMER	1000
-static int eee_timer = STMMAC_DEFAULT_LPI_TIMER;
-module_param(eee_timer, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(eee_timer, "LPI tx expiration time in msec");
 #define STMMAC_LPI_TIMER(x) (jiffies + msecs_to_jiffies(x))
+#define STMMAC_COAL_TIMER(x) (jiffies + usecs_to_jiffies(x))
 
 static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
 static int stmmac_rx(struct stmmac_priv *priv, int limit);
@@ -161,8 +156,6 @@ static void stmmac_verify_args(void)
 		flow_ctrl = FLOW_OFF;
 	if (unlikely((pause < 0) || (pause > 0xffff)))
 		pause = PAUSE_TIME;
-	if (eee_timer < 0)
-		eee_timer = STMMAC_DEFAULT_LPI_TIMER;
 }
 
 static void stmmac_clk_csr_set(struct stmmac_priv *priv)
@@ -254,7 +247,7 @@ static void stmmac_eee_ctrl_timer(unsigned long arg)
 	struct stmmac_priv *priv = (struct stmmac_priv *)arg;
 
 	stmmac_enable_eee_mode(priv);
-	mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_TIMER(eee_timer));
+	mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_TIMER(priv->eee_timer));
 }
 
 /**
@@ -280,7 +273,8 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 		init_timer(&priv->eee_ctrl_timer);
 		priv->eee_ctrl_timer.function = stmmac_eee_ctrl_timer;
 		priv->eee_ctrl_timer.data = (unsigned long)priv;
-		priv->eee_ctrl_timer.expires = STMMAC_LPI_TIMER(eee_timer);
+		priv->eee_ctrl_timer.expires =
+			STMMAC_LPI_TIMER(priv->eee_timer);
 		add_timer(&priv->eee_ctrl_timer);
 
 		priv->hw->mac->set_eee_timer(priv->ioaddr,
@@ -770,7 +764,8 @@ static void stmmac_tx(struct stmmac_priv *priv)
 
 	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
 		stmmac_enable_eee_mode(priv);
-		mod_timer(&priv->eee_ctrl_timer, STMMAC_LPI_TIMER(eee_timer));
+		mod_timer(&priv->eee_ctrl_timer,
+			  STMMAC_LPI_TIMER(priv->eee_timer));
 	}
 	spin_unlock_irqrestore(&priv->tx_lock, flags);
 }
@@ -1016,9 +1011,9 @@ static int stmmac_init_tx_coalesce(struct stmmac_priv *priv)
 						 STMMAC_TX_MAX_FRAMES);
 	if (priv->tx_coal_frames) {
 		/* Set Tx coalesce parameters and timers */
-		priv->tx_coal_timer = jiffies + usecs_to_jiffies(STMMAC_TX_TM);
+		priv->tx_coal_timer = STMMAC_COAL_TX_TIMER;
 		init_timer(&priv->txtimer);
-		priv->txtimer.expires = priv->tx_coal_timer;
+		priv->txtimer.expires = STMMAC_COAL_TIMER(priv->tx_coal_timer);
 		priv->txtimer.data = (unsigned long)priv;
 		priv->txtimer.function = stmmac_txtimer;
 
@@ -1138,6 +1133,7 @@ static int stmmac_open(struct net_device *dev)
 		phy_start(priv->phydev);
 
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS_TIMER;
+	priv->eee_timer = STMMAC_DEFAULT_LPI_TIMER;
 	priv->eee_enabled = stmmac_eee_init(priv);
 
 	ret = stmmac_init_tx_coalesce(priv);
@@ -1149,11 +1145,13 @@ static int stmmac_open(struct net_device *dev)
 	 */
 	if (priv->synopsys_id < DWMAC_CORE_3_50)
 		napi_enable(&priv->napi);
-	else if (priv->hw->dma->rx_watchdog)
+	else if (priv->hw->dma->rx_watchdog) {
+		priv->rx_riwt = MAX_DMA_RIWT;
 		/* Program RX Watchdog register to the default values
 		 * FIXME: provide user value for RIWT
 		 */
-		priv->hw->dma->rx_watchdog(priv->ioaddr, DEFAULT_DMA_RIWT);
+		priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt);
+	}
 
 	skb_queue_head_init(&priv->rx_recycle);
 	netif_start_queue(dev);
@@ -1317,7 +1315,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (priv->tx_coal_frames > priv->tx_count_frames) {
 		priv->hw->desc->clear_tx_ic(desc);
 		priv->xstats.tx_reset_ic_bit++;
-		mod_timer(&priv->txtimer, priv->tx_coal_timer);
+		mod_timer(&priv->txtimer,
+			  STMMAC_COAL_TIMER(priv->tx_coal_timer));
 	} else
 		priv->tx_count_frames = 0;
 
@@ -2081,6 +2080,8 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 		goto error_mdio_register;
 	}
 
+	stmmac_create_sysfs(ndev);
+
 	return priv;
 
 error_mdio_register:
@@ -2283,9 +2284,6 @@ static int __init stmmac_cmdline_opt(char *str)
 		} else if (!strncmp(opt, "pause:", 6)) {
 			if (kstrtoint(opt + 6, 0, &pause))
 				goto err;
-		} else if (!strncmp(opt, "eee_timer:", 6)) {
-			if (kstrtoint(opt + 10, 0, &eee_timer))
-				goto err;
 		}
 	}
 	return 0;
-- 
1.7.4.4
