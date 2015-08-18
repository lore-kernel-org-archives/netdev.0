From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-08-18
Date: Tue, 18 Aug 2015 14:09:07 -0700
Message-ID: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9866 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974AbbHRVJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, e100, e1000e and ixgbe.

Shota Suzuki provides a fix for a possible overflow in
igb_set_interrupt_capability() which leads to an oops.  When changing the
number of queues by "ethtool -L", set IGB_FLAG_QUEUE_PAIRS in the same
manner as when initializing the igb driver.

Vasily Averin provides a fix for a missing rtnl_unlock() for when we
error out due to not being able to allocate memory for our queues.

Stefan Assman provides a couple of fixes for igb/igbvf.  First changes
the igb driver in probe to simply call igb_enable_sriov() instead of
igb_sriov_reinit() since we are starting from scratch.  Then in igbvf,
fix the driver where it does not clear the buffer_info->dma in all
cases after calling dma_unmap_single(), which was found by changing the
MTU twice.

Richard Cochran implements the periodic output function using the
programmable clock outputs available in i210 when possible, falling
back to the target time for longer periods.

Todd adds support for the Marvell PHY 1512 which is required for i354
devices.  Then updates igb to make sure SR-IOV init uses the correct
number of queues, since recent changes could result in the PF holding
onto all of the queues.

Alex Williamson provides a fix in the case where a guest OS does not
support hot-unplug, so disable SR-IOV prior to unregister_netdev() to
avoid the problem.

Jia-Ju Bai provides several patches, first knocks some collecting dust
off an old e100 driver to add a check to avoid a null pointer
dereference.  Then cleans up a possible resource leak by releasing the
skb buffer allocated when the e100_xmit_prepare() runs into an issue
in the DMA mapping.  In igb, add a missing rtnl_unlock() for when we
error out due to igb_sriov_reinit() in the igb_init_interrupt_scheme().
Provides a e1000e fix, based on suggestions from Alex Duyck to move
head/tail register writing to e1000_configure_tx/rx() to avoid a
possible null pointer dereference (similar to igb driver).  Lastly,
fix a possible memory leak in igb_probe(), where the memory shadow_vfta
allocated by kcalloc in igb_sw_init() is not freed.

Mark simplifies port-specific macros for ixgbe by eliminating explicit
comparisons with 0 and enclose formal parameters in parens to eliminate
the risk of an operator precedence issue.

The following are changes since commit 61ed713bbb043f333ca9576c79a3d33d2ad17438:
  Merge branch 'drivers_iff_no_queue'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alex Williamson (1):
  igb: Teardown SR-IOV before unregister_netdev()

Jacob Keller (1):
  ixgbe: TRIVIAL fix up double 'the' and comment style

Jia-Ju Bai (5):
  e100: Add a check after pci_pool_create to avoid null pointer
    dereference
  e100: Release skb when DMA mapping is failed in e100_xmit_prepare
  igb: Fix a deadlock in igb_sriov_reinit
  e1000e: Modify Tx/Rx configurations to avoid null pointer dereferences
    in e1000_open
  igb: Fix a memory leak in igb_probe

Mark Rustad (1):
  ixgbe: Simplify port-specific macros

Richard Cochran (1):
  igb: implement high frequency periodic output signals

Shota Suzuki (1):
  igb: Fix oops caused by missing queue pairing

Stefan Assmann (2):
  igb: do not re-init SR-IOV during probe
  igbvf: clear buffer_info->dma after dma_unmap_single()

Todd Fujinaka (2):
  igb: add support for 1512 PHY
  igb: make sure SR-IOV init uses the right number of queues

Vasily Averin (1):
  igb: missing rtnl_unlock in igb_sriov_reinit()

 drivers/net/ethernet/intel/e100.c              | 12 +++-
 drivers/net/ethernet/intel/e1000e/netdev.c     | 24 +++----
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 20 +++++-
 drivers/net/ethernet/intel/igb/e1000_defines.h |  5 ++
 drivers/net/ethernet/intel/igb/e1000_phy.c     | 93 +++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igb/e1000_phy.h     |  1 +
 drivers/net/ethernet/intel/igb/e1000_regs.h    |  2 +
 drivers/net/ethernet/intel/igb/igb.h           |  1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |  5 +-
 drivers/net/ethernet/intel/igb/igb_main.c      | 38 ++++++++---
 drivers/net/ethernet/intel/igb/igb_ptp.c       | 72 ++++++++++++++------
 drivers/net/ethernet/intel/igbvf/netdev.c      |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  | 18 ++---
 14 files changed, 236 insertions(+), 59 deletions(-)

-- 
2.4.3
