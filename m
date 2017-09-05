From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 24/25 v2] net/cdc_ncm: Replace tasklet with softirq hrtimer
Date: Tue, 5 Sep 2017 17:42:04 +0200
Message-ID: <20170905154203.p2henpo2vd5iko2g@breakpoint.cc>
References: <20170831105725.809317030@linutronix.de>
 <20170831105827.479650817@linutronix.de>
 <87mv6fzvpr.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Anna-Maria Gleixner <anna-maria@linutronix.de>,
        LKML <linux-kernel@vger.kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>, Christoph Hellwig <hch@lst.de>,
        keescook@chromium.org, John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Oliver Neukum <oliver@neukum.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87mv6fzvpr.fsf@miraculix.mork.no>
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
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
[bigeasy: using usb_get_intfdata() as suggested by Bjørn Mork]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
On 2017-08-31 15:57:04 [+0200], Bjørn Mork wrote:
> I believe the struct usbnet pointer is redundant.  We already have lots
> of pointers back and forth here.  This should work, but is not tested:
> 
> 	struct usbnet *dev = usb_get_intfdata(ctx->control):

I think so, too. Still untested as I don't have a working gadget around.

v1…v2: Updated as suggested by Bjørn and added Greg's Acked-by.

 drivers/net/usb/cdc_ncm.c   | 36 +++++++++++++++---------------------
 include/linux/usb/cdc_ncm.h |  1 -
 2 files changed, 15 insertions(+), 22 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 8f572b9f3625..42f7bd90e6a4 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -61,7 +61,6 @@ static bool prefer_mbim;
 module_param(prefer_mbim, bool, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(prefer_mbim, "Prefer MBIM setting on dual NCM/MBIM functions");
 
-static void cdc_ncm_txpath_bh(unsigned long param);
 static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_timer);
 static struct usb_driver cdc_ncm_driver;
@@ -777,10 +776,8 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_
 	if (!ctx)
 		return -ENOMEM;
 
-	hrtimer_init(&ctx->tx_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+	hrtimer_init(&ctx->tx_timer, CLOCK_MONOTONIC_SOFT, HRTIMER_MODE_REL);
 	ctx->tx_timer.function = &cdc_ncm_tx_timer_cb;
-	ctx->bh.data = (unsigned long)dev;
-	ctx->bh.func = cdc_ncm_txpath_bh;
 	atomic_set(&ctx->stop, 0);
 	spin_lock_init(&ctx->mtx);
 
@@ -967,10 +964,7 @@ void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf)
 
 	atomic_set(&ctx->stop, 1);
 
-	if (hrtimer_active(&ctx->tx_timer))
-		hrtimer_cancel(&ctx->tx_timer);
-
-	tasklet_kill(&ctx->bh);
+	hrtimer_cancel(&ctx->tx_timer);
 
 	/* handle devices with combined control and data interface */
 	if (ctx->control == ctx->data)
@@ -1348,20 +1342,9 @@ static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx)
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
+	struct usbnet *dev = usb_get_intfdata(ctx->control);
 
 	spin_lock_bh(&ctx->mtx);
 	if (ctx->tx_timer_pending != 0) {
@@ -1379,6 +1362,17 @@ static void cdc_ncm_txpath_bh(unsigned long param)
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
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 1a59699cf82a..62b506fddf8d 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -92,7 +92,6 @@
 struct cdc_ncm_ctx {
 	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	struct hrtimer tx_timer;
-	struct tasklet_struct bh;
 
 	const struct usb_cdc_ncm_desc *func_desc;
 	const struct usb_cdc_mbim_desc *mbim_desc;
-- 
2.14.1
