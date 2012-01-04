From: Dave Taht <dave.taht@gmail.com>
Subject: still battling with qfq
Date: Wed, 4 Jan 2012 01:07:49 +0100
Message-ID: <CAA93jw4TNO6V837kDhE2yEAAAXaX09bvkwyRTi=BCCYP88FY7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51164 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043Ab2ADAHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 19:07:50 -0500
Received: by iaeh11 with SMTP id h11so31617607iae.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 16:07:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even after yesterday's patch, I can get qfq to lock up on the
e1000e or ag71xx in under half an hour. I have not managed to
make it lock up on wireless as of yet. Same boxes runs the
new SFQ all day long.

Three changes from previous behavior - no kernel panics, and where
before doing a tc qdisc del dev eth0 root would sometimes clear it,
on the e1000e I have to plug/unplug, but on the ag71xx I can
do the tc del and have the interface come back to life.

both tx and rx lock up.

I thought maybe I was running out of bins so I tried
a huge txqueuelen on the first try... (514*24)

I'm digging up another wired card, will try again in the morning.

some logs from 5 test runs, using 50 iperfs and ping to
generate the load, on the e1000e:

1)

eth0      Link encap:Ethernet  HWaddr 00:27:13:64:89:67
          inet addr:172.30.50.2  Bcast:172.30.50.31  Mask:255.255.255.224
          inet6 addr: fe80::227:13ff:fe64:8967/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:29539678 errors:0 dropped:0 overruns:0 frame:0
          TX packets:39935262 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:12338
          RX bytes:2175792991 (2.1 GB)  TX bytes:60590871054 (60.5 GB)
          Interrupt:20 Memory:fc000000-fc020000

64 bytes from 172.30.47.27: seq=839 ttl=64 time=0.542 ms
64 bytes from 172.30.47.27: seq=840 ttl=64 time=3.215 ms


Broot@cruithne:/home/d/git/deBloat/src# tc -s qdisc show dev eth0 | head
qdisc qfq a: root refcnt 2
 Sent 10537868266 bytes 6963579 pkt (dropped 13, overlimits 0 requeues 102755)
 backlog 0b 0p requeues 102755
qdisc pfifo 880f: parent a:201 limit 16p
 Sent 13342 bytes 313 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc pfifo 8810: parent a:202 limit 32p

eth0      Link encap:Ethernet  HWaddr 00:27:13:64:89:67
          inet addr:172.30.50.2  Bcast:172.30.50.31  Mask:255.255.255.224
          inet6 addr: fe80::227:13ff:fe64:8967/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:31897135 errors:0 dropped:0 overruns:0 frame:0
          TX packets:42821027 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:50
          RX bytes:2349877207 (2.3 GB)  TX bytes:64970047739 (64.9 GB)
          Interrupt:20 Memory:fc000000-fc020000

qdisc qfq a: root refcnt 2
 Sent 4367625466 bytes 2885705 pkt (dropped 62, overlimits 0 requeues 44029)
 backlog 0b 0p requeues 44029
qdisc pfifo 8a12: parent a:201 limit 16p
 Sent 588 bytes 14 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

3)

eth0      Link encap:Ethernet  HWaddr 00:27:13:64:89:67
          inet addr:172.30.50.2  Bcast:172.30.50.31  Mask:255.255.255.224
          inet6 addr: fe80::227:13ff:fe64:8967/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:34931659 errors:0 dropped:0 overruns:0 frame:0
          TX packets:46501739 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:50
          RX bytes:2574124993 (2.5 GB)  TX bytes:70555594515 (70.5 GB)
          Interrupt:20 Memory:fc000000-fc020000


64 bytes from 172.30.47.27: seq=237 ttl=64 time=0.956 ms
64 bytes from 172.30.47.27: seq=238 ttl=64 time=2.057 ms

qdisc qfq a: root refcnt 2
 Sent 5570820080 bytes 3680656 pkt (dropped 0, overlimits 0 requeues 54531)
 backlog 0b 0p requeues 54531
qdisc pfifo 8c15: parent a:201 limit 16p
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

4)

eth0      Link encap:Ethernet  HWaddr 00:27:13:64:89:67
          inet addr:172.30.50.2  Bcast:172.30.50.31  Mask:255.255.255.224
          inet6 addr: fe80::227:13ff:fe64:8967/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:40170972 errors:0 dropped:0 overruns:0 frame:0
          TX packets:52937141 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:50
          RX bytes:2960823653 (2.9 GB)  TX bytes:80321445250 (80.3 GB)
          Interrupt:20 Memory:fc000000-fc020000

64 bytes from 172.30.47.27: seq=424 ttl=64 time=1.342 ms
64 bytes from 172.30.47.27: seq=425 ttl=64 time=1.210 ms


qdisc qfq a: root refcnt 2
 Sent 9737835352 bytes 6433786 pkt (dropped 113, overlimits 0 requeues 96038)
 backlog 0b 0p requeues 96038

5)

eth0      Link encap:Ethernet  HWaddr 00:27:13:64:89:67
          inet addr:172.30.50.2  Bcast:172.30.50.31  Mask:255.255.255.224
          inet6 addr: fe80::227:13ff:fe64:8967/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:56565023 errors:0 dropped:0 overruns:0 frame:0
          TX packets:86214132 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:50
          RX bytes:4109565653 (4.1 GB)  TX bytes:130822456981 (130.8 GB)
          Interrupt:20 Memory:fc000000-fc020000

64 bytes from 172.30.47.27: seq=1973 ttl=64 time=0.468 ms
64 bytes from 172.30.47.27: seq=1974 ttl=64 time=0.333 ms

qdisc qfq a: root refcnt 2
 Sent 60105667903 bytes 39710741 pkt (dropped 24915, overlimits 0
requeues 4976782)
 backlog 0b 0p requeues 4976782
qdisc pfifo 901b: parent a:201 limit 16p
 Sent 10304 bytes 243 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
