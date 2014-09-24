From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] usb: gadget: f_rndis: fix usb_interface_descriptor for rndis
Date: Wed, 24 Sep 2014 11:38:40 +0200
Message-ID: <xa1tbnq59x3z.fsf@mina86.com>
References: <1411541339-32400-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Heiko Schocher <hs@denx.de>, Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, Oliver Neukum <oliver@neukum.name>,
	netdev@vger.kernel.org, linux-api@vger.kernel.org,
	Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Macpaul Lin <macpaul@gmail.com>
To: Heiko Schocher <hs@denx.de>, linux-usb@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411541339-32400-1-git-send-email-hs@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 24 2014, Heiko Schocher <hs@denx.de> wrote:
> use the values for RNDIS over Ethernet as defined in
> http://www.usb.org/developers/defined_class
> (search for RDNIS):
>
> - baseclass: 0xef (miscellaneous)
> - subclass: 0x04
> - protocol: 0x01
>
> with this setings the file in Documentation/usb/linux.inf is
> obsolete.
>
> Signed-off-by: Heiko Schocher <hs@denx.de>
>
> ---
>
> Cc: Felipe Balbi <balbi@ti.com>
> Cc: Greg Kroah-Hartman <gregkh@suse.de>
> Cc: linux-usb@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: Oliver Neukum <oliver@neukum.name>
> Cc: netdev@vger.kernel.org
> Cc: linux-api@vger.kernel.org
> Cc: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Kyungmin Park <kyungmin.park@samsung.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Macpaul Lin <macpaul@gmail.com>
>
> Tested with the "USB Compliance test suite which runs Windows", see:
> http://www.usb.org/developers/tools/usb20_tools/#usb20cv
>
>  drivers/net/usb/cdc_ether.c           | 6 +++---
>  drivers/usb/core/generic.c            | 6 +++---
>  drivers/usb/gadget/function/f_rndis.c | 6 +++---
>  include/uapi/linux/usb/cdc.h          | 3 +++
>  4 files changed, 12 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.=
c
> index 2a32d91..9c216c2 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -35,9 +35,9 @@
> =20
>  static int is_rndis(struct usb_interface_descriptor *desc)
>  {
> -	return (desc->bInterfaceClass =3D=3D USB_CLASS_COMM &&
> -		desc->bInterfaceSubClass =3D=3D 2 &&
> -		desc->bInterfaceProtocol =3D=3D 0xff);
> +	return (desc->bInterfaceClass =3D=3D USB_CLASS_MISC &&
> +		desc->bInterfaceSubClass =3D=3D USB_CDC_SUBCLASS_RNDIS &&
> +		desc->bInterfaceProtocol =3D=3D USB_CDC_RNDIS_PROTO_ETH);
>  }

Does that mean that new kernels will stop working with old RNDIs
gadgets because they stop recognising them as RNDIS?  I feel like this
function should accept both, i.e.:

	return (desc->bInterfaceClass =3D=3D USB_CLASS_COMM &&
		desc->bInterfaceSubClass =3D=3D 2 &&
		desc->bInterfaceProtocol =3D=3D 0xff) ||
	       (desc->bInterfaceClass =3D=3D USB_CLASS_MISC &&
		desc->bInterfaceSubClass =3D=3D USB_CDC_SUBCLASS_RNDIS &&
		desc->bInterfaceProtocol =3D=3D USB_CDC_RNDIS_PROTO_ETH);

> =20
>  static int is_activesync(struct usb_interface_descriptor *desc)
> diff --git a/drivers/usb/core/generic.c b/drivers/usb/core/generic.c
> index 358ca8d..a2a4e05 100644
> --- a/drivers/usb/core/generic.c
> +++ b/drivers/usb/core/generic.c
> @@ -28,9 +28,9 @@ static inline const char *plural(int n)
> =20
>  static int is_rndis(struct usb_interface_descriptor *desc)
>  {
> -	return desc->bInterfaceClass =3D=3D USB_CLASS_COMM
> -		&& desc->bInterfaceSubClass =3D=3D 2
> -		&& desc->bInterfaceProtocol =3D=3D 0xff;
> +	return desc->bInterfaceClass =3D=3D USB_CLASS_MISC
> +		&& desc->bInterfaceSubClass =3D=3D USB_CDC_SUBCLASS_RNDIS
> +		&& desc->bInterfaceProtocol =3D=3D USB_CDC_RNDIS_PROTO_ETH;
>  }

Ditto.

> =20
>  static int is_activesync(struct usb_interface_descriptor *desc)
> diff --git a/drivers/usb/gadget/function/f_rndis.c b/drivers/usb/gadg=
et/function/f_rndis.c
> index ddb09dc..cc06046 100644
> --- a/drivers/usb/gadget/function/f_rndis.c
> +++ b/drivers/usb/gadget/function/f_rndis.c
> @@ -117,9 +117,9 @@ static struct usb_interface_descriptor rndis_cont=
rol_intf =3D {
>  	/* .bInterfaceNumber =3D DYNAMIC */
>  	/* status endpoint is optional; this could be patched later */
>  	.bNumEndpoints =3D	1,
> -	.bInterfaceClass =3D	USB_CLASS_COMM,
> -	.bInterfaceSubClass =3D   USB_CDC_SUBCLASS_ACM,
> -	.bInterfaceProtocol =3D   USB_CDC_ACM_PROTO_VENDOR,
> +	.bInterfaceClass =3D	USB_CLASS_MISC,
> +	.bInterfaceSubClass =3D   USB_CDC_SUBCLASS_RNDIS,
> +	.bInterfaceProtocol =3D   USB_CDC_RNDIS_PROTO_ETH,
>  	/* .iInterface =3D DYNAMIC */
>  };
> =20
> diff --git a/include/uapi/linux/usb/cdc.h b/include/uapi/linux/usb/cd=
c.h
> index b6a9cdd..8e8fc85 100644
> --- a/include/uapi/linux/usb/cdc.h
> +++ b/include/uapi/linux/usb/cdc.h
> @@ -12,6 +12,7 @@
>  #include <linux/types.h>
> =20
>  #define USB_CDC_SUBCLASS_ACM			0x02
> +#define USB_CDC_SUBCLASS_RNDIS			0x04
>  #define USB_CDC_SUBCLASS_ETHERNET		0x06
>  #define USB_CDC_SUBCLASS_WHCM			0x08
>  #define USB_CDC_SUBCLASS_DMM			0x09
> @@ -31,6 +32,8 @@
>  #define USB_CDC_ACM_PROTO_AT_CDMA		6
>  #define USB_CDC_ACM_PROTO_VENDOR		0xff
> =20
> +#define USB_CDC_RNDIS_PROTO_ETH			1
> +
>  #define USB_CDC_PROTO_EEM			7
> =20
>  #define USB_CDC_NCM_PROTO_NTB			1

--=20
Best regards,                                         _     _
=2Eo. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
=2E.o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarew=
icz    (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--
