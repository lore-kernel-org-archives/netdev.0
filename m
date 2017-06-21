From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2017-06-20
Date: Tue, 20 Jun 2017 18:17:47 -0700
Message-ID: <20170621011802.81768-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:40195 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753016AbdFUBSH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 21:18:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Björn adds additional XDP support for i40e, by adding pass and drop actions
and XDP_TX action support.

Jake fixes a possible NULL pointer dereference in
i40evf_get_ethtool_stats() which could occur if the VF fails to recover
from a reset, and then a user requests statistics.  Changed the use of
dev_info() to dev_dbg() for vf_capability client routine so that the
standard log is not spammed with this information which "might" cause
administrators to worry.  Also added more code comments to help explain
why udp_port has be in host byte order and to avoid future changes which
may cause this to break.  Fixed the holding of the RTNL lock for the
entire reset routine, reduced the scope so that the reset function will
handle its own lock, so that we do not have to wrap every reference
to i40e_do_reset() with RTNL lock/unlock.

Alice updates flags related to firmware interactions for WoL and admin
queue command address with the correct value.

Sudheer makes a fix to ensure that the array is not accessed past the
size of the array.

Greg fixes the parsing of firmware 4.33 admin queue commmand "Get CEE
DCBX PER CFG" because the firmware now creates the oper_prio_tc nibbles
reversed from those in the CDD Priority Group sub-TLV.

Carolyn adds a check and message to let users know that when in MFP mode,
changing RSS hash input set is not supported.

Shannon makes the partition bandwidth control more generic since it is not
in just one form of multi-function partitioning (MFP).  Also fixes a bug
which was causing the firmware confusion in some reset sequences, when
we were disabling interrupts and we were clearing the whole register.
Instead we should only be clearing the CAUSE_ENA bit when disabling
interrupts.

Filip adds support for OEM firmware version, so that if a OEM specific
adapter is detected, ethtool reports the OEM product version in the
firmware version string instead of etrack id.

Alan fixes a bug where the driver was not correctly exiting overflow
promiscuous mode, which can happen if "too many" MAC filters are added,
putting the driver into overflow promiscuous mode, and the filters are
then removed.  The bug occurs because the conditional for toggling
promiscuous mode was only be executed when enabled and not when it was
disabled.

The following are changes since commit f5c306470ed0a8f03ba7017f397da2555b5800d4:
  Merge tag 'mlx5-updates-2017-06-20' of git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (1):
  i40e: fix disabling overflow promiscuous mode

Alice Michael (1):
  i40e/i40evf: update WOL and I40E_AQC_ADDR_VALID_MASK flags

Björn Töpel (2):
  i40e: add XDP support for pass and drop actions
  i40e: add support for XDP_TX action

Carolyn Wyborny (1):
  i40e: Add message for unsupported MFP mode

Catherine Sullivan (1):
  i40e: Handle PE_CRITERR properly with IWARP enabled

Filip Sadowski (1):
  i40e: Add support for OEM firmware version

Greg Bowers (1):
  i40e: Support firmware CEE DCB UP to TC map re-definition

Jacob Keller (4):
  i40evf: assign num_active_queues inside i40evf_alloc_queues
  i40e: use dev_dbg instead of dev_info when warning about missing
    routine
  i40e: comment that udp_port must be in host byte order
  i40e: don't hold RTNL lock for the entire reset

Shannon Nelson (2):
  i40e: genericize the partition bandwidth control
  i40e: clear only cause_ena bit

Sudheer Mogilappagari (1):
  i40e: Fix potential out of bound array access

 drivers/net/ethernet/intel/i40e/i40e.h             |  69 ++-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_client.c      |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         |  15 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  48 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 524 ++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 244 ++++++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  12 +
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |   5 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  18 +-
 11 files changed, 746 insertions(+), 205 deletions(-)

-- 
2.12.2
