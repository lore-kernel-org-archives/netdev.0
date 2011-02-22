From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net-2.6) 3/4] stmmac: switch to use the new generic timer
 interface
Date: Tue, 22 Feb 2011 11:17:43 +0100
Message-ID: <1298369864-24429-4-git-send-email-peppe.cavallaro@st.com>
References: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stuart MENEFY <stuart.menefy@st.com>,
	Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1298369864-24429-1-git-send-email-peppe.cavallaro@st.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The stmmac can use an external timer for mitigating
the number of interrupts.
On SH4 platforms based this can be done by using the
TMU channel 2 interrupt.
This actually helps many people to save the CPU usage
on platforms with MAC10/100 and GMAC devices without
an embedded timer.

This patch removes the old code (obsoleted and only
valid for old STM Kernels) and uses the new generic
timer interface.

Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig        |    1 -
 drivers/net/stmmac/stmmac_main.c  |   21 ++++----
 drivers/net/stmmac/stmmac_timer.c |  101 +++++++++++++++++++++---------------
 drivers/net/stmmac/stmmac_timer.h |   11 ++---
 4 files changed, 74 insertions(+), 60 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index 7df7df4..b74e79b 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -32,7 +32,6 @@ config STMMAC_DUAL_MAC
 config STMMAC_TIMER
 	bool "STMMAC Timer optimisation"
 	default n
-	depends on RTC_HCTOSYS_DEVICE
 	help
 	  Use an external timer for mitigating the number of network
 	  interrupts. Currently, for SH architectures, it is possible
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 34a0af3..26714b4 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -652,7 +652,7 @@ static inline void stmmac_enable_irq(struct stmmac_priv *priv)
 {
 #ifdef CONFIG_STMMAC_TIMER
 	if (likely(priv->tm->enable))
-		priv->tm->timer_start(tmrate);
+		priv->tm->timer_start(priv->tm->timer_callb, tmrate);
 	else
 #endif
 		priv->hw->dma->enable_dma_irq(priv->ioaddr);
@@ -662,7 +662,7 @@ static inline void stmmac_disable_irq(struct stmmac_priv *priv)
 {
 #ifdef CONFIG_STMMAC_TIMER
 	if (likely(priv->tm->enable))
-		priv->tm->timer_stop();
+		priv->tm->timer_stop(priv->tm->timer_callb);
 	else
 #endif
 		priv->hw->dma->disable_dma_irq(priv->ioaddr);
@@ -703,11 +703,11 @@ void stmmac_schedule(struct net_device *dev)
 	_stmmac_schedule(priv);
 }
 
-static void stmmac_no_timer_started(unsigned int x)
+static void stmmac_no_timer_started(void *t, unsigned int x)
 {;
 };
 
-static void stmmac_no_timer_stopped(void)
+static void stmmac_no_timer_stopped(void *t)
 {;
 };
 #endif
@@ -720,7 +720,6 @@ static void stmmac_no_timer_stopped(void)
  */
 static void stmmac_tx_err(struct stmmac_priv *priv)
 {
-
 	netif_stop_queue(priv->dev);
 
 	priv->hw->dma->stop_tx(priv->ioaddr);
@@ -807,7 +806,8 @@ static int stmmac_open(struct net_device *dev)
 	/* Test if the external timer can be actually used.
 	 * In case of failure continue without timer. */
 	if (unlikely((stmmac_open_ext_timer(dev, priv->tm)) < 0)) {
-		pr_warning("stmmaceth: cannot attach the external timer.\n");
+		pr_warning("stmmac (%s): cannot attach the external timer.\n",
+			   dev->name);
 		priv->tm->freq = 0;
 		priv->tm->timer_start = stmmac_no_timer_started;
 		priv->tm->timer_stop = stmmac_no_timer_stopped;
@@ -864,7 +864,8 @@ static int stmmac_open(struct net_device *dev)
 	priv->hw->dma->start_rx(priv->ioaddr);
 
 #ifdef CONFIG_STMMAC_TIMER
-	priv->tm->timer_start(tmrate);
+	if (likely(priv->tm->enable))
+		priv->tm->timer_start(priv->tm->timer_callb, tmrate);
 #endif
 	/* Dump DMA/MAC registers */
 	if (netif_msg_hw(priv)) {
@@ -902,7 +903,7 @@ static int stmmac_release(struct net_device *dev)
 
 #ifdef CONFIG_STMMAC_TIMER
 	/* Stop and release the timer */
-	stmmac_close_ext_timer();
+	stmmac_close_ext_timer(priv->tm->timer_callb);
 	if (priv->tm != NULL)
 		kfree(priv->tm);
 #endif
@@ -1815,7 +1816,7 @@ static int stmmac_suspend(struct device *dev)
 		phy_stop(priv->phydev);
 
 #ifdef CONFIG_STMMAC_TIMER
-	priv->tm->timer_stop();
+	priv->tm->timer_stop(priv->tm->timer_callb);
 	if (likely(priv->tm->enable))
 		dis_ic = 1;
 #endif
@@ -1866,7 +1867,7 @@ static int stmmac_resume(struct device *dev)
 
 #ifdef CONFIG_STMMAC_TIMER
 	if (likely(priv->tm->enable))
-		priv->tm->timer_start(tmrate);
+		priv->tm->timer_start(priv->tm->timer_callb, tmrate);
 #endif
 	napi_enable(&priv->napi);
 
diff --git a/drivers/net/stmmac/stmmac_timer.c b/drivers/net/stmmac/stmmac_timer.c
index 2a0e1ab..2481daa 100644
--- a/drivers/net/stmmac/stmmac_timer.c
+++ b/drivers/net/stmmac/stmmac_timer.c
@@ -33,102 +33,119 @@ static void stmmac_timer_handler(void *data)
 	stmmac_schedule(dev);
 }
 
-#define STMMAC_TIMER_MSG(timer, freq) \
-printk(KERN_INFO "stmmac_timer: %s Timer ON (freq %dHz)\n", timer, freq);
+#define STMMAC_TIMER_MSG(dev_name, timer, freq) \
+printk(KERN_INFO "stmmac_timer: (%s) %s Timer (freq %dHz)\n", \
+		 dev_name, timer, freq);
 
 #if defined(CONFIG_STMMAC_RTC_TIMER)
 #include <linux/rtc.h>
-static struct rtc_device *stmmac_rtc;
-static rtc_task_t stmmac_task;
 
-static void stmmac_rtc_start(unsigned int new_freq)
+static void stmmac_rtc_start(void *timer, unsigned int new_freq)
 {
-	rtc_irq_set_freq(stmmac_rtc, &stmmac_task, new_freq);
-	rtc_irq_set_state(stmmac_rtc, &stmmac_task, 1);
+	struct rtc_device *rtc = timer;
+
+	rtc_irq_set_freq(rtc, rtc->irq_task, new_freq);
+	rtc_irq_set_state(rtc, rtc->irq_task, 1);
+	return;
 }
 
-static void stmmac_rtc_stop(void)
+static void stmmac_rtc_stop(void *timer)
 {
-	rtc_irq_set_state(stmmac_rtc, &stmmac_task, 0);
+	struct rtc_device *rtc = timer;
+
+	rtc_irq_set_state(rtc, rtc->irq_task, 0);
+	return;
 }
 
 int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
 {
-	stmmac_task.private_data = dev;
-	stmmac_task.func = stmmac_timer_handler;
+	struct rtc_device *rtc;
+	rtc_task_t rtc_task;
+
+	rtc_task.private_data = dev;
+	rtc_task.func = stmmac_timer_handler;
 
-	stmmac_rtc = rtc_class_open(CONFIG_RTC_HCTOSYS_DEVICE);
-	if (stmmac_rtc == NULL) {
+	rtc = rtc_class_open(CONFIG_RTC_HCTOSYS_DEVICE);
+	if (rtc == NULL) {
 		pr_err("open rtc device failed\n");
 		return -ENODEV;
 	}
 
-	rtc_irq_register(stmmac_rtc, &stmmac_task);
+	rtc_irq_register(rtc, &rtc_task);
 
 	/* Periodic mode is not supported */
-	if ((rtc_irq_set_freq(stmmac_rtc, &stmmac_task, tm->freq) < 0)) {
+	if ((rtc_irq_set_freq(rtc, &rtc_task, tm->freq) < 0)) {
 		pr_err("set periodic failed\n");
-		rtc_irq_unregister(stmmac_rtc, &stmmac_task);
-		rtc_class_close(stmmac_rtc);
+		rtc_irq_unregister(rtc, &rtc_task);
+		rtc_class_close(rtc);
 		return -1;
 	}
 
-	STMMAC_TIMER_MSG(CONFIG_RTC_HCTOSYS_DEVICE, tm->freq);
+	STMMAC_TIMER_MSG(dev->name, CONFIG_RTC_HCTOSYS_DEVICE, tm->freq);
 
+	rtc->irq_task = &rtc_task;
+	tm->timer_callb = rtc;
 	tm->timer_start = stmmac_rtc_start;
 	tm->timer_stop = stmmac_rtc_stop;
 
 	return 0;
 }
 
-int stmmac_close_ext_timer(void)
+int stmmac_close_ext_timer(void *timer)
 {
-	rtc_irq_set_state(stmmac_rtc, &stmmac_task, 0);
-	rtc_irq_unregister(stmmac_rtc, &stmmac_task);
-	rtc_class_close(stmmac_rtc);
+	struct rtc_device *rtc = timer;
+
+	rtc_irq_set_state(rtc, rtc->irq_task, 0);
+	rtc_irq_unregister(rtc, rtc->irq_task);
+	rtc_class_close(rtc);
+
 	return 0;
 }
 
 #elif defined(CONFIG_STMMAC_TMU_TIMER)
-#include <linux/clk.h>
-#define TMU_CHANNEL "tmu2_clk"
-static struct clk *timer_clock;
+#include <linux/generictimer.h>
 
-static void stmmac_tmu_start(unsigned int new_freq)
+/* Set rate and start the timer */
+static void stmmac_tmu_set_rate(void *timer_callb, unsigned int new_freq)
 {
-	clk_set_rate(timer_clock, new_freq);
-	clk_enable(timer_clock);
+	struct generic_timer *timer = timer_callb;
+
+	generic_timer_start(timer);
+	generic_timer_set_rate(timer, new_freq);
+	return;
 }
 
-static void stmmac_tmu_stop(void)
+static void stmmac_tmu_stop(void *timer_callb)
 {
-	clk_disable(timer_clock);
+	struct generic_timer *timer = timer_callb;
+
+	generic_timer_stop(timer);
+	return;
 }
 
 int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
 {
-	timer_clock = clk_get(NULL, TMU_CHANNEL);
+	struct generic_timer *timer;
+	timer = generic_timer_claim(stmmac_timer_handler,  dev);
 
-	if (timer_clock == NULL)
+	if (timer == NULL)
 		return -1;
 
-	if (tmu2_register_user(stmmac_timer_handler, (void *)dev) < 0) {
-		timer_clock = NULL;
-		return -1;
-	}
+	STMMAC_TIMER_MSG(dev->name, "sh_tmu", tm->freq);
 
-	STMMAC_TIMER_MSG("TMU2", tm->freq);
-	tm->timer_start = stmmac_tmu_start;
+	tm->timer_callb = timer;
+	tm->timer_start = stmmac_tmu_set_rate;
 	tm->timer_stop = stmmac_tmu_stop;
 
 	return 0;
 }
 
-int stmmac_close_ext_timer(void)
+int stmmac_close_ext_timer(void *timer_callb)
 {
-	clk_disable(timer_clock);
-	tmu2_unregister_user();
-	clk_put(timer_clock);
+	struct generic_timer *timer = timer_callb;
+
+	stmmac_tmu_stop(timer_callb);
+	generic_timer_release(timer);
 	return 0;
 }
 #endif
diff --git a/drivers/net/stmmac/stmmac_timer.h b/drivers/net/stmmac/stmmac_timer.h
index 6863590..250f5cb 100644
--- a/drivers/net/stmmac/stmmac_timer.h
+++ b/drivers/net/stmmac/stmmac_timer.h
@@ -23,20 +23,17 @@
 *******************************************************************************/
 
 struct stmmac_timer {
-	void (*timer_start) (unsigned int new_freq);
-	void (*timer_stop) (void);
+	void (*timer_start) (void *timer, unsigned int new_freq);
+	void (*timer_stop) (void *timer);
 	unsigned int freq;
 	unsigned int enable;
+	void *timer_callb;
 };
 
 /* Open the HW timer device and return 0 in case of success */
 int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm);
 /* Stop the timer and release it */
-int stmmac_close_ext_timer(void);
+int stmmac_close_ext_timer(void *priv);
 /* Function used for scheduling task within the stmmac */
 void stmmac_schedule(struct net_device *dev);
 
-#if defined(CONFIG_STMMAC_TMU_TIMER)
-extern int tmu2_register_user(void *fnt, void *data);
-extern void tmu2_unregister_user(void);
-#endif
-- 
1.7.4
