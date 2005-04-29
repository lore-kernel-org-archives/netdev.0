From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 8/11] ixgb: Remove hook for suspend,
 no power management
Date: Thu, 28 Apr 2005 19:04:32 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281859020.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove hook for suspend. No power management in 10GbE Controllers

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-04-05 23:06:36.332229456 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-04-05 23:06:38.283932752 -0700
@@ -120,33 +120,20 @@ static int ixgb_change_mtu(struct net_de
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
 
 static struct pci_driver ixgb_driver = {
-	.name = ixgb_driver_name,
+	.name     = ixgb_driver_name,
 	.id_table = ixgb_pci_tbl,
-	.probe = ixgb_probe,
-	.remove = __devexit_p(ixgb_remove),
-	/* Power Managment Hooks */
-	.suspend = NULL,
-	.resume = NULL
+	.probe    = ixgb_probe,
+	.remove   = __devexit_p(ixgb_remove),
 };
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -169,17 +179,12 @@ MODULE_LICENSE("GPL");
 static int __init
 ixgb_init_module(void)
 {
-	int ret;
 	printk(KERN_INFO "%s - version %s\n",
 	       ixgb_driver_string, ixgb_driver_version);
 
 	printk(KERN_INFO "%s\n", ixgb_copyright);
 
-	ret = pci_module_init(&ixgb_driver);
-	if(ret >= 0) {
-		register_reboot_notifier(&ixgb_notifier_reboot);
-	}
-	return ret;
+	return pci_module_init(&ixgb_driver);
 }
 
 module_init(ixgb_init_module);
@@ -194,7 +194,6 @@ module_init(ixgb_init_module);
 static void __exit
 ixgb_exit_module(void)
 {
-	unregister_reboot_notifier(&ixgb_notifier_reboot);
 	pci_unregister_driver(&ixgb_driver);
 }
 
@@ -2121,54 +2092,6 @@ ixgb_restore_vlan(struct ixgb_adapter *a
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
-	switch(event) {
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
-static int
-ixgb_suspend(struct pci_dev *pdev, uint32_t state)
-{
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgb_adapter *adapter = netdev->priv;
-
-	netif_device_detach(netdev);
-
-	if(netif_running(netdev))
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
