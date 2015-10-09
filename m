From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] Intel Wired LAN Driver Updates 2015-10-08
Date: Thu,  8 Oct 2015 18:32:38 -0700
Message-ID: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17941 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261AbbJIBc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only (again).

Jesse fixes an issue where the driver was issuing a WARN_ON during ring
size changes because the code was cloning the rx_ring struct but not
zeroing out the pointers before allocating new memory, so simply zero
out the pointers.  Also reduced the function call overhead by moving
the interrupt enable function by moving it to the header file, which it
in turn allows us to inline it.  Also does a thorough job of code
cleanup to fix spaces after declarations, remove unnecessary braces
and breaks, remove another __func__ use and general code tidiness.

Mitch adds mover verbose error messages when the number of supported VFs
is reported in driver init and it different from the number reported in
config space.  Updated the VF driver to now detect a reset with the
VF_ARQLEN register since the enable bit is cleared when the VF is reset
and it stays cleared until the VF driver processes the reset and
re-enables the admin queue which is more reliable than using the
VFGEN_RSTAT as previously.

Neerav adds parsing for CEE DCBx TLVs from the LLDP MIB since there is
a need to get the CEE DesiredCfg Tx by firmware and DCB configuration
Rx from peer for debug and other application purposes.

Carolyn fixes a problem where the PF's Flow Director filter table would
have an entry that the hardware was unable to add, when this occurs an
invalid entry gets replayed and a valid one is lost.

Matt fixes an issue where multiple link up messages can be logged
resulting from admin queue link status timing when link properties are
changed.

Shannon adds the ability to control the period link polling through
ethtool to be able to switch it off and on for debugging link issues.

Serey explicitly assigns the enum index for each VSI type so that the PF
and VF always reference to the same VSI type event if the enum lists
are different.

The following are changes since commit df718423250c000ca4323a767cedc2f3219b685c:
  Merge branch 'bpf_random32'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Carolyn Wyborny (1):
  i40e: Fix for extra Flow Director filter in table after error

Greg Bowers (1):
  i40e: Support FW CEE DCB UP to TC map nibble swap

Jesse Brandeburg (5):
  i40e: fix erroneous WARN_ON
  i40e: inline interrupt enable
  i40e/i40evf: clean up some code
  i40e: refactor code to remove indent
  i40e: print neato new features

Matt Jared (1):
  i40e: Fix multiple link up messages

Mitch Williams (4):
  i40e: add more verbose error messages
  i40evf: detect reset more reliably
  i40evf: use capabilities flags properly
  i40e/i40evf: pass QOS handle to VF

Neerav Parikh (2):
  i40e: Add parsing for CEE DCBX TLVs
  i40e/i40evf: Store CEE DCBX DesiredCfg and RemoteCfg

Serey Kong (1):
  i40e/i40evf: Explicitly assign enum index for VSI type

Shannon Nelson (1):
  i40e: add switch for link polling

 drivers/net/ethernet/intel/i40e/i40e.h             |  24 ++-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         | 236 +++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_dcb.h         |  39 ++++
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |   1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 124 ++++++-----
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  43 +++-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   1 -
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 164 +++++++-------
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |   3 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  21 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  23 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   8 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   6 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  21 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   5 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  46 ++--
 23 files changed, 567 insertions(+), 227 deletions(-)

-- 
2.4.3
