From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] usb:smsc: preserve MAC address when resetting device
Date: Tue, 1 Feb 2011 12:24:25 +0100
Message-ID: <20110201112425.GA3407894@jupiter.n2.diac24.net>
References: <1296556457-4969-1-git-send-email-sakib@meta.ua>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BOKacYhQ+x31HxR3"
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Sergiy Kibrik <sakib@meta.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:55590 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113Ab1BALwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Feb 2011 06:52:05 -0500
Content-Disposition: inline
In-Reply-To: <1296556457-4969-1-git-send-email-sakib@meta.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 01, 2011 at 12:34:17PM +0200, Sergiy Kibrik wrote:
> Initialize MAC address only once, when device opened first time
> to avoid generation random addresses when failed to read one from ROM.
>=20
> Some hardware hasn't hw address in ROM, e.g. Pandaboard  (http://pandaboa=
rd.org),
> so every time device is up, its address is regenerated again.
> It makeis impossible to set custom hw address and also makes DHCP servers=
 and switches crazy.
[snip]
> +++ b/drivers/net/usb/smsc75xx.c
> @@ -77,6 +77,7 @@ struct usb_context {
>  };
> =20
>  static int turbo_mode =3D true;
> +static int first_reset =3D true;
>  module_param(turbo_mode, bool, 0644);
>  MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction"=
);
> =20
> @@ -836,7 +837,10 @@ static int smsc75xx_reset(struct usbnet *dev)
> =20
>  	netif_dbg(dev, ifup, dev->net, "PHY reset complete");
> =20
> -	smsc75xx_init_mac_address(dev);
> +	if (first_reset){
> +		smsc75xx_init_mac_address(dev);
> +		first_reset =3D false;
> +	}
[snip]

You cannot do that. Imagine if I plug in two devices. Only the first one
will get a MAC properly. Or imagine if i plug a device, unplug it and
plug it back. It will have an uninitialized mac address.

You need to move the init_mac_address call to happen on device plug-in.


-David


--BOKacYhQ+x31HxR3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk1H7WkACgkQpfBGV6DCGYa0UQCgh8lCBT7/yQ6NLR3kRmsXgjH8
kV0An0BJI7GvVdf6H7tk88OCEm8AG5p1
=5MxR
-----END PGP SIGNATURE-----

--BOKacYhQ+x31HxR3--
