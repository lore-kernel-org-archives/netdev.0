From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 7296] New: Connected networks persist in routing table
 despite no IF_RUNNING
Date: Wed, 11 Oct 2006 14:12:13 -0700
Message-ID: <20061011141213.6b80093c@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:32454 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161457AbWJKVMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:12:18 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k9BLCEaX002415
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 11 Oct 2006 14:12:14 -0700
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k9BLCD9h001764
	for <netdev@vger.kernel.org>; Wed, 11 Oct 2006 14:12:14 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I rejected this because I don't consider "sticky routes" when link is down
a bug.

Date: Tue, 10 Oct 2006 02:17:26 -0700
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@osdl.org
Subject: [Bug 7296] New: Connected networks persist in routing table despite no IF_RUNNING


http://bugzilla.kernel.org/show_bug.cgi?id=7296

           Summary: Connected networks persist in routing table despite no
                    IF_RUNNING
    Kernel Version: 2.6.18
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: shaun.kemp@stealthnet.net


Most recent kernel where this bug did not occur: All affected AFAIK
Distribution: Debian Sarge
Hardware Environment: Dual (Intel) Ethernet, PPro, SATA RAID, etc
0000:02:06.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 0d) 
0000:02:07.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 0d)
Software Environment: K:2.6.18 and more. (Quagga: 0.98.3-7.2)

Problem Description:

Introduction
------------
Our servers have two ethernet interfaces to offer resiliency.
They run a routing protocol (OSPF) in order to learn exit paths via either of
these interfaces. 
These routing protocols are independant to this problem, however from experience
the problem curtails the effectiveness of any such protocols in resilient
architectures. 
Therefore with growing interest shown in utilising Linux as a router, IMO this
should be considered a fairly serious bug.

Problem
-------
Whilst the nature of my specific topology is rather complex, I can define the
problem generally as:

A "connected" IP network whose interface subsequently loses its IF_RUNNING flag
(ie unusable for routing), persists in the Linux routing table apparently as a
"kernel" route.

In the case of running routing protocols on dual interface servers this
connected network is likely, following the destruction of the connected
interface, to be reachable via the other.
If the route persists however, it will never use this alternate path and black
hole any traffic by routing it via a dead interface.

See below example:
------------------
# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:20:ED:35:D4:C8
          inet addr:192.168.0.143  Bcast:192.168.0.191  Mask:255.255.255.192
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

eth1      Link encap:Ethernet  HWaddr 00:20:ED:35:D4:C9
          inet addr:192.168.0.207  Bcast:192.168.0.255  Mask:255.255.255.192
          UP BROADCAST MULTICAST  MTU:1500  Metric:1

# ip route show
192.168.0.128/26 dev eth0  proto kernel  scope link  src 192.168.0.143
192.168.0.192/26 dev eth1  proto kernel  scope link  src 192.168.0.207  <-- NO!!
192.168.0.192/26 via 192.168.0.130 dev eth0  proto zebra  metric 60 equalize

# ping {anything else on 192.168.0.192/26}
<zilch>

The path for 192.168.0.192 is learned via 192.168.0.130 (current ospf dr -
irrelevant), but it'll never use it because of the kernel sourced directly
connected route still sitting in there. 
If I then IFDOWN eth1, everything is fine and the route withdraws correctly, but
this kinda defeats the object of dynamic routing =:/

Not sure whether this is a "driver tells the kernel" or a "kernel checks the
driver at {n} intervals" issue - I would suggest the former would be more
correct, but it is a problem regardless.

Steps to reproduce:

Ingredients
-----------
1 x Linux (mine is Debian sarge but it may affect all kernels)
1 x Dual Ethernet server (see Intel cards above for my exact build)
1 x Switch or Hub or similar (cheap will do)

Connect the Server ports to the switch ports so the server interfaces are
RUNNING in ifconfig

On the server, configure:
eth0 as 192.168.0.1/24
eth1 as 192.168.1.1/24

NOW
"ip route show"

Pull the plug on the eth0 interface, or admin shut it on the SWITCH end if
you're a ciscoite.

If buggy then "ip route show" will still show the network 192.168.0.0/24 in the
routing table. It really shouldn't do this - if a path to this network had been
learned via a protocol via the other interface, it would never use that path
because the network persists as directly connected and thus supercedes any
dynamic path in true cisco style.

Try ifdown, the route will withdraw correctly, it needs to do that if IF_RUNNING
goes away.

Rgds
Shaun Kemp

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.


-- 
Stephen Hemminger <shemminger@osdl.org>
