From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 15:59:21 +0100
Message-ID: <1324652361.2223.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324651128.10184.586.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:51447 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757330Ab1LWO7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 09:59:25 -0500
Received: by wibhm6 with SMTP id hm6so3212559wib.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 06:59:24 -0800 (PST)
In-Reply-To: <1324651128.10184.586.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 09:38 -0500, John A. Sullivan =
III a
=C3=A9crit :

> Thanks very much, Eric.  gso and gso only was enabled but disabling i=
t
> does not seem to have solved the problem when I activate netem:
>=20

And your kernel version is ?

> root@testswitch01:~# ./tcplay
> root@testswitch01:~# man ethtool
> root@testswitch01:~# ethtool -k eth1
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: off
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
> root@testswitch01:~# ethtool -K eth1 gso off
> root@testswitch01:~# ethtool -k eth1
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: off
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
> ip ro flush cache
>=20
> 64 bytes from 192.168.223.84: icmp_req=3D16 ttl=3D64 time=3D42.6 ms
> 64 bytes from 192.168.223.84: icmp_req=3D17 ttl=3D64 time=3D39.1 ms
> 64 bytes from 192.168.223.84: icmp_req=3D18 ttl=3D64 time=3D45.5 ms
> 64 bytes from 192.168.223.84: icmp_req=3D19 ttl=3D64 time=3D406 ms
> 64 bytes from 192.168.223.84: icmp_req=3D20 ttl=3D64 time=3D919 ms
> 64 bytes from 192.168.223.84: icmp_req=3D21 ttl=3D64 time=3D920 ms
> 64 bytes from 192.168.223.84: icmp_req=3D22 ttl=3D64 time=3D1013 ms
> 64 bytes from 192.168.223.84: icmp_req=3D23 ttl=3D64 time=3D1158 ms
> 64 bytes from 192.168.223.84: icmp_req=3D24 ttl=3D64 time=3D1521 ms
> 64 bytes from 192.168.223.84: icmp_req=3D25 ttl=3D64 time=3D1915 ms
> 64 bytes from 192.168.223.84: icmp_req=3D26 ttl=3D64 time=3D2371 ms
> 64 bytes from 192.168.223.84: icmp_req=3D27 ttl=3D64 time=3D2797 ms
> 64 bytes from 192.168.223.84: icmp_req=3D28 ttl=3D64 time=3D3161 ms
> 64 bytes from 192.168.223.84: icmp_req=3D29 ttl=3D64 time=3D3162 ms
> 64 bytes from 192.168.223.84: icmp_req=3D30 ttl=3D64 time=3D3163 ms
>=20
> Just in case something is amiss in my methodology, I have four ssh
> sessions open to the test firewall; ssh is in a separate prioritized
> queue.  In one session I run:
> 	ping 192.168.223.84
> Then, in another, I do:
> 	nc 192.168.223.100 443 >/dev/null - this should go into a non-defaul=
t,

So you _receive_ trafic ?

Are you aware you dont have SFQ in your ingress setup, only egress  ?

> prioritized queue.
> Pings are OK at this point.
> Then, in a third, I do:
> 	nc 192.168.223.100 80 >/dev/null - this goes into the default queue,

same here ?

> the same as ping, and is when the trouble starts.
>=20
> I did alter the queue lengths in a recommendation from Dave Taht.  He=
re
> is my current script with netem:
>=20
> tc qdisc add dev eth1 root handle 1: hfsc default 20
> tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit ul
> rate 1490kbit
> tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls
> rate 200kbit
> tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 60 limit 30
> tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16kbit dma=
x
> 50ms rate 200kbit ls rate 1000kbit
> tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 60 limit 30
> tc class add dev eth1 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax
> 20ms rate 20kbit
> tc qdisc add dev eth1 parent 1:30 handle 1301 sfq perturb 60 limit 30
> iptables -t mangle -A POSTROUTING -p 6 --syn --dport 443 -j CONNMARK
> --set-mark 0x10
> iptables -t mangle -A PREROUTING -p 6 --syn --dport 822 -j CONNMARK
> --set-mark 0x11
> iptables -t mangle -A POSTROUTING -o eth1 -p 6 -j CONNMARK
> --restore-mark
> modprobe ifb
> ifconfig ifb0 up
> ifconfig ifb1 up
> tc qdisc add dev ifb0 root handle 1: hfsc default 20
> tc class add dev ifb0 parent 1: classid 1:1 hfsc sc rate 1490kbit ul
> rate 1490kbit
> tc class add dev ifb0 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls
> rate 200kbit
> tc qdisc add dev ifb0 parent 1:20 handle 1201 netem delay 25ms 5ms
> distribution normal loss 0.1% 30%
> tc class add dev ifb0 parent 1:1 classid 1:10 hfsc rt umax 16kbit dma=
x
> 50ms rate 200kbit ls rate 1000kbit
> tc qdisc add dev ifb0 parent 1:10 handle 1101 netem delay 25ms 5ms
> distribution normal loss 0.1% 30%
> tc class add dev ifb0 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax
> 20ms rate 20kbit
> tc qdisc add dev ifb0 parent 1:30 handle 1301 netem delay 25ms 5ms
> distribution normal loss 0.1% 30%
> tc filter add dev ifb0 parent 1:0 protocol ip prio 1 handle 6: u32
> divisor 1
> tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 match ip
> protocol 6 0xff link 6: offset at 0 mask 0x0f00 shift 6 plus 0 eat


> tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match
> tcp src 443 0x00ff flowid 1:10

why "src 443 0x00ff" ? It should be "src 443 0xffff"

> tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match
> tcp dst 822 0xff00 flowid 1:30

same here : "dst 822 0xffff"

> tc qdisc add dev ifb1 root handle 2 netem delay 25ms 5ms distribution
> normal loss 0.1% 30%
> tc qdisc add dev eth1 ingress
> tc filter add dev eth1 parent ffff: protocol ip prio 50 u32 match u32=
 0
> 0 action mirred egress redirect dev ifb0
> tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x11 fw
> flowid 1:30
> tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x10 fw
> flowid 1:10
> tc filter add dev eth1 parent 1:1 protocol ip prio 2 u32 match u32 0 =
0
> flowid 1:20
> tc filter add dev eth1 parent 1:0 protocol ip prio 1 u32 match u32 0 =
0
> flowid 1:1 action mirred egress redirect dev ifb1
> ip link set eth1 txqueuelen 100
> ip link set ifb1 txqueuelen 100
> ip link set ifb0 txqueuelen 100
>=20
> I'd love to solve this.  Just when I thought I was all finished havin=
g
> cracked the multiple filter problem to add netem to hfsc, I hit this.
> Thanks again - John
>=20

Add some SFQ to your ingress too...
