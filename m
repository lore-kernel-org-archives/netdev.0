From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 28 Aug 2010 15:23:49 -0700 (PDT)
Message-ID: <20100828.152349.112606342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831Ab0H1WXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 18:23:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Anton Blanchard discovered two flaws in how we handle TCP orphan
   overflows.

   First, since the orphan overflow check uses the weak percpu_counter
   read percpu_counter_read_positive(), it can be off by as much as
   the percpu batch factor (default of 32) and the number of online
   cpus (128 in his case).  This total is 4096 which as it turns out
   is also the default orphan limit for his memory configuration :-)

   Fix this by doing the accurate, but more expensive
   percpu_counter_sum_positive(), check if the weak and potentially
   inaccurate one triggers.

   Next, he and Eric Dumazet noticed that the orphan and two other
   sysctl limits were bogusly calculated.  It had a 4096 constant in
   there (meant to be PAGE_SIZE) and furthermore it used the total
   size of a hash table (which is variable based upon lock debugging
   options etc.) instead of something more meaningful and consistent
   such as the number of hash slots.  Fix written by Eric Dumazet
   based work by Anton and myself.

2) AX25 drops socket reference too early, from Bernard Pidoux.

3) pxa168_eth fixes from Dan Carpenter.  First, phy_mii_ioctl() args
   changed, but pxa168 was not updated.  Also error handling in driver
   probe was busted.

4) Memory leak fix in bridge netfilter from Changli Gao.

5) qlge needs to reset chip before we free up the buffers which the
   chip is potentially still DMA'ing to/from.  Fix from Breno Leitao.

6) If the send side of a socket is shutdown, TCP's poll should indicate
   all the write conditions since the next sendmsg() is going to
   return -EPIPE and the application is not always able to discern this
   case completely on it's own.

   This matches the behavior of BSD (see so_writable() macro definition)
   as well as pretty much every other system checked.

   Fix from KOSAKI Motohiro.

7) 3c59x using netpoll deadlocks, fix from Neil Horman.

8) TCP congestion control core has a kstrdup memory leak, fix from
   Julia Lawall.

9) CAIF protocol needs to use correct unaligned.h header, from Jeff
   Mahoney.

10) l2tp input needs to scrutinize available of ethernet header more
    strictly, since the 'data_len' passed into it comes from potentially
    untrusted sources.  Fix from Eric Dumazet.

Please pull, thanks a lot!

The following changes since commit 303fd2c2ce5addef1aacac962a5b099cc0af71ea:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/vapier/blackfin (2010-08-28 14:24:49 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Anton Vorontsov (1):
      phylib: Fix race between returning phydev and calling adjust_link

Bernard Pidoux F6BVP (1):
      ax25: missplaced sock_put(sk)

Breno Leitao (1):
      qlge: reset the chip before freeing the buffers

Changli Gao (1):
      bridge: netfilter: fix a memory leak

Dan Carpenter (4):
      pxa168_eth: remove unneeded null check
      pxa168_eth: fix error handling in prope
      pxa168_eth: update call to phy_mii_ioctl()
      pxa168_eth: silence gcc warnings

David S. Miller (1):
      tcp: Combat per-cpu skew in orphan tests.

Eric Dumazet (2):
      tcp: fix three tcp sysctls tuning
      l2tp: test for ethernet header in l2tp_eth_dev_recv()

Heiko Carstens (1):
      caif-driver: add HAS_DMA dependency

Jeff Mahoney (1):
      net/caif/cfrfml.c: use asm/unaligned.h

Julia Lawall (1):
      net/ipv4: Eliminate kstrdup memory leak

KOSAKI Motohiro (1):
      tcp: select(writefds) don't hang up when a peer close connection

Neil Horman (1):
      3c59x: Fix deadlock between boomerang_interrupt and boomerang_start_tx

Yinglin Luan (2):
      netxen: fix poll implementation
      qlcnic: fix poll implementation

 drivers/net/3c59x.c                  |   15 ++++++++-
 drivers/net/caif/Kconfig             |    2 +-
 drivers/net/netxen/netxen_nic_main.c |    9 +++++-
 drivers/net/phy/phy_device.c         |    2 +
 drivers/net/pxa168_eth.c             |   58 ++++++++++++++++-----------------
 drivers/net/qlcnic/qlcnic_main.c     |    9 +++++-
 drivers/net/qlge/qlge_main.c         |    4 +-
 include/net/tcp.h                    |   18 ++++++++--
 net/ax25/ax25_ds_timer.c             |    2 +-
 net/bridge/br_netfilter.c            |    2 +-
 net/caif/cfrfml.c                    |    2 +-
 net/ipv4/tcp.c                       |   32 ++++++-------------
 net/ipv4/tcp_cong.c                  |    5 ++-
 net/ipv4/tcp_timer.c                 |    8 ++--
 net/l2tp/l2tp_eth.c                  |    2 +-
 15 files changed, 98 insertions(+), 72 deletions(-)
