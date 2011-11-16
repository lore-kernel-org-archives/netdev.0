From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v6 0/9] net-sysfs+forcedeth: stats & debug enhancements
Date: Wed, 16 Nov 2011 14:15:06 -0800
Message-ID: <cover.1321481064.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These changes provide a new generic network tx_timeout sysfs queue
attribute and implement the ndo_get_stats64 API for forcedeth. They
also add a few more stats and debugging features for forcedeth. They
ensure that stats updates are correct in SMP systems, 32 or 64-bits.

Thanks to all the reviewers of the previous versions of this series!

Note: patch 1 is the cherry-pick of 898bdf2cb43e ("forcedeth: fix
stats on hardware without extended stats support")

Changes since v5:
  - get_stats64: back to using u64_stats_sync.h instead of atomic
    integers, but this time with 2 seqcounts: one for TX, one for RX

Changes since v4:
  - tx_timeout counter now a generic sysfs attribute. Credits to
    Stephen Hemminger for initial implementation
  - revert get_stats64 to using atomic variables: see
    http://patchwork.ozlabs.org/patch/125861/ for motivations
  - dropped patch "expose module parameters in /sys/module" for now: I
    will work on this later, following Stephen's recommendations
    (http://patchwork.ozlabs.org/patch/125862/).

Changes since v3:
  - updated get_stats64 + rx_dropped patches to use u64_stats_sync.h
  - dropped indentation "whitespace/indentation fixes" (included in
    get_stats64 api patch)

Changes since v2:
  - patch 1/9 is the cherry-pick of 898bdf2cb43e ("forcedeth: fix
    stats on hardware without extended stats support")
  - removed patch 5/10 "stats for rx_packets based on hardware
    registers" because packets&bytes stats are updated in software
    only (898bdf2cb43e)

Changes since v1:
  - patch 1/10 is the same as
    http://patchwork.ozlabs.org/patch/125017/ (targetting net)
  - other patches updated to take patch 1/10 into account
  - various commit message updates


Tested:
  ~150Mbps incoming TCP, ethtool -S in a loop, x86_64 16-way:
     tx_bytes: 5441989419
     rx_packets: 5439224
     tx_timeout: 0
     tx_packets: 5456705
     rx_bytes: 5566763850

Tested:
  pktgen + loopback report same RX/TX packets and bytes stats

Tested:
  tests above with Kconfig DEBUG_PAGEALLOC DEBUG_MUTEXES
  DEBUG_SPINLOCK LOCKUP_DETECTOR DEBUG_RT_MUTEXES DEBUG_LOCK_ALLOC
  PROVE_LOCKING DEBUG_ATOMIC_SLEEP DEBUG_STACK_USAGE DEBUG_KOBJECT
  DEBUG_VM DEBUG_LIST DEBUG_SG DEBUG_NOTIFIERS TEST_KSTRTOX
  STRICT_DEVMEM DEBUG_STACKOVERFLOW


############################################
# Patch Set Summary:

David Decotigny (6):
  net-sysfs: fixed minor sparse warning
  kbuild: document RPS/XPS network Kconfig options
  net: new counter for tx_timeout errors in sysfs
  forcedeth: implement ndo_get_stats64() API
  forcedeth: account for dropped RX frames
  forcedeth: stats updated with a deferrable timer

Mike Ditto (1):
  forcedeth: Add messages to indicate using MSI or MSI-X

Sameer Nanda (1):
  forcedeth: allow to silence "TX timeout" debug messages

david decotigny (1):
  forcedeth: fix stats on hardware without extended stats support

 drivers/net/ethernet/nvidia/forcedeth.c |  321 ++++++++++++++++++++++---------
 include/linux/netdevice.h               |   12 +-
 net/Kconfig                             |   22 ++-
 net/core/net-sysfs.c                    |   49 ++++--
 net/sched/sch_generic.c                 |    1 +
 5 files changed, 296 insertions(+), 109 deletions(-)

-- 
1.7.3.1
