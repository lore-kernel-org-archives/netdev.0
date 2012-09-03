From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net] net: usbnet: fix softirq storm on suspend
Date: Mon,  3 Sep 2012 10:26:18 +0200
Message-ID: <1346660778-24539-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Suspending an open usbnet device results in constant
rescheduling of usbnet_bh.

commit 65841fd5 "usbnet: handle remote wakeup asap"
refactored the usbnet_bh code to allow sharing the
urb allocate and submit code with usbnet_resume. In
this process, a test for, and immediate return on,
ENOLINK from rx_submit was unintentionally dropped.

The rx queue will not grow if rx_submit fails,
making usbnet_bh reschedule itself.  This results
in a softirq storm if the error is persistent.
rx_submit translates the usb_submit_urb error
EHOSTUNREACH into ENOLINK, so this is an expected
and persistent error for a suspended device. The
old code tested for this condition and avoided
rescheduling.  Putting this test back.

Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.5
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
Sorry for not noticing this before, but commit 65841fd5
makes usbnet autosuspend completely unusable.  The device
is suspended fine, but burning one CPU core at full load
uses a tiny bit more power making the power saving=20
negative...

I hope this can go into 3.6 and 3.5-stable ASAP. It is
a hard to notice regression, but all the same a serious
one.


Thanks,
Bj=C3=B8rn


 drivers/net/usb/usbnet.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index fd4b26d..fc9f578 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1201,19 +1201,26 @@ deferred:
 }
 EXPORT_SYMBOL_GPL(usbnet_start_xmit);
=20
-static void rx_alloc_submit(struct usbnet *dev, gfp_t flags)
+static int rx_alloc_submit(struct usbnet *dev, gfp_t flags)
 {
 	struct urb	*urb;
 	int		i;
+	int		ret =3D 0;
=20
 	/* don't refill the queue all at once */
 	for (i =3D 0; i < 10 && dev->rxq.qlen < RX_QLEN(dev); i++) {
 		urb =3D usb_alloc_urb(0, flags);
 		if (urb !=3D NULL) {
-			if (rx_submit(dev, urb, flags) =3D=3D -ENOLINK)
-				return;
+			ret =3D rx_submit(dev, urb, flags);
+			if (ret)
+				goto err;
+		} else {
+			ret =3D -ENOMEM;
+			goto err;
 		}
 	}
+err:
+	return ret;
 }
=20
 /*--------------------------------------------------------------------=
-----*/
@@ -1257,7 +1264,8 @@ static void usbnet_bh (unsigned long param)
 		int	temp =3D dev->rxq.qlen;
=20
 		if (temp < RX_QLEN(dev)) {
-			rx_alloc_submit(dev, GFP_ATOMIC);
+			if (rx_alloc_submit(dev, GFP_ATOMIC) =3D=3D -ENOLINK)
+				return;
 			if (temp !=3D dev->rxq.qlen)
 				netif_dbg(dev, link, dev->net,
 					  "rxqlen %d --> %d\n",
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
