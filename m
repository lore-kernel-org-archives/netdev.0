From: John Linn <john.linn@xilinx.com>
Subject: [PATCH] [V2] net: emaclite: adding MDIO and phy lib support
Date: Fri, 5 Feb 2010 15:40:46 -0700
Message-ID: <3d0d49ee-ead6-4286-8486-193f1f10345f@VA3EHSMHS024.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: john.williams@petalogix.com, John Linn <john.linn@xilinx.com>,
	Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:43536
	"EHLO VA3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934003Ab0BEWlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 17:41:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes add MDIO and phy lib support to the driver as the
IP core now supports the MDIO bus.

The MDIO bus and phy are added as a child to the emaclite in the device
tree as illustrated below.

mdio {
	#address-cells = <1>;
	#size-cells = <0>;
	compatible = "xlnx,emaclite-mdio";
	phy0: phy@7 {
		reg = <7>;
	} ;
}

Signed-off-by: Sadanand Mutyala <Sadanand.Mutyala@xilinx.com>
Signed-off-by: John Linn <john.linn@xilinx.com>

---

V2 - updated it for Grant's comments, except I couldn't find any tabs
converted to white space issue, let's see if V2 has it also
---
 drivers/net/Kconfig           |    1 +
 drivers/net/xilinx_emaclite.c |  393 ++++++++++++++++++++++++++++++++++++-----
 2 files changed, 351 insertions(+), 43 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dd9a09c..9509a36 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1939,6 +1939,7 @@ config ATL2
 config XILINX_EMACLITE
 	tristate "Xilinx 10/100 Ethernet Lite support"
 	depends on PPC32 || MICROBLAZE
+	select PHYLIB
 	help
 	  This driver supports the 10/100 Ethernet Lite from Xilinx.
 
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 8c777ba..02f18dd 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -22,11 +22,17 @@
 
 #include <linux/of_device.h>
 #include <linux/of_platform.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
 
 #define DRIVER_NAME "xilinx_emaclite"
 
 /* Register offsets for the EmacLite Core */
 #define XEL_TXBUFF_OFFSET 	0x0		/* Transmit Buffer */
+#define XEL_MDIOADDR_OFFSET	0x07E4		/* MDIO Address Register */
+#define XEL_MDIOWR_OFFSET	0x07E8		/* MDIO Write Data Register */
+#define XEL_MDIORD_OFFSET	0x07EC		/* MDIO Read Data Register */
+#define XEL_MDIOCTRL_OFFSET	0x07F0		/* MDIO Control Register */
 #define XEL_GIER_OFFSET		0x07F8		/* GIE Register */
 #define XEL_TSR_OFFSET		0x07FC		/* Tx status */
 #define XEL_TPLR_OFFSET		0x07F4		/* Tx packet length */
@@ -37,6 +43,22 @@
 
 #define XEL_BUFFER_OFFSET	0x0800		/* Next Tx/Rx buffer's offset */
 
+/* MDIO Address Register Bit Masks */
+#define XEL_MDIOADDR_REGADR_MASK  0x0000001F	/* Register Address */
+#define XEL_MDIOADDR_PHYADR_MASK  0x000003E0	/* PHY Address */
+#define XEL_MDIOADDR_PHYADR_SHIFT 5
+#define XEL_MDIOADDR_OP_MASK	  0x00000400	/* RD/WR Operation */
+
+/* MDIO Write Data Register Bit Masks */
+#define XEL_MDIOWR_WRDATA_MASK	  0x0000FFFF	/* Data to be Written */
+
+/* MDIO Read Data Register Bit Masks */
+#define XEL_MDIORD_RDDATA_MASK	  0x0000FFFF	/* Data to be Read */
+
+/* MDIO Control Register Bit Masks */
+#define XEL_MDIOCTRL_MDIOSTS_MASK 0x00000001	/* MDIO Status Mask */
+#define XEL_MDIOCTRL_MDIOEN_MASK  0x00000008	/* MDIO Enable */
+
 /* Global Interrupt Enable Register (GIER) Bit Masks */
 #define XEL_GIER_GIE_MASK	0x80000000 	/* Global Enable */
 
@@ -87,6 +109,13 @@
  * @reset_lock:		lock used for synchronization
  * @deferred_skb:	holds an skb (for transmission at a later time) when the
  *			Tx buffer is not free
+ * @phy_dev:		pointer to the PHY device
+ * @phy_node:		pointer to the PHY device node
+ * @mii_bus:		pointer to the MII bus
+ * @mdio_irqs:		IRQs table for MDIO bus
+ * @last_link:		last link status
+ * @has_mdio:		indicates whether MDIO is included in the HW
+ * @mdio_mutex:		protects MDIO accesses
  */
 struct net_local {
 
@@ -100,6 +129,16 @@ struct net_local {
 
 	spinlock_t reset_lock;
 	struct sk_buff *deferred_skb;
+
+	struct phy_device *phy_dev;
+	struct device_node *phy_node;
+
+	struct mii_bus *mii_bus;
+	int mdio_irqs[PHY_MAX_ADDR];
+
+	int last_link;
+	bool has_mdio;
+	struct mutex mdio_mutex;
 };
 
 
@@ -431,7 +470,7 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 }
 
 /**
- * xemaclite_set_mac_address - Set the MAC address for this device
+ * xemaclite_update_address - Update the MAC address in the device
  * @drvdata:	Pointer to the Emaclite device private data
  * @address_ptr:Pointer to the MAC address (MAC address is a 48-bit value)
  *
@@ -441,8 +480,8 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
  * The MAC address can be programmed using any of the two transmit
  * buffers (if configured).
  */
-static void xemaclite_set_mac_address(struct net_local *drvdata,
-				      u8 *address_ptr)
+static void xemaclite_update_address(struct net_local *drvdata,
+				     u8 *address_ptr)
 {
 	void __iomem *addr;
 	u32 reg_data;
@@ -465,6 +504,30 @@ static void xemaclite_set_mac_address(struct net_local *drvdata,
 }
 
 /**
+ * xemaclite_set_mac_address - Set the MAC address for this device
+ * @dev:	Pointer to the network device instance
+ * @addr:	Void pointer to the sockaddr structure
+ *
+ * This function copies the HW address from the sockaddr strucutre to the
+ * net_device structure and updates the address in HW.
+ *
+ * Return:	Error if the net device is busy or 0 if the addr is set
+ *		successfully
+ */
+static int xemaclite_set_mac_address(struct net_device *dev, void *address)
+{
+	struct net_local *lp = (struct net_local *) netdev_priv(dev);
+	struct sockaddr *addr = address;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	xemaclite_update_address(lp, dev->dev_addr);
+	return 0;
+}
+
+/**
  * xemaclite_tx_timeout - Callback for Tx Timeout
  * @dev:	Pointer to the network device
  *
@@ -641,12 +704,228 @@ static irqreturn_t xemaclite_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+/**********************/
+/* MDIO Bus functions */
+/**********************/
+
+/**
+ * xemaclite_mdio_wait - Wait for the MDIO to be ready to use
+ * @lp:		Pointer to the Emaclite device private data
+ *
+ * This function waits till the device is ready to accept a new MDIO
+ * request. Since this function uses msleep, the mdio_mutex is used
+ * to protect MDIO processsing.
+ *
+ * Return:	0 for success or ETIMEDOUT for a timeout
+ */
+
+static int xemaclite_mdio_wait(struct net_local *lp)
+{
+	long end = jiffies + 2;
+
+	/* wait for the MDIO interface to not be busy or timeout
+	   after some time.
+	*/
+	while (in_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET) &
+			XEL_MDIOCTRL_MDIOSTS_MASK) {
+		if (end - jiffies <= 0) {
+			WARN_ON(1);
+			return -ETIMEDOUT;
+		}
+		msleep(1);
+	}
+	return 0;
+}
+
+/**
+ * xemaclite_mdio_read - Read from a given MII management register
+ * @bus:	the mii_bus struct
+ * @phy_id:	the phy address
+ * @reg:	register number to read from
+ *
+ * This function waits till the device is ready to accept a new MDIO
+ * request and then writes the phy address to the MDIO Address register
+ * and reads data from MDIO Read Data register, when its available.
+ *
+ * Return:	Value read from the MII management register
+ */
+static int xemaclite_mdio_read(struct mii_bus *bus, int phy_id, int reg)
+{
+	struct net_local *lp = bus->priv;
+	u32 ctrl_reg;
+	u32 rc;
+
+	mutex_lock(&lp->mdio_mutex);
+
+	if (xemaclite_mdio_wait(lp))
+		return -ETIMEDOUT;
+
+	/* Write the PHY address, register number and set the OP bit in the
+	 * MDIO Address register. Set the Status bit in the MDIO Control
+	 * register to start a MDIO read transaction.
+	 */
+	ctrl_reg = in_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	out_be32(lp->base_addr + XEL_MDIOADDR_OFFSET,
+		 XEL_MDIOADDR_OP_MASK |
+		 ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg));
+	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
+		 ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK);
+
+	if (xemaclite_mdio_wait(lp))
+		return -ETIMEDOUT;
+
+	rc = in_be32(lp->base_addr + XEL_MDIORD_OFFSET);
+
+	mutex_unlock(&lp->mdio_mutex);
+
+	dev_dbg(&lp->ndev->dev,
+		"xemaclite_mdio_read(phy_id=%i, reg=%x) == %x\n",
+		phy_id, reg, rc);
+
+	return rc;
+}
+
+/**
+ * xemaclite_mdio_write - Write to a given MII management register
+ * @bus:	the mii_bus struct
+ * @phy_id:	the phy address
+ * @reg:	register number to write to
+ * @val:	value to write to the register number specified by reg
+ *
+ * This fucntion waits till the device is ready to accept a new MDIO
+ * request and then writes the val to the MDIO Write Data register.
+ */
+static int xemaclite_mdio_write(struct mii_bus *bus, int phy_id, int reg,
+				u16 val)
+{
+	struct net_local *lp = bus->priv;
+	u32 ctrl_reg;
+
+	dev_dbg(&lp->ndev->dev,
+		"xemaclite_mdio_write(phy_id=%i, reg=%x, val=%x)\n",
+		phy_id, reg, val);
+
+	mutex_lock(&lp->mdio_mutex);
+
+	if (xemaclite_mdio_wait(lp))
+		return -ETIMEDOUT;
+
+	/* Write the PHY address, register number and clear the OP bit in the
+	 * MDIO Address register and then write the value into the MDIO Write
+	 * Data register. Finally, set the Status bit in the MDIO Control
+	 * register to start a MDIO write transaction.
+	 */
+	ctrl_reg = in_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET);
+	out_be32(lp->base_addr + XEL_MDIOADDR_OFFSET,
+		 ~XEL_MDIOADDR_OP_MASK &
+		 ((phy_id << XEL_MDIOADDR_PHYADR_SHIFT) | reg));
+	out_be32(lp->base_addr + XEL_MDIOWR_OFFSET, val);
+	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
+		 ctrl_reg | XEL_MDIOCTRL_MDIOSTS_MASK);
+
+	mutex_unlock(&lp->mdio_mutex);
+
+	return 0;
+}
+
+/**
+ * xemaclite_mdio_reset - Reset the mdio bus.
+ * @bus:	Pointer to the MII bus
+ *
+ * This function is required(?) as per Documentation/networking/phy.txt.
+ * There is no reset in this device; this function always returns 0.
+ */
+static int xemaclite_mdio_reset(struct mii_bus *bus)
+{
+	return 0;
+}
+
+/**
+ * xemaclite_mdio_setup - Register mii_bus for the Emaclite device
+ * @lp:		Pointer to the Emaclite device private data
+ * @ofdev:	Pointer to OF device structure
+ *
+ * This function enables MDIO bus in the Emaclite device and registers a
+ * mii_bus.
+ *
+ * Return:	0 upon success or a negative error upon failure
+ */
+static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
+{
+	struct mii_bus *bus;
+	int rc;
+	struct resource res;
+	struct device_node *np = of_get_parent(lp->phy_node);
+
+	/* Don't register the MDIO bus if the phy_node or its parent node
+	 * can't be found.
+	 */
+	if (!np)
+		return -ENODEV;
+
+	/* Enable the MDIO bus by asserting the enable bit in MDIO Control
+	 * register.
+	 */
+	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
+		 XEL_MDIOCTRL_MDIOEN_MASK);
+
+	bus = mdiobus_alloc();
+	if (!bus)
+		return -ENOMEM;
+
+	of_address_to_resource(np, 0, &res);
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
+		 (unsigned long long)res.start);
+	bus->priv = lp;
+	bus->name = "Xilinx Emaclite MDIO";
+	bus->read = xemaclite_mdio_read;
+	bus->write = xemaclite_mdio_write;
+	bus->reset = xemaclite_mdio_reset;
+	bus->parent = dev;
+	bus->irq = lp->mdio_irqs; /* preallocated IRQ table */
+
+	lp->mii_bus = bus;
+
+	rc = of_mdiobus_register(bus, np);
+	if (rc)
+		goto err_register;
+
+	return 0;
+
+err_register:
+	mdiobus_free(bus);
+	return rc;
+}
+
+/**
+ * xemaclite_adjust_link - Link state callback for the Emaclite device
+ * @ndev: pointer to net_device struct
+ *
+ * There's nothing in the Emaclite device to be configured when the link
+ * state changes. We just print the status.
+ */
+void xemaclite_adjust_link(struct net_device *ndev)
+{
+	struct net_local *lp = netdev_priv(ndev);
+	struct phy_device *phy = lp->phy_dev;
+	int link_state;
+
+	/* hash together the state values to decide if something has changed */
+	link_state = phy->speed | (phy->duplex << 1) | phy->link;
+
+	if (lp->last_link != link_state) {
+		lp->last_link = link_state;
+		phy_print_status(phy);
+	}
+}
+
 /**
  * xemaclite_open - Open the network device
  * @dev:	Pointer to the network device
  *
  * This function sets the MAC address, requests an IRQ and enables interrupts
  * for the Emaclite device and starts the Tx queue.
+ * It also connects to the phy device, if MDIO is included in Emaclite device.
  */
 static int xemaclite_open(struct net_device *dev)
 {
@@ -656,14 +935,50 @@ static int xemaclite_open(struct net_device *dev)
 	/* Just to be safe, stop the device first */
 	xemaclite_disable_interrupts(lp);
 
+	if (lp->phy_node) {
+		u32 bmcr;
+
+		lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
+					     xemaclite_adjust_link, 0,
+					     PHY_INTERFACE_MODE_MII);
+		if (!lp->phy_dev) {
+			dev_err(&lp->ndev->dev, "of_phy_connect() failed\n");
+			return -ENODEV;
+		}
+
+		/* EmacLite doesn't support giga-bit speeds */
+		lp->phy_dev->supported &= (PHY_BASIC_FEATURES);
+		lp->phy_dev->advertising = lp->phy_dev->supported;
+
+		/* Don't advertise 1000BASE-T Full/Half duplex speeds */
+		xemaclite_mdio_write(lp->mii_bus, lp->phy_dev->addr,
+				     MII_CTRL1000, 0x00);
+		/* Advertise only 10 and 100mbps full/half duplex speeds */
+		xemaclite_mdio_write(lp->mii_bus, lp->phy_dev->addr,
+				     MII_ADVERTISE, ADVERTISE_ALL);
+
+		/* Restart auto negotiation */
+		bmcr = xemaclite_mdio_read(lp->mii_bus,
+					   lp->phy_dev->addr, MII_BMCR);
+		bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
+		xemaclite_mdio_write(lp->mii_bus, lp->phy_dev->addr,
+				     MII_BMCR, bmcr);
+
+		phy_start(lp->phy_dev);
+	}
+
 	/* Set the MAC address each time opened */
-	xemaclite_set_mac_address(lp, dev->dev_addr);
+	xemaclite_update_address(lp, dev->dev_addr);
 
 	/* Grab the IRQ */
 	retval = request_irq(dev->irq, xemaclite_interrupt, 0, dev->name, dev);
 	if (retval) {
 		dev_err(&lp->ndev->dev, "Could not allocate interrupt %d\n",
 			dev->irq);
+		if (lp->phy_dev)
+			phy_disconnect(lp->phy_dev);
+		lp->phy_dev = NULL;
+
 		return retval;
 	}
 
@@ -682,6 +997,7 @@ static int xemaclite_open(struct net_device *dev)
  *
  * This function stops the Tx queue, disables interrupts and frees the IRQ for
  * the Emaclite device.
+ * It also disconnects the phy device associated with the Emaclite device.
  */
 static int xemaclite_close(struct net_device *dev)
 {
@@ -691,6 +1007,10 @@ static int xemaclite_close(struct net_device *dev)
 	xemaclite_disable_interrupts(lp);
 	free_irq(dev->irq, dev);
 
+	if (lp->phy_dev)
+		phy_disconnect(lp->phy_dev);
+	lp->phy_dev = NULL;
+
 	return 0;
 }
 
@@ -754,42 +1074,6 @@ static int xemaclite_send(struct sk_buff *orig_skb, struct net_device *dev)
 }
 
 /**
- * xemaclite_ioctl - Perform IO Control operations on the network device
- * @dev:	Pointer to the network device
- * @rq:		Pointer to the interface request structure
- * @cmd:	IOCTL command
- *
- * The only IOCTL operation supported by this function is setting the MAC
- * address. An error is reported if any other operations are requested.
- *
- * Return:	0 to indicate success, or a negative error for failure.
- */
-static int xemaclite_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-{
-	struct net_local *lp = (struct net_local *) netdev_priv(dev);
-	struct hw_addr_data *hw_addr = (struct hw_addr_data *) &rq->ifr_hwaddr;
-
-	switch (cmd) {
-	case SIOCETHTOOL:
-		return -EIO;
-
-	case SIOCSIFHWADDR:
-		dev_err(&lp->ndev->dev, "SIOCSIFHWADDR\n");
-
-		/* Copy MAC address in from user space */
-		copy_from_user((void __force *) dev->dev_addr,
-			       (void __user __force *) hw_addr,
-			       IFHWADDRLEN);
-		xemaclite_set_mac_address(lp, dev->dev_addr);
-		break;
-	default:
-		return -EOPNOTSUPP;
-	}
-
-	return 0;
-}
-
-/**
  * xemaclite_remove_ndev - Free the network device
  * @ndev:	Pointer to the network device to be freed
  *
@@ -840,6 +1124,8 @@ static struct net_device_ops xemaclite_netdev_ops;
  * This function probes for the Emaclite device in the device tree.
  * It initializes the driver data structure and the hardware, sets the MAC
  * address and registers the network device.
+ * It also registers a mii_bus for the Emaclite device, if MDIO is included
+ * in the device.
  *
  * Return:	0, if the driver is bound to the Emaclite device, or
  *		a negative error if there is failure.
@@ -880,6 +1166,7 @@ static int __devinit xemaclite_of_probe(struct of_device *ofdev,
 	}
 
 	dev_set_drvdata(dev, ndev);
+	SET_NETDEV_DEV(ndev, &ofdev->dev);
 
 	ndev->irq = r_irq.start;
 	ndev->mem_start = r_mem.start;
@@ -906,6 +1193,7 @@ static int __devinit xemaclite_of_probe(struct of_device *ofdev,
 	}
 
 	spin_lock_init(&lp->reset_lock);
+	mutex_init(&lp->mdio_mutex);
 	lp->next_tx_buf_to_use = 0x0;
 	lp->next_rx_buf_to_use = 0x0;
 	lp->tx_ping_pong = get_bool(ofdev, "xlnx,tx-ping-pong");
@@ -923,7 +1211,12 @@ static int __devinit xemaclite_of_probe(struct of_device *ofdev,
 	out_be32(lp->base_addr + XEL_BUFFER_OFFSET + XEL_TSR_OFFSET, 0);
 
 	/* Set the MAC address in the EmacLite device */
-	xemaclite_set_mac_address(lp, ndev->dev_addr);
+	xemaclite_update_address(lp, ndev->dev_addr);
+
+	lp->phy_node = of_parse_phandle(ofdev->node, "phy-handle", 0);
+	rc = xemaclite_mdio_setup(lp, &ofdev->dev);
+	if (rc)
+		dev_warn(&ofdev->dev, "error registering MDIO bus\n");
 
 	dev_info(dev,
 		 "MAC address is now %2x:%2x:%2x:%2x:%2x:%2x\n",
@@ -972,12 +1265,25 @@ static int __devexit xemaclite_of_remove(struct of_device *of_dev)
 	struct device *dev = &of_dev->dev;
 	struct net_device *ndev = dev_get_drvdata(dev);
 
+	struct net_local *lp = (struct net_local *) netdev_priv(ndev);
+
+	/* Un-register the mii_bus, if configured */
+	if (lp->has_mdio) {
+		mdiobus_unregister(lp->mii_bus);
+		kfree(lp->mii_bus->irq);
+		mdiobus_free(lp->mii_bus);
+		lp->mii_bus = NULL;
+	}
+
 	unregister_netdev(ndev);
 
+	if (lp->phy_node)
+		of_node_put(lp->phy_node);
+	lp->phy_node = NULL;
+
 	release_mem_region(ndev->mem_start, ndev->mem_end-ndev->mem_start + 1);
 
 	xemaclite_remove_ndev(ndev);
-
 	dev_set_drvdata(dev, NULL);
 
 	return 0;
@@ -987,7 +1293,7 @@ static struct net_device_ops xemaclite_netdev_ops = {
 	.ndo_open		= xemaclite_open,
 	.ndo_stop		= xemaclite_close,
 	.ndo_start_xmit		= xemaclite_send,
-	.ndo_do_ioctl		= xemaclite_ioctl,
+	.ndo_set_mac_address	= xemaclite_set_mac_address,
 	.ndo_tx_timeout		= xemaclite_tx_timeout,
 	.ndo_get_stats		= xemaclite_get_stats,
 };
@@ -999,6 +1305,7 @@ static struct of_device_id xemaclite_of_match[] __devinitdata = {
 	{ .compatible = "xlnx,xps-ethernetlite-1.00.a", },
 	{ .compatible = "xlnx,xps-ethernetlite-2.00.a", },
 	{ .compatible = "xlnx,xps-ethernetlite-2.01.a", },
+	{ .compatible = "xlnx,xps-ethernetlite-3.00.a", },
 	{ /* end of list */ },
 };
 MODULE_DEVICE_TABLE(of, xemaclite_of_match);
-- 
1.6.2.1



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


