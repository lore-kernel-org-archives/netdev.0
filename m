From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/20][pull request] 40GbE Intel Wired LAN Driver Updates 2016-02-03
Date: Thu,  4 Feb 2016 03:48:51 -0800
Message-ID: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34313 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933831AbcBDLtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Kiran adds the MAC filter element to the end of the list instead of HEAD
just in case there are ever any ordering issues in the future.

Anjali fixes several RSS issues, first fixes the hash PCTYPE enable for
X722 since it supports a broader selection of PCTYPES for TCP and UDP.
Then fixes a bug in XL710, X710, and X722 support for RSS since we cannot
reduce the 4-tuple for RSS for TCP/IPv4/IPv6 or UDP/IPv4/IPv6 packets
since this requires a product feature change coming in a later release.
Cleans up the reset code where the restart-autoneg workaround is
applied, since X722 does not need the workaround, add a flag to indicate
which MAC and firmware version require the workaround to be applied.
Adds new device id's for X722 and code to add their support.  Also
adds another way to access the RSS keys and lookup table using the admin
queue for X722 devices.

Catherine updates the driver to replace the MAC check with a feature
flag check for 100M SGMII, since it is only support on X722 devices
currently.

Mitch reworks the VF driver to allow channel bonding, which was not
possible before this patch due to the asynchronous nature of the admin
queue mechanism.  Also fixes a rare case which causes a panic if the
VF driver is removed during reset recovery, resolve this by setting the
ring pointers to NULL after freeing them.

Shannon cleans up the driver where device capabilities were defined in
two different places, and neither had all the definitions, so he
consolidates the definitions in the admin queue API.  Also adds the new
proxy-wake-on-lan capability bit available with the new X722 device.
Lastly, added the new External Device Power Ability field to the
get_link_status data structure by using a reserved field at the end
of the structure.

Jesse mimics the ixgbe driver's use of a private work queue in the i40e
and i40evf drivers to avoid blocking the system work queue.

Greg cleans up the driver to limit the firmware revision checks to
properly handle DCB configurations from the firmware to the older
devices which need these checks (specifically X710 and XL710 devices
only).

The following are changes since commit b45efa30a626e915192a6c548cd8642379cd47cc:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Anjali Singhai Jain (6):
  i40e/i40evf: Fix RSS rx-flow-hash configuration through ethtool
  i40e: Cleanup the code with respect to restarting autoneg
  i40e: add new device IDs for X722
  i40e: Extend ethtool RSS hooks for X722
  i40e/i40evf: Fix for UDP/TCP RSS for X722
  i40evf: add new write-back mode

Catherine Sullivan (3):
  i40e: Replace X722 mac check in ethtool get_settings
  i40e: bump version to 1.4.10
  i40e: add 100Mb ethtool reporting

Greg Bowers (1):
  i40e: Limit DCB FW version checks to X710/XL710 devices

Jesse Brandeburg (2):
  i40e: update features with right offload
  i40e/i40evf: Use private workqueue

Kiran Patil (1):
  i40e: Add mac_filter_element at the end of the list instead of HEAD

Mitch Williams (2):
  i40evf: allow channel bonding of VFs
  i40evf: null out ring pointers on free

Shannon Nelson (5):
  i40e: define function capabilities in only one place
  i40e: add new proxy-wol bit for X722
  i40e: AQ Add Run PHY Activity struct
  i40e: AQ Geneve cloud tunnel type
  i40e: AQ Add external power class to get link status

 drivers/net/ethernet/intel/i40e/i40e.h             |  2 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 26 +++++-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 87 +++++++------------
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         | 12 +--
 drivers/net/ethernet/intel/i40e/i40e_devids.h      |  2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 38 ++++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 99 +++++++++++++++++++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 12 +++
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 26 +++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 16 ++++
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 57 ++++++-------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 34 ++++++--
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  2 +
 14 files changed, 283 insertions(+), 131 deletions(-)

-- 
2.5.0
