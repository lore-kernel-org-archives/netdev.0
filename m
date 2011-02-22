From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net-2.6) 4/4] stmmac: rework and improvement the stmmac
 timer
Date: Tue, 22 Feb 2011 11:17:44 +0100
Message-ID: <1298369864-24429-5-git-send-email-peppe.cavallaro@st.com>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stuart MENEFY <stuart.menefy@st.com>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:36553 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753957Ab1BVKmz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 05:42:55 -0500
In-Reply-To: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares the stmmac to use the
embedded watchdog timer included in the new
mac generations. The STMMAC_TIMER option becomes
STMMAC_EXT_TIMER. The patch also tidies-up the code
and improvements the Kconfig information.

The driver can use the external timer and in case
of problems, i.e. while registering the timer,
it'll continue to work with NAPI and interrupts.

Currently, the STMMAC_EXT_TIMER can be turned on
SUPERH only and it depends on SH_TIMER_TMU: I mean
on platforms where I performed all my tests.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig        |   18 ++++++++----
 drivers/net/stmmac/Makefile       |    2 +-
 drivers/net/stmmac/common.h       |    6 ++++
 drivers/net/stmmac/stmmac.h       |    5 ++-
 drivers/net/stmmac/stmmac_main.c  |   51 +++++++++++++++++++-----------------
 drivers/net/stmmac/stmmac_timer.c |    4 +-
 drivers/net/stmmac/stmmac_timer.h |    1 -
 7 files changed, 51 insertions(+), 36 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index b74e79b..cdbe5a8 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -29,22 +29,28 @@ config STMMAC_DUAL_MAC
 	  Ethernet Controllers. This option turns on the second Ethernet
 	  device on this kind of platforms.
 
-config STMMAC_TIMER
+config STMMAC_EXT_TIMER
 	bool "STMMAC Timer optimisation"
 	default n
 	help
 	  Use an external timer for mitigating the number of network
 	  interrupts. Currently, for SH architectures, it is possible
-	  to use the TMU channel 2 and the SH-RTC device.
+	  to use the TMU channel 2 (via Generic Timer) and the SH-RTC
+	  device. If the timer registration fails during the interface
+	  initialisation then the driver will work without any
+	  mitigation schema.
 
 choice
         prompt "Select Timer device"
-        depends on STMMAC_TIMER
+        depends on STMMAC_EXT_TIMER
 
-config STMMAC_TMU_TIMER
-        bool "TMU channel 2"
-        depends on CPU_SH4
+config STMMAC_GEN_TIMER
+        bool "Generic External Timer"
+        depends on SH_TIMER_TMU
 	help
+	  Use the Generic timer for mitigating the interrupts.
+	  For example, in case of SUPERH the TMU channel 2
+	  is used for that.
 
 config STMMAC_RTC_TIMER
         bool "Real time clock"
diff --git a/drivers/net/stmmac/Makefile b/drivers/net/stmmac/Makefile
index 9691733..05d84b2 100644
--- a/drivers/net/stmmac/Makefile
+++ b/drivers/net/stmmac/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_STMMAC_ETH) += stmmac.o
-stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
+stmmac-$(CONFIG_STMMAC_EXT_TIMER) += stmmac_timer.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
 	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o $(stmmac-y)
diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 375ea19..4bd9d01 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -43,6 +43,12 @@
 #undef FRAME_FILTER_DEBUG
 /* #define FRAME_FILTER_DEBUG */
 
+enum mitigation_timer {
+	no_timer = 0,
+	external = 1,
+	embedded = 2,
+};
+
 struct stmmac_extra_stats {
 	/* Transmit errors */
 	unsigned long tx_underflow ____cacheline_aligned;
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 5f06c47..1b76977 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -25,7 +25,7 @@
 #include <linux/stmmac.h>
 
 #include "common.h"
-#ifdef CONFIG_STMMAC_TIMER
+#ifdef CONFIG_STMMAC_EXT_TIMER
 #include "stmmac_timer.h"
 #endif
 
@@ -77,9 +77,10 @@ struct stmmac_priv {
 	spinlock_t lock;
 	int wolopts;
 	int wolenabled;
-#ifdef CONFIG_STMMAC_TIMER
+#ifdef CONFIG_STMMAC_EXT_TIMER
 	struct stmmac_timer *tm;
 #endif
+	unsigned int timer;
 #ifdef STMMAC_VLAN_TAG_USED
 	struct vlan_group *vlgrp;
 #endif
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 26714b4..53a7086 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -122,7 +122,7 @@ MODULE_PARM_DESC(tc, "DMA threshold control value");
 /* Pay attention to tune this parameter; take care of both
  * hardware capability and network stabitily/performance impact.
  * Many tests showed that ~4ms latency seems to be good enough. */
-#ifdef CONFIG_STMMAC_TIMER
+#ifdef CONFIG_STMMAC_EXT_TIMER
 #define DEFAULT_PERIODIC_RATE	256
 static int tmrate = DEFAULT_PERIODIC_RATE;
 module_param(tmrate, int, S_IRUGO | S_IWUSR);
@@ -415,9 +415,9 @@ static void init_dma_desc_rings(struct net_device *dev)
 	else
 		bfsize = DMA_BUFFER_SIZE;
 
-#ifdef CONFIG_STMMAC_TIMER
+#ifdef CONFIG_STMMAC_EXT_TIMER
 	/* Disable interrupts on completion for the reception if timer is on */
-	if (likely(priv->tm->enable))
+	if (likely(priv->timer == external))
 		dis_ic = 1;
 #endif
 	/* If the MTU exceeds 8k so use the second buffer in the chain */
@@ -650,8 +650,8 @@ static void stmmac_tx(struct stmmac_priv *priv)
 
 static inline void stmmac_enable_irq(struct stmmac_priv *priv)
 {
-#ifdef CONFIG_STMMAC_TIMER
-	if (likely(priv->tm->enable))
+#ifdef CONFIG_STMMAC_EXT_TIMER
+	if (likely(priv->timer == external))
 		priv->tm->timer_start(priv->tm->timer_callb, tmrate);
 	else
 #endif
@@ -660,8 +660,8 @@ static inline void stmmac_enable_irq(struct stmmac_priv *priv)
 
 static inline void stmmac_disable_irq(struct stmmac_priv *priv)
 {
-#ifdef CONFIG_STMMAC_TIMER
-	if (likely(priv->tm->enable))
+#ifdef CONFIG_STMMAC_EXT_TIMER
+	if (likely(priv->timer == external))
 		priv->tm->timer_stop(priv->tm->timer_callb);
 	else
 #endif
@@ -693,7 +693,7 @@ static inline void _stmmac_schedule(struct stmmac_priv *priv)
 	}
 }
 
-#ifdef CONFIG_STMMAC_TIMER
+#ifdef CONFIG_STMMAC_EXT_TIMER
 void stmmac_schedule(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
@@ -795,7 +795,7 @@ static int stmmac_open(struct net_device *dev)
 		return ret;
 	}
 
-#ifdef CONFIG_STMMAC_TIMER
+#ifdef CONFIG_STMMAC_EXT_TIMER
 	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
 	if (unlikely(priv->tm == NULL)) {
 		pr_err("%s: ERROR: timer memory alloc failed\n", __func__);
@@ -812,7 +812,7 @@ static int stmmac_open(struct net_device *dev)
 		priv->tm->timer_start = stmmac_no_timer_started;
 		priv->tm->timer_stop = stmmac_no_timer_stopped;
 	} else
-		priv->tm->enable = 1;
+		priv->timer = external;
 #endif
 
 	/* Create and initialize the TX/RX descriptors chains. */
@@ -863,8 +863,8 @@ static int stmmac_open(struct net_device *dev)
 	priv->hw->dma->start_tx(priv->ioaddr);
 	priv->hw->dma->start_rx(priv->ioaddr);
 
-#ifdef CONFIG_STMMAC_TIMER
-	if (likely(priv->tm->enable))
+#ifdef CONFIG_STMMAC_EXT_TIMER
+	if (likely(priv->timer == external))
 		priv->tm->timer_start(priv->tm->timer_callb, tmrate);
 #endif
 	/* Dump DMA/MAC registers */
@@ -901,11 +901,13 @@ static int stmmac_release(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-#ifdef CONFIG_STMMAC_TIMER
+#ifdef CONFIG_STMMAC_EXT_TIMER
 	/* Stop and release the timer */
-	stmmac_close_ext_timer(priv->tm->timer_callb);
-	if (priv->tm != NULL)
+	if (priv->tm != NULL) {
+		if (likely(priv->timer == external))
+			stmmac_close_ext_timer(priv->tm->timer_callb);
 		kfree(priv->tm);
+	}
 #endif
 	napi_disable(&priv->napi);
 	skb_queue_purge(&priv->rx_recycle);
@@ -1096,9 +1098,9 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Interrupt on completition only for the latest segment */
 	priv->hw->desc->close_tx_desc(desc);
 
-#ifdef CONFIG_STMMAC_TIMER
-	/* Clean IC while using timer */
-	if (likely(priv->tm->enable))
+#ifdef CONFIG_STMMAC_EXT_TIMER
+	/* Clean IC while using ext timer */
+	if (likely(priv->timer == external))
 		priv->hw->desc->clear_tx_ic(desc);
 #endif
 	/* To avoid raise condition */
@@ -1815,10 +1817,11 @@ static int stmmac_suspend(struct device *dev)
 	if (priv->phydev)
 		phy_stop(priv->phydev);
 
-#ifdef CONFIG_STMMAC_TIMER
-	priv->tm->timer_stop(priv->tm->timer_callb);
-	if (likely(priv->tm->enable))
+#ifdef CONFIG_STMMAC_EXT_TIMER
+	if (likely(priv->timer == external)) {
+		priv->tm->timer_stop(priv->tm->timer_callb);
 		dis_ic = 1;
+	}
 #endif
 	napi_disable(&priv->napi);
 
@@ -1865,8 +1868,8 @@ static int stmmac_resume(struct device *dev)
 	priv->hw->dma->start_tx(priv->ioaddr);
 	priv->hw->dma->start_rx(priv->ioaddr);
 
-#ifdef CONFIG_STMMAC_TIMER
-	if (likely(priv->tm->enable))
+#ifdef CONFIG_STMMAC_EXT_TIMER
+	if (likely(priv->timer == external))
 		priv->tm->timer_start(priv->tm->timer_callb, tmrate);
 #endif
 	napi_enable(&priv->napi);
@@ -1977,7 +1980,7 @@ static int __init stmmac_cmdline_opt(char *str)
 				       (unsigned long *)&flow_ctrl);
 		else if (!strncmp(opt, "pause:", 6))
 			strict_strtoul(opt + 6, 0, (unsigned long *)&pause);
-#ifdef CONFIG_STMMAC_TIMER
+#ifdef CONFIG_STMMAC_EXT_TIMER
 		else if (!strncmp(opt, "tmrate:", 7))
 			strict_strtoul(opt + 7, 0, (unsigned long *)&tmrate);
 #endif
diff --git a/drivers/net/stmmac/stmmac_timer.c b/drivers/net/stmmac/stmmac_timer.c
index 2481daa..e64db59 100644
--- a/drivers/net/stmmac/stmmac_timer.c
+++ b/drivers/net/stmmac/stmmac_timer.c
@@ -102,7 +102,7 @@ int stmmac_close_ext_timer(void *timer)
 	return 0;
 }
 
-#elif defined(CONFIG_STMMAC_TMU_TIMER)
+#elif defined(CONFIG_STMMAC_GEN_TIMER)
 #include <linux/generictimer.h>
 
 /* Set rate and start the timer */
@@ -131,7 +131,7 @@ int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
 	if (timer == NULL)
 		return -1;
 
-	STMMAC_TIMER_MSG(dev->name, "sh_tmu", tm->freq);
+	STMMAC_TIMER_MSG(dev->name, "Generic", tm->freq);
 
 	tm->timer_callb = timer;
 	tm->timer_start = stmmac_tmu_set_rate;
diff --git a/drivers/net/stmmac/stmmac_timer.h b/drivers/net/stmmac/stmmac_timer.h
index 250f5cb..d719bd5 100644
--- a/drivers/net/stmmac/stmmac_timer.h
+++ b/drivers/net/stmmac/stmmac_timer.h
@@ -26,7 +26,6 @@ struct stmmac_timer {
 	void (*timer_start) (void *timer, unsigned int new_freq);
 	void (*timer_stop) (void *timer);
 	unsigned int freq;
-	unsigned int enable;
 	void *timer_callb;
 };
 
-- 
1.7.4
