From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Sun, 3 Jun 2007 12:37:35 +0200
Message-ID: <200706031237.36773.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Valerie Henson <val@nmt.edu>,
	Nigel Cunningham <nigel@nigel.suspend2.net>,
	Pavel Machek <pavel@ucw.cz>, Peer Chen <peer.chen@uli.com.tw>
To: "linux-pm" <linux-pm@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:34140 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756745AbXFCKcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 06:32:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki <rjw@sisk.pl>

Add suspend/resume support to the uli526x network driver (tested on x86_64,
with 'Ethernet controller: ALi Corporation M5263 Ethernet Controller, rev 40').

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

 drivers/net/tulip/uli526x.c |  120 ++++++++++++++++++++++++++++++++++++++------
 1 file changed, 105 insertions(+), 15 deletions(-)

Index: linux-2.6.22-rc3/drivers/net/tulip/uli526x.c
===================================================================
--- linux-2.6.22-rc3.orig/drivers/net/tulip/uli526x.c	2007-06-03 12:10:41.000000000 +0200
+++ linux-2.6.22-rc3/drivers/net/tulip/uli526x.c	2007-06-03 12:14:33.000000000 +0200
@@ -220,6 +220,10 @@ static int mode = 8;
 static int uli526x_open(struct net_device *);
 static int uli526x_start_xmit(struct sk_buff *, struct net_device *);
 static int uli526x_stop(struct net_device *);
+#ifdef CONFIG_PM
+static int uli526x_suspend(struct pci_dev *pdev, pm_message_t state);
+static int uli526x_resume(struct pci_dev *pdev);
+#endif
 static struct net_device_stats * uli526x_get_stats(struct net_device *);
 static void uli526x_set_filter_mode(struct net_device *);
 static const struct ethtool_ops netdev_ethtool_ops;
@@ -425,21 +429,14 @@ static void __devexit uli526x_remove_one
 
 
 /*
- *	Open the interface.
- *	The interface is opened whenever "ifconfig" activates it.
+ *	Bring the interface up.
+ *	Used by uli526x_open and uli526x_resume.
  */
 
-static int uli526x_open(struct net_device *dev)
+static void uli526x_up(struct net_device *dev)
 {
-	int ret;
 	struct uli526x_board_info *db = netdev_priv(dev);
 
-	ULI526X_DBUG(0, "uli526x_open", 0);
-
-	ret = request_irq(dev->irq, &uli526x_interrupt, IRQF_SHARED, dev->name, dev);
-	if (ret)
-		return ret;
-
 	/* system variable init */
 	db->cr6_data = CR6_DEFAULT | uli526x_cr6_user_set;
 	db->tx_packet_cnt = 0;
@@ -467,7 +464,25 @@ static int uli526x_open(struct net_devic
 	db->timer.data = (unsigned long)dev;
 	db->timer.function = &uli526x_timer;
 	add_timer(&db->timer);
+}
+
+
+/*
+ *	Open the interface.
+ *	The interface is opened whenever "ifconfig" activates it.
+ */
 
+static int uli526x_open(struct net_device *dev)
+{
+	int ret;
+
+	ULI526X_DBUG(0, "uli526x_open", 0);
+
+	ret = request_irq(dev->irq, &uli526x_interrupt, IRQF_SHARED, dev->name, dev);
+	if (ret)
+		return ret;
+
+	uli526x_up(dev);
 	return 0;
 }
 
@@ -613,17 +628,15 @@ static int uli526x_start_xmit(struct sk_
 
 
 /*
- *	Stop the interface.
- *	The interface is stopped when it is brought.
+ *	Take the interface down.
+ *	Used by uli526x_stop and uli526x_suspend.
  */
 
-static int uli526x_stop(struct net_device *dev)
+static void uli526x_down(struct net_device *dev)
 {
 	struct uli526x_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = dev->base_addr;
 
-	ULI526X_DBUG(0, "uli526x_stop", 0);
-
 	/* disable system */
 	netif_stop_queue(dev);
 
@@ -634,6 +647,21 @@ static int uli526x_stop(struct net_devic
 	outl(ULI526X_RESET, ioaddr + DCR0);
 	udelay(5);
 	phy_write(db->ioaddr, db->phy_addr, 0, 0x8000, db->chip_id);
+}
+
+
+/*
+ *	Stop the interface.
+ *	The interface is stopped when it is brought.
+ */
+
+static int uli526x_stop(struct net_device *dev)
+{
+	struct uli526x_board_info *db = netdev_priv(dev);
+
+	ULI526X_DBUG(0, "uli526x_stop", 0);
+
+	uli526x_down(dev);
 
 	/* free interrupt */
 	free_irq(dev->irq, dev);
@@ -654,6 +682,64 @@ static int uli526x_stop(struct net_devic
 }
 
 
+#ifdef CONFIG_PM
+
+/*
+ *	Suspend the interface.
+ */
+
+static int uli526x_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	ULI526X_DBUG(0, "uli526x_suspend", 0);
+
+	if (dev && netdev_priv(dev)) {
+		if (netif_running(dev)) {
+			netif_device_detach(dev);
+			uli526x_down(dev);
+		}
+		pci_save_state(pdev);
+		pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
+		pci_disable_device(pdev);
+		pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	}
+	return 0;
+}
+
+/*
+ *	Resume the interface.
+ */
+
+static int uli526x_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct uli526x_board_info *db = netdev_priv(dev);
+	int err;
+
+	ULI526X_DBUG(0, "uli526x_resume", 0);
+
+	if (dev && db) {
+		pci_set_power_state(pdev, PCI_D0);
+		err = pci_enable_device(pdev);
+		if (err) {
+			printk(KERN_WARNING "%s: Could not enable device \n",
+				dev->name);
+			return err;
+		}
+		pci_restore_state(pdev);
+		pci_set_master(pdev);
+		if (netif_running(dev)) {
+			uli526x_up(dev);
+			netif_device_attach(dev);
+		}
+	}
+	return 0;
+}
+
+#endif /* CONFIG_PM */
+
+
 /*
  *	M5261/M5263 insterrupt handler
  *	receive the packet to upper layer, free the transmitted packet
@@ -1689,6 +1775,10 @@ static struct pci_driver uli526x_driver 
 	.id_table	= uli526x_pci_tbl,
 	.probe		= uli526x_init_one,
 	.remove		= __devexit_p(uli526x_remove_one),
+#ifdef CONFIG_PM
+	.suspend	= uli526x_suspend,
+	.resume		= uli526x_resume,
+#endif
 };
 
 MODULE_AUTHOR("Peer Chen, peer.chen@uli.com.tw");
