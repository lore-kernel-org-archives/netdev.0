From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] : CDC EEM driver patch to be applied to 2.6.30 kernel
Date: Mon, 4 May 2009 09:32:44 -0700
Message-ID: <200905040932.44927.david-b@pacbell.net>
References: <3a98b4410904270912g1838b534j2b53561b8caa1543@mail.gmail.com> <200905031713.58762.david-b@pacbell.net> <3a98b4410905040851i20d4192ax8f9ff3953e635979@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Omar Laazimani <omar.oberthur@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n14.bullet.mail.mud.yahoo.com ([68.142.206.41]:37527 "HELO
	n14.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758386AbZEDQiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 12:38:51 -0400
In-Reply-To: <3a98b4410905040851i20d4192ax8f9ff3953e635979@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 04 May 2009, Omar Laazimani wrote:
> Thanks for your quick feedbacks.
> I have tested your patch with our device and it's working well.

Great, then I'll send something to David Miller and
maybe it can merge before 2.6.30-final.


> I have also added the TX side support for ZLP (see patch herein).
> Please note that I can't test this issue as our device doesn't
> support it yet.=20

All your device needs to do is ignore them properly.  :)


> By the way, Just for curiosity, I have two questions about your patch
> (see bellow) :
>=20


> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_u=
naligned_le16(BIT(15) | (1 << 11) | len,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 skb_push(skb2, 2));
>=20
> why did you use 1 << 11 instead of BIT(11) ?

To me, BIT(x) is for one-bit fields.  That's a three-bit field,
and I'd write "2 << 11" for another opcode not BIT(12), or
even "3 << 11" instead of (BIT(11) | BIT(12)).

Some folk define special macros for "bitfield of length N
at offset O, value V" ... that can be overdone, but in any
case it's not standardized like BIT().


> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usbnet_skb_return(dev=
, skb2);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_last)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retur=
n crc =3D=3D crc2;
>=20
>  Why do you prefer returning 0 and not incrementing
> "dev->stats.rx_errors" instead of returning 1 (in all the cases) and
> incrementing "dev->stats.rx_errors" in the error cases?

To follow the standard calling convention as much as possible.
Look at what usbnet.c does:

        if (dev->driver_info->rx_fixup
                        && !dev->driver_info->rx_fixup (dev, skb))
                goto error;

Returning 0 is the error path (for better or worse),
while returning 1 is the success path.  So rx_fixup()
routines should not normally touch rx_errors, since
that's handled in the error path.

Plus, the other entry to the error path is returning
with skb->len =3D=3D 0.  You'll notice I changed things
to avoid doing that ... and that in some cases you
were both incrementing rx_error and emptying the SKB,
causing *two* errors to be reported.



> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D CUT HERE
> fixed :
>  - Zero length EEM packet support:
>     * Handle on TX side
>=20
>=20
> --- cdc_eem.c	2009-05-04 16:59:43.000000000 +0200
> +++ cdc_eem_v5.c	2009-05-04 17:07:20.000000000 +0200
> @@ -31,7 +31,6 @@
>  #include <linux/usb/cdc.h>
>  #include <linux/usb/usbnet.h>
>=20
> -
>  /*
>   * This driver is an implementation of the CDC "Ethernet Emulation
>   * Model" (EEM) specification, which encapsulates Ethernet frames
> @@ -122,11 +121,14 @@
>  	struct sk_buff	*skb2 =3D NULL;
>  	u16		len =3D skb->len;
>  	u32		crc =3D 0;
> +	int		padlen =3D 0;
>=20
> -	/* FIXME when ((len + EEM_HEAD + ETH_FCS_LEN) % dev->maxpacket)
> +	/* When ((len + EEM_HEAD + ETH_FCS_LEN) % dev->maxpacket)
>  	 * is zero, stick two bytes of zero length EEM packet on the end
>  	 * (so the framework won't add invalid single byte padding).
>  	 */
> +	if (!((len + EEM_HEAD + ETH_FCS_LEN) % dev->maxpacket))
> +		padlen +=3D 2;
>=20
>  	if (!skb_cloned(skb)) {
>  		int	headroom =3D skb_headroom(skb);

Close, but you also have to use "padlen + ETH_FCS_LEN"
when verifying there's enough space at the end of the
packet.  I'll fix that.


> @@ -145,7 +147,7 @@
>  		}
>  	}
>=20
> -	skb2 =3D skb_copy_expand(skb, EEM_HEAD, ETH_FCS_LEN, flags);
> +	skb2 =3D skb_copy_expand(skb, EEM_HEAD, ETH_FCS_LEN + padlen, flags=
);
>  	if (!skb2)
>  		return NULL;
>=20
> @@ -167,6 +169,10 @@
>  	len =3D skb->len;
>  	put_unaligned_le16(BIT(14) | len, skb_push(skb, 2));
>=20
> +	/* Add zero length EEM packet if needed */
> +	if (padlen)
> +		*skb_put(skb, 2) =3D (u16) 0;
> +
>  	return skb;
>  }
>=20
>=20



