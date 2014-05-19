From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next] net: cdc_ncm: fix 64bit division build error
Date: Mon, 19 May 2014 09:21:09 +0200
Message-ID: <1400484069-13702-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40130 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbaESHVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 03:21:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The upper timer_interval limit is arbitrary and much higher
than anything usable in the real world.  Reducing it from 15s
to ~4s to make the timer_interval fit in an u32 does not make
much difference.  The limit is still outside the practical
bounds.

This eliminates the need for a 64bit timer_interval, fixing a
build error related to 64bit division:

 drivers/built-in.o: In function `cdc_ncm_get_coalesce':
 ak8975.c:(.text+0x1ac994): undefined reference to `__aeabi_uldivmod'

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---

Thanks a lot for reporting this! I believe it makes more sense to chang=
e
to a u32 than using do_div here.


Bj=C3=B8rn


 drivers/net/usb/cdc_ncm.c   | 4 ++--
 include/linux/usb/cdc_ncm.h | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 2d0caf1eea25..ad2a386a6e92 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -138,7 +138,7 @@ static int cdc_ncm_get_coalesce(struct net_device *=
netdev,
 	ec->tx_max_coalesced_frames =3D ctx->tx_max / ctx->max_datagram_size;
=20
 	/* the timer will fire CDC_NCM_TIMER_PENDING_CNT times in a row */
-	ec->tx_coalesce_usecs =3D (ctx->timer_interval * CDC_NCM_TIMER_PENDIN=
G_CNT) / NSEC_PER_USEC;
+	ec->tx_coalesce_usecs =3D ctx->timer_interval / (NSEC_PER_USEC / CDC_=
NCM_TIMER_PENDING_CNT);
 	return 0;
 }
=20
@@ -164,7 +164,7 @@ static int cdc_ncm_set_coalesce(struct net_device *=
netdev,
 		return -EINVAL;
=20
 	spin_lock_bh(&ctx->mtx);
-	ctx->timer_interval =3D ec->tx_coalesce_usecs * NSEC_PER_USEC / CDC_N=
CM_TIMER_PENDING_CNT;
+	ctx->timer_interval =3D ec->tx_coalesce_usecs * (NSEC_PER_USEC / CDC_=
NCM_TIMER_PENDING_CNT);
 	if (!ctx->timer_interval)
 		ctx->tx_timer_pending =3D 0;
 	spin_unlock_bh(&ctx->mtx);
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 8c5e38819828..7c9b484735c5 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -78,7 +78,7 @@
 #define	CDC_NCM_TIMER_PENDING_CNT		2
 #define CDC_NCM_TIMER_INTERVAL_USEC		400UL
 #define CDC_NCM_TIMER_INTERVAL_MIN		5UL
-#define CDC_NCM_TIMER_INTERVAL_MAX		(15UL * USEC_PER_SEC)
+#define CDC_NCM_TIMER_INTERVAL_MAX		(U32_MAX / NSEC_PER_USEC)
=20
 #define cdc_ncm_comm_intf_is_mbim(x)  ((x)->desc.bInterfaceSubClass =3D=
=3D USB_CDC_SUBCLASS_MBIM && \
 				       (x)->desc.bInterfaceProtocol =3D=3D USB_CDC_PROTO_NONE)
@@ -104,7 +104,7 @@ struct cdc_ncm_ctx {
 	spinlock_t mtx;
 	atomic_t stop;
=20
-	u64 timer_interval;
+	u32 timer_interval;
 	u32 max_ndp_size;
=20
 	u32 tx_timer_pending;
--=20
2.0.0.rc2
