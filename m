From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 05/14] net: cdc_ncm: refactor bind preparing for MBIM support
Date: Thu, 18 Oct 2012 22:40:58 +0200
Message-ID: <1350592867-25651-6-git-send-email-bjorn@mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
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
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>

NCM and MBIM can share most of the bind function.  Split
out the shareable part and add MBIM functional descriptor
parsing.

Signed-off-by: Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   47 +++++++++++++++++++++++++++++++------=
--------
 1 file changed, 33 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index bddb0e4..9d2e344 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -475,7 +475,7 @@ static const struct ethtool_ops cdc_ncm_ethtool_ops=
 =3D {
 	.nway_reset =3D usbnet_nway_reset,
 };
=20
-static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf=
)
+static int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interfac=
e *intf, u8 data_altsetting)
 {
 	struct cdc_ncm_ctx *ctx;
 	struct usb_driver *driver;
@@ -549,6 +549,13 @@ static int cdc_ncm_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 			ctx->func_desc =3D (const struct usb_cdc_ncm_desc *)buf;
 			break;
=20
+		case USB_CDC_MBIM_TYPE:
+			if (buf[0] < sizeof(*(ctx->mbim_desc)))
+				break;
+
+			ctx->mbim_desc =3D (const struct usb_cdc_mbim_desc *)buf;
+			break;
+
 		default:
 			break;
 		}
@@ -561,7 +568,7 @@ advance:
=20
 	/* check if we got everything */
 	if ((ctx->control =3D=3D NULL) || (ctx->data =3D=3D NULL) ||
-	    (ctx->ether_desc =3D=3D NULL) || (ctx->control !=3D intf))
+	    ((!ctx->mbim_desc) && ((ctx->ether_desc =3D=3D NULL) || (ctx->con=
trol !=3D intf))))
 		goto error;
=20
 	/* claim interfaces, if any */
@@ -581,7 +588,7 @@ advance:
 		goto error2;
=20
 	/* configure data interface */
-	temp =3D usb_set_interface(dev->udev, iface_no, 1);
+	temp =3D usb_set_interface(dev->udev, iface_no, data_altsetting);
 	if (temp)
 		goto error2;
=20
@@ -598,11 +605,13 @@ advance:
 	usb_set_intfdata(ctx->control, dev);
 	usb_set_intfdata(ctx->intf, dev);
=20
-	temp =3D usbnet_get_ethernet_addr(dev, ctx->ether_desc->iMACAddress);
-	if (temp)
-		goto error2;
+	if (ctx->ether_desc) {
+		temp =3D usbnet_get_ethernet_addr(dev, ctx->ether_desc->iMACAddress)=
;
+		if (temp)
+			goto error2;
+		dev_info(&dev->udev->dev, "MAC-Address: %pM\n", dev->net->dev_addr);
+	}
=20
-	dev_info(&dev->udev->dev, "MAC-Address: %pM\n", dev->net->dev_addr);
=20
 	dev->in =3D usb_rcvbulkpipe(dev->udev,
 		ctx->in_ep->desc.bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
@@ -611,13 +620,6 @@ advance:
 	dev->status =3D ctx->status_ep;
 	dev->rx_urb_size =3D ctx->rx_max;
=20
-	/*
-	 * We should get an event when network connection is "connected" or
-	 * "disconnected". Set network connection in "disconnected" state
-	 * (carrier is OFF) during attach, so the IP network stack does not
-	 * start IPv6 negotiation and more.
-	 */
-	netif_carrier_off(dev->net);
 	ctx->tx_speed =3D ctx->rx_speed =3D 0;
 	return 0;
=20
@@ -663,6 +665,23 @@ static void cdc_ncm_unbind(struct usbnet *dev, str=
uct usb_interface *intf)
 	cdc_ncm_free(ctx);
 }
=20
+static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf=
)
+{
+	int ret;
+
+	/* NCM data altsetting is always 1 */
+	ret =3D cdc_ncm_bind_common(dev, intf, 1);
+
+	/*
+	 * We should get an event when network connection is "connected" or
+	 * "disconnected". Set network connection in "disconnected" state
+	 * (carrier is OFF) during attach, so the IP network stack does not
+	 * start IPv6 negotiation and more.
+	 */
+	netif_carrier_off(dev->net);
+	return ret;
+}
+
 static void cdc_ncm_zero_fill(u8 *ptr, u32 first, u32 end, u32 max)
 {
 	if (first >=3D max)
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
