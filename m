From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [PATCH] e1000 poll behavior
Date: Fri, 10 Dec 2004 17:19:36 +0100
Message-ID: <1102695576.12078.22.camel@tux.rsn.bth.se>
References: <16824.30773.125766.220826@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uCfZOX+FjD9Ul1SAZcD0"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16824.30773.125766.220826@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-uCfZOX+FjD9Ul1SAZcD0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-12-09 at 17:07, Robert Olsson wrote:
> Hello!
>=20
> Seems e1000 never gets into poll mode when tx_cleaned is false. Compare
> irq's on RX interfaces eth0, eth2 in the forwarding test below.

Yes, we discussed this in private some time ago, unfortunately I havn't
had any proper hardware to test my changes on :(

> --- drivers/net/e1000/e1000_main.c.orig	2004-12-09 17:49:56.000000000 +01=
00
> +++ drivers/net/e1000/e1000_main.c	2004-12-09 19:05:07.000000000 +0100
> @@ -2179,8 +2179,8 @@
>  	*budget -=3D work_done;
>  	netdev->quota -=3D work_done;
>  =09
> -	/* if no Rx and Tx cleanup work was done, exit the polling mode */
> -	if(!tx_cleaned || (work_done < work_to_do) ||=20
> +	/* if no Tx and not enough Rx work done, exit the polling mode */
> +	if((!tx_cleaned && (work_done < work_to_do)) ||=20
>  				!netif_running(netdev)) {
>  		netif_rx_complete(netdev);
>  		e1000_irq_enable(adapter);

This patch is broken.
What about the case where tx_cleaned is true but (work_done <
work_to_do) is true. Then the statement is false and we continue, later
we return (work_done >=3D work_to_do) which equals 0 (not seen in patch).
We are not allowed to return 0 when still on poll_list. That will sort
of continue polling in a degraded way (no increase in quota) but will
screw up device refcounting badly.

That final return must be changed into "return 1;"

--=20
/Martin

--=-uCfZOX+FjD9Ul1SAZcD0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBBucyXWm2vlfa207ERAoHvAJ95AJaO5ynq4ESESF+hIWjMpGJcaQCdHaFM
hO7YNHXsk8PWhJHEtqJSl6I=
=KFtZ
-----END PGP SIGNATURE-----

--=-uCfZOX+FjD9Ul1SAZcD0--
