From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 21 Feb 2012 17:45:51 +0100
Message-ID: <1329842751.18384.10.camel@edumazet-laptop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <1329164293.2523.0.camel@edumazet-laptop>
	 <5196304.nDv69tPK8W@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41059 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab2BUQpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 11:45:55 -0500
Received: by werb13 with SMTP id b13so3924527wer.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 08:45:54 -0800 (PST)
In-Reply-To: <5196304.nDv69tPK8W@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 f=C3=A9vrier 2012 =C3=A0 06:21 +0200, alekcejk@googlemail.c=
om a=20
> I tested last released 3.2.7 kernel (2.6.42.7-1.fc15.i686).
> Speed problems in 3.2.7 the same as in 3.2.6.
>=20

I am not sure what you expected from 3.2.7, given we still are
discussing of issues.

> I also have Fedora Rawhide installed in virtual machine (e1000 driver=
 used there)
> running on host with 3.1.10 kernel.
> And I noticed that after one of 3.3 rc's (or even rc's of 3.2) kernel=
 updates download speed of
> updates from dl.fedoraproject.org in VM became extremely slow - about=
 160 kilobytes/sec
> instead of 1,2 megabytes/sec as it was before.
> But recently (somewhere between 3.3 rc3 and rc4) speed became again
> as it should 1,2 MB/s.
>=20
> Don't know is this problem related with speed in 3.2.x kernels
> and it is hard to debug this now.
>=20

We have a pretty clear idea of what happens, we have to decide if we=20
must change kernel defaults now or not.

On prior kernels, memory accounting was wrong, and a socket could
consume far more memory than the limit given.

See the 3rd column in :

net.ipv4.tcp_wmem =3D 4096        16384   897664
net.ipv4.tcp_rmem =3D 4096        87380   897664

We now have a more correct 'truesize' accounting, and this means a
socket cannot lie anymore : Instead of consuming 1.200.000 bytes for re=
ceive
buffers, it really cannot consume more than 897664 bytes.
(unless yet another driver try to lie)

On your 32bit kernel, this means the tcp_rmem[2] (897664) really=20
can be too small for your case with a 50 ms RTT, since memory/rtt is
limiting the bandwidth.

On a 64bit kernel, we hit the memory/rtt limit less often because
tcp_rmem[2] default value is 4127616, unless you have very small
available memory.

Maybe we should default tcp_rmem[2] to 4Mbytes, even on 32bit kernel.

Could you try :

sysctl net.ipv4.tcp_rmem=3D"4096 87380 4127616"
or
echo "4096 87380 4127616" >/proc/sys/net/ipv4/tcp_rmem
