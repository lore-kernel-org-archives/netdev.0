From: Anna-Maria Gleixner <anna-maria@linutronix.de>
Subject: [PATCH 24/25] net/cdc_ncm: Replace tasklet with softirq hrtimer
Date: Thu, 31 Aug 2017 12:23:46 -0000
Message-ID: <20170831105827.479650817@linutronix.de>
References: <20170831105725.809317030@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Christoph Hellwig <hch@lst.org>, keescook@chromium.org,
        John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Oliver Neukum <oliver@neukum.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline;
 filename=netcdc_ncm_Replace_tasklet_with_softirq_hrtimer.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

The bh tasklet is used in invoke the hrtimer (cdc_ncm_tx_timer_cb) in
softirq context. This can be also achieved without the tasklet but with
CLOCK_MONOTONIC_SOFT as hrtimer base.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Anna-Maria Gleixner <anna-maria@linutronix.de>
Cc: Oliver Neukum <oliver@neukum.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-usb@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/net/usb/cdc_ncm.c   |   37 ++++++++++++++++---------------------
 include/linux/usb/cdc_ncm.h |    2 +-
 2 files changed, 17 insertions(+), 22 deletions(-)

--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -61,7 +61,6 @@ static bool prefer_mbim;
 module_param(prefer_mbim, bool, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(prefer_mbim, "Prefer MBIM setting on dual NCM/MBIM functions");
 
-static void cdc_ncm_txpath_bh(unsigned long param);
 static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_timer);
 static struct usb_driver cdc_ncm_driver;
@@ -777,10 +776,9 @@ int cdc_ncm_bind_common(struct usbnet *d
 	if (!ctx)
 		return -ENOMEM;
 
-	hrtimer_init(&ctx->tx_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+	hrtimer_init(&ctx->tx_timer, CLOCK_MONOTONIC_SOFT, HRTIMER_MODE_REL);
 	ctx->tx_timer.function = &cdc_ncm_tx_timer_cb;
-	ctx->bh.data = (unsigned long)dev;
-	ctx->bh.func = cdc_ncm_txpath_bh;
+	ctx->usbnet = dev;
 	atomic_set(&ctx->stop, 0);
 	spin_lock_init(&ctx->mtx);
 
@@ -967,10 +965,7 @@ void cdc_ncm_unbind(struct usbnet *dev,
 
 	atomic_set(&ctx->stop, 1);
 
-	if (hrtimer_active(&ctx->tx_timer))
-		hrtimer_cancel(&ctx->tx_timer);
-
-	tasklet_kill(&ctx->bh);
+	hrtimer_cancel(&ctx->tx_timer);
 
 	/* handle devices with combined control and data interface */
 	if (ctx->control == ctx->data)
@@ -1348,20 +1343,9 @@ static void cdc_ncm_tx_timeout_start(str
 				HRTIMER_MODE_REL);
 }
 
-static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *timer)
+static void cdc_ncm_txpath_bh(struct cdc_ncm_ctx *ctx)
 {
-	struct cdc_ncm_ctx *ctx =
-			container_of(timer, struct cdc_ncm_ctx, tx_timer);
-
-	if (!atomic_read(&ctx->stop))
-		tasklet_schedule(&ctx->bh);
-	return HRTIMER_NORESTART;
-}
-
-static void cdc_ncm_txpath_bh(unsigned long param)
-{
-	struct usbnet *dev = (struct usbnet *)param;
-	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
+	struct usbnet *dev = ctx->usbnet;
 
 	spin_lock_bh(&ctx->mtx);
 	if (ctx->tx_timer_pending != 0) {
@@ -1379,6 +1363,17 @@ static void cdc_ncm_txpath_bh(unsigned l
 	}
 }
 
+static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *timer)
+{
+	struct cdc_ncm_ctx *ctx =
+			container_of(timer, struct cdc_ncm_ctx, tx_timer);
+
+	if (!atomic_read(&ctx->stop))
+		cdc_ncm_txpath_bh(ctx);
+
+	return HRTIMER_NORESTART;
+}
+
 struct sk_buff *
 cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 {
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -92,7 +92,6 @@
 struct cdc_ncm_ctx {
 	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	struct hrtimer tx_timer;
-	struct tasklet_struct bh;
 
 	const struct usb_cdc_ncm_desc *func_desc;
 	const struct usb_cdc_mbim_desc *mbim_desc;
@@ -101,6 +100,7 @@ struct cdc_ncm_ctx {
 
 	struct usb_interface *control;
 	struct usb_interface *data;
+	struct usbnet *usbnet;
 
 	struct sk_buff *tx_curr_skb;
 	struct sk_buff *tx_rem_skb;
