From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: netif_carrier_on()/off() for xircom_tulip_cb
Date: Fri, 20 Feb 2004 17:21:24 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402201721.24047.srompf@isg.de>
References: <200402151504.22648.srompf@isg.de> <4033FAF6.2090200@pobox.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_EQjNA7alc3Y2zQJ"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4033FAF6.2090200@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_EQjNA7alc3Y2zQJ
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

> Please resend patches that may be applied with "patch -p1",
> not "patch -p0".

ok., here's the first, suspend/resume

--Boundary-00=_EQjNA7alc3Y2zQJ
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="xircom_tulip_cb_pm.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="xircom_tulip_cb_pm.diff"

--- jeffdir/drivers/net/tulip/xircom_tulip_cb.c.old	2004-02-14 14:33:03.000000000 +0100
+++ jeffdir/drivers/net/tulip/xircom_tulip_cb.c	2004-02-15 13:07:49.000000000 +0100
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

--Boundary-00=_EQjNA7alc3Y2zQJ--
