From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 10/23] e1000: Fix MANC detection for PCIE adapters
Date: Tue, 19 Sep 2006 10:28:55 -0700
Message-ID: <20060919172855.4605.79006.stgit@gitlost.site>
References: <20060919172623.4605.56860.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:19469 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030345AbWISRUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 13:20:00 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060919172623.4605.56860.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several manageability capability detection parts hinted towards
our code being incomplete for PCI-E. According to spec, we do not
want to poke any MANC bits at all.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f3f3d38..e81aa03 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -662,9 +662,7 @@ e1000_reset(struct e1000_adapter *adapte
 		                    phy_data);
 	}
 
-	if (adapter->hw.mac_type < e1000_ich8lan)
-	/* FIXME: this code is duplicate and wrong for PCI Express */
-	if (adapter->en_mng_pt) {
+	if ((adapter->en_mng_pt) && (adapter->hw.mac_type < e1000_82571)) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		manc |= (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
 		E1000_WRITE_REG(&adapter->hw, MANC, manc);
@@ -1042,8 +1040,7 @@ e1000_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-	if (adapter->hw.mac_type >= e1000_82540 &&
-	   adapter->hw.mac_type != e1000_ich8lan &&
+	if (adapter->hw.mac_type < e1000_82571 &&
 	   adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		if (manc & E1000_MANC_SMBUS_EN) {
@@ -4695,9 +4692,7 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	/* FIXME: this code is incorrect for PCI Express */
-	if (adapter->hw.mac_type >= e1000_82540 &&
-	   adapter->hw.mac_type != e1000_ich8lan &&
+	if (adapter->hw.mac_type < e1000_82571 &&
 	   adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		if (manc & E1000_MANC_SMBUS_EN) {
@@ -4749,9 +4744,7 @@ e1000_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	/* FIXME: this code is incorrect for PCI Express */
-	if (adapter->hw.mac_type >= e1000_82540 &&
-	   adapter->hw.mac_type != e1000_ich8lan &&
+	if (adapter->hw.mac_type < e1000_82571 &&
 	   adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		manc &= ~(E1000_MANC_ARP_EN);



---
Auke Kok <auke-jan.h.kok@intel.com>
