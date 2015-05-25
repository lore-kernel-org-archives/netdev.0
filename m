From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Drops in qdisc on ifb interface
Date: Mon, 25 May 2015 16:05:00 -0400
Message-ID: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:54727 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbbEYUFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 16:05:05 -0400
Received: from [10.3.0.5] ([69.74.118.2]) by mrelay.perfora.net (mreueus003)
 with ESMTPSA (Nemesis) id 0MV3pT-1Ye8Xq3syr-00YQ5X for
 <netdev@vger.kernel.org>; Mon, 25 May 2015 22:05:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  One one of our connections we are doing intensive traffic
shaping with tc.  We are using ifb interfaces for shaping ingress
traffic and we also use ifb interfaces for egress so that we can apply
the same set of rules to multiple interfaces (e.g., tun and eth
interfaces operating on the same physical interface).

These are running on very powerful gateways; I have watched them
handling 16 Gbps with CPU utilization at a handful of percent.  Yet, I
am seeing drops on the ifb interfaces when I do a tc -s qdisc show.

Why would this be? I would expect if there was some kind of problem that
it would manifest as drops on the physical interfaces and not the IFB
interface.  We have played with queue lengths in both directions.  We
are using HFSC with SFQ leaves so I would imagine this overrides the
very short qlen on the IFB interfaces (32).  These are drops and not
overlimits.

Ingress:

root@gwhq-2:~# tc -s qdisc show dev ifb0
qdisc hfsc 11: root refcnt 2 default 50
 Sent 198152831324 bytes 333838154 pkt (dropped 101509, overlimits 9850280 requeues 43871)
 backlog 0b 0p requeues 43871
qdisc sfq 1102: parent 11:10 limit 127p quantum 1514b divisor 4096
 Sent 208463490 bytes 1367761 pkt (dropped 234, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc sfq 1202: parent 11:20 limit 127p quantum 1514b divisor 4096
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc sfq 1302: parent 11:30 limit 127p quantum 1514b divisor 4096
 Sent 13498600307 bytes 203705301 pkt (dropped 23358, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc sfq 1402: parent 11:40 limit 127p quantum 1514b divisor 4096
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc sfq 1502: parent 11:50 limit 127p quantum 1514b divisor 4096
 Sent 184445767527 bytes 128765092 pkt (dropped 77990, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

root@gwhq-2:~# tc -s class show dev ifb0
class hfsc 11: root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 0 level 2

class hfsc 11:1 parent 11: ls m1 0bit d 0us m2 1000Mbit ul m1 0bit d 0us m2 1000Mbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 210766381 work 198152837828 bytes level 1

class hfsc 11:10 parent 11:1 leaf 1102: rt m1 0bit d 0us m2 1000Mbit
 Sent 208463490 bytes 1367761 pkt (dropped 234, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 0 work 208463490 bytes rtwork 208463490 bytes level 0

class hfsc 11:20 parent 11:1 leaf 1202: rt m1 186182Kbit d 2.2ms m2 100000Kbit ls m1 0bit d 0us m2 100000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 0 level 0

class hfsc 11:30 parent 11:1 leaf 1302: rt m1 0bit d 0us m2 100000Kbit ls m1 0bit d 0us m2 300000Kbit
 Sent 13498600307 bytes 203705301 pkt (dropped 23358, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 200073586 work 13498600307 bytes rtwork 10035553945 bytes level 0

class hfsc 11:40 parent 11:1 leaf 1402: rt m1 0bit d 0us m2 200000Kbit ls m1 0bit d 0us m2 500000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 0 level 0

class hfsc 11:50 parent 11:1 leaf 1502: rt m1 0bit d 0us m2 200000Kbit ls m1 0bit d 0us m2 100000Kbit
 Sent 184446394921 bytes 128765668 pkt (dropped 77917, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 11254219 work 184445774031 bytes rtwork 39040535823 bytes level 0


Egress:

root@gwhq-2:~# tc -s qdisc show dev ifb1
qdisc hfsc 1: root refcnt 2 default 40
 Sent 783335740812 bytes 551888729 pkt (dropped 9622, overlimits 8546933 requeues 7180)
 backlog 0b 0p requeues 7180
qdisc sfq 1101: parent 1:10 limit 127p quantum 1514b divisor 4096
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc sfq 1201: parent 1:20 limit 127p quantum 1514b divisor 4096
 Sent 345678 bytes 2800 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc sfq 1301: parent 1:30 limit 127p quantum 1514b divisor 4096
 Sent 573479513 bytes 8689797 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc sfq 1401: parent 1:40 limit 127p quantum 1514b divisor 4096
 Sent 782761915621 bytes 543196132 pkt (dropped 9692, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

root@gwhq-2:~# tc -s class show dev ifb1
class hfsc 1: root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 0 level 2

class hfsc 1:10 parent 1:1 leaf 1101: rt m1 186182Kbit d 2.2ms m2 100000Kbit ls m1 0bit d 0us m2 100000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 0 level 0

class hfsc 1:1 parent 1: ls m1 0bit d 0us m2 1000Mbit ul m1 0bit d 0us m2 1000Mbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 27259167 work 783335741126 bytes level 1

class hfsc 1:20 parent 1:1 leaf 1201: rt m1 0bit d 0us m2 100000Kbit ls m1 0bit d 0us m2 300000Kbit
 Sent 345678 bytes 2800 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 2791 work 345678 bytes rtwork 285108 bytes level 0

class hfsc 1:30 parent 1:1 leaf 1301: rt m1 0bit d 0us m2 200000Kbit ls m1 0bit d 0us m2 500000Kbit
 Sent 573479513 bytes 8689797 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 8689608 work 573479513 bytes rtwork 573479447 bytes level 0

class hfsc 1:40 parent 1:1 leaf 1401: rt m1 0bit d 0us m2 200000Kbit ls m1 0bit d 0us m2 100000Kbit
 Sent 782762094327 bytes 543196259 pkt (dropped 9622, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
 period 19132342 work 782761915935 bytes rtwork 200858352128 bytes level 0


Thanks - John
