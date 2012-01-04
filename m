From: Brent Cook <bcook@breakingpoint.com>
Subject: Possible DoS with 6RD border relay
Date: Wed, 4 Jan 2012 10:48:44 -0600
Message-ID: <201201041048.44509.bcook@breakingpoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.breakingpoint.com ([65.36.7.12]:11429 "EHLO
	mail.breakingpoint.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab2ADQyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 11:54:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

  I have been doing some testing of Linux serving as a 6RD border relay. It 
seems that if a client sends 6RD-encapsulated packets and varies the lower 64-
bits of the 6RD address over the range of the neighbor table size (the bits 
below the delegated prefix), it causes the neighbor table to quickly overflow. 
However, viewing the neighbor table never shows more than a handful of 
entries. When the neighbor table overflows, packet routing on my test system 
slows from 1Gbps to a couple of Mbps at most.

[28765.764079] net_ratelimit: 32003 callbacks suppressed
[28765.764084] ipv6: Neighbour table overflow.
[28765.764171] ipv6: Neighbour table overflow.

root@target1:~# ip neigh
fe80::1a:c5ff:fe02:2 dev test2  router FAILED
2001:1234::3 dev test2 lladdr 02:1a:c5:02:00:02 REACHABLE
192.168.2.1 dev mgmt0 lladdr 04:7d:7b:06:8d:2d REACHABLE
1.0.0.1 dev test0 lladdr 02:1a:c5:01:00:00 REACHABLE

If I send packets much more slowly, the system works as expected. If the 6RD 
client sends from a constant address rather than varying the lower bits, it 
also works fine. I tested the two neighbor table checks in sit.c and 

The network topology looks something like this:

6RD client -> Router -> Linux (6RD BR) -> IPv6 host

The 6RD client is at 1.1.1.1/24
The Linux BR is at 1.0.0.2/24, the IPv4 router is at 1.0.0.1/24 and the IPv6 
host is directly attached on a second physical interface at address 
2001:1234::3

A configuration script for configuring the BR follows:

#!/bin/bash
PREFIX1="2001:0db8"                  # 6rd ipv6 prefix
intf1=test0
intf2=test2

modprobe sit

## Setup the tunnel, it will create an interface named '6rd'
ip addr add 1.0.0.2/24 dev $intf1
ip link set $intf1 up
sudo ip route add 1.1.1.0/24 via 1.0.0.1
ip addr add 2001:1234::1/64 dev $intf2
ip link set $intf2 up
ip tunnel add 6rd mode sit local 1.0.0.2 dev $intf1 ttl 64
ip tunnel 6rd dev 6rd 6rd-prefix ${PREFIX1}::/32
ip addr add ${PREFIX1}::1/32 dev 6rd
ip link set 6rd up

sysctl -w net.ipv6.conf.all.forwarding=1
