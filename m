From: "Jeremy Jackson" <jerj@coplanar.net>
Subject: Re: Unwanted aliasing of UDP checksum failed error counter
Date: Tue, 26 Oct 2010 16:21:16 -0400
Message-ID: <a2ae895d871551a9b3ded9ce3874fe28.squirrel@imap.coplanar.net>
References: <8545971aec0612a0bca2801107d9493b.squirrel@imap.coplanar.net>
    <1288124033.2652.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Jeremy Jackson" <jerj@coplanar.net>, netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sputnik.coplanar.net ([70.47.139.1]:42112 "EHLO
	sputnik.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760400Ab0JZUVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:21:18 -0400
In-Reply-To: <1288124033.2652.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Le mardi 26 octobre 2010 =C3=A0 15:53 -0400, Jeremy Jackson a =C3=A9c=
rit :
>> Trying to find source of packet loss on an 8node compute cluster, we
>> find:
>> (not in this example, but on the real cluster)
>>
>> in /proc/sys/net/snmp
>> Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufEr=
rors
>> Udp: 976460 1750 0 986795 0 0
>>
>> InErrors *and* RcvbufErrors both go up with full socket buffer, this=
 has
>> made troubleshooting our application more difficult.  We were chasin=
g
>> UDP
>> checksum problems, until we checked linux source code, and found
>> aliasing.
>>
>> Is this done for assembly code efficiency?  Any reason ENOMEM (ie so=
cket
>> buffer full) can't avoid aliasing to UDP checksum failed errors?
>>
>> in linux-source-2.6.32/net/ipv4/udp.c:__udp_queue_rcv_skb()
>> ....
>>                 /* Note that an ENOMEM error is charged twice */
>>                 if (rc =3D=3D -ENOMEM) {
>>                         UDP_INC_STATS_BH(sock_net(sk),
>> UDP_MIB_RCVBUFERRORS,
>>                                          is_udplite);
>>                         atomic_inc(&sk->sk_drops);
>>                 }
>>                 goto drop;
>> ...
>> drop:
>>         UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite)=
;
>>
>
> In MIBS, there is no counter for UDP checksum errors
>
> So we use the standard UDP_MIB_INERRORS

Yes, this part I understand, but what I don't understand is why ENOMEM
errors *and* checksum errors both use the same counter, while ENOMEM ha=
s
it's own already.

> udpInErrors OBJECT-TYPE
>     SYNTAX     Counter32
>     MAX-ACCESS read-only
>     STATUS     current
>     DESCRIPTION
>            "The number of received UDP datagrams that could not be
>             delivered for reasons other than the lack of an
>             application at the destination port.
>
>
> We could add a LINUX specific MIB entry, eventually...
>
>
>
>


