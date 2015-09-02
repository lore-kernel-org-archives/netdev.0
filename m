From: Mohammad Rajiullah <mohammad.rajiullah@kau.se>
Subject: Re: Unexpected loss recovery in TLP
Date: Wed, 2 Sep 2015 10:54:41 +0200
Message-ID: <607F6E96-FABE-4C4E-8383-D9F27DD3C0E8@kau.se>
References: <3D743BF2-C02D-4E89-91AE-7E7F1D95AED5@kau.se> <1441110692.8932.168.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.39]:11250 "EHLO nasse.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753267AbbIBJBl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 05:01:41 -0400
In-Reply-To: <1441110692.8932.168.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric!

Thanks for the direction. I tried packet drill locally (with the same k=
ernel Linux 3.18.5 to start with)
with the following script. And it doesn=E2=80=99t show the problem I me=
ntioned.=20
So the fast retransmit happens after getting the dupack.
It would be good if I could get some information from the calls=20
from the TCP stack (I have some printk there), but using packet drill I=
 don=E2=80=99t know at the moment,
how to get that.=20

\
Mohammad


// Establish a connection.
0   socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
+0  setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
+0  setsockopt(3, SOL_SOCKET, TCP_NODELAY, [1], 4) =3D 0

+0  bind(3, ..., ...) =3D 0
+0  listen(3, 1) =3D 0

+0  < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
+0  > S. 0:0(0) ack 1 <...>

+.03 < . 1:1(0) ack 1 win 257
+0  accept(3, ..., ...) =3D 4

// Send 1 data segment and get an ACK with DATA
+0  write(4, ..., 1000) =3D 1000
+0  > P. 1:1001(1000) ack 1

+.03 < P. 1:11(10) ack 1001 win 257
+0  > . 1001:1001(0) ack 11
//+0.1 read(3,...,1000)=3D10
+0  write(4, ..., 1000) =3D 1000
+0  > P. 1001:2001(1000) ack 11=20

+.03 < P. 11:21(10) ack 2001 win 257
//+0  > . 2001:2001(0) ack 21
+0  write(4, ..., 1000) =3D 1000
+0  > P. 2001:3001(1000) ack 21=20

+.03 < P. 21:31(10) ack 3001 win 257
+0  write(4, ..., 1000) =3D 1000
+0  > P. 3001:4001(1000) ack 31=20

+0.2  write(4, ..., 1000) =3D 1000
+0  > P. 4001:5001(1000) ack 31=20
+0.03  > P. 4001:5001(1000) ack 31=20
+0.04  < P. 21:31(10) ack 3001 win 257=20
+0  > . 5001:5001(0) ack 31 <nop,nop,sack 21:31>
+0.03  < . 31:31(0) ack 3001 win 257 <nop,nop,sack 4001:5001>
+0.003  < . 31:31(0) ack 3001 win 257 <nop,nop,sack 4001:5001>
+0.006  > P. 3001:4001(1000) ack 31 =20

  1   0.000000    192.0.2.1 -> 192.168.0.1  TCP 68 60262 > http-alt [SY=
N] Seq=3D0 Win=3D32792 Len=3D0 MSS=3D1000 SACK_PERM=3D1 WS=3D128
  2   0.000068  192.168.0.1 -> 192.0.2.1    TCP 68 http-alt > 60262 [SY=
N, ACK] Seq=3D0 Ack=3D1 Win=3D29200 Len=3D0 MSS=3D1460 SACK_PERM=3D1 WS=
=3D512
  3   0.030294    192.0.2.1 -> 192.168.0.1  TCP 56 60262 > http-alt [AC=
K] Seq=3D1 Ack=3D1 Win=3D32896 Len=3D0
  4   0.030370  192.168.0.1 -> 192.0.2.1    TCP 1056 [TCP segment of a =
reassembled PDU]
  5   0.060474    192.0.2.1 -> 192.168.0.1  TCP 66 [TCP segment of a re=
assembled PDU]
  6   0.060507  192.168.0.1 -> 192.0.2.1    TCP 56 http-alt > 60262 [AC=
K] Seq=3D1001 Ack=3D1 Win=3D29696 Len=3D0
  7   0.060670  192.168.0.1 -> 192.0.2.1    TCP 1056 [TCP segment of a =
reassembled PDU]
  8   0.090766    192.0.2.1 -> 192.168.0.1  TCP 66 60262 > http-alt [PS=
H, ACK] Seq=3D1 Ack=3D2001 Win=3D32896 Len=3D10
  9   0.090809  192.168.0.1 -> 192.0.2.1    TCP 1056 [TCP segment of a =
reassembled PDU]
 10   0.120984    192.0.2.1 -> 192.168.0.1  TCP 66 [TCP segment of a re=
assembled PDU]
 11   0.121026  192.168.0.1 -> 192.0.2.1    TCP 1056 [TCP segment of a =
reassembled PDU]
 12   0.321111  192.168.0.1 -> 192.0.2.1    TCP 1056 [TCP segment of a =
reassembled PDU]
 13   0.351588  192.168.0.1 -> 192.0.2.1    TCP 1056 [TCP Retransmissio=
n] [TCP segment of a reassembled PDU]
 14   0.391668    192.0.2.1 -> 192.168.0.1  TCP 66 [TCP Retransmission]=
 [TCP segment of a reassembled PDU]
 15   0.391699  192.168.0.1 -> 192.0.2.1    TCP 68 [TCP Dup ACK 13#1] h=
ttp-alt > 60262 [ACK] Seq=3D5001 Ack=3D21 Win=3D29696 Len=3D0 SLE=3D11 =
SRE=3D21
 16   0.421888    192.0.2.1 -> 192.168.0.1  TCP 68 [TCP Dup ACK 14#1] 6=
0262 > http-alt [ACK] Seq=3D21 Ack=3D3001 Win=3D32896 Len=3D0 SLE=3D400=
1 SRE=3D5001
 17   0.424964    192.0.2.1 -> 192.168.0.1  TCP 68 [TCP Dup ACK 14#2] 6=
0262 > http-alt [ACK] Seq=3D21 Ack=3D3001 Win=3D32896 Len=3D0 SLE=3D400=
1 SRE=3D5001
 18   0.431597  192.168.0.1 -> 192.0.2.1    TCP 1056 [TCP Fast Retransm=
ission] [TCP segment of a reassembled PDU]

> On 01 Sep 2015, at 14:31, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
>=20
> On Tue, 2015-09-01 at 11:36 +0200, Mohammad Rajiullah wrote:
>> Hi!
>>=20
>> While measuring TLP=E2=80=99s performance for an online gaming scena=
rio,  where both the client and the server send data, TLP=20
>> shows unexpected loss recovery in Linux 3.18.5 kernel. Early retrans=
mit fails in response=20
>> to the dupack which is later resolved using RTO.  I found the behavi=
our consistent during the whole measurement period.
>> Following is an excerpt from the tcpdump traces (taken at the server=
) showing the behaviour:
>>=20
>> 0.733965    Client -> Server     HTTP 431 POST /Scores HTTP/1.1=20
>> 0.738355     Server -> Client HTTP 407 HTTP/1.1 200 OK=20
>> 0.985346     Server -> Client TCP 68 [TCP segment of a reassembled P=
DU]
>> 0.993322     Client -> Server     HTTP 431 [TCP Retransmission] POST=
 /Scores HTTP/1.1=20
>> 0.993352     Server -> Client TCP 78 [TCP Dup ACK 2339#1] 8081=E2=86=
=9245451 [ACK] Seq=3D186995 Ack=3D230031  Len=3D0   SLE=3D229666 SRE=3D=
230031
>> 1.089327     Server -> Client TCP 68 [TCP Retransmission] 8081=E2=86=
=9245451 [PSH, ACK] Seq=3D186993 Ack=3D230031  Len=3D2 =20
>> 1.294816     Client -> Server     TCP 78 [TCP Dup ACK 2340#1] 45451=E2=
=86=928081 [ACK] Seq=3D230031 Ack=3D186652  Len=3D0   SLE=3D186993 SRE=3D=
186995
>> 1.295018     Client -> Server     TCP 86 [TCP Dup ACK 2340#2] 45451=E2=
=86=928081 [ACK] Seq=3D230031 Ack=3D186652  Len=3D0   SLE=3D186993 SRE=3D=
186995 SLE=3D186993 SRE=3D186995
>> 1.541328     Server -> Client HTTP 407 [TCP Retransmission] HTTP/1.1=
 200 OK =20
>>=20
>> From some kernel debug info (using printk ..) it appears that for so=
me reason although the incoming dupack=20
>> starts the early retransmit delay timer, it never expires. The above=
 measurement was taken in a=20
>> wireless environment. I also recreated the scenario in a wired netwo=
rk with synthetic traffic to have regular=20
>> RTTs. The behaviour remains the same. =20
>> 0.287241     Client -> Server     TCP 316 58148 > colubris [PSH, ACK=
] Seq=3D251 Ack=3D501 Win=3D31744 Len=3D250 TSval=3D98871521 TSecr=3D98=
865126
>> 0.287278     Server -> Client     TCP 316 colubris > 58148 [PSH, ACK=
] Seq=3D501 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D98865134 TSecr=3D98=
871521
>> 0.515351     Server -> Client     TCP 316 colubris > 58148 [PSH, ACK=
] Seq=3D751 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D98865191 TSecr=3D98=
871521
>> 0.518003     Client -> Server     TCP 316 [TCP Retransmission] 58148=
 > colubris [PSH, ACK] Seq=3D251 Ack=3D501 Win=3D31744 Len=3D250 TSval=3D=
98871579 TSecr=3D98865126
>> 0.518021     Server -> Client     TCP 78 [TCP Dup ACK 12#1] colubris=
 > 58148 [ACK] Seq=3D1001 Ack=3D501 Win=3D31232 Len=3D0 TSval=3D9886519=
1 TSecr=3D98871579 SLE=3D251 SRE=3D501
>> 0.518798     Server -> Client     TCP 316 [TCP Retransmission] colub=
ris > 58148 [PSH, ACK] Seq=3D751 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D=
98865192 TSecr=3D98871579
>> 0.544700     Client -> Server     TCP 78 [TCP Window Update] 58148 >=
 colubris [ACK] Seq=3D501 Ack=3D501 Win=3D32768 Len=3D0 TSval=3D9887158=
5 TSecr=3D98865126 SLE=3D751 SRE=3D1001
>> 0.549653     Client -> Server     TCP 86 [TCP Dup ACK 16#1] 58148 > =
colubris [ACK] Seq=3D501 Ack=3D501 Win=3D32768 Len=3D0 TSval=3D98871586=
 TSecr=3D98865126 SLE=3D751 SRE=3D1001 SLE=3D751 SRE=3D1001
>> 0.778802     Server -> Client     TCP 316 [TCP Retransmission] colub=
ris > 58148 [PSH, ACK] Seq=3D501 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D=
98865257 TSecr=3D98871586
>>=20
>=20
> Hello Mohammad
>=20
> It would be nice you reproduce the problem with packetdrill and possi=
bly
> using a more recent kernel.
>=20
> Having a packetdrill test is easier to demonstrate the problem and
> testing a fix if needed.
>=20
> Thanks !
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
