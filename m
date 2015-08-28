From: pch@ordbogen.com
Subject: [PATCH v2 net-next 0/3] ipv4: Hash-based multipath routing
Date: Fri, 28 Aug 2015 22:00:47 +0200
Message-ID: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-api@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Benc <jbenc@redhat.com>,
	=?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:42866 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869AbbH1UG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 16:06:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the routing cache was removed in 3.6, the IPv4 multipath algorithm=
 changed
from more or less being destination-based into being quasi-random per-p=
acket
scheduling. This increases the risk of out-of-order packets and makes i=
t
impossible to use multipath together with anycast services.

This patch series seeks to extend the multipath system to support both =
L3 and
L4-based multipath while still supporting per-packet multipath.

The multipath algorithm is set as a per-route attribute (RTA_MP_ALGO) w=
ith some
degree of binary compatibility with the old implementation (2.6.12 - 2.=
6.22),
but without source level compatibility since attributes have different =
names:

RT_MP_ALG_L3_HASH:
L3 hash-based distribution. This was IP_MP_ALG_NONE, which with the rou=
te
cached behaved somewhat like L3-based distribution. This is the new def=
ault.

RT_MP_ALG_PER_PACKET:
Per-packet distribution. Was IP_MP_ALG_RR. Uses round-robin.

RT_MP_ALG_DRR, RT_MP_ALG_RANDOM, RT_MP_ALG_WRANDOM:
Unsupported values, but reserved because they existed in 2.6.12 - 2.6.2=
2.

RT_MP_ALG_L4_HASH:
L4 hash-based distribution. This is new.

The traditional modulo approach is replaced by a threshold-based approa=
ch,
described in RFC 2992. This reduces disruption in case of link failures=
 or
route changes.

To better support anycast environments where PMTU usually breaks with
multipath, certain ICMP packets are hashed using the IP addresses withi=
n the
ICMP payload when using L3 hashing. This ensures that ICMP packets are =
routed
over the same path as the flow they belong to. It is not enabled with L=
4
hashing, since we can only consistently rely on L4 information, when PM=
TU is
used, and PMTU may be used in one direction while not being used in the=
 other.

As a side effect, the multipath spinlock was removed and the code got f=
aster.
I measured ip_mkroute_input (excl. __mkroute_input) on a Xeon X3350 (4 =
cores,
2.66GHz) with two paths:

Old per-packet: ~393.9 cycles(tsc)
New per-packet:  ~75.2 cycles(tsc)
New L3:         ~107.9 cycles(tsc)
New L4:         ~129.1 cycles(tsc)

The timings are approximately the same with a single core, except for t=
he old
per-packet which gets faster (~199.8 cycles) most likely because there =
is no
contention on the spinlock.

If this patch is accepted, a follow-up patch to iproute2 will also be
submitted.

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

Best Regards,
 Peter N=C3=B8rlund

Peter N=C3=B8rlund (3):
      ipv4: Lock-less per-packet multipath
      ipv4: L3 and L4 hash-based multipath routing
      ipv4: ICMP packet inspection for L3 multipath

 include/net/ip_fib.h           |  26 ++++++-
 include/net/route.h            |  12 ++-
 include/uapi/linux/rtnetlink.h |  14 +++-
 net/ipv4/Kconfig               |   1 +
 net/ipv4/fib_frontend.c        |   4 +
 net/ipv4/fib_semantics.c       | 168 ++++++++++++++++++++++++++-------=
--------
 net/ipv4/icmp.c                |  34 ++++++++-
 net/ipv4/route.c               | 112 +++++++++++++++++++++++++--
 8 files changed, 298 insertions(+), 73 deletions(-)
