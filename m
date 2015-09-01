From: Mohammad Rajiullah <mohammad.rajiullah@kau.se>
Subject: Unexpected loss recovery in TLP
Date: Tue, 1 Sep 2015 11:36:04 +0200
Message-ID: <3D743BF2-C02D-4E89-91AE-7E7F1D95AED5@kau.se>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.39]:53449 "EHLO nasse.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754318AbbIAJgZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 05:36:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

While measuring TLP=E2=80=99s performance for an online gaming scenario=
,  where both the client and the server send data, TLP=20
shows unexpected loss recovery in Linux 3.18.5 kernel. Early retransmit=
 fails in response=20
to the dupack which is later resolved using RTO.  I found the behaviour=
 consistent during the whole measurement period.
=46ollowing is an excerpt from the tcpdump traces (taken at the server)=
 showing the behaviour:

0.733965    Client -> Server     HTTP 431 POST /Scores HTTP/1.1=20
0.738355     Server -> Client HTTP 407 HTTP/1.1 200 OK=20
0.985346     Server -> Client TCP 68 [TCP segment of a reassembled PDU]
0.993322     Client -> Server     HTTP 431 [TCP Retransmission] POST /S=
cores HTTP/1.1=20
0.993352     Server -> Client TCP 78 [TCP Dup ACK 2339#1] 8081=E2=86=92=
45451 [ACK] Seq=3D186995 Ack=3D230031  Len=3D0   SLE=3D229666 SRE=3D230=
031
1.089327     Server -> Client TCP 68 [TCP Retransmission] 8081=E2=86=92=
45451 [PSH, ACK] Seq=3D186993 Ack=3D230031  Len=3D2 =20
1.294816     Client -> Server     TCP 78 [TCP Dup ACK 2340#1] 45451=E2=86=
=928081 [ACK] Seq=3D230031 Ack=3D186652  Len=3D0   SLE=3D186993 SRE=3D1=
86995
1.295018     Client -> Server     TCP 86 [TCP Dup ACK 2340#2] 45451=E2=86=
=928081 [ACK] Seq=3D230031 Ack=3D186652  Len=3D0   SLE=3D186993 SRE=3D1=
86995 SLE=3D186993 SRE=3D186995
1.541328     Server -> Client HTTP 407 [TCP Retransmission] HTTP/1.1 20=
0 OK =20

=46rom some kernel debug info (using printk ..) it appears that for som=
e reason although the incoming dupack=20
starts the early retransmit delay timer, it never expires. The above me=
asurement was taken in a=20
wireless environment. I also recreated the scenario in a wired network =
with synthetic traffic to have regular=20
RTTs. The behaviour remains the same. =20
0.287241     Client -> Server     TCP 316 58148 > colubris [PSH, ACK] S=
eq=3D251 Ack=3D501 Win=3D31744 Len=3D250 TSval=3D98871521 TSecr=3D98865=
126
0.287278     Server -> Client     TCP 316 colubris > 58148 [PSH, ACK] S=
eq=3D501 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D98865134 TSecr=3D98871=
521
0.515351     Server -> Client     TCP 316 colubris > 58148 [PSH, ACK] S=
eq=3D751 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D98865191 TSecr=3D98871=
521
0.518003     Client -> Server     TCP 316 [TCP Retransmission] 58148 > =
colubris [PSH, ACK] Seq=3D251 Ack=3D501 Win=3D31744 Len=3D250 TSval=3D9=
8871579 TSecr=3D98865126
0.518021     Server -> Client     TCP 78 [TCP Dup ACK 12#1] colubris > =
58148 [ACK] Seq=3D1001 Ack=3D501 Win=3D31232 Len=3D0 TSval=3D98865191 T=
Secr=3D98871579 SLE=3D251 SRE=3D501
0.518798     Server -> Client     TCP 316 [TCP Retransmission] colubris=
 > 58148 [PSH, ACK] Seq=3D751 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D9=
8865192 TSecr=3D98871579
0.544700     Client -> Server     TCP 78 [TCP Window Update] 58148 > co=
lubris [ACK] Seq=3D501 Ack=3D501 Win=3D32768 Len=3D0 TSval=3D98871585 T=
Secr=3D98865126 SLE=3D751 SRE=3D1001
0.549653     Client -> Server     TCP 86 [TCP Dup ACK 16#1] 58148 > col=
ubris [ACK] Seq=3D501 Ack=3D501 Win=3D32768 Len=3D0 TSval=3D98871586 TS=
ecr=3D98865126 SLE=3D751 SRE=3D1001 SLE=3D751 SRE=3D1001
0.778802     Server -> Client     TCP 316 [TCP Retransmission] colubris=
 > 58148 [PSH, ACK] Seq=3D501 Ack=3D501 Win=3D31232 Len=3D250 TSval=3D9=
8865257 TSecr=3D98871586



Cheers,
Mohammad
