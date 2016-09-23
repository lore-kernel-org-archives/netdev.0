From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] 10GbE Intel Wired LAN Driver Updates 2016-09-23
Date: Fri, 23 Sep 2016 00:51:33 -0700
Message-ID: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:27953 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752652AbcIWHvo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

Emil provides several changes, first simplifies the logic for setting VLAN
filtering by checking the VMDQ flag and the old 82598 MAC, instead of
having to maintain a list of MAC types.  Then made two functions static
that are used only within the file, a by-product is sparse is now happy.
Added spinlocks to make sure that the MTU configuration is handled
properly.  Fixed an issue where when SR-IOV is enabled while the
ixgbevf driver is loaded would result in all mailbox requests being
rejected by ixgbe, so call ixgbe_sriov_reinit() before pci_enable_sriov()
to ensure mailbox requests are properly handled.

Mark resolves a NULL pointer issue by simply setting the read and write
*_ref_mdi pointers for x550em_a devices.  Then clearly indicates within
ethtool that all MACs support pause frames and made sure that the
advertising is set to the requested mode.  Fixed an issue where
MDIO_PRTAD_NONE was not being used consistently to indicate no PHY
address.

Alex fixes an issue, where the support for multiple queues when SR-IOV
is enabled was added but the support was not reported.  With that, fix
an issue where the hardware redirection table could support more queues
then the PF currently has when SR-IOV is enabled, so use the RSS mask to
trim off the bits that are not used.  Lastly, instead of limiting the
VFs if we do not use 4 queues for RSS in the PF, we can instead just limit
the RSS queues used to a power of 2.  We can now support use cases where
VFs are using more queues than the PF is currently using and can support
RSS if so desired.

The following are changes since commit cdd0766d7da19085e88df86d1e5e21d9fe3d374f:
  Merge branch 'ftgmac100-ast2500-support'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (3):
  ixgbe: Allow setting multiple queues when SR-IOV is enabled
  ixgbe: Limit reporting of redirection table if SR-IOV is enabled
  ixgbe: Support 4 queue RSS on VFs with 1 or 2 queue RSS on PF

Emil Tantilov (4):
  ixgbe: simplify the logic for setting VLAN filtering
  ixgbe: make ixgbe_led_on/off_t_x550em static
  ixgbevf: add spinlocks for MTU change calls
  ixgbe: reset before SRIOV init to avoid mailbox issues

Mark Rustad (3):
  ixgbe: Resolve NULL reference by setting {read, write}_reg_mdi
  ixgbe: Indicate support for pause frames in all cases
  ixgbe: Use MDIO_PRTAD_NONE consistently

 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  | 29 +++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      |  7 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 51 ++++++++---------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c      |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |  8 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 ++
 7 files changed, 62 insertions(+), 45 deletions(-)

-- 
2.7.4
