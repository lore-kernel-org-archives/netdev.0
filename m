From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Question regarding expected behavior of two udp sockets with
 SO_REUSEADDR set
Date: Sat, 20 Nov 2010 19:50:36 -0500
Message-ID: <20101121005036.GB29311@hmsreliant.think-freely.org>
References: <20101120004847.GA2590@hmsreliant.think-freely.org>
 <1290226015.2756.14.camel@edumazet-laptop>
 <20101120150441.GA17907@hmsreliant.think-freely.org>
 <1290267887.2756.75.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50987 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484Ab0KUAyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Nov 2010 19:54:33 -0500
Content-Disposition: inline
In-Reply-To: <1290267887.2756.75.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 20, 2010 at 04:44:47PM +0100, Eric Dumazet wrote:
> Le samedi 20 novembre 2010 =E0 10:04 -0500, Neil Horman a =E9crit :
>=20
> > Agreed.  My thought was to add logic to udp_lib_lport_inuse such th=
at, if
> > sk_reuse is set on both sockets, and the input snum is 0 (indicatin=
g autobind)
> > we should not allow binding sk to inet_sk(sk2)->num.  Thoughts?
>=20
> I dont know, problem is this could be possible right now if sk2 is bo=
und
> on 127.0.0.2 address. Adding this test would reduce possible space.
>=20
Well, yes, that is in fact the exact problem that I origionally describ=
ed.  Both
sockets are bound to the same port on 127.0.0.1 on the same system.  Si=
nce both
sockets have SO_REUSEADDR set, this is allowed, but when either socket =
sends  a
messaage, the delivery code does a lookup in __udp4_lib_lookup, and the=
 sock
structure that gets returned there is ambiguous. It could be either of =
the two
bound sockets, and the result will depend on which order they exist in =
the
hslot->head list (since they will both by definition hash to the same b=
ucket).

Another solution might be to treat daddr of 127 specially, and force a =
traversal
of the entire hslot->head list, delivering to every matching packet, bu=
t we
might need to do that for all locally owned daddrs, so I'm not sure tha=
ts a
great solution.  Other thoughts welcome, including just leave it all we=
ll enough
alone :)


> Autobind is tricky, it chooses a port while address is part of the
> problem.
>=20
Agreed, I'm comming to understand that :)

Neil

