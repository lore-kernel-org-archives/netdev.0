From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unwanted aliasing of UDP checksum failed error counter
Date: Tue, 26 Oct 2010 22:27:22 +0200
Message-ID: <1288124842.2652.28.camel@edumazet-laptop>
References: <8545971aec0612a0bca2801107d9493b.squirrel@imap.coplanar.net>
	 <1288124033.2652.24.camel@edumazet-laptop>
	 <a2ae895d871551a9b3ded9ce3874fe28.squirrel@imap.coplanar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jeremy Jackson <jerj@coplanar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:57160 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755917Ab0JZU11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:27:27 -0400
Received: by gwj21 with SMTP id 21so3654927gwj.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 13:27:26 -0700 (PDT)
In-Reply-To: <a2ae895d871551a9b3ded9ce3874fe28.squirrel@imap.coplanar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 16:21 -0400, Jeremy Jackson a =C3=A9cri=
t :
> > Le mardi 26 octobre 2010 =C3=83  15:53 -0400, Jeremy Jackson a =C3=83=
=C2=A9crit :
> >> Trying to find source of packet loss on an 8node compute cluster, =
we
> >> find:
> >> (not in this example, but on the real cluster)
> >>
> >> in /proc/sys/net/snmp
> >> Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors Sndbuf=
Errors
> >> Udp: 976460 1750 0 986795 0 0
> >>
> >> InErrors *and* RcvbufErrors both go up with full socket buffer, th=
is has
> >> made troubleshooting our application more difficult.  We were chas=
ing
> >> UDP
> >> checksum problems, until we checked linux source code, and found
> >> aliasing.
> >>
> >> Is this done for assembly code efficiency?  Any reason ENOMEM (ie =
socket
> >> buffer full) can't avoid aliasing to UDP checksum failed errors?
> >>
> >> in linux-source-2.6.32/net/ipv4/udp.c:__udp_queue_rcv_skb()
> >> ....
> >>                 /* Note that an ENOMEM error is charged twice */
> >>                 if (rc =3D=3D -ENOMEM) {
> >>                         UDP_INC_STATS_BH(sock_net(sk),
> >> UDP_MIB_RCVBUFERRORS,
> >>                                          is_udplite);
> >>                         atomic_inc(&sk->sk_drops);
> >>                 }
> >>                 goto drop;
> >> ...
> >> drop:
> >>         UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplit=
e);
> >>
> >
> > In MIBS, there is no counter for UDP checksum errors
> >
> > So we use the standard UDP_MIB_INERRORS
>=20
> Yes, this part I understand, but what I don't understand is why ENOME=
M
> errors *and* checksum errors both use the same counter, while ENOMEM =
has
> it's own already.

Because ENOMEM errors were handled in commit 81aa646c,
but _all_ errors must also be accounted in INERRORS, to be RFC
compliant.

[IPV4]: add the UdpSndbufErrors and UdpRcvbufErrors MIBs


If we add a new MIB counter for checksum errors, a bad checksum packet
will increment both this new counter and INERRORS.



