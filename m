From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [RFC PATCH kernel] PCI: Enable access to custom VPD for Chelsio devices (cxgb3)
Date: Thu, 11 Aug 2016 20:03:29 +1000
Message-ID: <1470909809-11007-1-git-send-email-aik@ozlabs.ru>
References: <307b33c6-786e-f910-c456-fda94e8fdb98@suse.de>
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Santosh Raspatur <santosh@chelsio.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Paul Mackerras <paulus@samba.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Reinecke <hare@suse.de>, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <307b33c6-786e-f910-c456-fda94e8fdb98@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is at least one Chelsio 10Gb card which uses VPD area to store
some custom blocks (example below). However pci_vpd_size() returns
the length of the first block only assuming that there can be only
one VPD "End Tag" and VFIO blocks access beyond that offset
(since 4e1a63555) which leads to the situation when the guest "cxgb3"
driver fails to probe the device. The host system does not have this
problem as the drives accesses the config space directly without
pci_read_vpd()/...

This adds a quirk to override the VPD size to a bigger value.

This is the controller:
Ethernet controller [0200]: Chelsio Communications Inc T310 10GbE Single Port Adapter [1425:0030]

This is its VPD:
#0000 Large item 42 bytes; name 0x2 Identifier String
	b'10 Gigabit Ethernet-SR PCI Express Adapter'
#002d Large item 74 bytes; name 0x10
	#00 [EC] len=7: b'D76809 '
	#0a [FN] len=7: b'46K7897'
	#14 [PN] len=7: b'46K7897'
	#1e [MN] len=4: b'1037'
	#25 [FC] len=4: b'5769'
	#2c [SN] len=12: b'YL102035603V'
	#3b [NA] len=12: b'00145E992ED1'
#007a Small item 1 bytes; name 0xf End Tag
---
#0c00 Large item 16 bytes; name 0x2 Identifier String
	b'S310E-SR-X      '
#0c13 Large item 234 bytes; name 0x10
	#00 [PN] len=16: b'TBD             '
	#13 [EC] len=16: b'110107730D2     '
	#26 [SN] len=16: b'97YL102035603V  '
	#39 [NA] len=12: b'00145E992ED1'
	#48 [V0] len=6: b'175000'
	#51 [V1] len=6: b'266666'
	#5a [V2] len=6: b'266666'
	#63 [V3] len=6: b'2000  '
	#6c [V4] len=2: b'1 '
	#71 [V5] len=6: b'c2    '
	#7a [V6] len=6: b'0     '
	#83 [V7] len=2: b'1 '
	#88 [V8] len=2: b'0 '
	#8d [V9] len=2: b'0 '
	#92 [VA] len=2: b'0 '
	#97 [RV] len=80: b's\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'...
#0d00 Large item 252 bytes; name 0x11
	#00 [VC] len=16: b'122310_1222 dp  '
	#13 [VD] len=16: b'610-0001-00 H1\x00\x00'
	#26 [VE] len=16: b'122310_1353 fp  '
	#39 [VF] len=16: b'610-0001-00 H1\x00\x00'
	#4c [RW] len=173: b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'...
#0dff Small item 0 bytes; name 0xf End Tag

Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
---
 drivers/pci/quirks.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index ee72ebe1..94d3fb5 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -3241,6 +3241,18 @@ DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_CACTUS_RIDGE_4C
 DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_PORT_RIDGE,
 			quirk_thunderbolt_hotplug_msi);
 
+static void quirk_chelsio_extend_vpd(struct pci_dev *dev)
+{
+	if (!dev->vpd || !dev->vpd->ops || !dev->vpd->ops->set_size)
+		return;
+
+	dev->vpd->ops->set_size(dev, max_t(unsigned int, dev->vpd->len, 0xe00));
+}
+
+DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO,
+			PCI_ANY_ID,
+			quirk_chelsio_extend_vpd);
+
 #ifdef CONFIG_ACPI
 /*
  * Apple: Shutdown Cactus Ridge Thunderbolt controller.
-- 
2.5.0.rc3
