From: domen@coderock.org
Subject: [patch 15/19] janitor: net/ixgb: remove pci_find_device
Date: Wed, 12 Jan 2005 00:10:53 +0100
Message-ID: <20050111231054.36CAF1F228@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, sfeldma@pobox.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Removing pci_find_device required removing driver's custom
reboot notifier which walked the device list and then called
the suspend func.  But, the suspend func isn't even hooked up
to the driver's PM ->suspend hook!  So it's vestigial (cut-
and-paste from e1000).  If ixgb ever implements PM hooks,
and there is a need to call ->suspend during shutdown, then
->shutdown can be implemented.  The need would be something
like Wake-on-LAN (10GbE?) arming.  Until then, all this code
needs to go.  Compile tested.

Signed-off-by: Scott Feldman <sfeldma@pobox.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/ixgb/ixgb_main.c |   68 ----------------------------------
 1 files changed, 1 insertion(+), 67 deletions(-)

diff -puN drivers/net/ixgb/ixgb_main.c~remove-pci-find-device-drivers_net_ixgb_ixgb_main drivers/net/ixgb/ixgb_main.c
--- kj/drivers/net/ixgb/ixgb_main.c~remove-pci-find-device-drivers_net_ixgb_ixgb_main	2005-01-10 18:00:17.000000000 +0100
+++ kj-domen/drivers/net/ixgb/ixgb_main.c	2005-01-10 18:00:17.000000000 +0100
@@ -105,21 +105,11 @@ static void ixgb_vlan_rx_add_vid(struct 
 static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 static void ixgb_restore_vlan(struct ixgb_adapter *adapter);
 
-static int ixgb_notify_reboot(struct notifier_block *, unsigned long event,
-			      void *ptr);
-static int ixgb_suspend(struct pci_dev *pdev, uint32_t state);
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* for netdump / net console */
 static void ixgb_netpoll(struct net_device *dev);
 #endif
 
-struct notifier_block ixgb_notifier_reboot = {
-	.notifier_call = ixgb_notify_reboot,
-	.next = NULL,
-	.priority = 0
-};
-
 /* Exported from other modules */
 
 extern void ixgb_check_options(struct ixgb_adapter *adapter);
@@ -130,9 +120,6 @@ static struct pci_driver ixgb_driver = {
 	.id_table = ixgb_pci_tbl,
 	.probe = ixgb_probe,
 	.remove = __devexit_p(ixgb_remove),
-	/* Power Managment Hooks */
-	.suspend = NULL,
-	.resume = NULL
 };
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -154,17 +141,12 @@ MODULE_LICENSE("GPL");
 
 static int __init ixgb_init_module(void)
 {
-	int ret;
 	printk(KERN_INFO "%s - version %s\n",
 	       ixgb_driver_string, ixgb_driver_version);
 
 	printk(KERN_INFO "%s\n", ixgb_copyright);
 
-	ret = pci_module_init(&ixgb_driver);
-	if (ret >= 0) {
-		register_reboot_notifier(&ixgb_notifier_reboot);
-	}
-	return ret;
+	return pci_module_init(&ixgb_driver);
 }
 
 module_init(ixgb_init_module);
@@ -178,7 +160,6 @@ module_init(ixgb_init_module);
 
 static void __exit ixgb_exit_module(void)
 {
-	unregister_reboot_notifier(&ixgb_notifier_reboot);
 	pci_unregister_driver(&ixgb_driver);
 }
 
@@ -2064,53 +2045,6 @@ static void ixgb_restore_vlan(struct ixg
 	}
 }
 
-/**
- * ixgb_notify_reboot - handles OS notification of reboot event.
- * @param nb notifier block, unused
- * @param event Event being passed to driver to act upon
- * @param p A pointer to our net device
- **/
-static int
-ixgb_notify_reboot(struct notifier_block *nb, unsigned long event, void *p)
-{
-	struct pci_dev *pdev = NULL;
-
-	switch (event) {
-	case SYS_DOWN:
-	case SYS_HALT:
-	case SYS_POWER_OFF:
-		while ((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
-			if (pci_dev_driver(pdev) == &ixgb_driver)
-				ixgb_suspend(pdev, 3);
-		}
-	}
-	return NOTIFY_DONE;
-}
-
-/**
- * ixgb_suspend - driver suspend function called from notify.
- * @param pdev pci driver structure used for passing to
- * @param state power state to enter 
- **/
-static int ixgb_suspend(struct pci_dev *pdev, uint32_t state)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgb_adapter *adapter = netdev->priv;
-
-	netif_device_detach(netdev);
-
-	if (netif_running(netdev))
-		ixgb_down(adapter, TRUE);
-
-	pci_save_state(pdev);
-
-	state = (state > 0) ? 3 : 0;
-	pci_set_power_state(pdev, state);
-	msec_delay(200);
-
-	return 0;
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs
_
