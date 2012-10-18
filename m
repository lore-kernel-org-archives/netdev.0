From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 06/14] net: cdc_ncm: process chained NDPs
Date: Thu, 18 Oct 2012 22:40:59 +0200
Message-ID: <1350592867-25651-7-git-send-email-bjorn@mork.no>
References: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gpsuarez2512@gmail.com>,
	"Fangxiaozhi (Franko)" <fangxiaozhi@huawei.com>,
	Dan Williams <dcbw@redhat.com>,
	Aleksander Morgado <aleksander@lanedo.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60318 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932288Ab2JRUm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 16:42:27 -0400
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NCM 1.0 spefication makes provisions for linking more than
one NDP into a single NTB. This is important for MBIM support,
where these NDPs might be of different types.

=46ollowing the chain of NDPs is also correct for NCM, and will
not change anything in the common case where there is only
one NDP

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c |   35 +++++++++++++++++++++--------------
 1 file changed, 21 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 9d2e344..889969d 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1001,6 +1001,8 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, s=
truct sk_buff *skb_in)
 	struct usb_cdc_ncm_nth16 *nth16;
 	struct usb_cdc_ncm_ndp16 *ndp16;
 	struct usb_cdc_ncm_dpe16 *dpe16;
+	int ndpoffset;
+	int loopcount =3D 50; /* arbitrary max preventing infinite loop */
=20
 	if (ctx =3D=3D NULL)
 		goto error;
@@ -1034,25 +1036,24 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev,=
 struct sk_buff *skb_in)
 	}
 	ctx->rx_seq =3D le16_to_cpu(nth16->wSequence);
=20
-	len =3D le16_to_cpu(nth16->wNdpIndex);
-	if ((len + sizeof(struct usb_cdc_ncm_ndp16)) > skb_in->len) {
-		pr_debug("invalid DPT16 index <%u>\n",
-					le16_to_cpu(nth16->wNdpIndex));
+	ndpoffset =3D le16_to_cpu(nth16->wNdpIndex);
+next_ndp:
+	if ((ndpoffset + sizeof(struct usb_cdc_ncm_ndp16)) > skb_in->len) {
+		pr_debug("invalid NDP offset  <%u>\n", ndpoffset);
 		goto error;
 	}
-
-	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(((u8 *)skb_in->data) + len);
+	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb_in->data + ndpoffset);
=20
 	if (le32_to_cpu(ndp16->dwSignature) !=3D USB_CDC_NCM_NDP16_NOCRC_SIGN=
) {
 		pr_debug("invalid DPT16 signature <%u>\n",
 					le32_to_cpu(ndp16->dwSignature));
-		goto error;
+		goto err_ndp;
 	}
=20
 	if (le16_to_cpu(ndp16->wLength) < USB_CDC_NCM_NDP16_LENGTH_MIN) {
 		pr_debug("invalid DPT16 length <%u>\n",
 					le32_to_cpu(ndp16->dwSignature));
-		goto error;
+		goto err_ndp;
 	}
=20
 	nframes =3D ((le16_to_cpu(ndp16->wLength) -
@@ -1060,15 +1061,15 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev,=
 struct sk_buff *skb_in)
 					sizeof(struct usb_cdc_ncm_dpe16));
 	nframes--; /* we process NDP entries except for the last one */
=20
-	len +=3D sizeof(struct usb_cdc_ncm_ndp16);
+	ndpoffset +=3D sizeof(struct usb_cdc_ncm_ndp16);
=20
-	if ((len + nframes * (sizeof(struct usb_cdc_ncm_dpe16))) >
+	if ((ndpoffset + nframes * (sizeof(struct usb_cdc_ncm_dpe16))) >
 								skb_in->len) {
 		pr_debug("Invalid nframes =3D %d\n", nframes);
-		goto error;
+		goto err_ndp;
 	}
=20
-	dpe16 =3D (struct usb_cdc_ncm_dpe16 *)(((u8 *)skb_in->data) + len);
+	dpe16 =3D (struct usb_cdc_ncm_dpe16 *)(skb_in->data + ndpoffset);
=20
 	for (x =3D 0; x < nframes; x++, dpe16++) {
 		offset =3D le16_to_cpu(dpe16->wDatagramIndex);
@@ -1080,7 +1081,7 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, s=
truct sk_buff *skb_in)
 		 */
 		if ((offset =3D=3D 0) || (len =3D=3D 0)) {
 			if (!x)
-				goto error; /* empty NTB */
+				goto err_ndp; /* empty NTB */
 			break;
 		}
=20
@@ -1091,7 +1092,7 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, s=
truct sk_buff *skb_in)
 					"offset[%u]=3D%u, length=3D%u, skb=3D%p\n",
 					x, offset, len, skb_in);
 			if (!x)
-				goto error;
+				goto err_ndp;
 			break;
=20
 		} else {
@@ -1104,6 +1105,12 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, =
struct sk_buff *skb_in)
 			usbnet_skb_return(dev, skb);
 		}
 	}
+err_ndp:
+	/* are there more NDPs to process? */
+	ndpoffset =3D le16_to_cpu(ndp16->wNextNdpIndex);
+	if (ndpoffset && loopcount--)
+		goto next_ndp;
+
 	return 1;
 error:
 	return 0;
--=20
1.7.10.4
