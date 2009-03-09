From: Marian =?utf-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>
Subject: TCP rx window autotuning harmful at LAN context
Date: Mon, 9 Mar 2009 12:25:21 +0100
Message-ID: <20090309112521.GB37984@bts.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from saus.bts.sk ([194.160.23.4]:50673 "EHLO saus.bts.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746AbZCILna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 07:43:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

  based on multiple user complaints about poor LAN performance with=20
TCP window autotuning on receiver side we conducted several tests at
our university to verify whether these complaints are valid. Unfortunat=
ely,
our results confirmed, that the present implementation indeed behaves=20
erratically in LAN context and causes serious harm to LAN operation.

  The behaviour could be descibed as "spiraling death" syndrome. While
TCP with constant and decently sized rx window natively reduces transmi=
ssion
rate when RTT increases, autotuning performs exactly the opposite - as =
a
response to increased RTT it increases the rx window size (which in tur=
n
again increases RTT...) As this happens again and again, the result is
complete waste of all available buffers at sending host or at the bottl=
eneck
point, resulting in upto 267 msec (!) latency in LAN context (with 100 =
Mbps
ethernet connection, default txqueuelen=3D1000, MTU=3D1500 and sky2 dri=
ver). =20
Needles to say that this means the LAN is almost unusable.

   With autotuning disabled, the same situation results in just 5 msec
latency and still full 100 Mpbs link utilization, since with 64 kB rx w=
indow
the TCP transmission is solely controlled by RTT without ever going int=
o
congestion avoidance mode since there are no packet drops.

   As rx window autotuning is enabled in all recent kernels and with 1 =
GB
of RAM the maximum tcp_rmem becomes 4 MB, this problem is spreading rap=
idly
and we believe it needs urgent attention. As demontrated above, such hu=
ge
rx window (which is at least 100*BDP of the example above) does not del=
iver
any performance gain but instead it seriously harms other hosts and/or
applications. It should also be noted, that host with autotuning enable=
d
steals an unfair share of the total available bandwidth, which might lo=
ok
like a "better" performing TCP stack at first sight - however such beha=
viour
is not appropriate (RFC2914, section 3.2).

   The possible solution to the above problem could be e.g. to limit RT=
T
measuring only to the initial phase of the TCP connection and computing
the BDP from this value for the whole lifetime of the connection. With
such modification, increases in RTT due to buffering at the bottleneck=20
point will again reduce transmission rate and the "spiraling death"=20
syndrome will no longer exist.


    Thanks kind regards,

-----------------------------------------------------------------------=
---
----                                                                  -=
---
----   Marian =C4=8Eurkovi=C4=8D                       network  manager=
         ----
----                                                                  -=
---
----   Slovak Technical University           Tel: +421 2 571 041 81   -=
---
----   Computer Centre, N=C3=A1m. Slobody 17      Fax: +421 2 524 94 35=
1   ----
----   812 43 Bratislava, Slovak Republic    E-mail/sip: md@bts.sk    -=
---
----                                                                  -=
---
-----------------------------------------------------------------------=
---
