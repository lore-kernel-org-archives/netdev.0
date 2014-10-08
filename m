From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: Indicate failure on vf reset for empty mac address
Date: Wed, 08 Oct 2014 15:29:15 -0700
Message-ID: <1412807355.2260.17.camel@jtkirshe-mobl.jf.intel.com>
References: <1412803407-10621-1-git-send-email-agraf@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/abLlJXioHUfEfGJ+cPw"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Stefan Assmann <sassmann@kpanic.de>,
	Aaron Brown <aaron.f.brown@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Alexander Graf <agraf@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11055 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755430AbaJHW3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 18:29:35 -0400
In-Reply-To: <1412803407-10621-1-git-send-email-agraf@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/abLlJXioHUfEfGJ+cPw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-08 at 23:23 +0200, Alexander Graf wrote:
> Commit 5ac6f91d changed the igb driver to expose a zero (empty) mac
> address to the VF on reset rather than a random one.
>=20
> However, that behavioral change also requires igbvf driver changes
> which can be hard especially when we want to talk to proprietary
> guest OSs.
>=20
> Looking at the code previous to the commit in Linux that made igbvf
> work with empty mac addresses (8d56b6d), we can see that on reset
> failure the driver will try to generate a new mac address with both
> the old and the new code.
>=20
> Furthermore, ixgbe does send reset failure when it detects an empty
> mac address (35055928c).
>=20
> So I think it's safe to make igb behave the same. With this patch I
> can successfully run a Windows 8.1 guest with an empty mac address
> and an assigned igbvf device that has no mac address set by the host.
>=20
> If anyone is aware of a guest driver that chokes on NACK returns of
> VF RESET commands, please speak up.
>=20
> Signed-off-by: Alexander Graf <agraf@suse.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)

Actually after further review of this patch and the reported bug in
SuSE's bugzilla, we are NACK'ing this patch.

If the reset has not failed, why are we indicating that it has?  We
originally supplied the VF with a NULL MAC, so we should supply it
again.  That way, the VF can choose to either regenerate a new random
MAC or keep using the one that it had.

The current method was a fix that was requested by the community in the
first place, also we cannot take into account "proprietary guest OS's".

>=20
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethe=
rnet/intel/igb/igb_main.c
> index cb14bbd..e8c53b6 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -6024,8 +6024,12 @@ static void igb_vf_reset_msg(struct igb_adapter *a=
dapter, u32 vf)
>  	adapter->vf_data[vf].flags |=3D IGB_VF_FLAG_CTS;
> =20
>  	/* reply to reset with ack and vf mac address */
> -	msgbuf[0] =3D E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
> -	memcpy(addr, vf_mac, ETH_ALEN);
> +	if (!is_zero_ether_addr(vf_mac)) {
> +		msgbuf[0] =3D E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
> +		memcpy(addr, vf_mac, ETH_ALEN);
> +	} else {
> +		msgbuf[0] =3D E1000_VF_RESET | E1000_VT_MSGTYPE_NACK;
> +	}
>  	igb_write_mbx(hw, msgbuf, 3, vf);
>  }
> =20



--=-/abLlJXioHUfEfGJ+cPw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUNbq7AAoJEOVv75VaS+3OgzAP/2EynCUTqEHCqk/piUUyj1ZY
g6V2qTsid0qqHS/Rra7WFedKF0GlOam+ztJjw9VFYpTtRUiYpGiVdN4ONpS4b52M
mUfU1oLECCXYUsflZlKNJi+YYZ3dQPHvxqtNjLsFE+se6K+XuzbtPQ3q0gGsEDIS
xtvzFETd8jLuwr7Yh1hWC4E0dc8WoPP/PKaf7w3S7purUN8qsgQ3WqGEJSQVWMC6
yRtIYJnSNG5rCbCgq6NOPEkbUQPkjcmGtsWRcRbrvMWyLgqTHqeHoh72p1IYXohL
Wt/Nkiq7GUnnKDRNkRcfIwkXln9xQqVYHA94T4vgm2hBhrSjygPV68pdmRcwviMk
X+z/nmoWaIBzhvwaqrtD7GRd004qoaf2dlyrhM2BIPaLVN+NWPffrZ+2tF8NfRBF
5qemRqU9AtMlL/q80LdvlWNVuM6P03D4D+U4rUMi6bBpabkbkvL8KNI1/G6Mfs6l
Xvn6DVZo+0WoDSI97mTvLM0bLZv6u3B+GpiZk1ikH4bUUaEcdKI88I7gijVq+6G+
F1q/aPALyPO0PemJAXCaXpwl8g7VT+YQ3iXk6FJ0khBXV+VQ+HoM3Bi6oSkR4dB3
oJuPjFZJYCQUsmkj/DCcSAdrgMydfWo2rjnEsauj1XhHRq+9gPqhNRbTWkb5lH0Q
efzFe3v7r3JcEDzWhNe5
=bB80
-----END PGP SIGNATURE-----

--=-/abLlJXioHUfEfGJ+cPw--
