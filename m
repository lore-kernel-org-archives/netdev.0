From: Egor Duda <deo@corpit.ru>
Subject: Problem with redirecting traffic via ifb device
Date: Mon, 26 Jun 2006 14:48:00 +0400
Message-ID: <449FBB60.2000600@corpit.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:64345 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S932465AbWFZKsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 06:48:03 -0400
Received: from [192.168.1.1] (paltus.tls.msk.ru [192.168.1.1])
	by hobbit.corpit.ru (Postfix) with ESMTP id EBA7E2A7F1
	for <netdev@vger.kernel.org>; Mon, 26 Jun 2006 14:48:01 +0400 (MSD)
	(envelope-from deo@corpit.ru)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have a linux router which is connected via pppoe to my ISP. My
provider limits aggregate upload+download rate to some fixed amount of
kbps, so to perform shaping on my router i'm trying to do the same on my
router (to "own the queue", so to say). Since standard tbf accounts to
the packets going only one way, i wanted to create virtual ifb
interface, which will gather all incoming and outgoing packets, and then
perform appropriate shaping on it.

I'm doing it roughly in the following way:

-------------------------------------------------------------------------
tc qdisc add dev $iface ingress
tc qdisc add dev $iface parent ffff: handle 1: prio

tc filter add dev $iface parent 1: protocol ip prio 10 \
u32   match u32 0 0 flowid 1:1 \
action ipt -j MARK --set-mark 1  \
action mirred egress redirect dev ifb0

tc qdisc add dev $iface root handle 2: prio

tc filter add dev $iface parent 2: protocol ip prio 10 \
u32   match u32 0 0 flowid 2:1 \
action ipt -j MARK --set-mark 1 \
action mirred egress redirect dev ifb0
-------------------------------------------------------------------------

The strange thing is, when i run this script over vtun interface, it
works as expected, i can later attach qdiscs on ifb0 interface and
perform shaping i need. But when i try to do the same on ppp interface
(which is my primary outbound interface), packets go to ifb0 (tcpdump
shows them) but not being returned to userspace. So, when i run

ping somehost &
tcpdump -p -n -i ifb0

i see both icmp request and icmp reply packtes in tcpdump output. But
ping seems to never receive icmp replies.

My kernel version is 2.6.16.19, pppd version 2.4.4b1-1 from debian.

Am i totally misguided about how all this stuff works? In this case i'd
appreciate some links to description of 'action mirred egress redirect'.
Or is it some specific of ppp interface which prevents my setup from
working? In fact, i'd be thankful for any advice on handling my
situation (upload+download rate is limited).

As as side note, ifb implementation sets dev type to ARPHRD_ETHER to ifb
device, which prevents tcpdump from parsing packets (it treats them as
ethernet frames, while they are, in fact ip packets). I've patched ifb.c
to set device type to ARPHRD_VOID, and it fixed tcpdump problem.

egor.
