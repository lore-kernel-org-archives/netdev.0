From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next PATCH 00/11] ixgbe: Add support for mixed PF/VF virtualization
Date: Mon, 02 Nov 2015 17:09:22 -0800
Message-ID: <20151103005850.28233.63113.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36637 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752803AbbKCBJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 20:09:24 -0500
Received: by pacfv9 with SMTP id fv9so2097341pac.3
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 17:09:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series extends the abilities of the ixgbe driver so that we can
now support VLAN trunking on top of the PF when SR-IOV is enabled.  By
doing this we are able to extend the existing capabilities that were
enabled with the "bridge fdb add" support that was added some time ago.  It
had enabled the ability to have PF and VF mixed on a flat network, this
makes it so that it also works on a VLAN enabled network.

The first few patches in this series are basically just cleanup.  They
either fix bugs found in the code, or address complexity that was making it
hard to either read or sort out exactly how the code was supposed to work.

The second half of the patch set is where we start adding features.
Specifically with this patch set the VLAN behavior changes for the PF in
two ways.  First we do not need to use the VLVF if the VFs have not already
set up a pool list.  As such I added functionality so that we can skip that
step when it is not needed.  Then I added support for VLAN promiscuous by
simply setting all of the bits in the VFTA and letting the packets fall
through to the default pool.  In addition when in promiscuous mode we set
the pool bit for the PF in all of the VLVF entries.  This way if anyone
adds a new entry it will automatically have the PF enabled.

The last few patches address some more issues I found during testing.  The
issues were primarily related to stale entries floating around in either
the RAR or VLVFB registers which were pointing to pools which were not
valid for the given L2 address.

---

Alexander Duyck (11):
      ixgbe: Return error on failure to allocate mac_table
      ixgbe: Fix SR-IOV VLAN pool configuration
      ixgbe: Simplify definitions for regidx and bit in set_vfta
      ixgbe: Reduce VT code indent in set_vfta by introducing jump label
      ixgbe: Simplify configuration of setting VLVF and VLVFB
      ixgbe: Add support for adding/removing VLAN on PF bypassing the VLVF
      ixgbe: Reorder search to work from the top down instead of bottom up
      ixgbe: Add support for VLAN promiscuous with SR-IOV
      ixgbe: Fix VLAN promisc in relation to SR-IOV
      ixgbe: Clear stale pool mappings
      ixgbe: Clean stale VLANs when changing port vlan or resetting


 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |   10 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  236 ++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  194 ++++++++++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c  |  187 +++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |   10 +
 9 files changed, 415 insertions(+), 231 deletions(-)

--
