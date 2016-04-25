From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH RFC] b43: stop hardcoding LED behavior
Date: Mon, 25 Apr 2016 17:53:26 +0200
Message-ID: <20160425175326.407eba27@wiggum>
References: <1461570051-3950-1-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/UVwYT3RFCi7sm2Ue3m9ZY58"; protocol="application/pgp-signature"
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461570051-3950-1-git-send-email-dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Sig_/UVwYT3RFCi7sm2Ue3m9ZY58
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 25 Apr 2016 09:40:51 +0200
Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org> wrote:

> On my system the SPROM correctly defines the only wired LED (radio) but
> skips all others, leading to the hardcode to register LEDs with RX and TX
> triggers.

Hm ok. It probably is a good idea to change the condition from

if (sprom[led_index] =3D=3D 0xFF)

to

if ((sprom[0] & sprom[1] & sprom[2] & sprom[3]) =3D=3D 0xFF)

So the hardcoding only happens if there is no LED configured in the
SPROM. (I think my card does this (see below), but I can check that
later)


> These triggers cause many uneccesary CPU wakeups to drive LEDs
> that aren't even present in the system, reducing battery runtime.


Numbers please. Did you measure that is actually causes more _wakeups_?
How many?
The led work is placed in the mac80211 workqueue and LED updates only
happen on behalf of mac80211 activities (by default). It only causes
additional wakeups, if there's nothing else scheduled on the workqueue
anyways (which might well be the case. So we need numbers. :)


> Remove the hardcode to stop it from doing any harm. If this code is useful
> for others it should probably be reworked as a quirk table triggering only
> for individual systems that need it.


There are cards that need it. I don't know how many that are, but I own
an older 4306 PC-Card card that needs this.

So this effectively is a regression for this card.

So I don't think this is acceptable.
You should at least make this configurable via module parameter or such.
Or maybe the change from above already is enough. It should work for
your case.


> Signed-off-by: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
> ---
>  drivers/net/wireless/broadcom/b43/leds.c | 26 ++------------------------
>  1 file changed, 2 insertions(+), 24 deletions(-)
>=20
> diff --git a/drivers/net/wireless/broadcom/b43/leds.c b/drivers/net/wirel=
ess/broadcom/b43/leds.c
> index d79ab2a..77d2dad 100644
> --- a/drivers/net/wireless/broadcom/b43/leds.c
> +++ b/drivers/net/wireless/broadcom/b43/leds.c
> @@ -224,31 +224,9 @@ static void b43_led_get_sprominfo(struct b43_wldev *=
dev,
> =20
>  	if (sprom[led_index] =3D=3D 0xFF) {
>  		/* There is no LED information in the SPROM
> -		 * for this LED. Hardcode it here. */
> +		 * for this LED. Keep it disabled. */
>  		*activelow =3D false;
> -		switch (led_index) {
> -		case 0:
> -			*behaviour =3D B43_LED_ACTIVITY;
> -			*activelow =3D true;
> -			if (dev->dev->board_vendor =3D=3D PCI_VENDOR_ID_COMPAQ)
> -				*behaviour =3D B43_LED_RADIO_ALL;
> -			break;
> -		case 1:
> -			*behaviour =3D B43_LED_RADIO_B;
> -			if (dev->dev->board_vendor =3D=3D PCI_VENDOR_ID_ASUSTEK)
> -				*behaviour =3D B43_LED_ASSOC;
> -			break;
> -		case 2:
> -			*behaviour =3D B43_LED_RADIO_A;
> -			break;
> -		case 3:
> -			*behaviour =3D B43_LED_OFF;
> -			break;
> -		default:
> -			*behaviour =3D B43_LED_OFF;
> -			B43_WARN_ON(1);
> -			return;
> -		}
> +		*behaviour =3D B43_LED_OFF;
>  	} else {
>  		*behaviour =3D sprom[led_index] & B43_LED_BEHAVIOUR;
>  		*activelow =3D !!(sprom[led_index] & B43_LED_ACTIVELOW);




--=20
Michael

--Sig_/UVwYT3RFCi7sm2Ue3m9ZY58
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXHj12AAoJEPUyvh2QjYsOR9kP/3E/xSeP+7F/bAHho7t+iHRY
4JoixlrluJboHbDsnkzfLNOyz+MsE2TbmimbRgMoC4Q447N2nFTbcLHWXRV0uZJ1
WEhepDva95w/BaaDCuXPucvJrma9l8TasEY8J2Av2eIcVSge8EhXPopXLBjsCbi+
49cYT/dDtb4J4+YPLFEx3/7FQOTp0A8JoST4A7Dk2ZZ6q6XgcHaXgwv3v5MDOWvB
7fWVJJ0Faz/y2Q8WwyTmuBu9tknDBVztKqiM5c+pDnyBjVAsqD6tjpRKd2J4zh45
AZXXRBNlVkYdgCEPo6LJ9Trr9zwtKVfUmdG2OGm1MOiiYmAGt/Oq7+4/0daNWIY8
hom3lSj5NavzuPM6yLw5whDMyr/OP0+f24JeW2ERfIGMwDP2q8E9vjm9WTNOye1E
dPkV/IMfyeRaZPrgy0SSUroDT5Cdrz9N/5tFpnIrsBMvBCqq2rdsqbm8iPildU5y
v/0dAaSlP3qDIJ11N+yJwMTxGuh2vpOPTgQgT2FS5wEHrUMMhWUETdPX3v8DlfgH
MexanHDKRJGWyBS6tsRK/jOr5saRLrRzwOwFwc7yz/vENk1Uk+fFVQMIrApLCUTJ
YrNNYNJ/3UMgdJvb51WG8V5+IYdoicGMgZ/6rOesEMp2KeIUIHvpdTbPe+78OdMu
5XIhffCtpLDNJdL+JmAZ
=MNk/
-----END PGP SIGNATURE-----

--Sig_/UVwYT3RFCi7sm2Ue3m9ZY58--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
