From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/atm/suni: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:51:11 -0700
Message-ID: <20171005005111.GA23374@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chas Williams <3chas3@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Passes NULL timer when doing non-
timer call.

Cc: Chas Williams <3chas3@gmail.com>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/atm/suni.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/atm/suni.c b/drivers/atm/suni.c
index b0363149b2fd..b8825f2d79e0 100644
--- a/drivers/atm/suni.c
+++ b/drivers/atm/suni.c
@@ -53,7 +53,7 @@ static DEFINE_SPINLOCK(sunis_lock);
     if (atomic_read(&stats->s) < 0) atomic_set(&stats->s,INT_MAX);
 
 
-static void suni_hz(unsigned long from_timer)
+static void suni_hz(struct timer_list *timer)
 {
 	struct suni_priv *walk;
 	struct atm_dev *dev;
@@ -85,7 +85,7 @@ static void suni_hz(unsigned long from_timer)
 		    ((GET(TACP_TCC) & 0xff) << 8) |
 		    ((GET(TACP_TCCM) & 7) << 16));
 	}
-	if (from_timer) mod_timer(&poll_timer,jiffies+HZ);
+	if (timer) mod_timer(&poll_timer,jiffies+HZ);
 }
 
 
@@ -322,13 +322,11 @@ static int suni_start(struct atm_dev *dev)
 		printk(KERN_WARNING "%s(itf %d): no signal\n",dev->type,
 		    dev->number);
 	PRIV(dev)->loop_mode = ATM_LM_NONE;
-	suni_hz(0); /* clear SUNI counters */
+	suni_hz(NULL); /* clear SUNI counters */
 	(void) fetch_stats(dev,NULL,1); /* clear kernel counters */
 	if (first) {
-		init_timer(&poll_timer);
+		timer_setup(&poll_timer, suni_hz, 0);
 		poll_timer.expires = jiffies+HZ;
-		poll_timer.function = suni_hz;
-		poll_timer.data = 1;
 #if 0
 printk(KERN_DEBUG "[u] p=0x%lx,n=0x%lx\n",(unsigned long) poll_timer.list.prev,
     (unsigned long) poll_timer.list.next);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
