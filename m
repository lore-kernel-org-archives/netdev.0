From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 5/6] wl1251: Parse and use MAC address from supplied NVS
 data
Date: Sat, 24 Dec 2016 19:14:21 +0100
Message-ID: <20161224181421.GC13590@amd>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-6-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="S1BNGpv0yoYahz37"
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1482598381-16513-6-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--S1BNGpv0yoYahz37
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat 2016-12-24 17:53:00, Pali Roh=E1r wrote:
> This patch implements parsing MAC address from NVS data which are sent to
> wl1251 chip. Calibration NVS data could contain valid MAC address and it
> will be used instead randomly generated.

will be used instead of randomly generated one.

> This patch also move code for requesting NVS data from userspace to driver

"moves"

> initialization code to make sure that NVS data will be there at time when
> permanent MAC address is needed.

"at a time"

> Calibration NVS data for wl1251 are model specific. Every one device with

"device specific"? "Every device".

> wl1251 chip should have been calibrated in factory and needs to provide o=
wn
> calibration data.
>=20
> Default example wl1251-nvs.bin data found in linux-firmware repository and

"are found"

> contains MAC address 00:00:20:07:03:09. So this MAC address is marked as

"contain"

> invalid as it is not real device specific address, just example one.
>=20
> Format of calibration NVS data can be found at:
> http://notaz.gp2x.de/misc/pnd/wl1251/nvs_map.txt
>=20
> Signed-off-by: Pali Roh=E1r <pali.rohar@gmail.com>
> ---
>  drivers/net/wireless/ti/wl1251/main.c |   39 ++++++++++++++++++++++++++-=
------
>  1 file changed, 31 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless=
/ti/wl1251/main.c
> index c3fa0b6..1454ba2 100644
> --- a/drivers/net/wireless/ti/wl1251/main.c
> +++ b/drivers/net/wireless/ti/wl1251/main.c
> @@ -205,13 +205,6 @@ static int wl1251_chip_wakeup(struct wl1251 *wl)
>  			goto out;
>  	}
> =20
> -	if (wl->nvs =3D=3D NULL && !wl->use_eeprom) {
> -		/* No NVS from netlink, try to get it from the filesystem */
> -		ret =3D wl1251_fetch_nvs(wl);
> -		if (ret < 0)
> -			goto out;
> -	}
> -
>  out:
>  	return ret;
>  }
> @@ -1538,6 +1531,30 @@ static int wl1251_read_eeprom_mac(struct wl1251 *w=
l)
>  	return 0;
>  }
> =20
> +static int wl1251_read_nvs_mac(struct wl1251 *wl)
> +{
> +	u8 mac[ETH_ALEN];
> +	int i;
> +
> +	if (wl->nvs_len < 0x24)
> +		return -ENODATA;
> +
> +	/* length is 2 and data address is 0x546c (mask is 0xfffe) */
> +	if (wl->nvs[0x19] !=3D 2 || wl->nvs[0x1a] !=3D 0x6d || wl->nvs[0x1b] !=
=3D 0x54)
> +		return -EINVAL;
> +
> +	/* MAC is stored in reverse order */
> +	for (i =3D 0; i < ETH_ALEN; i++)
> +		mac[i] =3D wl->nvs[0x1c + ETH_ALEN - i - 1];
> +
> +	/* 00:00:20:07:03:09 is in default example wl1251-nvs.bin, so invalid */

remove "default".

> +	if (ether_addr_equal_unaligned(mac, "\x00\x00\x20\x07\x03\x09"))
> +		return -EINVAL;
> +
> +	memcpy(wl->mac_addr, mac, ETH_ALEN);
> +	return 0;
> +}
> +
>  static int wl1251_register_hw(struct wl1251 *wl)
>  {
>  	int ret;
> @@ -1581,10 +1598,16 @@ int wl1251_init_ieee80211(struct wl1251 *wl)
> =20
>  	wl->hw->queues =3D 4;
> =20
> +	if (wl->nvs =3D=3D NULL && !wl->use_eeprom) {
> +		ret =3D wl1251_fetch_nvs(wl);
> +		if (ret < 0)
> +			goto out;
> +	}

Is goto out here good idea? IMNSHO it is copy&paste bug, it should
just proceed with generating random address.

>  	if (wl->use_eeprom)
>  		ret =3D wl1251_read_eeprom_mac(wl);
>  	else
> -		ret =3D -EINVAL;
> +		ret =3D wl1251_read_nvs_mac(wl);
> =20
>  	if (ret =3D=3D 0 && !is_valid_ether_addr(wl->mac_addr))
>  		ret =3D -EINVAL;

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--S1BNGpv0yoYahz37
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlheuv0ACgkQMOfwapXb+vKARgCghV/H0hHp+ZnaUpaS7KImU99z
QM4AnjH6IvqOkuGibtSOhds4YWPEOKIG
=nOeh
-----END PGP SIGNATURE-----

--S1BNGpv0yoYahz37--
