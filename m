From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net] net: qmi_wwan: call subdriver with control intf only
Date: Mon, 10 Sep 2012 22:15:50 +0200
Message-ID: <1347308150-19088-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This fixes a hang on suspend due to calling wdm_suspend on
the unregistered data interface. The hang should have been
a NULL pointer reference had it not been for a logic error
in the cdc_wdm code.

  commit 230718bd net: qmi_wwan: bind to both control and data interfac=
e

changed qmi_wwan to use cdc_wdm as a subdriver for devices with
a two-interface QMI/wwan function.  The commit failed to update
qmi_wwan_suspend and qmi_wwan_resume, which were written to handle
either a single combined interface function, or no subdriver at all.

The result was that we called into the subdriver both when the
control interface was suspended and when the data interface was
suspended.  Calling the subdriver suspend function with an
unregistered interface is not supported and will make the
subdriver bug out.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index adfab3f..9d1679f 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -297,7 +297,7 @@ static int qmi_wwan_suspend(struct usb_interface *i=
ntf, pm_message_t message)
 	if (ret < 0)
 		goto err;
=20
-	if (info->subdriver && info->subdriver->suspend)
+	if (intf =3D=3D info->control && info->subdriver && info->subdriver->=
suspend)
 		ret =3D info->subdriver->suspend(intf, message);
 	if (ret < 0)
 		usbnet_resume(intf);
@@ -311,7 +311,7 @@ static int qmi_wwan_resume(struct usb_interface *in=
tf)
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
 	int ret =3D 0;
=20
-	if (info->subdriver && info->subdriver->resume)
+	if (intf =3D=3D info->control && info->subdriver && info->subdriver->=
resume)
 		ret =3D info->subdriver->resume(intf);
 	if (ret < 0)
 		goto err;
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
