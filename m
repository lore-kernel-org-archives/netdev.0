From: Wolfgang Rosner <wrosner@tirnet.de>
Subject: One way TCP bottleneck over 6 x Gbit tecl aggregated link
Date: Sat, 21 Mar 2015 01:10:47 +0100
Message-ID: <201503210110.48980.wrosner@tirnet.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tirnet.de ([217.7.138.221]:40177 "EHLO mail.tirnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752500AbbCUAk1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 20:40:27 -0400
Received: from wjrws2 (p54BED612.dip0.t-ipconnect.de [84.190.214.18])
	by mail.tirnet.de (mailserver tirnet.de) with ESMTP id 790BA2C343
	for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 01:12:23 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, 

Im trying to configure a beowulf style cluster based on venerable HP blade 
server hardware.
I configured 6 parallel GBit vlans between 16 blade nodes and a gateway server 
with teql link aggregation.

After lots of tuning, nearly everything runs fine (i.e. > 5,5 GBit/s iperf 
transfer rate, which is 95 % of theoretical limit), but one bottleneck 
remains left:

>From gateway to blade nodes, I get only half of full rate if I use only a 
single iperf process / single TCP link. 
With 2 or more iperf in parallel, transfer rate is OK.

I don't see this bottleneck in the other direction, nor in the links between 
the blade nodes: 
there I have always > 5,5 GBit, even for a single process.

Is there just a some simple tuning paramter I overlooked, or do I have to dig 
for a deeper cause?


Wolfgang Rosner



===== test results ================================

A single process only yields little more than half of the 6GBit capacity:


root@cruncher:~# iperf -c 192.168.130.225
------------------------------------------------------------
Client connecting to 192.168.130.225, TCP port 5001
TCP window size:  488 KByte (default)
------------------------------------------------------------
[  3] local 192.168.130.250 port 38589 connected with 192.168.130.225 port 
5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  3.89 GBytes  3.34 Gbits/sec


If I use two (or more) connections in parallel to share the physical link, 
they add up to ~ 95 % of physical link limit:

root@cruncher:~# iperf -c 192.168.130.225 -P2
------------------------------------------------------------
Client connecting to 192.168.130.225, TCP port 5001
TCP window size:  488 KByte (default)
------------------------------------------------------------
[  4] local 192.168.130.250 port 38591 connected with 192.168.130.225 port 
5001
[  3] local 192.168.130.250 port 38590 connected with 192.168.130.225 port 
5001
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  3.31 GBytes  2.84 Gbits/sec
[  3]  0.0-10.0 sec  3.30 GBytes  2.84 Gbits/sec
[SUM]  0.0-10.0 sec  6.61 GBytes  5.68 Gbits/sec


The values are quite reproducable, +- 0.2 GBit I'd estimate.

When I run 6 iperf in parallel, each over one of the eth0 links directly 
(bypassing teql), I get 6 x 990 MBit.

===== eof test results ================================

Futile trials:

MTU is 9000 on all links, txqlen 1000
(was 100 on teql, no effect)

I tried to tweak the well known mem limits to really(?) large values - no 
effect

  echo 16777216 > /proc/sys/net/core/rmem_default
  echo 16777216 > /proc/sys/net/core/wmem_default
  echo 16777216 > /proc/sys/net/core/wmem_max
  echo 16777216 > /proc/sys/net/core/rmem_max

  echo 33554432 > /proc/sys/net/core/wmem_max
  echo 33554432 > /proc/sys/net/core/rmem_max

 echo 4096 500000 12000000 > /proc/sys/net/ipv4/tcp_wmem
 echo 4096 500000 12000000 > /proc/sys/net/ipv4/tcp_rmem


Increase TCP window size on both iperf sides to 1Mb - no effect


 ...  ethtool -G  eth* tx 1024 ... no effect
(was 254 before, is 512 on the blades)


========== some considerations ==================

I assume the cause is hidden somewhere in the gatway sending side.

I think I can exclude general system bottleneck:
In top, it's hard to trace any CPU load at all.

iperf over local loop: 33.3 Gbits/sec on gateway
iperf over local loop 7.95 Gbits/sec on blades

So I don't see a reason that on the gateway, core system performance were a 
limit. On the blades, where we are close to total system throughput, I don't 
see the bottleneck for blade-blade connections.


I had an issue with physical limit on one of the Quad-Port-NICs on the gateway 
due to PCIe misconfiguration.  There was only x1 bandwith available, instead 
of x4 required. 
But I think, this is solved. 
If it were not, I would not have full speed in the other direction nor with 2 
or more iperf in parallel.


I suppose there must be some bottleneck parameter either per Process, per CPU, 
per TCP link or similar, which I haven't identified.

What is different in the gateway, compared to the blades?
- Interrupt configuration?
- Chip and driver of NIC
- Mainboard structure
- Kernel version/configuration
- switch connectivity


I think I can rule out the switch, because then the bottleneck would not 
depend on the process allocation to the links, I think.

======= System details =============================

Client nodes:
16 x HP Blade server 460 G1
each dual quad core Xeon 2,66 MHz, 32 GByte RAM
HP NC373i - BCM5708S 2 Port GBit Nic (onboard)
	eth{0,1}	-  driver bnx2
HP NC325m - BCM5715S 4 Port GBit Nic (mezzanine PCIe Card)
	eth{2-5}	-  driver tg3
debian wheezy 7.8
debian backport kernel
Linux version 3.16.0-0.bpo.4-amd64 
nfsroot

Gateway:
Asus Sabertooth 990FX R2.0
AMD FX-8320 8-core  1400 ... 3500 MHz, 16 GByte RAM

RTL8111/8168/8411 PCI Express Gigabit 
	eth0 - driver r8169
RTL-8100/8101L/8139 PCI Fast Ethernet Adapter
	eth1 - driver 8139too
HP NC364T / Intel 82571EB  4 Port GBit Nic PCIe
Intel PRO/1000 PT / Intel 82571EB  4 Port GBit Nic PCIe
	eth{2-9},  driver e1000e
debian wheezy 7.7
Vanilla Kernel 3.19
oldconfig from debian 3.16 backport
nfs4 server for the blades (dnsmasq, pxelinux)
aufs, btrfs, ext4-root

==============Network configuration: ============

gateway
eth0 is uplink to outside world
eth1 is HP blade center config network
eth2...7 is cluster interconnect network

subnet 192.168.130.0/27 is required for boot (PXE, nfsroot)
and shares link with 192.168.130.32/27

192.168.130.32/27 to 192.168.130.192/27  are the parallel physical interlinks 
networks

192.168.130.224/27 is the aggregated teql layer over those 6 links

root@cruncher:/cluster/etc/scripts/available# ip route
default via 192.168.0.18 dev eth0
192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.53
192.168.129.0/24 dev eth1  proto kernel  scope link  src 192.168.129.250

192.168.130.0/27 dev eth6  proto kernel  scope link  src 192.168.130.30

192.168.130.32/27 dev eth6  proto kernel  scope link  src 192.168.130.62
192.168.130.64/27 dev eth7  proto kernel  scope link  src 192.168.130.94
192.168.130.96/27 dev eth4  proto kernel  scope link  src 192.168.130.126
192.168.130.128/27 dev eth5  proto kernel  scope link  src 192.168.130.158
192.168.130.160/27 dev eth2  proto kernel  scope link  src 192.168.130.190
192.168.130.192/27 dev eth3  proto kernel  scope link  src 192.168.130.222

192.168.130.224/27 dev teql0  proto kernel  scope link  src 192.168.130.250

ip link 
.....
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc teql0 state UP mode 
DEFAULT qlen 1000
.....(same for eth3...7)...
12: teql0: <BROADCAST,NOARP,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast state 
UNKNOWN mode DEFAULT qlen 1000

matching config on the blades for eth0..eth5

Layer 2:
6 x "HP blade center 1/10 Virtual connect (VC) Ethernet modules"
each VC Module is internally linked to one GBit Port of  each of the blades 
and uplinked by one TP  cable to one of eth2...7 on the gateway.

The 6 .../27 subnets match each one of those modules and are configured as 
seperate vlan in the HP VC connection manager.
(This was the only way I got the VC to utilize all uplinks in parallel, not as 
failover.)


Why teql?

Initially, I tried (layer 2) linux bonding module instead of teql for link 
aggregation. 
This did not load balance well in LACP mode.
Id did fine in round-robin mode on internal connections between blades,  but I 
could not get the VC-switch layer to round robin on the uplink (only LCAP or 
failover).

I expected to have more control over the misbehaving switch by using layer 3 
bonding, where still each channel has its own IP and MAC accessible.
The performance on the blade-blade connections is proof that it works.
