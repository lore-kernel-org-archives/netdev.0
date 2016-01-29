From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net v2 0/2] pv6: fix sticky pktinfo behaviour
Date: Fri, 29 Jan 2016 12:30:18 +0100
Message-ID: <cover.1454066754.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440AbcA2Lag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2016 06:30:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently:

ip addr add dev eth0 2001:0010::1/64
ip addr add dev eth1 2001:0020::1/64
ping6 -I eth0 2001:0020::2

do not lead to the expected results, i.e. eth1 is used as the
egress interface.

This is due to two related issues in handling sticky pktinfo,
used by ping6 to enforce the device binding:

- ip6_dst_lookup_flow()/ip6_dst_lookup_tail() do not really enforce
flowi6_oif match
- ipv6 udp connect() just ignore flowi6_oif

These patches address each issue individually.

The kernel has never enforced the egress interface specified
via the sticky pktinfo, except briefly between the commits
741a11d9e410 ("net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set")
and
d46a9d678e4c ("net: ipv6: Dont add RT6_LOOKUP_F_IFACE flag if saddr set"),
but the ping6 tools was unaffected up to iputils-20100214,
since before it used SO_BINDTODEVICE to enforce the egress
interface.

Paolo Abeni (2):
  ipv6: enforce flowi6_oif usage in ip6_dst_lookup_tail()
  ipv6/udp: use sticky pktinfo egress ifindex on connect()

 include/net/ip6_route.h | 12 ++++++++++--
 net/ipv6/datagram.c     |  3 +++
 net/ipv6/ip6_output.c   |  6 +++++-
 net/ipv6/route.c        |  7 +++----
 4 files changed, 21 insertions(+), 7 deletions(-)

-- 
1.8.3.1
