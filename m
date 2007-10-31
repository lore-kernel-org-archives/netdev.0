From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/4] e1000e: Disable L1 ASPM power savings for 82573 mobile
	variants
Date: Wed, 31 Oct 2007 15:22:00 -0700
Message-ID: <20071031222200.17411.52942.stgit@localhost.localdomain>
References: <20071031222152.17411.20977.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12972 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248AbXJaWWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 18:22:02 -0400
In-Reply-To: <20071031222152.17411.20977.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L1 ASPM link (pci-e link power savings) has significant benefits
(~1W savings when link is active) but unfortunately does not work
correctly on any of the chipsets that have 82573 on mobile platforms
which causes various nuisances:
 - eeprom reads return garbage information leading to bad eeprom
   checksums
 - long ping times (up to 2 seconds)
 - complete system hangs (freeze/lockup)

A lot of T60 owners have been plagued by this, but other mobile
solutions also suffer from these symptoms.

Disabling L1 ASPM before we activate the PCI-E link fixes all of
these issues at the cost of some power consumption.

Remove a workaround RDTR adjustment that is no longer needed with
this new one.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c  |    1 -
 drivers/net/e1000e/e1000.h  |    1 -
 drivers/net/e1000e/netdev.c |   30 ++++++++++++++++++++++++++++++
 drivers/net/e1000e/param.c  |    7 -------
 4 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index b6401ab..45f5ee2 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1343,7 +1343,6 @@ struct e1000_info e1000_82573_info = {
 				  | FLAG_HAS_STATS_ICR_ICT
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
-				  | FLAG_HAS_ASPM
 				  | FLAG_HAS_ERT
 				  | FLAG_HAS_SWSM_ON_LOAD,
 	.pba			= 20,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 473f78d..8b88c22 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -288,7 +288,6 @@ struct e1000_info {
 #define FLAG_HAS_CTRLEXT_ON_LOAD          (1 << 5)
 #define FLAG_HAS_SWSM_ON_LOAD             (1 << 6)
 #define FLAG_HAS_JUMBO_FRAMES             (1 << 7)
-#define FLAG_HAS_ASPM                     (1 << 8)
 #define FLAG_HAS_STATS_ICR_ICT            (1 << 9)
 #define FLAG_HAS_STATS_PTC_PRC            (1 << 10)
 #define FLAG_HAS_SMART_POWER_DOWN         (1 << 11)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4fd2e23..ec427e2 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3511,6 +3511,33 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 	return 0;
 }
 
+static void e1000e_disable_l1aspm(struct pci_dev *pdev)
+{
+	int pos;
+	u32 cap;
+	u16 val;
+
+	/*
+	 * 82573 workaround - disable L1 ASPM on mobile chipsets
+	 *
+	 * L1 ASPM on various mobile (ich7) chipsets do not behave properly
+	 * resulting in lost data or garbage information on the pci-e link
+	 * level. This could result in (false) bad EEPROM checksum errors,
+	 * long ping times (up to 2s) or even a system freeze/hang.
+	 *
+	 * Unfortunately this feature saves about 1W power consumption when
+	 * active.
+	 */
+	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	pci_read_config_dword(pdev, pos + PCI_EXP_LNKCAP, &cap);
+	pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &val);
+	if (val & 0x2) {
+		dev_warn(&pdev->dev, "Disabling L1 ASPM\n");
+		val &= ~0x2;
+		pci_write_config_word(pdev, pos + PCI_EXP_LNKCTL, val);
+	}
+}
+
 #ifdef CONFIG_PM
 static int e1000_resume(struct pci_dev *pdev)
 {
@@ -3521,6 +3548,7 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	e1000e_disable_l1aspm(pdev);
 	err = pci_enable_device(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
@@ -3621,6 +3649,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
+	e1000e_disable_l1aspm(pdev);
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
@@ -3722,6 +3751,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 
+	e1000e_disable_l1aspm(pdev);
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 3327892..df266c3 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -262,13 +262,6 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 					 .max = MAX_RXDELAY } }
 		};
 
-		/* modify min and default if 82573 for slow ping w/a,
-		 * a value greater than 8 needs to be set for RDTR */
-		if (adapter->flags & FLAG_HAS_ASPM) {
-			opt.def = 32;
-			opt.arg.r.min = 8;
-		}
-
 		if (num_RxIntDelay > bd) {
 			adapter->rx_int_delay = RxIntDelay[bd];
 			e1000_validate_option(&adapter->rx_int_delay, &opt,
