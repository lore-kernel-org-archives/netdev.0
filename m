From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] igb: Support ports mapped in 64-bit PCI space
Date: Tue, 10 Dec 2013 02:22:38 -0800
Message-ID: <1386670961-20392-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Aaron Sierra <asierra@xes-inc.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7804 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970Ab3LJKXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 05:23:18 -0500
In-Reply-To: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Sierra <asierra@xes-inc.com>

This patch resolves an issue with 64-bit PCI addresses being truncated
because the return values of pci_resource_start() and pci_resource_end()
were being cast to unsigned long.

Signed-off-by: Aaron Sierra <asierra@xes-inc.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6da479b..ed129f1 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2022,7 +2022,6 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	s32 ret_val;
 	static int global_quad_port_a; /* global quad port a indication */
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
-	unsigned long mmio_start, mmio_len;
 	int err, pci_using_dac;
 	u8 part_str[E1000_PBANUM_LENGTH];
 
@@ -2079,11 +2078,8 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->back = adapter;
 	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
-	mmio_start = pci_resource_start(pdev, 0);
-	mmio_len = pci_resource_len(pdev, 0);
-
 	err = -EIO;
-	hw->hw_addr = ioremap(mmio_start, mmio_len);
+	hw->hw_addr = pci_iomap(pdev, 0, 0);
 	if (!hw->hw_addr)
 		goto err_ioremap;
 
@@ -2093,8 +2089,8 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
-	netdev->mem_start = mmio_start;
-	netdev->mem_end = mmio_start + mmio_len;
+	netdev->mem_start = pci_resource_start(pdev, 0);
+	netdev->mem_end = pci_resource_end(pdev, 0);
 
 	/* PCI config space info */
 	hw->vendor_id = pdev->vendor;
-- 
1.8.3.1
