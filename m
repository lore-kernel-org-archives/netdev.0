From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/jme: Use pr_<level>
Date: Sun, 05 Sep 2010 01:21:05 -0700
Message-ID: <1283674865.23280.42.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Convert jeprintk to pr_err
Remove jeprintk macro define
Remove periods from end of logging messages
Coalesce format strings

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/jme.c |   98 ++++++++++++++++++++++++++---------------------------
 drivers/net/jme.h |    3 --
 2 files changed, 48 insertions(+), 53 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 99f24f5..9075a2b 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -21,6 +21,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
@@ -73,7 +75,7 @@ read_again:
 	}
 
 	if (i == 0) {
-		jeprintk(jme->pdev, "phy(%d) read timeout : %d\n", phy, reg);
+		pr_err("phy(%d) read timeout : %d\n", phy, reg);
 		return 0;
 	}
 
@@ -102,7 +104,7 @@ jme_mdio_write(struct net_device *netdev,
 	}
 
 	if (i == 0)
-		jeprintk(jme->pdev, "phy(%d) write timeout : %d\n", phy, reg);
+		pr_err("phy(%d) write timeout : %d\n", phy, reg);
 }
 
 static inline void
@@ -227,7 +229,7 @@ jme_reload_eeprom(struct jme_adapter *jme)
 		}
 
 		if (i == 0) {
-			jeprintk(jme->pdev, "eeprom reload timeout\n");
+			pr_err("eeprom reload timeout\n");
 			return -EIO;
 		}
 	}
@@ -397,8 +399,7 @@ jme_check_link(struct net_device *netdev, int testonly)
 					phylink = jread32(jme, JME_PHY_LINK);
 			}
 			if (!cnt)
-				jeprintk(jme->pdev,
-					"Waiting speed resolve timeout.\n");
+				pr_err("Waiting speed resolve timeout\n");
 
 			strcat(linkmsg, "ANed: ");
 		}
@@ -480,13 +481,13 @@ jme_check_link(struct net_device *netdev, int testonly)
 		strcat(linkmsg, (phylink & PHY_LINK_MDI_STAT) ?
 					"MDI-X" :
 					"MDI");
-		netif_info(jme, link, jme->dev, "Link is up at %s.\n", linkmsg);
+		netif_info(jme, link, jme->dev, "Link is up at %s\n", linkmsg);
 		netif_carrier_on(netdev);
 	} else {
 		if (testonly)
 			goto out;
 
-		netif_info(jme, link, jme->dev, "Link is down.\n");
+		netif_info(jme, link, jme->dev, "Link is down\n");
 		jme->phylink = 0;
 		netif_carrier_off(netdev);
 	}
@@ -648,7 +649,7 @@ jme_disable_tx_engine(struct jme_adapter *jme)
 	}
 
 	if (!i)
-		jeprintk(jme->pdev, "Disable TX engine timeout.\n");
+		pr_err("Disable TX engine timeout\n");
 }
 
 static void
@@ -867,7 +868,7 @@ jme_disable_rx_engine(struct jme_adapter *jme)
 	}
 
 	if (!i)
-		jeprintk(jme->pdev, "Disable RX engine timeout.\n");
+		pr_err("Disable RX engine timeout\n");
 
 }
 
@@ -887,13 +888,13 @@ jme_rxsum_ok(struct jme_adapter *jme, u16 flags)
 	if (unlikely((flags & (RXWBFLAG_MF | RXWBFLAG_UDPON | RXWBFLAG_UDPCS))
 			== RXWBFLAG_UDPON)) {
 		if (flags & RXWBFLAG_IPV4)
-			netif_err(jme, rx_err, jme->dev, "UDP Checksum error.\n");
+			netif_err(jme, rx_err, jme->dev, "UDP Checksum error\n");
 		return false;
 	}
 
 	if (unlikely((flags & (RXWBFLAG_IPV4 | RXWBFLAG_IPCS))
 			== RXWBFLAG_IPV4)) {
-		netif_err(jme, rx_err, jme->dev, "IPv4 Checksum error.\n");
+		netif_err(jme, rx_err, jme->dev, "IPv4 Checksum error\n");
 		return false;
 	}
 
@@ -1185,9 +1186,9 @@ jme_link_change_tasklet(unsigned long arg)
 
 	while (!atomic_dec_and_test(&jme->link_changing)) {
 		atomic_inc(&jme->link_changing);
-		netif_info(jme, intr, jme->dev, "Get link change lock failed.\n");
+		netif_info(jme, intr, jme->dev, "Get link change lock failed\n");
 		while (atomic_read(&jme->link_changing) != 1)
-			netif_info(jme, intr, jme->dev, "Waiting link change lock.\n");
+			netif_info(jme, intr, jme->dev, "Waiting link change lock\n");
 	}
 
 	if (jme_check_link(netdev, 1) && jme->old_mtu == netdev->mtu)
@@ -1221,15 +1222,13 @@ jme_link_change_tasklet(unsigned long arg)
 	if (netif_carrier_ok(netdev)) {
 		rc = jme_setup_rx_resources(jme);
 		if (rc) {
-			jeprintk(jme->pdev, "Allocating resources for RX error"
-				", Device STOPPED!\n");
+			pr_err("Allocating resources for RX error, Device STOPPED!\n");
 			goto out_enable_tasklet;
 		}
 
 		rc = jme_setup_tx_resources(jme);
 		if (rc) {
-			jeprintk(jme->pdev, "Allocating resources for TX error"
-				", Device STOPPED!\n");
+			pr_err("Allocating resources for TX error, Device STOPPED!\n");
 			goto err_out_free_rx_resources;
 		}
 
@@ -1324,7 +1323,7 @@ jme_wake_queue_if_stopped(struct jme_adapter *jme)
 	smp_wmb();
 	if (unlikely(netif_queue_stopped(jme->dev) &&
 	atomic_read(&txring->nr_free) >= (jme->tx_wake_threshold))) {
-		netif_info(jme, tx_done, jme->dev, "TX Queue Waked.\n");
+		netif_info(jme, tx_done, jme->dev, "TX Queue Waked\n");
 		netif_wake_queue(jme->dev);
 	}
 
@@ -1339,7 +1338,7 @@ jme_tx_clean_tasklet(unsigned long arg)
 	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi, *ttxbi;
 	int i, j, cnt = 0, max, err, mask;
 
-	tx_dbg(jme, "Into txclean.\n");
+	tx_dbg(jme, "Into txclean\n");
 
 	if (unlikely(!atomic_dec_and_test(&jme->tx_cleaning)))
 		goto out;
@@ -1361,7 +1360,7 @@ jme_tx_clean_tasklet(unsigned long arg)
 		!(txdesc[i].descwb.flags & TXWBFLAG_OWN))) {
 
 			tx_dbg(jme, "txclean: %d+%d@%lu\n",
-					i, ctxbi->nr_desc, jiffies);
+			       i, ctxbi->nr_desc, jiffies);
 
 			err = txdesc[i].descwb.flags & TXWBFLAG_ALLERR;
 
@@ -1402,7 +1401,7 @@ jme_tx_clean_tasklet(unsigned long arg)
 		ctxbi->nr_desc = 0;
 	}
 
-	tx_dbg(jme, "txclean: done %d@%lu.\n", i, jiffies);
+	tx_dbg(jme, "txclean: done %d@%lu\n", i, jiffies);
 	atomic_set(&txring->next_to_clean, i);
 	atomic_add(cnt, &txring->nr_free);
 
@@ -1548,10 +1547,10 @@ jme_request_irq(struct jme_adapter *jme)
 	rc = request_irq(jme->pdev->irq, handler, irq_flags, netdev->name,
 			  netdev);
 	if (rc) {
-		jeprintk(jme->pdev,
-			"Unable to request %s interrupt (return: %d)\n",
-			test_bit(JME_FLAG_MSI, &jme->flags) ? "MSI" : "INTx",
-			rc);
+		netdev_err(netdev,
+			   "Unable to request %s interrupt (return: %d)\n",
+			   test_bit(JME_FLAG_MSI, &jme->flags) ? "MSI" : "INTx",
+			   rc);
 
 		if (test_bit(JME_FLAG_MSI, &jme->flags)) {
 			pci_disable_msi(jme->pdev);
@@ -1834,7 +1833,7 @@ jme_tx_csum(struct jme_adapter *jme, struct sk_buff *skb, u8 *flags)
 			*flags |= TXFLAG_UDPCS;
 			break;
 		default:
-			netif_err(jme, tx_err, jme->dev, "Error upper layer protocol.\n");
+			netif_err(jme, tx_err, jme->dev, "Error upper layer protocol\n");
 			break;
 		}
 	}
@@ -1909,12 +1908,12 @@ jme_stop_queue_if_full(struct jme_adapter *jme)
 	smp_wmb();
 	if (unlikely(atomic_read(&txring->nr_free) < (MAX_SKB_FRAGS+2))) {
 		netif_stop_queue(jme->dev);
-		netif_info(jme, tx_queued, jme->dev, "TX Queue Paused.\n");
+		netif_info(jme, tx_queued, jme->dev, "TX Queue Paused\n");
 		smp_wmb();
 		if (atomic_read(&txring->nr_free)
 			>= (jme->tx_wake_threshold)) {
 			netif_wake_queue(jme->dev);
-			netif_info(jme, tx_queued, jme->dev, "TX Queue Fast Waked.\n");
+			netif_info(jme, tx_queued, jme->dev, "TX Queue Fast Waked\n");
 		}
 	}
 
@@ -1922,7 +1921,8 @@ jme_stop_queue_if_full(struct jme_adapter *jme)
 			(jiffies - txbi->start_xmit) >= TX_TIMEOUT &&
 			txbi->skb)) {
 		netif_stop_queue(jme->dev);
-		netif_info(jme, tx_queued, jme->dev, "TX Queue Stopped %d@%lu.\n", idx, jiffies);
+		netif_info(jme, tx_queued, jme->dev,
+			   "TX Queue Stopped %d@%lu\n", idx, jiffies);
 	}
 }
 
@@ -1945,7 +1945,8 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	if (unlikely(idx < 0)) {
 		netif_stop_queue(netdev);
-		netif_err(jme, tx_err, jme->dev, "BUG! Tx ring full when queue awake!\n");
+		netif_err(jme, tx_err, jme->dev,
+			  "BUG! Tx ring full when queue awake!\n");
 
 		return NETDEV_TX_BUSY;
 	}
@@ -1957,9 +1958,8 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 				TXCS_QUEUE0S |
 				TXCS_ENABLE);
 
-	tx_dbg(jme, "xmit: %d+%d@%lu\n", idx,
-			skb_shinfo(skb)->nr_frags + 2,
-			jiffies);
+	tx_dbg(jme, "xmit: %d+%d@%lu\n",
+	       idx, skb_shinfo(skb)->nr_frags + 2, jiffies);
 	jme_stop_queue_if_full(jme);
 
 	return NETDEV_TX_OK;
@@ -2501,7 +2501,7 @@ jme_smb_read(struct jme_adapter *jme, unsigned int addr)
 		val = jread32(jme, JME_SMBCSR);
 	}
 	if (!to) {
-		netif_err(jme, hw, jme->dev, "SMB Bus Busy.\n");
+		netif_err(jme, hw, jme->dev, "SMB Bus Busy\n");
 		return 0xFF;
 	}
 
@@ -2517,7 +2517,7 @@ jme_smb_read(struct jme_adapter *jme, unsigned int addr)
 		val = jread32(jme, JME_SMBINTF);
 	}
 	if (!to) {
-		netif_err(jme, hw, jme->dev, "SMB Bus Busy.\n");
+		netif_err(jme, hw, jme->dev, "SMB Bus Busy\n");
 		return 0xFF;
 	}
 
@@ -2537,7 +2537,7 @@ jme_smb_write(struct jme_adapter *jme, unsigned int addr, u8 data)
 		val = jread32(jme, JME_SMBCSR);
 	}
 	if (!to) {
-		netif_err(jme, hw, jme->dev, "SMB Bus Busy.\n");
+		netif_err(jme, hw, jme->dev, "SMB Bus Busy\n");
 		return;
 	}
 
@@ -2554,7 +2554,7 @@ jme_smb_write(struct jme_adapter *jme, unsigned int addr, u8 data)
 		val = jread32(jme, JME_SMBINTF);
 	}
 	if (!to) {
-		netif_err(jme, hw, jme->dev, "SMB Bus Busy.\n");
+		netif_err(jme, hw, jme->dev, "SMB Bus Busy\n");
 		return;
 	}
 
@@ -2699,26 +2699,26 @@ jme_init_one(struct pci_dev *pdev,
 	 */
 	rc = pci_enable_device(pdev);
 	if (rc) {
-		jeprintk(pdev, "Cannot enable PCI device.\n");
+		pr_err("Cannot enable PCI device\n");
 		goto err_out;
 	}
 
 	using_dac = jme_pci_dma64(pdev);
 	if (using_dac < 0) {
-		jeprintk(pdev, "Cannot set PCI DMA Mask.\n");
+		pr_err("Cannot set PCI DMA Mask\n");
 		rc = -EIO;
 		goto err_out_disable_pdev;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		jeprintk(pdev, "No PCI resource region found.\n");
+		pr_err("No PCI resource region found\n");
 		rc = -ENOMEM;
 		goto err_out_disable_pdev;
 	}
 
 	rc = pci_request_regions(pdev, DRV_NAME);
 	if (rc) {
-		jeprintk(pdev, "Cannot obtain PCI resource region.\n");
+		pr_err("Cannot obtain PCI resource region\n");
 		goto err_out_disable_pdev;
 	}
 
@@ -2729,7 +2729,7 @@ jme_init_one(struct pci_dev *pdev,
 	 */
 	netdev = alloc_etherdev(sizeof(*jme));
 	if (!netdev) {
-		jeprintk(pdev, "Cannot allocate netdev structure.\n");
+		pr_err("Cannot allocate netdev structure\n");
 		rc = -ENOMEM;
 		goto err_out_release_regions;
 	}
@@ -2767,7 +2767,7 @@ jme_init_one(struct pci_dev *pdev,
 	jme->regs = ioremap(pci_resource_start(pdev, 0),
 			     pci_resource_len(pdev, 0));
 	if (!(jme->regs)) {
-		jeprintk(pdev, "Mapping PCI resource region error.\n");
+		pr_err("Mapping PCI resource region error\n");
 		rc = -ENOMEM;
 		goto err_out_free_netdev;
 	}
@@ -2855,8 +2855,8 @@ jme_init_one(struct pci_dev *pdev,
 
 		if (!jme->mii_if.phy_id) {
 			rc = -EIO;
-			jeprintk(pdev, "Can not find phy_id.\n");
-			 goto err_out_unmap;
+			pr_err("Can not find phy_id\n");
+			goto err_out_unmap;
 		}
 
 		jme->reg_ghc |= GHC_LINK_POLL;
@@ -2883,8 +2883,7 @@ jme_init_one(struct pci_dev *pdev,
 	jme_reset_mac_processor(jme);
 	rc = jme_reload_eeprom(jme);
 	if (rc) {
-		jeprintk(pdev,
-			"Reload eeprom for reading MAC Address error.\n");
+		pr_err("Reload eeprom for reading MAC Address error\n");
 		goto err_out_unmap;
 	}
 	jme_load_macaddr(netdev);
@@ -2900,7 +2899,7 @@ jme_init_one(struct pci_dev *pdev,
 	 */
 	rc = register_netdev(netdev);
 	if (rc) {
-		jeprintk(pdev, "Cannot register net device.\n");
+		pr_err("Cannot register net device\n");
 		goto err_out_unmap;
 	}
 
@@ -3042,8 +3041,7 @@ static struct pci_driver jme_driver = {
 static int __init
 jme_init_module(void)
 {
-	printk(KERN_INFO PFX "JMicron JMC2XX ethernet "
-	       "driver version %s\n", DRV_VERSION);
+	pr_info("JMicron JMC2XX ethernet driver version %s\n", DRV_VERSION);
 	return pci_register_driver(&jme_driver);
 }
 
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 07ad3a4..1360f68 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -41,9 +41,6 @@
 	NETIF_MSG_TX_ERR | \
 	NETIF_MSG_HW)
 
-#define jeprintk(pdev, fmt, args...) \
-	printk(KERN_ERR PFX fmt, ## args)
-
 #ifdef TX_DEBUG
 #define tx_dbg(priv, fmt, args...)					\
 	printk(KERN_DEBUG "%s: " fmt, (priv)->dev->name, ##args)
