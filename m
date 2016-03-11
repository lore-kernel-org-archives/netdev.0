From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 0/3] Fix differences between IPv4 and IPv6 TCP/UDP
 checksum calculation
Date: Fri, 11 Mar 2016 14:05:28 -0800
Message-ID: <20160311215423.13431.64512.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexander.duyck@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is meant to address the differences that exist between
IPv4 and IPv6 in terms of checksum calculation.  Specifically the IPv6
function csum_ipv6_magic treated length as a value that could be greater
than 64K, while csum_tcpudp_magic was truncating the length at 16 bits.
After looking over the code and giving it some thought I decided it would
be best to update the IPv4 function so that it worked the same way the IPv6
one did.  This allows us to get the same results given the same inputs for
both functions.  As a result we can use the same processes to reverse the
calculation in the event we need to do something like remove the length of
the pseudo-header checksum.

I also took the opportunity to standardize things so that the parameters
for these functions all use the correct types.  IPv4 addresses are __be32,
length should always be __u32, and protocol is a __u8.

With this change in place it corrects an issue with UDP tunnels in which we
were getting a checksum that was off by 1 when performing fragmentation on
inner UDP packets.

---

Alexander Duyck (3):
      ipv4: Update parameters for csum_tcpudp_magic to their original types
      ipv6: Pass proto to csum_ipv6_magic as __u8 instead of unsigned short
      GSO/UDP: Use skb->len instead of udph->len to determine length of original skb


 arch/alpha/include/asm/checksum.h          |   12 ++++--------
 arch/alpha/lib/checksum.c                  |    8 ++------
 arch/arc/include/asm/checksum.h            |    4 ++--
 arch/arm/include/asm/checksum.h            |   14 +++++++-------
 arch/avr32/include/asm/checksum.h          |   10 ++++------
 arch/blackfin/include/asm/checksum.h       |    4 ++--
 arch/c6x/include/asm/checksum.h            |    4 ++--
 arch/cris/include/arch-v10/arch/checksum.h |    4 ++--
 arch/cris/include/arch-v32/arch/checksum.h |    2 +-
 arch/cris/include/asm/checksum.h           |    5 ++---
 arch/frv/include/asm/checksum.h            |   10 +++++-----
 arch/hexagon/include/asm/checksum.h        |    8 ++++----
 arch/hexagon/lib/checksum.c                |   10 ++++------
 arch/ia64/include/asm/checksum.h           |   16 ++++++----------
 arch/ia64/lib/checksum.c                   |    8 ++++----
 arch/m32r/include/asm/checksum.h           |   10 ++++------
 arch/m68k/include/asm/checksum.h           |    2 +-
 arch/metag/include/asm/checksum.h          |    7 +++----
 arch/microblaze/include/asm/checksum.h     |    4 ++--
 arch/mips/include/asm/checksum.h           |    8 ++++----
 arch/mn10300/include/asm/checksum.h        |   17 +++++------------
 arch/nios2/include/asm/checksum.h          |    9 ++++-----
 arch/parisc/include/asm/checksum.h         |   12 +++++-------
 arch/s390/include/asm/checksum.h           |    6 ++----
 arch/score/include/asm/checksum.h          |   15 +++++++--------
 arch/sh/include/asm/checksum_32.h          |    9 +++------
 arch/sparc/include/asm/checksum_32.h       |   13 +++++--------
 arch/sparc/include/asm/checksum_64.h       |    9 +++------
 arch/unicore32/include/asm/checksum.h      |    4 ++--
 arch/x86/include/asm/checksum_32.h         |    9 +++------
 arch/x86/include/asm/checksum_64.h         |   10 +++++-----
 arch/x86/lib/csum-wrappers_64.c            |    2 +-
 arch/x86/um/asm/checksum.h                 |    9 ++++-----
 arch/x86/um/asm/checksum_32.h              |    2 +-
 arch/xtensa/include/asm/checksum.h         |   12 +++++-------
 include/asm-generic/checksum.h             |    8 ++++----
 include/net/ip6_checksum.h                 |    3 +--
 lib/checksum.c                             |    4 +---
 net/ipv4/udp_offload.c                     |   15 ++++++++++-----
 net/ipv6/ip6_checksum.c                    |    3 +--
 40 files changed, 137 insertions(+), 184 deletions(-)
