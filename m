From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] e1000e: remove calls to ioremap/unmap for NVM addr
Date: Fri,  6 Mar 2015 03:06:02 -0800
Message-ID: <1425639966-6829-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	John W Linville <linville@tuxdriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50981 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756079AbbCFLGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 06:06:11 -0500
In-Reply-To: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

Starting I219, the NVM will not be mapped to its own BAR, but to an
address region in another bar.  The mapping/unmapping is relevant
to older HW only.

CC: John W Linville <linville@tuxdriver.com>
Reported-by: John W Linville <linville@tuxdriver.com>
Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 6fa4fc0..4be4576 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6833,7 +6833,8 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_ioremap;
 
 	if ((adapter->flags & FLAG_HAS_FLASH) &&
-	    (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
+	    (pci_resource_flags(pdev, 1) & IORESOURCE_MEM) &&
+	    (hw->mac.type < e1000_pch_spt)) {
 		flash_start = pci_resource_start(pdev, 1);
 		flash_len = pci_resource_len(pdev, 1);
 		adapter->hw.flash_address = ioremap(flash_start, flash_len);
@@ -7069,7 +7070,7 @@ err_hw_init:
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 err_sw_init:
-	if (adapter->hw.flash_address)
+	if ((adapter->hw.flash_address) && (hw->mac.type < e1000_pch_spt))
 		iounmap(adapter->hw.flash_address);
 	e1000e_reset_interrupt_capability(adapter);
 err_flashmap:
@@ -7142,7 +7143,8 @@ static void e1000_remove(struct pci_dev *pdev)
 	kfree(adapter->rx_ring);
 
 	iounmap(adapter->hw.hw_addr);
-	if (adapter->hw.flash_address)
+	if ((adapter->hw.flash_address) &&
+	    (adapter->hw.mac.type < e1000_pch_spt))
 		iounmap(adapter->hw.flash_address);
 	pci_release_selected_regions(pdev,
 				     pci_select_bars(pdev, IORESOURCE_MEM));
-- 
1.9.3
