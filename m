From: Jesse Young <jlyo@jlyo.org>
Subject: Missing TCP SYN on loopback, retransmits after 1s
Date: Tue, 22 Nov 2011 18:13:20 -0600
Message-ID: <20111122181320.38a70cf8@telperion.jlyo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/m52MJmY/YTcdnV_7MsrG4en"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:41219 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754215Ab1KWAPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Nov 2011 19:15:07 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RT0UU-000712-IR
	for netdev@vger.kernel.org; Wed, 23 Nov 2011 01:15:06 +0100
Received: from c-67-175-216-185.hsd1.il.comcast.net ([67.175.216.185])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 01:15:06 +0100
Received: from jlyo by c-67-175-216-185.hsd1.il.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 01:15:06 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/m52MJmY/YTcdnV_7MsrG4en
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi all,

I am experiencing packet loss over TCP/IPv[46], which causes 1 second
delays when connect()ing to a socket. This happens even on loopback, and
on multiple kernels. On the older kernels, the connect() time is nearly
3 seconds, I believe this is due to a recent TCP connect retrasmit
parameter changed in the kernel.

1. Linux dc-s1000-2114 2.6.32-35-server #78-Ubuntu SMP Tue Oct 11
    16:26:12 UTC 2011 x86_64 GNU/Linux
2. Linux dc-a1000-2131.cleversafelabs.com 2.6.39.4-2-clevos+ #1 SMP
    Tue Nov 8 09:06:49 CST 2011 x86_64 x86_64 x86_64 GNU/Linux
3. Linux telperion.jlyo.org 3.1.0-4-ARCH #1 SMP PREEMPT Mon Nov 7
    22:47:18 CET 2011 x86_64 Intel(R) Core(TM) i7-2630QM CPU @ 2.00GHz
    GenuineIntel GNU/Linux

I have created some test cases which reify this problem, the first set
of tests use select() multiplexing, and have some problems, however,
they exhibit odd behavior as well, especially in the difference between
tcp4 and tcp6.

Please note: these tests will quickly exaust the amount of available
ephemeral TCP ports on your system, which will cause any TCP connect()
calls in other processes to return with EADDRNOTAVAIL. However, ports
will become available after a short while.

The first test fails super quick, while the others haven't timed out
so far.  NOTE: The second test requires /proc/sys/net/ipv6/bindv6only
to be set to 1.

./packetloss :: ::1
./packetloss :: 127.0.0.1
./packetloss 0.0.0.0 127.0.0.1

The other tests run a client and server in different processes.
Run the "close" daemon using one of:
./closed ::
./closed 0.0.0.0

And flood connect() pings against 8009, the port closed listens on.
./tcping -f -p8009 ::1
./tcping -f -p8009 127.0.0.1

Wait for a pause, then ^C, and notice the max statistic is ~1000ms.

These tests have been rn between machines on a relativley noiseless
ethernet LAN with similar results.

What's also puzzling, is that I see no packet drop reporting in
$ ifconfig lo
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 16436  metric 1
inet 127.0.0.1  netmask 255.0.0.0
inet6 ::1  prefixlen 128  scopeid 0x10<host>
loop  txqueuelen 0  (Local Loopback)
RX packets 276411482  bytes 15822880567 (14.7 GiB)
RX errors 0  dropped 0  overruns 0  frame 0
TX packets 276411482 bytes 15822880567 (14.7 GiB)
TX errors 0 dropped 0 overruns 0 carrier 0 collisions

I'm thinking this may be a bug in the TCP/IP stack, however, I'm not
certain if I'm missing a socket option, or some other configuration
that may elimiate this behavior.

If there's anything else I can help you with, please don't hesitate
to Cc me.

Thanks,
Jesse

Attached: syndrop.pcap

Get the code here
https://github.com/jlyo/packetloss
git clone git://github.com/jlyo/packetloss.git

https://github.com/jlyo/tcping
git clone git://github.com/jlyo/tcping.git

https://github.com/jlyo/closed
git clone git://github.com/jlyo/closed.git

--MP_/m52MJmY/YTcdnV_7MsrG4en
Content-Type: application/vnd.tcpdump.pcap
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=syndrop.pcap

1MOyoQIABAAAAAAAAAAAAP//AAABAAAA5f7DTvGKAgBKAAAASgAAAAAAAAAAAAAAAAAAAAgARQAA
POeLQABABlUufwAAAX8AAAGxHh9Jhn/pFgAAAACgAoAY/jAAAAIEQAwEAggKAEkOnQAAAAABAwMH
5v7DTrKSAgBKAAAASgAAAAAAAAAAAAAAAAAAAAgARQAAPOeMQABABlUtfwAAAX8AAAGxHh9Jhn/p
FgAAAACgAoAY/jAAAAIEQAwEAggKAEkPygAAAAABAwMH5v7DTuSSAgBKAAAASgAAAAAAAAAAAAAA
AAAAAAgARQAAPAAAQABABjy6fwAAAX8AAAEfSbEeM+7gRIZ/6RegEoAA/jAAAAIEQAwEAggKAEkP
ygBJD8oBAwMH5v7DTv+SAgBCAAAAQgAAAAAAAAAAAAAAAAAAAAgARQAANOeNQABABlU0fwAAAX8A
AAGxHh9Jhn/pFzPu4EWAEAEB/igAAAEBCAoASQ/KAEkPyub+w054kwIAQgAAAEIAAAAAAAAAAAAA
AAAAAAAIAEUAADTnjkAAQAZVM38AAAF/AAABsR4fSYZ/6Rcz7uBFgBEBAf4oAAABAQgKAEkPygBJ
D8rm/sNOt5MCAEIAAABCAAAAAAAAAAAAAAAAAAAACABFAAA0749AAEAGTTJ/AAABfwAAAR9JsR4z
7uBFhn/pGIARAQD+KAAAAQEICgBJD8oASQ/K5v7DTvWTAgBCAAAAQgAAAAAAAAAAAAAAAAAAAAgA
RQAANOePQABABlUyfwAAAX8AAAGxHh9Jhn/pGDPu4EaAEAEB/igAAAEBCAoASQ/KAEkPyg==

--MP_/m52MJmY/YTcdnV_7MsrG4en--
