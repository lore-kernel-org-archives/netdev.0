From: Robert Evans <robert.evans@nasdaqomx.com>
Subject: RE: tcp_shift_skb_data uses wrong mss in non-gso case?
Date: Wed, 25 Aug 2010 10:43:23 -0400
Message-ID: <D3B72A8DFCA0A8418CB61D1E9E310A99E5F35252@US01XMB01.org.nasdaqomx.com>
References: <D3B72A8DFCA0A8418CB61D1E9E310A99E5F35219@US01XMB01.org.nasdaqomx.com>
 <AANLkTi=ygaa_fV4SwaLY2gP9H+Nn54QdXcGXkfGukSCD@mail.gmail.com>
 <alpine.DEB.2.00.1008241008250.31124@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?=27Ilpo_J=E4rvinen=27?= <ilpo.jarvinen@helsinki.fi>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.nasdaqomx.com ([206.200.254.15]:8069 "EHLO
	mx1.nasdaqomx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab0HYOxB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 10:53:01 -0400
In-Reply-To: <alpine.DEB.2.00.1008241008250.31124@melkinpaasi.cs.helsinki.fi>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > Is the small gso_size the correct and/or desired behavior? =A0Or =
am I missing
> > > something else that prevents this from being a problem?
> >=20
> > I believe that this is invalid for the stack to do, Ilpo, Herbert?
> > what do you think?
>
> The point of this code is to work with already SACKed segments (or to=
=20
> become SACKed from the current ACK), only TCP code is interested in t=
hem=20
> anymore. They should not be sent again to wire unless SACK reneging o=
ccurs=20
> but then retransmission code should deal with this just fine:
>
>         if (skb->len > cur_mss) {
>                 if (tcp_fragment(sk, skb, cur_mss, cur_mss))
>                         return -ENOMEM; /* We'll try again later. */
>         } else {
>                 int oldpcount =3D tcp_skb_pcount(skb);
>
>                 if (unlikely(oldpcount > 1)) {
>                         tcp_init_tso_segs(sk, skb, cur_mss);
>                         tcp_adjust_pcount(sk, skb, oldpcount - tcp_sk=
b_pcount(skb));
>                 }
>         }

Ilpo is right, the code in the retransmit path will prevent any packets=
=20
with tiny gso_size from being sent out to the net device.

However, that code was added after Ilpo's SACK patches. The original pa=
tch=20
went in for 2.6.29, and Ilpo fixed the retransmit in 2.6.30.  So 2.6.29=
 and=20
its descendants can have this problem. I'm using 2.6.29.4, so there you=
=20
have it.

A kernel update will definitely fix my problem, so that should be the=20
end of it.  Thanks for your time everyone!

-Bob
