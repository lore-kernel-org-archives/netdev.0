From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 1/9] ixgb: Enabling MSI on a PCI slot (not PCI-X) may
 not work, so always disable MSI for PCI slots, enable message signalled
 interrupts on 82597EX based adapters
Date: Thu, 6 Jan 2005 17:22:56 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061546290.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2005-01-05 17:13:28.000000000 -0800
@@ -188,5 +188,9 @@ struct ixgb_adapter {
 	/* structs defined in ixgb_hw.h */
 	struct ixgb_hw hw;
 	struct ixgb_hw_stats stats;
+	uint32_t pci_state[16];
+#ifdef CONFIG_PCI_MSI
+	boolean_t have_msi;
+#endif
 };
 #endif /* _IXGB_H_ */
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-01-05 17:13:29.000000000 -0800
@@ -238,6 +238,23 @@ ixgb_up(struct ixgb_adapter *adapter)
 	ixgb_configure_rx(adapter);
 	ixgb_alloc_rx_buffers(adapter);
 
+#ifdef CONFIG_PCI_MSI
+	{
+	boolean_t pcix = (IXGB_READ_REG(&adapter->hw, STATUS) & 
+						  IXGB_STATUS_PCIX_MODE) ? TRUE : FALSE;
+	adapter->have_msi = TRUE;
+
+	if (!pcix)
+	   adapter->have_msi = FALSE;
+	else if((err = pci_enable_msi(adapter->pdev))) {
+		printk (KERN_ERR
+		 "Unable to allocate MSI interrupt Error: %d\n", err);
+		adapter->have_msi = FALSE;
+		/* proceed to try to request regular interrupt */
+	}
+	}
+
+#endif
 	if((err = request_irq(adapter->pdev->irq, &ixgb_intr,
 				  SA_SHIRQ | SA_SAMPLE_RANDOM,
 				  netdev->name, netdev)))
@@ -278,6 +278,11 @@ ixgb_down(struct ixgb_adapter *adapter, 
 
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
+#ifdef CONFIG_PCI_MSI
+	if(adapter->have_msi == TRUE)
+		pci_disable_msi(adapter->pdev);
+
+#endif
 	if(kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
 	adapter->link_speed = 0;
