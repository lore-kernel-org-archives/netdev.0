From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6-exp 2/2] netpoll support
Date: Mon, 22 Dec 2003 17:03:56 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312221702490.20044-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Add netpoll support.  [Prasanna S. Panshamukhi (prasanna@in.ibm.com)]


diff -Naurp net-drivers-2.5-exp/drivers/net/e1000/e1000_main.c net-drivers-2.5-exp/drivers/net/e1000.mod/e1000_main.c
--- net-drivers-2.5-exp/drivers/net/e1000/e1000_main.c	2003-12-16 17:19:19.000000000 -0800
+++ net-drivers-2.5-exp/drivers/net/e1000.mod/e1000_main.c	2003-12-16 17:20:00.000000000 -0800
@@ -30,7 +30,8 @@
 
 /* Change Log
  *
- * 5.2.26	11/13/03
+ * 5.2.27	12/14/03
+ *   o Added netpoll support.
  *   o Fixed endianess bug causing ethtool loopback diags to fail on ppc.
  *   o Use pdev->irq rather than netdev->irq in preparation for MSI support.
  *   o Report driver message on user override of InterruptThrottleRate
@@ -62,7 +63,7 @@
 
 char e1000_driver_name[] = "e1000";
 char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-char e1000_driver_version[] = "5.2.26-k1";
+char e1000_driver_version[] = "5.2.27-k1";
 char e1000_copyright[] = "Copyright (c) 1999-2003 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -179,6 +180,11 @@ static int e1000_suspend(struct pci_dev 
 static int e1000_resume(struct pci_dev *pdev);
 #endif
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/* for netdump / net console */
+static void e1000_netpoll (struct net_device *dev);
+#endif
+
 struct notifier_block e1000_notifier_reboot = {
 	.notifier_call	= e1000_notify_reboot,
 	.next		= NULL,
@@ -431,6 +437,9 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->vlan_rx_register = e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid = e1000_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = e1000_vlan_rx_kill_vid;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = e1000_netpoll;
+#endif
 
 	netdev->mem_start = mmio_start;
 	netdev->mem_end = mmio_start + mmio_len;
@@ -2886,4 +2895,20 @@ e1000_resume(struct pci_dev *pdev)
 }
 #endif
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+
+static void e1000_netpoll (struct net_device *dev)
+{
+	struct e1000_adapter *adapter = dev->priv;
+	disable_irq(adapter->pdev->irq);
+	e1000_intr (adapter->pdev->irq, dev, NULL);
+	enable_irq(adapter->pdev->irq);
+}
+#endif
+
 /* e1000_main.c */
