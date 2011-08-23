From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP - RST flag
Date: Tue, 23 Aug 2011 22:55:32 +0200
Message-ID: <1314132932.4478.0.camel@edumazet-laptop>
References: <CAEnQRZAchYf-3-t7RRogfb0WogzY9ZF8rzMdtOeS1Vdvx7N4og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	kernelnewbies <kernelnewbies@kernelnewbies.org>
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48400 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534Ab1HWUzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 16:55:36 -0400
Received: by wyg24 with SMTP id 24so386809wyg.19
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 13:55:35 -0700 (PDT)
In-Reply-To: <CAEnQRZAchYf-3-t7RRogfb0WogzY9ZF8rzMdtOeS1Vdvx7N4og@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 ao=C3=BBt 2011 =C3=A0 23:31 +0300, Daniel Baluta a =C3=A9cr=
it :
> Hello,
>=20
> Please help me understanding the behavior of the following
> TCP conversation.
>=20
> You can find bellow a snippet of the (FTP) conversation captured both
> on client (C) and server (S).
>=20
> [client]$ tcpdump  -n  -r client-6-conv.cap
> [P1] 49.045690 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [P.], seq
> 197:220, ack 81, win 757, length 23
> [P2] 49.046600 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 220=
,
> win 738, length 0
> [P3] 49.047462 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [P.], seq
> 81:87, ack 220, win 738, length 6
> [P5] 49.048757 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [F.], seq
> 242, ack 87, win 757, length 0
> [P6] 49.048794 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 220=
,
> win 738, options [nop,nop,sack 1 {242:243}], length 0
> [P4] 49.048801 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [P.], seq
> 220:242, ack 87, win 757, length 22
> [P7] 49.048833 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 243=
,
> win 715, length 0
> [P8] 49.049566 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [F.], seq 87=
,
> ack 243, win 715, length 0
> [P9] 49.050889 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [R], seq
> 1672731590, win 0, length 0
>=20
> [server]$ tcpdump  -n  -r server-6-conv.cap
> [P1] 49.059740 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [P.], seq
> 197:220, ack 81, win 757, length 23
> [P2] 49.061394 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 220=
,
> win 738, length 0
> [P3] 49.061760 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [P.], seq
> 81:87, ack 220, win 738, length 6
> [P4] 49.062794 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [P.], seq
> 220:242, ack 87, win 757, length 22
> [P5] 49.062843 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [F.], seq
> 242, ack 87, win 757, length 0
> [P6] 49.063808 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 220=
,
> win 738, options [nop,nop,sack 1 {242:243}], length 0
> [P7] 49.063823 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [.], ack 243=
,
> win 715, length 0
> [P8] 49.064271 IP 10.10.0.20.58277 > 10.10.0.1.21: Flags [F.], seq 87=
,
> ack 243, win 715, length 0
> [P9] 49.064481 IP 10.10.0.1.21 > 10.10.0.20.58277: Flags [R], seq
> 1672731590, win 0, length 0
>=20
> What happens is that servers sends packets P4 and P5, but client
> receives P5 before P4.
> Since SACK is enabled, client will send a SACK (P6) ack-ing P5.
>=20
> Then client sees P4, and will send an ack (P7) for P4, then sends P8
> with FIN flag set.
> What I don't understand, is why server responds with RST (P9) instead=
 of ACK?
>=20
> This is was obtained on 2.6.32.43. I have also attached full capture =
files.
>=20
> I am reading TCP's RFC and kernel code, but so far I haven't reached
> a conclusion.

TCP in RFC 1122 section 4.2.2.13:

 "A host MAY implement a "half-duplex" TCP close sequence, so that an
 application that has called CLOSE cannot continue to read data from th=
e
 connection. If such a host issues a CLOSE call while received data is
 still pending in TCP, or if new data is received after CLOSE is called=
,
 its TCP SHOULD send a RST to show that data was lost."=20

This is why some apps first call shutdown(), then drain receive queue,
then close()
