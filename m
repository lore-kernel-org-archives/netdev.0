From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/2] usbnet: Convert dev(dbg|err|warn|info) macros to
 netdev_<level>
Date: Mon, 15 Feb 2010 01:17:46 +0100
Message-ID: <4B7892AA.7000305@imap.cc>
References: <20100212.123837.56526847.davem@davemloft.net> <cover.1266187669.git.joe@perches.com> <ec60c0152394dbca309a66072035b92342d8bf7b.1266187670.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB383FED137101E5C18C15175"
Cc: David Miller <davem@davemloft.net>,
	David Brownell <david-b@pacbell.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:46272 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754874Ab0BOASH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 19:18:07 -0500
In-Reply-To: <ec60c0152394dbca309a66072035b92342d8bf7b.1266187670.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB383FED137101E5C18C15175
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Am 15.02.2010 00:01 schrieb Joe Perches:
> Some logging messages were in the form:
>=20
> 	printk(KERN_<level> "msg %s%s%s%s\n",
> 	       value =3D=3D 1 ? "one" : "",
> 	       value =3D=3D 2 ? "two" : "",
> 	       value =3D=3D 3 ? "three" : "",
> 	       value =3D=3D 4 ? "four" : "unknown");
>=20
> Converted to:
>=20
> 	printk(KERN_<level> "msg %s\n",
> 	       value =3D=3D 1 ? "one" :
> 	       value =3D=3D 2 ? "two" :
> 	       value =3D=3D 3 ? "three" :
> 	       value =3D=3D 4 ? "four" : "unknown");
[...]
> diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
> index aeb1ab0..aa078f3 100644
> --- a/drivers/net/usb/net1080.c
> +++ b/drivers/net/usb/net1080.c
> @@ -205,23 +205,24 @@ static inline void nc_dump_usbctl(struct usbnet *=
dev, u16 usbctl)
>  {
>  	if (!netif_msg_link(dev))
>  		return;
> -	devdbg(dev, "net1080 %s-%s usbctl 0x%x:%s%s%s%s%s;"
> -			" this%s%s;"
> -			" other%s%s; r/o 0x%x",
> -		dev->udev->bus->bus_name, dev->udev->devpath,
> -		usbctl,
> -		(usbctl & USBCTL_ENABLE_LANG) ? " lang" : "",
> -		(usbctl & USBCTL_ENABLE_MFGR) ? " mfgr" : "",
> -		(usbctl & USBCTL_ENABLE_PROD) ? " prod" : "",
> -		(usbctl & USBCTL_ENABLE_SERIAL) ? " serial" : "",
> -		(usbctl & USBCTL_ENABLE_DEFAULTS) ? " defaults" : "",
> -
> -		(usbctl & USBCTL_FLUSH_OTHER) ? " FLUSH" : "",
> -		(usbctl & USBCTL_DISCONN_OTHER) ? " DIS" : "",
> -		(usbctl & USBCTL_FLUSH_THIS) ? " FLUSH" : "",
> -		(usbctl & USBCTL_DISCONN_THIS) ? " DIS" : "",
> -		usbctl & ~USBCTL_WRITABLE_MASK
> -		);
> +	netdev_dbg(dev->net, "net1080 %s-%s usbctl 0x%x:%s;"
> +		   " this%s;"
> +		   " other%s; r/o 0x%x\n",
> +		   dev->udev->bus->bus_name, dev->udev->devpath,
> +		   usbctl,
> +		   (usbctl & USBCTL_ENABLE_LANG) ? " lang" :
> +		   (usbctl & USBCTL_ENABLE_MFGR) ? " mfgr" :
> +		   (usbctl & USBCTL_ENABLE_PROD) ? " prod" :
> +		   (usbctl & USBCTL_ENABLE_SERIAL) ? " serial" :
> +		   (usbctl & USBCTL_ENABLE_DEFAULTS) ? " defaults" : "",
> +
> +		   (usbctl & USBCTL_FLUSH_OTHER) ? " FLUSH" :
> +		   (usbctl & USBCTL_DISCONN_OTHER) ? " DIS" : "",
> +
> +		   (usbctl & USBCTL_FLUSH_THIS) ? " FLUSH" :
> +		   (usbctl & USBCTL_DISCONN_THIS) ? " DIS" : "",
> +
> +		   usbctl & ~USBCTL_WRITABLE_MASK);
>  }
> =20
>  /*--------------------------------------------------------------------=
-----*/

That doesn't look right. The original code concatenates all the strings
corresponding to the set bits in usbctl. With your patch, it prints only
the string corresponding to the first set bit it encounters within each
group. Eg. with USBCTL_FLUSH_OTHER and USBCTL_DISCONN_OTHER both set,
the original code would print "this FLUSH DIS", while your version would
only print "this FLUSH".

Btw, is it intentional that the _OTHER values are printed after the
label "this", and the _THIS values after the label "other"?

> @@ -250,28 +251,25 @@ static inline void nc_dump_status(struct usbnet *=
dev, u16 status)
>  {
>  	if (!netif_msg_link(dev))
>  		return;
> -	devdbg(dev, "net1080 %s-%s status 0x%x:"
> -			" this (%c) PKT=3D%d%s%s%s;"
> -			" other PKT=3D%d%s%s%s; unspec 0x%x",
> -		dev->udev->bus->bus_name, dev->udev->devpath,
> -		status,
> -
> -		// XXX the packet counts don't seem right
> -		// (1 at reset, not 0); maybe UNSPEC too
> -
> -		(status & STATUS_PORT_A) ? 'A' : 'B',
> -		STATUS_PACKETS_THIS(status),
> -		(status & STATUS_CONN_THIS) ? " CON" : "",
> -		(status & STATUS_SUSPEND_THIS) ? " SUS" : "",
> -		(status & STATUS_MAILBOX_THIS) ? " MBOX" : "",
> -
> -		STATUS_PACKETS_OTHER(status),
> -		(status & STATUS_CONN_OTHER) ? " CON" : "",
> -		(status & STATUS_SUSPEND_OTHER) ? " SUS" : "",
> -		(status & STATUS_MAILBOX_OTHER) ? " MBOX" : "",
> -
> -		status & STATUS_UNSPEC_MASK
> -		);
> +	netdev_dbg(dev->net, "net1080 %s-%s status 0x%x: this (%c) PKT=3D%d%s=
; other PKT=3D%d%s; unspec 0x%x\n",
> +		   dev->udev->bus->bus_name, dev->udev->devpath,
> +		   status,
> +
> +		   // XXX the packet counts don't seem right
> +		   // (1 at reset, not 0); maybe UNSPEC too
> +
> +		   (status & STATUS_PORT_A) ? 'A' : 'B',
> +		   STATUS_PACKETS_THIS(status),
> +		   (status & STATUS_CONN_THIS) ? " CON" :
> +		   (status & STATUS_SUSPEND_THIS) ? " SUS" :
> +		   (status & STATUS_MAILBOX_THIS) ? " MBOX" : "",
> +
> +		   STATUS_PACKETS_OTHER(status),
> +		   (status & STATUS_CONN_OTHER) ? " CON" :
> +		   (status & STATUS_SUSPEND_OTHER) ? " SUS" :
> +		   (status & STATUS_MAILBOX_OTHER) ? " MBOX" : "",
> +
> +		   status & STATUS_UNSPEC_MASK);
>  }
> =20
>  /*--------------------------------------------------------------------=
-----*/

Same problem.

HTH
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enigB383FED137101E5C18C15175
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAkt4krUACgkQQ3+did9BuFv6WwCgl9B+mYdcGHsu5u4iIzeZT4/v
pX0Anjtcb71tUVKweeSCxPioWvqyALU3
=xJxm
-----END PGP SIGNATURE-----

--------------enigB383FED137101E5C18C15175--
