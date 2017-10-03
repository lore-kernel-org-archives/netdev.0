From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] 100GbE Intel Wired LAN Driver Updates 2017-10-03
Date: Tue,  3 Oct 2017 09:31:29 -0700
Message-ID: <20171003163138.47569-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19640 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751908AbdJCQcA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 12:32:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to fm10k only.

Jake provides majority of the changes in this series, starting with using
fm10k_prepare_for_reset() if we lose PCIe link.  Before we would detach
the device and close the netdev, which left a lot of items still active,
such as the Tx/Rx resources.  This could cause problems where register
reads would return potentially invalid values and would result in unknown
driver behavior, so call fm10k_prepare_for_reset() much like we do for
suspend/resume cycles.  This will attempt to shutdown as much as possible
to prevent possible issues.  Then replaced the PCI specific legacy power
management hooks with the new generic power management hooks for both
suspend and hibernate.  Introduced a workqueue item which monitors a
queue of MAC and VLAN requests since a large number of MAC address or
VLAN updates at once can overload the mailbox with too many messages at
once.  Fixed a cppcheck warning by properly declaring the min_rate and
max_rate variables in the declaration and definition for .ndo_set_vf_bw,
rather than using "unused" for the minimum rates.

Joe Perches fixes the backward logic when using net_ratelimit().

The following are changes since commit 4efac6ff4dc7d08ff3a63bf72172cb31323b6a8d:
  Merge branch '40GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 100GbE

Jacob Keller (8):
  fm10k: prepare_for_reset() when we lose PCIe Link
  fm10k: use spinlock to implement mailbox lock
  fm10k: use generic PM hooks instead of legacy PCIe power hooks
  fm10k: introduce a message queue for MAC/VLAN messages
  fm10k: use the MAC/VLAN queue for VF<->PF MAC/VLAN requests
  fm10k: bump version number
  fm10k: prefer %s and __func__ for diagnostic prints
  fm10k: fix mis-ordered parameters in declaration for .ndo_set_vf_bw

Joe Perches (1):
  fm10k: Fix misuse of net_ratelimit()

 drivers/net/ethernet/intel/fm10k/fm10k.h        |  60 +++-
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c    | 141 ++++++++-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |   5 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 199 +++++++++---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    | 392 +++++++++++++++++++-----
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c     |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h     |   3 +-
 7 files changed, 665 insertions(+), 137 deletions(-)

-- 
2.14.2
