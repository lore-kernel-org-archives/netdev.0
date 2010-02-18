From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 12/15] drivers/net/sky2.c: Use (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:59 -0800
Message-ID: <dd6928cf4431fb87b8a834d07aa13db04d7d244f.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/sky2.c |   63 ++++++++++++++++++++++-----------------------------
 1 files changed, 27 insertions(+), 36 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a1198f1..d1e98e2 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -22,6 +22,8 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/crc32.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -51,7 +53,6 @@
 
 #define DRV_NAME		"sky2"
 #define DRV_VERSION		"1.27"
-#define PFX			DRV_NAME " "
 
 /*
  * The Yukon II chipset takes 64 bit command blocks (called list elements)
@@ -1212,8 +1213,7 @@ static void sky2_rx_stop(struct sky2_port *sky2)
 		    == sky2_read8(hw, RB_ADDR(rxq, Q_RL)))
 			goto stopped;
 
-	printk(KERN_WARNING PFX "%s: receiver stop failed\n",
-	       sky2->netdev->name);
+	netdev_warn(sky2->netdev, "receiver stop failed\n");
 stopped:
 	sky2_write32(hw, Q_ADDR(rxq, Q_CSR), BMU_RST_SET | BMU_FIFO_RST);
 
@@ -1555,7 +1555,7 @@ static void sky2_hw_up(struct sky2_port *sky2)
 	if (ramsize > 0) {
 		u32 rxspace;
 
-		pr_debug(PFX "%s: ram buffer %dK\n", sky2->netdev->name, ramsize);
+		netdev_dbg(sky2->netdev, "ram buffer %dK\n", ramsize);
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
 		else
@@ -2070,13 +2070,12 @@ static int sky2_autoneg_done(struct sky2_port *sky2, u16 aux)
 	advert = gm_phy_read(hw, port, PHY_MARV_AUNE_ADV);
 	lpa = gm_phy_read(hw, port, PHY_MARV_AUNE_LP);
 	if (lpa & PHY_M_AN_RF) {
-		printk(KERN_ERR PFX "%s: remote fault", sky2->netdev->name);
+		netdev_err(sky2->netdev, "remote fault\n");
 		return -1;
 	}
 
 	if (!(aux & PHY_M_PS_SPDUP_RES)) {
-		printk(KERN_ERR PFX "%s: speed/duplex mismatch",
-		       sky2->netdev->name);
+		netdev_err(sky2->netdev, "speed/duplex mismatch\n");
 		return -1;
 	}
 
@@ -2195,10 +2194,10 @@ static void sky2_tx_timeout(struct net_device *dev)
 
 	netif_err(sky2, timer, dev, "tx timeout\n");
 
-	printk(KERN_DEBUG PFX "%s: transmit ring %u .. %u report=%u done=%u\n",
-	       dev->name, sky2->tx_cons, sky2->tx_prod,
-	       sky2_read16(hw, sky2->port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX),
-	       sky2_read16(hw, Q_ADDR(txqaddr[sky2->port], Q_DONE)));
+	netdev_printk(KERN_DEBUG, dev, "transmit ring %u .. %u report=%u done=%u\n",
+		      sky2->tx_cons, sky2->tx_prod,
+		      sky2_read16(hw, sky2->port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX),
+		      sky2_read16(hw, Q_ADDR(txqaddr[sky2->port], Q_DONE)));
 
 	/* can't restart safely under softirq */
 	schedule_work(&hw->restart_work);
@@ -2614,8 +2613,7 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 
 		default:
 			if (net_ratelimit())
-				printk(KERN_WARNING PFX
-				       "unknown status opcode 0x%x\n", opcode);
+				pr_warning("unknown status opcode 0x%x\n", opcode);
 		}
 	} while (hw->st_idx != idx);
 
@@ -2634,41 +2632,37 @@ static void sky2_hw_error(struct sky2_hw *hw, unsigned port, u32 status)
 	struct net_device *dev = hw->dev[port];
 
 	if (net_ratelimit())
-		printk(KERN_INFO PFX "%s: hw error interrupt status 0x%x\n",
-		       dev->name, status);
+		netdev_info(dev, "hw error interrupt status 0x%x\n", status);
 
 	if (status & Y2_IS_PAR_RD1) {
 		if (net_ratelimit())
-			printk(KERN_ERR PFX "%s: ram data read parity error\n",
-			       dev->name);
+			netdev_err(dev, "ram data read parity error\n");
 		/* Clear IRQ */
 		sky2_write16(hw, RAM_BUFFER(port, B3_RI_CTRL), RI_CLR_RD_PERR);
 	}
 
 	if (status & Y2_IS_PAR_WR1) {
 		if (net_ratelimit())
-			printk(KERN_ERR PFX "%s: ram data write parity error\n",
-			       dev->name);
+			netdev_err(dev, "ram data write parity error\n");
 
 		sky2_write16(hw, RAM_BUFFER(port, B3_RI_CTRL), RI_CLR_WR_PERR);
 	}
 
 	if (status & Y2_IS_PAR_MAC1) {
 		if (net_ratelimit())
-			printk(KERN_ERR PFX "%s: MAC parity error\n", dev->name);
+			netdev_err(dev, "MAC parity error\n");
 		sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_CLI_TX_PE);
 	}
 
 	if (status & Y2_IS_PAR_RX1) {
 		if (net_ratelimit())
-			printk(KERN_ERR PFX "%s: RX parity error\n", dev->name);
+			netdev_err(dev, "RX parity error\n");
 		sky2_write32(hw, Q_ADDR(rxqaddr[port], Q_CSR), BMU_CLR_IRQ_PAR);
 	}
 
 	if (status & Y2_IS_TCP_TXA1) {
 		if (net_ratelimit())
-			printk(KERN_ERR PFX "%s: TCP segmentation error\n",
-			       dev->name);
+			netdev_err(dev, "TCP segmentation error\n");
 		sky2_write32(hw, Q_ADDR(txqaddr[port], Q_CSR), BMU_CLR_IRQ_TCP);
 	}
 }
@@ -2751,8 +2745,7 @@ static void sky2_le_error(struct sky2_hw *hw, unsigned port, u16 q)
 	struct net_device *dev = hw->dev[port];
 	u16 idx = sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_GET_IDX));
 
-	dev_err(&hw->pdev->dev, PFX
-		"%s: descriptor error q=%#x get=%u put=%u\n",
+	dev_err(&hw->pdev->dev, "%s: descriptor error q=%#x get=%u put=%u\n",
 		dev->name, (unsigned) q, (unsigned) idx,
 		(unsigned) sky2_read16(hw, Y2_QADDR(q, PREF_UNIT_PUT_IDX)));
 
@@ -2777,9 +2770,10 @@ static int sky2_rx_hung(struct net_device *dev)
 	     /* Check if the PCI RX hang */
 	     (fifo_rp == sky2->check.fifo_rp &&
 	      fifo_lev != 0 && fifo_lev >= sky2->check.fifo_lev))) {
-		printk(KERN_DEBUG PFX "%s: hung mac %d:%d fifo %d (%d:%d)\n",
-		       dev->name, mac_lev, mac_rp, fifo_lev, fifo_rp,
-		       sky2_read8(hw, Q_ADDR(rxq, Q_WP)));
+		netdev_printk(KERN_DEBUG, dev,
+			      "hung mac %d:%d fifo %d (%d:%d)\n",
+			      mac_lev, mac_rp, fifo_lev,
+			      fifo_rp, sky2_read8(hw, Q_ADDR(rxq, Q_WP)));
 		return 1;
 	} else {
 		sky2->check.last = dev->last_rx;
@@ -2810,8 +2804,7 @@ static void sky2_watchdog(unsigned long arg)
 			/* For chips with Rx FIFO, check if stuck */
 			if ((hw->flags & SKY2_HW_RAM_BUFFER) &&
 			     sky2_rx_hung(dev)) {
-				pr_info(PFX "%s: receiver hang detected\n",
-					dev->name);
+				netdev_info(dev, "receiver hang detected\n");
 				schedule_work(&hw->restart_work);
 				return;
 			}
@@ -3253,8 +3246,7 @@ static int sky2_reattach(struct net_device *dev)
 	if (netif_running(dev)) {
 		err = sky2_up(dev);
 		if (err) {
-			printk(KERN_INFO PFX "%s: could not restart %d\n",
-			       dev->name, err);
+			netdev_info(dev, "could not restart %d\n", err);
 			dev_close(dev);
 		} else {
 			netif_device_attach(dev);
@@ -4032,7 +4024,7 @@ static int sky2_vpd_wait(const struct sky2_hw *hw, int cap, u16 busy)
 	while ( (sky2_pci_read16(hw, cap + PCI_VPD_ADDR) & PCI_VPD_ADDR_F) == busy) {
 		/* Can take up to 10.6 ms for write */
 		if (time_after(jiffies, start + HZ/4)) {
-			dev_err(&hw->pdev->dev, PFX "VPD cycle timed out");
+			dev_err(&hw->pdev->dev, "VPD cycle timed out\n");
 			return -ETIMEDOUT;
 		}
 		mdelay(1);
@@ -4366,8 +4358,7 @@ static int sky2_device_event(struct notifier_block *unused,
 
 	case NETDEV_GOING_DOWN:
 		if (sky2->debugfs) {
-			printk(KERN_DEBUG PFX "%s: remove debugfs\n",
-			       dev->name);
+			netdev_printk(KERN_DEBUG, dev, "remove debugfs\n");
 			debugfs_remove(sky2->debugfs);
 			sky2->debugfs = NULL;
 		}
@@ -4931,7 +4922,7 @@ static struct pci_driver sky2_driver = {
 
 static int __init sky2_init_module(void)
 {
-	pr_info(PFX "driver version " DRV_VERSION "\n");
+	pr_info("driver version " DRV_VERSION "\n");
 
 	sky2_debug_init();
 	return pci_register_driver(&sky2_driver);
-- 
1.7.0.14.g7e948
