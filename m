From: Ian Pilcher <arequipeno@gmail.com>
Subject: Proxy ARP causing Neighbour table overflow
Date: Tue, 08 Jan 2013 11:26:22 -0600
Message-ID: <kchkrs$nmb$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:50494 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756796Ab3AHR34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 12:29:56 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Tsd00-0007Qu-0h
	for netdev@vger.kernel.org; Tue, 08 Jan 2013 18:30:04 +0100
Received: from pool-71-170-109-80.dllstx.fios.verizon.net ([71.170.109.80])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 18:30:04 +0100
Received: from arequipeno by pool-71-170-109-80.dllstx.fios.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 18:30:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am using proxy ARP to divide my home network into several different
subnets, while allowing them all to communicate through my residential
"router".  I am seeing a (very) large number of "Neighbour table over-
flow" messages, although I haven't noticed any impact on connectivity or
performance.

(If you're not familiar with proxy ARP, it's pretty cool.  See
http://en.wikipedia.org/wiki/Proxy_ARP.)

Some details on my setup:

* I have configured my residential router (Verizon FiOS) to use all of
  172.31.0.0/16 as my home network.

* The routers internal IP address is 172.31.255.254.  As expected its
  subnet mask is 255.255.0.0.

* I have configured the router's built-in DHCP server to provide
  addresses within the range 172.31.255.151 - 172.31.255.253 (along with
  a subnet mask of 255.255.0.0).  Normally, the only devices using these
  addresses are my FiOS set-top boxes.

* My subnets run on separate VLANs.  Routing between them is provided by
  a small server running CentOS 6.3 (32-bit).  The server has a dual-
  port NIC, and it is using mode 6 (balance-alb) bonding.  Thus, the
  interfaces on the server range from bond0.249 - bond0.255.

* The "upstream" IP address of my server (on bond0.255) is
  172.31.255.1; it's subnet mask is 255.255.255.0.  (Note the
  difference from the router's subnet mask.)

* The server acts as the default gateway for the other subnets --
  172.31.249.0/24 (on bond0.249, 172.31.249.254) through 172.31.254.0/24
  (on bond0.254, 172.31.249.254).

* I have set "net.ipv4.conf.bond0/255.proxy_arp = 1" in
  /etc/sysctl.conf.  When the server sees an ARP request on bond0.255
  for an address in the range 172.31.249.1 - 172.31.254.254, it responds
  with its own MAC (actually, one of its two MACs because of the way
  mode 6 bonding works).

Despite all this complexity (for a home network at least), I really
don't have a huge number of devices.  Running "arp -n | wc -l" on the
server shows that it has 15 entries in its ARP cache right now, which is
about normal.  It may go up a bit when I spin up a bunch of VMs, but not
by that much.

So why am I getting the "Neighbour table overflow" messages.  Everything
I can Google up on this messages indicates that it happens with "large,
flat networks" with a lot of users.  I do sort of have a large flat
network, but that's really only true from the router's point of view.

(I should note that I only recently configured Ethernet bonding, I was
seeing the "Neighbour table overflow" messages when I was using only a
single interface.)

Any ideas?

Thanks!

-- 
========================================================================
Ian Pilcher                                         arequipeno@gmail.com
Sometimes there's nothing left to do but crash and burn...or die trying.
========================================================================
