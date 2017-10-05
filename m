From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] isdn/gigaset: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:52:12 -0700
Message-ID: <20171005005212.GA23556@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Bolle <pebolle@tiscali.nl>,
        Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Also uses kzmalloc to replace open-
coded field assignments to NULL and zero.

Cc: Paul Bolle <pebolle@tiscali.nl>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johan Hovold <johan@kernel.org>
Cc: gigaset307x-common@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/isdn/gigaset/bas-gigaset.c | 45 ++++++++++++++++++--------------------
 1 file changed, 21 insertions(+), 24 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 2da3ff650e1d..f92a0d972ce7 100644
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
 
@@ -2200,7 +2204,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 {
 	struct bas_cardstate *ucs;
 
-	cs->hw.bas = ucs = kmalloc(sizeof *ucs, GFP_KERNEL);
+	cs->hw.bas = ucs = kzalloc(sizeof *ucs, GFP_KERNEL);
 	if (!ucs) {
 		pr_err("out of memory\n");
 		return -ENOMEM;
@@ -2212,19 +2216,12 @@ static int gigaset_initcshw(struct cardstate *cs)
 		return -ENOMEM;
 	}
 
-	ucs->urb_cmd_in = NULL;
-	ucs->urb_cmd_out = NULL;
-	ucs->rcvbuf = NULL;
-	ucs->rcvbuf_size = 0;
-
 	spin_lock_init(&ucs->lock);
-	ucs->pending = 0;
 
-	ucs->basstate = 0;
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
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
