From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP_DEFER_ACCEPT issues
Date: Fri, 02 Nov 2007 08:24:30 +0100
Message-ID: <472AD0AE.50106@cosmosbay.com>
References: <20071102013321.GA30893@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46481 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179AbXKBH0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 03:26:08 -0400
In-Reply-To: <20071102013321.GA30893@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46elix von Leitner a =E9crit :
> I am trying to use TCP_DEFER_ACCEPT in my web server.
>=20
> There are some operational problems.  First of all: timeout handling.=
  I
> would like to be able to set a timeout in seconds (or better:
> milliseconds) for how long the socket is allowed to sit there without
> data coming in.  For high load situations, I have been enforcing
> timeouts in the range of 15 seconds, otherwise someone can DoS the
> server by opening a lot of connections and tying up data structures.
>=20
> It is still possible, of course, to tie up kernel memory this way, by
> not reacting to the FIN or RST packets and running into a timeout the=
re,
> too, but that is partially tunable via sysctl.
>=20
> According to tcp(7) the int argument to TCP_DEFER_ACCEPT is in second=
s.
> In the kernel code, it's converted to TCP timeout units.  When I ran =
my
> server, and connected without sending any data, nothing happened.  No
> timeout.  Minutes later, the connection was still there.  Even worse:
> when I killed (!) the server process (thus closing the server socket)=
,
> the client did not get a reset.  Only when I type something in the
> telnet, I get a reset.  This appears to be very broken.
>=20
> My suggestion:
>=20
>   1. make the argument to the setsockopt be in seconds, or millisecon=
ds.
>   2. if the server socket is closed, reset all pending connections.
>=20
> Comments?
>=20

I agree TCP_DEFER_ACCEPT is not worth it at the current time, if you ta=
ke into=20
account the bad guys, or very slow networks.

1) Setting a timeout in a millisecond range (< 1000) is not very good b=
ecause=20
some clients may need much more time to send your server the data (very=
 long=20
distance). So a second granularity is OK.

2) After timeout is elapsed, the server tcp stack has no socket associa=
ted to=20
your client attempt. So closing the server listening socket wont be abl=
e to=20
send RST. I agree a RST *should* be sent by the server once the timeout=
 is=20
triggered.

A typical tcpdump of what is happening for a tcp_defer_accept timeout o=
f 20=20
seconds is :

[1]08:52:47.480291 IP client.60930 > server.http: S 2498995442:24989954=
42(0)=20
win 5840 <mss 1460,sackOK,timestamp 2685904595 0,nop,wscale 2>
[2]08:52:47.480302 IP server.http > client.60930: S 1173302644:11733026=
44(0)=20
ack 2498995443 win 5840 <mss 1460>
[3]08:52:47.481669 IP client.60930 > server.http: . ack 1 win 5840

[4]08:52:50.757543 IP server.http > client.60930: S 1173302644:11733026=
44(0)=20
ack 2498995443 win 5840 <mss 1460>
[5]08:52:50.758953 IP client.60930 > server.http: . ack 1 win 5840

[6]08:52:56.760611 IP server.http > client.60930: S 1173302644:11733026=
44(0)=20
ack 2498995443 win 5840 <mss 1460>
[7]08:52:56.761886 IP client.60930 > server.http: . ack 1 win 5840

[8]08:53:08.771254 IP server.http > client.60930: S 1173302644:11733026=
44(0)=20
ack 2498995443 win 5840 <mss 1460>
[9]08:53:08.772514 IP client.60930 > server.http: . ack 1 win 5840

[10]08:53:32.782488 IP server.http > client.60930: S 1173302644:1173302=
644(0)=20
ack 2498995443 win 5840 <mss 1460>
[11]08:53:32.783754 IP client.60930 > server.http: . ack 1 win 5840

<a very long time, then client finally sends 2 bytes>

[12]08:59:30.509097 IP client.60930 > server.http: P 1:3(2) ack 1 win 5=
840
[13]08:59:30.509125 IP server.http > client.60930: R 1173302645:1173302=
645(0)=20
win 0


So TCP_DEFER_ACCEPT might send way more packets than needed. Packets 4,=
6,8,10=20
(and their corresponding acks 5,7,9,11) seem un-necessary, since (1,2,3=
) has=20
engaged a normal TCP session (three way handshake).

We only should wait for the data coming from the client to be able to p=
ass the=20
new socket to the listening application.


