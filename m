From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/1] ixgbe: force to synchronize reporting "link on" and
 getting speed and duplex
Date: Wed, 23 Dec 2015 02:54:06 -0800
Message-ID: <1450868046.3316.11.camel@intel.com>
References: <1450853205-27133-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-i39HEoMxk4e/F4clYfvp"
Cc: venkat.viswanathan@windriver.com, Boris.Shteinbock@windriver.com,
	Vincent.Bourg@windriver.com
To: zyjzyj2000@gmail.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65106 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753569AbbLWKyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 05:54:19 -0500
In-Reply-To: <1450853205-27133-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i39HEoMxk4e/F4clYfvp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-12-23 at 14:46 +0800, zyjzyj2000@gmail.com wrote:
> From: Zhu Yanjun <zyjzyj2000@gmail.com>
>=20
> In X540 NIC, there is a time span between reporting "link on" and
> getting the speed and duplex. To a bonding driver in 802.3ad mode,
> this time span will make it not work well if the time span is big
> enough. The big time span will make bonding driver change the state
> of
> the slave device to up while the speed and duplex of the slave device
> can not be gotten. Later the bonding driver will not have change to
> get the speed and duplex of the slave device. The speed and duplex of
> the slave device are important to a bonding driver in 802.3ad mode.
>=20
> To 82599_SFP NIC and other kinds of NICs, this problem does
> not exist. As such, it is necessary for X540 to report"link on" when
> the link speed is not IXGBE_LINK_SPEED_UNKNOWN.
>=20
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |=C2=A0=C2=A0=C2=A016
> +++++++++++++++-
> =C2=A01 file changed, 15 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index aed8d02..cb9d310 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -6479,7 +6479,21 @@ static void ixgbe_watchdog_link_is_up(struct
> ixgbe_adapter *adapter)
> =C2=A0	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(flow_rx ? "RX" :
> =C2=A0	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(flow_tx ? "TX" : "None"=
))));
> =C2=A0
> -	netif_carrier_on(netdev);
> +	/*
> +	=C2=A0* In X540 NIC, there is a time span between reporting "link
> on"
> +	=C2=A0* and getting the speed and duplex. To a bonding driver in
> 802.3ad
> +	=C2=A0* mode, this time span will make it not work well if the
> time span
> +	=C2=A0* is big enough. To 82599_SFP NIC and other kinds of NICs,
> this
> +	=C2=A0* problem does not exist. As such, it is better for X540 to
> report
> +	=C2=A0* "link on" when the link speed is not
> IXGBE_LINK_SPEED_UNKNOWN.
> +	=C2=A0*/
> +	if ((hw->mac.type =3D=3D ixgbe_mac_X540) &&
> +	=C2=A0=C2=A0=C2=A0=C2=A0(link_speed !=3D IXGBE_LINK_SPEED_UNKNOWN)) {
> +		netif_carrier_on(netdev);
> +	} else {
> +		netif_carrier_on(netdev);
> +	}
> +
> =C2=A0	ixgbe_check_vf_rate_limit(adapter);
> =C2=A0
> =C2=A0	/* enable transmits */

This patch only adds a needless test before
calling=C2=A0netif_carrier_on(netdev), since the call happens no matter the
branch you take, it appears your running into a timing issue. =C2=A0So
adding a wait() before calling=C2=A0netif_carrier_on(netdev) will accomplis=
h
the same result and you do not have to add a useless test.
--=-i39HEoMxk4e/F4clYfvp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWen1OAAoJEOVv75VaS+3OSwMP/1MUTI1RtWCuSZRN6daLgyc9
p7aejfgq+ta/mcmA5bjlyu1kJecyZXGdyHGK6Z78Dc5s2rnh4CyYnfg3QyDaxZrB
7Hskg2ujgkTuw5v9MGcpYYwzx1HwtvF05ZDsFVOJX7ngca7L4a1ojx2wJku/CLkA
vqIMuhAy8TlaeNA8EW3Rs5OnWeWR4Xptv4UYzfuedd1sKodWVcNG+j+LE7Z0a3Pv
qwzczpqovKpzxgMxzbuexbfZeMGHOpdXIs0oYcPWEITQv5vTPTDpm6VOKBvkRre8
XUxWyBN+y6F8hKai3ewCaY/O1DSrx9ih7Vg1NgIbi+ocDaTJvdfhlvgj9WXGlLl/
z4cjaUEEGi2DVclv2D1I6aVminIJCc7tWjjkNuHz9V/w4IGejaVpAJ0pnGefaRHN
mOAeTKiQj2RebBp8zr4Nqe7uGAn4BH+FPiwWIN999LgVaDwv3JLmJ/UHCa7bBkNN
0Ev1tdCrjBF+LqGcaCHHJoo2HotQP4KCq2ZyXuUph166RZ+X/CLppnNquTHJmvza
lcM28OaU1zYosU8ZkC+GDr1jgEVasf3mgUP2/ejYnnyM92S3eF9++eU12M+WuqBL
e4Gvgku7ZzarN4Zoooc0f/sMSCY+UFISE/8ZRCEoCs4ybcVctL9p6FzUakMHnKph
EAUw6V0Qe/ozucifBpWf
=vBdS
-----END PGP SIGNATURE-----

--=-i39HEoMxk4e/F4clYfvp--
