From: =?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
Subject: [PATCH v4 net-next 0/2] ipv4: Hash-based multipath routing
Date: Wed, 23 Sep 2015 21:49:35 +0200
Message-ID: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	=?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:36199 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033AbbIWTuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2015 15:50:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the routing cache was removed in 3.6, the IPv4 multipath algorithm=
 changed
from more or less being destination-based into being quasi-random per-p=
acket
scheduling. This increases the risk of out-of-order packets and makes i=
t
impossible to use multipath together with anycast services.

This patch series replaces the old implementation with flow-based load
balancing based on a hash over the source and destination addresses.

Distribution of the hash is done with thresholds as described in RFC 29=
92.
This reduces the disruption when a path is added/remove when having mor=
e than
two paths.

To futher the chance of successful usage in conjuction with anycast, IC=
MP
error packets are hashed over the inner IP addresses. This ensures that=
 PMTU
will work together with anycast or load-balancers such as IPVS.

Port numbers are not considered since fragments could cause problems wi=
th
anycast and IPVS. Relying on the DF-flag for TCP packets is also insuff=
icient,
since ICMP inspection effectively extracts information from the opposit=
e
flow which might have a different state of the DF-flag. This is also wh=
y the
RSS hash is not used. These are typically based on the NDIS RSS spec wh=
ich
mandates TCP support.

Measurements of the additional overhead of a two-path multipath
(p_mkroute_input excl. __mkroute_input) on a Xeon X3550 (4 cores, 2.66G=
Hz):

Original per-packet: ~394 cycles/packet
L3 hash:              ~76 cycles/packet

Changes in v4:
- Functions take hash directly instead of func ptr
- Added inline hash function
- Added dummy macros to minimize ifdefs
- Use upper 31 bits of hash instead of lower

Changes in v3:
- Multipath algorithm is no longer configurable (always L3)
- Added random seed to hash
- Moved ICMP inspection to isolated function
- Ignore source quench packets (deprecated as per RFC 6633)

Changes in v2:
- Replaced 8-bit xor hash with 31-bit jenkins hash
- Don't scale weights (since 31-bit)
- Avoided unnecesary renaming of variables
- Rely on DF-bit instead of fragment offset when checking for fragmenta=
tion
- upper_bound is now inclusive to avoid overflow
- Use a callback to postpone extracting flow information until necessar=
y
- Skipped ICMP inspection entirely with L4 hashing
- Handle newly added sysctl ignore_routes_with_linkdown

Best Regards
 Peter N=C3=B8rlund


Peter N=C3=B8rlund (2):
      ipv4: L3 hash-based multipath
      ipv4: ICMP packet inspection for multipath

 include/net/ip_fib.h     |   14 ++++-
 include/net/route.h      |   11 +++-
 net/ipv4/fib_semantics.c |  140 ++++++++++++++++++++++----------------=
----
 net/ipv4/icmp.c          |   19 +++++-
 net/ipv4/route.c         |   63 +++++++++++++++++--
 5 files changed, 172 insertions(+), 75 deletions(-)
