From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 20:37:38 +0300
Message-ID: <200805132037.39580.rdenis@simphalempin.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org, Ulrich Drepper <drepper@redhat.com>
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:43938 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755034AbYEMRhm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 13:37:42 -0400
In-Reply-To: <20080513170325.GB11499@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tuesday 13 May 2008 20:03:25 Gerrit Renker, vous avez =E9crit=A0:
> Using work-arounds is brittle and frustrating when the API behaviour
> suddenly changes. My experience of using such a wrapper was:
>
>  * it passed UDP(-Lite), TCP through without changing the socket type=
;
>  * when passed DCCP, it set the socket type to 0, to avoid `ai_sockty=
pe
>    not supported' getaddrinfo error;

>  * this used to work fine until about January, when something in the
>    lookup machinery for dual-stack hosts changed:
>    - before, AF_UNSPEC + ai_socktype=3D0 put IPv6 first into the resu=
lt list,
>    - now the the result order is reversed (IPv4 sockets are returned =
first)

You're probably using a recent libc that applies RFC3484 _properly_. If=
 you=20
still want IPv6 first, no matter what addresses the host has, I think t=
he=20
AI_PASSIVE flag should do the trick. Then again, working around RFC3484=
=20
policy is _not_ a good idea.

As far as I am concerned, for DCCP, I (meaning VLC) currently use SOCK_=
STREAM,=20
and overrides the socktype and protocol fields in the socket() call=20
manually - so I don't get a TCP socjet.

In any case, getaddrinfo() should be patched to
1/ accept ai_socktype =3D=3D SOCK_DCCP and ai_protocol =3D=3D IPPROTO_D=
CCP,
2/ accept ai_socktype =3D=3D SOCK_DCCP and ai_protocol =3D=3D 0,
   and set ai_protocol to IPPROTO_DCCP in the results,
3/ (perhaps?) accept ai_protocol =3D=3D IPPROTO_DCCP and ai_socktype =3D=
=3D 0,
   and set ai_socktype to SOCK_DCCP in the results.

Similarly:
1/ accept ai_socktype =3D=3D SOCK_DGRAM and ai_protocol =3D=3D IPPROTO_=
UDPLITE,
2/ (intentionally omitted - keep normal UDP non-Lite behavior)
3/ (perhaps?) accept ai_protocol =3D=3D IPPROTO_UDPLITE and ai_socktype=
 =3D=3D 0,
   and set ai_socktype to SOCK_DGRAM in the results.

Voil=E0. Best to check this with Ulrich Drepper, no?

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
