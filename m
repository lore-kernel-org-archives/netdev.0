From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 01/15] drivers/net/8139cp.c: Use (pr|netdev|netif)_<level> macro helpers
Date: Wed, 17 Feb 2010 17:01:48 -0800
Message-ID: <3c5a9a27afc33ad04c017b7f3ed53fbbcd6d3793.1266454576.git.joe@perches.com>
References: <cover.1266454575.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266454575.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Use netif_<level>
Remove periods from formats
Coalesce long formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/8139cp.c |   72 +++++++++++++++++++++-----------------------------
 1 files changed, 30 insertions(+), 42 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 60bc0b0..3d4406b 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -46,6 +46,8 @@
 
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #define DRV_NAME		"8139cp"
 #define DRV_VERSION		"1.3"
 #define DRV_RELDATE		"Mar 22, 2004"
@@ -104,8 +106,6 @@ static int multicast_filter_limit = 32;
 module_param(multicast_filter_limit, int, 0);
 MODULE_PARM_DESC (multicast_filter_limit, "8139cp: maximum number of filtered multicast addresses");
 
-#define PFX			DRV_NAME ": "
-
 #define CP_DEF_MSG_ENABLE	(NETIF_MSG_DRV		| \
 				 NETIF_MSG_PROBE 	| \
 				 NETIF_MSG_LINK)
@@ -470,9 +470,8 @@ static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
 static void cp_rx_err_acct (struct cp_private *cp, unsigned rx_tail,
 			    u32 status, u32 len)
 {
-	if (netif_msg_rx_err (cp))
-		pr_debug("%s: rx err, slot %d status 0x%x len %d\n",
-			cp->dev->name, rx_tail, status, len);
+	netif_dbg(cp, rx_err, cp->dev, "rx err, slot %d status 0x%x len %d\n",
+		  rx_tail, status, len);
 	cp->dev->stats.rx_errors++;
 	if (status & RxErrFrame)
 		cp->dev->stats.rx_frame_errors++;
@@ -545,9 +544,8 @@ rx_status_loop:
 			goto rx_next;
 		}
 
-		if (netif_msg_rx_status(cp))
-			pr_debug("%s: rx slot %d status 0x%x len %d\n",
-			       dev->name, rx_tail, status, len);
+		netif_dbg(cp, rx_status, dev, "rx slot %d status 0x%x len %d\n",
+			  rx_tail, status, len);
 
 		new_skb = netdev_alloc_skb_ip_align(dev, buflen);
 		if (!new_skb) {
@@ -621,9 +619,8 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 	if (!status || (status == 0xFFFF))
 		return IRQ_NONE;
 
-	if (netif_msg_intr(cp))
-		pr_debug("%s: intr, status %04x cmd %02x cpcmd %04x\n",
-		        dev->name, status, cpr8(Cmd), cpr16(CpCmd));
+	netif_dbg(cp, intr, dev, "intr, status %04x cmd %02x cpcmd %04x\n",
+		  status, cpr8(Cmd), cpr16(CpCmd));
 
 	cpw16(IntrStatus, status & ~cp_rx_intr_mask);
 
@@ -654,8 +651,8 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 
 		pci_read_config_word(cp->pdev, PCI_STATUS, &pci_status);
 		pci_write_config_word(cp->pdev, PCI_STATUS, pci_status);
-		pr_err("%s: PCI bus error, status=%04x, PCI status=%04x\n",
-		       dev->name, status, pci_status);
+		netdev_err(dev, "PCI bus error, status=%04x, PCI status=%04x\n",
+			   status, pci_status);
 
 		/* TODO: reset hardware */
 	}
@@ -700,9 +697,8 @@ static void cp_tx (struct cp_private *cp)
 
 		if (status & LastFrag) {
 			if (status & (TxError | TxFIFOUnder)) {
-				if (netif_msg_tx_err(cp))
-					pr_debug("%s: tx err, status 0x%x\n",
-					       cp->dev->name, status);
+				netif_dbg(cp, tx_err, cp->dev,
+					  "tx err, status 0x%x\n", status);
 				cp->dev->stats.tx_errors++;
 				if (status & TxOWC)
 					cp->dev->stats.tx_window_errors++;
@@ -717,8 +713,8 @@ static void cp_tx (struct cp_private *cp)
 					((status >> TxColCntShift) & TxColCntMask);
 				cp->dev->stats.tx_packets++;
 				cp->dev->stats.tx_bytes += skb->len;
-				if (netif_msg_tx_done(cp))
-					pr_debug("%s: tx done, slot %d\n", cp->dev->name, tx_tail);
+				netif_dbg(cp, tx_done, cp->dev,
+					  "tx done, slot %d\n", tx_tail);
 			}
 			dev_kfree_skb_irq(skb);
 		}
@@ -752,8 +748,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 	if (TX_BUFFS_AVAIL(cp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&cp->lock, intr_flags);
-		pr_err(PFX "%s: BUG! Tx Ring full when queue awake!\n",
-		       dev->name);
+		netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -878,9 +873,8 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 		wmb();
 	}
 	cp->tx_head = entry;
-	if (netif_msg_tx_queued(cp))
-		pr_debug("%s: tx queued, slot %d, skblen %d\n",
-		       dev->name, entry, skb->len);
+	netif_dbg(cp, tx_queued, cp->dev, "tx queued, slot %d, skblen %d\n",
+		  entry, skb->len);
 	if (TX_BUFFS_AVAIL(cp) <= (MAX_SKB_FRAGS + 1))
 		netif_stop_queue(dev);
 
@@ -992,7 +986,7 @@ static void cp_reset_hw (struct cp_private *cp)
 		schedule_timeout_uninterruptible(10);
 	}
 
-	pr_err("%s: hardware reset timeout\n", cp->dev->name);
+	netdev_err(cp->dev, "hardware reset timeout\n");
 }
 
 static inline void cp_start_hw (struct cp_private *cp)
@@ -1159,8 +1153,7 @@ static int cp_open (struct net_device *dev)
 	struct cp_private *cp = netdev_priv(dev);
 	int rc;
 
-	if (netif_msg_ifup(cp))
-		pr_debug("%s: enabling interface\n", dev->name);
+	netif_dbg(cp, ifup, dev, "enabling interface\n");
 
 	rc = cp_alloc_rings(cp);
 	if (rc)
@@ -1194,8 +1187,7 @@ static int cp_close (struct net_device *dev)
 
 	napi_disable(&cp->napi);
 
-	if (netif_msg_ifdown(cp))
-		pr_debug("%s: disabling interface\n", dev->name);
+	netif_dbg(cp, ifdown, dev, "disabling interface\n");
 
 	spin_lock_irqsave(&cp->lock, flags);
 
@@ -1218,9 +1210,9 @@ static void cp_tx_timeout(struct net_device *dev)
 	unsigned long flags;
 	int rc;
 
-	pr_warning("%s: Transmit timeout, status %2x %4x %4x %4x\n",
-	       dev->name, cpr8(Cmd), cpr16(CpCmd),
-	       cpr16(IntrStatus), cpr16(IntrMask));
+	netdev_warn(dev, "Transmit timeout, status %2x %4x %4x %4x\n",
+		    cpr8(Cmd), cpr16(CpCmd),
+		    cpr16(IntrStatus), cpr16(IntrMask));
 
 	spin_lock_irqsave(&cp->lock, flags);
 
@@ -1873,8 +1865,8 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&
 	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 && pdev->revision < 0x20) {
 		dev_info(&pdev->dev,
-			   "This (id %04x:%04x rev %02x) is not an 8139C+ compatible chip, use 8139too\n",
-		           pdev->vendor, pdev->device, pdev->revision);
+			 "This (id %04x:%04x rev %02x) is not an 8139C+ compatible chip, use 8139too\n",
+			 pdev->vendor, pdev->device, pdev->revision);
 		return -ENODEV;
 	}
 
@@ -1932,14 +1924,13 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_err(&pdev->dev,
-				   "No usable DMA configuration, aborting.\n");
+				"No usable DMA configuration, aborting\n");
 			goto err_out_res;
 		}
 		rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
 			dev_err(&pdev->dev,
-				   "No usable consistent DMA configuration, "
-			           "aborting.\n");
+				"No usable consistent DMA configuration, aborting\n");
 			goto err_out_res;
 		}
 	}
@@ -1951,7 +1942,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (!regs) {
 		rc = -EIO;
 		dev_err(&pdev->dev, "Cannot map PCI MMIO (%Lx@%Lx)\n",
-		       (unsigned long long)pci_resource_len(pdev, 1),
+			(unsigned long long)pci_resource_len(pdev, 1),
 		       (unsigned long long)pciaddr);
 		goto err_out_res;
 	}
@@ -1989,11 +1980,8 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rc)
 		goto err_out_iomap;
 
-	pr_info("%s: RTL-8139C+ at 0x%lx, %pM, IRQ %d\n",
-		dev->name,
-		dev->base_addr,
-		dev->dev_addr,
-		dev->irq);
+	netdev_info(dev, "RTL-8139C+ at 0x%lx, %pM, IRQ %d\n",
+		    dev->base_addr, dev->dev_addr, dev->irq);
 
 	pci_set_drvdata(pdev, dev);
 
-- 
1.7.0.14.g7e948
