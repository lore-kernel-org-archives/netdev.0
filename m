From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/21][pull request] 10GbE Intel Wired LAN Driver Updates 2017-01-03
Date: Tue,  3 Jan 2017 13:07:36 -0800
Message-ID: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25260 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752632AbdACVH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:07:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf only.

Emil fixes ixgbe to use the NVM settings for FEC, so do not override the
settings.  Fixed the indirection table for x550, where newer devices can
support up to 64 RSS queues.  Extends the rtnl_lock() to protect the call
to netif_device_detach() and ixgbe_clear_interrupt_scheme() to avoid
against a double free WARN and/or a BUG in free_msi_irqs().  Fixed AER
error handling by making sure that the driver frees the IRQs in
ixgbe_io_error_detected() when responding to a PCIe AER error, and to
restore them when the interface recovers.

Tony updates the driver to report the driver version to the firmware using
the host interface command for x550 devices.  Fixed the PHY reset check
for x550em_ext_t PHY type.  Fixed bounds checking for x540 devices to
ensure the index is valid for the LED function.  Fixed the BaseT adapters
which support 100Mb capability and were not reporting the capability.

Ken Cox adds a missing check for the trusted bit before trying to set the
MACVLAN MAC address.

Yusuke Suzuki fixes an issue with 82599 and x540 devices where receive
timestamps were not working becase the bitwise operation for RX_HWSTAMP
falg was incorrect.

Don ensures that x553 KR/KX devices correctly advertise link speeds.
Adds the mailbox message to allow for VF promiscuous mode support.

Mark fixes two issues with EEPROM access, where the semaphore was not
being held until the entire response was read and the acquiring/releasing
of the semaphore is slow.  Cleaned up firmware version method and
functions which are no longer used.  Added new interfaces for firmware
commands to access some new PHYs.

v2: fixed tab indentation in patch 12 and mis-spelled words in patch 15
    based on feedback from Sergei Shtylyov and Rami Rosen.

The following are changes since commit a88eb6becfa86fd0a05daed27957f5fcfff9f0e0:
  Merge branch 'tipc-link-starvation'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Don Skidmore (3):
  ixgbe: Configure advertised speeds correctly for KR/KX backplane
  ixgbevf: Add support for VF promiscuous mode
  ixgbe: Add PF support for VF promiscuous mode

Emil Tantilov (7):
  ixgbe: do not disable FEC from the driver
  ixgbe: add mask for 64 RSS queues
  ixgbe: handle close/suspend race with netif_device_detach/present
  ixgbevf: handle race between close and suspend on shutdown
  ixgbe: fix AER error handling
  ixgbevf: fix AER error handling
  ixgbevf: restore hw_addr on resume or error

Ken Cox (1):
  ixgbe: test for trust in macvlan adjustments for VF

Mark Rustad (4):
  ixgbe: Fix issues with EEPROM access
  ixgbe: Remove unused firmware version functions and method
  ixgbe: Implement firmware interface to access some PHYs
  ixgbe: Implement support for firmware-controlled PHYs

Tony Nguyen (5):
  ixgbe: Report driver version to firmware for x550 devices
  ixgbe: Fix check for ixgbe_phy_x550em_ext_t reset
  ixgbe: Add bounds check for x540 LED functions
  ixgbe: Reduce I2C retry count on X550 devices
  ixgbe: Fix reporting of 100Mb capability

Yusuke Suzuki (1):
  ixgbe: Fix incorrect bitwise operations of PTP Rx timestamp flags

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   5 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    |   2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |   2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c   | 113 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h   |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  | 153 +++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  92 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c      |  66 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h      |   4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c      |  12 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  50 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  90 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |  10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     | 594 +++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  66 ++-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |   1 +
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  24 +-
 20 files changed, 1101 insertions(+), 199 deletions(-)

-- 
2.9.3
