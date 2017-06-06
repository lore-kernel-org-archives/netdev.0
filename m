From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] 1GbE Intel Wired LAN Driver Updates 2017-06-06
Date: Tue,  6 Jun 2017 01:57:58 -0700
Message-ID: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20068 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751243AbdFFI6O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 04:58:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates and fixes to e1000e and igb.

Matwey V Kornilov fixes an issue where igb_get_phy_id_82575() relies on
the fact that page 0 is already selected, but this is not the case after
igb_read_phy_reg_gs40g()/igb_write_phy_reg_gs40g() were removed in a
previous commit.  This leads to initialization failure and some devices
not working.  To fix the issue, explicitly select page 0 before first
access to PHY registers.

Arnd Bergmann modifies the driver to avoid a "defined but not used"
warning by removing #ifdefs and using __maybe_unused annotation instead
for new power management functions.

Jake provides most of the changes in the series, all around PTP and
timestamp fixes/updates.  Resolved several race conditions based on
the hardware can only handle one transmit timestamp at a time, so
fix the locking logic, as well as create a statistic for "skipped"
timestamps to help administrators identify issues.

Benjamin Poirier provides 2 changes, first to igb to remove the
second argument to igb_update_stats() since it always passes the
same two arguments.  So instead of having to pass the second argument,
just update the function to the necessary information from the adapter
structure.  Second modifies the e1000e_get_stats64() call to
dev_get_stats() to avoid ethtool garbage being reported.

Konstantin Khlebnikov modifies e1000e to use disable_hardirq(), instead
of disable_irq() for MSIx vectors in e1000_netpoll().

The following are changes since commit 9d15e5cc8cb68326f7f89b76e04c834fe8e1a2db:
  mdio: mux: fix an incorrect less than zero error check using a u32
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Arnd Bergmann (1):
  igb: mark PM functions as __maybe_unused

Benjamin Poirier (2):
  igb: Remove useless argument
  e1000e: Don't return uninitialized stats

Jacob Keller (6):
  e1000e: fix race condition around skb_tstamp_tx()
  igb: fix race condition with PTP_TX_IN_PROGRESS bits
  igb: avoid permanent lock of *_PTP_TX_IN_PROGRESS
  e1000e: add statistic indicating number of skipped Tx timestamps
  igb: add statistic indicating number of skipped Tx timestamps
  igb: check for Tx timestamp timeouts during watchdog

Konstantin Khlebnikov (1):
  e1000e: use disable_hardirq() also for MSIX vectors in e1000_netpoll()

Matwey V Kornilov (1):
  igb: Explicitly select page 0 at initialization

 drivers/net/ethernet/intel/e1000e/e1000.h    |  1 +
 drivers/net/ethernet/intel/e1000e/ethtool.c  |  3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c   | 39 ++++++++++++--------
 drivers/net/ethernet/intel/igb/e1000_82575.c |  1 +
 drivers/net/ethernet/intel/igb/igb.h         |  4 ++-
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  3 +-
 drivers/net/ethernet/intel/igb/igb_main.c    | 54 ++++++++++++++++------------
 drivers/net/ethernet/intel/igb/igb_ptp.c     | 41 +++++++++++++++++++--
 8 files changed, 103 insertions(+), 43 deletions(-)

-- 
2.12.2
