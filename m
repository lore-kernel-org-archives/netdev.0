From: Wolfgang Walter <linux@stwm.de>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery stalls on v3.
Date: Fri, 12 Dec 2014 21:31:41 +0100
Message-ID: <4013455.miJUA6iczs@h2o.as.studentenwerk.mhn.de>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <2630078.LdJXSsPB40@h2o.as.studentenwerk.mhn.de> <1418405225.13491.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:48740 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751471AbaLLUbo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 15:31:44 -0500
In-Reply-To: <1418405225.13491.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 12. Dezember 2014, 09:27:05 schrieb Eric Dumazet:
> On Fri, 2014-12-12 at 17:58 +0100, Wolfgang Walter wrote:
> > This fixes hangs of local tcp connections over ipsec tunnels where
> > pmtu is lower than the mtu of the interface.
>=20
> Again this is a work around, the one liner patch is not a clean patch=
=2E
>=20
> Something is wrong, we should fix GSO path instead.
>=20
> Why ? Because we can queue a GSO packet in a qdisc, then later call
> sk_setup_caps() (too late)

Hmm. Do you think that sk_setup_caps should not disable GSO later at al=
l? Or=20
only that it should not influence already queued packets?

In the case of an ipsec tunnel GSO gets disabled later (for tcp connect=
ions)=20
because dst->header_len() is zero at first and non-zero later. tcp conn=
ections=20
initiated not to long afterwards start with GSO disabled from the begin=
ning.


dst->header_len() being non zero for ipsec tunnels seems to be the case=
 with=20
or without an adjustment via PMTU. It seems that routing only does not =
know it=20
from the beginning on (for incomimg connections) :-).

Why does a non zero dst->header_len() disable GSO? Is it just an optimi=
zation=20
or does GSO not work in that case? If dst->header_len() being non zero =
signals=20
that ipsec tunnel mode can't handle GSO at all then the problem would n=
ot lay=20
in the gso path.


There is one thing which indicates that there is also a problen in the =
GSO=20
path, though. As my tests demonstrated disabling GSO on the physical in=
terface=20
serving the ipsec tunnel does not prevent the hangs. It does, though, i=
f sk-
>sk_gso_max_segs =3D 1 in sk_setup_caps() if sk_can_gso(sk) returns fal=
se. This=20
was the first variation of the patch where sk->sk_gso_max_segs was not =
set if=20
dst->header_len() is non zero.


Concering qdisc: an ipsec tunnel doesn't have a "tunnel-device" so it d=
oes not=20
have qdisc? The ipsec tunnel transforms packets and the results are (in=
 case=20
of ipsec esp tunnel) esp packets which cannot be resgmented. Only these=
=20
transformed packets are finally queued to a qdisc of a network device t=
hen.


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
