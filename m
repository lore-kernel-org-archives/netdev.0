From: Stefan Rompf <srompf@isg.de>
Subject: Patch: working suspend/resume for xircom_tulip_cb
Date: Sun, 15 Feb 2004 15:02:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402151502.59735.srompf@isg.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Tw3LAvXFPKchaLa"
Cc: jgarzik@pobox.com, ionut@cs.columbia.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_Tw3LAvXFPKchaLa
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

attached is a patch against 2.6.3rc2 that fixes suspend/resume for the 
ethernet device of my Xircom RBEM56G-100 pc card. Previously, the driver did 
not survive the resume operation. I still have problems when I remove the 
card during suspend, but that yields to a different code path.

I could check with one laptop and one card, so the patch might need broader 
testing, but it works nicely in my configuration.

Please apply if it looks ok.

Stefan

--Boundary-00=_Tw3LAvXFPKchaLa
Content-Type: text/x-diff;
  charset="us-ascii";
  name="xircom_tulip_cb_pm.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="xircom_tulip_cb_pm.diff"

--- drivers/net/tulip/xircom_tulip_cb.c.old	2004-02-14 14:33:03.000000000 +0100
+++ drivers/net/tulip/xircom_tulip_cb.c	2004-02-15 13:07:49.000000000 +0100
@@ -329,6 +329,9 @@ struct xircom_private {
 	int saved_if_port;
 	struct pci_dev *pdev;
 	spinlock_t lock;
+#ifdef CONFIG_PM
+	u32 pci_state[16];
+#endif
 };
 
 static int mdio_read(struct net_device *dev, int phy_id, int location);
@@ -749,6 +752,7 @@ xircom_up(struct net_device *dev)
 	long ioaddr = dev->base_addr;
 	int i;
 
+	xircom_init_ring(dev);
 	/* Clear the tx ring */
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		tp->tx_skbuff[i] = 0;
@@ -801,8 +805,6 @@ xircom_open(struct net_device *dev)
 	if (request_irq(dev->irq, &xircom_interrupt, SA_SHIRQ, dev->name, dev))
 		return -EAGAIN;
 
-	xircom_init_ring(dev);
-
 	xircom_up(dev);
 	tp->open = 1;
 
@@ -1668,6 +1670,11 @@ static int xircom_suspend(struct pci_dev
 	printk(KERN_INFO "xircom_suspend(%s)\n", dev->name);
 	if (tp->open)
 		xircom_down(dev);
+
+	pci_save_state(pdev, tp->pci_state);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, 3);
+
 	return 0;
 }
 
@@ -1678,6 +1685,10 @@ static int xircom_resume(struct pci_dev 
 	struct xircom_private *tp = dev->priv;
 	printk(KERN_INFO "xircom_resume(%s)\n", dev->name);
 
+	pci_set_power_state(pdev,0);
+	pci_enable_device(pdev);
+	pci_restore_state(pdev, tp->pci_state);
+
 	/* Bring the chip out of sleep mode.
 	   Caution: Snooze mode does not work with some boards! */
 	if (xircom_tbl[tp->chip_id].flags & HAS_ACPI)

--Boundary-00=_Tw3LAvXFPKchaLa--
