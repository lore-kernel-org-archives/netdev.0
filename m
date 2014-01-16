From: ethan zhao <ethan.zhao@oracle.com>
Subject: [PATCH 2/2 Net-next v4] ixgbe: set driver_max_VFs should be done
 before enabling SRIOV
Date: Thu, 16 Jan 2014 14:19:38 +0800
Message-ID: <52D779FA.4090007@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ethan.kernel@gmail.com
To: aaron.f.brown@intel.com, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32404 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbaAPGT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 01:19:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


commit 43dc4e01 Limit number of reported VFs to device specific value
It doesn't work and always returns -EBUSY because VFs ware already enabled.

ixgbe_enable_sriov()
         pci_enable_sriov()
                 sriov_enable()
                 {
                 ... ..
                 iov->ctrl |= PCI_SRIOV_CTRL_VFE | PCI_SRIOV_CTRL_MSE;
                 pci_cfg_access_lock(dev);
                 ... ...
                 }

pci_sriov_set_totalvfs()
{
... ...
if (dev->sriov->ctrl & PCI_SRIOV_CTRL_VFE)
                 return -EBUSY;
...
}

So should set driver_max_VFs with pci_sriov_set_totalvfs() before
enable VFs with ixgbe_enable_sriov().

V2: revised for net-next tree.
V4: remove one signoff of two.

Signed-off-by: Ethan Zhao <ethan.kernel@gmail.com>
---
  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c 
b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bea2cec..6e6af0d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7972,8 +7972,8 @@ static int ixgbe_probe(struct pci_dev *pdev, const 
struct pci_device_id *ent)
      /* Mailbox */
      ixgbe_init_mbx_params_pf(hw);
      memcpy(&hw->mbx.ops, ii->mbx_ops, sizeof(hw->mbx.ops));
-    ixgbe_enable_sriov(adapter);
      pci_sriov_set_totalvfs(pdev, IXGBE_MAX_VFS_DRV_LIMIT);
+    ixgbe_enable_sriov(adapter);
  skip_sriov:

  #endif
-- 
1.7.1
