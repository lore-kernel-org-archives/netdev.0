From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: NOHZ: local_softirq_pending 08
Date: Fri, 23 Oct 2009 16:31:51 +0200
Message-ID: <1256308311.12174.38.camel@johannes.local>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local>
	 <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>
	 <4AE0ECCE.2020407@imap.cc> <1256304869.12174.20.camel@johannes.local>
	 <4AE1BD3D.3020007@imap.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-KyBo9tGkm0yCRfckrJid"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	i4ldeveloper <i4ldeveloper@listserv.isdn4linux.de>,
	Karsten Keil <isdn@linux-pingi.de>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:35434 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbZJWObx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 10:31:53 -0400
In-Reply-To: <4AE1BD3D.3020007@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KyBo9tGkm0yCRfckrJid
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-10-23 at 16:27 +0200, Tilman Schmidt wrote:

> >> --- a/drivers/isdn/i4l/isdn_ppp.c
> >> +++ b/drivers/isdn/i4l/isdn_ppp.c
> >> @@ -1174,7 +1174,10 @@ isdn_ppp_push_higher(isdn_net_dev * net_dev, is=
dn_net_local * lp, struct sk_buff
> >>  #endif /* CONFIG_IPPP_FILTER */
> >>  	skb->dev =3D dev;
> >>  	skb_reset_mac_header(skb);
> >> -	netif_rx(skb);
> >> +	if (in_interrupt())
> >> +		netif_rx(skb);
> >> +	else
> >> +		netif_rx_ni(skb);
> >=20
> > So you've verified that the entire i4l stack can cope with being called
> > twice on the same CPU, from different contexts?
>=20
> What makes you think so?

I thought I'd explained this in my other email. *sigh*

You're squelching a warning, which comes from the fact that you're
calling something that calls into netif_rx() with softirqs enabled. That
would seem to imply that potentially a softirq could at the same time
call into that code too.

Basically, what happens now is this:

disable softirqs
call into i4l/ppp
i4l/ppp code
call netif_rx()
more code
enable softirqs


You're changing it to

call into i4l/ppp
i4l/ppp code
call netif_rx_ni()
more code

so the entire chunks "i4l/ppp code" and "more code" are now no longer
protected against being interrupted by a softirq that runs the same
code, maybe for a different device, on the same CPU.

johannes

--=-KyBo9tGkm0yCRfckrJid
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK4b5TAAoJEODzc/N7+Qma39YP/1FwLDWKmjBavzhZ/qSQAetd
tjrZ7Eij63pD2R7VLQdUuAs26E1LvM243DeRaVQAJtqIWUE+Sd2DP744N9OG0b58
HX9EVfI2rb8A1vJuhMV4eIAV7P05sYPsrabKwLE76NczBDwx6E3fdB8rffvC57Eb
80DB3x7fPJoSXqMBmQH10OmGFupI/BVgbP+COhyV4Jad7QKWZ6ps+UkkJZ11hpze
cndQQVAiVtLi4kmiyx9X1mJJI3QojTnXy3Z7baRLQYZYeSvksJxd5Vev+oaTK06p
ySdnU9JKPjedKfgcJndI8Jc3uf4V32kffNR0XTWFuRhZEjRf08Yoqnlezlkj/3ht
ZMX8Gm8vSkA3vmGzrUc1/dxrE303DyEtgRhU0r2EhKd9NdPPerKVyhKeNOpbRiVE
DPoWaLV/p4y0nL8qfGLuZSinUmiAnYQyRiriVBVQIRNQZ0t8zyN3ZLkU/j65uWwS
wciGnaSMh/2F2fE+IMxPZJsuMR5pWWDLyUN0LLnZsaFqH+WekhmhHOIfOA5xMsU1
uDWMvmbhZEgTGGNGauMD4+d4GtGsn+p3a9GNByjdTYYqyd0wXWuIVIJU6sAqMv3T
5ca9o6uH3BQ8+mRBmJuLBiuJBOMEoAZzGJR7ycWnE7xLonb0fnUk3yOLW74UlmjA
qocNik5vjf5h6LM5Fgpp
=O6iC
-----END PGP SIGNATURE-----

--=-KyBo9tGkm0yCRfckrJid--

