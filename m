From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] isdn/gigaset: Provide cardstate context for bas timer
 callbacks
Date: Fri, 20 Oct 2017 13:47:08 -0700
Message-ID: <20171020204708.GA58150@beast>
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

While the work callback uses the urb to find cardstate from bas_cardstate,
this may not be valid for timer callbacks. Instead, introduce a direct
pointer back to the cardstate from bas_cardstate for use in timer
callbacks.

Reported-by: Paul Bolle <pebolle@tiscali.nl>
Fixes: 4cfea08e6251 ("isdn/gigaset: Convert timers to use timer_setup()")
Cc: Paul Bolle <pebolle@tiscali.nl>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johan Hovold <johan@kernel.org>
Cc: gigaset307x-common@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/isdn/gigaset/bas-gigaset.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index c990c6bbffc2..20d0a080a2b0 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -89,6 +89,7 @@ static int start_cbsend(struct cardstate *);
 
 struct bas_cardstate {
 	struct usb_device	*udev;		/* USB device pointer */
+	struct cardstate	*cs;
 	struct usb_interface	*interface;	/* interface for this device */
 	unsigned char		minor;		/* starting minor number */
 
@@ -436,8 +437,7 @@ static void check_pending(struct bas_cardstate *ucs)
 static void cmd_in_timeout(struct timer_list *t)
 {
 	struct bas_cardstate *ucs = from_timer(ucs, t, timer_cmd_in);
-	struct urb *urb = ucs->urb_int_in;
-	struct cardstate *cs = urb->context;
+	struct cardstate *cs = ucs->cs;
 	int rc;
 
 	if (!ucs->rcvbuf_size) {
@@ -643,8 +643,7 @@ static void int_in_work(struct work_struct *work)
 static void int_in_resubmit(struct timer_list *t)
 {
 	struct bas_cardstate *ucs = from_timer(ucs, t, timer_int_in);
-	struct urb *urb = ucs->urb_int_in;
-	struct cardstate *cs = urb->context;
+	struct cardstate *cs = ucs->cs;
 	int rc;
 
 	if (ucs->retry_int_in++ >= BAS_RETRY) {
@@ -1446,8 +1445,7 @@ static void read_iso_tasklet(unsigned long data)
 static void req_timeout(struct timer_list *t)
 {
 	struct bas_cardstate *ucs = from_timer(ucs, t, timer_ctrl);
-	struct urb *urb = ucs->urb_int_in;
-	struct cardstate *cs = urb->context;
+	struct cardstate *cs = ucs->cs;
 	int pending;
 	unsigned long flags;
 
@@ -1843,8 +1841,7 @@ static void write_command_callback(struct urb *urb)
 static void atrdy_timeout(struct timer_list *t)
 {
 	struct bas_cardstate *ucs = from_timer(ucs, t, timer_atrdy);
-	struct urb *urb = ucs->urb_int_in;
-	struct cardstate *cs = urb->context;
+	struct cardstate *cs = ucs->cs;
 
 	dev_warn(cs->dev, "timeout waiting for HD_READY_SEND_ATDATA\n");
 
@@ -2217,6 +2214,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 	}
 
 	spin_lock_init(&ucs->lock);
+	ucs->cs = cs;
 	timer_setup(&ucs->timer_ctrl, req_timeout, 0);
 	timer_setup(&ucs->timer_atrdy, atrdy_timeout, 0);
 	timer_setup(&ucs->timer_cmd_in, cmd_in_timeout, 0);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
