From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 1/4] cdc_ncm: reduce driver latency in the data path
Date: Wed, 14 Mar 2012 22:26:10 +0100
Message-ID: <1331760373-1914-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Changes:
- use high resolution timer
  latency became approx. 10-15 times less than before
- use taklet for sending remaining data in tx path
Tested on Intel/ARM.

Reviewed-by: Sjur Br=C3=A6ndeland <sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Tested-by: Dmitry Tarnyagin <Dmitry.Tarnyagin-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   94 ++++++++++++++++++++++++-------------=
-------
 1 files changed, 51 insertions(+), 43 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 81f86b8..a8e2a62 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1,7 +1,7 @@
 /*
  * cdc_ncm.c
  *
- * Copyright (C) ST-Ericsson 2010-2011
+ * Copyright (C) ST-Ericsson 2010-2012
  * Contact: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
  * Original author: Hans Petter Selasky <hans.petter.selasky@stericsso=
n.com>
  *
@@ -47,13 +47,12 @@
 #include <linux/mii.h>
 #include <linux/crc32.h>
 #include <linux/usb.h>
-#include <linux/timer.h>
-#include <linux/spinlock.h>
+#include <linux/hrtimer.h>
 #include <linux/atomic.h>
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
=20
-#define	DRIVER_VERSION				"04-Aug-2011"
+#define	DRIVER_VERSION				"14-Mar-2012"
=20
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -81,6 +80,8 @@
=20
 /* Restart the timer, if amount of datagrams is less than given value =
*/
 #define	CDC_NCM_RESTART_TIMER_DATAGRAM_CNT	3
+#define	CDC_NCM_TIMER_PENDING_CNT		2
+#define CDC_NCM_TIMER_INTERVAL			(400UL * NSEC_PER_USEC)
=20
 /* The following macro defines the minimum header space */
 #define	CDC_NCM_MIN_HDR_SIZE \
@@ -97,7 +98,8 @@ struct cdc_ncm_ctx {
 	struct cdc_ncm_data rx_ncm;
 	struct cdc_ncm_data tx_ncm;
 	struct usb_cdc_ncm_ntb_parameters ncm_parm;
-	struct timer_list tx_timer;
+	struct hrtimer tx_timer;
+	struct tasklet_struct bh;
=20
 	const struct usb_cdc_ncm_desc *func_desc;
 	const struct usb_cdc_header_desc *header_desc;
@@ -117,6 +119,7 @@ struct cdc_ncm_ctx {
 	struct sk_buff *tx_rem_skb;
=20
 	spinlock_t mtx;
+	atomic_t stop;
=20
 	u32 tx_timer_pending;
 	u32 tx_curr_offset;
@@ -135,7 +138,9 @@ struct cdc_ncm_ctx {
 	u16 connected;
 };
=20
-static void cdc_ncm_tx_timeout(unsigned long arg);
+static void cdc_ncm_txpath_bh(unsigned long param);
+static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
+static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_tim=
er);
 static const struct driver_info cdc_ncm_info;
 static struct usb_driver cdc_ncm_driver;
 static const struct ethtool_ops cdc_ncm_ethtool_ops;
@@ -441,8 +446,6 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
 	if (ctx =3D=3D NULL)
 		return;
=20
-	del_timer_sync(&ctx->tx_timer);
-
 	if (ctx->tx_rem_skb !=3D NULL) {
 		dev_kfree_skb_any(ctx->tx_rem_skb);
 		ctx->tx_rem_skb =3D NULL;
@@ -469,7 +472,11 @@ static int cdc_ncm_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 	if (ctx =3D=3D NULL)
 		return -ENODEV;
=20
-	init_timer(&ctx->tx_timer);
+	hrtimer_init(&ctx->tx_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+	ctx->tx_timer.function =3D &cdc_ncm_tx_timer_cb;
+	ctx->bh.data =3D (unsigned long)ctx;
+	ctx->bh.func =3D cdc_ncm_txpath_bh;
+	atomic_set(&ctx->stop, 0);
 	spin_lock_init(&ctx->mtx);
 	ctx->netdev =3D dev->net;
=20
@@ -617,6 +624,13 @@ static void cdc_ncm_unbind(struct usbnet *dev, str=
uct usb_interface *intf)
 	if (ctx =3D=3D NULL)
 		return;		/* no setup */
=20
+	atomic_set(&ctx->stop, 1);
+
+	if (hrtimer_active(&ctx->tx_timer))
+		hrtimer_cancel(&ctx->tx_timer);
+
+	tasklet_kill(&ctx->bh);
+
 	/* disconnect master --> disconnect slave */
 	if (intf =3D=3D ctx->control && ctx->data) {
 		usb_set_intfdata(ctx->data, NULL);
@@ -787,7 +801,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, stru=
ct sk_buff *skb)
 		ctx->tx_curr_last_offset =3D last_offset;
 		/* set the pending count */
 		if (n < CDC_NCM_RESTART_TIMER_DATAGRAM_CNT)
-			ctx->tx_timer_pending =3D 2;
+			ctx->tx_timer_pending =3D CDC_NCM_TIMER_PENDING_CNT;
 		goto exit_no_skb;
=20
 	} else {
@@ -867,44 +881,49 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, st=
ruct sk_buff *skb)
=20
 	/* return skb */
 	ctx->tx_curr_skb =3D NULL;
+	ctx->netdev->stats.tx_packets +=3D ctx->tx_curr_frame_num;
 	return skb_out;
=20
 exit_no_skb:
+	/* Start timer, if there is a remaining skb */
+	if (ctx->tx_curr_skb !=3D NULL)
+		cdc_ncm_tx_timeout_start(ctx);
 	return NULL;
 }
=20
 static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx)
 {
 	/* start timer, if not already started */
-	if (timer_pending(&ctx->tx_timer) =3D=3D 0) {
-		ctx->tx_timer.function =3D &cdc_ncm_tx_timeout;
-		ctx->tx_timer.data =3D (unsigned long)ctx;
-		ctx->tx_timer.expires =3D jiffies + ((HZ + 999) / 1000);
-		add_timer(&ctx->tx_timer);
-	}
+	if (!(hrtimer_active(&ctx->tx_timer) || atomic_read(&ctx->stop)))
+		hrtimer_start(&ctx->tx_timer,
+				ktime_set(0, CDC_NCM_TIMER_INTERVAL),
+				HRTIMER_MODE_REL);
 }
=20
-static void cdc_ncm_tx_timeout(unsigned long arg)
+static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *timer)
 {
-	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)arg;
-	u8 restart;
+	struct cdc_ncm_ctx *ctx =3D
+			container_of(timer, struct cdc_ncm_ctx, tx_timer);
=20
-	spin_lock(&ctx->mtx);
-	if (ctx->tx_timer_pending !=3D 0) {
-		ctx->tx_timer_pending--;
-		restart =3D 1;
-	} else {
-		restart =3D 0;
-	}
+	if (!atomic_read(&ctx->stop))
+		tasklet_schedule(&ctx->bh);
+	return HRTIMER_NORESTART;
+}
=20
-	spin_unlock(&ctx->mtx);
+static void cdc_ncm_txpath_bh(unsigned long param)
+{
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)param;
=20
-	if (restart) {
-		spin_lock(&ctx->mtx);
+	spin_lock_bh(&ctx->mtx);
+	if (ctx->tx_timer_pending !=3D 0) {
+		ctx->tx_timer_pending--;
 		cdc_ncm_tx_timeout_start(ctx);
-		spin_unlock(&ctx->mtx);
+		spin_unlock_bh(&ctx->mtx);
 	} else if (ctx->netdev !=3D NULL) {
+		spin_unlock_bh(&ctx->mtx);
+		netif_tx_lock_bh(ctx->netdev);
 		usbnet_start_xmit(NULL, ctx->netdev);
+		netif_tx_unlock_bh(ctx->netdev);
 	}
 }
=20
@@ -913,7 +932,6 @@ cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff=
 *skb, gfp_t flags)
 {
 	struct sk_buff *skb_out;
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-	u8 need_timer =3D 0;
=20
 	/*
 	 * The Ethernet API we are using does not support transmitting
@@ -925,19 +943,9 @@ cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buf=
f *skb, gfp_t flags)
 	if (ctx =3D=3D NULL)
 		goto error;
=20
-	spin_lock(&ctx->mtx);
+	spin_lock_bh(&ctx->mtx);
 	skb_out =3D cdc_ncm_fill_tx_frame(ctx, skb);
-	if (ctx->tx_curr_skb !=3D NULL)
-		need_timer =3D 1;
-
-	/* Start timer, if there is a remaining skb */
-	if (need_timer)
-		cdc_ncm_tx_timeout_start(ctx);
-
-	if (skb_out)
-		dev->net->stats.tx_packets +=3D ctx->tx_curr_frame_num;
