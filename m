From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/4] net: update the spider_net driver
Date: Thu, 18 Aug 2005 19:39:35 +0200
Message-ID: <200508181752.j7IHq2Qp001692@d03av02.boulder.ibm.com>
References: <200508181931.43481.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linuxppc64-dev@ozlabs.org, paulus@samba.org,
	linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <200508181931.43481.arnd@arndb.de>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

This update fixes a few bugs in the spider_net driver, relative to
the version in 2.6.13-rc6-mm1. Please merge the updated driver in the
2.6.14 cycle.

- Prevent PCI posting problems by using synchronous register access
  in critical places
- Check return value from firmware device tree functions
- fix device cleanup

From: Jens Osterkamp <osterkam@de.ibm.com>
Signed-off-by: Arnd Bergmann <arndb@de.ibm.com>

diff -u devel-akpm/drivers/net/spider_net.c linux-2.6.13-rc3/drivers/net/spider_net.c
--- devel-akpm/drivers/net/spider_net.c	2005-08-06 15:34:31.000000000 -0700
+++ linux-2.6.13-rc3/drivers/net/spider_net.c
@@ -109,6 +109,23 @@
 }
 
 /**
+ * spider_net_write_reg_sync - writes to an SMMIO register of a card
+ * @card: device structure
+ * @reg: register to write to
+ * @value: value to write into the specified SMMIO register
+ *
+ * Unlike spider_net_write_reg, this will also make sure the
+ * data arrives on the card by reading the reg again.
+ */
+static void
+spider_net_write_reg_sync(struct spider_net_card *card, u32 reg, u32 value)
+{
+	value = cpu_to_le32(value);
+	writel(value, card->regs + reg);
+	(void)readl(card->regs + reg);
+}
+
+/**
  * spider_net_rx_irq_off - switch off rx irq on this spider card
  * @card: device structure
  *
@@ -123,7 +140,7 @@
 	spin_lock_irqsave(&card->intmask_lock, flags);
 	regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
 	regvalue &= ~SPIDER_NET_RXINT;
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
+	spider_net_write_reg_sync(card, SPIDER_NET_GHIINT0MSK, regvalue);
 	spin_unlock_irqrestore(&card->intmask_lock, flags);
 }
 
@@ -196,7 +213,7 @@
 	spin_lock_irqsave(&card->intmask_lock, flags);
 	regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
 	regvalue |= SPIDER_NET_RXINT;
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
+	spider_net_write_reg_sync(card, SPIDER_NET_GHIINT0MSK, regvalue);
 	spin_unlock_irqrestore(&card->intmask_lock, flags);
 }
 
@@ -215,7 +232,7 @@
 	spin_lock_irqsave(&card->intmask_lock, flags);
 	regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
 	regvalue &= ~SPIDER_NET_TXINT;
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
+	spider_net_write_reg_sync(card, SPIDER_NET_GHIINT0MSK, regvalue);
 	spin_unlock_irqrestore(&card->intmask_lock, flags);
 }
 
@@ -234,7 +251,7 @@
 	spin_lock_irqsave(&card->intmask_lock, flags);
 	regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
 	regvalue |= SPIDER_NET_TXINT;
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
+	spider_net_write_reg_sync(card, SPIDER_NET_GHIINT0MSK, regvalue);
 	spin_unlock_irqrestore(&card->intmask_lock, flags);
 }
 
@@ -813,6 +830,9 @@
 	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
 	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
 
+	/* free_irq(netdev->irq, netdev);*/
+	free_irq(to_pci_dev(netdev->class_dev.dev)->irq, netdev);
+
 	spider_net_write_reg(card, SPIDER_NET_GDTDMACCNTR,
 			     SPIDER_NET_DMA_TX_FEND_VALUE);
 
@@ -822,10 +842,6 @@
 	/* release chains */
 	spider_net_release_tx_chain(card, 1);
 
-	/* switch off card */
-	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
-			     SPIDER_NET_CKRCTRL_STOP_VALUE);
-
 	spider_net_free_chain(card, &card->tx_chain);
 	spider_net_free_chain(card, &card->rx_chain);
 
@@ -1744,6 +1760,10 @@
 		goto register_int_failed;
 
 	spider_net_enable_card(card);
+	
+	netif_start_queue(netdev);
+	netif_carrier_on(netdev);
+	netif_poll_enable(netdev);
 
 	return 0;
 
@@ -2045,7 +2065,12 @@
 	netdev->irq = card->pdev->irq;
 
 	dn = pci_device_to_OF_node(card->pdev);
+	if (!dn)
+		return -EIO;
+
 	mac = (u8 *)get_property(dn, "local-mac-address", NULL);
+	if (!mac)
+		return -EIO;
 	memcpy(addr.sa_data, mac, ETH_ALEN);
 
 	result = spider_net_set_mac(netdev, &addr);
@@ -2241,12 +2266,17 @@
 
 	wait_event(card->waitq,
 		   atomic_read(&card->tx_timeout_task_counter) == 0);
-
+	
 	unregister_netdev(netdev);
+
+	/* switch off card */
+	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
+			     SPIDER_NET_CKRCTRL_STOP_VALUE);
+	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
+			     SPIDER_NET_CKRCTRL_RUN_VALUE);
+	
 	spider_net_undo_pci_setup(card);
 	free_netdev(netdev);
-
-	free_irq(to_pci_dev(netdev->class_dev.dev)->irq, netdev);
 }
 
 static struct pci_driver spider_net_driver = {
