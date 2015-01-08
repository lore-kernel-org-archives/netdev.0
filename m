From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is received
Date: Thu, 8 Jan 2015 10:43:07 -0500
Message-ID: <CADVnQy=kACmKGkakx85BHWg7WppS3-B1yLa-TXvfBKbXtXYJ+A@mail.gmail.com>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>
	<1420729656.5947.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<54AEA11A.1000603@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: =?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:54851 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbbAHPnI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:43:08 -0500
Received: by mail-qg0-f47.google.com with SMTP id q108so2664610qgd.6
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 07:43:08 -0800 (PST)
In-Reply-To: <54AEA11A.1000603@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Le 08/01/2015 16:07, Eric Dumazet a =C3=A9crit :
>> Do you have at hand a packetdrill test to demonstrate that the patch
>> works ?

I cooked up the packetdrill test below when Sebastien sent out his v1
a few weeks ago. It fails on a kernel without his patch, and passes on
a kernel with his patch.

The code change looks fine to me, but if Eric prefers that the
expression be assigned to a bool before the check, that also sounds
fine to me.

neal


------------
// Establish a connection.
0     socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
+0     setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
+0    bind(3, ..., ...) =3D 0
+0    listen(3, 1) =3D 0

+0    < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
+0    > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
+.020 < . 1:1(0) ack 1 win 257
+0    accept(3, ..., ...) =3D 4

// Send 1 packet.
+0    write(4, ..., 1000) =3D 1000
+0    > P. 1:1001(1000) ack 1

// Loss probe retransmission.
// packets_out =3D=3D 1 =3D> schedule PTO in max(2*RTT, 1.5*RTT + 200ms=
)
// In this case, this means: 1.5*RTT + 200ms =3D 230ms
+.230 > P. 1:1001(1000) ack 1
+0    %{ assert tcpi_snd_cwnd =3D=3D 10 }%

// Receiver ACKs at tlp_high_seq with a DSACK,
// indicating they received the original packet and probe.
+.020 < . 1:1(0) ack 1001 win 257 <sack 1:1001,nop,nop>
+0    %{ assert tcpi_snd_cwnd =3D=3D 10 }%

// Send another packet.
+0    write(4, ..., 1000) =3D 1000
+0    > P. 1001:2001(1000) ack 1

// Receiver ACKs above tlp_high_seq, which should end the TLP episode
// if we haven't already. We should not reduce cwnd.
+.020 < . 1:1(0) ack 2001 win 257
+0    %{ assert tcpi_snd_cwnd =3D=3D 10, tcpi_snd_cwnd }%
