From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis
 purpose.
Date: Sat, 19 Mar 2011 07:03:24 +0100
Message-ID: <1300514604.2831.23.camel@edumazet-laptop>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	 <1300351330.10164.712.camel@edumazet-laptop>
	 <AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	 <20110317142030.62af785a@nehalam>
	 <AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
	 <1300428324.2881.5.camel@edumazet-laptop>
	 <AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com>
	 <1300510960.2831.2.camel@edumazet-laptop>
	 <AANLkTimsoF+khCfU2aEQNoJ0DBf_p9-v+Zim0X5RrLpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49667 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab1CSGDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 02:03:30 -0400
Received: by wya21 with SMTP id 21so4458056wya.19
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 23:03:29 -0700 (PDT)
In-Reply-To: <AANLkTimsoF+khCfU2aEQNoJ0DBf_p9-v+Zim0X5RrLpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 mars 2011 =C3=A0 22:38 -0700, Jerry Chu a =C3=A9crit :
> On Fri, Mar 18, 2011 at 10:02 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > Le vendredi 18 mars 2011 =C3=A0 21:33 -0700, Jerry Chu a =C3=A9crit=
 :
> >
> >> I'm well aware of the past, hideous O(n**2) problem of reading
> >> /proc/net/tcp but I
> >> thought the problem has been fixed by Tom Herbert a while back, no=
?
> >> (See http://marc.info/?l=3Dlinux-netdev&m=3D127588123429437&w=3D2)
> >>
> >
> > O(N) is still too slow, to gather stats for your socket, if you wan=
t to
> > gather stats once per second for example.
>=20
> I don't see anyway around O(n). The netlink/inet_diag_dump() will tak=
e at
> best O(n) too.

1) netlink is extensible, without breaking old apps.

2) netlink is able to dump part of the information, while
whith /proc/net/tcp you have to cat all the file and grep the needed
info. O(1) is better than O(10)

Example :

I only want info of socket identified by dst ip 192.168.0.144 and dst
port 58196

# ss -emoi dst 192.168.20.144:58196
State       Recv-Q Send-Q     Local Address:Port         Peer Address:P=
ort  =20
ESTAB       0      0         192.168.20.108:65111      192.168.20.144:5=
8196    ino:3302 sk:ffff88011c278c80
	 mem:(r0,w0,f0,t0) sack cubic wscale:7,7 rto:201 rtt:1.75/0.75 cwnd:10=
 send 66.7Mbps rcv_space:14600

I want all sockets to remote 192.168.20.110
# ss -emoi dst 192.168.20.110
State       Recv-Q Send-Q     Local Address:Port         Peer Address:P=
ort  =20
ESTAB       0      0      ::ffff:192.168.20.108:ssh     ::ffff:192.168.=
20.110:47633    timer:(keepalive,120min,0) ino:70342 sk:ffff88011c38150=
0
	 mem:(r0,w0,f0,t0) ts sack ecn cubic wscale:8,7 rto:207 rtt:7.625/11.5=
 ato:40 cwnd:10 send 15.2Mbps rcv_rtt:1 rcv_space:14480



3) getsockopt(fd) is O(1)

>=20
> >
> > AFAIK, I am not sure we want to allow any user to access all these =
data
> > for all tcp sockets on the machine. This might have security impact=
s.
>=20
> This seems to be an orthogonal issue to netlink or /proc/net/tcp.

getsockopt(fd) only finds information about your own socket.

An application might want to log tcp information only right before
closing one socket. This sounds more practical than having a separate
spy thread.



