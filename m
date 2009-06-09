From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: error handling for dev_mc_sync (__dev_addr_add)
Date: Tue, 09 Jun 2009 19:04:22 +0200
Message-ID: <1244567063.18481.13.camel@johannes.local>
References: <1244556667.4672.18.camel@johannes.local>
	 <4A2E7376.4080407@trash.net> <1244558606.4672.25.camel@johannes.local>
	 <4A2E7929.9070705@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-LA3k7S6PkVxgjlK/K8ro"
Cc: netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59298 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbZFIREy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 13:04:54 -0400
In-Reply-To: <4A2E7929.9070705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LA3k7S6PkVxgjlK/K8ro
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-06-09 at 17:00 +0200, Patrick McHardy wrote:

> >> The problem on errors is that it can't determine which addresses
> >> were added in this run, and which were previously. So it can't undo
> >> just the actions of the last run. A generation count for da_synced
> >> could be used to fix that, but it would need to be bigger than the
> >> currently used u8.
> >=20
> > Hmm, ok, but in the da_synced case why is da_users not incremented? I
> > don't claim to understand any of this code though :)
>=20
> Its kind of a mess. In my excuse, it was even worse before the
> synchronization functions were added :)

Oh, I'm not blaming anyone :)

> The __dev_addr_sync() function is for both incremental additions and
> removals. In the da_synced (=3D=3D already synced) case, it deletes the
> address if it has a only a single reference left, which means its
> only held for unsychronization, and releases the address completely
> afterwards.

Hmm, ok.

> # grep -r set_multicast_list drivers/net/ | wc -l
> 499
>=20
> It probably includes some false positives, but I think its still
> quite a lot. You could of course add a new callback for those few
> drivers which actually can fail.
>=20
> > Regular drivers should need to be changed,
> > would they, except for adding changing 'return' to 'return 0;' and
> > adding a 'return 0;' at the end which is a quite simple spatch I'd
> > think.
>=20
> Right.

Yeah, so this spatch should be sufficient:

----- >% -----
@ ndomatch @
identifier ndo, sml;
@@
struct net_device_ops ndo =3D {
.ndo_set_multicast_list =3D sml,
};
@forall@
identifier dev;
identifier ndomatch.sml;
@@
void sml(struct net_device *dev)
{
...
-return;
+return 0;
...
}
----- %< -----

Haven't really tested it though but it seems to do the correct thing for
all drivers I looked at.

> > Not that I want to do that now, I'm just confused by the semantics here=
,
> > and the lack of error handling. Additionally, I'm worried if that might
> > be causing the occasional 'multicast leaked' messages I was seeing, but
> > I doubt it.
>=20
> It shouldn't cause this from what I can tell.

Ok, good, thanks.

johannes

--=-LA3k7S6PkVxgjlK/K8ro
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKLpYSAAoJEODzc/N7+QmaGqUP/j1CP4bvVqLwrSdynr2iW3eE
5aE8QHJVRQkpV5E/w5pahwoSTDy6/KCuAote6XvrXIAyGwgKe9lDjiblJGND5w+n
2C6fRe+iB7aaUl6Rm9nZxoWIgFvh+nrJG7+YZGlqUGmcTjGWg1kKcYA8gUOM+rX5
1/awyJmFOoxv3OExn9KZ4E+oxBnm8uHs6uu1CmJO78EijJshN9sYSiWGh8qZ+y0q
J5QBDbCaFbhHffmJx4zsYinxgbUEDzbUs44Ezx/xIOb0+xcO3PVd7VWocw9xie4n
yv7vUwn0qaLa1r5EWdGtMvSd/KutDEUSRc3W37rfp/1lppiGbgRcl8eJ/KX3uCM6
RWdQ0EBZIX6iGldmF99yoUkQtEP1QnU9deG7mblmH94IzcfalBaGgVBWPO6N1l+Q
b3l/5HjXBD32Nud+WX8toAOId7/fZg70pcTrTrv9jkeHyCzs0jnwSpMGqDvK4Qgj
MJCnfSEgWCQgF8PlVCtOkUgchXZs1aZNnjFRHwlrvODVkqjUwFdZz+02Yh5mBa+Y
kfOCP41M1U0vuVkM7IL8R+qrh6FWiVjxzOYzsc8xmt7jGdSnysGqgBKXvJxXy5uo
P2eWuWeD9PUjzGXlvFcOT2YAp8eLw8ZGfhTR5VZSzKVd8AWANE0A2mfYdJSzFR+6
f8O5niwVyJ3BK0HCl+1B
=j+n+
-----END PGP SIGNATURE-----

--=-LA3k7S6PkVxgjlK/K8ro--

