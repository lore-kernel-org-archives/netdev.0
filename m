From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFCv3 bluetooth-next 0/4] 6lowpan: debugfs and stateful compression support
Date: Sun, 29 Nov 2015 12:34:38 +0100
Message-ID: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, lukasz.duda-hR+23Fw+YnFSHonuZl5R5Q@public.gmane.org,
	martin.gergeleit-6wGqcYweBVc@public.gmane.org, Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This patch based on the work of Lukasz Duda. It doesn't contain any interface
lookup methods since we have a generic private dataroom per 6lowpan interface.

Also I dropped the list implementation and do a simple array one. It also
contains support for multicast stateful compression.

To access the context we supporting a complete callback structure for
operations, the include/net/6lowpan.h header contains static inline functions
to call these operations. With such behaviour we don't get any module
dependencies if we need upcomming runtime decisions inside the IPv6 stack.
The alternative would be to do everything inside static inline functions, but
there are few different to handling unicast and multicast context id's, so
it's maybe better to do this as "ops callback structure".

Few things which I am not sure about if it's correct:
 - I implement the dci multicast context table and dci unicast as different
   table. I don't know if when I have a context id "6" which is multicast
   then, I don't can have a unicast context id which is "6". I think they are
   different and we can indicate which table we need to use by the IPHC M bit
   (receiving side)  or the multicast address scope (transmit side).
 - Unicast context prefix length can be shorter than 64 bits. Yes this can be,
   but if somebody wants to do that he usually means "expand the bits until 64
   with zeros". I forbid to add prefix below 64 bits for now.
   Each stateful compression has cases for the IID bits (last 8 byte, use it as
   inline data/do compression, etc.). When I have a prefix 2000:: with prefix
   length 16, then I we hit the case of "Any remaining bits are zero." of
   stateful compression, this means it can be converted by "2000::" prefix
   length 64, then we don't need to care about that when doing a lookup of
   context.
 - I tried to get wireshark know about the available context without success.
   What I successful get working is tell prefix length exact 64 bits long. I
   don't know if wireshark do a correct context handling here, but it's also
   possible to have a prefix length above 64 (In my opinion). E.g. unicast
   stateful compression in case of SAM/DAM 01:
   "Bits covered by context information are always used.  Any IID bits not
    covered by context information are taken directly from the corresponding
    bits carried in-line.

   This patch series do following handling for this case:
   1. generate ipv6 address with inline IID data.
   2. copy the prefix bits from context to the address, which _maybe_ overwrite
      the IID (last eight bytes) data which was carried as inline data.

   This means, if my context is a full address 2001::1/128, then it will be
   the case of SAM/DAM = 11, which means the address is fully elided. (Don't
   care about the IID bits, which will be reconstructed from encapsulating
   header.

   All others SAM/DAM cases has a similar handling.

   Nevertheless I don't know how I can tell that wireshark, I can tell prefix which
   are 64 bit's long only.

Any comments are welcome.

- Alex

changes since RFCv3:
 - add patch for introduce lowpan register/unregister functions
 - change name from ipv6_addr_prefix_cpy to ipv6_addr_prefix_copy
 - move depends on DEBUG_FS to Patch 1/4 (reported by Stefan Schmidt)
 - add "static inline" to lowpan_dev_debugfs_exit if
   CONFIG_6LOWPAN_DEBUGFS is not defined. (reported by some bot)
 - change "enum state" to simple bool and keyword "enabled"
 - change formatstring of prefix-length from "%-03d" to "%-3d", not filled
   with zeros anymore.
 - Add LOWPAN_DEBUGFS_CTX_NUM_ARGS to avoid magic numbers.
 - change name "uninit" to "exit".

changes since RFCv2:
 - fix cleanup for 6LoWPAN per interface debugfs
 - add ipv6_addr_prefix_cpy
 - replace lowpan_iphc_bitcpy with ipv6_addr_prefix_cpy (unicast)
   replace lowpan_iphc_bitcpy with ipv6_addr_prefix and memcpy (multicast)
 - add netdev mailinglist into cc

Alexander Aring (4):
  6lowpan: add lowpan dev register helpers
  6lowpan: add debugfs support
  ipv6: add ipv6_addr_prefix_copy
  6lowpan: iphc: add support for stateful compression

 include/net/6lowpan.h         |  64 +++++-
 include/net/ipv6.h            |  15 ++
 net/6lowpan/6lowpan_i.h       |  31 +++
 net/6lowpan/Kconfig           |   8 +
 net/6lowpan/Makefile          |   1 +
 net/6lowpan/core.c            |  74 ++++++-
 net/6lowpan/debugfs.c         | 166 +++++++++++++++
 net/6lowpan/iphc.c            | 479 +++++++++++++++++++++++++++++++++++++-----
 net/bluetooth/6lowpan.c       |   8 +-
 net/ieee802154/6lowpan/core.c |   6 +-
 10 files changed, 783 insertions(+), 69 deletions(-)
 create mode 100644 net/6lowpan/6lowpan_i.h
 create mode 100644 net/6lowpan/debugfs.c

-- 
2.6.1
