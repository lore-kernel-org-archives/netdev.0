From: akpm@osdl.org
Subject: [patch 3/9] e100: disable interrupts at boot
Date: Thu, 06 Jul 2006 23:58:21 -0700
Message-ID: <200607070658.k676wLQV030368@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bjorn.helgaas@hp.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, nils.rennebarth@packetalarm.com,
	stern@rowland.harvard.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:8898 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751223AbWGGG6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 02:58:36 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bjorn.helgaas@hp.com>

Apparently the Intel PRO/100 device enables interrupts on reset.  Unless
firmware explicitly disables PRO/100 interrupts, we can get a flood of
interrupts when a driver attaches to an unrelated device that happens to
share the PRO/100 IRQ.

This should resolve this "irq 11: nobody cared" bug report:
    http://bugzilla.kernel.org/show_bug.cgi?id=5918

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: <stern@rowland.harvard.edu>
Cc: <nils.rennebarth@packetalarm.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/pci/quirks.c |   57 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff -puN drivers/pci/quirks.c~e100-disable-interrupts-at-boot drivers/pci/quirks.c
--- a/drivers/pci/quirks.c~e100-disable-interrupts-at-boot
+++ a/drivers/pci/quirks.c
@@ -1403,6 +1403,63 @@ static void __devinit quirk_netmos(struc
 }
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_NETMOS, PCI_ANY_ID, quirk_netmos);
 
+static void __devinit quirk_e100_interrupt(struct pci_dev *dev)
+{
+	u16 command;
+	u32 bar;
+	u8 __iomem *csr;
+	u8 cmd_hi;
+
+	switch (dev->device) {
+	/* PCI IDs taken from drivers/net/e100.c */
+	case 0x1029:
+	case 0x1030 ... 0x1034:
+	case 0x1038 ... 0x103E:
+	case 0x1050 ... 0x1057:
+	case 0x1059:
+	case 0x1064 ... 0x106B:
+	case 0x1091 ... 0x1095:
+	case 0x1209:
+	case 0x1229:
+	case 0x2449:
+	case 0x2459:
+	case 0x245D:
+	case 0x27DC:
+		break;
+	default:
+		return;
+	}
+
+	/*
+	 * Some firmware hands off the e100 with interrupts enabled,
+	 * which can cause a flood of interrupts if packets are
+	 * received before the driver attaches to the device.  So
+	 * disable all e100 interrupts here.  The driver will
+	 * re-enable them when it's ready.
+	 */
+	pci_read_config_word(dev, PCI_COMMAND, &command);
+	pci_read_config_dword(dev, PCI_BASE_ADDRESS_0, &bar);
+
+	if (!(command & PCI_COMMAND_MEMORY) || !bar)
+		return;
+
+	csr = ioremap(bar, 8);
+	if (!csr) {
+		printk(KERN_WARNING "PCI: Can't map %s e100 registers\n",
+			pci_name(dev));
+		return;
+	}
+
+	cmd_hi = readb(csr + 3);
+	if (cmd_hi == 0) {
+		printk(KERN_WARNING "PCI: Firmware left %s e100 interrupts "
+			"enabled, disabling\n", pci_name(dev));
+		writeb(1, csr + 3);
+	}
+
+	iounmap(csr);
+}
+DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, quirk_e100_interrupt);
 
 static void __devinit fixup_rev1_53c810(struct pci_dev* dev)
 {
_
