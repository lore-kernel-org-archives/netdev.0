From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 1GbE Intel Wired LAN Driver Updates 2016-02-15
Date: Mon, 15 Feb 2016 19:21:41 -0800
Message-ID: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57142 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752086AbcBPDV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 22:21:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb only.

Shota Suzuki cleans up unnecessary flag setting for 82576 in
igb_set_flag_queue_pairs() since the default block already sets
IGB_FLAG_QUEUE_PAIRS to the correct value anyways, so the e1000_82576
code block is not necessary and we can simply fall through.  Then fixes
an issue where IGB_FLAG_QUEUE_PAIRS can now be set by using "ethtool -L"
option but is never cleared unless the driver is reloaded, so clear the
queue pairing if the pairing becomes unnecessary as a result of "ethtool
-L".

Mitch fixes the igbvf from giving up if it fails to get the hardware
mailbox lock.  This can happen when the PF-VF communication channel is
heavily loaded and causes complete communications failure between the
PF and VF drivers, so add a counter and a delay so that the driver will
now retry ten times before giving up on getting the mailbox lock.

The remaining patches in the series are from Alex Duyck, starting with the
cleaning up code that sets the MAC address.  Then refactors the VFTA and
VLVF configuration, to simplify and update to similar setups in the ixgbe
driver.  Fixed an issue were VLANs headers size was being added to the
value programmed into the RLPML registers, yet these registers already
take into account the size of the VLAN headers when determining the
maximum packet length, so we can drop the code that adds the size to
the RLPML registers.  Cleaned up the configuration of the VF port based
VLAN configuration.  Also fixed the igb driver so that we can fully
support SR-IOV or the recently added NTUPLE filtering while allowing
support for VLAN promiscuous mode.  Also added the ability to use the
bridge utility to add a FDB entry for the PF to an igb port.

The following are changes since commit 667f00630ebefc4d73aa105c6ab254e4aec867f8:
  Merge branch 'local-checksum-offload'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Alexander Duyck (11):
  igb: clean up code for setting MAC address
  igb: Refactor VFTA configuration
  igb: Allow asymmetric configuration of MTU versus Rx frame size
  igb: Do not factor VLANs into RLPML calculation
  igb: Always enable VLAN 0 even if 8021q is not loaded
  igb: Merge VLVF configuration into igb_vfta_set
  igb: Clean-up configuration of VF port VLANs
  igb: Add support for VLAN promiscuous with SR-IOV and NTUPLE
  igb: Drop unnecessary checks in transmit path
  igb: Enable use of "bridge fdb add" to set unicast table entries
  igb: Add workaround for VLAN tag stripping on 82576

Mitch Williams (1):
  igb/igbvf: don't give up

Shota Suzuki (2):
  igb: Remove unnecessary flag setting in igb_set_flag_queue_pairs()
  igb: Unpair the queues when changing the number of queues

 drivers/net/ethernet/intel/igb/e1000_82575.c   |  39 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h |   3 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h      |   2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c     | 213 ++++---
 drivers/net/ethernet/intel/igb/e1000_mac.h     |   5 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c     |  18 +-
 drivers/net/ethernet/intel/igb/igb.h           |   2 +-
 drivers/net/ethernet/intel/igb/igb_main.c      | 774 ++++++++++++++-----------
 drivers/net/ethernet/intel/igbvf/mbx.c         |  20 +-
 9 files changed, 637 insertions(+), 439 deletions(-)

-- 
2.5.0
