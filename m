From: Jan Engelhardt <jengelh@inai.de>
Subject: TSO on veth device slows transmission to a crawl
Date: Tue, 7 Apr 2015 00:45:43 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares41.inai.de ([46.4.122.207]:52866 "EHLO ares41.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752834AbbDFWw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2015 18:52:58 -0400
Received: from localhost (localhost [127.0.0.1])
	by ares41.inai.de (Postfix) with ESMTP id 4D21180C5449
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 00:45:43 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have here a Linux 3.19(.0) system where activated TSO on a veth slave 
device makes IPv4-TCP transfers going into that veth-connected container 
progress slowly.


Host side (hv03):
hv03# ip l
2: ge0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast 
state UP mode DEFAULT group default qlen 1000 [Intel 82579LM]
7: ve-build01: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
pfifo_fast state UP mode DEFAULT group default qlen 1000 [veth]
hv03# ethtool -k ve-build01
Features for ve-build01:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: off [fixed]
        tx-checksum-ip-generic: on
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: on
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: on
        tx-tcp6-segmentation: on
udp-fragmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: on
tx-ipip-segmentation: on
tx-sit-segmentation: on
tx-udp_tnl-segmentation: on
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: on
rx-vlan-stag-hw-parse: on
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]


Guest side (build01):
build01# ip l
2: host0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast 
state UP mode DEFAULT group default qlen 1000
build01# ethtool -k host0
Features for host0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: off [fixed]
        tx-checksum-ip-generic: on
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: on
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: on
        tx-tcp6-segmentation: on
udp-fragmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: on
tx-ipip-segmentation: on
tx-sit-segmentation: on
tx-udp_tnl-segmentation: on
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: on
rx-vlan-stag-hw-parse: on
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]


Using an independent machine, I query a xinetd-chargen sample service
to send a sufficient number of bytes through the pipe.

ares40# traceroute build01
traceroute to build01 (x), 30 hops max, 60 byte packets
 1  hv03 ()  0.713 ms  0.663 ms  0.636 ms
 2  build01 ()  0.905 ms  0.882 ms  0.858 ms

ares40$ socat tcp4-connect:build01:19 - | pv >/dev/null
 480KiB 0:00:05 [91.5KiB/s] [    <=>             ]
1.01MiB 0:00:11 [91.1KiB/s] [          <=>       ]
1.64MiB 0:00:18 [ 110KiB/s] [                <=> ]

(PV is the Pipe Viewer, showing throughput.)

It hovers between 80 and 110 kilobytes/sec, which is 600-fold lower
than what I would normally see. Once TSO is turned off on the
container-side interface:

build01# ethtool -K host0 tso off
(must be host0 // doing it on ve-build01 has no effect)

I observe restoration of expected throughput:

ares40$ socat tcp4-connect:build01:19 - | pv >/dev/null
 182MiB 0:02:05 [66.1MiB/s] [                       <=> ]


This problem does not manifest when using IPv6.
The problem also does not manifest if the TCP4 connection is kernel-local,
e.g. hv03->build01.
The problem also does not manifest if the TCP4 connection is outgoing, 
e.g. build01->ares40.
IOW, the tcp4 listening socket needs to be inside a veth-connected 
container.
