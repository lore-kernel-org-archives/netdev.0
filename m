From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Mon, 17 Mar 2014 17:05:27 +0200
Message-ID: <20140317150527.GO3200@reaktio.net>
References: <87ob19nndo.fsf@nemi.mork.no>
 <20140314125934.GC3200@reaktio.net>
 <87vbvgnbv3.fsf@nemi.mork.no>
 <20140314142559.GD3200@reaktio.net>
 <87k3btm57a.fsf@nemi.mork.no>
 <20140317115919.GK3200@reaktio.net>
 <20140317124555.GL3200@reaktio.net>
 <87y509kluc.fsf@nemi.mork.no>
 <20140317131731.GM3200@reaktio.net>
 <87txawlx9h.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas =?iso-8859-1?Q?Sch=E4fer?= <tschaefer@t-online.de>,
	Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh06.mail.saunalahti.fi ([62.142.5.116]:55359 "EHLO
	emh06.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932903AbaCQPF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 11:05:29 -0400
Content-Disposition: inline
In-Reply-To: <87txawlx9h.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 03:23:22PM +0100, Bj=F8rn Mork wrote:
> Pasi K=E4rkk=E4inen <pasik@iki.fi> writes:
> > On Mon, Mar 17, 2014 at 02:15:23PM +0100, Bj=F8rn Mork wrote:
> >
> >> I still don't know for sure, but I do hope this bug is the real ca=
use of
> >> the problems you are having.  I'll send you a patch for testing as=
 soon
> >> as it is ready.
> >>=20
> >
> > Sure. I'll be happy to test the patch!
>=20
> I ended up with a simple revert of the buggy commit, except for a
> conflict due to unrelated context changes.  This seemed like the
> cleanest approach given that this fix also needs to go to stable.
>=20
> Attaching the first version.  Please give it a try if you can. I've
> tested it somewhat myself and it doesn't seem to break anything.  Sin=
ce
> it's a simple revert, there isn't really that much that could go wron=
g
> here...
>=20

I applied the patch on top of Linux 3.13.6 kernel and now I'm able to u=
se the wwan0 NCM interface successfully!=20
I do get an IP with a dhcp client (this failed earlier without the patc=
h), and Internet seems to work OK.=20
So the patch definitely fixes the problem for me with Huawei E3276 4G/L=
TE USB dongle.=20

Thanks a lot!

Tested-by: Pasi K=E4rkk=E4inen <pasik@iki.fi>


-- Pasi

>=20
> Bj=F8rn
>=20

> From 2ad87cde1d386acc31ac3caf66a24d24423ca721 Mon Sep 17 00:00:00 200=
1
> From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn@mork.no>
> Date: Mon, 17 Mar 2014 14:58:06 +0100
> Subject: [PATCH] net: cdc_ncm: fix control message ordering
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3DUTF-8
> Content-Transfer-Encoding: 8bit
>=20
> Commit 6a9612e2cb22 ("net: cdc_ncm: remove ncm_parm field")
> introduced a specification violation, which caused setup
> errors for some devices. In some cases, these errors
> resulted in the device and host disagreeing about shared
> settings, with complete failure to communicate as the end
> result.
>=20
> The NCM specification require that some commands are sent
> only while the NCM Data Interface is in alternate setting 0.
> Reverting the commit ensures that we follow this requirement.
>=20
> Fixes: 6a9612e2cb22 ("net: cdc_ncm: remove ncm_parm field")
> Reported-by: Pasi K=E4rkk=E4inen <pasik@iki.fi>
> Reported-by: Thomas Sch=E4fer <tschaefer@t-online.de>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>
> ---
>  drivers/net/usb/cdc_ncm.c   | 48 ++++++++++++++++++++++-------------=
----------
>  include/linux/usb/cdc_ncm.h |  1 +
>  2 files changed, 24 insertions(+), 25 deletions(-)
>=20
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index dbff290ed0e4..d350d2795e10 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -68,7 +68,6 @@ static struct usb_driver cdc_ncm_driver;
>  static int cdc_ncm_setup(struct usbnet *dev)
>  {
>  	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
> -	struct usb_cdc_ncm_ntb_parameters ncm_parm;
>  	u32 val;
>  	u8 flags;
>  	u8 iface_no;
> @@ -82,22 +81,22 @@ static int cdc_ncm_setup(struct usbnet *dev)
>  	err =3D usbnet_read_cmd(dev, USB_CDC_GET_NTB_PARAMETERS,
>  			      USB_TYPE_CLASS | USB_DIR_IN
>  			      |USB_RECIP_INTERFACE,
> -			      0, iface_no, &ncm_parm,
> -			      sizeof(ncm_parm));
> +			      0, iface_no, &ctx->ncm_parm,
> +			      sizeof(ctx->ncm_parm));
>  	if (err < 0) {
>  		dev_err(&dev->intf->dev, "failed GET_NTB_PARAMETERS\n");
>  		return err; /* GET_NTB_PARAMETERS is required */
>  	}
> =20
>  	/* read correct set of parameters according to device mode */
> -	ctx->rx_max =3D le32_to_cpu(ncm_parm.dwNtbInMaxSize);
> -	ctx->tx_max =3D le32_to_cpu(ncm_parm.dwNtbOutMaxSize);
> -	ctx->tx_remainder =3D le16_to_cpu(ncm_parm.wNdpOutPayloadRemainder)=
;
> -	ctx->tx_modulus =3D le16_to_cpu(ncm_parm.wNdpOutDivisor);
> -	ctx->tx_ndp_modulus =3D le16_to_cpu(ncm_parm.wNdpOutAlignment);
> +	ctx->rx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize);
> +	ctx->tx_max =3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize);
> +	ctx->tx_remainder =3D le16_to_cpu(ctx->ncm_parm.wNdpOutPayloadRemai=
nder);
> +	ctx->tx_modulus =3D le16_to_cpu(ctx->ncm_parm.wNdpOutDivisor);
> +	ctx->tx_ndp_modulus =3D le16_to_cpu(ctx->ncm_parm.wNdpOutAlignment)=
;
>  	/* devices prior to NCM Errata shall set this field to zero */
> -	ctx->tx_max_datagrams =3D le16_to_cpu(ncm_parm.wNtbOutMaxDatagrams)=
;
> -	ntb_fmt_supported =3D le16_to_cpu(ncm_parm.bmNtbFormatsSupported);
> +	ctx->tx_max_datagrams =3D le16_to_cpu(ctx->ncm_parm.wNtbOutMaxDatag=
rams);
> +	ntb_fmt_supported =3D le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupport=
ed);
> =20
>  	/* there are some minor differences in NCM and MBIM defaults */
>  	if (cdc_ncm_comm_intf_is_mbim(ctx->control->cur_altsetting)) {
> @@ -146,7 +145,7 @@ static int cdc_ncm_setup(struct usbnet *dev)
>  	}
> =20
>  	/* inform device about NTB input size changes */
> -	if (ctx->rx_max !=3D le32_to_cpu(ncm_parm.dwNtbInMaxSize)) {
> +	if (ctx->rx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
>  		__le32 dwNtbInMaxSize =3D cpu_to_le32(ctx->rx_max);
> =20
>  		err =3D usbnet_write_cmd(dev, USB_CDC_SET_NTB_INPUT_SIZE,
> @@ -162,14 +161,6 @@ static int cdc_ncm_setup(struct usbnet *dev)
>  		dev_dbg(&dev->intf->dev, "Using default maximum transmit length=3D=
%d\n",
>  			CDC_NCM_NTB_MAX_SIZE_TX);
>  		ctx->tx_max =3D CDC_NCM_NTB_MAX_SIZE_TX;
> -
> -		/* Adding a pad byte here simplifies the handling in
> -		 * cdc_ncm_fill_tx_frame, by making tx_max always
> -		 * represent the real skb max size.
> -		 */
> -		if (ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
> -			ctx->tx_max++;
> -
>  	}
> =20
>  	/*
> @@ -439,6 +430,10 @@ advance:
>  		goto error2;
>  	}
> =20
> +	/* initialize data interface */
> +	if (cdc_ncm_setup(dev))
> +		goto error2;
> +
>  	/* configure data interface */
>  	temp =3D usb_set_interface(dev->udev, iface_no, data_altsetting);
>  	if (temp) {
> @@ -453,12 +448,6 @@ advance:
>  		goto error2;
>  	}
> =20
> -	/* initialize data interface */
> -	if (cdc_ncm_setup(dev))	{
> -		dev_dbg(&intf->dev, "cdc_ncm_setup() failed\n");
> -		goto error2;
> -	}
> -
>  	usb_set_intfdata(ctx->data, dev);
>  	usb_set_intfdata(ctx->control, dev);
> =20
> @@ -475,6 +464,15 @@ advance:
>  	dev->hard_mtu =3D ctx->tx_max;
>  	dev->rx_urb_size =3D ctx->rx_max;
> =20
> +	/* cdc_ncm_setup will override dwNtbOutMaxSize if it is
> +	 * outside the sane range. Adding a pad byte here if necessary
> +	 * simplifies the handling in cdc_ncm_fill_tx_frame, making
> +	 * tx_max always represent the real skb max size.
> +	 */
> +	if (ctx->tx_max !=3D le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize) &&
> +	    ctx->tx_max % usb_maxpacket(dev->udev, dev->out, 1) =3D=3D 0)
> +		ctx->tx_max++;
> +
>  	return 0;
> =20
>  error2:
> diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.=
h
> index c3fa80745996..2c14d9cdd57a 100644
> --- a/include/linux/usb/cdc_ncm.h
> +++ b/include/linux/usb/cdc_ncm.h
> @@ -88,6 +88,7 @@
>  #define cdc_ncm_data_intf_is_mbim(x)  ((x)->desc.bInterfaceProtocol =
=3D=3D USB_CDC_MBIM_PROTO_NTB)
> =20
>  struct cdc_ncm_ctx {
> +	struct usb_cdc_ncm_ntb_parameters ncm_parm;
>  	struct hrtimer tx_timer;
>  	struct tasklet_struct bh;
> =20
> --=20
> 1.9.0
>=20
