From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 3/7] net: hp100: remove unnecessary #ifdefs
Date: Fri, 29 Jan 2016 12:39:11 +0100
Message-ID: <1454067557-3546883-4-git-send-email-arnd@arndb.de>
References: <1454067557-3546883-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jaroslav Kysela <perex@perex.cz>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1454067557-3546883-1-git-send-email-arnd@arndb.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Building the hp100 ethernet driver causes warnings when both the PCI
and EISA drivers are disabled:

ethernet/hp/hp100.c: In function 'hp100_module_init':
ethernet/hp/hp100.c:3047:2: warning: label 'out3' defined but not used [-Wunused-label]
ethernet/hp/hp100.c: At top level:
ethernet/hp/hp100.c:2828:13: warning: 'cleanup_dev' defined but not used [-Wunused-function]

We can easily avoid the warnings and make the driver look slightly
nicer by removing the #ifdefs that check for the CONFIG_PCI and
CONFIG_EISA, as all the registration functions are designed to
have no effect when the buses are disabled.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/hp/hp100.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 1d5c3e16d8f4..3daf2d4a7ca0 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -194,7 +194,6 @@ static const char *hp100_isa_tbl[] = {
 };
 #endif
 
-#ifdef CONFIG_EISA
 static struct eisa_device_id hp100_eisa_tbl[] = {
 	{ "HWPF180" }, /* HP J2577 rev A */
 	{ "HWP1920" }, /* HP 27248B */
@@ -205,9 +204,7 @@ static struct eisa_device_id hp100_eisa_tbl[] = {
 	{ "" }	       /* Mandatory final entry ! */
 };
 MODULE_DEVICE_TABLE(eisa, hp100_eisa_tbl);
-#endif
 
-#ifdef CONFIG_PCI
 static const struct pci_device_id hp100_pci_tbl[] = {
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585A, PCI_ANY_ID, PCI_ANY_ID,},
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585B, PCI_ANY_ID, PCI_ANY_ID,},
@@ -219,7 +216,6 @@ static const struct pci_device_id hp100_pci_tbl[] = {
 	{}			/* Terminating entry */
 };
 MODULE_DEVICE_TABLE(pci, hp100_pci_tbl);
-#endif
 
 static int hp100_rx_ratio = HP100_DEFAULT_RX_RATIO;
 static int hp100_priority_tx = HP100_DEFAULT_PRIORITY_TX;
@@ -2842,7 +2838,6 @@ static void cleanup_dev(struct net_device *d)
 	free_netdev(d);
 }
 
-#ifdef CONFIG_EISA
 static int hp100_eisa_probe(struct device *gendev)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct hp100_private));
@@ -2884,9 +2879,7 @@ static struct eisa_driver hp100_eisa_driver = {
 		.remove  = hp100_eisa_remove,
         }
 };
-#endif
 
-#ifdef CONFIG_PCI
 static int hp100_pci_probe(struct pci_dev *pdev,
 			   const struct pci_device_id *ent)
 {
@@ -2955,7 +2948,6 @@ static struct pci_driver hp100_pci_driver = {
 	.probe		= hp100_pci_probe,
 	.remove		= hp100_pci_remove,
 };
-#endif
 
 /*
  *  module section
@@ -3032,23 +3024,17 @@ static int __init hp100_module_init(void)
 	err = hp100_isa_init();
 	if (err && err != -ENODEV)
 		goto out;
-#ifdef CONFIG_EISA
 	err = eisa_driver_register(&hp100_eisa_driver);
 	if (err && err != -ENODEV)
 		goto out2;
-#endif
-#ifdef CONFIG_PCI
 	err = pci_register_driver(&hp100_pci_driver);
 	if (err && err != -ENODEV)
 		goto out3;
-#endif
  out:
 	return err;
  out3:
-#ifdef CONFIG_EISA
 	eisa_driver_unregister (&hp100_eisa_driver);
  out2:
-#endif
 	hp100_isa_cleanup();
 	goto out;
 }
@@ -3057,12 +3043,8 @@ static int __init hp100_module_init(void)
 static void __exit hp100_module_exit(void)
 {
 	hp100_isa_cleanup();
-#ifdef CONFIG_EISA
 	eisa_driver_unregister (&hp100_eisa_driver);
-#endif
-#ifdef CONFIG_PCI
 	pci_unregister_driver (&hp100_pci_driver);
-#endif
 }
 
 module_init(hp100_module_init)
-- 
2.7.0
