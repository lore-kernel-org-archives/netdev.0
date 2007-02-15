From: Maxim <maximlevitsky@gmail.com>
Subject: Subject:  [PATCH 2.6.20 004/005] dmfe: Add support for suspend/resume
Date: Thu, 15 Feb 2007 23:11:54 +0200
Message-ID: <200702152311.54407.maximlevitsky@gmail.com>
References: <200702152253.53680.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>
To: netdev@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161324AbXBOVMB@vger.kernel.org>
In-Reply-To: <200702152253.53680.maximlevitsky@gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Maxim Levitsky <maximlevitsky@gmail.com>
Subject:  [PATCH 2.6.20 004/005] dmfe: Add support for suspend/resume

This adds support for suspend resume

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>

---

--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c	2007-02-15 18:24:47.000000000 +0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c	2007-02-15 18:26:34.000000000 +0200
@@ -55,9 +55,6 @@
 
     TODO
 
-    Implement pci_driver::suspend() and pci_driver::resume()
-    power management methods.
-
     Check on 64 bit boxes.
     Check and fix on big endian boxes.
 
@@ -2050,11 +2047,56 @@ static struct pci_device_id dmfe_pci_tbl
 MODULE_DEVICE_TABLE(pci, dmfe_pci_tbl);
 
 
+
+static int dmfe_suspend(struct pci_dev *pci_dev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pci_dev);
+	struct dmfe_board_info *db = netdev_priv(dev);
+
+	/* Disable upper layer interface */
+	netif_device_detach (dev);
+
+	/* Disable Tx/Rx */
+	db->cr6_data &= ~(CR6_RXSC | CR6_TXSC);
+	update_cr6(db->cr6_data, dev->base_addr);
+
+	/* Disable Interrupt */
+	outl (0, dev->base_addr + DCR7);
+	outl (inl (dev->base_addr + DCR5), dev->base_addr + DCR5);
+
+	/* Fre RX buffers */
+	dmfe_free_rxbuffer (db);
+
+	/* Power down device*/
+	pci_set_power_state (pci_dev, pci_choose_state (pci_dev,state));
+	pci_save_state (pci_dev);
+
+	return 0;
+}
+
+static int dmfe_resume (struct pci_dev *pci_dev)
+{
+	struct net_device *dev = pci_get_drvdata (pci_dev);
+
+	pci_restore_state(pci_dev);
+	pci_set_power_state(pci_dev ,PCI_D0);
+
+	/* Re-initilize DM910X board */
+	dmfe_init_dm910x(dev);
+
+	/* Restart upper layer interface */
+	netif_device_attach(dev);
+
+	return 0;
+}
+
 static struct pci_driver dmfe_driver = {
 	.name		= "dmfe",
 	.id_table	= dmfe_pci_tbl,
 	.probe		= dmfe_init_one,
 	.remove		= __devexit_p(dmfe_remove_one),
+	.suspend        = dmfe_suspend,
+	.resume         = dmfe_resume
 };
 
 MODULE_AUTHOR("Sten Wang, sten_wang@davicom.com.tw");
