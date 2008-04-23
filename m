From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Fix race between ieee80211_rx_bss_put and
	lookup routines.
Date: Wed, 23 Apr 2008 09:53:49 +0200
Message-ID: <1208937230.31429.60.camel@johannes.berg>
References: <480EE983.4020209@openvz.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rRGNBGUfbN2oGHL1FeQ2"
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480EE983.4020209-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-rRGNBGUfbN2oGHL1FeQ2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2008-04-23 at 11:47 +0400, Pavel Emelyanov wrote:
> The put routine first decrements the users counter and then
> (if it is zero) locks the sta_bss_lock and removes one from
> the list and the hash.
>=20
> Thus, any of ieee80211_sta_config_auth, ieee80211_rx_bss_get
> or ieee80211_rx_mesh_bss_get can race with it by finding a
> bss that is about to get kfree-ed.
>=20
> Using atomic_dec_and_lock in ieee80211_rx_bss_put takes care
> of this race.

Good catch, thanks.

> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Acked-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

I think we will need this in -stable (different file, same contents)

> ---
>=20
> diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
> index 6b75cb6..dac3c2a 100644
> --- a/net/mac80211/mlme.c
> +++ b/net/mac80211/mlme.c
> @@ -2248,10 +2248,13 @@ static void ieee80211_rx_bss_put(struct net_devic=
e *dev,
>  				 struct ieee80211_sta_bss *bss)
>  {
>  	struct ieee80211_local *local =3D wdev_priv(dev->ieee80211_ptr);
> -	if (!atomic_dec_and_test(&bss->users))
> +
> +	local_bh_disable();
> +	if (!atomic_dec_and_lock(&bss->users, &local->sta_bss_lock)) {
> +		local_bh_enable();
>  		return;
> +	}
> =20
> -	spin_lock_bh(&local->sta_bss_lock);
>  	__ieee80211_rx_bss_hash_del(dev, bss);
>  	list_del(&bss->list);
>  	spin_unlock_bh(&local->sta_bss_lock);
>=20

--=-rRGNBGUfbN2oGHL1FeQ2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASA7rDKVg1VMiehFYAQIGGBAAhI+C4JZYmVANKUiIC2BwY6LfB0eIlOCl
xnB+fCsRMfW3Yv/+6KaEg8dYK+Nqyw9yuNo4wejpE51wtj6qHGRQGmQp8D8LwH/N
9QsO/X2FhfQWU7tMe7/8fSdbIk1YFOC17WjAli8F0MHaIZwJ1w6gPSN6TrCdilWr
ivYH/PAOXDtqjNG50ugE5BypSEXQFGNL4BhvGI1fphteQFe9wYmvfnVfmyuQxcdW
xfJNDJFBrcA5w24QKPOWaHg3Ub8eIAVHP92h+mEMSJDj9lr9b/M060ebTSipcUwm
qhEdUkiLghE/nOPYcjqkLd8fMlNLTcK5QlI9cbSjr3zStw0cL3W5wkojEIQvTe2t
SMVoHTKuYjx71TAo3Ia9/qQlnK7Xh2/aBHg0n9xUwh9ZxA8AaOrzvXFr0GdBc92s
lxM54kXvbMaoGeMsnqs7b0A7sdoB1v6e0E9GFStcEhok0Val7d0tBiMAjPHwUeCp
fdDDZKZ8GWvY6xEXVx0oakgjz4l3C9sNRPt2zAvBKBavl0lHRJETZzF1ttSxp8PH
NqbuyN1pvu5gkNOWSP8TrE+PiqVnPYYFrpbMqNjCM1JsT44MjSCT9rnOwj9lP5sl
OZsmceWp1rNlVNtbPT5HW8Hg3ZJ94EG/4vxqgKC6BY2hu41/eQChSY0vfN5h/FWs
+bxCzndZBXo=
=iFLl
-----END PGP SIGNATURE-----

--=-rRGNBGUfbN2oGHL1FeQ2--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
