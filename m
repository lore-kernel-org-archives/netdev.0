From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/16][pull request] Intel Wired LAN Driver Updates 2015-02-05
Date: Thu,  5 Feb 2015 01:35:34 -0800
Message-ID: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55122 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750838AbbBEJgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:36:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k, ixgbe and ixgbevf.

Matthew fixes an issue where fm10k does not properly drop the upper-most four
bits on of the VLAN ID due to type promotion, so resolve the issue by not
masking off the bits, but by throwing an error if the VLAN ID is out-of-bounds.
Then cleans up two cases where variables were not being used, but were
being set, so just remove the unused variables.

Don cleans up sparse errors in the x550 family file for ixgbe.  Fixed up
a redundant setting of the default value for set_rxpba, which was done
twice accidentally.  Cleaned up the probe routine to remove a redundant
attempt to identify the PHY, which could lead to a panic on x550.  Added
support for VXLAN receive checksum offload in x550 hardware.  Added the
Ethertype Anti-spoofing feature for affected devices.

Emil enables ixgbe and ixgbevf to allow multiple queues in SRIOV mode.
Adds RSS support for x550 per VF.  Fixed up a couple of issues introduced
in commit 2b509c0cd292 ("ixgbe: cleanup ixgbe_ndo_set_vf_vlan"), fixed
setting of the VLAN inside ixgbe_enable_port_vlan() and disable the
"hide VLAN" bit in PFQDE when port VLAN is disabled.  Cleaned up the
setting of vlan_features by enabling all features at once.  Fixed the
ordering of the shutdown patch so that we attempt to shutdown the rings
more gracefully.  We shutdown the main Rx filter in the case of Rx and we
set the carrier_off state in the case of Tx so that packets stop being
delivered from outside the driver.  Then we shutdown interrupts and NAPI,
then finally stop the rings from performing DMA and clean them.  Added
code to allow for Tx hang checking to provide more robust debug info in
the event of a transmit unit hang in ixgbevf.  Cleaned up ixgbevf logic
dealing with link up/down by breaking down the link detection and up/down
events into separate functions, similar to how these events are handled
in other drivers.  Combined the ixgbevf reset and watchdog tasks into a
single task so that we can avoid multiple schedules of the reset task when
we have a reset event needed due to either the mailbox going down or
transmit packets being present on a link down.

The following are changes since commit db79a621835ee91d3e10177abd97f48e0a4dcf9b:
  vxlan: Only set has-GBP bit in header if any other bits would be set
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Don Skidmore (5):
  ixgbe: cleanup sparse errors in new ixgbe_x550.c file
  ixgbe: cleanup redundant default method set_rxpba
  ixgbe: Cleanup probe to remove redundant attempt to ID PHY
  ixgbe: add VXLAN offload support for X550 devices
  ixgbe: add Tx anti spoofing support

Emil Tantilov (9):
  ixgbe: allow multiple queues in SRIOV mode
  ixgbevf: enable multiple queue support
  ixgbevf: add RSS support for X550
  ixgbe: fix setting port VLAN
  ixgbevf: set vlan_features in a single write instead of several ORs
  ixgbevf: Fix ordering of shutdown to correctly disable Rx and Tx
  ixgbevf: Add code to check for Tx hang
  ixgbevf: rewrite watchdog task to function similar to igbvf
  ixgbevf: combine all of the tasks into a single service task

Matthew Vick (2):
  fm10k: Validate VLAN ID in fm10k_update_xc_addr_pf
  fm10k: Resolve compile warnings with W=1

 drivers/net/ethernet/intel/Kconfig                |  11 +
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c      |   5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c       |   7 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c      |   3 -
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 112 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  16 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  16 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c     |   3 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |  90 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  36 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 495 +++++++++++++++-------
 drivers/net/ethernet/intel/ixgbevf/regs.h         |  10 +
 13 files changed, 586 insertions(+), 221 deletions(-)

-- 
1.9.3
