From: =?UTF-8?q?Peter=20N=C3=B8rlund?= <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 0/3] ipv4: Hash-based multipath routing
Date: Wed, 17 Jun 2015 22:08:03 +0200
Message-ID: <1434571686-5149-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series enhances the IPv4 multipath code, adding support for
hash-based multipath.

The multipath algorithm is a per-route attribute (RTA_MP_ALGO) with som=
e
degree of binary compatibility with the old implementation (2.6.12 - 2.=
6.22),
but without source level compatibility since attributes have different =
names:

RT_MP_ALG_L3_HASH:
L3 hash-based distribution. This was IP_MP_ALG_NONE, which with the rou=
te
cache behaved somewhat like L3-based distribution. This is now the defa=
ult.

RT_MP_ALG_PER_PACKET:
Per-packet distribution. Was IP_MP_ALG_RR. Uses round-robin.

RT_MP_ALG_DRR, RT_MP_ALG_RANDOM, RT_MP_ALG_WRANDOM:
Unsupported values, but reserved because they existed in 2.6.12 - 2.6.2=
2.

RT_MP_ALG_L4_HASH:
L4 hash-based distribution. This is new.

The traditional modulo approach was replaced by a threshold-based appro=
ach,
described in RFC 2992. This reduces disruption in case of link failures=
 or
route changes.

To better support anycast environments where PMTU usually breaks with
multipath, certain ICMP packets are hashed using the header within the
payload, ensuring that ICMP packets are routed over the same path as th=
e
flow they belong to.

As a side effect, the multipath spinlock was removed and the code got f=
aster.
I measured ip_mkroute_input (excl. __mkroute_input) on a Xeon X3350 (2.=
66GHz)
with two paths and L3 hashing:

1 thread:
Before: ~199.8 cycles(tsc)
After:   ~75.2 cycles(tsc)

4 threads:
Before: ~393.9 cycles(tsc)
After:   ~77.8 cycles(tsc)

If this patch is accepted, a follow-up patch to iproute2 will also be
submitted.

Best regards,
 Peter N=C3=B8rlund

Peter N=C3=B8rlund (3):
      ipv4: Lock-less per-packet multipath
      ipv4: L3 and L4 hash-based multipath routing
      ipv4: ICMP packet inspection for multipath

 include/net/ip_fib.h           |   10 ++-
 include/net/route.h            |    5 +
 include/uapi/linux/rtnetlink.h |   14 ++++
 net/ipv4/Kconfig               |    1=20
 net/ipv4/fib_frontend.c        |    4 +
 net/ipv4/fib_semantics.c       |  146 +++++++++++++++++++++++++-------=
--------
 net/ipv4/icmp.c                |   29 +++++++-
 net/ipv4/route.c               |  108 +++++++++++++++++++++++++++---
 net/ipv4/xfrm4_policy.c        |    2 -
 9 files changed, 246 insertions(+), 73 deletions(-)
