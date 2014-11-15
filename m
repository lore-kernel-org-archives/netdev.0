From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Updates 2014-11-14
Date: Fri, 14 Nov 2014 22:08:23 -0800
Message-ID: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4893 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750855AbaKOGIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 01:08:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Shannon provides a patch to clean up the driver to only warn once that
PTP is not supported when linked at 100Mbps.

Mitch provides a fix for i40e where the VF interrupt processing takes
a long time and it is possible that we could lose a VFLR event if it
happens while processing a VFLR on another VF.  To correct this situation,
we enable the VFLR interrupt cause before we begin processing any pending
resets.

Serey provides a fix to handle the case where a single packet with more
than 8 data descriptors triggers a Malicious Driver Detect event in the
device.

Neerav provides several patches to update DCB support in i40e.  When
there are DCB configuration changes based on DCBx, the firmware suspends
the port's Tx and generates an event to the PF.  The PF is then
responsible to reconfigure the PF VSIs and switching topology as per the
updated DCB configuration and then resume the port's Tx by calling the
"Resume Port Tx" AQ command, so add this call to the flow that handles
DCB re-configuration in the PF.  Allow the driver to query and use DCB
configuration from firmware when firmware DCBx agent is in CEE mode.
Add a check whether LLDP Agent's default AdminStatus is enabled or
disabled on a given port, and sets DCBx status to disabled if the
status is disabled.  Fix an issue when the port TC configuration
changes as a result of DCBx and the driver modifies the enabled TCs for
the VEBs it manages but does not update the enabled_tc value that 
was cached on a per VEB basis.  Add a new PF state so that if a port's
Tx is in suspended state the Tx queue disable flow would just put the
request for the queue to be disabled and return without waiting for the
queue to be actually disabled.  Allows the driver to enable/disable
the XPS based on the number of TCs being enabled for the given VSI.

The following are changes since commit a77f9c5dcdf8480a93332792c336fa2bf9d31229:
  Revert "fast_hash: avoid indirect function calls"
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Catherine Sullivan (1):
  i40e: Bump version to 1.1.23

Mitch Williams (1):
  i40e: re-enable VFLR interrupt sooner

Neerav Parikh (8):
  i40e: Resume Port Tx after DCB event
  i40e: Add support to firmware CEE DCBX mode
  i40e: Check for LLDP AdminStatus before querying DCBX
  i40e: Update VEB's enabled_tc after reconfiguration
  i40e: Modify Tx disable wait flow in case of DCB reconfiguration
  i40e: Do not disable/enable FCoE VSI with DCB reconfig
  i40e: Prevent link flow control settings when PFC is enabled
  i40e: Set XPS bit mask to zero in DCB mode

Serey Kong (1):
  i40e: Handle a single mss packet with more than 8 frags

Shannon Nelson (1):
  i40e: only warn once of PTP nonsupport in 100Mbit speed

 drivers/net/ethernet/intel/i40e/i40e.h             |   1 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  45 +++-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  48 ++++
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         | 252 ++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_dcb.h         |   5 +
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  14 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 170 ++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   7 +
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  14 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  53 +++--
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  12 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  14 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   1 +
 18 files changed, 597 insertions(+), 64 deletions(-)

-- 
1.9.3
