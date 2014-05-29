From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Thu, 29 May 2014 08:10:01 -0700
Message-ID: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51814 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756104AbaE2PKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Kevin updates the i40e and i40evf driver i40e_check_asq_alive() to ensure
the length register offset is non-zero which indicates that the software
has initialized the admin queue.  Also removes PCTYPE definitions which are
now reserved.

Mitch enables descriptor prefetch for rings belonging to the virtual function.
Also configures the VF minimum transmit rate to 50 Mbps rather than 0 which was
be interpreted as no limit at all.  Mitch found in order for the VF to achieve
its programmed transmit rate, we need to set the max credit value to 4.
Lastly fixes a Tx hang and firmware crash that happens after setting the MTU
on a VF by not using the RESETTING state during reinit, this is because
the RESETTING state means that a catastrophic hardware bad thing is happening
and the driver needs to tiptoe around and not use the admin queue or registers.
A reinit is no big deal and we can use the admin queue (and we should) so
do not set the state to RESETTING during reinit to resolve the bug.

Akeem changes the declaration of the transmit and receive rings inside
several loops to eliminate declaring the same ring every time for the
duration of the loop and declares them just once before the loop.  Also fixes
the driver to clear the recovery pending bit if pf_reset fails instead of
falling through the setup process.

Anjali makes a change based on feedback from Ben Hutchings that cmd->data
needs to be reported in ETHTOOL_GRXCLSRLCNT and use a helper function to
calculate the total filter count.

Jesse removes storm control since the storm control features are not apart
of the hardware and were mistakenly left in the code.

Greg changes tx_lpi_status and rx_lpi_status from bool to u32 to avoid
sparse errors.

Shannon adds the clear_pxe AdminQ API call to tell the firmware that the
driver is taking over from PXE.  In addition, relaxes the firmware API
check to allow more flexibility in handling newer NICs and NVMs in the field.

Vasu ensures that FCoE is disabled for MFP modes since it is not supported
by overriding the hardware FCoE capability.

The following are changes since commit 6623b4194459c07859d3e3196c3994fa7be5b88e:
  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (2):
  i40e: Tx/Rx rings declaration
  i40e: Clear recovery pending, if reset failed

Anjali Singhai Jain (2):
  i40e: Report cmd->data in ETHTOOL_GRXCLSRLCNT instead of
    ETHTOOL_GRXCLSRULE
  i40e: Use the new i40e_get_fd_cnt_all function in other places

Greg Rose (1):
  i40e/i40evf: Change type to u32 to avoid sparse error

Jesse Brandeburg (1):
  i40e/i40evf: remove storm control

Kevin Scott (2):
  i40e/i40evf: Update check for AQ aliveness
  i40e/i40evf: Remove reserved PCTYPE defines

Mitch Williams (4):
  i40e: enable descriptor prefetch for VFs
  i40evf: don't round Tx rate down to 0
  i40evf: tweak Tx rate params and de-magic-ify
  i40evf: don't use RESETTING state during reinit

Shannon Nelson (2):
  i40e: add clear_pxe AdminQ request
  i40e: relax the firmware API version check

Vasu Dev (1):
  i40: disable FCoE for MFP modes

 drivers/net/ethernet/intel/i40e/i40e.h             |  9 +++++
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  3 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 42 +++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 37 +++++++------------
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 19 +++++-----
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_register.h    |  4 ---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 33 +++++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  7 +---
 drivers/net/ethernet/intel/i40e/i40e_type.h        | 14 +++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 13 +++++--
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  6 +++-
 drivers/net/ethernet/intel/i40evf/i40e_register.h  |  4 ---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  7 +---
 drivers/net/ethernet/intel/i40evf/i40e_type.h      | 14 +++-----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  2 --
 16 files changed, 116 insertions(+), 100 deletions(-)

-- 
1.9.3
