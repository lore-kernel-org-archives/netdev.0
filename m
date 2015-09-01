From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unexpected loss recovery in TLP
Date: Tue, 01 Sep 2015 05:31:32 -0700
Message-ID: <1441110692.8932.168.camel@edumazet-glaptop2.roam.corp.google.com>
References: <3D743BF2-C02D-4E89-91AE-7E7F1D95AED5@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mohammad Rajiullah <mohammad.rajiullah@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34280 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755757AbbIAMbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 08:31:35 -0400
Received: by pabzx8 with SMTP id zx8so175788483pab.1
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 05:31:35 -0700 (PDT)
In-Reply-To: <3D743BF2-C02D-4E89-91AE-7E7F1D95AED5@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-01 at 11:36 +0200, Mohammad Rajiullah wrote:
> Hi!
>=20
> While measuring TLP=E2=80=99s performance for an online gaming scenar=
io,  where both the client and the server send data, TLP=20
> shows unexpected loss recovery in Linux 3.18.5 kernel. Early retransm=
it fails in response=20
> to the dupack which is later resolved using RTO.  I found the behavio=
ur consistent during the whole measurement period.
> Following is an excerpt from the tcpdump traces (taken at the server)=
 showing the behaviour:
>=20
> 0.733965    Client -> Server     HTTP 431 POST /Scores HTTP/1.1=20
> 0.738355     Server -> Client HTTP 407 HTTP/1.1 200 OK=20
> 0.985346     Server -> Client TCP 68 [TCP segment of a reassembled PD=
U]
> 0.993322     Client -> Server     HTTP 431 [TCP Retransmission] POST =
/Scores HTTP/1.1=20
> 0.993352     Server -> Client TCP 78 [TCP Dup ACK 2339#1] 8081=E2=86=92=
45451 [ACK] Seq=3D186995 Ack=3D230031  Len=3D0   SLE=3D229666 SRE=3D230=
031
> 1.089327     Server -> Client TCP 68 [TCP Retransmission] 8081=E2=86=92=
45451 [PSH, ACK] Seq=3D186993 Ack=3D230031  Len=3D2 =20
> 1.294816     Client -> Server     TCP 78 [TCP Dup ACK 2340#1] 45451=E2=
=86=928081 [ACK] Seq=3D230031 Ack=3D186652  Len=3D0   SLE=3D186993 SRE=3D=
186995
> 1.295018     Client -> Server     TCP 86 [TCP Dup ACK 2340#2] 45451=E2=
=86=928081 [ACK] Seq=3D230031 Ack=3D186652  Len=3D0   SLE=3D186993 SRE=3D=
186995 SLE=3D186993 SRE=3D186995
> 1.541328     Server -> Client HTTP 407 [TCP Retransmission] HTTP/1.1 =
200 OK =20
>=20
> From some kernel debug info (using printk ..) it appears that for som=
e reason although the incoming dupack=20
> starts the early retransmit delay timer, it never expires. The above =
measurement was taken in a=20
> wireless environment. I also recreated the scenario in a wired networ=
k with synthetic traffic to have regular=20
> RTTs. The behaviour remains the same. =20
> 0.287241     Client -> Server     TCP 316 58148 > colubris [PSH, ACK]=
 Seq=3D251 Ack=3D501 Win=3D31744 Len=3D250 TSval=3D98871521 TSecr=3D988=
65126
> 0.287278     Server -> Client     TCP 316 colubris > 58148 [PSH, ACK]=
 Seq=3D501 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D98865134 TSecr=3D988=
71521
> 0.515351     Server -> Client     TCP 316 colubris > 58148 [PSH, ACK]=
 Seq=3D751 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D98865191 TSecr=3D988=
71521
> 0.518003     Client -> Server     TCP 316 [TCP Retransmission] 58148 =
> colubris [PSH, ACK] Seq=3D251 Ack=3D501 Win=3D31744 Len=3D250 TSval=3D=
98871579 TSecr=3D98865126
> 0.518021     Server -> Client     TCP 78 [TCP Dup ACK 12#1] colubris =
> 58148 [ACK] Seq=3D1001 Ack=3D501 Win=3D31232 Len=3D0 TSval=3D98865191=
 TSecr=3D98871579 SLE=3D251 SRE=3D501
> 0.518798     Server -> Client     TCP 316 [TCP Retransmission] colubr=
is > 58148 [PSH, ACK] Seq=3D751 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D=
98865192 TSecr=3D98871579
> 0.544700     Client -> Server     TCP 78 [TCP Window Update] 58148 > =
colubris [ACK] Seq=3D501 Ack=3D501 Win=3D32768 Len=3D0 TSval=3D98871585=
 TSecr=3D98865126 SLE=3D751 SRE=3D1001
> 0.549653     Client -> Server     TCP 86 [TCP Dup ACK 16#1] 58148 > c=
olubris [ACK] Seq=3D501 Ack=3D501 Win=3D32768 Len=3D0 TSval=3D98871586 =
TSecr=3D98865126 SLE=3D751 SRE=3D1001 SLE=3D751 SRE=3D1001
> 0.778802     Server -> Client     TCP 316 [TCP Retransmission] colubr=
is > 58148 [PSH, ACK] Seq=3D501 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D=
98865257 TSecr=3D98871586
>=20

Hello Mohammad

It would be nice you reproduce the problem with packetdrill and possibl=
y
using a more recent kernel.

Having a packetdrill test is easier to demonstrate the problem and
testing a fix if needed.

Thanks !
