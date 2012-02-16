From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 14:40:16 +0100
Message-ID: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <4249109.nLB9JCi9YF@localhost.localdomain>
	 <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <2687521.3ztN17SHUf@localhost.localdomain>
	 <1329318481.2437.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADVnQy=UOvC06TBOE7d7WvuKm1Tdkzu7M4dfvm6VRcRJaDMyLw@mail.gmail.com>
	 <1329377352.5646.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, alekcejk@googlemail.com
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64006 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab2BPNkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 08:40:21 -0500
Received: by wics10 with SMTP id s10so1204318wic.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 05:40:19 -0800 (PST)
In-Reply-To: <1329377352.5646.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 08:29 +0100, Eric Dumazet a =C3=A9=
crit :
> So I took the time to setup a netem in my lab (and had to fix netem b=
y
> the way). Gigabit link.
>=20
> On sender :
> tc qdisc add dev vlan.103 root netem delay 50ms
>=20
> And netperf session is a bit strange, since receiver window is about
> 1Mbytes (17097*64) but sender never uses half of it.
>=20
> cwnd is ~408
>=20
> $ ss -emoi  dst 192.168.20.108
> State      Recv-Q Send-Q                                 Local
> Address:Port                                     Peer Address:Port  =20
> ESTAB      0      450976
> 192.168.20.110:52017
> 192.168.20.108:44169    timer:(on,235ms,0) ino:21711 sk:f24d2d00
> 	 mem:(r0,w698880,f206336,t0) ts sack ecn bic wscale:6,8 rto:252
> rtt:52/0.75 cwnd:408 send 90.9Mbps rcv_space:14600
>=20
> $ tc -s -d qdisc show dev vlan.103
> qdisc netem 8009: root refcnt 2 limit 1000 delay 50.0ms
>  Sent 15149167430 bytes 10017438 pkt (dropped 0, overlimits 0 requeue=
s
> 0)=20
>  rate 74878Kbit 6193pps backlog 476760b 316p requeues 0=20

Its seems a problem with GRO.

Receiver opens its window each time it sends an ACK, without taking car=
e
how many segments were ACKed.

In these traces, I give the ACKS sent by receiver, first trace GRO on,
second with GRO off

We can see that with GRO off, receiver opens its window way faster
(against number of received bytes)

(REC & SENDER are both 3.0 kernels, so problem is quite old)

--------------------------------- GRO ON

14:13:43.287758 IP REC > SENDER: SE 1890584798:1890584798(0) ack 373469=
8542 win 14480 <mss 1460,sackOK,timestamp 11659135 2360992,nop,wscale 6=
>
14:13:43.337945 IP REC > SENDER: . ack 8689 win 272 <nop,nop,timestamp =
11659186 2361042>
14:13:43.338077 IP REC > SENDER: . ack 13033 win 317 <nop,nop,timestamp=
 11659186 2361042>
14:13:43.388076 IP REC > SENDER: . ack 16385 win 362 <nop,nop,timestamp=
 11659236 2361092>
14:13:43.388187 IP REC > SENDER: . ack 26521 win 408 <nop,nop,timestamp=
 11659236 2361092>
14:13:43.388358 IP REC > SENDER: . ack 29417 win 453 <nop,nop,timestamp=
 11659236 2361092>
14:13:43.438336 IP REC > SENDER: . ack 41001 win 498 <nop,nop,timestamp=
 11659286 2361142>
14:13:43.438488 IP REC > SENDER: . ack 49689 win 543 <nop,nop,timestamp=
 11659286 2361142>
14:13:43.438689 IP REC > SENDER: . ack 51137 win 589 <nop,nop,timestamp=
 11659286 2361142>
14:13:43.488542 IP REC > SENDER: . ack 62721 win 634 <nop,nop,timestamp=
 11659336 2361192>
14:13:43.488608 IP REC > SENDER: . ack 68513 win 679 <nop,nop,timestamp=
 11659336 2361192>
14:13:43.488750 IP REC > SENDER: . ack 74305 win 724 <nop,nop,timestamp=
 11659336 2361192>
14:13:43.488998 IP REC > SENDER: . ack 77201 win 770 <nop,nop,timestamp=
 11659337 2361193>
14:13:43.538859 IP REC > SENDER: . ack 97473 win 815 <nop,nop,timestamp=
 11659386 2361242>
14:13:43.538887 IP REC > SENDER: . ack 100369 win 860 <nop,nop,timestam=
p 11659386 2361243>
14:13:43.539061 IP REC > SENDER: . ack 104713 win 905 <nop,nop,timestam=
p 11659387 2361243>
14:13:43.539309 IP REC > SENDER: . ack 109057 win 951 <nop,nop,timestam=
p 11659387 2361243>
14:13:43.589049 IP REC > SENDER: . ack 119193 win 996 <nop,nop,timestam=
p 11659437 2361293>
14:13:43.589150 IP REC > SENDER: . ack 131073 win 1041 <nop,nop,timesta=
mp 11659437 2361293>
14:13:43.589273 IP REC > SENDER: . ack 139761 win 1086 <nop,nop,timesta=
mp 11659437 2361293>


--------------------------- GRO OFF

14:23:30.833888 IP REC > SENDER: SE 2942791281:2942791281(0) ack 598061=
43 win 14480 <mss 1460,sackOK,timestamp 12246638 2948538,nop,wscale 6>
14:23:30.884007 IP REC > SENDER: . ack 1449 win 272 <nop,nop,timestamp =
12246689 2948588>
14:23:30.884024 IP REC > SENDER: . ack 2897 win 317 <nop,nop,timestamp =
12246689 2948588>
14:23:30.884057 IP REC > SENDER: . ack 4345 win 362 <nop,nop,timestamp =
12246689 2948588>
14:23:30.884064 IP REC > SENDER: . ack 5793 win 408 <nop,nop,timestamp =
12246689 2948588>
14:23:30.884069 IP REC > SENDER: . ack 7241 win 453 <nop,nop,timestamp =
12246689 2948588>
14:23:30.884075 IP REC > SENDER: . ack 8689 win 498 <nop,nop,timestamp =
12246689 2948588>
14:23:30.884105 IP REC > SENDER: . ack 10137 win 543 <nop,nop,timestamp=
 12246689 2948588>
14:23:30.884111 IP REC > SENDER: . ack 11585 win 589 <nop,nop,timestamp=
 12246689 2948588>
14:23:30.884125 IP REC > SENDER: . ack 13033 win 634 <nop,nop,timestamp=
 12246689 2948588>
14:23:30.934126 IP REC > SENDER: . ack 14481 win 679 <nop,nop,timestamp=
 12246739 2948638>
14:23:30.934136 IP REC > SENDER: . ack 15929 win 724 <nop,nop,timestamp=
 12246739 2948638>
14:23:30.934149 IP REC > SENDER: . ack 16385 win 770 <nop,nop,timestamp=
 12246739 2948638>
14:23:30.934154 IP REC > SENDER: . ack 17833 win 815 <nop,nop,timestamp=
 12246739 2948638>
14:23:30.934161 IP REC > SENDER: . ack 19281 win 860 <nop,nop,timestamp=
 12246739 2948638>
14:23:30.934198 IP REC > SENDER: . ack 20729 win 905 <nop,nop,timestamp=
 12246739 2948638>
14:23:30.934204 IP REC > SENDER: . ack 22177 win 951 <nop,nop,timestamp=
 12246739 2948638>
14:23:30.934208 IP REC > SENDER: . ack 23625 win 996 <nop,nop,timestamp=
 12246739 2948638>
14:23:30.934213 IP REC > SENDER: . ack 25073 win 1002 <nop,nop,timestam=
p 12246739 2948638>
14:23:30.934240 IP REC > SENDER: . ack 26521 win 1002 <nop,nop,timestam=
p 12246739 2948638>
14:23:30.934245 IP REC > SENDER: . ack 27969 win 1002 <nop,nop,timestam=
p 12246739 2948638>
14:23:30.934272 IP REC > SENDER: . ack 29417 win 1002 <nop,nop,timestam=
p 12246739 2948638>
14:23:30.934276 IP REC > SENDER: . ack 30865 win 1002 <nop,nop,timestam=
p 12246739 2948638>
14:23:30.934295 IP REC > SENDER: . ack 33761 win 1002 <nop,nop,timestam=
p 12246739 2948638>
14:23:30.934319 IP REC > SENDER: . ack 36657 win 1002 <nop,nop,timestam=
p 12246739 2948638>
