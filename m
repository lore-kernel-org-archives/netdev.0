From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-02-03
Date: Fri, 03 Feb 2012 01:15:07 +0100
Message-ID: <4F2B270B.2090400@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mkl@blackshift.org, Netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56447 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821Ab2BCAPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 19:15:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

here is a group of CAN driver fixes intended for 3.3. The first one by
Wolfgang Grandegger fixing a race condition in the TX path the cc770
driver. The next one, by Wolfgang Zarre, adds locking to the indirect
register access function. Then follows a patch by Wolfgang Grandegger
which fixes the irq flood on flexcan (on mx28) which is triggered by
error interrupts. Xi Wang's patch fixes the error passive level test
on pch_can. Stephane Grosjean contribues a patch for peak_pci which
fixes the linking of the channels avoiding an kernel oops when the
driver is removed. The next patch by Wolfgang Grandegger fixes the
ti_hecc driver, by using netif_rx in interrupt context. The last patch
comes from Sebastian Haas, it removes a double netif_device_detach
from the error path of the ems_usb driver.

Please let me know if there are problems!

Marc

---

The following changes since commit ba7605745d5c99f0e71b3ec6c7cb5ed6afe540ad:

  caif: Bugfix double kfree_skb upon xmit failure (2012-02-02 14:35:12 -0500)

are available in the git repository at:
  git://gitorious.org/linux-can/linux-can.git master

Sebastian Haas (1):
      can: ems_usb: Removed double netif_device_detach

Stephane Grosjean (1):
      can: peak_pci: Fix the way channels are linked together

Wolfgang Grandegger (3):
      can: flexcan: fix irq flooding by clearing all interrupt sources
      can: cc770: store echo skb before starting the transfer
      can: ti_hecc: use netif_rx in the interrupt

Wolfgang Zarre (1):
      can: cc770: Fix indirect access deadlock on ISA cards

Xi Wang (1):
      can: pch_can: fix error passive level test

 drivers/net/can/cc770/cc770.c      |    4 +++-
 drivers/net/can/cc770/cc770_isa.c  |   16 +++++++++++++++-
 drivers/net/can/flexcan.c          |    7 ++++++-
 drivers/net/can/pch_can.c          |    3 ++-
 drivers/net/can/sja1000/peak_pci.c |   23 +++++++++--------------
 drivers/net/can/ti_hecc.c          |    3 ++-
 drivers/net/can/usb/ems_usb.c      |    9 ---------
 7 files changed, 37 insertions(+), 28 deletions(-)

diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc770.c
index 7668967..c30f0e6 100644
--- a/drivers/net/can/cc770/cc770.c
+++ b/drivers/net/can/cc770/cc770.c
@@ -440,12 +440,14 @@ static netdev_tx_t cc770_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i < dlc; i++)
 		cc770_write_reg(priv, msgobj[mo].data[i], cf->data[i]);
 
+	/* Store echo skb before starting the transfer */
+	can_put_echo_skb(skb, dev, 0);
+
 	cc770_write_reg(priv, msgobj[mo].ctrl1,
 			RMTPND_RES | TXRQST_SET | CPUUPD_RES | NEWDAT_UNC);
 
 	stats->tx_bytes += dlc;
 
-	can_put_echo_skb(skb, dev, 0);
 
 	/*
 	 * HM: We had some cases of repeated IRQs so make sure the
diff --git a/drivers/net/can/cc770/cc770_isa.c b/drivers/net/can/cc770/cc770_isa.c
index 4be5fe2..9f3a25c 100644
--- a/drivers/net/can/cc770/cc770_isa.c
+++ b/drivers/net/can/cc770/cc770_isa.c
@@ -110,6 +110,11 @@ MODULE_PARM_DESC(bcr, "Bus configuration register (default=0x40 [CBY])");
 #define CC770_IOSIZE          0x20
 #define CC770_IOSIZE_INDIRECT 0x02
 
+/* Spinlock for cc770_isa_port_write_reg_indirect
+ * and cc770_isa_port_read_reg_indirect
+ */
+static DEFINE_SPINLOCK(cc770_isa_port_lock);
+
 static struct platform_device *cc770_isa_devs[MAXDEV];
 
 static u8 cc770_isa_mem_read_reg(const struct cc770_priv *priv, int reg)
@@ -138,18 +143,27 @@ static u8 cc770_isa_port_read_reg_indirect(const struct cc770_priv *priv,
 					     int reg)
 {
 	unsigned long base = (unsigned long)priv->reg_base;
+	unsigned long flags;
+	u8 val;
 
+	spin_lock_irqsave(&cc770_isa_port_lock, flags);
 	outb(reg, base);
-	return inb(base + 1);
+	val = inb(base + 1);
+	spin_unlock_irqrestore(&cc770_isa_port_lock, flags);
+
+	return val;
 }
 
 static void cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
 						int reg, u8 val)
 {
 	unsigned long base = (unsigned long)priv->reg_base;
+	unsigned long flags;
 
+	spin_lock_irqsave(&cc770_isa_port_lock, flags);
 	outb(reg, base);
 	outb(val, base + 1);
+	spin_unlock_irqrestore(&cc770_isa_port_lock, flags);
 }
 
 static int __devinit cc770_isa_probe(struct platform_device *pdev)
diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 7fd8089..96d2357 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -118,6 +118,9 @@
 	(FLEXCAN_ESR_TWRN_INT | FLEXCAN_ESR_RWRN_INT | FLEXCAN_ESR_BOFF_INT)
 #define FLEXCAN_ESR_ERR_ALL \
 	(FLEXCAN_ESR_ERR_BUS | FLEXCAN_ESR_ERR_STATE)
+#define FLEXCAN_ESR_ALL_INT \
+	(FLEXCAN_ESR_TWRN_INT | FLEXCAN_ESR_RWRN_INT | \
+	 FLEXCAN_ESR_BOFF_INT | FLEXCAN_ESR_ERR_INT)
 
 /* FLEXCAN interrupt flag register (IFLAG) bits */
 #define FLEXCAN_TX_BUF_ID		8
@@ -577,7 +580,9 @@ static irqreturn_t flexcan_irq(int irq, void *dev_id)
 
 	reg_iflag1 = flexcan_read(&regs->iflag1);
 	reg_esr = flexcan_read(&regs->esr);
-	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
+	/* ACK all bus error and state change IRQ sources */
+	if (reg_esr & FLEXCAN_ESR_ALL_INT)
+		flexcan_write(reg_esr & FLEXCAN_ESR_ALL_INT, &regs->esr);
 
 	/*
 	 * schedule NAPI in case of:
diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index d11fbb2..6edc25e 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -66,6 +66,7 @@
 #define PCH_IF_CREQ_BUSY	BIT(15)
 
 #define PCH_STATUS_INT		0x8000
+#define PCH_RP			0x00008000
 #define PCH_REC			0x00007f00
 #define PCH_TEC			0x000000ff
 
@@ -527,7 +528,7 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		priv->can.can_stats.error_passive++;
 		state = CAN_STATE_ERROR_PASSIVE;
 		cf->can_id |= CAN_ERR_CRTL;
-		if (((errc & PCH_REC) >> 8) > 127)
+		if (errc & PCH_RP)
 			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
 		if ((errc & PCH_TEC) > 127)
 			cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 2c7f503..2147959 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -39,9 +39,9 @@ MODULE_LICENSE("GPL v2");
 #define DRV_NAME  "peak_pci"
 
 struct peak_pci_chan {
-	void __iomem *cfg_base;	     /* Common for all channels */
-	struct net_device *next_dev; /* Chain of network devices */
-	u16 icr_mask;		     /* Interrupt mask for fast ack */
+	void __iomem *cfg_base;		/* Common for all channels */
+	struct net_device *prev_dev;	/* Chain of network devices */
+	u16 icr_mask;			/* Interrupt mask for fast ack */
 };
 
 #define PEAK_PCI_CAN_CLOCK	(16000000 / 2)
@@ -98,7 +98,7 @@ static int __devinit peak_pci_probe(struct pci_dev *pdev,
 {
 	struct sja1000_priv *priv;
 	struct peak_pci_chan *chan;
-	struct net_device *dev, *dev0 = NULL;
+	struct net_device *dev;
 	void __iomem *cfg_base, *reg_base;
 	u16 sub_sys_id, icr;
 	int i, err, channels;
@@ -196,18 +196,14 @@ static int __devinit peak_pci_probe(struct pci_dev *pdev,
 		}
 
 		/* Create chain of SJA1000 devices */
-		if (i == 0)
-			dev0 = dev;
-		else
-			chan->next_dev = dev;
+		chan->prev_dev = pci_get_drvdata(pdev);
+		pci_set_drvdata(pdev, dev);
 
 		dev_info(&pdev->dev,
 			 "%s at reg_base=0x%p cfg_base=0x%p irq=%d\n",
 			 dev->name, priv->reg_base, chan->cfg_base, dev->irq);
 	}
 
-	pci_set_drvdata(pdev, dev0);
-
 	/* Enable interrupts */
 	writew(icr, cfg_base + PITA_ICR + 2);
 
@@ -217,12 +213,11 @@ failure_remove_channels:
 	/* Disable interrupts */
 	writew(0x0, cfg_base + PITA_ICR + 2);
 
-	for (dev = dev0; dev; dev = chan->next_dev) {
+	for (dev = pci_get_drvdata(pdev); dev; dev = chan->prev_dev) {
 		unregister_sja1000dev(dev);
 		free_sja1000dev(dev);
 		priv = netdev_priv(dev);
 		chan = priv->priv;
-		dev = chan->next_dev;
 	}
 
 	pci_iounmap(pdev, reg_base);
@@ -241,7 +236,7 @@ failure_disable_pci:
 
 static void __devexit peak_pci_remove(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev); /* First device */
+	struct net_device *dev = pci_get_drvdata(pdev); /* Last device */
 	struct sja1000_priv *priv = netdev_priv(dev);
 	struct peak_pci_chan *chan = priv->priv;
 	void __iomem *cfg_base = chan->cfg_base;
@@ -255,7 +250,7 @@ static void __devexit peak_pci_remove(struct pci_dev *pdev)
 		dev_info(&pdev->dev, "removing device %s\n", dev->name);
 		unregister_sja1000dev(dev);
 		free_sja1000dev(dev);
-		dev = chan->next_dev;
+		dev = chan->prev_dev;
 		if (!dev)
 			break;
 		priv = netdev_priv(dev);
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index df809e3..5a2e1e3 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -745,9 +745,10 @@ static int ti_hecc_error(struct net_device *ndev, int int_status,
 		}
 	}
 
-	netif_receive_skb(skb);
+	netif_rx(skb);
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
+
 	return 0;
 }
 
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 9697c14..7dae64d 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -627,9 +627,6 @@ static int ems_usb_start(struct ems_usb *dev)
 
 		err = usb_submit_urb(urb, GFP_KERNEL);
 		if (err) {
-			if (err == -ENODEV)
-				netif_device_detach(dev->netdev);
-
 			usb_unanchor_urb(urb);
 			usb_free_coherent(dev->udev, RX_BUFFER_SIZE, buf,
 					  urb->transfer_dma);
@@ -659,9 +656,6 @@ static int ems_usb_start(struct ems_usb *dev)
 
 	err = usb_submit_urb(dev->intr_urb, GFP_KERNEL);
 	if (err) {
-		if (err == -ENODEV)
-			netif_device_detach(dev->netdev);
-
 		dev_warn(netdev->dev.parent, "intr URB submit failed: %d\n",
 			 err);
 
@@ -692,9 +686,6 @@ static int ems_usb_start(struct ems_usb *dev)
 	return 0;
 
 failed:
-	if (err == -ENODEV)
-		netif_device_detach(dev->netdev);
-
 	dev_warn(netdev->dev.parent, "couldn't submit control: %d\n", err);
 
 	return err;

-- 
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |
