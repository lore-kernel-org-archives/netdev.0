From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP keepalives ignored by kernel when the contain timestamps
Date: Fri, 10 Jun 2011 15:56:17 +0200
Message-ID: <1307714177.4044.4.camel@edumazet-laptop>
References: <4DF0E638.2010506@uth.tmc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Charles Bearden <Charles.F.Bearden@uth.tmc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55720 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932255Ab1FJN4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 09:56:21 -0400
Received: by wya21 with SMTP id 21so1877027wya.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 06:56:20 -0700 (PDT)
In-Reply-To: <4DF0E638.2010506@uth.tmc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 juin 2011 =C3=A0 10:26 -0500, Charles Bearden a =C3=A9crit =
:
> I have come across a case that looks like it might be a kernel bug. I=
t appears=20
> that tcp keepalives sent by a remote system are ignored when they con=
tain tcp=20
> timestamps, but are ACKed when they don't. When they are ignored, the=
 remote=20
> system resets the connection after a number of retries.
>=20
> I have replicated this problem on both Ubuntu 10.04 with a 2.6.32-32-=
server=20
> kernel (x86_64) and CentOS 5.6 with a 2.6.18-238.12.1.el5 kernel. I'm=
 sorry that=20
> I haven't had a chance to try to replicate the bug with a newer kerne=
l, though a=20
> co-worker has looked through changelogs for more recent kernels and d=
idn't find=20
> anything that looked relevant.
>=20
>  From either of these hosts I run an application that connects to a r=
emote host=20
> for 2-3 minutes, and that for most of that time sends no application =
data back=20
> and forth. After 30 seconds of no data from the Linux host, the remot=
e host=20
> sends a garden variety keepalive. When the remote host includes tcp t=
imestamps=20
> in the keepalives, they are ignored by the Linux host, and the remote=
 host=20
> resets the connection after 10 unACKed keepalives. When timestamps ar=
e absent=20
> from the keepalives, the Linux host ACKs each one, and all is copacet=
ic.
>=20
> Text output of a tcpdump trace of a connection that fails:
>    http://pastebin.com/v6CpteJ9
>=20
> Text output of a tcpdump trace of a connection that succeeds:
>    http://pastebin.com/KVLb3Mzh
>=20
> More details, in case you think they are relevant:
>=20
>    My application creates a JDBC connection to a remote MS SQL Server=
 and
>    executes a statement that does not return a result set, and so it =
doesn't
>    need to pass application data back and forth while it executes. Th=
e
>    statement takes 2 or 3 minutes to complete. I connect to two diffe=
rent
>    remote hosts: a Win2003 machine, and a Win2008R2 machine. The Win2=
003
>    machine doesn't put timestamps in its keep-alives, so the applicat=
ion
>    completes successfully when connecting to that host. If tcp timest=
amps
>    are enabled on the Linux host, the Win2008 host includes them in i=
ts
>    keepalives, and they are unACKed, so the connection is reset; if t=
hey
>    are disabled on the Linux host, the Win2008 host doesn't include t=
hem in
>    the keepalives, and the application completes successfully. I use =
(as
>    you might expect) sysctl to disable tcp timestamps on the Linux ho=
sts.
>=20
> I have dumps for all permutations of CentOS/Ubuntu, Win200[38], and +=
/-=20
> timestamps on the Linux side, and I will post them if the developers =
think that=20
> they would be useful.

Hi Charles

I could not reproduce the problem here, even using a quite old kernel a=
s
receiver (2.6.9)

15:54:33.566192 IP 192.168.20.108.55926 > 192.168.20.124.777: SWE
479814493:479814493(0) win 14600 <mss 1460,sackOK,timestamp 151666
0,nop,wscale 7>
15:54:33.566265 IP 192.168.20.124.777 > 192.168.20.108.55926: S
3714869381:3714869381(0) ack 479814494 win 5792 <mss
1460,sackOK,timestamp 54553041 151666,nop,wscale 2>
15:54:33.566274 IP 192.168.20.108.55926 > 192.168.20.124.777: . ack 1
win 115 <nop,nop,timestamp 151666 54553041>
15:54:33.566281 IP 192.168.20.108.55926 > 192.168.20.124.777: P 1:5(4)
ack 1 win 115 <nop,nop,timestamp 151666 54553041>
15:54:33.566351 IP 192.168.20.124.777 > 192.168.20.108.55926: . ack 5
win 1448 <nop,nop,timestamp 54553041 151666>
15:54:33.566375 IP 192.168.20.124.777 > 192.168.20.108.55926: P 1:5(4)
ack 5 win 1448 <nop,nop,timestamp 54553041 151666>
15:54:33.566380 IP 192.168.20.108.55926 > 192.168.20.124.777: . ack 5
win 115 <nop,nop,timestamp 151666 54553041>
15:54:43.577945 IP 192.168.20.108.55926 > 192.168.20.124.777: . 4:5(1)
ack 5 win 115 <nop,nop,timestamp 152668 54553041>
15:54:43.578012 IP 192.168.20.124.777 > 192.168.20.108.55926: . ack 5
win 1448 <nop,nop,timestamp 54563053 152668,nop,nop,sack sack 1 {4:5} >
15:54:53.597946 IP 192.168.20.108.55926 > 192.168.20.124.777: . 4:5(1)
ack 5 win 115 <nop,nop,timestamp 153670 54563053>
15:54:53.598012 IP 192.168.20.124.777 > 192.168.20.108.55926: . ack 5
win 1448 <nop,nop,timestamp 54573073 153670,nop,nop,sack sack 1 {4:5} >


Are you sure frame tcp checksums are OK when the 'faulty' linux receive
them ?   (tcpdump -v)



