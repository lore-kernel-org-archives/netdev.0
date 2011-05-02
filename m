From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ipheth.c: Enable IP header alignment
Date: Mon, 02 May 2011 22:04:34 +0100
Message-ID: <1304370274.2833.192.camel@localhost>
References: <1304264799.2833.82.camel@localhost>
	 <1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, dgiagio@gmail.com, dborca@yahoo.com,
	davem@davemloft.net, pmcenery@gmail.com, david.hill@ubisoft.com,
	"open list:USB SUBSYSTEM" <linux-usb@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: "L. Alberto" =?ISO-8859-1?Q?Gim=E9nez?= <agimenez@sysvalve.es>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-02 at 21:35 +0200, L. Alberto Gim=C3=A9nez wrote:
> Since commit ea812ca1b06113597adcd8e70c0f84a413d97544 (x86: Align skb=
 w/ start
> of cacheline on newer core 2/Xeon Arch), NET_IP_ALIGN changed from 2 =
to 0, and
> the constant is used to reserve more room for the socket buffer.
>=20
> Some people have reported that tethering stopped working and David Hi=
ll
> submited a patch that redefined NET_IP_ALIGN. Pointed by Ben Hutching=
s, the
> patch has been reworked to use a private constant.
>=20
> I have no more an iPhone device to test it, so it is only compile-tes=
ted.
>=20
> Signed-off-by: L. Alberto Gim=C3=A9nez <agimenez@sysvalve.es>
> ---
>  drivers/net/usb/ipheth.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/usb/ipheth.c b/drivers/net/usb/ipheth.c
> index 7d42f9a..8f1ffc7 100644
> --- a/drivers/net/usb/ipheth.c
> +++ b/drivers/net/usb/ipheth.c
> @@ -80,6 +80,8 @@
>  #define IPHETH_CARRIER_CHECK_TIMEOUT round_jiffies_relative(1 * HZ)
>  #define IPHETH_CARRIER_ON       0x04
> =20
> +#define IPHETH_IP_ALIGN 2
> +
>  static struct usb_device_id ipheth_table[] =3D {
>  	{ USB_DEVICE_AND_INTERFACE_INFO(
>  		USB_VENDOR_APPLE, USB_PRODUCT_IPHONE,
> @@ -205,15 +207,15 @@ static void ipheth_rcvbulk_callback(struct urb =
*urb)
>  	len =3D urb->actual_length;
>  	buf =3D urb->transfer_buffer;
> =20
> -	skb =3D dev_alloc_skb(NET_IP_ALIGN + len);
> +	skb =3D dev_alloc_skb(IPHETH_IP_ALIGN + len);
>  	if (!skb) {
>  		err("%s: dev_alloc_skb: -ENOMEM", __func__);
>  		dev->net->stats.rx_dropped++;
>  		return;
>  	}
> =20
> -	skb_reserve(skb, NET_IP_ALIGN);
> -	memcpy(skb_put(skb, len), buf + NET_IP_ALIGN, len - NET_IP_ALIGN);
> +	skb_reserve(skb, IPHETH_IP_ALIGN);
> +	memcpy(skb_put(skb, len), buf + IPHETH_IP_ALIGN, len - IPHETH_IP_AL=
IGN);
[...]

So this was using NET_IP_ALIGN as an offset into the URB.  Which was
totally bogus, as its value has long been architecture-dependent.  The
code is also claiming to put len bytes but only copying len - delta.

The correct code would be something like:

	if (urb->actual_length <=3D IPHETH_IP_ALIGN) {
		dev->net->stats.rx_length_errors++;
		return;
	}
	len =3D urb->actual_length - IPHETH_IP_ALIGN;
	buf =3D urb->transfer_buffer + IPHETH_IP_ALIGN;
=09
	dev_alloc_skb(len);
	...
	memcpy(skb_put(skb, len), buf, len);

Ben.

>  	skb->dev =3D dev->net;
>  	skb->protocol =3D eth_type_trans(skb, dev->net);
> =20

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
