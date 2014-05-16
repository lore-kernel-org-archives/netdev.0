From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next v2 05/12] net: cdc_ncm: use ethtool to tune coalescing settings
Date: Fri, 16 May 2014 21:48:22 +0200
Message-ID: <1400269709-18854-6-git-send-email-bjorn@mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52161 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755216AbaEPTss (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 15:48:48 -0400
In-Reply-To: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Datagram coalescing is an integral part of the NCM and MBIM
protocols, intended to reduce the interrupt load primarily
on the device end of the USB link.  As with all coalescing
solutions, there is a trade-off between buffering and
interrupts.

The current defaults are based on the assumption that device
side buffers should be the limiting factor.  However, many
modern high speed LTE modems suffers from buffer-bloat,
making this assumption fail. This results in sub-optimal
performance due to excessive coalescing.  And in cases where
such modems are connected to cheap embedded hosts there is
often severe buffer allocation issues, giving very noticeable
performance degradation .

A start on improving this is going from build time hard
coded limits to per device user configurable limits.  The
ethtool coalescing API was selected as user interface
because, although the tuned values are buffer sizes, these
settings directly control datagram coalescing.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c   | 71 +++++++++++++++++++++++++++++++++++++=
++++++--
 include/linux/usb/cdc_ncm.h |  6 +++-
 2 files changed, 74 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 2ec3790a4db8..141dbec912be 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -65,6 +65,67 @@ static void cdc_ncm_tx_timeout_start(struct cdc_ncm_=
ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_tim=
er);
 static struct usb_driver cdc_ncm_driver;
=20
+static int cdc_ncm_get_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *ec)
+{
+	struct usbnet *dev =3D netdev_priv(netdev);
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+
+	/* assuming maximum sized dgrams and ignoring NDPs */
+	ec->rx_max_coalesced_frames =3D ctx->rx_max / ctx->max_datagram_size;
+	ec->tx_max_coalesced_frames =3D ctx->tx_max / ctx->max_datagram_size;
+
+	/* the timer will fire CDC_NCM_TIMER_PENDING_CNT times in a row */
+	ec->tx_coalesce_usecs =3D (ctx->timer_interval * CDC_NCM_TIMER_PENDIN=
G_CNT) / NSEC_PER_USEC;
+	return 0;
+}
+
+static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u3=
2 new_tx);
+
+static int cdc_ncm_set_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *ec)
+{
+	struct usbnet *dev =3D netdev_priv(netdev);
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	u32 new_rx_max =3D ctx->rx_max;
+	u32 new_tx_max =3D ctx->tx_max;
+
+	/* assuming maximum sized dgrams and a single NDP */
+	if (ec->rx_max_coalesced_frames)
+		new_rx_max =3D ec->rx_max_coalesced_frames * ctx->max_datagram_size;
+	if (ec->tx_max_coalesced_frames)
+		new_tx_max =3D ec->tx_max_coalesced_frames * ctx->max_datagram_size;
+
+	if (ec->tx_coalesce_usecs &&
+	    (ec->tx_coalesce_usecs < CDC_NCM_TIMER_INTERVAL_MIN * CDC_NCM_TIM=
ER_PENDING_CNT ||
+	     ec->tx_coalesce_usecs > CDC_NCM_TIMER_INTERVAL_MAX * CDC_NCM_TIM=
ER_PENDING_CNT))
+		return -EINVAL;
+
+	spin_lock_bh(&ctx->mtx);
+	ctx->timer_interval =3D ec->tx_coalesce_usecs * NSEC_PER_USEC / CDC_N=
CM_TIMER_PENDING_CNT;
+	if (!ctx->timer_interval)
+		ctx->tx_timer_pending =3D 0;
+	spin_unlock_bh(&ctx->mtx);
+
+	/* inform device of new values */
+	if (new_rx_max !=3D ctx->rx_max || new_tx_max !=3D ctx->tx_max)
+		cdc_ncm_update_rxtx_max(dev, new_rx_max, new_tx_max);
+	return 0;
+}
+
+static const struct ethtool_ops cdc_ncm_ethtool_ops =3D {
+	.get_settings      =3D usbnet_get_settings,
+	.set_settings      =3D usbnet_set_settings,
+	.get_link          =3D usbnet_get_link,
+	.nway_reset        =3D usbnet_nway_reset,
+	.get_drvinfo       =3D usbnet_get_drvinfo,
+	.get_msglevel      =3D usbnet_get_msglevel,
+	.set_msglevel      =3D usbnet_set_msglevel,
+	.get_ts_info       =3D ethtool_op_get_ts_info,
+	.get_coalesce      =3D cdc_ncm_get_coalesce,
+	.set_coalesce      =3D cdc_ncm_set_coalesce,
+};
+
 /* handle rx_max and tx_max changes */
 static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u3=
2 new_tx)
 {
@@ -257,6 +318,9 @@ static int cdc_ncm_init(struct usbnet *dev)
 			(ctx->tx_max_datagrams > CDC_NCM_DPT_DATAGRAMS_MAX))
 		ctx->tx_max_datagrams =3D CDC_NCM_DPT_DATAGRAMS_MAX;
=20
+	/* initial coalescing timer interval */
+	ctx->timer_interval =3D CDC_NCM_TIMER_INTERVAL_USEC * NSEC_PER_USEC;
+
 	return 0;
 }
=20
@@ -596,6 +660,9 @@ advance:
 	/* finish setting up the device specific data */
 	cdc_ncm_setup(dev);
=20
+	/* override ethtool_ops */
+	dev->net->ethtool_ops =3D &cdc_ncm_ethtool_ops;
+
 	return 0;
=20
 error2:
@@ -863,7 +930,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk=
_buff *skb, __le32 sign)
 		ctx->tx_curr_skb =3D skb_out;
 		goto exit_no_skb;
=20
-	} else if ((n < ctx->tx_max_datagrams) && (ready2send =3D=3D 0)) {
+	} else if ((n < ctx->tx_max_datagrams) && (ready2send =3D=3D 0) && (c=
tx->timer_interval > 0)) {
 		/* wait for more frames */
 		/* push variables */
 		ctx->tx_curr_skb =3D skb_out;
@@ -915,7 +982,7 @@ static void cdc_ncm_tx_timeout_start(struct cdc_ncm=
_ctx *ctx)
 	/* start timer, if not already started */
 	if (!(hrtimer_active(&ctx->tx_timer) || atomic_read(&ctx->stop)))
 		hrtimer_start(&ctx->tx_timer,
-				ktime_set(0, CDC_NCM_TIMER_INTERVAL),
+				ktime_set(0, ctx->timer_interval),
 				HRTIMER_MODE_REL);
 }
=20
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 55b6feead93b..5c1066b4dc41 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -72,7 +72,9 @@
 /* Restart the timer, if amount of datagrams is less than given value =
*/
 #define	CDC_NCM_RESTART_TIMER_DATAGRAM_CNT	3
 #define	CDC_NCM_TIMER_PENDING_CNT		2
-#define CDC_NCM_TIMER_INTERVAL			(400UL * NSEC_PER_USEC)
+#define CDC_NCM_TIMER_INTERVAL_USEC		400UL
+#define CDC_NCM_TIMER_INTERVAL_MIN		5UL
+#define CDC_NCM_TIMER_INTERVAL_MAX		(15UL * USEC_PER_SEC)
=20
 /* The following macro defines the minimum header space */
 #define	CDC_NCM_MIN_HDR_SIZE \
@@ -107,6 +109,8 @@ struct cdc_ncm_ctx {
 	spinlock_t mtx;
 	atomic_t stop;
=20
+	u64 timer_interval;
+
 	u32 tx_timer_pending;
 	u32 tx_curr_frame_num;
 	u32 rx_max;
--=20
2.0.0.rc2
