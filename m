From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 4 Dec 2007 15:10:42 -0500
Message-ID: <20071204201042.GA20425@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753710AbXLDUK4@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fixes several ugly bugs...


Please pull from 'upstream-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-fixes

to receive the following updates:

 drivers/net/fec_mpc52xx.c    |    4 ++--
 drivers/net/gianfar.c        |    2 +-
 drivers/net/pasemi_mac.c     |    4 ++--
 drivers/net/phy/mdio_bus.c   |    9 +++++----
 drivers/net/phy/phy_device.c |   12 ++++++++++++
 drivers/net/sky2.c           |    6 ++----
 drivers/net/smc911x.c        |    2 +-
 include/linux/phy.h          |    1 +
 8 files changed, 26 insertions(+), 14 deletions(-)
 mode change 100755 => 100644 drivers/net/chelsio/cxgb2.c
 mode change 100755 => 100644 drivers/net/chelsio/pm3393.c
 mode change 100755 => 100644 drivers/net/chelsio/sge.c
 mode change 100755 => 100644 drivers/net/chelsio/sge.h

Anton Vorontsov (1):
      PHY: Add the phy_device_release device method.

David Woodhouse (1):
      Don't claim to do IPv6 checksum offload

Divy Le Ray (1):
      cxgb - revert file mode changes.

Grant Likely (1):
      gianfar: fix compile warning

Jon Smirl (1):
      Fix memory corruption in fec_mpc52xx

Olof Johansson (1):
      pasemi_mac: Fix reuse of free'd skb

Stephen Hemminger (1):
      sky2: recovery deadlock fix

Wang Chen (1):
      SMC911X: Fix using of dereferenced skb after netif_rx

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
old mode 100755
new mode 100644
diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/chelsio/pm3393.c
old mode 100755
new mode 100644
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
old mode 100755
new mode 100644
diff --git a/drivers/net/chelsio/sge.h b/drivers/net/chelsio/sge.h
old mode 100755
new mode 100644
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index bf5a7ca..79f7ead 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -422,7 +422,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 
 		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status,
 				(struct bcom_bd **)&bd);
-		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
+		dma_unmap_single(&dev->dev, bd->skb_pa, rskb->len, DMA_FROM_DEVICE);
 
 		/* Test for errors in received frame */
 		if (status & BCOM_FEC_RX_BD_ERRORS) {
@@ -467,7 +467,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 			bcom_prepare_next_buffer(priv->rx_dmatsk);
 
 		bd->status = FEC_RX_BUFFER_SIZE;
-		bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
+		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
 				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
 
 		bcom_submit_next_buffer(priv->rx_dmatsk, skb);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 38268d7..0431e9e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -696,7 +696,7 @@ int startup_gfar(struct net_device *dev)
 {
 	struct txbd8 *txbdp;
 	struct rxbd8 *rxbdp;
-	dma_addr_t addr;
+	dma_addr_t addr = 0;
 	unsigned long vaddr;
 	int i;
 	struct gfar_private *priv = netdev_priv(dev);
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 09b4fde..816a59e 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -586,7 +586,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 			/* CRC error flagged */
 			mac->netdev->stats.rx_errors++;
 			mac->netdev->stats.rx_crc_errors++;
-			dev_kfree_skb_irq(skb);
+			/* No need to free skb, it'll be reused */
 			goto next;
 		}
 
@@ -1362,7 +1362,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netif_napi_add(dev, &mac->napi, pasemi_mac_poll, 64);
 
-	dev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX | NETIF_F_SG;
+	dev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX | NETIF_F_SG;
 
 	/* These should come out of the device tree eventually */
 	mac->dma_txch = index;
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index fc2f0e6..c30196d 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -91,9 +91,12 @@ int mdiobus_register(struct mii_bus *bus)
 
 			err = device_register(&phydev->dev);
 
-			if (err)
+			if (err) {
 				printk(KERN_ERR "phy %d failed to register\n",
 						i);
+				phy_device_free(phydev);
+				phydev = NULL;
+			}
 		}
 
 		bus->phy_map[i] = phydev;
@@ -110,10 +113,8 @@ void mdiobus_unregister(struct mii_bus *bus)
 	int i;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		if (bus->phy_map[i]) {
+		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
-			kfree(bus->phy_map[i]);
-		}
 	}
 }
 EXPORT_SYMBOL(mdiobus_unregister);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index f6e4848..5b9e175 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -44,6 +44,16 @@ static struct phy_driver genphy_driver;
 extern int mdio_bus_init(void);
 extern void mdio_bus_exit(void);
 
+void phy_device_free(struct phy_device *phydev)
+{
+	kfree(phydev);
+}
+
+static void phy_device_release(struct device *dev)
+{
+	phy_device_free(to_phy_device(dev));
+}
+
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 {
 	struct phy_device *dev;
@@ -54,6 +64,8 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 	if (NULL == dev)
 		return (struct phy_device*) PTR_ERR((void*)-ENOMEM);
 
+	dev->dev.release = phy_device_release;
+
 	dev->speed = 0;
 	dev->duplex = -1;
 	dev->pause = dev->asym_pause = 0;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 3d1dfc9..6197afb 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2906,16 +2906,14 @@ static void sky2_restart(struct work_struct *work)
 	int i, err;
 
 	rtnl_lock();
-	sky2_write32(hw, B0_IMSK, 0);
-	sky2_read32(hw, B0_IMSK);
-	napi_disable(&hw->napi);
-
 	for (i = 0; i < hw->ports; i++) {
 		dev = hw->dev[i];
 		if (netif_running(dev))
 			sky2_down(dev);
 	}
 
+	napi_disable(&hw->napi);
+	sky2_write32(hw, B0_IMSK, 0);
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 	napi_enable(&hw->napi);
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 1a3d80b..76cc1d3 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1299,9 +1299,9 @@ smc911x_rx_dma_irq(int dma, void *data)
 	PRINT_PKT(skb->data, skb->len);
 	dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, dev);
-	netif_rx(skb);
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += skb->len;
+	netif_rx(skb);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	pkts = (SMC_GET_RX_FIFO_INF() & RX_FIFO_INF_RXSUSED_) >> 16;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e10763d..554836e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -403,6 +403,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id);
+void phy_device_free(struct phy_device *phydev);
 
 extern struct bus_type mdio_bus_type;
 #endif /* __PHY_H */
