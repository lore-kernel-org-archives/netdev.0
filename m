From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 4/4] net: cdc_ncm/cdc_mbim: rework probing of NCM/MBIM functions
Date: Sun, 11 May 2014 00:17:23 +0200
Message-ID: <1399760243-26625-5-git-send-email-bjorn@mork.no>
References: <1399760243-26625-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399760243-26625-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The NCM class match in the cdc_mbim driver is confusing and
cause unexpected behaviour. The USB core guarantees that a
USB interface is in altsetting 0 when probing starts. This
means that devices implementing a NCM 1.0 backwards
compatible MBIM function (a "NCM/MBIM function") always hit
the NCM entry in the cdc_mbim driver match table. Such
functions will never match any of the MBIM entries.

This causes unexpeced behaviour for cases where the NCM and
MBIM entries are differet, which is currently the case for
all except Ericsson devices.

Improve the probing of NCM/MBIM functions by looking up the
device again in the cdc_mbim match table after switching to
the MBIM identity.

The shared altsetting selection is updated to better
accommodate the new probing logic, returning the preferred
altsetting for the control interface instead of the data
interface. The control interface altsetting update is moved
to the cdc_mbim driver. It is never necessary to change the
control interface altsetting for NCM.

Cc: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
Reported by: Yu-an Shih <yshih-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_mbim.c  | 43 +++++++++++++++++++++++++++++++++++++=
++++--
 drivers/net/usb/cdc_ncm.c   | 27 +++++++++++++--------------
 include/linux/usb/cdc_ncm.h |  2 +-
 3 files changed, 55 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index beb8b95160a5..cfbd9ba65bc5 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -107,15 +107,54 @@ static const struct net_device_ops cdc_mbim_netde=
v_ops =3D {
 	.ndo_vlan_rx_kill_vid =3D cdc_mbim_rx_kill_vid,
 };
=20
+/* Change the control interface altsetting and update the .driver_info
+ * pointer if the matching entry after changing class codes points to
+ * a different struct
+ */
+static int cdc_mbim_set_ctrlalt(struct usbnet *dev, struct usb_interfa=
ce *intf, u8 alt)
+{
+	struct usb_driver *driver =3D to_usb_driver(intf->dev.driver);
+	const struct usb_device_id *id;
+	struct driver_info *info;
+	int ret;
+
+	ret =3D usb_set_interface(dev->udev,
+				intf->cur_altsetting->desc.bInterfaceNumber,
+				alt);
+	if (ret)
+		return ret;
+
+	id =3D usb_match_id(intf, driver->id_table);
+	if (!id)
+		return -ENODEV;
+
+	info =3D (struct driver_info *)id->driver_info;
+	if (info !=3D dev->driver_info) {
+		dev_dbg(&intf->dev, "driver_info updated to '%s'\n",
+			info->description);
+		dev->driver_info =3D info;
+	}
+	return 0;
+}
+
 static int cdc_mbim_bind(struct usbnet *dev, struct usb_interface *int=
f)
 {
 	struct cdc_ncm_ctx *ctx;
 	struct usb_driver *subdriver =3D ERR_PTR(-ENODEV);
 	int ret =3D -ENODEV;
-	u8 data_altsetting =3D cdc_ncm_select_altsetting(dev, intf);
+	u8 data_altsetting =3D 1;
 	struct cdc_mbim_state *info =3D (void *)&dev->data;
=20
-	/* Probably NCM, defer for cdc_ncm_bind */
+	/* should we change control altsetting on a NCM/MBIM function? */
+	if (cdc_ncm_select_altsetting(intf) =3D=3D CDC_NCM_COMM_ALTSETTING_MB=
IM) {
+		data_altsetting =3D CDC_NCM_DATA_ALTSETTING_MBIM;
+		ret =3D cdc_mbim_set_ctrlalt(dev, intf, CDC_NCM_COMM_ALTSETTING_MBIM=
);
+		if (ret)
+			goto err;
+		ret =3D -ENODEV;
+	}
+
+	/* we will hit this for NCM/MBIM functions if prefer_mbim is false */
 	if (!cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
 		goto err;
=20
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 549dbac710ed..a1e0ba2a3a42 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -541,10 +541,10 @@ void cdc_ncm_unbind(struct usbnet *dev, struct us=
b_interface *intf)
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_unbind);
=20
-/* Select the MBIM altsetting iff it is preferred and available,
- * returning the number of the corresponding data interface altsetting
+/* Return the number of the MBIM control interface altsetting iff it
+ * is preferred and available,
  */
-u8 cdc_ncm_select_altsetting(struct usbnet *dev, struct usb_interface =
*intf)
+u8 cdc_ncm_select_altsetting(struct usb_interface *intf)
 {
 	struct usb_host_interface *alt;
=20
@@ -563,15 +563,15 @@ u8 cdc_ncm_select_altsetting(struct usbnet *dev, =
struct usb_interface *intf)
 	 *   the rules given in section 6 (USB Device Model) of this
 	 *   specification."
 	 */
-	if (prefer_mbim && intf->num_altsetting =3D=3D 2) {
+	if (intf->num_altsetting < 2)
+		return intf->cur_altsetting->desc.bAlternateSetting;
+
+	if (prefer_mbim) {
 		alt =3D usb_altnum_to_altsetting(intf, CDC_NCM_COMM_ALTSETTING_MBIM)=
;
-		if (alt && cdc_ncm_comm_intf_is_mbim(alt) &&
-		    !usb_set_interface(dev->udev,
-				       intf->cur_altsetting->desc.bInterfaceNumber,
-				       CDC_NCM_COMM_ALTSETTING_MBIM))
-			return CDC_NCM_DATA_ALTSETTING_MBIM;
+		if (alt && cdc_ncm_comm_intf_is_mbim(alt))
+			return CDC_NCM_COMM_ALTSETTING_MBIM;
 	}
-	return CDC_NCM_DATA_ALTSETTING_NCM;
+	return CDC_NCM_COMM_ALTSETTING_NCM;
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_select_altsetting);
=20
@@ -580,12 +580,11 @@ static int cdc_ncm_bind(struct usbnet *dev, struc=
t usb_interface *intf)
 	int ret;
=20
 	/* MBIM backwards compatible function? */
-	cdc_ncm_select_altsetting(dev, intf);
-	if (cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
+	if (cdc_ncm_select_altsetting(intf) !=3D CDC_NCM_COMM_ALTSETTING_NCM)
 		return -ENODEV;
=20
-	/* NCM data altsetting is always 1 */
-	ret =3D cdc_ncm_bind_common(dev, intf, 1);
+	/* The NCM data altsetting is fixed */
+	ret =3D cdc_ncm_bind_common(dev, intf, CDC_NCM_DATA_ALTSETTING_NCM);
=20
 	/*
 	 * We should get an event when network connection is "connected" or
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 44b38b92236a..55b6feead93b 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -121,7 +121,7 @@ struct cdc_ncm_ctx {
 	u16 connected;
 };
=20
-u8 cdc_ncm_select_altsetting(struct usbnet *dev, struct usb_interface =
*intf);
+u8 cdc_ncm_select_altsetting(struct usb_interface *intf);
 int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf=
, u8 data_altsetting);
 void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *intf);
 struct sk_buff *cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_bu=
ff *skb, __le32 sign);
--=20
2.0.0.rc2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
