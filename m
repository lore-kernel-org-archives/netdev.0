From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: dereference after null check in usbnet_start_xmit() and __usbnet_read_cmd()
Date: Wed, 19 Aug 2015 13:51:20 +0200
Message-ID: <87fv3febt3.fsf@nemi.mork.no>
References: <907196681.281711439983295252.JavaMail.weblogic@ep2mlwas02b>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nitin.j@samsung.com, hemanshu.s@samsung.com
To: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57202 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753330AbbHSLvf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 07:51:35 -0400
In-Reply-To: <907196681.281711439983295252.JavaMail.weblogic@ep2mlwas02b>
	(Vivek Kumar Bhagat's message of "Wed, 19 Aug 2015 11:21:35 +0000
	(GMT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vivek Kumar Bhagat <vivek.bhagat@samsung.com> writes:

> usbnet_start_xmit() - If info->tx_fixup is not defined by class drive=
r,
> NULL check does not happen for skb pointer and leads to NULL derefere=
nce.
> __usbnet_read_cmd() - if data pointer is passed as NULL, memcpy will
> dereference NULL pointer.

That's two completely different issues.  Mixing them in a single patch
is only confusing things.


> Signed-off-by: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
> ---
>  drivers/net/usb/usbnet.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 3c86b10..ec4d224 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1294,6 +1294,8 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *=
skb,
> =20
>  	if (skb)
>  		skb_tx_timestamp(skb);
> +	else
> +		goto drop;
> =20
>  	// some devices want funky USB-level framing, for
>  	// win32 driver (usually) and/or hardware quirks


This is wrong.  There are usbnet minidrivers depending on info->tx_fixu=
p
being called with a NULL skb.


> @@ -1906,7 +1908,8 @@ static int __usbnet_read_cmd(struct usbnet *dev=
, u8 cmd, u8 reqtype,
>  		buf =3D kmalloc(size, GFP_KERNEL);
>  		if (!buf)
>  			goto out;
> -	}
> +	} else
> +		goto out;
> =20
>  	err =3D usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
>  			      cmd, reqtype, value, index, buf, size,


This is also wrong.  It makes __usbnet_read_cmd() return -ENOMEM if
called with a NULL data pointer.  I don't know if it is used, but it's
perfectly valid to call __usbnet_read_cmd() with data =3D=3D NULL if
size =3D=3D 0. No memcpy will happen in this case because usb_control_m=
sg
can only return 0 or an error

Please don't submit any more such patches without proper justification.
You cannot trust that someone will actually take the time to sanity
check your changes.  Patches claiming to fix a NULL dereference should
at least provide an oops.


Bj=C3=B8rn
