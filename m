From: Wolfgang Rosner <wrosner@tirnet.de>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link
Date: Sun, 22 Mar 2015 21:47:58 +0100
Message-ID: <201503222148.00332.wrosner@tirnet.de>
References: <201503210110.48980.wrosner@tirnet.de> <201503221614.47994.wrosner@tirnet.de> <1427043294.25985.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_AqyDV4MtCmuWW14"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tirnet.de ([217.7.138.221]:45896 "EHLO mail.tirnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbbCVUsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 16:48:04 -0400
In-Reply-To: <1427043294.25985.52.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_AqyDV4MtCmuWW14
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello, Eric,

Am Sonntag, 22. M=C3=A4rz 2015 17:54:54 schrieb Eric Dumazet:
>
> I see nothing wrong but a single retransmit.
> You might be bitten by tcp_metric cache.
> check /proc/sys/net/ipv4/tcp_no_metrics_save

OK, lets go testing.

reference figures before any changes:
gateway -> blade 	3.21 Gbits/sec
blade -> blade		5.49 Gbits/sec


both on gateway and on blade:

root@cruncher:/home/tmp/netdev# cat /proc/sys/net/ipv4/tcp_no_metrics_save
0
root@blade-002:~# cat /proc/sys/net/ipv4/tcp_no_metrics_save
0

> (set it to 0, and flush tcp metric cache :
> echo 0 >/proc/sys/net/ipv4/tcp_no_metrics_save

no need to do so, , right?

> ip tcp_metrics flush

root@cruncher:/home/tmp/netdev# ip tcp_metrics flush
	Object "tcp_metrics" is unknown, try "ip help".


Looks like debian-stable's iproute tools are quite old, aren't they?
So I suppose the iproute2 package you pointed me to will do the job.
Is it OK this way, or shold I install and configure it on my systems?
Or will the iproute2 from debian backport do?

btw: the teql aggregation is constructed by ip anc tc commands which are pa=
rt=20
of iproute2 package, right. Could the old toolbox, maybe in connection with=
 a=20
recent 3.19 vanilla kernel, cause the problem?


/home/build/iproute2/shemminger/iproute2/ip/ip tcp_metrics flush
(both on blades and on gateway)



root@blade-002:~# iperf -s
=2D-----------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
=2D-----------------------------------------------------------
[  4] local 192.168.130.226 port 5001 connected with 192.168.130.250 port=20
49522
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  3.78 GBytes  3.25 Gbits/sec


root@cruncher:/home/tmp/netdev# iperf -c 192.168.130.226
=2D-----------------------------------------------------------
Client connecting to 192.168.130.226, TCP port 5001
TCP window size:  488 KByte (default)
=2D-----------------------------------------------------------
[  3] local 192.168.130.250 port 49522 connected with 192.168.130.226 port=
=20
5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  3.78 GBytes  3.25 Gbits/sec


repeated tests: 3.25, 3.25, 3.12
was 3.12 before.
Sad to say: no effect

>
>
> Also, not clear why you use jumbo frames with 1Gbit NIC (do not do that,
> really), and it seems TSO is disabled on your NIC(s) ????

Because it increased thrughput by a factor of tree.

Jumbo frames was THE ONE AND ONLY really helpful tuning parameter.

What is wrong with jumbo frames in your view?

That's what many TCP tuning tips out there in the internet recommend.
I could follow their argument, that the lesser number of chunks to tranfer=
=20
reduces system load.

And my half-educated guess was, even if GBit NICs do a lot of work in=20
hardware / firmware, there is still the teql layer which I suppose is 100 %=
=20
handled in CPU, right?



=46rom my early setup test notes:

default MTU (1500)
	1622.65 MBit / s

jumbo frames (MTU =3D 9000)
(on both eth links and on teql)
	5143.78 MBit / s

This was on blade-blade links.
If I had this figure on gateway->blade link too, I would be glad and not=20
bother you.


> and it seems TSO is disabled on your NIC(s) ????
> for dev in eth0 eth1 eth2 eth3 ....
> do
>  ethtool -k $dev
> done

TSO also known as tcp-segmentation-offload, right?
let me grep a little to keep the mail text readable.
I'll put the unfiltered ethtool -k outputs as attachments for further=20
scrutiny.


On the gateway:

root@cruncher:~# for i in `seq 0 9` ; do  ethtool -k  eth$i | grep 'Feature=
s\|
segmentation-offload'  ; done
=46eatures for eth0:
tcp-segmentation-offload: off
generic-segmentation-offload: off [requested on]
=46eatures for eth1:
tcp-segmentation-offload: off
generic-segmentation-offload: on
=46eatures for eth2:
tcp-segmentation-offload: on
generic-segmentation-offload: on
=46eatures for eth3:
tcp-segmentation-offload: on
generic-segmentation-offload: on
=46eatures for eth4:
tcp-segmentation-offload: on
generic-segmentation-offload: on
=46eatures for eth5:
tcp-segmentation-offload: on
generic-segmentation-offload: on
=46eatures for eth6:
tcp-segmentation-offload: on
generic-segmentation-offload: on
=46eatures for eth7:
tcp-segmentation-offload: on
generic-segmentation-offload: on
=46eatures for eth8:
tcp-segmentation-offload: on
generic-segmentation-offload: on
=46eatures for eth9:
tcp-segmentation-offload: on
generic-segmentation-offload: on

Don't care for the first two:
eth0 is the external uplink and mostly used for ssh
eth1 is a 100Mbit link for the blade center admin subnet

This is what we need:
eth2 .... eth7 contribute the teql links towards the blades.


On the blades

root@blade-002:~# for i in `seq 0 5` ; do  ethtool -k  eth$i |=20
grep 'Features\|segmentation-offload'  ; done
=46eatures for eth0:
tcp-segmentation-offload: on
generic-segmentation-offload: on
=46eatures for eth1:
tcp-segmentation-offload: on
generic-segmentation-offload: on
=46eatures for eth2:
tcp-segmentation-offload: off
generic-segmentation-offload: on
=46eatures for eth3:
tcp-segmentation-offload: off
generic-segmentation-offload: on
=46eatures for eth4:
tcp-segmentation-offload: off
generic-segmentation-offload: on
=46eatures for eth5:
tcp-segmentation-offload: off
generic-segmentation-offload: on


This may be due to different card types:

root@blade-002:~# lspci | grep -i ether
03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708S=20
Gigabit Ethernet (rev 12)
07:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708S=20
Gigabit Ethernet (rev 12)
16:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gigabi=
t=20
Ethernet (rev a3)
16:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gigabi=
t=20
Ethernet (rev a3)
18:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gigabi=
t=20
Ethernet (rev a3)
18:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gigabi=
t=20
Ethernet (rev a3)

lspci -k ....=20
eth{0,1}
        Subsystem: Hewlett-Packard Company NC373i Integrated Multifunction=
=20
Gigabit Server Adapter
        Kernel driver in use: bnx2

eth{2,3,4,5}
        Subsystem: Hewlett-Packard Company NC325m PCIe Quad Port Adapter
        Kernel driver in use: tg3


I remember some discussion on the web that generic-segmentation-offload wou=
ld=20
be preferrable over tcp-segmentation-offload anyway.
Nevertheless, let's  give it a try, but it does not want to do so:

root@blade-002:~# ethtool -K eth4 tso on
Could not change any device features

Do I interpret this right when I say the card/the driver is not supporting=
=20
TSO?


Just for curiousity:
Tried to set tso off for all cluster link eht? on the gateway, too
	.... 3.31 Gbits/sec -> no effect


but still the old picture: over 2 different connections, I can easyly satur=
ate=20
the link:


# iperf -c 192.168.130.226 -P2
=2D-----------------------------------------------------------
Client connecting to 192.168.130.226, TCP port 5001
TCP window size:  780 KByte (default)
=2D-----------------------------------------------------------
[  4] local 192.168.130.250 port 49543 connected with 192.168.130.226 port=
=20
5001
[  3] local 192.168.130.250 port 49542 connected with 192.168.130.226 port=
=20
5001
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  3.29 GBytes  2.82 Gbits/sec
[  3]  0.0-10.0 sec  3.30 GBytes  2.84 Gbits/sec
[SUM]  0.0-10.0 sec  6.59 GBytes  5.66 Gbits/sec


And doing it the other way round, I can saturat the link with only one=20
connection:

# iperf -s
=2D-----------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  488 KByte (default)
=2D-----------------------------------------------------------
[  4] local 192.168.130.250 port 5001 connected with 192.168.130.226 port=20
60139
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  6.52 GBytes  5.60 Gbits/sec

root@blade-002:~# iperf -c 192.168.130.250
=2D-----------------------------------------------------------
Client connecting to 192.168.130.250, TCP port 5001
TCP window size:  325 KByte (default)
=2D-----------------------------------------------------------
[  3] local 192.168.130.226 port 60139 connected with 192.168.130.250 port=
=20
5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  6.52 GBytes  5.60 Gbits/sec


****************************************************************

What puzzles me are the differences in TCP window size:
Does it relate to the 	tcp_metric_cache  issue?

What we also might consider is that one of the physical links is used as "b=
oot=20
net"


As you can see, there are two addresses assigned to the first physical link=
=20
(eth6 on gateway, eth0 on blade)
Subnet 192.168.130.0/27 is used for boot (PXE, tftp, nfsroot)
Subnet 192.168.130.32/27 is the first teql assigned subnet.

While there is no traffic blade <-> blade and not much blade ->gateway,
during boot, all the nfsroot traffic is transferred gateway -> blade
right in the direction we encounter bad teql performance.

I don't think that there is much transfer during the iperf tests.=20
So it is not an issue of congestion.
But may it be that the boot traffic "skews" the tcp_metric_cache ?
May even just a small number of transfers imbalance the teql flow?


root@cruncher:~# ip route
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


root@blade-002:~# ip ro
default via 192.168.130.30 dev eth0
192.168.130.0/27 dev eth0  proto kernel  scope link  src 192.168.130.2
192.168.130.32/27 dev eth0  proto kernel  scope link  src 192.168.130.34
192.168.130.64/27 dev eth1  proto kernel  scope link  src 192.168.130.66
192.168.130.96/27 dev eth2  proto kernel  scope link  src 192.168.130.98
192.168.130.128/27 dev eth3  proto kernel  scope link  src 192.168.130.130
192.168.130.160/27 dev eth4  proto kernel  scope link  src 192.168.130.162
192.168.130.192/27 dev eth5  proto kernel  scope link  src 192.168.130.194
192.168.130.224/27 dev teql0  proto kernel  scope link  src 192.168.130.226



Sorry when things are weird that way.
But I wouldn't have bothered this venerable list when there had been a simp=
le=20
solution....



Wolfgang Rosner

--Boundary-00=_AqyDV4MtCmuWW14
Content-Type: text/x-log;
  charset="iso 8859-15";
  name="eth_offload_blade-002.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="eth_offload_blade-002.log"

Features for eth0:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: on
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: on
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth1:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: on
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: on
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth2:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: on
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [requested on]
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on [fixed]
tx-vlan-offload: on [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth3:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: on
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [requested on]
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on [fixed]
tx-vlan-offload: on [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth4:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: on
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [requested on]
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on [fixed]
tx-vlan-offload: on [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth5:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: on
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [requested on]
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on [fixed]
tx-vlan-offload: on [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]


--Boundary-00=_AqyDV4MtCmuWW14
Content-Type: text/x-log;
  charset="iso 8859-15";
  name="eth_offload_gateway.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="eth_offload_gateway.log"

Features for eth0:
rx-checksumming: on
tx-checksumming: off
	tx-checksum-ipv4: off
	tx-checksum-ip-generic: off [fixed]
	tx-checksum-ipv6: off
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: off
	tx-scatter-gather: off
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: off [requested on]
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth1:
rx-checksumming: off [fixed]
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on [fixed]
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on [fixed]
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: off
	tx-tcp-segmentation: off [fixed]
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth2:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth3:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth4:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth5:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth6:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth7:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth8:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Features for eth9:
rx-checksumming: on
tx-checksumming: on
	tx-checksum-ipv4: off [fixed]
	tx-checksum-ip-generic: on
	tx-checksum-ipv6: off [fixed]
	tx-checksum-fcoe-crc: off [fixed]
	tx-checksum-sctp: off [fixed]
scatter-gather: on
	tx-scatter-gather: on
	tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
	tx-tcp-segmentation: on
	tx-tcp-ecn-segmentation: off [fixed]
	tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]


--Boundary-00=_AqyDV4MtCmuWW14--
