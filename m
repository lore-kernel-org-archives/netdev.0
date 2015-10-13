From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] Intel Wired LAN Driver Updates 2015-10-12
Date: Mon, 12 Oct 2015 22:53:01 -0700
Message-ID: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbbJMFxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf, ixgbe and fm10k.

Carolyn cleans up ndo_bridge_getlink() by flagging a parameter as
__always_unused, since it is never used.  Adds a member to the nvm_info
struct to store OEM version info to be output either by OID or ethtool.

Neerav cleans up a remaining bit shift to use BIT() macro.

Mitch fixes the i40evf driver to properly handle calls to its
ndo_set_mac_address() method.  It did not properly check to see if the
override would be allowed by the PF driver, and it never removed the old
address from its filter list.  Cleaned up the use of
i40e_enable_vf_mappings() in i40e_alloc_vfs(), since it is just redundant
since we already call it by i40e_reset_vf().  Fixed a possible panic
in some circumstances where the firmware may fail to allocate a VSI for
a VF by checking the return value from i40e_alloc_vf_res() and don't
try to configure the device further if it failed.

Greg fixes the parsing of CEE App TLVs so the caller does not have to
consider whether the App came from a CEE or IEEE DCBx negotiation.
Adds two new functions to support NFV which requires the ability to
steer packets to VSIs by VLAN tag alone while being in promiscuous mode
for multicast and unicast MAC address.

Shannon moves the device ids into a standalone file due to the desire
to write user-land drivers (and other requests) without needing the rest
of the include files.

Catherine adds the ability to save the module information from
get_phy_capabilities() to be used to determine which speeds the module
supports.  Also cleaned up the PHY structure by removing unused members
and add the ability to store the PHY capabilities reported by the
firmware.

Emil modifies ixgbe to ensure that flow control packets initiated by the
VF are dropped and reported as spoofed.

Jacob cleans up the fm10k driver to avoid buffer overflow by using
sprintf(), so convert to using snprintf().  Also fixed the use of an
enum as a boolean, so check for the actual value of NETREG_UNINITIALIZED
in case it ever changes from the current value of zero.

The following are changes since commit 0fa28877b26641cca56b607ccec1fcbda7ae09c6:
  net: HNS: fix MDIO dependencies
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Carolyn Wyborny (3):
  i40e: Make it clear a parameter is never used
  i40e/i40evf: Add info to nvm info struct for OEM version data
  i40e: update fw version text string per previous product formats

Catherine Sullivan (3):
  i40e/i40evf: Add module_types and update_link_info
  i40e/i40evf: Refactor PHY structure and add phy_capabilities enum
  i40e/i40evf: Bump i40e version to 1.3.25 and i40evf to 1.3.17

Emil Tantilov (1):
  ixgbe: add flow control ethertype to the anti-spoofing filter

Greg Bowers (1):
  i40e: Convert CEE App TLV selector to IEEE selector

Greg Rose (1):
  i40e: Add promiscuous on VLAN support

Jacob Keller (2):
  fm10k: use snprintf() instead of sprintf() to avoid buffer overflow
  fm10k: do not use enum as boolean

Mitch Williams (3):
  i40evf: properly handle ndo_set_mac_address calls
  i40e: remove redundant call
  i40e: don't panic on VSI allocation failure

Neerav Parikh (1):
  i40e: Use BIT() macro for priority map parsing

Shannon Nelson (2):
  i40e/i40evf: Add new link status defines
  i40e/i40evf: split device ids into a separate file

 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c   |   6 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c   |   8 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c      |   2 +-
 drivers/net/ethernet/intel/i40e/i40e.h             |  10 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  98 +++++++++-
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         |  18 +-
 drivers/net/ethernet/intel/i40e/i40e_devids.h      |  55 ++++++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 205 ++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  22 ++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   7 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  86 ++++++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  13 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |   4 +-
 drivers/net/ethernet/intel/i40evf/i40e_devids.h    |  55 ++++++
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  83 ++++++---
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  20 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  16 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |   4 +
 21 files changed, 539 insertions(+), 187 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_devids.h
 create mode 100644 drivers/net/ethernet/intel/i40evf/i40e_devids.h

-- 
2.4.3
