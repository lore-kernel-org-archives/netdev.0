From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] Intel Wired LAN Driver Updates 2015-02-22
Date: Sun, 22 Feb 2015 19:25:28 -0800
Message-ID: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3456 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800AbbBWDZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2015 22:25:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e, igbvf, i40e and i40evf.

David adds support for i219 devices to the e1000e driver.

Jeff (me) provides two patches to cleanup igbvf, first cleans up the
whitespace issues found and the second cleans up the usage of msleep(),
min() and max() with usleep_range(), min_t() and max_t() respectively.

Kamil updates the shadow RAM read/write functions by refactoring them
to prepare for future work.

Shannon renames the debugfs command "clear_stats pf" to clear_stats port"
to clarify what the function really does.

Mitch refactors the receive routine, by splitting the receive hot path
code into two, one for packet split and one for single buffer, which
improves receive performance.  Disables NAPI polling sooner when closing
the interface to fix an occasional panic during close which was
caused by the driver trying to delete and clean rings at the same time.
Also refactors reset for i40evf, since a recent change to the shutdown
flow messed up the reset flow.  Since i40evf_down() now holds the
critical section lock, we cannot call it from the reset handler, which
also holds the lock.

Nicholas restricts the virtual channel opcodes should remain consistent
between updates to the opcode enum.

Neerav converts the VSI connection type to use a #define instead of
using a magic number.

Anjali updates the registers file to remove registers no longer available.
Also fixes the EMPR interrupt handling, so that we won't trigger another
EMPR when we receive an EMPR event.

Catherine cleans up the variable an_enable since it was set and never
used.

Greg fixes the netdev op that allows the operator to turn MAC/VLAN
spoof checking on and off so that it includes the flag for VLAN spoof
checking.

The following are changes since commit bb39b7433d1c652b3699a7b335e0ad91181b2b05:
  sunvnet: failed trigger should not cause BUG_ON()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (2):
  i40e/i40evf: i40e_register.h updates
  i40e: Fix the EMPR interrupt received handling

Catherine Sullivan (1):
  i40e/i40evf: Remove unused variable an_enable and function
    update_link_info

David Ertman (1):
  e1000e: initial support for i219

Greg Rose (1):
  i40e: Fix i40e_ndo_set_vf_spoofchk

Jeff Kirsher (2):
  igbvf: Fix code comments and whitespace
  igbvf: cleanup msleep() and min/max() usage

Kamil Krawczyk (1):
  i40e: update Shadow RAM read/write functions

Mitch Williams (4):
  i40e/i40evf: Refactor the receive routines
  i40evf: disable NAPI polling sooner
  i40evf: refactor reset
  i40evf: don't wait forever

Neerav Parikh (1):
  i40e: Use #define for the VSI connection type

Nicholas Nunley (1):
  i40e/i40evf: restrict VC opcodes to their initial values

Shannon Nelson (1):
  i40e: rename debugfs clear_stats option

Sravanthi Tangeda (1):
  i40e/i40evf: Bump Driver Versions

 drivers/net/ethernet/intel/e1000e/defines.h        |   1 +
 drivers/net/ethernet/intel/e1000e/e1000.h          |   2 +
 drivers/net/ethernet/intel/e1000e/ethtool.c        |   6 +-
 drivers/net/ethernet/intel/e1000e/hw.h             |   6 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c        | 770 +++++++++++++++++++--
 drivers/net/ethernet/intel/e1000e/ich8lan.h        |   9 +
 drivers/net/ethernet/intel/e1000e/netdev.c         |  50 +-
 drivers/net/ethernet/intel/e1000e/ptp.c            |   4 +-
 drivers/net/ethernet/intel/e1000e/regs.h           |   3 +
 drivers/net/ethernet/intel/i40e/i40e.h             |   1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  33 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  14 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  50 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  96 ++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   3 -
 drivers/net/ethernet/intel/i40e/i40e_register.h    |  50 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 419 ++++++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  17 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   1 -
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |  42 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_register.h  |  50 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 401 ++++++++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  17 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   1 -
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  42 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  63 +-
 drivers/net/ethernet/intel/igbvf/defines.h         | 128 ++--
 drivers/net/ethernet/intel/igbvf/ethtool.c         |  83 ++-
 drivers/net/ethernet/intel/igbvf/igbvf.h           | 103 ++-
 drivers/net/ethernet/intel/igbvf/mbx.c             |  21 +-
 drivers/net/ethernet/intel/igbvf/mbx.h             |  53 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          | 391 +++++------
 drivers/net/ethernet/intel/igbvf/regs.h            | 123 ++--
 drivers/net/ethernet/intel/igbvf/vf.c              |  43 +-
 drivers/net/ethernet/intel/igbvf/vf.h              |  83 ++-
 38 files changed, 2158 insertions(+), 1031 deletions(-)

-- 
1.9.3
