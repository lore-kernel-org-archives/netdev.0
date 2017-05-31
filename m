From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] 40GbE Intel Wired LAN Driver Updates 2017-05-31
Date: Wed, 31 May 2017 03:48:47 -0700
Message-ID: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:32543 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdEaKtA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:49:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Jesse provides a couple of fixes, starting with cleaning up duplicate
lines of code.  Fixed a missing line which enables RSS as a negotiated
feature.  Since the VF does not have any way of reporting FCoE enabled,
so just force the code to always report FCoE as disabled.

Jake provides several fixes and changes, starting with fixing a race
condition in i40e.  The hardware has a limitation on transmit PTP packets,
which requires us to limit the driver to timestamping a single packet at
once.  This is done using a state bitlock which enforces that only one
timestamp request is honored at a time, unfortunately this suffers from
a race condition.  Fixed a corner case where we failed to cleanup the
bit lock after a failed transmit, and resulted in a state bit being
locked forever.  Added a new statistic which tracks when a transmit
timestamp request is skipped/ignored, since the driver can only handle
one transmit timestamp request at a time.

Christophe Jaillet fixes a NULL pointer dereference if kzalloc fails.

The following are changes since commit ffe406457753a7ca2061ecc8c4d3971623066911:
  bnxt_en: Fix xmit_more with BQL.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Christophe Jaillet (1):
  i40e: Check for memory allocation failure

Jacob Keller (5):
  i40e: fix race condition with PTP_TX_IN_PROGRESS bits
  i40e: avoid permanent lock of *_PTP_TX_IN_PROGRESS
  i40e: add statistic indicating number of skipped Tx timestamps
  i40e: use pf data structure directly in i40e_ptp_rx_hang
  i40e: check for Tx timestamp timeouts during watchdog

Jesse Brandeburg (3):
  i40evf: fix duplicate lines
  i40evf: fix merge error in older patch
  i40evf: disable unused flags

 drivers/net/ethernet/intel/i40e/i40e.h             |  5 ++-
 drivers/net/ethernet/intel/i40e/i40e_client.c      |  2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  3 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         | 48 +++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 28 ++++++++++---
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  3 +-
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  3 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  3 +-
 9 files changed, 77 insertions(+), 19 deletions(-)

-- 
2.12.2
