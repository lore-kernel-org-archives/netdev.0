From: Marc Haber <mh+netdev@zugschlus.de>
Subject: IPv6 route to gateway on fe80::1%eth0 when I have fe80::1%br0
  locally
Date: Sat, 12 Dec 2015 20:58:30 +0100
Message-ID: <20151212195830.GA18286@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:44962 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbbLLUlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 15:41:44 -0500
Received: from mh by torres.zugschlus.de with local (Exim 4.80)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1a7qJK-0005af-5c
	for netdev@vger.kernel.org; Sat, 12 Dec 2015 20:58:30 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

one of my systems (Debian unstable, kernel 4.3.2) serves as host to
virtualize other systems. It therefore has a Bridge interface br0 to
talk to the virtual machines. To have simple configuration, I have
configured fe80::1 on br0, and the VMs use that as a default gateway
(in the case that SLAAC might be turned off on the target machines).

|[1/498]mh@fan:~$ ip -6 addr show dev br0
|3: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
|    inet6 2a01:238:4071:328d:c4f4:98ff:fedc:5e21/64 scope global mngtmpaddr dynamic
|       valid_lft 86400sec preferred_lft 14400sec
|    inet6 2a01:238:4071:328d::1d:153/64 scope global
|       valid_lft forever preferred_lft forever
|    inet6 2a01:238:4071:328d::1d:100/64 scope global
|       valid_lft forever preferred_lft forever
|    inet6 fec0:0:0:ffff::3/128 scope site
|       valid_lft forever preferred_lft forever
|    inet6 fec0:0:0:ffff::2/128 scope site
|       valid_lft forever preferred_lft forever
|    inet6 fec0:0:0:ffff::1/128 scope site
|       valid_lft forever preferred_lft forever
|    inet6 fe80::1/64 scope link
|       valid_lft forever preferred_lft forever
|    inet6 fe80::c4f4:98ff:fedc:5e21/64 scope link
|       valid_lft forever preferred_lft forever
|[2/499]mh@fan:~$

The Machine itself does, of course, have an uplink to the Internet. I
would like to have it do SLAAC on that uplink interface so that it
learns the gateway automatically.
/proc/sys/net/ipv6/conf/{all,eth0}/forwarding is 1,
/proc/sys/net/ipv6/conf/{all,eth0}/accept_ra is 2.

On older machines, this setup works fine.

Here is the result of SLAAC:
|[2/499]mh@fan:~$ ip -6 addr show dev eth0
|2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
|    inet6 2a01:238:4071:3282:5604:a6ff:fe82:2100/64 scope global mngtmpaddr dynamic
|       valid_lft 86318sec preferred_lft 14318sec
|    inet6 fe80::5604:a6ff:fe82:2100/64 scope link
|       valid_lft forever preferred_lft forever
|[3/500]mh@fan:~$

Please note that eth0 does _not_ have an fe80::1 address.

The gateway that is reachable on the physical eth0 is a Linux as well.
It's running radvd 1.9.1, and it has fe80::1 on its inner interface
configured, for the same reason of ease of configurability on systems
not running SLAAC. It also has a auto-configured link local address,
fe80::7c79:61ff:fe31:5528/64.

For some strange reasons, the radvd running on the router now
announces fe80::1 as the gateway address and not the auto-configured
link local address that older radvd versions (such as the 1.8 in
Debian oldstable) use.

Fan, the system in question, uses this as excuse to only honor the
prefix announcement in the RA coming in from the router and to ignore
the gateway, presumably because we have the same IP address bound to
one of our other IP addresses.

In IPv6, this setup is however, perfectly valid and common. fe80::1 is
commonly used on interfaces that can be used as gateway towards the
Internet so that the local admin does not need to think when manually
setting a default route. This is easily proven by manually setting the
route ("ip -6 route add default via fe80::1 dev eth0"), which makes
the entire setup work immediately.

Cross-Checking, with the fe80::1 removed from br0, things are fine as
well, prefix and route are learned on eth0 in this case.

I find the kernel's behavior perfectly valid for IPv4, so that it
doesn't accept routes pointing towards locally bound IP addresses. In
IPv6, link local addresses do depend on the interface, and thus only
the combination of IP address and interface should be used for this
extra check.

It should be possible to have fe80::1%br0 locally while having a route
point towards fe80::1%eth0. That this does not work is, in my opinion,
a kernel bug.

I am open to arguments why the kernel's behavior is correct this way,
and would like to know what to do on my systems to (a) have SLAAC
working on my "routing" VM host and to (b) keep ease of configuration
on non-SLAAC systems on both the physical and the virtual network.

Any hints would be appreciated.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
