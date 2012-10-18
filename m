From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 07/14] net: cdc_ncm: splitting rx_fixup for code reuse
Date: Thu, 18 Oct 2012 22:41:00 +0200
Message-ID: <1350592867-25651-8-git-send-email-bjorn@mork.no>
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
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350592867-25651-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Verifying and handling received MBIM and NCM frames will need
to be different in three areas:
 - verifying the NDP signature
 - checking valid datagram length
 - datagram header manipulation

This makes it inconvenient to share rx_fixup in whole.  But
some verification parts are common.  Split these out in separate
functions.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   83 ++++++++++++++++++++++++++++++-------=
--------
 1 file changed, 55 insertions(+), 28 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 889969d..07d199a 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -990,19 +990,12 @@ error:
 	return NULL;
 }
=20
-static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in=
)
+/* verify NTB header and return offset of first NDP, or negative error=
 */
+static int cdc_ncm_rx_verify_nth16(struct cdc_ncm_ctx *ctx, struct sk_=
buff *skb_in)
 {
-	struct sk_buff *skb;
-	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-	int len;
-	int nframes;
-	int x;
-	int offset;
 	struct usb_cdc_ncm_nth16 *nth16;
-	struct usb_cdc_ncm_ndp16 *ndp16;
-	struct usb_cdc_ncm_dpe16 *dpe16;
-	int ndpoffset;
-	int loopcount =3D 50; /* arbitrary max preventing infinite loop */
+	int len;
+	int ret =3D -EINVAL;
=20
 	if (ctx =3D=3D NULL)
 		goto error;
@@ -1036,40 +1029,74 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev,=
 struct sk_buff *skb_in)
 	}
 	ctx->rx_seq =3D le16_to_cpu(nth16->wSequence);
=20
-	ndpoffset =3D le16_to_cpu(nth16->wNdpIndex);
-next_ndp:
+	ret =3D le16_to_cpu(nth16->wNdpIndex);
+error:
+	return ret;
+}
+
+/* verify NDP header and return number of datagrams, or negative error=
 */
+static int cdc_ncm_rx_verify_ndp16(struct sk_buff *skb_in, int ndpoffs=
et)
+{
+	struct usb_cdc_ncm_ndp16 *ndp16;
+	int ret =3D -EINVAL;
+
 	if ((ndpoffset + sizeof(struct usb_cdc_ncm_ndp16)) > skb_in->len) {
 		pr_debug("invalid NDP offset  <%u>\n", ndpoffset);
 		goto error;
 	}
 	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb_in->data + ndpoffset);
=20
-	if (le32_to_cpu(ndp16->dwSignature) !=3D USB_CDC_NCM_NDP16_NOCRC_SIGN=
) {
-		pr_debug("invalid DPT16 signature <%u>\n",
-					le32_to_cpu(ndp16->dwSignature));
-		goto err_ndp;
-	}
-
 	if (le16_to_cpu(ndp16->wLength) < USB_CDC_NCM_NDP16_LENGTH_MIN) {
 		pr_debug("invalid DPT16 length <%u>\n",
 					le32_to_cpu(ndp16->dwSignature));
-		goto err_ndp;
+		goto error;
 	}
=20
-	nframes =3D ((le16_to_cpu(ndp16->wLength) -
+	ret =3D ((le16_to_cpu(ndp16->wLength) -
 					sizeof(struct usb_cdc_ncm_ndp16)) /
 					sizeof(struct usb_cdc_ncm_dpe16));
-	nframes--; /* we process NDP entries except for the last one */
-
-	ndpoffset +=3D sizeof(struct usb_cdc_ncm_ndp16);
+	ret--; /* we process NDP entries except for the last one */
=20
-	if ((ndpoffset + nframes * (sizeof(struct usb_cdc_ncm_dpe16))) >
+	if ((sizeof(struct usb_cdc_ncm_ndp16) + ret * (sizeof(struct usb_cdc_=
ncm_dpe16))) >
 								skb_in->len) {
-		pr_debug("Invalid nframes =3D %d\n", nframes);
-		goto err_ndp;
+		pr_debug("Invalid nframes =3D %d\n", ret);
+		ret =3D -EINVAL;
 	}
=20
-	dpe16 =3D (struct usb_cdc_ncm_dpe16 *)(skb_in->data + ndpoffset);
+error:
+	return ret;
+}
+
+static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in=
)
+{
+	struct sk_buff *skb;
+	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
+	int len;
+	int nframes;
+	int x;
+	int offset;
+	struct usb_cdc_ncm_ndp16 *ndp16;
+	struct usb_cdc_ncm_dpe16 *dpe16;
+	int ndpoffset;
+	int loopcount =3D 50; /* arbitrary max preventing infinite loop */
+
+	ndpoffset =3D cdc_ncm_rx_verify_nth16(ctx, skb_in);
+	if (ndpoffset < 0)
+		goto error;
+
+next_ndp:
+	nframes =3D cdc_ncm_rx_verify_ndp16(skb_in, ndpoffset);
+	if (nframes < 0)
+		goto error;
+
+	ndp16 =3D (struct usb_cdc_ncm_ndp16 *)(skb_in->data + ndpoffset);
+
+	if (le32_to_cpu(ndp16->dwSignature) !=3D USB_CDC_NCM_NDP16_NOCRC_SIGN=
) {
+		pr_debug("invalid DPT16 signature <%u>\n",
+			 le32_to_cpu(ndp16->dwSignature));
+		goto err_ndp;
+	}
+	dpe16 =3D ndp16->dpe16;
=20
 	for (x =3D 0; x < nframes; x++, dpe16++) {
 		offset =3D le16_to_cpu(dpe16->wDatagramIndex);
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
