From: domen@coderock.org
Subject: [patch 08/26] janitor: net/e1000: remove pci_find_device
Date: Sun, 06 Mar 2005 11:33:01 +0100
Message-ID: <20050306103301.EF37B1F203@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, sfeldma@pobox.com,
        janitor@sternwelten.at
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Removing pci_find_device required removing driver's custom
reboot notifier which walked the device list and replace it
with standard driver ->shutdown method.  Compiled and tested.

Signed-off-by: Scott Feldman <sfeldma@pobox.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/e1000/e1000_main.c |   38 ++++++++------------------------
 1 files changed, 10 insertions(+), 28 deletions(-)

diff -puN drivers/net/e1000/e1000_main.c~remove-pci-find-device-drivers_net_e1000_e1000_main drivers/net/e1000/e1000_main.c
--- kj/drivers/net/e1000/e1000_main.c~remove-pci-find-device-drivers_net_e1000_e1000_main	2005-03-05 16:09:43.000000000 +0100
+++ kj-domen/drivers/net/e1000/e1000_main.c	2005-03-05 16:09:43.000000000 +0100
@@ -165,7 +165,7 @@ static void e1000_vlan_rx_add_vid(struct
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
 
-static int e1000_notify_reboot(struct notifier_block *, unsigned long event, void *ptr);
+static void e1000_shutdown(struct device *dev);
 static int e1000_suspend(struct pci_dev *pdev, uint32_t state);
 #ifdef CONFIG_PM
 static int e1000_resume(struct pci_dev *pdev);
@@ -176,12 +176,6 @@ static int e1000_resume(struct pci_dev *
 static void e1000_netpoll (struct net_device *netdev);
 #endif
 
-struct notifier_block e1000_notifier_reboot = {
-	.notifier_call	= e1000_notify_reboot,
-	.next		= NULL,
-	.priority	= 0
-};
-
 /* Exported from other modules */
 
 extern void e1000_check_options(struct e1000_adapter *adapter);
@@ -194,8 +188,11 @@ static struct pci_driver e1000_driver = 
 	/* Power Managment Hooks */
 #ifdef CONFIG_PM
 	.suspend  = e1000_suspend,
-	.resume   = e1000_resume
+	.resume   = e1000_resume,
 #endif
+	.driver   = {
+		.shutdown  = e1000_shutdown,
+	}
 };
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -216,17 +213,12 @@ MODULE_PARM_DESC(debug, "Debug level (0=
 static int __init
 e1000_init_module(void)
 {
-	int ret;
 	printk(KERN_INFO "%s - version %s\n",
 	       e1000_driver_string, e1000_driver_version);
 
 	printk(KERN_INFO "%s\n", e1000_copyright);
 
-	ret = pci_module_init(&e1000_driver);
-	if(ret >= 0) {
-		register_reboot_notifier(&e1000_notifier_reboot);
-	}
-	return ret;
+	return pci_module_init(&e1000_driver);
 }
 
 module_init(e1000_init_module);
@@ -241,7 +233,6 @@ module_init(e1000_init_module);
 static void __exit
 e1000_exit_module(void)
 {
-	unregister_reboot_notifier(&e1000_notifier_reboot);
 	pci_unregister_driver(&e1000_driver);
 }
 
@@ -2783,21 +2774,12 @@ e1000_set_spd_dplx(struct e1000_adapter 
 	return 0;
 }
 
-static int
-e1000_notify_reboot(struct notifier_block *nb, unsigned long event, void *p)
+static
+void e1000_shutdown(struct device *dev)
 {
-	struct pci_dev *pdev = NULL;
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
 
-	switch(event) {
-	case SYS_DOWN:
-	case SYS_HALT:
-	case SYS_POWER_OFF:
-		while((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
-			if(pci_dev_driver(pdev) == &e1000_driver)
-				e1000_suspend(pdev, 3);
-		}
-	}
-	return NOTIFY_DONE;
+	e1000_suspend(pdev, 3);
 }
 
 static int
_
