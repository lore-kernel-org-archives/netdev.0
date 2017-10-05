From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2] isdn/gigaset: Convert timers to use timer_setup()
Date: Thu, 5 Oct 2017 12:31:18 -0700
Message-ID: <20171005193118.GA105874@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
        "David S. Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>, linux-kernel@vger.kernel.org,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
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
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.

v2:
- split kzalloc() into a separate patch; pebolle.
---
 drivers/isdn/gigaset/bas-gigaset.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

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
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
