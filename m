From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 03:42:34 +0200
Message-ID: <1209865354.6210.23.camel@johannes.berg>
References: <1209760731.3608.17.camel@johannes.berg>
	 <20080502.163334.148944203.davem@davemloft.net>
	 <1209815533.3987.21.camel@johannes.berg>
	 <20080503.180300.10562559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mdUPoX/r1KBEaVloWJMB"
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080503.180300.10562559.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-mdUPoX/r1KBEaVloWJMB
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


> > Why don't we update the socket allocation when doing pskb_expand_head()=
?
> > Sure, it could become negative, but is that so bad?
>=20
> The socket locked state at this time is variable and unknown.
>=20
> The socket must be locked in order to modify these values.
> And such locks cannot be taken, for example, from HW interrupt
> context, amongst other restrictions.

Ok, that makes sense.

> > We need more space though. Should we then just increase the built-in
> > headroom?
>=20
> I simply don't know what to suggest at this point, that's why
> we are having this discussion :-)

I'm still not sure about the dependencies between LL_MAX_HEADER,
dev->hard_header_len and similar. Why, for example, does ipip set it to
LL_MAX_HEADER + sizeof(struct iphdr)? Because it doesn't know better
since the packets it creates could be routed anywhere?

Could mac80211 announce it needs a very long hard_header_len (say 48 (or
54) bytes)? Am I right in thinking that then we'd have to increase
LL_MAX_HEADER as well? I haven't found a check somewhere that warns you
if you set dev->hard_header_len > LL_MAX_HEADER, should there be one?

If I increase dev->hard_header_len, will that have any negative impact
on the caching since I'm still just using regular ethernet headers?


As far as I understand we have a few options:

 (a) go along with it as we do now, use pskb_expand_head, just call
     skb_orphan before. I assume this has a number of requirements just
     like sock size accounting would have, does this work from within a
     hard_start_xmit path? I haven't seen any problems with it so far
     anyway.
 (b) clone the skb and free the original. pretty much equivalent
 (c) increase hard_header_len/LL_MAX_HEADER constants to 48 (54).

Options (a) and (b) make the accounting pretty useless since that would
drop the charge to the socket quite early. (c) doesn't seem to work, I
tried =EF=BB=BFjust increasing LL_MAX_HEADER doesn't seem to help although
MAX_TCP_HEADER suggests it should be getting enough headroom then.

Ideally, we'd have enough headroom in the skb to start with, since right
now we're apparently reallocating a lot, especially encrypted frames.
Not that I understand why we don't get a truesize bug (without the
monitors) when we do that.

With smart hardware like b43 we could even think about putting the
802.11 header stuff into a separate buffer and have the hardware to
gather-dma but there are so many dumb usb devices that this won't help
much anyway.

johannes

--=-mdUPoX/r1KBEaVloWJMB
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB0UiaVg1VMiehFYAQLxIQ/6A7IrW6+mxn9GXwKy4SitmraNvJ1B1GIE
a9U4n42lAT3Hhnfi+kulNVGXkbLIyZWshFr8qhErd7ryURkrxW8k1O+gXvzluwSL
AnBPi0rVdHNWky1FI40wC2SGBK8X237QSjApoFAYu/eGA9cCGNJ1UgN6MuSJcmyt
WWhE4d9oiYAzHW13Tk3ZbiV/aANjabePO5bTjCIvdUUvpnWJxQyue1CSo3duG3lB
98k52Z15ufsnUd5G+Gfh6yQjpDxJ0rNmV7UrRprHo0x1tcnDJSCtOPgcaxiH/GRT
rC1DKG4dlSKBq7EjA3WyZILguJQwAKD3WEz/fuCoCz5o4v1N3tyB8TgtHNIqu1fo
4s5zcHh9/WixsqCTdq+WS4KuFeOew/c/sGr8GD5gb5ygQfq3qr7BWtijGCFbgxCA
LAGSu641P325ELLf6145BGdJrohjJ5Z3dkAx2/OCQqgjQwtUyYAgCrwi3Bu16E8X
DfXXNlsgDFUdQ+FgGpwdMeDOuAKNJJtO9J4zOpM64un0qEfIfetqxGyFmACQKOnm
HKtWQN3n6KJU/CK0YWS06BEZFjKB0SKZHZL3lp8VwqQDWdY5BGbU92R9JiCfqyAW
rhGRp6sT5roW7DCTNP3s8q1f7IL7jj4dxevdt1zR8Ew/E+//JygBfNWoCXQbk/uh
tzd464Mvltc=
=CaVE
-----END PGP SIGNATURE-----

--=-mdUPoX/r1KBEaVloWJMB--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
