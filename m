From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [RFC] net: cdc_ncm: workaround NTB input size firmware bug
Date: Fri, 19 Oct 2012 13:36:15 +0200
Message-ID: <87mwziu21c.fsf_-_@nemi.mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
	<1350592867-25651-3-git-send-email-bjorn@mork.no>
	<3426241.1WN6uXHlgW@linux-lqwf.site> <87ehkvv3ej.fsf@nemi.mork.no>
	<CAL_Kpj0j9umyQBFFDVqWqEjH1057EjR0cZRcScdZG30E54=M0w@mail.gmail.com>
	<878vb3ufnx.fsf@nemi.mork.no> <871uguvmfy.fsf@nemi.mork.no>
	<CAL_Kpj3QX_bpLh5yX5VXKaqq+TSO9+aVxt+1TrU9e1BamKdFkA@mail.gmail.com>
	<87vce6u52w.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Greg Suarez <gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Fangxiaozhi \(Franko\)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87vce6u52w.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Fri, 19
	Oct 2012 12:30:31 +0200")
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some devices do not support the 8 byte variants of
the NTB input size control messages despite announcing
such support in the functional descriptor. This can be
detected by reading the current input size, looking
at how many bytes the device returns.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:

> I'll cook up an alternative patch implementing this so you can evalua=
te
> the impact.

So how about something like this?

I couldn't help myself not combining the two paths here while at it.
But I have intentionally not done the other obvious cleanups, like usin=
g
the standard timeout constants and using dev_xxx for instead of pr_xxx,
because they must and should be done separately over the whole driver.

This works for me:

Oct 19 13:19:43 nemi kernel: [304987.350138] dwNtbInMaxSize=3D131072 dw=
NtbOutMaxSize=3D32768 wNdpOutPayloadRemainder=3D0 wNdpOutDivisor=3D4 wN=
dpOutAlignment=3D4 wNtbOutMaxDatagrams=3D0 flags=3D0x20
Oct 19 13:19:43 nemi kernel: [304987.350144] Using default maximum rece=
ive length=3D32768
Oct 19 13:19:43 nemi kernel: [304987.350507] firmware bug: flags=3D0x20=
, but USB_CDC_GET_NTB_INPUT_SIZE returned 4 bytes


Bj=C3=B8rn

 drivers/net/usb/cdc_ncm.c |   64 +++++++++++++++++++++++--------------=
--------
 1 file changed, 33 insertions(+), 31 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4cd582a..26d31d7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -215,44 +215,46 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
=20
 	/* inform device about NTB input size changes */
 	if (ctx->rx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
+		struct usb_cdc_ncm_ndp_input_size *ndp_in_sz;
+		size_t request_len =3D 4;
=20
+		ndp_in_sz =3D kzalloc(sizeof(*ndp_in_sz), GFP_KERNEL);
+		if (!ndp_in_sz) {
+			err =3D -ENOMEM;
+			goto size_err;
+		}
 		if (flags & USB_CDC_NCM_NCAP_NTB_INPUT_SIZE) {
-			struct usb_cdc_ncm_ndp_input_size *ndp_in_sz;
-
-			ndp_in_sz =3D kzalloc(sizeof(*ndp_in_sz), GFP_KERNEL);
-			if (!ndp_in_sz) {
-				err =3D -ENOMEM;
-				goto size_err;
-			}
-
 			err =3D usb_control_msg(ctx->udev,
-					usb_sndctrlpipe(ctx->udev, 0),
-					USB_CDC_SET_NTB_INPUT_SIZE,
-					USB_TYPE_CLASS | USB_DIR_OUT
-					 | USB_RECIP_INTERFACE,
-					0, iface_no, ndp_in_sz, 8, 1000);
-			kfree(ndp_in_sz);
-		} else {
-			__le32 *dwNtbInMaxSize;
-			dwNtbInMaxSize =3D kzalloc(sizeof(*dwNtbInMaxSize),
-					GFP_KERNEL);
-			if (!dwNtbInMaxSize) {
-				err =3D -ENOMEM;
-				goto size_err;
+					      usb_rcvctrlpipe(ctx->udev, 0),
+					      USB_CDC_GET_NTB_INPUT_SIZE,
+					      USB_TYPE_CLASS | USB_DIR_OUT
+					      | USB_RECIP_INTERFACE,
+					      0, iface_no, ndp_in_sz, 8, 1000);
+			switch (err) {
+			case 4:
+				pr_debug("firmware bug: flags=3D0x%02x, but USB_CDC_GET_NTB_INPUT_=
SIZE returned 4 bytes\n", flags);
+				break;
+			case 8:
+				/* bmNetworkCapabilities is correct */
+				request_len =3D 8;
+				break;
+			default:
+				goto size_err_free;
 			}
-			*dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
-
-			err =3D usb_control_msg(ctx->udev,
-					usb_sndctrlpipe(ctx->udev, 0),
-					USB_CDC_SET_NTB_INPUT_SIZE,
-					USB_TYPE_CLASS | USB_DIR_OUT
-					 | USB_RECIP_INTERFACE,
-					0, iface_no, dwNtbInMaxSize, 4, 1000);
-			kfree(dwNtbInMaxSize);
 		}
+		ndp_in_sz->dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
+		ndp_in_sz->wNtbInMaxDatagrams =3D 0;	/* unlimited */
+		err =3D usb_control_msg(ctx->udev,
+				      usb_sndctrlpipe(ctx->udev, 0),
+				      USB_CDC_SET_NTB_INPUT_SIZE,
+				      USB_TYPE_CLASS | USB_DIR_OUT
+				      | USB_RECIP_INTERFACE,
+				      0, iface_no, ndp_in_sz, request_len, 1000);
+size_err_free:
+		kfree(ndp_in_sz);
 size_err:
 		if (err < 0)
-			pr_debug("Setting NTB Input Size failed\n");
+			pr_debug("Setting NTB Input Size failed: %d\n", err);
 	}
=20
 	/* verify maximum size of transmitted NTB in bytes */
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
