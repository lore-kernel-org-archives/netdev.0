From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: HTB going crazy over ~5Gbit/s (4.12.9, but problem present in older
 kernels as well)
Date: Wed, 13 Sep 2017 18:20:48 +0300
Message-ID: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:45766 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751123AbdIMPUv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 11:20:51 -0400
Received: from localhost (localhost [127.0.0.1])
        by nuclearcat.com (Postfix) with ESMTP id A1F5767C08A7
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 15:20:50 +0000 (UTC)
Received: from nuclearcat.com ([127.0.0.1])
        by localhost (nuclearcat.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id xW9qNOnPqPgF for <netdev@vger.kernel.org>;
        Wed, 13 Sep 2017 15:20:48 +0000 (UTC)
Received: from germany.nuclearcat.com (localhost [127.0.0.1])
        (Authenticated sender: nuclearcat@nuclearcat.com)
        by nuclearcat.com (Postfix) with ESMTPA id 99A8967C0742
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 15:20:48 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed after increasing bandwidth over some amount HTB started to 
throttle classes it should not throttle.
Also estimated rate in htb totally wrong, while byte counters is 
correct.

Is there any overflow or something?

X520 card (but XL710 same)
br1		8000.90e2ba86c38c	no		eth3.1777
							eth3.777
br2		8000.90e2ba86c38d	no		eth3.360
							eth3.361

Inbound traffic is coming over one vlan, leaving another vlan.
Shaper is just bunch of classes and u32 filters, with few fw filters.
qdisc is pie

I put totally high values to not reach them, tried to change 
quantum/burst/cburst but... stats below.

First, "root" class is 1:1 showing  rate 18086Mbit, which is physically 
impossible.

Class 1:111 showing 5355Mbit, while real traffic is ~1.5Gbit

shaper /etc # tc -s -d class show dev eth3.777 classid 1:111;sleep 5;tc 
-s -d class show dev eth3.777 classid 1:111
class htb 1:111 parent 1:1 leaf 111: prio 0 quantum 50000 rate 10Gbit 
ceil 100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 6487632263 bytes 5235525 pkt (dropped 0, overlimits 0 requeues 0)
  rate 5529Mbit 557534pps backlog 0b 0p requeues 0
  lended: 2423323 borrowed: 0 giants: 0
  tokens: 124 ctokens: -1

class htb 1:111 parent 1:1 leaf 111: prio 0 quantum 50000 rate 10Gbit 
ceil 100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 7438601731 bytes 6003811 pkt (dropped 0, overlimits 0 requeues 0)
  rate 5631Mbit 568214pps backlog 36624b 8p requeues 0
  lended: 2772486 borrowed: 0 giants: 0
  tokens: 124 ctokens: -1

(7438601731-6487632263)/5*8 = 1.521.551.148

And most important some classes suffering, while they should not (not 
reaching limits)
class htb 1:95 parent 1:1 leaf 95: prio 0 quantum 50000 rate 10Gbit ceil 
100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 13556762059 bytes 17474559 pkt (dropped 16017, overlimits 0 
requeues 0)
  rate 2524Mbit 414197pps backlog 31969245b 34513p requeues 0
  lended: 13995723 borrowed: 0 giants: 0
  tokens: 111 ctokens: -2





Full classes stats:

class htb 1:100 parent 1:1 leaf 100: prio 0 quantum 50000 rate 10Gbit 
ceil 100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 116 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
  rate 8bit 0pps backlog 0b 0p requeues 0
  lended: 2 borrowed: 0 giants: 0
  tokens: 124 ctokens: -1

class htb 1:120 parent 1:1 leaf 120: prio 0 quantum 50000 rate 10Gbit 
ceil 100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 531230043 bytes 782130 pkt (dropped 0, overlimits 0 requeues 0)
  rate 132274Kbit 25240pps backlog 0b 0p requeues 0
  lended: 540693 borrowed: 0 giants: 0
  tokens: 109 ctokens: -2

class htb 1:50 parent 1:1 leaf 50: prio 0 quantum 50000 rate 10Gbit ceil 
100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 773472109 bytes 587335 pkt (dropped 0, overlimits 0 requeues 0)
  rate 215929Kbit 20503pps backlog 0b 0p requeues 0
  lended: 216614 borrowed: 0 giants: 0
  tokens: 91 ctokens: -4

class htb 1:70 parent 1:1 leaf 70: prio 0 quantum 50000 rate 10Gbit ceil 
100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 1574768 bytes 6194 pkt (dropped 0, overlimits 0 requeues 0)
  rate 406272bit 214pps backlog 0b 0p requeues 0
  lended: 5758 borrowed: 0 giants: 0
  tokens: 101 ctokens: -3

class htb 1:90 parent 1:1 leaf 90: prio 0 quantum 50000 rate 1Kbit ceil 
100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 3206 bytes 53 pkt (dropped 0, overlimits 0 requeues 0)
  rate 848bit 1pps backlog 0b 0p requeues 0
  lended: 53 borrowed: 0 giants: 0

class htb 1:110 parent 1:1 leaf 110: prio 0 quantum 50000 rate 10Gbit 
ceil 100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 17205952113 bytes 12926008 pkt (dropped 239, overlimits 0 requeues 
0)
  rate 4433Mbit 416825pps backlog 5847785b 2394p requeues 0
  lended: 7021696 borrowed: 0 giants: 0
  tokens: 91 ctokens: -4

class htb 1:45 root leaf 45: prio 0 quantum 50000 rate 80Mbit ceil 
80Mbit linklayer ethernet burst 10000b/1 mpu 0b cburst 10000b/1 mpu 0b 
level 0
  Sent 2586 bytes 45 pkt (dropped 0, overlimits 0 requeues 0)
  rate 456bit 1pps backlog 0b 0p requeues 0
  lended: 45 borrowed: 0 giants: 0
  tokens: 15540 ctokens: 15540

class htb 1:1 root rate 100Gbit ceil 100Gbit linklayer ethernet burst 
0b/1 mpu 0b cburst 0b/1 mpu 0b level 7
  Sent 72277215121 bytes 72693012 pkt (dropped 0, overlimits 0 requeues 
0)
  rate 18086Mbit 2304729pps backlog 0b 0p requeues 0
  lended: 0 borrowed: 0 giants: 0
  tokens: -4 ctokens: -4

class htb 1:111 parent 1:1 leaf 111: prio 0 quantum 50000 rate 10Gbit 
ceil 100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 21977384237 bytes 17697345 pkt (dropped 391, overlimits 0 requeues 
0)
  rate 5355Mbit 543216pps backlog 41746345b 14743p requeues 0
  lended: 8837667 borrowed: 0 giants: 0
  tokens: 124 ctokens: -1

class htb 1:200 parent 1:1 leaf 200: prio 0 quantum 50000 rate 10Gbit 
ceil 100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 9209112058 bytes 10941655 pkt (dropped 5396413, overlimits 0 
requeues 0)
  rate 2142Mbit 326938pps backlog 20798724b 25717p requeues 0
  lended: 9926866 borrowed: 0 giants: 0
  tokens: 108 ctokens: -2

class htb 1:20 parent 1:1 leaf 20: prio 0 quantum 50000 rate 10Gbit ceil 
100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 1504918577 bytes 1170037 pkt (dropped 0, overlimits 0 requeues 0)
  rate 413892Kbit 40322pps backlog 0b 0p requeues 0
  lended: 497069 borrowed: 0 giants: 0
  tokens: 92 ctokens: -4

class htb 1:40 parent 1:1 leaf 40: prio 0 quantum 50000 rate 1Gbit ceil 
1Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 10000b/1 mpu 0b 
level 0
  Sent 8638241052 bytes 9526035 pkt (dropped 0, overlimits 0 requeues 0)
  rate 2442Mbit 333804pps backlog 0b 0p requeues 0
  lended: 6947694 borrowed: 0 giants: 0
  tokens: 1064 ctokens: 1064

class htb 1:60 parent 1:1 leaf 60: prio 0 quantum 50000 rate 10Gbit ceil 
100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 3124889750 bytes 6972789 pkt (dropped 5833, overlimits 0 requeues 
0)
  rate 824981Kbit 233296pps backlog 616b 3p requeues 0
  lended: 6701559 borrowed: 0 giants: 0
  tokens: 122 ctokens: -1

class htb 1:25 parent 1:1 leaf 25: prio 0 quantum 50000 rate 10Gbit ceil 
100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 3275 bytes 57 pkt (dropped 0, overlimits 0 requeues 0)
  rate 504bit 1pps backlog 0b 0p requeues 0
  lended: 57 borrowed: 0 giants: 0
  tokens: 123 ctokens: -1

class htb 1:80 parent 1:1 leaf 80: prio 0 quantum 50000 rate 10Gbit ceil 
100Gbit linklayer ethernet burst 10000b/1 mpu 0b cburst 0b/1 mpu 0b 
level 0
  Sent 2598 bytes 45 pkt (dropped 0, overlimits 0 requeues 0)
  rate 672bit 1pps backlog 0b 0p requeues 0
  lended: 45 borrowed: 0 giants: 0
  tokens: 124 ctokens: -1

tc -s -d qdisc show dev eth3.777
qdisc htb 1: root refcnt 2 r2q 10 default 200 direct_packets_stat 6858 
ver 3.17 direct_qlen 1000
  Sent 185271955178 bytes 186767377 pkt (dropped 14248387, overlimits 0 
requeues 0)
  backlog 62369772b 68728p requeues 0
qdisc pie 120: parent 1:120 limit 40000p target 200.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 1532094051 bytes 2108158 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 0us avg_dq_rate 0
pkts_in 1424069 overlimit 0 dropped 0 maxq 96 ecn_mark 0

qdisc pie 95: parent 1:95 limit 40000p target 250.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 24359099839 bytes 31531160 pkt (dropped 36527, overlimits 0 
requeues 0)
  backlog 27116831b 28680p requeues 0
prob 0.000000 delay 82019us avg_dq_rate 96252441
pkts_in 25249681 overlimit 2107 dropped 36527 maxq 39999 ecn_mark 0

qdisc pie 80: parent 1:80 limit 40000p target 250.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 19695 bytes 317 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 0us avg_dq_rate 0
pkts_in 317 overlimit 0 dropped 0 maxq 1 ecn_mark 0

qdisc pie 111: parent 1:111 limit 40000p target 200.0ms tupdate 300.0ms 
alpha 2 beta 20
  Sent 57513872600 bytes 46387754 pkt (dropped 0, overlimits 0 requeues 
0)
  backlog 126218b 49p requeues 0
prob 0.000000 delay 227us avg_dq_rate 184143066

qdisc pie 100: parent 1:100 limit 40000p target 200.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 494 bytes 9 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 0us avg_dq_rate 0
pkts_in 9 overlimit 0 dropped 0 maxq 0 ecn_mark 0

qdisc pie 60: parent 1:60 limit 40000p target 250.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 8749993535 bytes 18718111 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 7875b 14p requeues 0
prob 0.000000 delay 98us avg_dq_rate 0
pkts_in 17978754 overlimit 0 dropped 0 maxq 281 ecn_mark 0

qdisc pie 25: parent 1:25 limit 40000p target 250.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 9412 bytes 135 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 0us avg_dq_rate 0
pkts_in 135 overlimit 0 dropped 0 maxq 0 ecn_mark 0

qdisc pie 200: parent 1:200 limit 40000p target 50.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 22224392951 bytes 26861660 pkt (dropped 14211817, overlimits 0 
requeues 0)
  backlog 35124441b 39999p requeues 0
prob 0.000071 delay 23747us avg_dq_rate 66040039
pkts_in 25266532 overlimit 14160730 dropped 14211817 maxq 39999 ecn_mark 
0

qdisc pie 90: parent 1:90 limit 40000p target 250.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 7396 bytes 134 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 0us avg_dq_rate 0
pkts_in 134 overlimit 0 dropped 0 maxq 0 ecn_mark 0

qdisc pie 40: parent 1:40 limit 40000p target 200.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 21316494470 bytes 23786396 pkt (dropped 0, overlimits 0 requeues 
0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 0us avg_dq_rate 2085892079
pkts_in 17465291 overlimit 0 dropped 0 maxq 184 ecn_mark 0

qdisc pie 110: parent 1:110 limit 40000p target 200.0ms tupdate 300.0ms 
alpha 2 beta 20
  Sent 44081304635 bytes 33108042 pkt (dropped 0, overlimits 0 requeues 
0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 47us avg_dq_rate 201721191
pkts_in 17602600 overlimit 0 dropped 0 maxq 157 ecn_mark 0

qdisc pie 70: parent 1:70 limit 40000p target 250.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 4992265 bytes 16959 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 0us avg_dq_rate 0
pkts_in 15448 overlimit 0 dropped 0 maxq 3 ecn_mark 0

qdisc pie 20: parent 1:20 limit 40000p target 250.0ms tupdate 30.0ms 
alpha 2 beta 20
  Sent 3475884019 bytes 2717342 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 0us avg_dq_rate 0
pkts_in 1186311 overlimit 0 dropped 0 maxq 41 ecn_mark 0

qdisc pie 50: parent 1:50 limit 40000p target 250.0ms tupdate 30.0ms 
alpha 2 beta 20 ecn
  Sent 1994354891 bytes 1511636 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
prob 0.000000 delay 0us avg_dq_rate 0
pkts_in 561648 overlimit 0 dropped 0 maxq 27 ecn_mark 0



More info about setup:
shaper /etc # ethtool -k eth3
Features for eth3:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: on [fixed]
	tx-checksum-sctp: on
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp-mangleid-segmentation: off
	tx-tcp6-segmentation: off
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: on [fixed]
tx-gre-segmentation: on
tx-gre-csum-segmentation: on
tx-ipxip4-segmentation: on
tx-ipxip6-segmentation: on
tx-udp_tnl-segmentation: on
tx-udp_tnl-csum-segmentation: on
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off
hw-tc-offload: off
esp-hw-offload: off [fixed]
esp-tx-csum-hw-offload: off [fixed]
shaper /etc # ethtool -k eth3.777
Features for eth3.777:
rx-checksumming: off [fixed]
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: on
	tx-checksum-sctp: on
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [requested on]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off
	tx-tcp-ecn-segmentation: off
	tx-tcp-mangleid-segmentation: off
	tx-tcp6-segmentation: off
udp-fragmentation-offload: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: on [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: on
tx-gre-segmentation: off [fixed]
tx-gre-csum-segmentation: off [fixed]
tx-ipxip4-segmentation: off [fixed]
tx-ipxip6-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-udp_tnl-csum-segmentation: off [fixed]
tx-gso-partial: off [fixed]
tx-sctp-segmentation: on
tx-esp-segmentation: off [fixed]
fcoe-mtu: off [requested on]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
hw-tc-offload: off [fixed]
esp-hw-offload: off [fixed]
esp-tx-csum-hw-offload: off [fixed]


shaper /etc # ethtool -i eth3
driver: ixgbe
version: 5.0.0-k
firmware-version: 0x2b2c0001
expansion-rom-version:
bus-info: 0000:06:00.1
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

mpstat -P ALL 10
Linux 4.12.9-build-0132 (shaper)	09/13/17	_x86_64_	(32 CPU)

18:15:55     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal 
  %guest   %idle
18:16:05     all    0.00    0.00    0.00    0.00    0.00    0.63    0.00 
    0.00   99.37
18:16:05       0    0.00    0.00    0.13    0.00    0.00    0.13    0.00 
    0.00   99.73
18:16:05       1    0.00    0.00    0.00    0.00    0.00    1.34    0.00 
    0.00   98.66
18:16:05       2    0.00    0.00    0.00    0.00    0.00    1.32    0.00 
    0.00   98.68
18:16:05       3    0.00    0.00    0.00    0.00    0.00    1.81    0.00 
    0.00   98.19
18:16:05       4    0.00    0.00    0.00    0.00    0.00    1.78    0.00 
    0.00   98.22
18:16:05       5    0.00    0.00    0.00    0.00    0.00    1.77    0.00 
    0.00   98.23
18:16:05       6    0.00    0.00    0.00    0.00    0.00    1.77    0.00 
    0.00   98.23
18:16:05       7    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
    0.00  100.00
18:16:05       8    0.00    0.00    0.00    0.00    0.00    0.15    0.00 
    0.00   99.85
18:16:05       9    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
    0.00  100.00
18:16:05      10    0.00    0.00    0.00    0.00    0.00    0.15    0.00 
    0.00   99.85
18:16:05      11    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
    0.00  100.00
18:16:05      12    0.00    0.00    0.00    0.00    0.00    0.48    0.00 
    0.00   99.52
18:16:05      13    0.00    0.00    0.00    0.00    0.00    0.59    0.00 
    0.00   99.41
18:16:05      14    0.00    0.00    0.00    0.00    0.00    1.30    0.00 
    0.00   98.70
18:16:05      15    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
    0.00  100.00
18:16:05      16    0.00    0.00    0.00    0.00    0.00    0.12    0.00 
    0.00   99.88
18:16:05      17    0.00    0.00    0.00    0.00    0.00    0.82    0.00 
    0.00   99.18
18:16:05      18    0.00    0.00    0.00    0.00    0.00    0.71    0.00 
    0.00   99.29
18:16:05      19    0.00    0.00    0.00    0.00    0.00    0.71    0.00 
    0.00   99.29
18:16:05      20    0.00    0.00    0.00    0.00    0.00    0.72    0.00 
    0.00   99.28
18:16:05      21    0.00    0.00    0.00    0.00    0.00    0.59    0.00 
    0.00   99.41
18:16:05      22    0.00    0.00    0.00    0.00    0.00    1.30    0.00 
    0.00   98.70
18:16:05      23    0.00    0.00    0.00    0.00    0.00    1.18    0.00 
    0.00   98.82
18:16:05      24    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
    0.00  100.00
18:16:05      25    0.00    0.00    0.00    0.00    0.00    0.84    0.00 
    0.00   99.16
18:16:05      26    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
    0.00  100.00
18:16:05      27    0.00    0.00    0.00    0.00    0.00    0.85    0.00 
    0.00   99.15
18:16:05      28    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
    0.00  100.00
18:16:05      29    0.00    0.00    0.12    0.00    0.00    0.12    0.00 
    0.00   99.76
18:16:05      30    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
    0.00  100.00
18:16:05      31    0.00    0.00    0.00    0.00    0.00    0.00    0.00 
    0.00  100.00
