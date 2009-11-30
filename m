From: Patrick McHardy <kaber@trash.net>
Subject: RFC: net 00/05: routing based send-to-self implementation
Date: Mon, 30 Nov 2009 18:55:30 +0100 (MET)
Message-ID: <20091130175529.7555.10132.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56502 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbZK3Rza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:55:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are yet another attempt at adding "send-to-self" functionality,
allowing to send packets between two local interfaces over the wire. Unlike
the approaches I've seen so far, this one is purely routing based.
Especially the oif classification should also be useful for different setups.

The patchset consists of three parts:

- the first three patches add oif classification to fib_rules. This can be
  used create special routing tables for sockets bound to an interface.

- the fourth patch changes IPv4 and IPv6 to allow to delete the local rule
  with priority 0. This allows to re-create it using a lower priority and
  insert new rules below it to force packets with a local destination out
  on the wire.

- the fifth patch adds a devinet sysctl to accept packets with local source
  addresses in fib_validate_source(). This one unfortunately seems to be
  necessary, I couldn't come up with a method based purely on adding more
  routes to fool fib_validate_source() into accepting those packets.

Usage example:

# move local routing rule to lower priority
ip rule add pref 1000 lookup local
ip rule del pref 0

# only reply to ARP requests for addresses configured on the device
echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore

# configure device and force packets of bound sockets out on eth1
ip address add dev eth1 10.0.0.1/24
echo 1 > /proc/sys/net/ipv4/conf/eth1/accept_local
ip link set eth1 up
ip rule add pref 500 oif eth1 lookup 500
ip route add default dev eth1 table 500

# configure device and force packets of bound sockets out on eth2
ip address add dev eth2 10.0.0.2/24
echo 1 > /proc/sys/net/ipv4/conf/eth2/accept_local
ip link set eth2 up
ip rule add pref 501 oif eth2 lookup 501
ip route add default dev eth2 table 501

At this point both packets between sockets bound to eth1/eth2 will
go over the wire.

Comments welcome.


 Documentation/networking/ip-sysctl.txt |    6 +++
 include/linux/fib_rules.h              |    8 +++-
 include/linux/inetdevice.h             |    1 +
 include/linux/sysctl.h                 |    1 +
 include/net/fib_rules.h                |    9 +++-
 kernel/sysctl_check.c                  |    1 +
 net/core/fib_rules.c                   |   71 +++++++++++++++++++++++---------
 net/ipv4/devinet.c                     |    1 +
 net/ipv4/fib_frontend.c                |   11 +++--
 net/ipv4/fib_rules.c                   |    2 +-
 net/ipv6/fib6_rules.c                  |    2 +-
 11 files changed, 82 insertions(+), 31 deletions(-)

Patrick McHardy (5):
      net: fib_rules: rearrange struct fib_rule
      net: fib_rules: rename ifindex/ifname/FRA_IFNAME to iifindex/iifname/FRA_IIFNAME
      net: fib_rules: add oif classification
      net: fib_rules: allow to delete local rule
      ipv4: add sysctl to accept packets with local source addresses
