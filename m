From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2017-08-12
Date: Sat, 12 Aug 2017 04:08:32 -0700
Message-ID: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54045 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750802AbdHLLIw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 07:08:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Jesse fixes two type mismatches, one where we were returning an enum type,
but pretending it was an integer.  The other was where we were using a
void* for offset math, but it is communicated more clearly to use a u8*,
which we can then cast to void* for prefetch to use.

Mitch adjusts the max packet size to account for two VLAN tags.

Sudheer provides a fix to ensure that the watchdog timer is scheduled
immediately after admin queue operations are scheduled in i40evf_down().
Fixes an issue by adding locking around the admin queue command and
update of state variables so that adminq_subtask will have the accurate
information whenever it gets scheduled.

Anjali fixes a bug where the PF flag setup should happen before the VMDq
RSS queue count is initialized for VMDq VSI to get the right number of
queues for RSS in the case of x722 devices.  Fixed a problem with the
hardware ATR eviction feature where the NVM setting was incorrect.

Jake separates the flags into two types, hw_features and flags.  The
hw_features flags contain a set of features which are enabled at init
time and will not contain feature flags that can be toggled.  Everything
else will remain in the flags variable, and can be modified anytime
during run time.  We should not be directly copying a cpumask_t, since
it is bitmap and might not be copied correctly, so use cpumask_copy()
instead.

Stefan Assmann makes vf _offload_flags more "generic" by renaming it to
vf_cap_flags, which allows other capabilities besides offloading to be
added.

Alan makes it such that if adaptive-rx/tx is enabled, the user cannot
make any manual adjustments to interrupt moderation.  Also makes it so
that if ITR is disabled by adaptive-rx/tx is then enabled, ITR will be
re-enabled.

The following are changes since commit aa69ff9e9c32db8aa84835baffea1b70c39e5112:
  liquidio: moved ptp_enable to octeon_device structure
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (2):
  i40evf: use netdev variable in reset task
  i40e: prevent changing ITR if adaptive-rx/tx enabled

Anjali Singhai Jain (2):
  i40e: Fix a bug with VMDq RSS queue allocation
  i40e: Detect ATR HW Evict NVM issue and disable the feature

Jacob Keller (6):
  i40e: separate hw_features from runtime changing flags
  i40e: remove workaround for Open Firmware MAC address
  i40e/i40evf: organize and re-number feature flags
  i40e/i40evf: use cmpxchg64 when updating private flags in ethtool
  i40e: move check for avoiding VID=0 filters into i40e_vsi_add_vlan
  i40e: use cpumask_copy instead of direct assignment

Jesse Brandeburg (1):
  i40e/i40evf: fix some minor type mismatches

Mitch Williams (1):
  i40e/i40evf: adjust packet size to account for double VLANs

Stefan Assmann (1):
  i40e/i40evf: rename vf_offload_flags to vf_cap_flags in struct
    virtchnl_vf_resource

Sudheer Mogilappagari (2):
  i40evf: prevent VF close returning before state transitions to DOWN
  i40e: synchronize nvmupdate command and adminq subtask

 drivers/net/ethernet/intel/i40e/i40e.h             | 101 +++++------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 154 +++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 188 ++++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |   6 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  30 ++--
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   5 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  44 ++---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  41 +++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  41 +++--
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   4 +-
 include/linux/avf/virtchnl.h                       |   4 +-
 16 files changed, 340 insertions(+), 299 deletions(-)

-- 
2.14.0
