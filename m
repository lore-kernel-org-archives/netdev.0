From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Sat, 03 May 2008 11:37:57 +0200
Message-ID: <1209807477.3987.9.camel@johannes.berg>
References: <1209639500.7067.0.camel@johannes.berg>
	 <20080501110341.GD7490@gondor.apana.org.au>
	 <1209760731.3608.17.camel@johannes.berg>
	 <20080502.163334.148944203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-kA9cTGF6RBSZGKV9+Izp"
Cc: herbert@gondor.apana.org.au, mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:39924 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760170AbYECJiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 05:38:15 -0400
In-Reply-To: <20080502.163334.148944203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kA9cTGF6RBSZGKV9+Izp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > I'm confused. The area should be used say with encryption when it's
> > actually necessary. Maybe there's always enough headroom for some
> > reason now?
>=20
> That's possible.
>=20
> There are paths, that, although they could take advantage of the
> fact that all of the non-header packet data is going to come from
> pages, they don't and allocate a full MTU skb->data area anyways.

Ok.

> On the other hand, if we provide ways for users to subvert the socket
> buffer limits, we might as well not try to limit anything.

Well, not exactly, since we'd only do that (at least in mac80211) when
packets are about to be sent to the hardware so they wouldn't live much
longer.

> Take a look at some ethernet drivers that implement TSO in a way that
> requires munging the IP headers for whatever reason.  If they need to
> COW the packet data in order to modify it, they always do this with
> pskb_expand_head(skb, 0, 0, GFP_*) exactly so that they don't modify
> the SKB data size, and exactly so that the skb->truesize value stays
> accurate.

Right, but we might actually need more space. Say you have a device that
requires 82 bytes headroom (yes, there are such devices) for their own
transmit header. Then you need maybe up to 30 bytes of 802.11 header
plus 8 byte ICV, so minus the 14 ethernet header that we remove we now
need well over 100 bytes headroom. On the other hand, not even
accounting the actual data buffer (you proposed to skb_orphan the skb
early) seems wrong as well. Worse yet, the needed transmit header
headroom is variable depending on devices.

One of the worst devices is the Broadcom one with 82 header and nowadays
actually DMAs this header from a separate memory location, so there this
won't happen, but can we guarantee that all devices are programmable
that way? We've seen lots of rather strange devices unfortunately...

> Try to find out exactly what's going wrong here, you seem to be
> close.  Once we know the precise issue we can talk about real
> changes to make this easier to cope with and debug in the future.

I'll try. I don't really see myself being that close ;)

johannes

--=-kA9cTGF6RBSZGKV9+Izp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBwydKVg1VMiehFYAQKuwA//ZlV/hU7J09gLSZsnynp8RCzpZ3JqcdDg
M9ezMmK97JKwcly2WJlwfwziUO2HW91gTMPJx0GOadKe8CZRPTW2t76J0BhgTZGe
6PLNcifFJ1KAdZATrPj+dFqNK9K4kicto1dHEfsydhAJPAykE2GeQPU05rD5YRXo
sIwrNHcYJTCDMnWiDV6jGCmwKDw+AtC7aiFRZIurgqikwdX5rDkDZK9M4MXtWmbU
FAM+iTNmXlgMkMM4r+OHkEtj47JYHTX+BNfsHMJ7vwYr7lXsmGv77exDQ7oq5yoa
Edua6moEZOn1dAdKwEQVNb60A1yQwLf3BhPAjd/rhp07yadBIzfBSyHF8EtU0tfH
Lz5iAVH6BmNEgmjocwYbNGoEbEO5IOhaWhaiXM+Zsz9gprT5pJ2fAUVVHtrcAMd5
RMxqyuGoLNtfLzpXK/ecF6cJR4+tmiKnX8ovm0ZVasF0qPs8YAupkZZjypKQfaJB
oXjLpH2hzVpXvkbijdzUczIPfzFiO8TH66WuKoo8nhzRlcPPDrugNZ8QEThetTbv
32c1v7JwDCkoFNSOUrBT+43c4PU8GIoLEH07GVmi4/Xi0jxBNWV13JOTTCYH0/pt
tdgPR8u445FurBHj2h5z7KW2FwmcZozBKwxGYT7TT8dG3bgZ21ugqRkoh40d5+2Y
0aKJjYzczzc=
=/Iak
-----END PGP SIGNATURE-----

--=-kA9cTGF6RBSZGKV9+Izp--

