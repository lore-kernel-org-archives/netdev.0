From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 2.6.20 4/5] dmfe: Add support for suspend/resume
Date: Thu, 8 Feb 2007 23:15:07 +0200
Message-ID: <200702082315.07400.maximlevitsky@gmail.com>
References: <200702082305.26735.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:39734 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423405AbXBHVST convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:18:19 -0500
Received: by nf-out-0910.google.com with SMTP id o25so989776nfa
        for <netdev@vger.kernel.org>; Thu, 08 Feb 2007 13:18:18 -0800 (PST)
In-Reply-To: <200702082305.26735.maximlevitsky@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 2.6.20 4/5] dmfe: Add support for suspend/resume

This adds support for suspend resume

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>

---

--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c	2007-02-08 21:49:19.000000000 
+0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c	2007-02-08 22:02:03.000000000 
+0200
@@ -55,9 +55,6 @@
 
     TODO
 
-    Implement pci_driver::suspend() and pci_driver::resume()
-    power management methods.
-
     Check on 64 bit boxes.
     Check and fix on big endian boxes.
 
@@ -2054,11 +2051,56 @@ static struct pci_device_id dmfe_pci_tbl
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
+        .suspend        = dmfe_suspend,
+        .resume         = dmfe_resume
 };
 
 MODULE_AUTHOR("Sten Wang, sten_wang@davicom.com.tw");
