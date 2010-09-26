From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 19:02:47 +0200
Message-ID: <1285520567.2530.8.camel@edumazet-laptop>
References: <20100926131717.GA13046@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54783 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674Ab0IZRCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 13:02:52 -0400
Received: by wyb28 with SMTP id 28so3221912wyb.19
        for <netdev@vger.kernel.org>; Sun, 26 Sep 2010 10:02:51 -0700 (PDT)
In-Reply-To: <20100926131717.GA13046@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 26 septembre 2010 =C3=A0 15:17 +0200, Willy Tarreau a =C3=A9=
crit :
> Hi,
>=20
> one haproxy user was reporting occasionally truncated responses to
> HTTP POST requests exclusively. After he took many captures, we
> could verify that the strace dumps were showing all data to be
> emitted, but network captures showed that an RST was emitted before
> the end of the data.
>=20
> Looking more closely, I noticed that in traces showing the issue,
> the client was sending an additional CRLF after the data in a
> separate packet (permitted eventhough not recommended).
>=20
> I could thus finally understand what happens and I'm now able to
> reproduce it very easily using the attached program. What happens
> is that haproxy sends the last data to the client, followed by a
> shutdown()+close(). This is mimmicked by the attached program,
> which is connected to by a simple netcat from another machine
> sending two distinct chunks :
>=20
> server:$ ./abort-data
> client:$ (echo "req1";usleep 200000; echo "req2") | nc6 server 8000
> block1
> ("block2" is missing here)
> client:$
>=20
> It gives the following capture, with client=3D10.8.3.4 and server=3D1=
0.8.3.1 :
>=20
> reading from file abort-linux.cap, link-type EN10MB (Ethernet)
> 10:47:07.057793 IP (tos 0x0, ttl 64, id 57159, offset 0, flags [DF], =
proto TCP (6), length 60)
>     10.8.3.4.39925 > 10.8.3.1.8000: Flags [S], cksum 0xdad9 (correct)=
, seq 2570439277, win 5840, options [mss 1460,sackOK,TS val 138417450 e=
cr 0,nop,wscale 6], length 0
> 10:47:07.058015 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], prot=
o TCP (6), length 60)
>     10.8.3.1.8000 > 10.8.3.4.39925: Flags [S.], cksum 0x3851 (correct=
), seq 1066199564, ack 2570439278, win 5792, options [mss 1460,sackOK,T=
S val 295921514 ecr 138417450,nop,wscale 7], length 0
> 10:47:07.058071 IP (tos 0x0, ttl 64, id 57160, offset 0, flags [DF], =
proto TCP (6), length 52)
>     10.8.3.4.39925 > 10.8.3.1.8000: Flags [.], cksum 0x7d60 (correct)=
, seq 2570439278, ack 1066199565, win 92, options [nop,nop,TS val 13841=
7451 ecr 295921514], length 0
> 10:47:07.058213 IP (tos 0x0, ttl 64, id 57161, offset 0, flags [DF], =
proto TCP (6), length 57)
>     10.8.3.4.39925 > 10.8.3.1.8000: Flags [P.], cksum 0x1a40 (incorre=
ct -> 0x8fbc), seq 2570439278:2570439283, ack 1066199565, win 92, optio=
ns [nop,nop,TS val 138417451 ecr 295921514], length 5
> 10:47:07.058410 IP (tos 0x0, ttl 64, id 36199, offset 0, flags [DF], =
proto TCP (6), length 52)
>     10.8.3.1.8000 > 10.8.3.4.39925: Flags [.], cksum 0x7d89 (correct)=
, seq 1066199565, ack 2570439283, win 46, options [nop,nop,TS val 29592=
1514 ecr 138417451], length 0
> 10:47:07.253294 IP (tos 0x0, ttl 64, id 57162, offset 0, flags [DF], =
proto TCP (6), length 53)
>     10.8.3.4.39925 > 10.8.3.1.8000: Flags [P.], cksum 0x1a3c (incorre=
ct -> 0x7321), seq 2570439283:2570439284, ack 1066199565, win 92, optio=
ns [nop,nop,TS val 138417500 ecr 295921514], length 1
> 10:47:07.253468 IP (tos 0x0, ttl 64, id 36200, offset 0, flags [DF], =
proto TCP (6), length 52)
>     10.8.3.1.8000 > 10.8.3.4.39925: Flags [.], cksum 0x7d27 (correct)=
, seq 1066199565, ack 2570439284, win 46, options [nop,nop,TS val 29592=
1562 ecr 138417500], length 0
> 10:47:08.060213 IP (tos 0x0, ttl 64, id 36201, offset 0, flags [DF], =
proto TCP (6), length 59)
>     10.8.3.1.8000 > 10.8.3.4.39925: Flags [P.], cksum 0x354c (correct=
), seq 1066199565:1066199572, ack 2570439284, win 46, options [nop,nop,=
TS val 295921765 ecr 138417500], length 7
> 10:47:08.060270 IP (tos 0x0, ttl 64, id 57163, offset 0, flags [DF], =
proto TCP (6), length 52)
>     10.8.3.4.39925 > 10.8.3.1.8000: Flags [.], cksum 0x7b5e (correct)=
, seq 2570439284, ack 1066199572, win 92, options [nop,nop,TS val 13841=
7701 ecr 295921765], length 0
> 10:47:08.060298 IP (tos 0x0, ttl 64, id 36202, offset 0, flags [DF], =
proto TCP (6), length 52)
>     10.8.3.1.8000 > 10.8.3.4.39925: Flags [R.], cksum 0x7c51 (correct=
), seq 1066199572, ack 2570439284, win 46, options [nop,nop,TS val 2959=
21765 ecr 138417500], length 0
> 10:47:08.060613 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], prot=
o TCP (6), length 40)
>     10.8.3.1.8000 > 10.8.3.4.39925: Flags [R], cksum 0xb0f5 (correct)=
, seq 1066199572, win 0, length 0
> .
>=20
> The connection should in theory become an orphan. I'm saying "in theo=
ry",
> because since the following test was added to tcp_close(), if the cli=
ent
> happens to send any data between the last recv() and the close(), we
> immediately send an RST to it, regardless of any pending outgoing dat=
a :
>=20
>         /* As outlined in RFC 2525, section 2.17, we send a RST here =
because
>          * data was lost. To witness the awful effects of the old beh=
avior of
>          * always doing a FIN, run an older 2.1.x kernel or 2.0.x, st=
art a bulk
>          * GET in an FTP client, suspend the process, wait for the cl=
ient to
>          * advertise a zero window, then kill -9 the FTP client, whee=
e...
>          * Note: timeout is always zero in such a case.
>          */
>         if (data_was_unread) {
>                 /* Unread data was tossed, zap the connection. */
>                 NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPABORTON=
CLOSE);
>                 tcp_set_state(sk, TCP_CLOSE);
>                 tcp_send_active_reset(sk, sk->sk_allocation);
> 	}
>=20
> The immediate effect then is that the client receives an abort before=
 it
> even gets the last data that were scheduled for being sent.
>=20
> I've read RFC 2525 #2.17 and it shows quite interesting examples of w=
hat
> it wanted to protect against. However, the recommendation did not con=
sider
> the fact that there could be some unacked pending data in the outgoin=
g
> buffers.
>=20
> What is even more more embarrassing is that the HTTP working group is
> trying to encourage browsers to enable pipelining by default. That me=
ans
> that the situation above can become much more common, where two reque=
sts
> will be pipeline, the first one will cause a short response followed =
by
> a close(), and the simple presence of the second one will kill the fi=
rst
> one's data.
>=20
> I tried to think about a finer way to process those unwanted data. Id=
eally,
> we should just ignore until the ACK indicates that our last segment w=
as
> properly received. Then we could emit the RST.
>=20
> I made a few attempts by first changing the test above like this :
>=20
> -        if (data_was_unread) {
> +        if (data_was_unread && !tcp_sk(sk)->packets_out) {
>=20
> then fiddling a little bit in tcp_input.c:tcp_rcv_state_process() for
> the TCP_FIN_WAIT1 state, but I'm not satisfied with my experimentatio=
ns,
> they were a bit too much experimental for the results to be considere=
d
> reliable.
>=20
> What I was looking for was a way to only send an RST when the socket =
is
> an orphan and all of its outgoing data has been ACKed. This would cov=
er
> the situations that RFC 2525 #2.17 tries to fix without rendering orp=
hans
> unusable.
>=20
> Has anyone an opinion on this, or even could suggest a patch to relax
> the conditions in which we send an RST ?

How could we delay the close() ? We must either send a FIN or RST.

I would say, fix the program, so that RST is avoided ?

The program does :

recv() // read the request
send() // queue the answer
close() // could work if world was perfect...

Change it to

recv()
send()
shutdown()
recv() // read & flush in excess data
close()

This for sure will send FIN after all queued data is sent.
I am not sure the final rcv() is even needed, its Sunday after all ;)


