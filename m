From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis purpose.
Date: Sun, 20 Mar 2011 00:30:58 -0700
Message-ID: <AANLkTikyoS-YDH+N92yCXiFg7MfXhSHeudND9VJgAp15@mail.gmail.com>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	<1300351330.10164.712.camel@edumazet-laptop>
	<AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	<20110317142030.62af785a@nehalam>
	<AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
	<1300428324.2881.5.camel@edumazet-laptop>
	<AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com>
	<1300510960.2831.2.camel@edumazet-laptop>
	<AANLkTimsoF+khCfU2aEQNoJ0DBf_p9-v+Zim0X5RrLpw@mail.gmail.com>
	<1300514604.2831.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:41950 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab1CTHbD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 03:31:03 -0400
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p2K7V1pk008041
	for <netdev@vger.kernel.org>; Sun, 20 Mar 2011 00:31:01 -0700
Received: from yxk8 (yxk8.prod.google.com [10.190.3.136])
	by kpbe11.cbf.corp.google.com with ESMTP id p2K7UxfC014749
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 20 Mar 2011 00:31:00 -0700
Received: by yxk8 with SMTP id 8so2167284yxk.32
        for <netdev@vger.kernel.org>; Sun, 20 Mar 2011 00:30:59 -0700 (PDT)
In-Reply-To: <1300514604.2831.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2011 at 11:03 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>
> Le vendredi 18 mars 2011 =E0 22:38 -0700, Jerry Chu a =E9crit :
> > On Fri, Mar 18, 2011 at 10:02 PM, Eric Dumazet <eric.dumazet@gmail.=
com> wrote:
> > > Le vendredi 18 mars 2011 =E0 21:33 -0700, Jerry Chu a =E9crit :
> > >
> > >> I'm well aware of the past, hideous O(n**2) problem of reading
> > >> /proc/net/tcp but I
> > >> thought the problem has been fixed by Tom Herbert a while back, =
no?
> > >> (See http://marc.info/?l=3Dlinux-netdev&m=3D127588123429437&w=3D=
2)
> > >>
> > >
> > > O(N) is still too slow, to gather stats for your socket, if you w=
ant to
> > > gather stats once per second for example.
> >
> > I don't see anyway around O(n). The netlink/inet_diag_dump() will t=
ake at
> > best O(n) too.
>
> 1) netlink is extensible, without breaking old apps.
>
> 2) netlink is able to dump part of the information, while
> whith /proc/net/tcp you have to cat all the file and grep the needed
> info. O(1) is better than O(10)
>
> Example :
>
> I only want info of socket identified by dst ip 192.168.0.144 and dst
> port 58196
>
> # ss -emoi dst 192.168.20.144:58196
> State =A0 =A0 =A0 Recv-Q Send-Q =A0 =A0 Local Address:Port =A0 =A0 =A0=
 =A0 Peer Address:Port
> ESTAB =A0 =A0 =A0 0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 192.168.20.108:65111=
 =A0 =A0 =A0192.168.20.144:58196 =A0 =A0ino:3302 sk:ffff88011c278c80
> =A0 =A0 =A0 =A0 mem:(r0,w0,f0,t0) sack cubic wscale:7,7 rto:201 rtt:1=
=2E75/0.75 cwnd:10 send 66.7Mbps rcv_space:14600
>
> I want all sockets to remote 192.168.20.110
> # ss -emoi dst 192.168.20.110
> State =A0 =A0 =A0 Recv-Q Send-Q =A0 =A0 Local Address:Port =A0 =A0 =A0=
 =A0 Peer Address:Port
> ESTAB =A0 =A0 =A0 0 =A0 =A0 =A00 =A0 =A0 =A0::ffff:192.168.20.108:ssh=
 =A0 =A0 ::ffff:192.168.20.110:47633 =A0 =A0timer:(keepalive,120min,0) =
ino:70342 sk:ffff88011c381500
> =A0 =A0 =A0 =A0 mem:(r0,w0,f0,t0) ts sack ecn cubic wscale:8,7 rto:20=
7 rtt:7.625/11.5 ato:40 cwnd:10 send 15.2Mbps rcv_rtt:1 rcv_space:14480

I presume the filtering of specific IP addrs/ports are done in the
kernel to short-circuit the
O(n) loop. Otherwise it seems moot (i.e., it still costs O(n)).

A quick look at inet_csk_diag_dump() does not reveal anything like
that. But I haven't
looked hard enough.

>
>
> 3) getsockopt(fd) is O(1)
>
> >
> > >
> > > AFAIK, I am not sure we want to allow any user to access all thes=
e data
> > > for all tcp sockets on the machine. This might have security impa=
cts.
> >
> > This seems to be an orthogonal issue to netlink or /proc/net/tcp.
>
> getsockopt(fd) only finds information about your own socket.

Make no mistake if my usage case was driven by specific apps why would =
I
waste my time chasing /proc/net/tcp? In fact we've had a private
TCP_INFO_EXT socket option for years used by some specific apps. (We
have not tried to pushed it upstreams because some of the counters we c=
ollect
are too Google specific.)

But my immediate use of the counters/stats proposed here is for our int=
ernal
monitor programs to take samples occasionally from ALL CONNECTIONS, or =
for
diagnosis purpose from the TCP layer when we don't have specific info a=
bout the
apps' IP or port# (so we just want to dump info from all connections).

>
> An application might want to log tcp information only right before
> closing one socket. This sounds more practical than having a separate
> spy thread.

I'm not trying to use /proc/net/tcp (or netlink) because I don't know a=
bout
other, more efficient way to retrieve counters from a subset, or even j=
ust one
specific connection as explained above.

Jerry

>
>
>
