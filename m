From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] block MSI on Sony
Date: Mon, 29 Jan 2007 15:50:43 -0800
Message-ID: <20070129155043.56a1c577@freekitty>
References: <Pine.LNX.4.64.0701241847360.25027@woody.linux-foundation.org>
	<1169931333.17469.125.camel@localhost.localdomain>
	<20070129113159.7ad22e4c@freekitty>
	<1170101430.29240.34.camel@localhost.localdomain>
	<20070129133849.1b523226@freekitty>
	<1170109401.29240.49.camel@localhost.localdomain>
	<1170110318.21603.25.camel@funkylaptop>
	<1170110732.29240.59.camel@localhost.localdomain>
	<1170111056.21603.30.camel@funkylaptop>
	<1170111464.29240.63.camel@localhost.localdomain>
	<1170113200.21603.41.camel@funkylaptop>
	<1170113879.29240.79.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?RnLDqWTDqXJpYw==?= Riss <frederic.riss@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34320 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964934AbXA2XxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 18:53:16 -0500
In-Reply-To: <1170113879.29240.79.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Sony VAIO BIOS resets to INTx on resume. This happens
after device resume, so device irq's get misrouted.

This hack turns off MSI on this laptop, until power management
initialization order is fixed.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/pci/quirks.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index ef882a8..9a64179 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -21,6 +21,7 @@ #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/acpi.h>
+#include <linux/dmi.h>
 #include "pci.h"
 
 /* The Mellanox Tavor device gives false positive parity errors
@@ -1779,6 +1780,37 @@ static void __devinit quirk_nvidia_ck804
 }
 DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_CK804_PCIE,
 			quirk_nvidia_ck804_msi_ht_cap);
+
+/* On Sony VAIO laptop, BIOS resets MSI during resume. */
+static __initdata struct dmi_system_id sony_dmi_table[] = {
+	{
+		.ident = "Sony Vaio",
+		.matches = {
+			DMI_MATCH(DMI_SYS_VENDOR, "Sony Corporation"),
+			DMI_MATCH(DMI_PRODUCT_NAME, "PCG-"),
+		},
+	},
+	{
+		.ident = "Sony Vaio",
+		.matches = {
+			DMI_MATCH(DMI_SYS_VENDOR, "Sony Corporation"),
+			DMI_MATCH(DMI_PRODUCT_NAME, "VGN-"),
+		},
+	},
+	{ }
+};
+
+static void __init quirk_sony_msi(struct pci_dev *dev)
+{
+	if (!dmi_check_system(sony_dmi_table))
+		return;
+
+	pci_msi_quirk = 1;
+	printk(KERN_WARNING "PCI: MSI sony quirk detected. pci_msi_quirk set.\n");
+}
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82801BA_6,
+			quirk_sony_msi);
+
 #endif /* CONFIG_PCI_MSI */
 
 EXPORT_SYMBOL(pcie_mch_quirk);
-- 
1.4.1

