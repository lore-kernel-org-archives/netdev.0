From: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
Subject: [PATCH] PCI legacy I/O port free driver - Making Intel e1000 driver
 legacy I/O port free
Date: Thu, 10 May 2007 19:03:25 +0900
Message-ID: <4642EDED.7020109@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cramerj@intel.com, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	auke-jan.h.kok@intel.com, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail9.fujitsu.co.jp ([192.51.44.39]:50672 "EHLO
	fgwmail9.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbXEJKFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 06:05:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

As you can see in the "10. pci_enable_device_bars() and Legacy I/O
Port space" of the Documentation/pci.txt, the latest kernel has
interfaces for PCI device drivers to tell the kernel which resource
the driver want to use, ex. I/O port or MMIO.

I've made a patch which makes Intel e1000 driver legacy I/O port
free by using the PCI core changes I mentioned above. The Intel
e1000 driver can handle some of its devices without using I/O port.
So this patch changes the driver not to enable/request I/O port
region depending on the device id.

As a result, the driver can handle its device even when there are
huge number of PCI devices being used on the system and no I/O
port region assigned to the device.

Tomohiro Kusumi

Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>

---
 e1000.h      |    6 +-
 e1000_main.c |  152 +++++++++++++++++++++++++++++++----------------------------
 2 files changed, 86 insertions(+), 72 deletions(-)

diff -uprN linux-2.6.21.orig/drivers/net/e1000/e1000.h linux-2.6.21/drivers/net/e1000/e1000.h
--- linux-2.6.21.orig/drivers/net/e1000/e1000.h	2007-05-09 18:02:26.000000000 +0900
+++ linux-2.6.21/drivers/net/e1000/e1000.h	2007-05-09 18:02:59.000000000 +0900
@@ -74,8 +74,9 @@
 #define BAR_1		1
 #define BAR_5		5

-#define INTEL_E1000_ETHERNET_DEVICE(device_id) {\
-	PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
+#define E1000_USE_IOPORT       (1 << 0)
+#define INTEL_E1000_ETHERNET_DEVICE(device_id, flags) {\
+       PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id), .driver_data = flags}

 struct e1000_adapter;

@@ -347,6 +348,7 @@ struct e1000_adapter {
 	boolean_t quad_port_a;
 	unsigned long flags;
 	uint32_t eeprom_wol;
+	int bars;               /* BARs to be enabled */
 };

 enum e1000_state_t {
diff -uprN linux-2.6.21.orig/drivers/net/e1000/e1000_main.c linux-2.6.21/drivers/net/e1000/e1000_main.c
--- linux-2.6.21.orig/drivers/net/e1000/e1000_main.c	2007-05-09 18:02:27.000000000 +0900
+++ linux-2.6.21/drivers/net/e1000/e1000_main.c	2007-05-09 18:03:00.000000000 +0900
@@ -48,65 +48,65 @@ static char e1000_copyright[] = "Copyrig
  *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
  */
 static struct pci_device_id e1000_pci_tbl[] = {
-	INTEL_E1000_ETHERNET_DEVICE(0x1000),
-	INTEL_E1000_ETHERNET_DEVICE(0x1001),
-	INTEL_E1000_ETHERNET_DEVICE(0x1004),
-	INTEL_E1000_ETHERNET_DEVICE(0x1008),
-	INTEL_E1000_ETHERNET_DEVICE(0x1009),
-	INTEL_E1000_ETHERNET_DEVICE(0x100C),
-	INTEL_E1000_ETHERNET_DEVICE(0x100D),
-	INTEL_E1000_ETHERNET_DEVICE(0x100E),
-	INTEL_E1000_ETHERNET_DEVICE(0x100F),
-	INTEL_E1000_ETHERNET_DEVICE(0x1010),
-	INTEL_E1000_ETHERNET_DEVICE(0x1011),
-	INTEL_E1000_ETHERNET_DEVICE(0x1012),
-	INTEL_E1000_ETHERNET_DEVICE(0x1013),
-	INTEL_E1000_ETHERNET_DEVICE(0x1014),
-	INTEL_E1000_ETHERNET_DEVICE(0x1015),
-	INTEL_E1000_ETHERNET_DEVICE(0x1016),
-	INTEL_E1000_ETHERNET_DEVICE(0x1017),
-	INTEL_E1000_ETHERNET_DEVICE(0x1018),
-	INTEL_E1000_ETHERNET_DEVICE(0x1019),
-	INTEL_E1000_ETHERNET_DEVICE(0x101A),
-	INTEL_E1000_ETHERNET_DEVICE(0x101D),
-	INTEL_E1000_ETHERNET_DEVICE(0x101E),
-	INTEL_E1000_ETHERNET_DEVICE(0x1026),
-	INTEL_E1000_ETHERNET_DEVICE(0x1027),
-	INTEL_E1000_ETHERNET_DEVICE(0x1028),
-	INTEL_E1000_ETHERNET_DEVICE(0x1049),
-	INTEL_E1000_ETHERNET_DEVICE(0x104A),
-	INTEL_E1000_ETHERNET_DEVICE(0x104B),
-	INTEL_E1000_ETHERNET_DEVICE(0x104C),
-	INTEL_E1000_ETHERNET_DEVICE(0x104D),
-	INTEL_E1000_ETHERNET_DEVICE(0x105E),
-	INTEL_E1000_ETHERNET_DEVICE(0x105F),
-	INTEL_E1000_ETHERNET_DEVICE(0x1060),
-	INTEL_E1000_ETHERNET_DEVICE(0x1075),
-	INTEL_E1000_ETHERNET_DEVICE(0x1076),
-	INTEL_E1000_ETHERNET_DEVICE(0x1077),
-	INTEL_E1000_ETHERNET_DEVICE(0x1078),
-	INTEL_E1000_ETHERNET_DEVICE(0x1079),
-	INTEL_E1000_ETHERNET_DEVICE(0x107A),
-	INTEL_E1000_ETHERNET_DEVICE(0x107B),
-	INTEL_E1000_ETHERNET_DEVICE(0x107C),
-	INTEL_E1000_ETHERNET_DEVICE(0x107D),
-	INTEL_E1000_ETHERNET_DEVICE(0x107E),
-	INTEL_E1000_ETHERNET_DEVICE(0x107F),
-	INTEL_E1000_ETHERNET_DEVICE(0x108A),
-	INTEL_E1000_ETHERNET_DEVICE(0x108B),
-	INTEL_E1000_ETHERNET_DEVICE(0x108C),
-	INTEL_E1000_ETHERNET_DEVICE(0x1096),
-	INTEL_E1000_ETHERNET_DEVICE(0x1098),
-	INTEL_E1000_ETHERNET_DEVICE(0x1099),
-	INTEL_E1000_ETHERNET_DEVICE(0x109A),
-	INTEL_E1000_ETHERNET_DEVICE(0x10A4),
-	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
-	INTEL_E1000_ETHERNET_DEVICE(0x10B9),
-	INTEL_E1000_ETHERNET_DEVICE(0x10BA),
-	INTEL_E1000_ETHERNET_DEVICE(0x10BB),
-	INTEL_E1000_ETHERNET_DEVICE(0x10BC),
-	INTEL_E1000_ETHERNET_DEVICE(0x10C4),
-	INTEL_E1000_ETHERNET_DEVICE(0x10C5),
+	INTEL_E1000_ETHERNET_DEVICE(0x1000, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1001, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1004, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1008, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1009, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x100C, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x100D, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x100E, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x100F, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1010, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1011, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1012, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1013, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1014, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1015, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1016, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1017, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1018, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1019, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x101A, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x101D, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x101E, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1026, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1027, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1028, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1049, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x104A, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x104B, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x104C, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x104D, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x105E, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x105F, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1060, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1075, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1076, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1077, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1078, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x1079, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x107A, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x107B, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x107C, E1000_USE_IOPORT),
+	INTEL_E1000_ETHERNET_DEVICE(0x107D, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x107E, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x107F, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x108A, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x108B, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x108C, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1096, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1098, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x1099, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x109A, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x10A4, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x10B5, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x10B9, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x10BA, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x10BB, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x10BC, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x10C4, 0),
+	INTEL_E1000_ETHERNET_DEVICE(0x10C5, 0),
 	/* required last entry */
 	{0,}
 };
@@ -879,7 +879,14 @@ e1000_probe(struct pci_dev *pdev,
 	int i, err, pci_using_dac;
 	uint16_t eeprom_data = 0;
 	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
-	if ((err = pci_enable_device(pdev)))
+	int bars;
+
+	if (ent->driver_data & E1000_USE_IOPORT)
+		bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
+	else
+		bars = pci_select_bars(pdev, IORESOURCE_MEM);
+
+	if ((err = pci_enable_device_bars(pdev, bars)))
 		return err;

 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
@@ -894,7 +901,8 @@ e1000_probe(struct pci_dev *pdev,
 		pci_using_dac = 0;
 	}

-	if ((err = pci_request_regions(pdev, e1000_driver_name)))
+	err = pci_request_selected_regions(pdev, bars, e1000_driver_name);
+	if (err)
 		goto err_pci_reg;

 	pci_set_master(pdev);
@@ -913,6 +921,7 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
 	adapter->msg_enable = (1 << debug) - 1;
+	adapter->bars = bars;

 	mmio_start = pci_resource_start(pdev, BAR_0);
 	mmio_len = pci_resource_len(pdev, BAR_0);
@@ -922,12 +931,15 @@ e1000_probe(struct pci_dev *pdev,
 	if (!adapter->hw.hw_addr)
 		goto err_ioremap;

-	for (i = BAR_1; i <= BAR_5; i++) {
-		if (pci_resource_len(pdev, i) == 0)
-			continue;
-		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
-			adapter->hw.io_base = pci_resource_start(pdev, i);
-			break;
+	if (ent->driver_data & E1000_USE_IOPORT) {
+		for (i = BAR_1; i <= BAR_5; i++) {
+			if (pci_resource_len(pdev, i) == 0)
+				continue;
+			if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+				adapter->hw.io_base =
+					pci_resource_start(pdev, i);
+				break;
+			}
 		}
 	}

@@ -1190,7 +1202,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -1242,7 +1254,7 @@ e1000_remove(struct pci_dev *pdev)
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, adapter->bars);

 	free_netdev(netdev);

@@ -5172,7 +5184,7 @@ e1000_resume(struct pci_dev *pdev)

 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	if ((err = pci_enable_device(pdev))) {
+	if ((err = pci_enable_device_bars(pdev, adapter->bars))) {
 		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
 		return err;
 	}

