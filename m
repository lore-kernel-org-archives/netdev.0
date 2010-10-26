From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unwanted aliasing of UDP checksum failed error counter
Date: Tue, 26 Oct 2010 22:13:53 +0200
Message-ID: <1288124033.2652.24.camel@edumazet-laptop>
References: <8545971aec0612a0bca2801107d9493b.squirrel@imap.coplanar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jeremy Jackson <jerj@coplanar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:55143 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755090Ab0JZUN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:13:57 -0400
Received: by gyg4 with SMTP id 4so3185292gyg.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 13:13:56 -0700 (PDT)
In-Reply-To: <8545971aec0612a0bca2801107d9493b.squirrel@imap.coplanar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 15:53 -0400, Jeremy Jackson a =C3=A9cri=
t :
> Trying to find source of packet loss on an 8node compute cluster, we =
find:
> (not in this example, but on the real cluster)
>=20
> in /proc/sys/net/snmp
> Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufErr=
ors
> Udp: 976460 1750 0 986795 0 0
>=20
> InErrors *and* RcvbufErrors both go up with full socket buffer, this =
has
> made troubleshooting our application more difficult.  We were chasing=
 UDP
> checksum problems, until we checked linux source code, and found alia=
sing.
>=20
> Is this done for assembly code efficiency?  Any reason ENOMEM (ie soc=
ket
> buffer full) can't avoid aliasing to UDP checksum failed errors?
>=20
> in linux-source-2.6.32/net/ipv4/udp.c:__udp_queue_rcv_skb()
> ....
>                 /* Note that an ENOMEM error is charged twice */
>                 if (rc =3D=3D -ENOMEM) {
>                         UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUF=
ERRORS,
>                                          is_udplite);
>                         atomic_inc(&sk->sk_drops);
>                 }
>                 goto drop;
> ...
> drop:
>         UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
>=20

In MIBS, there is no counter for UDP checksum errors

So we use the standard UDP_MIB_INERRORS

udpInErrors OBJECT-TYPE
    SYNTAX     Counter32
    MAX-ACCESS read-only
    STATUS     current
    DESCRIPTION
           "The number of received UDP datagrams that could not be
            delivered for reasons other than the lack of an
            application at the destination port.


We could add a LINUX specific MIB entry, eventually...



