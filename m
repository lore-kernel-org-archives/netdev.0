From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable] net: huawei_cdc_ncm: increase command buffer size
Date: Wed, 18 Jun 2014 14:21:24 +0200
Message-ID: <1403094084-13588-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Messages from the modem exceeding 256 bytes cause communication
failure.

The WDM protocol is strictly "read on demand", meaning that we only
poll for unread data after receiving a notification from the modem.
Since we have no way to know how much data the modem has to send,
we must make sure that the buffer we provide is "big enough".
Message truncation does not work. Truncated messages are left unread
until the modem has another message to send.  Which often won't
happen until the userspace application has given up waiting for the
final part of the last message, and therefore sends another command.

With a proper CDC WDM function there is a descriptor telling us
which buffer size the modem uses. But with this vendor specific
implementation there is no known way to calculate the exact "big
enough" number.  It is an unknown property of the modem firmware.
Experience has shown that 256 is too small.  The discussion of
this failure ended up concluding that 512 might be too small as
well. So 1024 seems like a reasonable value for now.

=46ixes: 41c47d8cfd68 ("net: huawei_cdc_ncm: Introduce the huawei_cdc_n=
cm driver")
Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reported-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---

The problem is a showstopper for anyone hitting it, so I believe this
fix should go into all maintained stable kernels with this driver.
That is anything based on v3.13 or newer.

Thanks,
Bj=C3=B8rn


 drivers/net/usb/huawei_cdc_ncm.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_=
cdc_ncm.c
index f9822bc75425..5d95a13dbe2a 100644
--- a/drivers/net/usb/huawei_cdc_ncm.c
+++ b/drivers/net/usb/huawei_cdc_ncm.c
@@ -84,12 +84,13 @@ static int huawei_cdc_ncm_bind(struct usbnet *usbne=
t_dev,
 	ctx =3D drvstate->ctx;
=20
 	if (usbnet_dev->status)
-		/* CDC-WMC r1.1 requires wMaxCommand to be "at least 256
-		 * decimal (0x100)"
+		/* The wMaxCommand buffer must be big enough to hold
+		 * any message from the modem. Experience has shown
+		 * that some replies are more than 256 bytes long
 		 */
 		subdriver =3D usb_cdc_wdm_register(ctx->control,
 						 &usbnet_dev->status->desc,
-						 256, /* wMaxCommand */
+						 1024, /* wMaxCommand */
 						 huawei_cdc_ncm_wdm_manage_power);
 	if (IS_ERR(subdriver)) {
 		ret =3D PTR_ERR(subdriver);
--=20
2.0.0

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
