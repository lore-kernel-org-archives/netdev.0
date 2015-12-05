From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable] net: cdc_mbim: add "NDP to end" quirk for Huawei E3372
Date: Sat,  5 Dec 2015 13:01:50 +0100
Message-ID: <1449316910-8009-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Sami Farin <hvtaifwkbgefbaei@gmail.com>,
	Aleksander Morgado <aleksander@aleksander.es>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34748 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470AbbLEMCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2015 07:02:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Huawei E3372 (12d1:157d) needs this quirk in MBIM mode
as well. Allow this by forcing the NTB to contain only a
single NDP, and add a device specific entry for this ID.

Due to the way Huawei use device IDs, this might be applied
to other modems as well.  It is assumed that those modems
will be based on the same firmware and will need this quirk
too.  If not, it will still not harm normal usage, although
multiplexing performance could be impacted.

Cc: Enrico Mioso <mrkiko.rs@gmail.com>
Reported-by: Sami Farin <hvtaifwkbgefbaei@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_mbim.c | 26 +++++++++++++++++++++++++-
 drivers/net/usb/cdc_ncm.c  | 10 +++++++++-
 2 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index bbde9884ab8a..8973abdec9f6 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -158,7 +158,7 @@ static int cdc_mbim_bind(struct usbnet *dev, struct=
 usb_interface *intf)
 	if (!cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
 		goto err;
=20
-	ret =3D cdc_ncm_bind_common(dev, intf, data_altsetting, 0);
+	ret =3D cdc_ncm_bind_common(dev, intf, data_altsetting, dev->driver_i=
nfo->data);
 	if (ret)
 		goto err;
=20
@@ -582,6 +582,26 @@ static const struct driver_info cdc_mbim_info_zlp =
=3D {
 	.tx_fixup =3D cdc_mbim_tx_fixup,
 };
=20
+/* The spefication explicitly allows NDPs to be placed anywhere in the
+ * frame, but some devices fail unless the NDP is placed after the IP
+ * packets.  Using the CDC_NCM_FLAG_NDP_TO_END flags to force this
+ * behaviour.
+ *
+ * Note: The current implementation of this feature restricts each NTB
+ * to a single NDP, implying that multiplexed sessions cannot share an
+ * NTB. This might affect performace for multiplexed sessions.
+ */
+static const struct driver_info cdc_mbim_info_ndp_to_end =3D {
+	.description =3D "CDC MBIM",
+	.flags =3D FLAG_NO_SETINT | FLAG_MULTI_PACKET | FLAG_WWAN,
+	.bind =3D cdc_mbim_bind,
+	.unbind =3D cdc_mbim_unbind,
+	.manage_power =3D cdc_mbim_manage_power,
+	.rx_fixup =3D cdc_mbim_rx_fixup,
+	.tx_fixup =3D cdc_mbim_tx_fixup,
+	.data =3D CDC_NCM_FLAG_NDP_TO_END,
+};
+
 static const struct usb_device_id mbim_devs[] =3D {
 	/* This duplicate NCM entry is intentional. MBIM devices can
 	 * be disguised as NCM by default, and this is necessary to
@@ -597,6 +617,10 @@ static const struct usb_device_id mbim_devs[] =3D =
{
 	{ USB_VENDOR_AND_INTERFACE_INFO(0x0bdb, USB_CLASS_COMM, USB_CDC_SUBCL=
ASS_MBIM, USB_CDC_PROTO_NONE),
 	  .driver_info =3D (unsigned long)&cdc_mbim_info,
 	},
+	/* Huawei E3372 fails unless NDP comes after the IP packets */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x12d1, 0x157d, USB_CLASS_COMM, USB_C=
DC_SUBCLASS_MBIM, USB_CDC_PROTO_NONE),
+	  .driver_info =3D (unsigned long)&cdc_mbim_info_ndp_to_end,
+	},
 	/* default entry */
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MBIM, USB_CDC_P=
ROTO_NONE),
 	  .driver_info =3D (unsigned long)&cdc_mbim_info_zlp,
diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 3b1ba8237768..1e9843a41168 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -955,10 +955,18 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(stru=
ct cdc_ncm_ctx *ctx, struct sk_
 	* NTH16 header as we would normally do. NDP isn't written to the SKB =
yet, and
 	* the wNdpIndex field in the header is actually not consistent with r=
eality. It will be later.
 	*/
-	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END)
+	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END) {
 		if (ctx->delayed_ndp16->dwSignature =3D=3D sign)
 			return ctx->delayed_ndp16;
=20
+		/* We can only push a single NDP to the end. Return
+		 * NULL to send what we've already got and queue this
+		 * skb for later.
+		 */
+		else if (ctx->delayed_ndp16->dwSignature)
+			return NULL;
+	}
+
 	/* follow the chain of NDPs, looking for a match */
 	while (ndpoffset) {
 		ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb->data + ndpoffset);
--=20
2.1.4
