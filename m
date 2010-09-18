From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 17 Sep 2010 21:14:57 -0700 (PDT)
Message-ID: <20100917.211457.209584788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) A user reported that with 75 byte MSS and 75 byte advertised window
   (some strange embedded device), we packetize in TCP even when the
   full window is available.

   We do this as part of our SWS algorithm, and the logic makes sense
   when MSS is extremely large (say, 64K) but it doesn't have any
   value in this kind of case.

   So avoid the "bound by half of max window" logic when MSS is very
   small.

   Fix from Alexey N. Kuznetsov.

2) Non-linear SKBs are not handled properly by bonding.  From Andy
   Gospodarek.

3) LLC stores negative error codes in an unsinged short, and also
   has signed overflow issues in llc_ui_setsockopt().  From
   Dan Carpenter.

4) NULL deref in ppp_mp_explode(), also from Dan Carpenter.

5) Uninitialized memory reading fixes in USB/HSO, EQL, and
   CXGB3 network drivers.  All from Dan Rosenberg.

6) WOL handlers in 3c59x sleep in atomic, fix from Denis Kirjanov.

7) Fix NULL defer in sch_atm.

8) Add proper dependencies for CONFIG_RPS, otherwise architectures
   not using the generic SMP helpers won't build.

9) IP_NODEFRAG was mistakenly added with only a "setsockopt()"
   handler, add the trivial getsockopt() side.  From Michael Kerrisk.

10) PAL state machine missing an ops pointer validation on resume.
    From Simon Guinot.

11) Need to handle rxfifo errors on 8158 r8169 chips.  Fix by Matthew Garrett.

12) DCA needs to be disabled on some platforms, from Maciej Sosnowski.

13) SCTP remote oops from from Vlad Yasevich.

14) Fix RCU warnings in netpoll_rx(), from Herbert Xu.  More permanent
    long term cure coming from Paul E. McKenney.

15) Fix RCU locking in IPSEC output path, from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 03a7ab083e4d619136d6f07ce70fa9de0bc436fc:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.6 (2010-09-16 12:59:11 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Kuznetsov (1):
      tcp: Prevent overzealous packetization by SWS logic.

Andy Gospodarek (1):
      bonding: correctly process non-linear skbs

Bob Arendt (1):
      ipv4: force_igmp_version ignored when a IGMPv3 query received

Chris Snook (1):
      MAINTAINERS: move atlx discussions to netdev

Dan Carpenter (3):
      net/llc: make opt unsigned in llc_ui_setsockopt()
      ppp: potential NULL dereference in ppp_mp_explode()
      net/llc: storing negative error codes in unsigned short

Dan Rosenberg (3):
      drivers/net/usb/hso.c: prevent reading uninitialized memory
      drivers/net/eql.c: prevent reading uninitialized stack memory
      drivers/net/cxgb3/cxgb3_main.c: prevent reading uninitialized stack memory

David S. Miller (2):
      sch_atm: Fix potential NULL deref.
      net: RPS needs to depend upon USE_GENERIC_SMP_HELPERS

Denis Kirjanov (1):
      3c59x: Remove atomic context inside vortex_{set|get}_wol

Eric Dumazet (2):
      net: use rcu_barrier() in rollback_registered_many
      xfrm: dont assume rcu_read_lock in xfrm_output_one()

Herbert Xu (1):
      netpoll: Disable IRQ around RCU dereference in netpoll_rx

Matthew Garrett (1):
      r8169: Handle rxfifo errors on 8168 chips

Michael Kerrisk (1):
      ipv4: enable getsockopt() for IP_NODEFRAG

Simon Guinot (1):
      phylib: fix PAL state machine restart on resume

Sosnowski, Maciej (1):
      dca: disable dca on IOAT ver.3.0 multiple-IOH platforms

Vlad Yasevich (1):
      sctp: Do not reset the packet during sctp_packet_config().

 MAINTAINERS                    |    2 +-
 drivers/dca/dca-core.c         |   85 +++++++++++++++++++++++++++++++++++++---
 drivers/net/3c59x.c            |    7 +--
 drivers/net/bonding/bond_3ad.c |    3 +
 drivers/net/bonding/bond_alb.c |    3 +
 drivers/net/cxgb3/cxgb3_main.c |    2 +
 drivers/net/eql.c              |    2 +
 drivers/net/phy/mdio_bus.c     |    4 +-
 drivers/net/ppp_generic.c      |    9 +++-
 drivers/net/r8169.c            |    5 +-
 drivers/net/usb/hso.c          |    2 +
 include/linux/netpoll.h        |    8 ++--
 include/net/tcp.h              |   18 +++++++-
 net/Kconfig                    |    2 +-
 net/core/dev.c                 |    2 +-
 net/ipv4/igmp.c                |    2 +-
 net/ipv4/ip_sockglue.c         |    3 +
 net/llc/af_llc.c               |    3 +-
 net/llc/llc_station.c          |    2 +-
 net/sched/sch_atm.c            |    4 --
 net/sctp/output.c              |    1 -
 net/xfrm/xfrm_output.c         |    2 +-
 22 files changed, 136 insertions(+), 35 deletions(-)
