From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Fwd: [Bug 447812] New: Netlink messages from "tc"  to sch_netem
 module are not interpreted correctly
Date: Wed, 21 May 2008 15:10:21 -0700
Message-ID: <20080521151021.3d47a3d8@extreme>
References: <20080521214523.GB22591@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55607 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762899AbYEUWK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 18:10:28 -0400
In-Reply-To: <20080521214523.GB22591@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Something in the new netlink parsing made netem break. One other person
saw it and was working on fixing, but no definitive answer yet.

Begin forwarded message:

Date: Thu, 08 May 2008 17:59:24 -0700
From: Karl Auerbach 
To: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Some netem issues with 2.6.25 kernel



I've dug even deeper into the issue of netem on the 2.6.25.x kernels.

(And I'm also attaching a cleaner version of my patch to q_netem.c for 
iproute2.2.6.25: I pulled out the gratuitous changes and left only the 
necessary ones to fix the bug in which uninitialized data was being sent 
across the netlink API, plus one teensy one to remove some whitespace.) 
  (I believe that there are still some remaining issues in the tc 
support of netem in which some correlation values, for instance, could 
be zeroed out, but I did not go after those.)

 From what I can see the larger problem with the netlink messages is 
happening on the kernel side of the boundary.

I used several old binary images of the 'tc' command, several of which I 
built but also ones "borrowed" from Fedora 8/32-bit and tried 'em. 
Every one showed caused the 2.6.25.x kernel to emit the warnings while 
they worked fine on a 2.6.24.x kernel.

I wondered whether this might be caused by my kernel on the AMD Geode 
LX, so I hopped over to a more typical platform - I  went and built a 
64-bit version of 2.6.25.1 and slapped it onto a Fedora 8/64-bit box and 
it, using the Fedora 8 version of 'tc', also showed an error.

My typical test case is a script that clears things out and then imposes 
an impairment on the last line.  (But I get the same problem with other 
command sequences as well, but this one is nice and short.)

/sbin/tc qdisc del dev eth1 root
/sbin/tc qdisc del dev eth1 ingress
/sbin/tc qdisc add dev eth1 root handle 1: prio bands 5 priomap 4 4 4 4 
4 4 4 4 4 4 4 4 4 4 4 4
/sbin/tc qdisc add dev eth1 parent 1:1 handle 10: netem
/sbin/tc qdisc add dev eth1 parent 10:1 handle 100: tbf rate 2147483647 
burst 1600 latency 2000000 mpu 64
/sbin/tc qdisc change dev eth1 parent 1:1 handle 10: netem delay 50ms 
5ms 10% corrupt 8%

It also generates the warning if the last line of the above is simply:

/sbin/tc qdisc change dev eth1 parent 1:1 handle 10: netem delay 50ms 
5ms 10%

But not if that last line is (i.e. with the correlation part dropped.)

/sbin/tc qdisc change dev eth1 parent 1:1 handle 10: netem delay 50ms 5ms

So, all in all, it seems to me that a bug has crept into the kernel 
interpretation of the netem netlink messages.

		--karl--
