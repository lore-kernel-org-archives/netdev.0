From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/20] fm10k: check if PCIe link is restored
Date: Wed, 20 Jul 2016 15:23:54 -0700
Message-ID: <1469053438-85381-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21457 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755361AbcGTWYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:08 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Sometimes, a VF driver will lose PCIe address access, such as due to
a PF FLR event. In fm10k_detach_subtask, poll and check whether the
PCIe register space is active again and restore the device when it has.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 5e40460..d4ccb2a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -123,11 +123,24 @@ static void fm10k_service_timer(unsigned long data)
 static void fm10k_detach_subtask(struct fm10k_intfc *interface)
 {
 	struct net_device *netdev = interface->netdev;
+	u32 __iomem *hw_addr;
+	u32 value;
 
 	/* do nothing if device is still present or hw_addr is set */
 	if (netif_device_present(netdev) || interface->hw.hw_addr)
 		return;
 
+	/* check the real address space to see if we've recovered */
+	hw_addr = READ_ONCE(interface->uc_addr);
+	value = readl(hw_addr);
+	if ((~value)) {
+		interface->hw.hw_addr = interface->uc_addr;
+		netif_device_attach(netdev);
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+		netdev_warn(netdev, "PCIe link restored, device now attached\n");
+		return;
+	}
+
 	rtnl_lock();
 
 	if (netif_running(netdev))
-- 
2.5.5
