From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/18][pull request] Intel Wired LAN Driver Updates 2015-09-15
Date: Tue, 15 Sep 2015 17:36:25 -0700
Message-ID: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:26285 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644AbbIPAgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:36:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and fm10k.

Don fixes a ixgbe issue by adding checks for systems that do not have
SFP's to avoid incorrectly acting on interrupts that are falsely
interpreted as SFP events.

Alex Williamson adds a fix for ixgbe to disable SR-IOV prior to
unregistering the netdev to avoid issues with guest OS's which do not
support hot-unplug or their hot-unplug is broken.

Alex Duyck update the lowest limit for adaptive interrupt interrupt
moderation to about 12K interrupts per second for ixgbe.  This change
increases the performance for ixgbe.  Also fixed up fm10k to remove
the optimization that assumed that all fragments would be limited to
page size, since that assumption is incorrect as the TCP allocator can
provide up to a 32K page fragment.  Updated fm10k to add the MAC
address to the list of values recorded on driver load.  Fixes fm10k
so that we only trigger the data path reset if the fabric is ready to
handle traffic to avoid triggering the reset unless the switch API is
ready for us.

Jacob updates the fm10k driver to disable the service task during
suspend and re-enable it after we resume. If we don't do this, the
device could be UP when you suspend and come back from resume as
DOWN.  Also update fm10k to prevent the removal of default VID rules,
 and correctly remove the stack layers information of the VLAN, but then
return to forwarding that VID as untagged frames.  If we deleted the VID
rules here, we would begin dropping traffic due to VLAN membership
violations.  Fixed fm10k to use pcie_get_minimum_link(), which is useful
in cases where we connect to a slot at Gen3, but the slot is behind a bus
which is only connected at Gen2.  Updated fm10k to update the netdev
permanent address during reinit instead of up to enable users to
immediately see the new MAC address on the VF even if the device is not
up.  Adds the creation of VLAN interfaces on a device, even while the
device is down for fm10k.  Fixed an issue where we request the incorrect
MAC/VLAN combinations, and prevents us from accidentally reporting some
frames as VLAN tagged.  Provided a couple of trivial fixes for fm10k
to fix code style and typos in code comments.

The following are changes since commit ad1e7b97b3adb91d46f3adb70a7867a50fc274cf:
  cdc: Fix build warning.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Alex Williamson (1):
  ixgbe: Teardown SR-IOV before unregister_netdev()

Alexander Duyck (4):
  ixgbe: Limit lowest interrupt rate for adaptive interrupt moderation
    to 12K
  fm10k: Don't assume page fragments are page size
  fm10k: Report MAC address on driver load
  fm10k: Only trigger data path reset if fabric is up

Don Skidmore (1):
  ixgbe: fix issue with SFP events with new X550 devices

Jacob Keller (12):
  fm10k: disable service task during suspend
  fm10k: only prevent removal of default VID rules
  fm10k: update fm10k_slot_warn to use pcie_get_minimum link
  fm10k: update netdev perm_addr during reinit, instead of at up
  fm10k: allow creation of VLAN interfaces even while down
  fm10k: don't store sw_vid at reset
  fm10k: remove is_slot_appropriate
  fm10k: TRIVIAL fix up ordering of __always_unused and style
  fm10k: send traffic on default VID to VLAN device if we have one
  fm10k: TRIVIAL fix typo in fm10k_netdev.c
  fm10k: re-enable VF after a full reset on detection of a Malicious
    event
  fm10k: fix iov_msg_mac_vlan_pf VID checks

 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c |   5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c     |   3 -
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  12 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  39 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 176 +++++++++++++++++++----
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c      | 105 ++++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |   1 -
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      |  14 --
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  25 ++--
 12 files changed, 252 insertions(+), 135 deletions(-)

-- 
2.4.3
