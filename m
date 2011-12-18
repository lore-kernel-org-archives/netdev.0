From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: netem and hierarchical ingress traffic shaping
Date: Sun, 18 Dec 2011 00:12:12 -0500
Message-ID: <1324185132.8451.439.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:54351 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039Ab1LRFMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Dec 2011 00:12:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I am having some delightful success building a test WAN
environment using hfsc and netem.  We have placed netem on both ingress
and egress for various test environment reasons.  We are also using hfsc
on both ingress and egress for traffic shaping.

Since netem appears to be classless, we realized we would need to
replace the SFQ on each leaf with netem which we really didn't want to
do - not only to not lose SFQ but because we didn't want to maintain the
netem parameters on each leaf.  So, we activated our ifb1 interface,
placed netem on it and redirected all the egress traffic to ifb1.  Taht
worked fine.

However, how do we do this on the ingress? To use hfsc on ingres, we are
already redirecting to ifb0.  We can't redirect ifb0 to ifb1.  If we
apply multiple filters, one to redirect into ifb0 and the other to ifb1,
only the first match takes effect.  So we are living with replacing SFQ
on the ifb0 leaves with netem.

Is there any other way? Thanks - John

In case it is of interest, here is the set of rules we are using:

tc qdisc add dev eth1 root handle 1: hfsc default 20
tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit ul rate 1490kbit
tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls rate 200kbit
tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 10
tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16kbit dmax 50ms rate 200kbit ls rate 1000kbit
tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 60
tc class add dev eth1 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax 20ms rate 20kbit
tc qdisc add dev eth1 parent 1:30 handle 1301 sfq perturb 60
iptables -t mangle -A POSTROUTING -p 6 --syn --dport 443 -j CONNMARK --set-mark 0x10
iptables -t mangle -A PREROUTING -p 6 --syn --dport 822 -j CONNMARK --set-mark 0x11
iptables -t mangle -A POSTROUTING -o eth1 -p 6 -j CONNMARK --restore-mark
tc filter add dev eth1 parent 1:0 protocol ip prio 10 handle 0x10 fw flowid 1:10
tc filter add dev eth1 parent 1:0 protocol ip prio 10 handle 0x11 fw flowid 1:30
tc qdisc add dev eth1 ingress
modprobe ifb
ifconfig ifb0 up
tc filter add dev eth1 parent ffff: protocol ip prio 50 u32 match u32 0 0 action mirred egress redirect dev ifb0
tc qdisc add dev ifb0 root handle 1: hfsc default 20
tc class add dev ifb0 parent 1: classid 1:1 hfsc sc rate 1490kbit ul rate 1490kbit
tc class add dev ifb0 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls rate 200kbit
tc qdisc add dev ifb0 parent 1:20 handle 1201 netem delay 25ms 5ms distribution normal loss 0.1% 30%
tc class add dev ifb0 parent 1:1 classid 1:10 hfsc rt umax 16kbit dmax 50ms rate 200kbit ls rate 1000kbit
tc qdisc add dev ifb0 parent 1:10 handle 1101 netem delay 25ms 5ms distribution normal loss 0.1% 30%
tc class add dev ifb0 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax 20ms rate 20kbit
tc qdisc add dev ifb0 parent 1:30 handle 1301 netem delay 25ms 5ms distribution normal loss 0.1% 30%
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 handle 6: u32 divisor 1
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 match ip protocol 6 0xff link 6: offset at 0 mask 0x0f00 shift 6 plus 0 eat
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match tcp src 443 0x00ff flowid 1:10
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match tcp dst 822 0xff00 flowid 1:30
ifconfig ifb1 up
tc qdisc add dev ifb1 root handle 2 netem delay 25ms 5ms distribution normal loss 0.1% 30%
tc filter add dev eth1 parent 1:0 protocol ip prio 1 u32 match u32 0 0 action mirred egress redirect dev ifb1
