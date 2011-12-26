From: "John A. Sullivan III" <jsullivan@spiritualoutreach.com>
Subject: Redirection to multiple IFBs from different qdiscs on the same
 interface produces a loop
Date: Mon, 26 Dec 2011 17:22:28 -0500
Message-ID: <1324938148.4401.71.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:54680 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753390Ab1LZWWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Dec 2011 17:22:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I've been able to successfully create our WAN test
environment using netem on egress and ingress along with HFSC and have
eliminated the terrible bufferbloat effect.  Since I can't do both HFSC
shaping and netem conditioning on the ingress, I got around it by
marking the packet coming in from the Internet, and then redirecting it
to a netem conditioned IFB interface on the egress if it has the
"Internet ingress" mark.  It works perfectly fine for traffic traversing
the forward chain.

However, I hit a problem when trying to produce the same effect for
traffic directed to the test router.  In this case, the packets must
pass twice through netem conditioning.  Thus, I set up a "placeholder"
PRIO qdisc to hold the HFSC qdisc so I could put one redirection filter
on the first and a second on the second.

When I do so, I seem to create a loop.  My pings stop and, when I remove
the filter, they resume without a single packet lost but huge round trip
times.  I tried sending the packets to separate IFB interfaces rather
than passing twice through the same one and I tried creating a PRIO
qdisc to hold the PRIO qdisc to insert an extra processing step between
the redirections in case that was the problem.  Nothing help - I always
create a loop.

How can I do this successfully?

Here is the rule set:

#egress traffic shaping
tc qdisc add dev eth1 root handle 2: prio bands 2 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
tc qdisc add dev eth1 parent 2:1 handle 1: hfsc default 20
tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit ul rate 1490kbit #mimic T1 on LAN outbound
tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls rate 200kbit
tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 60
tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16kbit dmax 50ms rate 200kbit ls rate 1000kbit
tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 60
tc class add dev eth1 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax 20ms rate 20kbit
tc qdisc add dev eth1 parent 1:30 handle 1301 sfq perturb 60

iptables -t mangle -A PREROUTING -p 6 --tcp-flags SYN,RST,FIN SYN --dport 443 -j CONNMARK --set-mark 0x12/0 #test settings
iptables -t mangle -A PREROUTING -p 6 --tcp-flags SYN,RST,FIN SYN --dport 822 -j CONNMARK --set-mark 0x11/0 #Interactive
iptables -t mangle -A PREROUTING -i eth1 -j CONNMARK --set-mark 0x30/0
iptables -t mangle -A POSTROUTING -o eth1 -j CONNMARK --restore-mark
iptables -t mangle -A PREROUTING -i eth1 -j CONNMARK --restore-mark
modprobe ifb #numifbs=3
ifconfig ifb0 up
ifconfig ifb1 up

#ingress traffic shaping
tc qdisc add dev ifb0 root handle 1: hfsc default 20
tc class add dev ifb0 parent 1: classid 1:1 hfsc sc rate 1490kbit ul rate 1490kbit - mimic T1 on LAN inbound
tc class add dev ifb0 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls rate 200kbit
tc qdisc add dev ifb0 parent 1:20 handle 1201 sfq perturb 60
tc class add dev ifb0 parent 1:1 classid 1:10 hfsc rt umax 16kbit dmax 50ms rate 200kbit ls rate 1000kbit
tc qdisc add dev ifb0 parent 1:10 handle 1101 sfq perturb 60
tc class add dev ifb0 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax 20ms rate 20kbit
tc qdisc add dev ifb0 parent 1:30 handle 1301 sfq perturb 60
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 handle 6: u32 divisor 1
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 match ip protocol 6 0xff link 6: offset at 0 mask 0x0f00 shift 6 plus 0 eat
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match tcp src 443 0x00ff flowid 1:10
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match tcp dst 822 0xff00 flowid 1:30

#handle all netem conditioning in one definition
tc qdisc add dev ifb1 root handle 2 netem delay 25ms 5ms distribution normal loss 0.1% 30%

# ingress traffic shaping
tc qdisc add dev eth1 ingress
tc filter add dev eth1 parent ffff: protocol ip prio 50 u32 match u32 0 0 action mirred egress redirect dev ifb0
tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x11 fw flowid 1:30
tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x12 fw flowid 1:10
tc filter add dev eth1 parent 1:1 protocol ip prio 2 u32 match u32 0 0 flowid 1:20
#egress netem conditioning
tc filter add dev eth1 parent 1:0 protocol ip prio 1 u32 match u32 0 0 flowid 1:1 action mirred egress redirect dev ifb1

tc qdisc add dev eth0 root handle 10: prio
tc qdisc add dev eth0 parent 10:1 handle 110: sfq perturb 60
tc qdisc add dev eth0 parent 10:2 handle 120: sfq perturb 60
tc qdisc add dev eth0 parent 10:3 handle 130: sfq perturb 60
#ingress netem conditioning
tc filter add dev eth0 parent 10: protocol ip prio 1 handle 0x30/0x30 fw action mirred egress redirect dev ifb1
# THE NEXT ONE IS THE PROBLEM - this one acts on 2:0 as opposed to the eth1 redirect filter above which acts on 1:0
tc filter add dev eth1 parent 2:0 protocol ip prio 1 handle 0x30/0x30 fw action mirred egress redirect dev ifb1

#buffer management
ip link set eth1 txqueuelen 100
ip link set ifb1 txqueuelen 100
ip link set ifb0 txqueuelen 100
ethtool -K eth1 gso off gro off


Oh, as an aside, I first tried to do the "ingress marking" as an action
in the eth1 ingress filter but it seemed to be eliminated by the
--restore-mark in iptables.  Am I correct to assume that is the expected
behavior and CONNMARK and marking in tc are somewhat incompatible?
Thanks - John
