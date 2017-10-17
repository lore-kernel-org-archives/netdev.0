From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 46/58] hamradio/scc: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:30 -0700
Message-ID: <1508200182-104605-47-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>, Joerg Reuter <jreuter@yaina.de>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Joerg Reuter <jreuter@yaina.de>
Cc: linux-hams@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/hamradio/scc.c | 69 +++++++++++++++++++++++-----------------------
 1 file changed, 35 insertions(+), 34 deletions(-)

diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 295f267b73ea..c9f7215c5dc2 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -185,14 +185,15 @@
 static const char banner[] __initconst = KERN_INFO \
 	"AX.25: Z8530 SCC driver version "VERSION".dl1bke\n";
 
-static void t_dwait(unsigned long);
-static void t_txdelay(unsigned long);
-static void t_tail(unsigned long);
-static void t_busy(unsigned long);
-static void t_maxkeyup(unsigned long);
-static void t_idle(unsigned long);
+static void t_dwait(struct timer_list *t);
+static void t_txdelay(struct timer_list *t);
+static void t_tail(struct timer_list *t);
+static void t_busy(struct timer_list *);
+static void t_maxkeyup(struct timer_list *);
+static void t_idle(struct timer_list *t);
 static void scc_tx_done(struct scc_channel *);
-static void scc_start_tx_timer(struct scc_channel *, void (*)(unsigned long), unsigned long);
+static void scc_start_tx_timer(struct scc_channel *,
+			       void (*)(struct timer_list *), unsigned long);
 static void scc_start_maxkeyup(struct scc_channel *);
 static void scc_start_defer(struct scc_channel *);
 
@@ -992,24 +993,27 @@ static void scc_key_trx(struct scc_channel *scc, char tx)
 
 /* ----> SCC timer interrupt handler and friends. <---- */
 
-static void __scc_start_tx_timer(struct scc_channel *scc, void (*handler)(unsigned long), unsigned long when)
+static void __scc_start_tx_timer(struct scc_channel *scc,
+				 void (*handler)(struct timer_list *t),
+				 unsigned long when)
 {
 	del_timer(&scc->tx_t);
 
 	if (when == 0)
 	{
-		handler((unsigned long) scc);
+		handler(&scc->tx_t);
 	} else 
 	if (when != TIMER_OFF)
 	{
-		scc->tx_t.data = (unsigned long) scc;
-		scc->tx_t.function = handler;
+		scc->tx_t.function = (TIMER_FUNC_TYPE)handler;
 		scc->tx_t.expires = jiffies + (when*HZ)/100;
 		add_timer(&scc->tx_t);
 	}
 }
 
-static void scc_start_tx_timer(struct scc_channel *scc, void (*handler)(unsigned long), unsigned long when)
+static void scc_start_tx_timer(struct scc_channel *scc,
+			       void (*handler)(struct timer_list *t),
+			       unsigned long when)
 {
 	unsigned long flags;
 	
@@ -1027,8 +1031,7 @@ static void scc_start_defer(struct scc_channel *scc)
 	
 	if (scc->kiss.maxdefer != 0 && scc->kiss.maxdefer != TIMER_OFF)
 	{
-		scc->tx_wdog.data = (unsigned long) scc;
-		scc->tx_wdog.function = t_busy;
+		scc->tx_wdog.function = (TIMER_FUNC_TYPE)t_busy;
 		scc->tx_wdog.expires = jiffies + HZ*scc->kiss.maxdefer;
 		add_timer(&scc->tx_wdog);
 	}
@@ -1044,8 +1047,7 @@ static void scc_start_maxkeyup(struct scc_channel *scc)
 	
 	if (scc->kiss.maxkeyup != 0 && scc->kiss.maxkeyup != TIMER_OFF)
 	{
-		scc->tx_wdog.data = (unsigned long) scc;
-		scc->tx_wdog.function = t_maxkeyup;
+		scc->tx_wdog.function = (TIMER_FUNC_TYPE)t_maxkeyup;
 		scc->tx_wdog.expires = jiffies + HZ*scc->kiss.maxkeyup;
 		add_timer(&scc->tx_wdog);
 	}
@@ -1121,9 +1123,9 @@ static inline int is_grouped(struct scc_channel *scc)
  * fulldup == 2:  mintime expired, reset status or key trx and start txdelay
  */
 
-static void t_dwait(unsigned long channel)
+static void t_dwait(struct timer_list *t)
 {
-	struct scc_channel *scc = (struct scc_channel *) channel;
+	struct scc_channel *scc = from_timer(scc, t, tx_t);
 	
 	if (scc->stat.tx_state == TXS_WAIT)	/* maxkeyup or idle timeout */
 	{
@@ -1163,9 +1165,9 @@ static void t_dwait(unsigned long channel)
  * kick transmission by a fake scc_txint(scc), start 'maxkeyup' watchdog.
  */
 
-static void t_txdelay(unsigned long channel)
+static void t_txdelay(struct timer_list *t)
 {
-	struct scc_channel *scc = (struct scc_channel *) channel;
+	struct scc_channel *scc = from_timer(scc, t, tx_t);
 
 	scc_start_maxkeyup(scc);
 
@@ -1184,9 +1186,9 @@ static void t_txdelay(unsigned long channel)
  * transmission after 'mintime' seconds
  */
 
-static void t_tail(unsigned long channel)
+static void t_tail(struct timer_list *t)
 {
-	struct scc_channel *scc = (struct scc_channel *) channel;
+	struct scc_channel *scc = from_timer(scc, t, tx_t);
 	unsigned long flags;
 	
 	spin_lock_irqsave(&scc->lock, flags); 
@@ -1211,9 +1213,9 @@ static void t_tail(unsigned long channel)
  * throw away send buffers if DCD remains active too long.
  */
 
-static void t_busy(unsigned long channel)
+static void t_busy(struct timer_list *t)
 {
-	struct scc_channel *scc = (struct scc_channel *) channel;
+	struct scc_channel *scc = from_timer(scc, t, tx_wdog);
 
 	del_timer(&scc->tx_t);
 	netif_stop_queue(scc->dev);	/* don't pile on the wabbit! */
@@ -1230,9 +1232,9 @@ static void t_busy(unsigned long channel)
  * this is our watchdog.
  */
 
-static void t_maxkeyup(unsigned long channel)
+static void t_maxkeyup(struct timer_list *t)
 {
-	struct scc_channel *scc = (struct scc_channel *) channel;
+	struct scc_channel *scc = from_timer(scc, t, tx_wdog);
 	unsigned long flags;
 
 	spin_lock_irqsave(&scc->lock, flags);
@@ -1264,9 +1266,9 @@ static void t_maxkeyup(unsigned long channel)
  * expires.
  */
 
-static void t_idle(unsigned long channel)
+static void t_idle(struct timer_list *t)
 {
-	struct scc_channel *scc = (struct scc_channel *) channel;
+	struct scc_channel *scc = from_timer(scc, t, tx_t);
 	
 	del_timer(&scc->tx_wdog);
 
@@ -1397,9 +1399,9 @@ static unsigned long scc_get_param(struct scc_channel *scc, unsigned int cmd)
 /* *			Send calibration pattern		     * */
 /* ******************************************************************* */
 
-static void scc_stop_calibrate(unsigned long channel)
+static void scc_stop_calibrate(struct timer_list *t)
 {
-	struct scc_channel *scc = (struct scc_channel *) channel;
+	struct scc_channel *scc = from_timer(scc, t, tx_wdog);
 	unsigned long flags;
 	
 	spin_lock_irqsave(&scc->lock, flags);
@@ -1426,8 +1428,7 @@ scc_start_calibrate(struct scc_channel *scc, int duration, unsigned char pattern
 
 	del_timer(&scc->tx_wdog);
 
-	scc->tx_wdog.data = (unsigned long) scc;
-	scc->tx_wdog.function = scc_stop_calibrate;
+	scc->tx_wdog.function = (TIMER_FUNC_TYPE)scc_stop_calibrate;
 	scc->tx_wdog.expires = jiffies + HZ*duration;
 	add_timer(&scc->tx_wdog);
 
@@ -1522,8 +1523,8 @@ static int scc_net_alloc(const char *name, struct scc_channel *scc)
 	dev->ml_priv = scc;
 	scc->dev = dev;
 	spin_lock_init(&scc->lock);
-	init_timer(&scc->tx_t);
-	init_timer(&scc->tx_wdog);
+	timer_setup(&scc->tx_t, NULL, 0);
+	timer_setup(&scc->tx_wdog, NULL, 0);
 
 	err = register_netdevice(dev);
 	if (err) {
-- 
2.7.4

