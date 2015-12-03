From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH 1/6] net: qmi_wwan: MDM9x30 specific power management
Date: Thu,  3 Dec 2015 19:24:18 +0100
Message-ID: <1449167063-22703-2-git-send-email-bjorn@mork.no>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	Oliver Neukum <oneukum@suse.com>,
	Aleksander Morgado <aleksander@aleksander.es>,
	Dan Williams <dcbw@redhat.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55648 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbbLCSZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 13:25:08 -0500
In-Reply-To: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MDM9x30 based modems appear to go into a deeper sleep when
suspended without "Remote Wakeup" enabled.  The QMI interface
will not respond unless a "set DTR" control request is sent
on resume. The effect is similar to a QMI_CTL SYNC request,
resetting (some of) the firmware state.

We allow userspace sessions to span multiple character device
open/close sequences.  This means that userspace can depend
on firmware state while both the netdev and the character
device are closed.  We have disabled "needs_remote_wakeup" at
this point to allow devices without remote wakeup support to
be auto-suspended.

To make sure the MDM9x30 keeps firmware state, we need to
keep "needs_remote_wakeup" always set. We also need to
issue a "set DTR" request to enable the QMI interface.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 9a5be8b85186..fc9dd452a3b5 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -223,6 +223,20 @@ err:
 	return rv;
 }
=20
+/* Send CDC SetControlLineState request, setting or clearing the DTR.
+ * "Required for Autoconnect and 9x30 to wake up" according to the
+ * GobiNet driver. The requirement has been verified on an MDM9230
+ * based Sierra Wireless MC7455
+ */
+static int qmi_wwan_change_dtr(struct usbnet *dev, bool on)
+{
+	u8 intf =3D dev->intf->cur_altsetting->desc.bInterfaceNumber;
+
+	return usbnet_write_cmd(dev, USB_CDC_REQ_SET_CONTROL_LINE_STATE,
+				USB_DIR_OUT | USB_TYPE_CLASS | USB_RECIP_INTERFACE,
+				on ? 0x01 : 0x00, intf, NULL, 0);
+}
+
 static int qmi_wwan_bind(struct usbnet *dev, struct usb_interface *int=
f)
 {
 	int status =3D -1;
@@ -280,6 +294,24 @@ static int qmi_wwan_bind(struct usbnet *dev, struc=
t usb_interface *intf)
 		usb_driver_release_interface(driver, info->data);
 	}
=20
+	/* disabling remote wakeup on MDM9x30 devices has the same
+	 * effect as clearing DTR. The device will not respond to QMI
+	 * requests until we set DTR again.  This is similar to a
+	 * QMI_CTL SYNC request, clearing a lot of firmware state
+	 * including the client ID allocations.
+	 *
+	 * Our usage model allows a session to span multiple
+	 * open/close events, so we must prevent the firmware from
+	 * clearing out state the clients might need.
+	 *
+	 * MDM9x30 is the first QMI chipset with USB3 support. Abuse
+	 * this fact to enable the quirk.
+	 */
+	if (le16_to_cpu(dev->udev->descriptor.bcdUSB) >=3D 0x0201) {
+		qmi_wwan_manage_power(dev, 1);
+		qmi_wwan_change_dtr(dev, true);
+	}
+
 	/* Never use the same address on both ends of the link, even if the
 	 * buggy firmware told us to. Or, if device is assigned the well-know=
n
 	 * buggy firmware MAC address, replace it with a random address,
@@ -307,6 +339,12 @@ static void qmi_wwan_unbind(struct usbnet *dev, st=
ruct usb_interface *intf)
 	if (info->subdriver && info->subdriver->disconnect)
 		info->subdriver->disconnect(info->control);
=20
+	/* disable MDM9x30 quirk */
+	if (le16_to_cpu(dev->udev->descriptor.bcdUSB) >=3D 0x0201) {
+		qmi_wwan_change_dtr(dev, false);
+		qmi_wwan_manage_power(dev, 0);
+	}
+
 	/* allow user to unbind using either control or data */
 	if (intf =3D=3D info->control)
 		other =3D info->data;
--=20
2.1.4
