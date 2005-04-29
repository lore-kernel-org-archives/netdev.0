From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.4 3/16] e1000:MSI support for PCI-e
 adapters
Date: Thu, 28 Apr 2005 20:10:58 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281958280.30085-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

MSI support for PCI-e adapters

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000.h net-drivers-2.4/drivers/net/e1000.new/e1000.h
--- net-drivers-2.4/drivers/net/e1000/e1000.h	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000.h	2005-04-12 23:00:55.000000000 -0700
@@ -259,5 +259,8 @@ struct e1000_adapter {
 
 	uint32_t pci_state[16];
 	int msg_enable;
+#ifdef CONFIG_PCI_MSI
+	boolean_t have_msi;
+#endif
 };
 #endif /* _E1000_H_ */
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2005-04-12 23:00:55.000000000 -0700
@@ -309,6 +309,16 @@ e1000_up(struct e1000_adapter *adapter)
 	e1000_configure_rx(adapter);
 	e1000_alloc_rx_buffers(adapter);
 
+#ifdef CONFIG_PCI_MSI
+	if(adapter->hw.mac_type > e1000_82547_rev_2) {
+		adapter->have_msi = TRUE;
+		if((err = pci_enable_msi(adapter->pdev))) {
+			DPRINTK(PROBE, ERR,
+			 "Unable to allocate MSI interrupt Error: %d\n", err);
+			adapter->have_msi = FALSE;
+		}
+	}
+#endif
 	if((err = request_irq(adapter->pdev->irq, &e1000_intr,
 		              SA_SHIRQ | SA_SAMPLE_RANDOM,
 		              netdev->name, netdev)))
@@ -330,6 +330,11 @@ e1000_down(struct e1000_adapter *adapter
 
 	e1000_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
+#ifdef CONFIG_PCI_MSI
+	if(adapter->hw.mac_type > e1000_82547_rev_2 &&
+	   adapter->have_msi == TRUE)
+		pci_disable_msi(adapter->pdev);
+#endif
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
