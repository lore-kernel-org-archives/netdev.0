From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net] net: cdc_mbim: send ZLP only for the specific buggy device
Date: Wed, 23 Jan 2013 11:57:02 +0100
Message-ID: <1358938622-18344-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>,
	Yauheni Kaliuta <y.kaliuta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Reverting 328d7b8 and instead adding an exception for the
Sierra Wireless MC7710.

commit 328d7b8 (net: cdc_mbim: send ZLP after max sized NTBs)
added a workaround for an issue observed on one specific device.
Concerns were raised that this workaround adds a performance
penalty to all devices based on questionable, if not buggy,
behaviour of a single device:

 "If you add ZLP for NTBs of dwNtbOutMaxSize, you are heavily affecting=
 CPU
  load, increasing interrupt load by factor of 2 in high load traffic
  scenario and possibly decreasing throughput for all other devices
  which behaves correctly."

 "The idea of NCM was to avoid extra ZLPs. If your transfer is exactly
  dwNtbOutMaxSize, it's known, you can submit such request on the recei=
ver
  side and you do not need any EOT indicatation, so the frametime can b=
e
  used for useful data."

Adding a device specific exception to prevent the workaround from
affecting well behaved devices.

The assumption here is that needing a ZLP is truly an *exception*.
We do not yet have enough data to verify this.  The generic
workaround in commit 328d7b8 should be considered acceptable despite
the performance penalty if the exception list becomes a maintainance
hassle.

Cc: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Cc: Yauheni Kaliuta <y.kaliuta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
Sorry about all the back and forth here.  And as indicated in the commi=
t
message, I am not guaranteeing this is the last round either...

I am not going to maintain an ever-growing exception list. My personal
accptance limit for such lists in a class driver is extremely low.  I a=
m
going to reconsider the original patch the next time a device wants thi=
s
specific workaround. And I fear that will happen really soon, based on
the facts that the device the issue in question=20
 - is based on Qualcomm firmware,
 - is commercially available now,
 - is just one of a gazillion expected Qualcomm hardware/firmware based
   MBIM devices on their way to a Linux computer near you...

Yes the firmware is of course buggy as hell.  We don't expect anything
else.  But it doesn't matter.  If a significant number of MBIM devices
from a number of different vendors have the same bug, then we will do
what's needed to support them.  Including accepting smaller performance
penalties not noticable to any end user. In fact not even measurable to
anyone without device firmware debugging tools.

But please let this go into 3.8 for now, and let us all hope I am wrong
this time too, as I often am :-)


Bj=C3=B8rn

 drivers/net/usb/cdc_mbim.c |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 3a5673a..248d2dc 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -366,6 +366,21 @@ err:
=20
 static const struct driver_info cdc_mbim_info =3D {
 	.description =3D "CDC MBIM",
+	.flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
+	.bind =3D cdc_mbim_bind,
+	.unbind =3D cdc_mbim_unbind,
+	.manage_power =3D cdc_mbim_manage_power,
+	.rx_fixup =3D cdc_mbim_rx_fixup,
+	.tx_fixup =3D cdc_mbim_tx_fixup,
+};
+
+/* MBIM and NCM devices should not need a ZLP after NTBs with
+ * dwNtbOutMaxSize length. This driver_info is for the exceptional
+ * devices requiring it anyway, allowing them to be supported without
+ * forcing the performance penalty on all the sane devices.
+ */
+static const struct driver_info cdc_mbim_info_zlp =3D {
+	.description =3D "CDC MBIM",
 	.flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN | FLAG_SEND=
_ZLP,
 	.bind =3D cdc_mbim_bind,
 	.unbind =3D cdc_mbim_unbind,
@@ -385,6 +400,10 @@ static const struct usb_device_id mbim_devs[] =3D =
{
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_NCM, USB_CDC_PR=
OTO_NONE),
 	  .driver_info =3D (unsigned long)&cdc_mbim_info,
 	},
+	/* Sierra Wireless MC7710 need ZLPs */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x1199, 0x68a2, USB_CLASS_COMM, USB_C=
DC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
+	  .driver_info =3D (unsigned long)&cdc_mbim_info_zlp,
+	},
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_P=
ROTO_NONE),
 	  .driver_info =3D (unsigned long)&cdc_mbim_info,
 	},
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
