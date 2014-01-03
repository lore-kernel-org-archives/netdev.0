From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/11][pull request] Intel Wired LAN Driver Updates
Date: Thu,  2 Jan 2014 21:18:19 -0800
Message-ID: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48918 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbaACFSh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 00:18:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, e1000e and igb.

Most notable are the patches to add Live Error Recovery (LER)
support to the ixgbe driver. This support also improves behavior
in Thunderbolt environments. This involves checking all register
reads for a value of all one's and when that is seen, to read the
status register, which should never properly return all one's, to
confirm whether the received value was correct. When this detects
a removal, the hw_addr field is cleared to indicate the removal.
This then blocks subsequent access to the device registers.

The register access macros have been changed to static inline
functions and all register accesses now use them. A configuration
option is added to allow the LER feature to be disabled. The added
checks on register accesses results in a small increase in cpu 
utilization, so disabling the option makes it possible to avoid 
paying that price in environments that have no need for LER. The
option is enabled by default because the cost is not high and
it makes the driver more robust.

The __IXGBE_DOWN bit is no longer overloaded to also mean that
device removal has been initiated. Now the bit can be used to
protect ixgbe_down from multiple entry via test_and_set_bit. A
needed smp_mb__before_clear_bit was also added.

v2 Changes:
- Use ACCESS_ONCE where needed, thanks to Ben Hutchings
- Fix crash on module removal
- Use boolean values for boolean returns instead of 0 and 1
- Reword Kconfig help text

The following are changes since commit c1ddf295f5183a5189196a8035546842caa2055a:
  net: revert "sched classifier: make cgroup table local"
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Jeff Kirsher (1):
  igb: make local functions static and remove dead code

Mark Rustad (8):
  ixbge: Protect ixgbe_down with __IXGBE_DOWN bit
  ixgbe: Indicate removal state explicitly
  ixgbe: Use static inlines instead of macros
  ixgbe: Make ethtool register test use accessors
  ixgbe: Check register reads for adapter removal
  ixgbe: Check for adapter removal on register writes
  ixgbe: Additional adapter removal checks
  ixgbe: Add Live Error Recovery configuration option

Tom Herbert (2):
  net: e1000e calls skb_set_hash
  net: igb calls skb_set_hash

 drivers/net/ethernet/intel/Kconfig               |  11 +++
 drivers/net/ethernet/intel/e1000e/netdev.c       |   2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c     |   4 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h     |   2 -
 drivers/net/ethernet/intel/igb/e1000_i210.c      |  20 +++--
 drivers/net/ethernet/intel/igb/e1000_i210.h      |   9 --
 drivers/net/ethernet/intel/igb/e1000_phy.c       |  71 ---------------
 drivers/net/ethernet/intel/igb/e1000_phy.h       |   1 -
 drivers/net/ethernet/intel/igb/igb.h             |   2 -
 drivers/net/ethernet/intel/igb/igb_main.c        |   4 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c         |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  12 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  58 +++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 110 +++++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  82 ++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c     |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   2 +-
 17 files changed, 229 insertions(+), 170 deletions(-)

-- 
1.8.3.1
