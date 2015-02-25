From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] e1000e: avoid incorrect ioremap/iounmap sequences for e1000_pch_spt
Date: Wed, 25 Feb 2015 14:11:32 -0500
Message-ID: <1424891492-2897-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Ertman <david.m.ertman@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42802 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbbBYTPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 14:15:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 79849ebc0e06 (e1000e: initial support for i219) overwrites
hw->flash_addr for e1000_pch_spt MACs without doing an iounmap.
It also reuses the address without changing the areas that then
iounmap the new address (which was never explicitly ioremap'ed).
This causes iounmap to spit-out a call trace on rmmod.

This patch circumvents this issue on the early hardware that we have
in-house at Red Hat.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David Ertman <david.m.ertman@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 6fa4fc05709e..b9d7e69a7414 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6833,7 +6833,8 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_ioremap;
 
 	if ((adapter->flags & FLAG_HAS_FLASH) &&
-	    (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
+	    (pci_resource_flags(pdev, 1) & IORESOURCE_MEM) &&
+	    (adapter->hw.mac.type != e1000_pch_spt)) {
 		flash_start = pci_resource_start(pdev, 1);
 		flash_len = pci_resource_len(pdev, 1);
 		adapter->hw.flash_address = ioremap(flash_start, flash_len);
@@ -7069,7 +7070,8 @@ err_hw_init:
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 err_sw_init:
-	if (adapter->hw.flash_address)
+	if (adapter->hw.flash_address &&
+	    (adapter->hw.mac.type != e1000_pch_spt))
 		iounmap(adapter->hw.flash_address);
 	e1000e_reset_interrupt_capability(adapter);
 err_flashmap:
@@ -7142,7 +7144,8 @@ static void e1000_remove(struct pci_dev *pdev)
 	kfree(adapter->rx_ring);
 
 	iounmap(adapter->hw.hw_addr);
-	if (adapter->hw.flash_address)
+	if (adapter->hw.flash_address &&
+	    (adapter->hw.mac.type != e1000_pch_spt))
 		iounmap(adapter->hw.flash_address);
 	pci_release_selected_regions(pdev,
 				     pci_select_bars(pdev, IORESOURCE_MEM));
-- 
2.1.0
