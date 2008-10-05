From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: 802.1p, skb->priority, CoS for transit traffic not working?
Date: Sun, 5 Oct 2008 19:35:56 +0300
Message-ID: <200810051935.56616.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:36243 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758532AbYJEQiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 12:38:13 -0400
Received: from [195.69.208.252] (unknown [195.69.208.252])
	by relay2.globalproof.net (Postfix) with ESMTP id 05E20131045
	for <netdev@vger.kernel.org>; Sun,  5 Oct 2008 19:38:03 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to set CoS tag, to manage priorities on my microwave link.
Possible such setup will be very useful also to set classify traffic passing 
QoS. A lot of hardware support this simple L2 QoS.

Hardware: RTL8139, since it doesn't have VLAN tags acceleration, i can use 
tcpdump to see priority flag.

Commands i did to setup test VLAN, 

vconfig add eth2 10
ifconfig eth2.10 3.3.3.3 netmask 255.255.255.0
vconfig set_egress_map eth2.10 1 1
vconfig set_egress_map eth2.10 2 2
vconfig set_egress_map eth2.10 3 3
vconfig set_egress_map eth2.10 4 4 

First, i made it works locally, with Patrick McHardy patch
http://marc.info/?l=lartc&m=101914368423554&w=2

Source PC: ping -P 2 3.3.3.1

Destination PC:
19:31:21.738317 00:0a:cd:14:6b:6f > 00:05:5d:2f:9b:ba, ethertype 802.1Q 
(0x8100), length 102: vlan 10, p 2, ethertype IPv4, (tos 0x0, ttl 64, id 0, 
offset 0, flags [DF], proto ICMP (1), length 84) 3.3.3.3 > 3.3.3.1: ICMP echo 
request, id 62505, seq 15, length 64
19:31:22.738376 00:0a:cd:14:6b:6f > 00:05:5d:2f:9b:ba, ethertype 802.1Q 
(0x8100), length 102: vlan 10, p 2, ethertype IPv4, (tos 0x0, ttl 64, id 0, 
offset 0, flags [DF], proto ICMP (1), length 84) 3.3.3.3 > 3.3.3.1: ICMP echo 
request, id 62505, seq 16, length 64
19:31:23.738398 00:0a:cd:14:6b:6f > 00:05:5d:2f:9b:ba, ethertype 802.1Q 
(0x8100), length 102: vlan 10, p 2, ethertype IPv4, (tos 0x0, ttl 64, id 0, 
offset 0, flags [DF], proto ICMP (1), length 84) 3.3.3.3 > 3.3.3.1: ICMP echo 
request, id 62505, seq 17, length 64

But next step is to manage traffic over iproute2. Sure it is not clear for me 
how it works, and for example i am feeling prio qdisc is not thing i need, at 
all.
I've tried , smth like this (not sure how it was, but on stats it was showing 
packets hit filter).

tc qdisc del dev eth2.10 root
tc qdisc add dev eth2.10 root handle 1: prio
/sbin/tc filter add dev eth2.10 parent 1:0 protocol all u32 match u32 0 0 
classid 1:3



And i try even new Intel patch, "action skbedit", it works on stats, but 
doesn't set anything. I try ingress(on incoming interface) and egress 
(outgoing).

tc qdisc del dev eth2.10 root
tc qdisc add dev eth2.10 root handle 1: prio
/sbin/tc filter add dev eth2.10 parent 1:0 protocol all u32 match u32 0 0 
action skbedit queue_mapping 2

and ingress
tc qdisc del dev eth0 ingress
tc qdisc add dev eth0 ingress
tc filter add dev eth0 parent ffff: protocol all u32 match u32 0 0 action 
skbedit queue_mapping 3

Is there a way to make work changing transit packets 802.1p values?

