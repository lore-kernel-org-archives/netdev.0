From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] ixgbe: reset before SRIOV init to avoid mailbox issues
Date: Fri, 23 Sep 2016 00:51:43 -0700
Message-ID: <1474617103-59530-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:27953 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757951AbcIWHvs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:48 -0400
In-Reply-To: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Enabling SRIOV while the ixgbevf driver is loaded will result in all
mailbox requests from ixgbevf_open() being rejected by ixgbe because
adapter->clear_to_send is set to false on reset.

Call ixgbe_sriov_reinit() before pci_enable_sriov() to make sure that
mailbox requests are handled from the time ixgbevf is loaded.

Reported-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 8618599..343a182 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -329,13 +329,15 @@ static int ixgbe_pci_sriov_enable(struct pci_dev *dev, int num_vfs)
 	for (i = 0; i < adapter->num_vfs; i++)
 		ixgbe_vf_configuration(dev, (i | 0x10000000));
 
+	/* reset before enabling SRIOV to avoid mailbox issues */
+	ixgbe_sriov_reinit(adapter);
+
 	err = pci_enable_sriov(dev, num_vfs);
 	if (err) {
 		e_dev_warn("Failed to enable PCI sriov: %d\n", err);
 		return err;
 	}
 	ixgbe_get_vfs(adapter);
-	ixgbe_sriov_reinit(adapter);
 
 	return num_vfs;
 #else
-- 
2.7.4
