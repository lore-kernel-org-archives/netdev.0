From: "Shaun Kemp" <shaun.kemp@stealthnet.net>
Subject: Bug ? IF_RUNNING/routing table updates
Date: Mon, 9 Oct 2006 11:55:28 +0100
Message-ID: <018201c6eb91$816764e0$8100a8c0@stealth00025>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.stealthnet.net.216.3.62.in-addr.arpa ([62.3.216.19]:57239
	"EHLO cow.int.stealthnet.net") by vger.kernel.org with ESMTP
	id S1751791AbWJIKzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 06:55:09 -0400
Received: from ws129.int.stealthnet.net ([192.168.0.129] helo=stealth00025)
	by cow.int.stealthnet.net with esmtp (Exim 4.50)
	id 1GWsmq-0003Ap-Iw
	for netdev@vger.kernel.org; Mon, 09 Oct 2006 11:55:08 +0100
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

We appear to have encountered a bug with kernel routing table updates.
If an interface (+ associated IP network) loses its IF_RUNNING flag, it is
still used for routing.

More details below:

Flavour: Debian
Quagga: ii  quagga         0.96.5-11      Unoff. successor of the Zebra
BGP/OSPF/RIP r
Specific kernel is: 2.4.27-2-386 but noticed the same on 2.6.* release.
0000:02:06.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100]
(rev 0d)
0000:02:07.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100]
(rev 0d)

Basically when operating any of the dynamic routing protocols under Quagga
(or the older "Zebra"), a niggling problem keeps surfacing which curtails
the operation of routing protocols in multihomed server environments under
certain circumstances. Similar reports of the problem appear to be littered
around various lists, but to date I can see no solution and it remains a
problem, hence the post.

Whilst the nature of my specific topology is rather complex, I can define
the problem generally as:
An interface (+ connected IP network) which loses its IF_RUNNING flag (ie
unusable for routing) persists in the routing table as a kernel route.
Thus rather than responding to a dynamically announced route to this
connected network (the connected being unreachable due to the interface
being down, but the dynamic offering an alternate path), the box insists on
trying to route it out of the broken interface via this ?kernel? sourced
route.

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
192.168.0.192/26 dev eth1  proto kernel  scope link  src 192.168.0.207
192.168.0.192/26 via 192.168.0.130 dev eth0  proto zebra  metric 60 equalize

# ping {anything on 192.168.0.192}
<zilch>

The path for 192.168.0.192 is learned via 192.168.0.130 (current ospf dr -
irrelevant), but it'll never use it presumably (from Cisco experience)
because of the kernel sourced directly connected route still sitting in
there. Furthermore, if I then IFDOWN eth1, everything is fine but I don't
want to do this manually everytime there's an interface problem because
that's why we run ospf ! =:D

Not sure whether this is a "driver tells the kernel" or a "kernel checks the
driver at {n} intervals" issue - I would suggest the former would be more
correct, but it is a problem regardless.

Maybe it's just these Intel drivers ? :/

Thanks for your time,
Shaun Kemp.




