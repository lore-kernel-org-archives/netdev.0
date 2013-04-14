From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] fec: Convert printks to netdev_<level>
Date: Sat, 13 Apr 2013 22:03:17 -0700
Message-ID: <aed8fe4fece480227a397667e6f6ce4bdbd9cd08.1365915548.git.joe@perches.com>
References: <cover.1365915548.git.joe@perches.com>
Cc: Fabio Estevam <festevam@gmail.com>, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1365915548.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging message style.

Convert the printks where a struct net_device is available to
netdev_<level>.  Convert the other printks to pr_<level> and
add pr_fmt where appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/freescale/fec_main.c    | 26 +++++++++++---------------
 drivers/net/ethernet/freescale/fec_mpc52xx.c | 16 ++++++++--------
 drivers/net/ethernet/freescale/fec_ptp.c     |  2 ++
 3 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 153437b..d7657a4 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -266,7 +266,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		/* Ooops.  All transmit buffers are full.  Bail out.
 		 * This should not happen, since ndev->tbusy should be set.
 		 */
-		printk("%s: tx queue full!.\n", ndev->name);
+		netdev_err(ndev, "tx queue full!\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -578,7 +578,7 @@ fec_stop(struct net_device *ndev)
 		writel(1, fep->hwp + FEC_X_CNTRL); /* Graceful transmit stop */
 		udelay(10);
 		if (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_GRA))
-			printk("fec_stop : Graceful transmit stop did not complete !\n");
+			netdev_err(ndev, "Graceful transmit stop did not complete!\n");
 	}
 
 	/* Whack a reset.  We should wait for this. */
@@ -676,7 +676,7 @@ fec_enet_tx(struct net_device *ndev)
 		}
 
 		if (status & BD_ENET_TX_READY)
-			printk("HEY! Enet xmit interrupt and TX_READY.\n");
+			netdev_err(ndev, "HEY! Enet xmit interrupt and TX_READY\n");
 
 		/* Deferred means some collisions occurred during transmit,
 		 * but we eventually sent the packet OK.
@@ -744,7 +744,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
 		 * the last indicator should be set.
 		 */
 		if ((status & BD_ENET_RX_LAST) == 0)
-			printk("FEC ENET: rcv is not +last\n");
+			netdev_err(ndev, "rcv is not +last\n");
 
 		if (!fep->opened)
 			goto rx_processing_done;
@@ -1031,7 +1031,7 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 			usecs_to_jiffies(FEC_MII_TIMEOUT));
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
-		printk(KERN_ERR "FEC: MDIO read timeout\n");
+		netdev_err(fep->netdev, "MDIO read timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1059,7 +1059,7 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 			usecs_to_jiffies(FEC_MII_TIMEOUT));
 	if (time_left == 0) {
 		fep->mii_timeout = 1;
-		printk(KERN_ERR "FEC: MDIO write timeout\n");
+		netdev_err(fep->netdev, "MDIO write timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1099,9 +1099,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	}
 
 	if (phy_id >= PHY_MAX_ADDR) {
-		printk(KERN_INFO
-			"%s: no PHY, assuming direct connection to switch\n",
-			ndev->name);
+		netdev_info(ndev, "no PHY, assuming direct connection to switch\n");
 		strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE);
 		phy_id = 0;
 	}
@@ -1110,7 +1108,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	phy_dev = phy_connect(ndev, phy_name, &fec_enet_adjust_link,
 			      fep->phy_interface);
 	if (IS_ERR(phy_dev)) {
-		printk(KERN_ERR "%s: could not attach to PHY\n", ndev->name);
+		netdev_err(ndev, "could not attach to PHY\n");
 		return PTR_ERR(phy_dev);
 	}
 
@@ -1128,11 +1126,9 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	fep->link = 0;
 	fep->full_duplex = 0;
 
-	printk(KERN_INFO
-		"%s: Freescale FEC PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		ndev->name,
-		fep->phy_dev->drv->name, dev_name(&fep->phy_dev->dev),
-		fep->phy_dev->irq);
+	netdev_info(ndev, "Freescale FEC PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+		    fep->phy_dev->drv->name, dev_name(&fep->phy_dev->dev),
+		    fep->phy_dev->irq);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 77943a6..9bc15e2 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -14,6 +14,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/dma-mapping.h>
 #include <linux/module.h>
 
@@ -858,13 +860,11 @@ static int mpc52xx_fec_probe(struct platform_device *op)
 	/* Reserve FEC control zone */
 	rv = of_address_to_resource(np, 0, &mem);
 	if (rv) {
-		printk(KERN_ERR DRIVER_NAME ": "
-				"Error while parsing device node resource\n" );
+		pr_err("Error while parsing device node resource\n");
 		goto err_netdev;
 	}
 	if (resource_size(&mem) < sizeof(struct mpc52xx_fec)) {
-		printk(KERN_ERR DRIVER_NAME
-		       " - invalid resource size (%lx < %x), check mpc52xx_devices.c\n",
+		pr_err("invalid resource size (%lx < %x), check mpc52xx_devices.c\n",
 		       (unsigned long)resource_size(&mem),
 		       sizeof(struct mpc52xx_fec));
 		rv = -EINVAL;
@@ -902,7 +902,7 @@ static int mpc52xx_fec_probe(struct platform_device *op)
 	priv->tx_dmatsk = bcom_fec_tx_init(FEC_TX_NUM_BD, tx_fifo);
 
 	if (!priv->rx_dmatsk || !priv->tx_dmatsk) {
-		printk(KERN_ERR DRIVER_NAME ": Can not init SDMA tasks\n" );
+		pr_err("Can not init SDMA tasks\n");
 		rv = -ENOMEM;
 		goto err_rx_tx_dmatsk;
 	}
@@ -982,8 +982,8 @@ static int mpc52xx_fec_probe(struct platform_device *op)
 
 	/* We're done ! */
 	dev_set_drvdata(&op->dev, ndev);
-	printk(KERN_INFO "%s: %s MAC %pM\n",
-	       ndev->name, op->dev.of_node->full_name, ndev->dev_addr);
+	netdev_info(ndev, "%s MAC %pM\n",
+		    op->dev.of_node->full_name, ndev->dev_addr);
 
 	return 0;
 
@@ -1094,7 +1094,7 @@ mpc52xx_fec_init(void)
 	int ret;
 	ret = platform_driver_register(&mpc52xx_fec_mdio_driver);
 	if (ret) {
-		printk(KERN_ERR DRIVER_NAME ": failed to register mdio driver\n");
+		pr_err("failed to register mdio driver\n");
 		return ret;
 	}
 #endif
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index e040c8b..25fc960 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -17,6 +17,8 @@
  * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-- 
1.8.1.2.459.gbcd45b4.dirty
