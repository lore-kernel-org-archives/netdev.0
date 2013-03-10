From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [RFC] net: cdc_ncm, cdc_mbim: allow user to prefer NCM for backwards compatibility
Date: Sun, 10 Mar 2013 19:13:29 +0100
Message-ID: <1362939209-19056-1-git-send-email-bjorn@mork.no>
References: <87sj43cxg5.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@stericsson.com>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: Greg Suarez <gsuarez@smithmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54674 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802Ab3CJSOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Mar 2013 14:14:20 -0400
In-Reply-To: <87sj43cxg5.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Devices implementing NCM backwards compatibility according to section
3.2 of the MBIM v1.0 specification allow either NCM or MBIM on a single
USB function, using different altsettings.  The cdc_ncm and cdc_mbim
drivers will both probe such functions, and must agree on a common
policy for selecting either MBIM or NCM.  Until now, this policy has
been set at build time based on CONFIG_USB_NET_CDC_MBIM.

Use a module parameter to set the system policy at runtime, allowing th=
e
user to prefer NCM on systems with the cdc_mbim driver.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---

Maybe something like this?  I don't like the way this code looks, but I
am unable to make it look more readable...

Does this still work as expected with all your devices?  Does it allow =
you
to use cdc_ncm on devices with compatibility mode?  I still don't have =
any
such device, except for my fake emulated kvm one.

Thanks for testing.


Bj=C3=B8rn

 drivers/net/usb/cdc_mbim.c  |   12 +----------
 drivers/net/usb/cdc_ncm.c   |   49 ++++++++++++++++++++++++++++-------=
--------
 include/linux/usb/cdc_ncm.h |    1 +
 3 files changed, 34 insertions(+), 28 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 248d2dc..70fd7c6 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -62,24 +62,14 @@ static int cdc_mbim_wdm_manage_power(struct usb_int=
erface *intf, int status)
 	return cdc_mbim_manage_power(dev, status);
 }
=20
-
 static int cdc_mbim_bind(struct usbnet *dev, struct usb_interface *int=
f)
 {
 	struct cdc_ncm_ctx *ctx;
 	struct usb_driver *subdriver =3D ERR_PTR(-ENODEV);
 	int ret =3D -ENODEV;
-	u8 data_altsetting =3D CDC_NCM_DATA_ALTSETTING_NCM;
+	u8 data_altsetting =3D cdc_ncm_select_altsetting(dev, intf);
 	struct cdc_mbim_state *info =3D (void *)&dev->data;
=20
-	/* see if interface supports MBIM alternate setting */
-	if (intf->num_altsetting =3D=3D 2) {
-		if (!cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
-			usb_set_interface(dev->udev,
-					  intf->cur_altsetting->desc.bInterfaceNumber,
-					  CDC_NCM_COMM_ALTSETTING_MBIM);
-		data_altsetting =3D CDC_NCM_DATA_ALTSETTING_MBIM;
-	}
-
 	/* Probably NCM, defer for cdc_ncm_bind */
 	if (!cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
 		goto err;
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 61b74a2..8b6bd1b 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -55,6 +55,14 @@
=20
 #define	DRIVER_VERSION				"14-Mar-2012"
=20
+#if IS_ENABLED(CONFIG_USB_NET_CDC_MBIM)
+static bool prefer_mbim =3D true;
+#else
+static bool prefer_mbim;
+#endif
+module_param(prefer_mbim, bool, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(prefer_mbim, "Prefer MBIM on NCM/MBIM backwards compa=
tible functions");
+
 static void cdc_ncm_txpath_bh(unsigned long param);
 static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_tim=
er);
@@ -550,9 +558,12 @@ void cdc_ncm_unbind(struct usbnet *dev, struct usb=
_interface *intf)
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_unbind);
=20
-static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf=
)
+/* Select the MBIM altsetting iff it is preferred and available,
+ * returning the number of the corresponding data interface altsetting
+ */
+u8 cdc_ncm_select_altsetting(struct usbnet *dev, struct usb_interface =
*intf)
 {
-	int ret;
+	struct usb_host_interface *alt;
=20
 	/* The MBIM spec defines a NCM compatible default altsetting,
 	 * which we may have matched:
@@ -568,23 +579,27 @@ static int cdc_ncm_bind(struct usbnet *dev, struc=
t usb_interface *intf)
 	 *   endpoint descriptors, shall be constructed according to
 	 *   the rules given in section 6 (USB Device Model) of this
 	 *   specification."
-	 *
-	 * Do not bind to such interfaces, allowing cdc_mbim to handle
-	 * them
 	 */
-#if IS_ENABLED(CONFIG_USB_NET_CDC_MBIM)
-	if ((intf->num_altsetting =3D=3D 2) &&
-	    !usb_set_interface(dev->udev,
-			       intf->cur_altsetting->desc.bInterfaceNumber,
-			       CDC_NCM_COMM_ALTSETTING_MBIM)) {
-		if (cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
-			return -ENODEV;
-		else
-			usb_set_interface(dev->udev,
-					  intf->cur_altsetting->desc.bInterfaceNumber,
-					  CDC_NCM_COMM_ALTSETTING_NCM);
+	if (prefer_mbim && intf->num_altsetting =3D=3D 2) {
+		alt =3D usb_altnum_to_altsetting(intf, CDC_NCM_COMM_ALTSETTING_MBIM)=
;
+		if (alt && cdc_ncm_comm_intf_is_mbim(alt) &&
+		    !usb_set_interface(dev->udev,
+				       intf->cur_altsetting->desc.bInterfaceNumber,
+				       CDC_NCM_COMM_ALTSETTING_MBIM))
+			return CDC_NCM_DATA_ALTSETTING_MBIM;
 	}
-#endif
+	return CDC_NCM_DATA_ALTSETTING_NCM;
+}
+EXPORT_SYMBOL_GPL(cdc_ncm_select_altsetting);
+
+static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf=
)
+{
+	int ret;
+
+	/* MBIM backwards compatible function? */
+	cdc_ncm_select_altsetting(dev, intf);
+	if (cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
+		return -ENODEV;
=20
 	/* NCM data altsetting is always 1 */
 	ret =3D cdc_ncm_bind_common(dev, intf, 1);
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 3b8f9d4..cc25b70 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -127,6 +127,7 @@ struct cdc_ncm_ctx {
 	u16 connected;
 };
=20
+extern u8 cdc_ncm_select_altsetting(struct usbnet *dev, struct usb_int=
erface *intf);
 extern int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interfac=
e *intf, u8 data_altsetting);
 extern void cdc_ncm_unbind(struct usbnet *dev, struct usb_interface *i=
ntf);
 extern struct sk_buff *cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, =
struct sk_buff *skb, __le32 sign);
--=20
1.7.10.4
