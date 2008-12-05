From: Thomas Renninger <trenn@suse.de>
Subject: [PATCH] PCIe ASPM causes machine (HP Compaq 6735s) to sometimes freeze hard at boot at PCI initialization time
Date: Fri, 5 Dec 2008 14:07:13 +0100
Message-ID: <200812051407.14419.trenn@suse.de>
References: <200811281328.55259.trenn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jbarnes@virtuousgeek.org, shaohua.li@intel.com,
	Rafael Wysocki <rwysocki@suse.de>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Stable@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:37184 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757190AbYLENHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 08:07:18 -0500
In-Reply-To: <200811281328.55259.trenn@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is intended for review by someone with more PCI experience, first.

If it is considered as safe as I think it is :), it would be great if
this can be picked up ang go into stable kernels as well if the
feedback is positive (just checked with .25, the patch still
patches there, even without offset).

Thanks,

    Thomas


PCIE: Break out of endless loop waiting for PCI config bits to switch

Makes a Compaq 6735s boot reliably again which hang in the loop
on some boots.

Signed-off-by: Thomas Renninger <trenn@suse.de>

---
 drivers/pci/pcie/aspm.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: linux-2.6.27/drivers/pci/pcie/aspm.c
===================================================================
--- linux-2.6.27.orig/drivers/pci/pcie/aspm.c
+++ linux-2.6.27/drivers/pci/pcie/aspm.c
@@ -165,6 +165,7 @@ static void pcie_aspm_configure_common_c
 	u16 reg16 = 0;
 	struct pci_dev *child_dev;
 	int same_clock = 1;
+	int loop_count = 0;
 
 	/*
 	 * all functions of a slot should have the same Slot Clock
@@ -212,12 +213,15 @@ static void pcie_aspm_configure_common_c
 	pci_write_config_word(pdev, pos + PCI_EXP_LNKCTL, reg16);
 
 	/* Wait for link training end */
-	while (1) {
+	while (loop_count < 100) {
 		pci_read_config_word(pdev, pos + PCI_EXP_LNKSTA, &reg16);
 		if (!(reg16 & PCI_EXP_LNKSTA_LT))
 			break;
 		cpu_relax();
+		loop_count++;
 	}
+	if (loop_count == 100) 
+		dev_printk (KERN_WARNING, &pdev->dev, "Could not configure ASPM\n");
 }
 
 /*
