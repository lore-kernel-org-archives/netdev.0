From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
Date: Mon, 17 Mar 2014 15:23:22 +0100
Message-ID: <87txawlx9h.fsf@nemi.mork.no>
References: <87siqlnol8.fsf@nemi.mork.no> <20140314090525.GB3200@reaktio.net>
	<87ob19nndo.fsf@nemi.mork.no> <20140314125934.GC3200@reaktio.net>
	<87vbvgnbv3.fsf@nemi.mork.no> <20140314142559.GD3200@reaktio.net>
	<87k3btm57a.fsf@nemi.mork.no> <20140317115919.GK3200@reaktio.net>
	<20140317124555.GL3200@reaktio.net> <87y509kluc.fsf@nemi.mork.no>
	<20140317131731.GM3200@reaktio.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Thomas =?utf-8?Q?Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140317131731.GM3200-GxtO3QLqHcLR7s880joybQ@public.gmane.org> ("Pasi =?utf-8?Q?K=C3=A4r?=
 =?utf-8?Q?kk=C3=A4inen=22's?= message
	of "Mon, 17 Mar 2014 15:17:31 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Pasi K=C3=A4rkk=C3=A4inen <pasik-X3B1VOXEql0@public.gmane.org> writes:
> On Mon, Mar 17, 2014 at 02:15:23PM +0100, Bj=C3=B8rn Mork wrote:
>
>> I still don't know for sure, but I do hope this bug is the real cause of
>> the problems you are having.  I'll send you a patch for testing as soon
>> as it is ready.
>>=20
>
> Sure. I'll be happy to test the patch!

I ended up with a simple revert of the buggy commit, except for a
conflict due to unrelated context changes.  This seemed like the
cleanest approach given that this fix also needs to go to stable.

Attaching the first version.  Please give it a try if you can. I've
tested it somewhat myself and it doesn't seem to break anything.  Since
it's a simple revert, there isn't really that much that could go wrong
here...


Bj=C3=B8rn


--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: inline;
 filename=0001-net-cdc_ncm-fix-control-message-ordering.patch
Content-Transfer-Encoding: quoted-printable

>From 2ad87cde1d386acc31ac3caf66a24d24423ca721 Mon Sep 17 00:00:00 2001
From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Mon, 17 Mar 2014 14:58:06 +0100
Subject: [PATCH] net: cdc_ncm: fix control message ordering
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

Commit 6a9612e2cb22 ("net: cdc_ncm: remove ncm_parm field")
introduced a specification violation, which caused setup
errors for some devices. In some cases, these errors
resulted in the device and host disagreeing about shared
settings, with complete failure to communicate as the end
result.

The NCM specification require that some commands are sent
only while the NCM Data Interface is in alternate setting 0.
Reverting the commit ensures that we follow this requirement.

Fixes: 6a9612e2cb22 ("net: cdc_ncm: remove ncm_parm field")
Reported-by: Pasi K=C3=A4rkk=C3=A4inen <pasik-X3B1VOXEql0@public.gmane.org>
Reported-by: Thomas Sch=C3=A4fer <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c   | 48 ++++++++++++++++++++++-------------------=
----
 include/linux/usb/cdc_ncm.h |  1 +
 2 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index dbff290ed0e4..d350d2795e10 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -68,7 +68,6 @@ static struct usb_driver cdc_ncm_driver;
 static int cdc_ncm_setup(struct usbnet *dev)
 {
 	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	u32 val;
 	u8 flags;
 	u8 iface_no;
@@ -82,22 +81,22 @@ static int cdc_ncm_setup(struct usbnet *dev)
 	err =3D usbnet_read_cmd(dev, USB_CDC_GET_NTB_PARAMETERS,
 			      USB_TYPE_CLASS | USB_DIR_IN
 			      |USB_RECIP_INTERFACE,
-			      0, iface_no, &ncm_parm,
-			      sizeof(ncm_parm));
+			      0, iface_no, &ctx->ncm_parm,
+			      sizeof(ctx->ncm_parm));
 	if (err < 0) {
 		dev_err(&dev->intf->dev, "failed GET_NTB_PARAMETERS\n");
 		return err; /* GET_NTB_PARAMETERS is required */
 	}
=20
 	/* read correct set of parameters according to device mode */
-	ctx->rx_max =3D le32_to_cpu(ncm_parm.dwNtbInMaxSize);
-	ctx->tx_max =3D le32_to_cpu(ncm_parm.dwNtbOutMaxSize);
-	ctx->tx_remainder =3D le16_to_cpu(ncm_parm.wNdpOutPayloadRemainder);
-	ctx->tx_modulus =3D le16_to_cpu(ncm_parm.wNdpOutDivisor);
-	ctx->tx_ndp_modulus =3D le16_to_cpu(ncm_parm.wNdpOutAlignment);
+	ctx->rx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize);
+	ctx->tx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize);
+	ctx->tx_remainder =3D le16_to_cpu(ctx->ncm_parm.wNdpOutPayloadRemainder);
+	ctx->tx_modulus =3D le16_to_cpu(ctx->ncm_parm.wNdpOutDivisor);
+	ctx->tx_ndp_modulus =3D le16_to_cpu(ctx->ncm_parm.wNdpOutAlignment);
 	/* devices prior to NCM Errata shall set this field to zero */
-	ctx->tx_max_datagrams =3D le16_to_cpu(ncm_parm.wNtbOutMaxDatagrams);
-	ntb_fmt_supported =3D le16_to_cpu(ncm_parm.bmNtbFormatsSupported);
+	ctx->tx_max_datagrams =3D le16_to_cpu(ctx->ncm_parm.wNtbOutMaxDatagrams);
+	ntb_fmt_supported =3D le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported);
=20
 	/* there are some minor differences in NCM and MBIM defaults */
 	if (cdc_ncm_comm_intf_is_mbim(ctx->control->cur_altsetting)) {
@@ -146,7 +145,7 @@ static int cdc_ncm_setup(struct usbnet *dev)
 	}
=20
 	/* inform device about NTB input size changes */
-	if (ctx->rx_max !=3D le32_to_cpu(ncm_parm.dwNtbInMaxSize)) {
+	if (ctx->rx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
 		__le32 dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
=20
 		err =3D usbnet_write_cmd(dev, USB_CDC_SET_NTB_INPUT_SIZE,
@@ -162,14 +161,6 @@ static int cdc_ncm_setup(struct usbnet *dev)
 		dev_dbg(&dev->intf->dev, "Using default maximum transmit length=3D%d\n",
 			CDC_NCM_NTB_MAX_SIZE_TX);
 		ctx->tx_max =3D CDC_NCM_NTB_MAX_SIZE_TX;
-
-		/* Adding a pad byte here simplifies the handling in
-		 * cdc_ncm_fill_tx_frame, by making tx_max always
-		 * represent the real skb max size.
-		 */
-		if (ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
-			ctx->tx_max++;
-
 	}
=20
 	/*
@@ -439,6 +430,10 @@ advance:
 		goto error2;
 	}
=20
+	/* initialize data interface */
+	if (cdc_ncm_setup(dev))
+		goto error2;
+
 	/* configure data interface */
 	temp =3D usb_set_interface(dev->udev, iface_no, data_altsetting);
 	if (temp) {
@@ -453,12 +448,6 @@ advance:
 		goto error2;
 	}
=20
-	/* initialize data interface */
-	if (cdc_ncm_setup(dev))	{
-		dev_dbg(&intf->dev, "cdc_ncm_setup() failed\n");
-		goto error2;
-	}
-
 	usb_set_intfdata(ctx->data, dev);
 	usb_set_intfdata(ctx->control, dev);
=20
@@ -475,6 +464,15 @@ advance:
 	dev->hard_mtu =3D ctx->tx_max;
 	dev->rx_urb_size =3D ctx->rx_max;
=20
+	/* cdc_ncm_setup will override dwNtbOutMaxSize if it is
+	 * outside the sane range. Adding a pad byte here if necessary
+	 * simplifies the handling in cdc_ncm_fill_tx_frame, making
+	 * tx_max always represent the real skb max size.
+	 */
+	if (ctx->tx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize) &&
+	    ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
+		ctx->tx_max++;
+
 	return 0;
=20
 error2:
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index c3fa80745996..2c14d9cdd57a 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -88,6 +88,7 @@
 #define cdc_ncm_data_intf_is_mbim(x)  ((x)->desc.bInterfaceProtocol =3D=3D=
 USB_CDC_MBIM_PROTO_NTB)
=20
 struct cdc_ncm_ctx {
+	struct usb_cdc_ncm_ntb_parameters ncm_parm;
 	struct hrtimer tx_timer;
 	struct tasklet_struct bh;
=20
--=20
1.9.0


--=-=-=--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
