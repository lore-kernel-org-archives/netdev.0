From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit
Date: Thu, 15 Dec 2011 09:24:29 +0100
Message-ID: <1323937469.2631.31.camel@edumazet-laptop>
References: <2D9E1426-D432-4D08-BF28-FD2615AAEDBA@mpi-bpc.mpg.de>
	 <CAK6E8=dcG3mw8r4FXt62G-0uoRNa9tcyQL3DS62MYe8F=9R6Nw@mail.gmail.com>
	 <1323901909.2631.17.camel@edumazet-laptop>
	 <201112150841.08087.carsten@wolffcarsten.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	"Esztermann, Ansgar" <Ansgar.Esztermann@mpi-bpc.mpg.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Carsten Wolff <carsten@wolffcarsten.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64102 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667Ab1LOIYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 03:24:33 -0500
Received: by wgbdr13 with SMTP id dr13so3602606wgb.1
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 00:24:32 -0800 (PST)
In-Reply-To: <201112150841.08087.carsten@wolffcarsten.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 d=C3=A9cembre 2011 =C3=A0 08:41 +0100, Carsten Wolff a =C3=A9=
crit :
> On Wednesday 14 December 2011, Eric Dumazet wrote:
> > Le mercredi 14 d=C3=A9cembre 2011 =C3=A0 11:00 -0800, Yuchung Cheng=
 a =C3=A9crit :
> > > I use tcptrace to check the time sequence and I am puzzled:
> > > I see a lot of OOO packets too but how can this happen at a sende=
r-side
> > > trace? unless the trace is taken close to but not exactly at the =
sender.
> > > I expect on seeing in-sequence packets but a lots of SACKs plus s=
ome
> > > spurious retransmists.
> >=20
> > I understood the trace was a receiver-side one (a linux machine if =
I am
> > not mistaken, while the sender is AIX powered)
> >=20
> > (Looking at timings of ACKS, coming a few us after corresponding da=
ta
> > packet arrival)
>=20
> Oh. Right. This also means, that net.ipv4.tcp_reordering is only avai=
lable at=20
> the receiver (Linux), which doesn't help, because the reordering robu=
stness=20
> stuff happens on sender-side. So don't even bother changing that sysc=
tl.
>=20

Oh well, reading Ansgar mail, it seems this is the other way :

quote :
2.6.37.6 with openSUSE patches in the sender, some version of AIX in th=
e
receiver. The latter seems to be critical: we've never encountered this
problem with any other combination of OSs but AIX & Linux.


I only dont understand how we can receive an ACK so fast (6 us after th=
e
data packet ACKed, even 3us a bit later). This seems not possible, even
with 10Gb infra. (A CISCO firewall was mentioned)

12:18:20.732998 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 284400:287136, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 2736
12:18:20.733004 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 287136, win 591, options [nop,nop,TS val 627192022 ecr 1327509818], l=
ength 0
12:18:20.733048 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 287136:293976, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 6840
12:18:20.733073 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 293976, win 549, options [nop,nop,TS val 627192022 ecr 1327509818], l=
ength 0
12:18:20.733104 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 293976:298080, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 4104
12:18:20.733120 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 298080, win 522, options [nop,nop,TS val 627192022 ecr 1327509818], l=
ength 0

Here next two packets we send are out of order.

12:18:20.733161 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 299448:300816, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733164 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 298080, win 522, options [nop,nop,TS val 627192022 ecr 1327509818,nop=
,nop,sack 1 {299448:300816}], length 0
12:18:20.733166 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 298080:299448, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733169 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 300816:302184, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733171 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 303552:304920, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733173 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 302184, win 490, options [nop,nop,TS val 627192022 ecr 1327509818,nop=
,nop,sack 1 {303552:304920}], length 0
12:18:20.733174 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 302184:303552, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733177 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 304920, win 469, options [nop,nop,TS val 627192022 ecr 1327509818], l=
ength 0
12:18:20.733224 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 304920:310392, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 5472
12:18:20.733228 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 311760:313128, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733230 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 310392, win 427, options [nop,nop,TS val 627192022 ecr 1327509818,nop=
,nop,sack 1 {311760:313128}], length 0
12:18:20.733272 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 313128:315864, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 2736
12:18:20.733276 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 310392, win 427, options [nop,nop,TS val 627192022 ecr 1327509818,nop=
,nop,sack 1 {311760:315864}], length 0
12:18:20.733326 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 315864:319968, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 4104
12:18:20.733330 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 310392, win 427, options [nop,nop,TS val 627192022 ecr 1327509818,nop=
,nop,sack 1 {311760:319968}], length 0
12:18:20.733332 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 310392:311760, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733333 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 321336:322704, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733335 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 319968, win 353, options [nop,nop,TS val 627192022 ecr 1327509818,nop=
,nop,sack 1 {321336:322704}], length 0
12:18:20.733372 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 322704:324072, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733375 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 319968, win 353, options [nop,nop,TS val 627192022 ecr 1327509818,nop=
,nop,sack 1 {321336:324072}], length 0
12:18:20.733377 IP 134.76.98.13.1500 > 10.208.9.87.35337: Flags [.], se=
q 319968:321336, ack 555, win 65280, options [nop,nop,TS val 1327509818=
 ecr 627192022], length 1368
12:18:20.733381 IP 10.208.9.87.35337 > 134.76.98.13.1500: Flags [.], ac=
k 324072, win 327, options [nop,nop,TS val 627192022 ecr 1327509818], l=
ength 0


Really, my feeling is this trace is taken on receiver, and maybe LRO/GR=
O
is buggy ?

Ansgar, please provide more details, like the NIC you use (hardware,
driver versions...)
