From: Christoph Egger <siccegge@cs.fau.de>
Subject: [PATCH 01/11] Removing dead RT2800PCI_SOC
Date: Wed, 14 Jul 2010 14:39:43 +0200
Message-ID: <29013fb6eab9e95e95d61df894797d2455dfa10c.1279110894.git.siccegge@cs.fau.de>
References: <cover.1279110894.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Felix Fiet
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:43527 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755228Ab0GNMjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:39:45 -0400
Content-Disposition: inline
In-Reply-To: <cover.1279110894.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While RT2800PCI_SOC exists in Kconfig, it depends on either
RALINK_RT288X or RALINK_RT305X which are both not available in Kconfig
so all Code depending on that can't ever be selected and, if there's
no plan to add these options, should be cleaned up

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 drivers/net/wireless/rt2x00/Kconfig     |    5 ----
 drivers/net/wireless/rt2x00/rt2800pci.c |   39 -------------------------------
 2 files changed, 0 insertions(+), 44 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2x00/Kconfig
index eea1ef2..d59195a 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -58,11 +58,6 @@ config RT2800PCI_PCI
 	depends on PCI
 	default y
 
-config RT2800PCI_SOC
-	boolean
-	depends on RALINK_RT288X || RALINK_RT305X
-	default y
-
 config RT2800PCI
 	tristate "Ralink rt28xx/rt30xx/rt35xx (PCI/PCIe/PCMCIA) support (EXPERIMENTAL)"
 	depends on (RT2800PCI_PCI || RT2800PCI_SOC) && EXPERIMENTAL
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index b2f2327..1445038 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -85,18 +85,9 @@ static void rt2800pci_mcu_status(struct rt2x00_dev *rt2x00dev, const u8 token)
 	rt2800_register_write(rt2x00dev, H2M_MAILBOX_CID, ~0);
 }
 
-#ifdef CONFIG_RT2800PCI_SOC
-static void rt2800pci_read_eeprom_soc(struct rt2x00_dev *rt2x00dev)
-{
-	u32 *base_addr = (u32 *) KSEG1ADDR(0x1F040000); /* XXX for RT3052 */
-
-	memcpy_fromio(rt2x00dev->eeprom, base_addr, EEPROM_SIZE);
-}
-#else
 static inline void rt2800pci_read_eeprom_soc(struct rt2x00_dev *rt2x00dev)
 {
 }
-#endif /* CONFIG_RT2800PCI_SOC */
 
 #ifdef CONFIG_RT2800PCI_PCI
 static void rt2800pci_eepromregister_read(struct eeprom_93cx6 *eeprom)
@@ -1160,25 +1151,6 @@ MODULE_DEVICE_TABLE(pci, rt2800pci_device_table);
 #endif /* CONFIG_RT2800PCI_PCI */
 MODULE_LICENSE("GPL");
 
-#ifdef CONFIG_RT2800PCI_SOC
-static int rt2800soc_probe(struct platform_device *pdev)
-{
-	return rt2x00soc_probe(pdev, &rt2800pci_ops);
-}
-
-static struct platform_driver rt2800soc_driver = {
-	.driver		= {
-		.name		= "rt2800_wmac",
-		.owner		= THIS_MODULE,
-		.mod_name	= KBUILD_MODNAME,
-	},
-	.probe		= rt2800soc_probe,
-	.remove		= __devexit_p(rt2x00soc_remove),
-	.suspend	= rt2x00soc_suspend,
-	.resume		= rt2x00soc_resume,
-};
-#endif /* CONFIG_RT2800PCI_SOC */
-
 #ifdef CONFIG_RT2800PCI_PCI
 static struct pci_driver rt2800pci_driver = {
 	.name		= KBUILD_MODNAME,
@@ -1194,17 +1166,9 @@ static int __init rt2800pci_init(void)
 {
 	int ret = 0;
 
-#ifdef CONFIG_RT2800PCI_SOC
-	ret = platform_driver_register(&rt2800soc_driver);
-	if (ret)
-		return ret;
-#endif
 #ifdef CONFIG_RT2800PCI_PCI
 	ret = pci_register_driver(&rt2800pci_driver);
 	if (ret) {
-#ifdef CONFIG_RT2800PCI_SOC
-		platform_driver_unregister(&rt2800soc_driver);
-#endif
 		return ret;
 	}
 #endif
@@ -1217,9 +1181,6 @@ static void __exit rt2800pci_exit(void)
 #ifdef CONFIG_RT2800PCI_PCI
 	pci_unregister_driver(&rt2800pci_driver);
 #endif
-#ifdef CONFIG_RT2800PCI_SOC
-	platform_driver_unregister(&rt2800soc_driver);
-#endif
 }
 
 module_init(rt2800pci_init);
-- 
1.7.0.4

