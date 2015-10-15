From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] Intel Wired LAN Driver Updates 2015-10-15
Date: Thu, 15 Oct 2015 14:43:07 -0700
Message-ID: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32107 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbbJOVn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 17:43:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e, igb, igbvf, ixgbe, ixgbevf,
i40e, i40evf and fm10k.

Alex Duyck fixes the polling routine for i40e/i40evf were the NAPI budget
for receive cleanup was being rounded up to 1 but the netpoll call was
expecting no Rx to be processed as the budget passed was 0.  Also cleaned
up IN_NETPOLL flag that was not adding any value due to the receive
cleanup was handled in NAPI.  Added support for netpoll for i40evf as
well.

Jesse updates all of our drivers to use napi_complete_done() instead of
napi_complete(), which allows us to use
/sys/class/net/ethX/gro_flush_timeout.  Added ethtool support to control
and report the new Interrupt Limit register, since the XL710 hardware
has a different interrupt moderation design that can support a limit of
total interrupts per second per vector.

Shannon cleans up startup log entries to cut down the number by putting
a couple behind debug flags and combining others into single line.  Added
support to enable/disable printing VEB statistics via ethtool.

Jingjing fixes a compile issue by adding const to functions that return
strings that are not going to be modified.

Greg Rose cleans up defines that were not used and were causing customer
confusion.

Greg Bowers adds support for setting a new bit in the Set Local LLDP MIB
admin queue command Type field.

Mitch fixes an issue where vlan_features field was set to the same value
as netdev features field, but before the features were actually being
set up, leaving the vlan_features empty.  Resolve the issue by setting
up the netdev features first, then mask out the VLAN feature bits when
assigning vlan_features.  Fixed VF init timing, where in some instances
the VFs would fail to initialize the first time you loaded the driver.
To correct this, increased the delay time for the init task and wait
longer before giving up.

The following are changes since commit 96aec911482246a319bf457f39fa848ce436c8fd:
  amd-xgbe: Use system workqueue for device restart
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alexander Duyck (3):
  i40e/i40evf: Fix handling of napi budget
  i40e/i40evf: Drop useless "IN_NETPOLL" flag
  i40evf: Add support for netpoll

Catherine Sullivan (2):
  i40e: Recognize 1000Base_T_Optical phy type when link is up
  i40e/i40evf: Bump i40e to 1.3.34 and i40evf to 1.3.21

Greg Bowers (1):
  i40e: Add support for non-willing Apps

Greg Rose (1):
  i40e: Removed unused defines

Jesse Brandeburg (2):
  drivers/net/intel: use napi_complete_done()
  i40e/i40evf: moderate interrupts differently

Jingjing Wu (2):
  i40e/i40evf: Fix compile issue related to const string
  i40e: reset the invalid msg counter in vf when a valid msg is received

Mitch Williams (3):
  i40evf: correctly populate vlan_features
  i40evf: relax and stagger init timing a bit
  i40e: increase AQ work limit

Shannon Nelson (3):
  i40e: generate fewer startup messages
  i40e: remove read/write failed messages from nvmupdate
  i40e: priv flag for controlling VEB stats

 drivers/net/ethernet/intel/e1000/e1000_main.c      |  2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c      | 21 ++++++----
 drivers/net/ethernet/intel/i40e/i40e.h             |  9 ++--
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  7 ++++
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 49 ++++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 34 ++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 20 +++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        | 10 +++++
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  2 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  2 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  5 +--
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  4 +-
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |  4 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 20 +++++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      | 10 +++++
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  4 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 37 ++++++++++++++--
 drivers/net/ethernet/intel/igb/igb_main.c          | 17 +++++---
 drivers/net/ethernet/intel/igbvf/netdev.c          |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      | 14 ++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  | 14 ++++---
 26 files changed, 211 insertions(+), 92 deletions(-)

-- 
2.4.3
