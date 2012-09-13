From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net v2] net: qmi_wwan: call subdriver with control intf only
Date: Thu, 13 Sep 2012 08:44:35 +0200
Message-ID: <1347518675-8427-1-git-send-email-bjorn@mork.no>
References: <1347308150-19088-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347308150-19088-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
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
v2: fix resume error path as well


 drivers/net/usb/qmi_wwan.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 17b8f3e..b1ba68f 100644
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
@@ -310,13 +310,14 @@ static int qmi_wwan_resume(struct usb_interface *=
intf)
 	struct usbnet *dev =3D usb_get_intfdata(intf);
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
 	int ret =3D 0;
+	bool callsub =3D (intf =3D=3D info->control && info->subdriver && inf=
o->subdriver->resume);
=20
-	if (info->subdriver && info->subdriver->resume)
+	if (callsub)
 		ret =3D info->subdriver->resume(intf);
 	if (ret < 0)
 		goto err;
 	ret =3D usbnet_resume(intf);
-	if (ret < 0 && info->subdriver && info->subdriver->resume && info->su=
bdriver->suspend)
+	if (ret < 0 && callsub && info->subdriver->suspend)
 		info->subdriver->suspend(intf, PMSG_SUSPEND);
 err:
 	return ret;
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
