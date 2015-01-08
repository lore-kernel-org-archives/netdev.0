From: =?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Thu, 8 Jan 2015 17:00:24 +0100
Message-ID: <54AEA998.5010109@uclouvain.be>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be>	<1420729656.5947.50.camel@edumazet-glaptop2.roam.corp.google.com>	<54AEA11A.1000603@uclouvain.be> <CADVnQy=kACmKGkakx85BHWg7WppS3-B1yLa-TXvfBKbXtXYJ+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33973 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877AbbAHQAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 11:00:37 -0500
In-Reply-To: <CADVnQy=kACmKGkakx85BHWg7WppS3-B1yLa-TXvfBKbXtXYJ+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Le 08/01/2015 16:43, Neal Cardwell a =C3=A9crit :
>> Le 08/01/2015 16:07, Eric Dumazet a =C3=A9crit :
>>> Do you have at hand a packetdrill test to demonstrate that the patc=
h
>>> works ?
> I cooked up the packetdrill test below when Sebastien sent out his v1
> a few weeks ago. It fails on a kernel without his patch, and passes o=
n
> a kernel with his patch.
Thanks a lot for this ! I will include it in our test suite then.
I understand that there is convergence on having a
bool called is_probe_rcvd with the whole logic.
Eric, is this ok for you ?

Thanks,

S=C3=A9bastien.
>
> The code change looks fine to me, but if Eric prefers that the
> expression be assigned to a bool before the check, that also sounds
> fine to me.
>
> neal
>
>
> ------------
> // Establish a connection.
> 0     socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
> +0     setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> +0    bind(3, ..., ...) =3D 0
> +0    listen(3, 1) =3D 0
>
> +0    < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
> +0    > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
> +.020 < . 1:1(0) ack 1 win 257
> +0    accept(3, ..., ...) =3D 4
>
> // Send 1 packet.
> +0    write(4, ..., 1000) =3D 1000
> +0    > P. 1:1001(1000) ack 1
>
> // Loss probe retransmission.
> // packets_out =3D=3D 1 =3D> schedule PTO in max(2*RTT, 1.5*RTT + 200=
ms)
> // In this case, this means: 1.5*RTT + 200ms =3D 230ms
> +.230 > P. 1:1001(1000) ack 1
> +0    %{ assert tcpi_snd_cwnd =3D=3D 10 }%
>
> // Receiver ACKs at tlp_high_seq with a DSACK,
> // indicating they received the original packet and probe.
> +.020 < . 1:1(0) ack 1001 win 257 <sack 1:1001,nop,nop>
> +0    %{ assert tcpi_snd_cwnd =3D=3D 10 }%
>
> // Send another packet.
> +0    write(4, ..., 1000) =3D 1000
> +0    > P. 1001:2001(1000) ack 1
>
> // Receiver ACKs above tlp_high_seq, which should end the TLP episode
> // if we haven't already. We should not reduce cwnd.
> +.020 < . 1:1(0) ack 2001 win 257
> +0    %{ assert tcpi_snd_cwnd =3D=3D 10, tcpi_snd_cwnd }%
