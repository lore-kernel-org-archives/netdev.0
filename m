From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2014-08-29
Date: Fri, 29 Aug 2014 02:30:05 -0700
Message-ID: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53234 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751006AbaH2JaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf, ixgbe and ixgbevf.

Catherine adds dual speed module support to i40e.  Updates i40e to allow
the user to change link settings when the link is down.

Serey renames i40e_ndo_set_vf_spoofck() to i40e_ndo_set_vf_spookchk()
to be more consistent with what is defined in netdev and removes a
unnecessary variable assignment.

Jesse makes a malicious driver detection warning only print if extended
driver string is enabled for i40e.  Fixes a panic under traffic load when
resetting or if/whenever there was a Tx-timeout because we were enabling
the Tx queue to early.

Anjali fixes an issue when PF reset fails, where we were trying to restart
the admin queue which has not been setup at that point.  This resolves an
occasional kernel panic when PF reset fails for some reason.

Ethan Zhao replaces the use of a local i40e_vfs_are_assigned() with the
global kernel pci_vfs_assigned() for i40e.

Alex cleans up the FDB handling for ixgbe.  This change makes it so that
the behavior for FDB handling is consistent between both the SR-IOV and
non-SR-IOV cases.  The main change is that we perform bounds checking on
the number of SR-IOV addresses regardless of if SR-IOV is enabled or not
as we can only support a certain number of addresses in the hardware.

Emil extends the pending Tx work check to the VF interfaces, where the
driver initiates a reset of the interface on link loss with pending Tx
work in order to clear the rings.  Introduces a delay for 82599 VFs of
at least 500 usecs to make sure the VFLINKS value is correct, since this
bit tends to flap when a DA or SFP+ cable is disconnected.

Jacob adds code comments in ixgbe to make it more obvious that we are
resetting features based on the fact that we do not have MSI-X enabled,
and cannot use the previous settings.  Also resolves a kernel NULL
pointer dereference by limiting the combined total of MACVLAN and
SR-IOV VFs, since the hardware has a limited number of pools available
(64).  Previously, no checks were in place to limit the number of
accelerated MACVLAN devices based on the number of pools, which would
be ok since there was already a limit for these well below the number of
available pools.  However, SR-IOV uses the very same pools, therefore
we need to ensure that the total number of pools does not exceed the
number of pools available in the hardware.

The following are changes since commit a3bf5c429eb5f5ec4d364d51dfa8855efcc005f8:
  r8169: add missing MODULE_FIRMWARE.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (1):
  ixgbe: Cleanup FDB handling code

Anjali Singhai Jain (1):
  i40e: Fix an issue when PF reset fails

Catherine Sullivan (4):
  i40e: Add dual speed module support
  i40e: Allow user to change link settings if link is down
  i40e: Tell OS link is going down when calling set_phy_config
  i40e/i40evf: Bump i40e/i40evf versions

Emil Tantilov (2):
  ixgbe: reset interface on link loss with pending Tx work from the VF
  ixgbevf: introduce delay for checking VFLINKS on 82599

Ethan Zhao (1):
  i40e: use global pci_vfs_assigned() to replace local
    i40e_vfs_are_assigned()

Jacob Keller (2):
  ixgbe: add comment noting recalculation of queues
  ixgbe: limit combined total of macvlan and SR-IOV VFs

Jesse Brandeburg (2):
  i40e: make warning less verbose
  i40e: fix panic due to too-early Tx queue enable

Serey Kong (2):
  i40e: Change wording to be more consistent
  i40e: Remove unnecessary assignment

 drivers/net/ethernet/intel/i40e/i40e.h             |  1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 55 +++++++------
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 45 +++++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 36 +-------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |  8 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 96 ++++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c     | 14 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |  7 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c            | 15 ++++
 12 files changed, 156 insertions(+), 127 deletions(-)

-- 
1.9.3
