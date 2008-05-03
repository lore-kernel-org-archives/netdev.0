From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 01:43:29 +0200
Message-ID: <1209858209.3779.8.camel@johannes.berg>
References: <20080501.034950.261408566.davem@davemloft.net>
	 <1209641914.3904.0.camel@johannes.berg>
	 <1209857088.3920.4.camel@johannes.berg>
	 <20080503.163202.48704621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-gYMrAoQuJpUOBYI+xXtI"
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080503.163202.48704621.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-gYMrAoQuJpUOBYI+xXtI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > > > +	if (unlikely((nhead || ntail) && skb->sk)) {
> > > > +		printk(KERN_ERR "SKB BUG: Illegal pskb expand (%d:%d) "
> > > > +		       "with socket attached\n",
> > > > +		       nhead, ntail);
> > > > +	}
> > > > +
> > > >  	size =3D SKB_DATA_ALIGN(size);
> > >=20
> > > Ok I think I'm starting to understand this a little better. However,
> > > shouldn't this function update skb->truesize so if the skb is later
> > > attached to a different socket again it has the right size?
> >=20
> > Judging from some of the callers, the caller should. Why?!
>=20
> Relax :-)

:)

Hm. The only caller that does seem to do it seems to be in af_netlink.c.

> We certainly could check that there is no socket attached here,
> and make the truesize adjustment right at this spot.
>=20
> It just never happened before in practice in a way that matters.
>=20
> That's why we have the truesize assertion, to discover situations
> like this and thus be able to fix it.

Except unfortunately the truesize assertion is rather useless since you
have no idea where it comes from. FWIW, some caller that does the
adjustment must be going wrong, whenever I start vpnc I get a single one
like this:

[  162.108556] SKB BUG: Invalid truesize (408) size=3D432,
sizeof(sk_buff)=3D176

This is again without the patch to pskb_expand_head that did the
truesize adjustment, I only put in a WARN_ON (similar to the code you
had above but is, I think, more useful since it has a stack dump and
other useful info)

Right now I think I'm too lazy to dig into where this happens. I don't
hit the warning in pskb_expand_head so it must be one of the other
20-odd places where truesize is adjusted. Maybe I'll just make each of
them print out the info.

johannes

--=-gYMrAoQuJpUOBYI+xXtI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBz4oKVg1VMiehFYAQKhkQ//UrZe8+wFSzKsKpaTzj5r6GKIX7aasXuy
WlrN6n/dhymZ+LH54GlddNnAwbdiqnz0eXN266ob/HlSJHkcxjB9NjtbrRkO24xL
BMIS3e8C682N6nt5Ps4hoVP5fqedaIVzrpW5b3sIjdEbBhLRMWFTBoocg1e2tmy5
Ku4qLjxdiZFWrR7Mdz+7d2ZN3rBFfLK7Tf5QbZ0k96OT7qF7u9YpTf7ffk7JhuBQ
BkCKe6FRqHfEvnioSe+sDz7tXWxsYbfj1vrxlJXJkPHyPX2pJC87jEKvUOQeGSR6
ALW5cQcAX2Oaa7SVwQ5uPW5pJSjcgfhfDNnEHAlhjkl6cmkvx3P4I2M5Tzc10+L3
pq87j7JntQhx1wHyzpp8Lk/xJfi5qtd0nMho6JTrDlczRs+APQdyK1UOmJxus1Ui
iy8TXr3MQ83q/Re+kPm9F5KcHaXXG/vX9lwtHNYZA56aVUOQDDGbJ7pVPPBWM9l8
FtGd50lvlHlsZ6eqpM93rlGDl1GLGhDLZJaXrCG0YAdkSyzLKPR8qwyFMKTPHX+C
vwM6uegEv0Krp7TyXU1BuVNsEI2I2hjHa0pvgJX0GDjZ9Ir63cMFkqdI314iZNwg
byJ74+OA/dYPTlEo52CezL9w/VhPK7zIDctq7pH2Y++FpShSgzU7LqiCYX5DJY0/
+/dXF8AH8xc=
=V4rB
-----END PGP SIGNATURE-----

--=-gYMrAoQuJpUOBYI+xXtI--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
