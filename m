From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 09:22:19 +0200
Message-ID: <1209972139.3655.9.camel@johannes.berg>
References: <1209936253.7304.10.camel@johannes.berg>
	 <1209936745.7304.16.camel@johannes.berg>
	 <20080504.173051.133197507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sQgKu33CsBIoURX49bcW"
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080504.173051.133197507.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-sQgKu33CsBIoURX49bcW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Where is the patch that adds these new members to struct netdevice,
> and where is the code that uses these new values?

Inlined below this time.

> Anyways I see your basic idea and this may be the best way to handle
> the problem.  The invariants would be:
>=20
> 1) LL_MAX_HEADER has to include all of these bits.

Yes. Well, it has to be long enough for it, yes, but mac80211 has
drivers that want 100 bytes more headroom for themselves and probably
won't get added to LL_MAX_HEADER. But still putting that much into
needed_headroom is beneficial for many cases even if that means that
some packets will have to be copy-expanded. This, however, means that
you cannot put an assertion into dev_queue_xmit.

Also, taking into account tailroom isn't trivial because you need to
reserve the headroom but not the tailroom etc. I'm still thinking of a
way to avoid reserving tailroom completely when the hardware will handle
the crypto-checksumming but right now we don't have hardware that does
all crypto, only some algorithms. But we can even update
needed_headroom/tailroom on the fly.

> 2) LL_RESERVED_SPACE*() has to take the new needed_headroom
>    into account.

Check. I added LL_ALLOCATED_SPACE() for the tailroom and used that in
places for the allocation. I'm fairly sure I didn't get all of them
though.

> Your patch which I can't find, which adds netdev->needed_*, probably
> does all of that.  But I'm just making sure :-)
>=20
> Note that what would be really nice is if we could assert, in
> dev_queue_xmit, that the SKB has all of the necessary headroom, and
> give a WARN_ON_ONCE() backtrace if not.
>=20
> If we can ensure that, things like mac80211 and others will not need
> to skb_realloc_headroom() or anything like that unless they need to
> modify packet contents after skb->data and the packet is shared
> (ie. the pskb_expand_headroom(skb, 0, 0, GFP_*) case the TSO drivers
> use).

That would be nice, but I don't think it's possible.

johannes

--=-sQgKu33CsBIoURX49bcW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB61qqVg1VMiehFYAQIDnA//fUI1dI+Qbuf6dNG5b7BQScPKZdkJSBKf
MIEcjGAWbZ8Ow7Rgq57XBNA/iGC92GAi3zABfNwkskhNCPeXg9ENDE0PG68LU72B
yuC42y/2yeUyak1vsOq6PCBXUXmHXmAjT/pZNZ+o3JRPSx6iCTk9EWXdA3TQcz+6
wWw8Il7tirX/BhNhqjCbishvNmXLha7BtBzcCWTjncklQAlesYNmWWLIlmZuSBVl
JcHF8fld6Rv5uErqGtvSjwPITfDR9payvoCX0HU4+beS3jNFnPe5VyfyZsC/6pTo
/Qtm0gJjOesy5qMxo2dGO7xMWWmhZb2Sv0fDq67HP0H32Xk3I5dZ61nnLpbpmk9J
a77lFqLjYSf74qb3gsOzNgu7Ds3SN37CVNZ4M2lEA+/dE5NY4kquwn8pR1JkN2d8
n7lHiyiY2rW2R/7h+SgfwtY5KssujpJ7AKv2Dn54JrlRK3rr8veZZY2VLcuLHYpf
e5n+z7UiOZb+ZCXnq0lNfSXibsOSXHKCc+ARLJ+nfl/2a+RLB9GM7bXmykzziv/y
TH5F3ZSE03qzRvhKLbmT8qvJLC4HeVQwBbC0JejcKu1YWupijI061szMX/J5Q5+A
kc6PttKhfZPh04hOeUWN04vQt6Sl3ua2IUmNzfBqslxfPTogFybw7FU+TRB3H3ek
vpnZvYRIVdk=
=xCUF
-----END PGP SIGNATURE-----

--=-sQgKu33CsBIoURX49bcW--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
