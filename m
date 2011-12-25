From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Problems with route classifiers
Date: Sat, 24 Dec 2011 19:39:27 -0500
Message-ID: <1324773567.3200.56.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:54025 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753064Ab1LYAjb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Dec 2011 19:39:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  Mountains of expensive frustration today :(

I'm still working on creating a test WAN environment using netem with
netem functioning on both egress and ingress.  I understand that we
cannot use both netem and sfq in ingress for reasons discussed in other
threads.

But, I thought, there has to be a way based upon creative configuration;
there's always a way in Linux given some good old fashioned Yankee
ingenuity.  So, I thought, if we can't get the packet on the way in,
we'll get it on the way out - at least for forwarded traffic.  Well
redirect the internal interfaces into ifb1 for processing through netem
if the packet came from the Internet interface.

I didn't want to use marking lest it interfere with other marks, e.g.,
Endian devices have consumed all available marks for their policy
routing.  So, I thought I'd use route fromif classifiers and a couple of
dummy PRIO qdiscs to make it work.

Let's assume eth1 is Internet, eth0 is internal, and that ifb1 is
already configured for netem.  Here's what I thought I could do:

tc qdisc add dev eth0 root handle 10: prio bands 2 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
tc qdisc add dev eth0 parent 10:1 handle 11: prio - this handles the real traffic
tc qdisc add dev eth0 parent 10:2 handle 12: prio - this is just a stub for a filter
For some reason, it seems like I can only attach filters to PRIO qdiscs
and not classes.

Then, the filters (and the problems):
tc filter add dev eth0 parent 12:0 protocol ip prio 1 flowid 11:0 u32 match u32 0 0 action mirred egress redirect dev ifb1
This should get us into ifb1 and then back to the main PRIO qdisc but, I
never got this far because of the problems of getting traffic into 12:0.
This is what I tried:

tc filter add dev eth0 parent 10: protocol ip prio 1 route fromif eth1 flowid 12:0

What is wrong? ip link ls shows the interface is tagged as eth1.  If I
log the iptables traffic on the forward chain, I see it knows IN=eth1.

Neither tc -s filter show dev eth0 parent 12:0 nor tc -s class show dev
eth0 show any packets flowing into 12:2 (I created route filter first
and never got to create the redirect filter so I was expecting packets
on 12:2).  Thanks - John
