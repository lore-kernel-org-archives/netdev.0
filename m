From: Simon Horman <horms@verge.net.au>
Subject: Possible regression in HTB
Date: Tue, 7 Oct 2008 12:15:53 +1100
Message-ID: <20081007011551.GA28408@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36494 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbYJGBPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 21:15:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Hi Jarek,

I know that you guys were/are playing around a lot in here, but
unfortunately I think that "pkt_sched: Always use q->requeue in
dev_requeue_skb()" (f0876520b0b721bedafd9cec3b1b0624ae566eee) has
introduced a performance regression for HTB.

My tc rules are below, but in a nutshell I have 3 leaf classes.
One with a rate of 500Mbit/s and the other two with 100Mbit/s.
The ceiling for all classes is 1Gb/s and that is also both
the rate and ceiling for the parent class.

                          [ rate=1Gbit/s ]
                          [ ceil=1Gbit/s ]
                                 |
            +--------------------+--------------------+
            |                    |                    |
     [ rate=500Mbit/s ]   [ rate=100Mbit/s ]   [ rate=100Mbit/s ]
     [ ceil=  1Gbit/s ]   [ ceil=100Mbit/s ]   [ ceil=  1Gbit/s ]

The tc rules have an extra class for all other traffic,
but its idle, so I left it out of the diagram.

In order to test this I set up filters so that traffic to
each of port 10194, 10196 and 10197 is directed to one of the leaf-classes.
I then set up a process on the same host for each port sending
UDP as fast as it could in a while() { send(); } loop. On another
host I set up processes listening for the UDP traffic in a
while () { recv(); } loop. And I measured the results.

( I should be able to provide the code used for testing,
  but its not mine and my colleague who wrote it is off
  with the flu today. )

Prior to this patch the result looks like this:

10194: 545134589bits/s 545Mbits/s
10197: 205358520bits/s 205Mbits/s
10196: 205311416bits/s 205Mbits/s
-----------------------------------
total: 955804525bits/s 955Mbits/s

And after the patch the result looks like this:
10194: 384248522bits/s 384Mbits/s
10197: 284706778bits/s 284Mbits/s
10196: 288119464bits/s 288Mbits/s
-----------------------------------
total: 957074765bits/s 957Mbits/s

There is some noise in these results, but I think that its clear
that before the patch all leaf-classes received at least their rate,
and after the patch the rate=500Mbit/s class received much less than
its rate. This I believe is a regression.

I do not believe that this happens at lower bit rates, for instance
if you reduce the ceiling and rate of all classes by a factor of 10.
I can produce some numbers on that if you want them.

The test machine with the tc rules and udp-sending processes
has two Intel Xeon Quad-cores running at 1.86GHz. The kernel
is SMP x86_64.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en


tc qdisc del dev eth0 root

tc qdisc add dev eth0 root handle 1: htb default 10 r2q 10000

tc class add dev eth0 parent 1:  classid 1:1   htb \
	rate 1Gbit ceil 1Gbit

tc class add dev eth0 parent 1:1 classid 1:10 htb \
	rate 1Gbit ceil 1Gbit
tc class add dev eth0 parent 1:1 classid 1:11 htb \
	rate 500Mbit ceil 1Gbit
tc class add dev eth0 parent 1:1 classid 1:12 htb \
	rate 100Mbit ceil 1Gbit
tc class add dev eth0 parent 1:1 classid 1:13 htb \
	rate 100Mbit ceil 1Gbit

tc filter add dev eth0 protocol ip parent 1: \
	u32 match ip dport 10194 0xffff flowid 1:11
tc filter add dev eth0 protocol ip parent 1: \
	u32 match ip dport 10196 0xffff flowid 1:12
tc filter add dev eth0 protocol ip parent 1: \
	u32 match ip dport 10197 0xffff flowid 1:13

