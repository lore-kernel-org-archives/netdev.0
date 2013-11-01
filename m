From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [RFC] Revert "sierra_net: keep status interrupt URB active"
Date: Fri,  1 Nov 2013 13:53:48 +0100
Message-ID: <1383310428-19913-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Henderson <jhen-qw6QB7/foO7QT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This reverts commit 7b0c5f21f348a66de495868b8df0284e8dfd6bbf.

It's not easy to create a driver for all the various firmware
bugs out there.

This change caused regressions for a number of devices, which
started to fail link detection and therefore became completely
non-functional. The exact reason is yet unknown, it looks like
the affected firmwares might actually need all or some of the
additional SYNC messages the patch got rid of.

Reverting is not optimal, as it will re-introduce the original
problem, but it is currently the only alternative known to fix
this issue.

Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Link: https://bugzilla.redhat.com/show_bug.cgi?id=3D998342
Reported-by: John Henderson <jhen-qw6QB7/foO7QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
Hello Dan,

I don't know if you've noticed the bug report referenced above
and the discussions taking place down under.  E.g.:
http://forums.whirlpool.net.au/forum-replies.cfm?t=3D2135188&p=3D15#r30=
0

It seems that a number of devices just won't work at all with
the fix for the SYNC problem.  Unfortunately, the only DirectIP
device I've got (MC7710) doesn't have any of these firmware problems,
so I have been unable to come up with any better solution than
reverting.  Which has been confirmed to fix the problem.

My only real alternative proposal, delaying the first SYNC message
to give the firmware some slack, did not work:
http://forums.whirlpool.net.au/forum-replies.cfm?t=3D2135188&p=3D16#r31=
2

So unless you or someone else has a better idea, I don't really
see any other option than reverting the patch.  I am posting
this as an RFC initially as I believe we need to discuss the
options.


Bj=C3=B8rn

 drivers/net/usb/sierra_net.c |   38 +++++++---------------------------=
----
 1 file changed, 7 insertions(+), 31 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.=
c
index a79e9d3..a923d61 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -426,13 +426,6 @@ static void sierra_net_dosync(struct usbnet *dev)
=20
 	dev_dbg(&dev->udev->dev, "%s", __func__);
=20
-	/* The SIERRA_NET_HIP_MSYNC_ID command appears to request that the
-	 * firmware restart itself.  After restarting, the modem will respond
-	 * with the SIERRA_NET_HIP_RESTART_ID indication.  The driver continu=
es
-	 * sending MSYNC commands every few seconds until it receives the
-	 * RESTART event from the firmware
-	 */
-
 	/* tell modem we are ready */
 	status =3D sierra_net_send_sync(dev);
 	if (status < 0)
@@ -711,9 +704,6 @@ static int sierra_net_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
 	/* set context index initially to 0 - prepares tx hdr template */
 	sierra_net_set_ctx_index(priv, 0);
=20
-	/* prepare sync message template */
-	memcpy(priv->sync_msg, sync_tmplate, sizeof(priv->sync_msg));
-
 	/* decrease the rx_urb_size and max_tx_size to 4k on USB 1.1 */
 	dev->rx_urb_size  =3D SIERRA_NET_RX_URB_SIZE;
 	if (dev->udev->speed !=3D USB_SPEED_HIGH)
@@ -749,6 +739,11 @@ static int sierra_net_bind(struct usbnet *dev, str=
uct usb_interface *intf)
 		kfree(priv);
 		return -ENODEV;
 	}
+	/* prepare sync message from template */
+	memcpy(priv->sync_msg, sync_tmplate, sizeof(priv->sync_msg));
+
+	/* initiate the sync sequence */
+	sierra_net_dosync(dev);
=20
 	return 0;
 }
@@ -771,9 +766,8 @@ static void sierra_net_unbind(struct usbnet *dev, s=
truct usb_interface *intf)
 		netdev_err(dev->net,
 			"usb_control_msg failed, status %d\n", status);
=20
-	usbnet_status_stop(dev);
-
 	sierra_net_set_private(dev, NULL);
+
 	kfree(priv);
 }
=20
@@ -914,24 +908,6 @@ static const struct driver_info sierra_net_info_di=
rect_ip =3D {
 	.tx_fixup =3D sierra_net_tx_fixup,
 };
=20
-static int
-sierra_net_probe(struct usb_interface *udev, const struct usb_device_i=
d *prod)
-{
-	int ret;
-
-	ret =3D usbnet_probe(udev, prod);
-	if (ret =3D=3D 0) {
-		struct usbnet *dev =3D usb_get_intfdata(udev);
-
-		ret =3D usbnet_status_start(dev, GFP_KERNEL);
-		if (ret =3D=3D 0) {
-			/* Interrupt URB now set up; initiate sync sequence */
-			sierra_net_dosync(dev);
-		}
-	}
-	return ret;
-}
