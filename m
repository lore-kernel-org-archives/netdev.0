From: =?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
Subject: [PATCH v3 net-next 0/2] ipv4: Hash-based multipath routing
Date: Tue, 15 Sep 2015 22:29:51 +0200
Message-ID: <1442348993-3023-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:41184 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981AbbIOUa0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 16:30:26 -0400
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

Benchmarking on a Xeon X3550 (4 cores, 2.66GHz) showed that it was desi=
reable
to move the ICMP handling to a separate method. The reason for this bei=
ng that
the standard hash function can work without using the stack, and the IC=
MP
function cannot (due to skb_header_pointer), causing 4 additional hits =
on the
cache. By separating the two, the fast path (non-ICMP) only requires th=
ree
reads from cache.

Two-path benchmarks (ip_mkroute_input excl. __mkroute_input):

Original per-packet:  ~394 cycles/packet
L3 hash w/o noinline: ~128 cycles/packet
L3 hash w/ noinline:   ~97 cycles/packet

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

 include/net/ip_fib.h     |  11 +++-
 include/net/route.h      |  12 +++-
 net/ipv4/fib_semantics.c | 137 +++++++++++++++++++++++----------------=
----
 net/ipv4/icmp.c          |  16 +++++
 net/ipv4/route.c         |  73 +++++++++++++++++++++--
 5 files changed, 177 insertions(+), 72 deletions(-)
