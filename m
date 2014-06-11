From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2014-06-11
Date: Wed, 11 Jun 2014 09:33:09 -0700
Message-ID: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55587 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755568AbaFKQd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, i40e and i40evf.

Todd makes a change to igb to un-hide invariant returns by getting rid of
the E1000_SUCCESS define and converting those returns to return 0.

Jacob separates the hardware logic from the set function, so that we can
re-use it during a ptp_reset in igb.  This enables the reset to return
functionality to the last know timestamp mode, rather than resetting the
value.

Ashish implements context flags for headwb and headwb_addr so that we
do not have to keep them always enabled.

Shannon updates the admin queue API for the new firmware, which adds
set_pf_content, nvm_config_read/write, replaces set_phy_reset with
set_phy_debug and removes nvm_read/write_reg_se.  Cleans up the driver
to use the stored base_queue value since there is no need to read the
PCI register for the PF's base queue on every single transmit queue
enable and disable as we already have the value stored from reading
the capability features at startup.

Anjali changes the notion of source and destination for FD_SB in ethtool
to align i40e with other drivers.  Adds flow director statistics to
the PF stats.  Fixes a bug in ethtool for flow director drop packet
filter where the drop action comes down as a ring_cookie value, so allow
it as a special value that can be used to configure destination control.

Mitch fixes the i40evf to keep the driver from going down when it is
already in a down state.  This prevents a CPU soft lock in napi_disable().
Also change the i40evf to check the admin queue error bits since the
firmware can indicate any admin queue error states to the driver via
some bits in the length registers.

Neerav separates out the DCB capability and enabled flags because currently
if the firmware reports DCB capability the driver enables
I40E_FLAG_DCB_ENABLED flag.  When this flag is enabled the driver inserts
a tag when transmitting a packet from the port even if there are no DCB
traffic classes configured at the port.  So by adding the additional flag,
I40E_FLAG_DCB_CAPABLE, that will be set when the DCB capability is present
and the existing enabled flag will only be set if there are more than one
traffic classes configured at the port.

Greg fixes the i40e driver to not automatically accept tagged packets by
default so that the system must request a VLAN tag packet filter to get
packets with that tag.  Greg also converts i40e to use the in-kernel
ether_addr_copy() instead of mempcy().

Jesse removes the FTYPE field from the receive descriptor to match the
hardware implementation.

The following are changes since commit 581d9baa21dbd69b5b02cd654d858d064c400769:
  farsync: Fix confusion about DMA address and buffer offset types
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (3):
  i40e: Change the notion of src and dst for FD_SB in ethtool
  i40e/i40evf: Add Flow director stats to PF stats
  i40e: Fix a bug in ethtool for FD drop packet filter action

Ashish Shah (1):
  i40e/i40evf: set headwb Tx context flags and use them

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e to version 0.4.10 and i40evf to 0.9.34

Greg Rose (2):
  i40e: Do not accept tagged packets by default
  i40e/i40evf: User ether_addr_copy instead of memcpy

Jacob Keller (1):
  igb: separate hardware setting from the set_ts_config ioctl

Jesse Brandeburg (1):
  i40e/i40evf: remove FTYPE

Mitch Williams (2):
  i40evf: don't go further down
  i40evf: check admin queue error bits

Neerav Parikh (1):
  i40e: Separate out DCB capability and enabled flags

Shannon Nelson (2):
  i40e/i40evf: AdminQ API update for new FW
  i40e: use stored base_queue value

Todd Fujinaka (1):
  igb: unhide invariant returns

 drivers/net/ethernet/intel/i40e/i40e.h             | 15 ++++
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 96 ++++++++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  5 +-
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 37 ++++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 96 +++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  7 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  7 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 96 ++++++++++++++++++----
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |  4 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 57 ++++++++++---
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  7 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c       | 28 +++----
 drivers/net/ethernet/intel/igb/e1000_defines.h     |  1 -
 drivers/net/ethernet/intel/igb/e1000_i210.c        | 86 +++++++++----------
 drivers/net/ethernet/intel/igb/igb_ethtool.c       | 10 +--
 drivers/net/ethernet/intel/igb/igb_main.c          | 15 ++--
 drivers/net/ethernet/intel/igb/igb_ptp.c           | 50 ++++++++---
 20 files changed, 453 insertions(+), 174 deletions(-)

-- 
1.9.3
