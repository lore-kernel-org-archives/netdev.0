From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/17][pull request] Intel Wired LAN Driver Updates 2015-03-03
Date: Tue,  3 Mar 2015 01:44:07 -0800
Message-ID: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7373 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbbCCJo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 04:44:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k, i40e and i40evf.

Matthew updates the fm10k driver by cleaning up code comments and whitespace
issues.  Also modifies the tunnel length header check, to make it more robust
by calculating the inner L4 header length based on whether it is TCP or UDP.
Implemented ndo_features_check() that allows drivers to report their offload
capabilities per-skb.

Neerav updates the i40e driver to skip over priority tagging if DCB is not
enabled.  Fixes an issue where the driver is not flushing out the
DCBNL app table for applications that are not present in the local DCBX
application configuration TLVs.  Fixed i40e where, in the case of MFP
mode, the driver was returning the incorrect number of traffic classes
for partitions that are not enabled for iSCSI.  Even though the driver
was not configuring these traffic classes in the transmit scheduler for
the NIC partitions, it does use this map to setup the queue mappings.

Shannon updates i40e/i40evf to include the firmware build number in the
formatted firmware version string.

Akeem adds a safety net (by adding a 'default' case) for the possible
unmatched switch calls.

Mitch updates i40e to not automatically disable PF loopback at runtime,
now that we have the functionality to enable and disable PF loopback.  This
fix cleans up a bogus error message when removing the PF module with VFs
enabled.  Adds a extra check to make sure that the indirection table
pointer is valid before dereferencing it.

Anjali enables i40e to enable more than the max RSS qps when running in a
single TC mode for the main VSI.  It is possible to enable as many as
num_online_cpus().  Adds a firmware check to ensure that DCB is disabled for
firmware versions older than 4.33.  Updates i40e/i40evf to add missing
packet types for VXLAN offload.  Updated i40e to be able to handle varying
RSS table size for each VSI, since all VSI's do not have the same RSS table
size.

v2: Dropped previous patch #9 "i40e/i40evf: Add capability to gather VEB
    per TC stats" since the stats should be in ethtool and not debugfs.

The following are changes since commit b898441f4ece44933af90b116b467f7864dd1ae7:
  Merge branch 'neigh_cleanups'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (1):
  i40e: Add safety net for switch calling

Anjali Singhai Jain (5):
  i40e: Enable more than 64 qps for the Main VSI
  i40e: Add FW check to disable DCB and wrap autoneg workaround with FW
    check
  i40e/i40evf: Add missing packet types for VXLAN encapsulated packet
    types
  i40e: Move RSS table size for VSIs to the VSI struct
  i40e: Fix RSS size at init since default num queue calculation has
    changed

Matthew Vick (3):
  fm10k: Modify tunnel length header check when offloading
  fm10k: Implement ndo_features_check
  fm10k: Resolve various spelling errors and checkpatch warnings

Mitch Williams (2):
  i40e: don't disable PF LB when disabling VFs
  i40evf: ethtool RSS fixes

Neerav Parikh (4):
  i40e: Skip the priority tagging if DCB is not enabled
  i40e: Fix issue with removal of apps from DBCNL app table
  i40e: Register DCBNL ops in MFP mode
  i40e: Only enable TC0 for NIC partition type

Shannon Nelson (1):
  i40e/i40evf: print FW build number in version string

Sravanthi Tangeda (1):
  i40e/i40evf: Bump versions

 drivers/net/ethernet/intel/fm10k/fm10k.h           |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_common.c    |  3 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c   |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c       |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c      | 39 +++++++---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c       | 20 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    | 19 ++++-
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c       |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c        | 23 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_tlv.c       |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h      |  5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c        | 14 ++--
 drivers/net/ethernet/intel/i40e/i40e.h             | 11 ++-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_adminq.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 12 ++-
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      | 13 ++--
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  8 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 87 +++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  1 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 13 +++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  8 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 14 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  2 +-
 26 files changed, 190 insertions(+), 115 deletions(-)

-- 
1.9.3
