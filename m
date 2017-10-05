From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mISDN: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:52:07 -0700
Message-ID: <20171005005207.GA23542@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
        Geliang Tang <geliangtang@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Anton Vasilyev <vasilyev@ispras.ru>,
        Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Geliang Tang <geliangtang@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Anton Vasilyev <vasilyev@ispras.ru>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/isdn/mISDN/dsp.h        |  2 +-
 drivers/isdn/mISDN/dsp_core.c   |  6 ++----
 drivers/isdn/mISDN/dsp_tones.c  |  4 ++--
 drivers/isdn/mISDN/fsm.c        |  5 +++--
 drivers/isdn/mISDN/l1oip_core.c | 15 +++++++--------
 drivers/isdn/mISDN/timerdev.c   |  6 +++---
 6 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp.h b/drivers/isdn/mISDN/dsp.h
index fc1733a08845..fa09d511a8ed 100644
--- a/drivers/isdn/mISDN/dsp.h
+++ b/drivers/isdn/mISDN/dsp.h
@@ -259,7 +259,7 @@ extern u8 *dsp_dtmf_goertzel_decode(struct dsp *dsp, u8 *data, int len,
 
 extern int dsp_tone(struct dsp *dsp, int tone);
 extern void dsp_tone_copy(struct dsp *dsp, u8 *data, int len);
-extern void dsp_tone_timeout(void *arg);
+extern void dsp_tone_timeout(struct timer_list *t);
 
 extern void dsp_bf_encrypt(struct dsp *dsp, u8 *data, int len);
 extern void dsp_bf_decrypt(struct dsp *dsp, u8 *data, int len);
diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index 880e9d367a39..cd036e87335a 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -1092,7 +1092,7 @@ dspcreate(struct channel_req *crq)
 	ndsp->pcm_bank_tx = -1;
 	ndsp->hfc_conf = -1; /* current conference number */
 	/* set tone timer */
-	setup_timer(&ndsp->tone.tl, (void *)dsp_tone_timeout, (long)ndsp);
+	timer_setup(&ndsp->tone.tl, dsp_tone_timeout, 0);
 
 	if (dtmfthreshold < 20 || dtmfthreshold > 500)
 		dtmfthreshold = 200;
@@ -1202,9 +1202,7 @@ static int __init dsp_init(void)
 	}
 
 	/* set sample timer */
-	dsp_spl_tl.function = (void *)dsp_cmx_send;
-	dsp_spl_tl.data = 0;
-	init_timer(&dsp_spl_tl);
+	timer_setup(&dsp_spl_tl, (void *)dsp_cmx_send, 0);
 	dsp_spl_tl.expires = jiffies + dsp_tics;
 	dsp_spl_jiffies = dsp_spl_tl.expires;
 	add_timer(&dsp_spl_tl);
diff --git a/drivers/isdn/mISDN/dsp_tones.c b/drivers/isdn/mISDN/dsp_tones.c
index 057e0d6a369b..263e8886703d 100644
--- a/drivers/isdn/mISDN/dsp_tones.c
+++ b/drivers/isdn/mISDN/dsp_tones.c
@@ -457,9 +457,9 @@ dsp_tone_hw_message(struct dsp *dsp, u8 *sample, int len)
  * timer expires *
  *****************/
 void
-dsp_tone_timeout(void *arg)
+dsp_tone_timeout(struct timer_list *t)
 {
-	struct dsp *dsp = arg;
+	struct dsp *dsp = from_timer(dsp, t, tone.tl);
 	struct dsp_tone *tone = &dsp->tone;
 	struct pattern *pat = (struct pattern *)tone->pattern;
 	int index = tone->index;
diff --git a/drivers/isdn/mISDN/fsm.c b/drivers/isdn/mISDN/fsm.c
index 92e6570b1143..613df2638eab 100644
--- a/drivers/isdn/mISDN/fsm.c
+++ b/drivers/isdn/mISDN/fsm.c
@@ -100,8 +100,9 @@ mISDN_FsmChangeState(struct FsmInst *fi, int newstate)
 EXPORT_SYMBOL(mISDN_FsmChangeState);
 
 static void
-FsmExpireTimer(struct FsmTimer *ft)
+FsmExpireTimer(struct timer_list *t)
 {
+	struct FsmTimer *ft = from_timer(ft, t, tl);
 #if FSM_TIMER_DEBUG
 	if (ft->fi->debug)
 		ft->fi->printdebug(ft->fi, "FsmExpireTimer %lx", (long) ft);
@@ -117,7 +118,7 @@ mISDN_FsmInitTimer(struct FsmInst *fi, struct FsmTimer *ft)
 	if (ft->fi->debug)
 		ft->fi->printdebug(ft->fi, "mISDN_FsmInitTimer %lx", (long) ft);
 #endif
-	setup_timer(&ft->tl, (void *)FsmExpireTimer, (long)ft);
+	timer_setup(&ft->tl, FsmExpireTimer, 0);
 }
 EXPORT_SYMBOL(mISDN_FsmInitTimer);
 
diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index 6be2041248d3..b5d590e378ac 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -842,17 +842,18 @@ l1oip_send_bh(struct work_struct *work)
  * timer stuff
  */
 static void
-l1oip_keepalive(void *data)
+l1oip_keepalive(struct timer_list *t)
 {
-	struct l1oip *hc = (struct l1oip *)data;
+	struct l1oip *hc = from_timer(hc, t, keep_tl);
 
 	schedule_work(&hc->workq);
 }
 
 static void
-l1oip_timeout(void *data)
+l1oip_timeout(struct timer_list *t)
 {
-	struct l1oip			*hc = (struct l1oip *)data;
+	struct l1oip			*hc = from_timer(hc, t,
+								  timeout_tl);
 	struct dchannel		*dch = hc->chan[hc->d_idx].dch;
 
 	if (debug & DEBUG_L1OIP_MSG)
@@ -1437,13 +1438,11 @@ init_card(struct l1oip *hc, int pri, int bundle)
 	if (ret)
 		return ret;
 
-	hc->keep_tl.function = (void *)l1oip_keepalive;
-	hc->keep_tl.data = (ulong)hc;
-	init_timer(&hc->keep_tl);
+	timer_setup(&hc->keep_tl, l1oip_keepalive, 0);
 	hc->keep_tl.expires = jiffies + 2 * HZ; /* two seconds first time */
 	add_timer(&hc->keep_tl);
 
-	setup_timer(&hc->timeout_tl, (void *)l1oip_timeout, (ulong)hc);
+	timer_setup(&hc->timeout_tl, l1oip_timeout, 0);
 	hc->timeout_on = 0; /* state that we have timer off */
 
 	return 0;
diff --git a/drivers/isdn/mISDN/timerdev.c b/drivers/isdn/mISDN/timerdev.c
index b1e135fc1fb5..c50a34340f67 100644
--- a/drivers/isdn/mISDN/timerdev.c
+++ b/drivers/isdn/mISDN/timerdev.c
@@ -162,9 +162,9 @@ mISDN_poll(struct file *filep, poll_table *wait)
 }
 
 static void
-dev_expire_timer(unsigned long data)
+dev_expire_timer(struct timer_list *t)
 {
-	struct mISDNtimer *timer = (void *)data;
+	struct mISDNtimer *timer = from_timer(timer, t, tl);
 	u_long			flags;
 
 	spin_lock_irqsave(&timer->dev->lock, flags);
@@ -189,7 +189,7 @@ misdn_add_timer(struct mISDNtimerdev *dev, int timeout)
 		if (!timer)
 			return -ENOMEM;
 		timer->dev = dev;
-		setup_timer(&timer->tl, dev_expire_timer, (long)timer);
+		timer_setup(&timer->tl, dev_expire_timer, 0);
 		spin_lock_irq(&dev->lock);
 		id = timer->id = dev->next_id++;
 		if (dev->next_id < 0)
-- 
2.7.4


-- 
Kees Cook
Pixel Security
