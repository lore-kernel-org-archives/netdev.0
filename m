From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 24 Jun 2009 00:43:17 -0700 (PDT)
Message-ID: <20090624.004317.71339627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, kaber@trash.net
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56867
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755556AbZFXHnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 03:43:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[ Ingo, the top of this pull request is commit
  7959ea254ed18faee41160b1c50b3c9664735967, so you can use
  that to know when to start checking to see if your netfilter
  crashes are fixed. ]

1) Drivers like DJA1000 and KS8842 cannot compile on platforms like
   s390, make them depen on HAS_IOMEM.  From Heiko Carstnes.

2) NETXEN build fix, and a fix for firmware handshaking, from
   Dhananjay Phadke.

3) The ipv6 layers pass ICMP6 type and code fields around as
   ints, which is silly.  When those values are use to index
   tables, because they are int's, it looks like out-of-range
   access are possible so people send "fixes" for that.

   Fix it right by using "u8" consistently as the type to pass
   these values around.  From Brian Haley.

4) Unconditional skb_orphan() call in netif_receive_skb() created
   regressions in protocols such as CAN which expect skb->sk and
   destructors to survive from transmit back to receive into
   their stack.  Fix from Herbert Xu.

5) Netfilter fixes via Patrick McHardy.  In particular fixes for
   crashes reported by Ingo Molnar that were due to various races.

6) Another routing fix from Neil Horman based upon suggestions by
   Alexey Kuznetsov.  When we decide to not cache, we would leak
   the route.

7) Before being brought up, bnx2 devices report incorrect link state.
   Fix from Ooiwa Naohiro.

8) qla3xxx bug fixes from Ron Mercer.  Sleep while holding spinlock
   and missing delay after PHY reset.

Please pull, thanks a lot!

The following changes since commit 4e8a2372f9255a1464ef488ed925455f53fbdaa1:
  Mikael Pettersson (1):
        nvidiafb: fix boot-time printk string

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git master

Brian Haley (1):
      ipv6: Use correct data types for ICMPv6 type and code

Dhananjay Phadke (2):
      netxen: fix build with without CONFIG_PM
      netxen: fix firmware init handshake

Eric Dumazet (1):
      netfilter: nf_conntrack: death_by_timeout() fix

Heiko Carstens (2):
      can: let SJA1000 driver depend on HAS_IOMEM
      net: let KS8842 driver depend on HAS_IOMEM

Herbert Xu (1):
      net: Move rx skb_orphan call to where needed

Jan Engelhardt (1):
      netfilter: xt_quota: fix incomplete initialization

Neil Horman (1):
      ipv4 routing: Ensure that route cache entries are usable and reclaimable with caching is off

Ooiwa Naohiro (1):
      bnx2: Fix the behavior of ethtool when ONBOOT=no

Patrick McHardy (5):
      netfilter: nf_conntrack: fix confirmation race condition
      netfilter: nf_conntrack: fix conntrack lookup race
      netfilter: fix some sparse endianess warnings
      netfilter: nf_log: fix direct userspace memory access in proc handler
      netfilter: xt_rateest: fix comparison with self

Ron Mercer (2):
      qla3xxx: Give the PHY time to come out of reset.
      qla3xxx: Don't sleep while holding lock.

 drivers/net/Kconfig                  |    1 +
 drivers/net/bnx2.c                   |   10 ++++++++-
 drivers/net/can/Kconfig              |    2 +-
 drivers/net/netxen/netxen_nic_init.c |   37 ++++++++++++++++++---------------
 drivers/net/netxen/netxen_nic_main.c |    7 +++++-
 drivers/net/qla3xxx.c                |    6 ++++-
 include/linux/icmpv6.h               |    6 ++--
 include/net/protocol.h               |    2 +-
 include/net/rawv6.h                  |    2 +-
 include/net/sctp/sctp.h              |    1 +
 include/net/sock.h                   |    2 +
 include/net/xfrm.h                   |    2 +-
 net/ax25/ax25_in.c                   |    3 +-
 net/core/dev.c                       |    2 -
 net/dccp/ipv6.c                      |    2 +-
 net/ipv4/route.c                     |   26 +++++++++++++++++++++--
 net/ipv6/ah6.c                       |    2 +-
 net/ipv6/esp6.c                      |    2 +-
 net/ipv6/icmp.c                      |   12 +++++-----
 net/ipv6/ip6_tunnel.c                |   18 ++++++++--------
 net/ipv6/ipcomp6.c                   |    2 +-
 net/ipv6/mip6.c                      |    2 +-
 net/ipv6/raw.c                       |    4 +-
 net/ipv6/route.c                     |    2 +-
 net/ipv6/tcp_ipv6.c                  |    2 +-
 net/ipv6/tunnel6.c                   |    2 +-
 net/ipv6/udp.c                       |    6 ++--
 net/ipv6/udp_impl.h                  |    2 +-
 net/ipv6/udplite.c                   |    2 +-
 net/ipv6/xfrm6_tunnel.c              |    2 +-
 net/irda/af_irda.c                   |    3 --
 net/irda/ircomm/ircomm_lmp.c         |    1 +
 net/netfilter/nf_conntrack_core.c    |   25 ++++++++++++++++++----
 net/netfilter/nf_log.c               |   16 ++++++++++----
 net/netfilter/xt_NFQUEUE.c           |    8 +++---
 net/netfilter/xt_cluster.c           |    8 +++---
 net/netfilter/xt_quota.c             |    1 +
 net/netfilter/xt_rateest.c           |    2 +-
 net/sctp/ipv6.c                      |    2 +-
 39 files changed, 149 insertions(+), 88 deletions(-)
