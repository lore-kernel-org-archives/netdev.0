From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Sat, 15 Oct 2011 08:54:42 +0200
Message-ID: <1318661682.2525.41.camel@edumazet-laptop>
References: <20111014.034224.1197576516015404466.davem@davemloft.net>
	 <4E985A3F.5080103@hp.com> <4E98B3B4.20406@hp.com>
	 <20111014.191845.232827637484150228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60049 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918Ab1JOGyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2011 02:54:47 -0400
Received: by wyg36 with SMTP id 36so724521wyg.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 23:54:46 -0700 (PDT)
In-Reply-To: <20111014.191845.232827637484150228.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 19:18 -0400, David Miller a =C3=A9cr=
it :
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 14 Oct 2011 15:12:04 -0700
>=20
> > From just a very quick look it looks like tcp_v[46]_rcv is called,
> > finds that the socket is owned by the user, attempts to add to the
> > backlog, but the path called by sk_add_backlog does not seem to mak=
e
> > any attempts to compress things, so when the quantity of data is <<
> > the truesize it starts tossing babies out with the bathwater.
>=20
> This is why I don't believe the right fix is to add bandaids all
> around the TCP layer.
>=20
> The wastage has to be avoided at a higher level.

We cant do that at higher level without smart hardware (like NIU) or
adding a copy.

Its a tradeoff between space and speed.

Most drivers have to allocate a large skb1 and post it to hardware to
receive a frame (Unknown length, only max length is known)

Some drivers have a copybreak feature, doing a copy of small incoming
frames into a smaller skb2 (skb2->truesize < skb1->truesize)

This strategy do save memory for small frames, not for 1500 bytes
frames.

I think the problem is in TCP layer (and maybe in other protocols) :

1) Either tune rcvbuf to allow more memory to be used, for a particular
tcp window,

   Or lower TCP window to allow less packets in flight for a given
rcvbuf.

2) TCP COLLAPSE already is trying to reduce memory costs of a tcp socke=
t
with many packets in OFO queue. But fixing 1) would make these collapse=
s
never happen in the first place. People wanting high TCP bandwidth
[ with say more than 500 in-flight packets per session ] can certainly
afford having enough memory.
