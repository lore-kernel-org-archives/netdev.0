From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/8] e1000: FIX: don't poke at manageability registers for incompatible adapters
Date: Tue, 17 Oct 2006 12:02:34 -0700
Message-ID: <20061017190234.4194.86732.stgit@gitlost.site>
References: <20061017190139.4194.20128.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:15118 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751430AbWJQSxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 14:53:48 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061017190139.4194.20128.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The MANC register should not be read for PCI-E adapters at all, as well as
82543 and older where 82543 would master abort when this register was
accessed.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    3 ++-
 drivers/net/e1000/e1000_main.c    |   21 ++++++++++++++-------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 773821e..71fb278 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -461,7 +461,8 @@ e1000_get_regs(struct net_device *netdev
 	regs_buff[24] = (uint32_t)phy_data;  /* phy local receiver status */
 	regs_buff[25] = regs_buff[24];  /* phy remote receiver status */
 	if (hw->mac_type >= e1000_82540 &&
-	   hw->media_type == e1000_media_type_copper) {
+	    hw->mac_type < e1000_82571 &&
+	    hw->media_type == e1000_media_type_copper) {
 		regs_buff[26] = E1000_READ_REG(hw, MANC);
 	}
 }
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ce0d35f..de3dced 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -699,7 +699,10 @@ e1000_reset(struct e1000_adapter *adapte
 		                    phy_data);
 	}
 
-	if ((adapter->en_mng_pt) && (adapter->hw.mac_type < e1000_82571)) {
+	if ((adapter->en_mng_pt) &&
+	    (adapter->hw.mac_type >= e1000_82540) &&
+	    (adapter->hw.mac_type < e1000_82571) &&
+	    (adapter->hw.media_type == e1000_media_type_copper)) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		manc |= (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
 		E1000_WRITE_REG(&adapter->hw, MANC, manc);
@@ -1076,8 +1079,9 @@ e1000_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-	if (adapter->hw.mac_type < e1000_82571 &&
-	   adapter->hw.media_type == e1000_media_type_copper) {
+	if (adapter->hw.mac_type >= e1000_82540 &&
+	    adapter->hw.mac_type < e1000_82571 &&
+	    adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		if (manc & E1000_MANC_SMBUS_EN) {
 			manc |= E1000_MANC_ARP_EN;
@@ -4773,8 +4777,9 @@ e1000_suspend(struct pci_dev *pdev, pm_m
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	if (adapter->hw.mac_type < e1000_82571 &&
-	   adapter->hw.media_type == e1000_media_type_copper) {
+	if (adapter->hw.mac_type >= e1000_82540 &&
+	    adapter->hw.mac_type < e1000_82571 &&
+	    adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		if (manc & E1000_MANC_SMBUS_EN) {
 			manc |= E1000_MANC_ARP_EN;
@@ -4825,8 +4830,9 @@ e1000_resume(struct pci_dev *pdev)
 
 	netif_device_attach(netdev);
 
-	if (adapter->hw.mac_type < e1000_82571 &&
-	   adapter->hw.media_type == e1000_media_type_copper) {
+	if (adapter->hw.mac_type >= e1000_82540 &&
+	    adapter->hw.mac_type < e1000_82571 &&
+	    adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		manc &= ~(E1000_MANC_ARP_EN);
 		E1000_WRITE_REG(&adapter->hw, MANC, manc);
@@ -4948,6 +4954,7 @@ static void e1000_io_resume(struct pci_d
 	netif_device_attach(netdev);
 
 	if (adapter->hw.mac_type >= e1000_82540 &&
+	    adapter->hw.mac_type < e1000_82571 &&
 	    adapter->hw.media_type == e1000_media_type_copper) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		manc &= ~(E1000_MANC_ARP_EN);



---
Auke Kok <auke-jan.h.kok@intel.com>
