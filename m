From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 32/58] isdn/gigaset: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:16 -0700
Message-ID: <1508200182-104605-33-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>, Paul Bolle <pebolle@tiscali.nl>,
        Karsten Keil <isdn@linux-pingi.de>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
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

Cc: Paul Bolle <pebolle@tiscali.nl>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johan Hovold <johan@kernel.org>
Cc: gigaset307x-common@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/isdn/gigaset/bas-gigaset.c | 36 ++++++++++++++++++++----------------
 drivers/isdn/gigaset/common.c      |  7 +++----
 2 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 33151f05e744..c990c6bbffc2 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -433,10 +433,11 @@ static void check_pending(struct bas_cardstate *ucs)
  * argument:
  *	controller state structure
  */
-static void cmd_in_timeout(unsigned long data)
+static void cmd_in_timeout(struct timer_list *t)
 {
-	struct cardstate *cs = (struct cardstate *) data;
-	struct bas_cardstate *ucs = cs->hw.bas;
+	struct bas_cardstate *ucs = from_timer(ucs, t, timer_cmd_in);
+	struct urb *urb = ucs->urb_int_in;
+	struct cardstate *cs = urb->context;
 	int rc;
 
 	if (!ucs->rcvbuf_size) {
@@ -639,10 +640,11 @@ static void int_in_work(struct work_struct *work)
  * argument:
  *	controller state structure
  */
-static void int_in_resubmit(unsigned long data)
+static void int_in_resubmit(struct timer_list *t)
 {
-	struct cardstate *cs = (struct cardstate *) data;
-	struct bas_cardstate *ucs = cs->hw.bas;
+	struct bas_cardstate *ucs = from_timer(ucs, t, timer_int_in);
+	struct urb *urb = ucs->urb_int_in;
+	struct cardstate *cs = urb->context;
 	int rc;
 
 	if (ucs->retry_int_in++ >= BAS_RETRY) {
@@ -1441,10 +1443,11 @@ static void read_iso_tasklet(unsigned long data)
  * argument:
  *	controller state structure
  */
-static void req_timeout(unsigned long data)
+static void req_timeout(struct timer_list *t)
 {
-	struct cardstate *cs = (struct cardstate *) data;
-	struct bas_cardstate *ucs = cs->hw.bas;
+	struct bas_cardstate *ucs = from_timer(ucs, t, timer_ctrl);
+	struct urb *urb = ucs->urb_int_in;
+	struct cardstate *cs = urb->context;
 	int pending;
 	unsigned long flags;
 
@@ -1837,10 +1840,11 @@ static void write_command_callback(struct urb *urb)
  * argument:
  *	controller state structure
  */
-static void atrdy_timeout(unsigned long data)
+static void atrdy_timeout(struct timer_list *t)
 {
-	struct cardstate *cs = (struct cardstate *) data;
-	struct bas_cardstate *ucs = cs->hw.bas;
+	struct bas_cardstate *ucs = from_timer(ucs, t, timer_atrdy);
+	struct urb *urb = ucs->urb_int_in;
+	struct cardstate *cs = urb->context;
 
 	dev_warn(cs->dev, "timeout waiting for HD_READY_SEND_ATDATA\n");
 
@@ -2213,10 +2217,10 @@ static int gigaset_initcshw(struct cardstate *cs)
 	}
 
 	spin_lock_init(&ucs->lock);
-	setup_timer(&ucs->timer_ctrl, req_timeout, (unsigned long) cs);
-	setup_timer(&ucs->timer_atrdy, atrdy_timeout, (unsigned long) cs);
-	setup_timer(&ucs->timer_cmd_in, cmd_in_timeout, (unsigned long) cs);
-	setup_timer(&ucs->timer_int_in, int_in_resubmit, (unsigned long) cs);
+	timer_setup(&ucs->timer_ctrl, req_timeout, 0);
+	timer_setup(&ucs->timer_atrdy, atrdy_timeout, 0);
+	timer_setup(&ucs->timer_cmd_in, cmd_in_timeout, 0);
+	timer_setup(&ucs->timer_int_in, int_in_resubmit, 0);
 	init_waitqueue_head(&ucs->waitqueue);
 	INIT_WORK(&ucs->int_in_wq, int_in_work);
 
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 7c7814497e3e..15482c5de33c 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -153,9 +153,9 @@ static int test_timeout(struct at_state_t *at_state)
 	return 1;
 }
 
-static void timer_tick(unsigned long data)
+static void timer_tick(struct timer_list *t)
 {
-	struct cardstate *cs = (struct cardstate *) data;
+	struct cardstate *cs = from_timer(cs, t, timer);
 	unsigned long flags;
 	unsigned channel;
 	struct at_state_t *at_state;
@@ -687,7 +687,7 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->ignoreframes = ignoreframes;
 	INIT_LIST_HEAD(&cs->temp_at_states);
 	cs->running = 0;
-	init_timer(&cs->timer); /* clear next & prev */
+	timer_setup(&cs->timer, timer_tick, 0);
 	spin_lock_init(&cs->ev_lock);
 	cs->ev_tail = 0;
 	cs->ev_head = 0;
@@ -768,7 +768,6 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	spin_lock_irqsave(&cs->lock, flags);
 	cs->running = 1;
 	spin_unlock_irqrestore(&cs->lock, flags);
-	setup_timer(&cs->timer, timer_tick, (unsigned long) cs);
 	cs->timer.expires = jiffies + msecs_to_jiffies(GIG_TICK);
 	add_timer(&cs->timer);
 
-- 
2.7.4
