From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP syn flood handling regression
Date: Sat, 10 Mar 2012 09:44:50 -0800
Message-ID: <1331401490.2453.28.camel@edumazet-laptop>
References: <20120310122725.GA31129@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Kirby <sim@netnation.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43161 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab2CJRo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 12:44:57 -0500
Received: by wejx9 with SMTP id x9so1982315wej.19
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2012 09:44:56 -0800 (PST)
In-Reply-To: <20120310122725.GA31129@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 mars 2012 =C3=A0 04:27 -0800, Simon Kirby a =C3=A9crit :
> Hello!
>=20
> A typical port 80 SYN flood started up to one of our clusters, but th=
is
> time, it didn't work so well. Legitimate connections and trying to fe=
tch
> server-status via localhost would hang for ~30 seconds before respond=
ing,
> even though though the box had plenty of spare cycles. An strace of a=
ll
> Apache processes showed quite a bit of sleeping in accept4().
>=20
> This was with 3.2.9, so I went back in kernel builds and found that 3=
=2E1
> and 3.0 were also broken, while 2.6.39 works as I remember -- when sy=
n
> cookies are enabled, everything just works and is fast. The DoS kept =
up,
> so I was able to feed a bit to a node to do some bisection.
>=20
> Of course, the DoS stopped literally seconds before the last bisectio=
n
> test, but I got it down to:
>=20
> # good: [0e734419923bd8e599858f8fc196c7804bb85564] ipv4: Use inet_csk=
_route_child_sock() in DCCP and TCP.
> # bad: [ea4fc0d6193ff56fcef39b0d2210d402a7acb5f0] ipv4: Don't use rt-=
>rt_{src,dst} in ip_queue_xmit().
>=20
> ...leaving ea4fc0d6193ff56fcef39b0d2210d402a7acb5f0 and
> d9d8da805dcb503ef8ee49918a94d49085060f23 as culprits.
>=20
> I've stared at them but can't see what could be doing this.
>=20

Hi Simon, thanks a lot for this report.

This sounds as a SYNCOOKIE side effect

I could reproduce this with a typical DOS on ssh port.

Yes, it seems first messages are not sent at all, only after several tc=
p
timeouts :

Here my sshd write() its first frame (23 bytes) right after the 3WHS,
but we can see first frame leaves the machine 17 seconds later :

17:42:49.958432 IP 10.170.237.2.37550 > 192.168.20.110.22: S 3066771530=
:3066771530(0) win 14600 <mss 1460,sackOK,timestamp 19981015 0,nop,wsca=
le 6>
17:42:49.958438 IP 192.168.20.110.22 > 10.170.237.2.37550: S 881027529:=
881027529(0) ack 3066771531 win 14480 <mss 1460,sackOK,timestamp 155035=
3622 19981015,nop,wscale 4>
17:42:50.137163 IP 10.170.237.2.37550 > 192.168.20.110.22: . ack 1 win =
229 <nop,nop,timestamp 19981060 1550353622>

17:43:07.557096 IP 192.168.20.110.22 > 10.170.237.2.37550: P 1:24(23) a=
ck 1 win 913 <nop,nop,timestamp 1550371264 19981060>
17:43:07.757096 IP 10.170.237.2.37550 > 192.168.20.110.22: . ack 24 win=
 229 <nop,nop,timestamp 19985459 1550371264>
17:43:07.936756 IP 10.170.237.2.37550 > 192.168.20.110.22: P 1:40(39) a=
ck 24 win 229 <nop,nop,timestamp 19985459 1550371264>
17:43:07.936769 IP 192.168.20.110.22 > 10.170.237.2.37550: . ack 40 win=
 913 <nop,nop,timestamp 1550371643 19985459>
17:43:07.937384 IP 192.168.20.110.22 > 10.170.237.2.37550: P 24:664(640=
) ack 40 win 913 <nop,nop,timestamp 1550371644 19985459>
17:43:08.156252 IP 10.170.237.2.37550 > 192.168.20.110.22: P 40:1184(11=
44) ack 24 win 229 <nop,nop,timestamp 19985554 1550371643>

To check that its indeed the tcp retransmits that trigger and eventuall=
y send the frame :

$ ss -emoi dst 10.170.237.2
State       Recv-Q Send-Q                            Local Address:Port=
                                Peer Address:Port  =20
ESTAB       0      23                        ::ffff:192.168.20.110:ssh =
                         ::ffff:10.170.237.2:37604    timer:(on,700ms,0=
) ino:11067765 sk:f3564780
	 mem:(r0,w2240,f1856,t0) ts sack bic wscale:6,4 rto:1209 rtt:403/201.5=
 cwnd:10 ssthresh:5 send 287.4Kbps rcv_space:14600
$ ss -emoi dst 10.170.237.2
State       Recv-Q Send-Q                            Local Address:Port=
                                Peer Address:Port  =20
ESTAB       0      23                        ::ffff:192.168.20.110:ssh =
                         ::ffff:10.170.237.2:37604    timer:(on,1.529ms=
,1) ino:11067765 sk:f3564780
	 mem:(r0,w2240,f1856,t0) ts sack bic wscale:6,4 rto:2418 rtt:403/201.5=
 ssthresh:5 send 57.5Kbps rcv_space:14600
$ ss -emoi dst 10.170.237.2
State       Recv-Q Send-Q                            Local Address:Port=
                                Peer Address:Port  =20
ESTAB       0      23                        ::ffff:192.168.20.110:ssh =
                         ::ffff:10.170.237.2:37604    timer:(on,4.005ms=
,2) ino:11067765 sk:f3564780
	 mem:(r0,w2240,f1856,t0) ts sack bic wscale:6,4 rto:4836 rtt:403/201.5=
 ssthresh:5 send 57.5Kbps rcv_space:14600
$ ss -emoi dst 10.170.237.2
State       Recv-Q Send-Q                            Local Address:Port=
                                Peer Address:Port  =20
ESTAB       0      23                        ::ffff:192.168.20.110:ssh =
                         ::ffff:10.170.237.2:37604    timer:(on,1.773ms=
,2) ino:11067765 sk:f3564780
	 mem:(r0,w2240,f1856,t0) ts sack bic wscale:6,4 rto:4836 rtt:403/201.5=
 ssthresh:5 send 57.5Kbps rcv_space:14600
$ ss -emoi dst 10.170.237.2
State       Recv-Q Send-Q                            Local Address:Port=
                                Peer Address:Port  =20
ESTAB       0      23                        ::ffff:192.168.20.110:ssh =
                         ::ffff:10.170.237.2:37604    timer:(on,8.574ms=
,3) ino:11067765 sk:f3564780
	 mem:(r0,w2240,f1856,t0) ts sack bic wscale:6,4 rto:9672 rtt:403/201.5=
 ssthresh:5 send 57.5Kbps rcv_space:14600
$ ss -emoi dst 10.170.237.2
State       Recv-Q Send-Q                            Local Address:Port=
                                Peer Address:Port  =20
ESTAB       0      0                         ::ffff:192.168.20.110:ssh =
                         ::ffff:10.170.237.2:37604    timer:(keepalive,=
48min,0) ino:11067765 sk:f3564780
	 mem:(r0,w0,f0,t0) ts sack bic wscale:6,4 rto:806 rtt:263.875/105.5 at=
o:40 cwnd:6 ssthresh:5 send 263.4Kbps rcv_rtt:181 rcv_space:14600
