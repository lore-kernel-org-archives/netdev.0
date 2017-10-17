From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 30/58] mISDN: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:14 -0700
Message-ID: <1508200182-104605-31-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        Geliang Tang <geliangtang@gmail.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Anton Vasilyev <vasilyev@ispras.ru>,
        Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
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
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/isdn/hardware/mISDN/mISDNipac.c |  7 +++----
 drivers/isdn/hardware/mISDN/w6692.c     |  7 +++----
 drivers/isdn/mISDN/dsp.h                |  2 +-
 drivers/isdn/mISDN/dsp_core.c           |  6 ++----
 drivers/isdn/mISDN/dsp_tones.c          |  6 ++----
 drivers/isdn/mISDN/fsm.c                |  7 +++----
 drivers/isdn/mISDN/l1oip_core.c         | 15 +++++++--------
 drivers/isdn/mISDN/timerdev.c           |  6 +++---
 8 files changed, 24 insertions(+), 32 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index e240010b93fa..4d78f870435e 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -172,7 +172,6 @@ isac_fill_fifo(struct isac_hw *isac)
 		pr_debug("%s: %s dbusytimer running\n", isac->name, __func__);
 		del_timer(&isac->dch.timer);
 	}
-	init_timer(&isac->dch.timer);
 	isac->dch.timer.expires = jiffies + ((DBUSY_TIMER_VALUE * HZ)/1000);
 	add_timer(&isac->dch.timer);
 	if (isac->dch.debug & DEBUG_HW_DFIFO) {
@@ -727,8 +726,9 @@ isac_release(struct isac_hw *isac)
 }
 
 static void
-dbusy_timer_handler(struct isac_hw *isac)
+dbusy_timer_handler(struct timer_list *t)
 {
+	struct isac_hw *isac = from_timer(isac, t, dch.timer);
 	int rbch, star;
 	u_long flags;
 
@@ -796,8 +796,7 @@ isac_init(struct isac_hw *isac)
 	}
 	isac->mon_tx = NULL;
 	isac->mon_rx = NULL;
-	setup_timer(&isac->dch.timer, (void *)dbusy_timer_handler,
-		    (long)isac);
+	timer_setup(&isac->dch.timer, dbusy_timer_handler, 0);
 	isac->mocr = 0xaa;
 	if (isac->type & IPAC_TYPE_ISACX) {
 		/* Disable all IRQ */
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index d80072fef434..536d5137f49d 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -311,7 +311,6 @@ W6692_fill_Dfifo(struct w6692_hw *card)
 		pr_debug("%s: fill_Dfifo dbusytimer running\n", card->name);
 		del_timer(&dch->timer);
 	}
-	init_timer(&dch->timer);
 	dch->timer.expires = jiffies + ((DBUSY_TIMER_VALUE * HZ) / 1000);
 	add_timer(&dch->timer);
 	if (debug & DEBUG_HW_DFIFO) {
@@ -819,8 +818,9 @@ w6692_irq(int intno, void *dev_id)
 }
 
 static void
-dbusy_timer_handler(struct dchannel *dch)
+dbusy_timer_handler(struct timer_list *t)
 {
+	struct dchannel *dch = from_timer(dch, t, timer);
 	struct w6692_hw	*card = dch->hw;
 	int		rbch, star;
 	u_long		flags;
@@ -852,8 +852,7 @@ static void initW6692(struct w6692_hw *card)
 {
 	u8	val;
 
-	setup_timer(&card->dch.timer, (void *)dbusy_timer_handler,
-		    (u_long)&card->dch);
+	timer_setup(&card->dch.timer, dbusy_timer_handler, 0);
 	w6692_mode(&card->bc[0], ISDN_P_NONE);
 	w6692_mode(&card->bc[1], ISDN_P_NONE);
 	WriteW6692(card, W_D_CTL, 0x00);
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
index 057e0d6a369b..8389e2105cdc 100644
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
@@ -478,7 +478,6 @@ dsp_tone_timeout(void *arg)
 	else
 		dsp_tone_hw_message(dsp, pat->data[index], *(pat->siz[index]));
 	/* set timer */
-	init_timer(&tone->tl);
 	tone->tl.expires = jiffies + (pat->seq[index] * HZ) / 8000;
 	add_timer(&tone->tl);
 }
@@ -541,7 +540,6 @@ dsp_tone(struct dsp *dsp, int tone)
 		/* set timer */
 		if (timer_pending(&tonet->tl))
 			del_timer(&tonet->tl);
-		init_timer(&tonet->tl);
 		tonet->tl.expires = jiffies + (pat->seq[0] * HZ) / 8000;
 		add_timer(&tonet->tl);
 	} else {
diff --git a/drivers/isdn/mISDN/fsm.c b/drivers/isdn/mISDN/fsm.c
index 92e6570b1143..cabcb906e0b5 100644
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
 
@@ -153,7 +154,6 @@ mISDN_FsmAddTimer(struct FsmTimer *ft,
 		}
 		return -1;
 	}
-	init_timer(&ft->tl);
 	ft->event = event;
 	ft->arg = arg;
 	ft->tl.expires = jiffies + (millisec * HZ) / 1000;
@@ -175,7 +175,6 @@ mISDN_FsmRestartTimer(struct FsmTimer *ft,
 
 	if (timer_pending(&ft->tl))
 		del_timer(&ft->tl);
-	init_timer(&ft->tl);
 	ft->event = event;
 	ft->arg = arg;
 	ft->tl.expires = jiffies + (millisec * HZ) / 1000;
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
