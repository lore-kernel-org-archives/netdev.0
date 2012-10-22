From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH v2 net-next 01/13] net: cdc_ncm: workaround NTB input size firmware bug
Date: Mon, 22 Oct 2012 22:56:28 +0200
Message-ID: <1350939400-27209-2-git-send-email-bjorn@mork.no>
References: <1350939400-27209-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Suarez <gpsuarez2512-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Fangxiaozhi (Franko)" <fangxiaozhi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350939400-27209-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some devices do not support the 8 byte variants of the NTB input
size control messages despite announcing such support in their
NCM or MBIM functional descriptor.

According to the NCM specification, all devices must support the
4 byte variant regardless of whether or not the flag is set:

  If bit D5 is set in the bmNetworkCapabilities field of
  function=E2=80=99s NCM Functional Descriptor, the host may
  set wLength either to 4 or to 8. If wLength is 4, the
  function shall assume that wNtbInMaxDatagrams is to be
  set to zero. If wLength is 8, then the function shall
  use the provided value as the limit. The function shall
  return an error response (a STALL PID) if wLength is set
  to any other value.

We do not set wNtbInMaxDatagrams in any case, so we can just as
well unconditionally use the 4 byte variant without losing any
functionality.  This works around the known firmware bug, and
simplifies the code considerably.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   46 +++++++++++++------------------------=
--------
 1 file changed, 13 insertions(+), 33 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4cd582a..32bdf54 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -215,41 +215,21 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
=20
 	/* inform device about NTB input size changes */
 	if (ctx->rx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
+		__le32 *dwNtbInMaxSize;
=20
-		if (flags & USB_CDC_NCM_NCAP_NTB_INPUT_SIZE) {
-			struct usb_cdc_ncm_ndp_input_size *ndp_in_sz;
-
-			ndp_in_sz =3D kzalloc(sizeof(*ndp_in_sz), GFP_KERNEL);
-			if (!ndp_in_sz) {
-				err =3D -ENOMEM;
-				goto size_err;
-			}
-
-			err =3D usb_control_msg(ctx->udev,
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
-			}
-			*dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
-
-			err =3D usb_control_msg(ctx->udev,
-					usb_sndctrlpipe(ctx->udev, 0),
-					USB_CDC_SET_NTB_INPUT_SIZE,
-					USB_TYPE_CLASS | USB_DIR_OUT
-					 | USB_RECIP_INTERFACE,
-					0, iface_no, dwNtbInMaxSize, 4, 1000);
-			kfree(dwNtbInMaxSize);
+		dwNtbInMaxSize =3D kzalloc(sizeof(*dwNtbInMaxSize), GFP_KERNEL);
+		if (!dwNtbInMaxSize) {
+			err =3D -ENOMEM;
+			goto size_err;
 		}
+		*dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
+		err =3D usb_control_msg(ctx->udev,
+				      usb_sndctrlpipe(ctx->udev, 0),
+				      USB_CDC_SET_NTB_INPUT_SIZE,
+				      USB_TYPE_CLASS | USB_DIR_OUT
+				      | USB_RECIP_INTERFACE,
+				      0, iface_no, dwNtbInMaxSize, 4, 1000);
+		kfree(dwNtbInMaxSize);
 size_err:
 		if (err < 0)
 			pr_debug("Setting NTB Input Size failed\n");
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
