From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Mon, 17 Dec 2007 21:01:42 -0500
Message-ID: <20071218020142.GA1580@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:43941 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429AbXLRCBn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 21:01:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A couple serious fixes (wireless, e100, sky2) and a bevy of minor ones.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 MAINTAINERS                                    |    6 ++
 drivers/net/e100.c                             |    5 ++-
 drivers/net/hamachi.c                          |   70 +++++++++++++-----------
 drivers/net/ibm_newemac/debug.c                |    2 +-
 drivers/net/ixgb/ixgb_main.c                   |   16 +++++-
 drivers/net/pcmcia/pcnet_cs.c                  |    1 +
 drivers/net/s2io.c                             |    4 +-
 drivers/net/sis190.c                           |   10 ++--
 drivers/net/sky2.c                             |    9 +++-
 drivers/net/smc911x.h                          |    2 +-
 drivers/net/starfire.c                         |    2 +-
 drivers/net/sundance.c                         |   34 ++++++------
 drivers/net/ucc_geth.c                         |    2 +-
 drivers/net/ucc_geth_mii.h                     |    2 +-
 drivers/net/wireless/Kconfig                   |    1 +
 drivers/net/wireless/b43/leds.c                |    4 ++
 drivers/net/wireless/b43/main.c                |   22 ++++----
 drivers/net/wireless/b43/rfkill.c              |   37 +++++++++++--
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c |    2 +-
 drivers/net/wireless/ipw2200.c                 |    7 ++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |    5 ++-
 drivers/net/wireless/iwlwifi/iwl4965-base.c    |    5 ++-
 drivers/net/wireless/zd1211rw/zd_mac.c         |   10 +++-
 net/mac80211/ieee80211_rate.c                  |    1 +
 24 files changed, 168 insertions(+), 91 deletions(-)

Adrian Bunk (3):
      drivers/net/sis190.c section fix
      drivers/net/s2io.c section fixes
      wireless/ipw2200.c: add __dev{init,exit} annotations

Al Viro (4):
      sundance fixes
      starfire VLAN fix
      hamachi endianness fixes
      sis190 endianness

Andrew Morton (2):
      ucc_geth: minor whitespace fix
      bcm43xx_debugfs sscanf fix

Anton Vorontsov (1):
      ucc_geth: really fix section mismatch

Auke Kok (1):
      e100: free IRQ to remove warningwhenrebooting

Cyrill Gorcunov (2):
      ieee80211_rate: missed unlock
      iwlwifi3945/4965: fix rate control algo reference leak

Dan Williams (1):
      libertas: select WIRELESS_EXT

Jiri Slaby (1):
      Net: ibm_newemac, remove SPIN_LOCK_UNLOCKED

Komuro (1):
      pcnet_cs: add new id

Larry Finger (1):
      b43: Fix rfkill radio LED

Matheos Worku (1):
      ixgb: make sure jumbos stay enabled after reset

Paul Mundt (1):
      net: smc911x: shut up compiler warnings

Stefano Brivio (1):
      libertas: add Dan Williams as maintainer

Stephen Hemminger (1):
      sky2: RX lockup fix

Ulrich Kunitz (1):
      zd1211rw: Fix alignment problems

Zhu Yi (1):
      iwlwifi: fix rf_kill state inconsistent during suspend and resume

diff --git a/MAINTAINERS b/MAINTAINERS
index 9507b42..c331ba3 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2489,6 +2489,12 @@ M:	mtk.manpages@gmail.com
 W:	ftp://ftp.kernel.org/pub/linux/docs/manpages
 S:	Maintained
 
+MARVELL LIBERTAS WIRELESS DRIVER
+P:	Dan Williams
+M:	dcbw@redhat.com
+L:	libertas-dev@lists.infradead.org
+S:	Maintained
+
 MARVELL MV643XX ETHERNET DRIVER
 P:	Dale Farnsworth
 M:	dale@farnsworth.org
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index e1c8a0d..2b06e4b 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2737,8 +2737,9 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	pci_disable_device(pdev);
 	free_irq(pdev->irq, netdev);
+
+	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
@@ -2780,6 +2781,8 @@ static void e100_shutdown(struct pci_dev *pdev)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
+	free_irq(pdev->irq, netdev);
+
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
 }
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index ed407c8..b53f6b6 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -204,8 +204,10 @@ KERN_INFO "   Further modifications by Keith Underwood <keithu@parl.clemson.edu>
 /* Condensed bus+endian portability operations. */
 #if ADDRLEN == 64
 #define cpu_to_leXX(addr)	cpu_to_le64(addr)
+#define leXX_to_cpu(addr)	le64_to_cpu(addr)
 #else
 #define cpu_to_leXX(addr)	cpu_to_le32(addr)
+#define leXX_to_cpu(addr)	le32_to_cpu(addr)
 #endif
 
 
@@ -465,12 +467,12 @@ enum intr_status_bits {
 
 /* The Hamachi Rx and Tx buffer descriptors. */
 struct hamachi_desc {
-	u32 status_n_length;
+	__le32 status_n_length;
 #if ADDRLEN == 64
 	u32 pad;
-	u64 addr;
+	__le64 addr;
 #else
-	u32 addr;
+	__le32 addr;
 #endif
 };
 
@@ -874,13 +876,13 @@ static int hamachi_open(struct net_device *dev)
 
 #if ADDRLEN == 64
 	/* writellll anyone ? */
-	writel(cpu_to_le64(hmp->rx_ring_dma), ioaddr + RxPtr);
-	writel(cpu_to_le64(hmp->rx_ring_dma) >> 32, ioaddr + RxPtr + 4);
-	writel(cpu_to_le64(hmp->tx_ring_dma), ioaddr + TxPtr);
-	writel(cpu_to_le64(hmp->tx_ring_dma) >> 32, ioaddr + TxPtr + 4);
+	writel(hmp->rx_ring_dma, ioaddr + RxPtr);
+	writel(hmp->rx_ring_dma >> 32, ioaddr + RxPtr + 4);
+	writel(hmp->tx_ring_dma, ioaddr + TxPtr);
+	writel(hmp->tx_ring_dma >> 32, ioaddr + TxPtr + 4);
 #else
-	writel(cpu_to_le32(hmp->rx_ring_dma), ioaddr + RxPtr);
-	writel(cpu_to_le32(hmp->tx_ring_dma), ioaddr + TxPtr);
+	writel(hmp->rx_ring_dma, ioaddr + RxPtr);
+	writel(hmp->tx_ring_dma, ioaddr + TxPtr);
 #endif
 
 	/* TODO:  It would make sense to organize this as words since the card
@@ -1019,8 +1021,8 @@ static inline int hamachi_tx(struct net_device *dev)
 		skb = hmp->tx_skbuff[entry];
 		if (skb) {
 			pci_unmap_single(hmp->pci_dev,
-				hmp->tx_ring[entry].addr, skb->len,
-				PCI_DMA_TODEVICE);
+				leXX_to_cpu(hmp->tx_ring[entry].addr),
+				skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb(skb);
 			hmp->tx_skbuff[entry] = NULL;
 		}
@@ -1071,10 +1073,10 @@ static void hamachi_tx_timeout(struct net_device *dev)
 	{
 		printk(KERN_DEBUG "  Rx ring %p: ", hmp->rx_ring);
 		for (i = 0; i < RX_RING_SIZE; i++)
-			printk(" %8.8x", (unsigned int)hmp->rx_ring[i].status_n_length);
+			printk(" %8.8x", le32_to_cpu(hmp->rx_ring[i].status_n_length));
 		printk("\n"KERN_DEBUG"  Tx ring %p: ", hmp->tx_ring);
 		for (i = 0; i < TX_RING_SIZE; i++)
-			printk(" %4.4x", hmp->tx_ring[i].status_n_length);
+			printk(" %4.4x", le32_to_cpu(hmp->tx_ring[i].status_n_length));
 		printk("\n");
 	}
 
@@ -1099,14 +1101,15 @@ static void hamachi_tx_timeout(struct net_device *dev)
 		struct sk_buff *skb;
 
 		if (i >= TX_RING_SIZE - 1)
-			hmp->tx_ring[i].status_n_length = cpu_to_le32(
-				DescEndRing |
-				(hmp->tx_ring[i].status_n_length & 0x0000FFFF));
+			hmp->tx_ring[i].status_n_length =
+				cpu_to_le32(DescEndRing) |
+				(hmp->tx_ring[i].status_n_length &
+				 cpu_to_le32(0x0000ffff));
 		else
-			hmp->tx_ring[i].status_n_length &= 0x0000ffff;
+			hmp->tx_ring[i].status_n_length &= cpu_to_le32(0x0000ffff);
 		skb = hmp->tx_skbuff[i];
 		if (skb){
-			pci_unmap_single(hmp->pci_dev, hmp->tx_ring[i].addr,
+			pci_unmap_single(hmp->pci_dev, leXX_to_cpu(hmp->tx_ring[i].addr),
 				skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb(skb);
 			hmp->tx_skbuff[i] = NULL;
@@ -1128,7 +1131,8 @@ static void hamachi_tx_timeout(struct net_device *dev)
 		struct sk_buff *skb = hmp->rx_skbuff[i];
 
 		if (skb){
-			pci_unmap_single(hmp->pci_dev, hmp->rx_ring[i].addr,
+			pci_unmap_single(hmp->pci_dev,
+				leXX_to_cpu(hmp->rx_ring[i].addr),
 				hmp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(skb);
 			hmp->rx_skbuff[i] = NULL;
@@ -1420,7 +1424,7 @@ static irqreturn_t hamachi_interrupt(int irq, void *dev_instance)
 					/* Free the original skb. */
 					if (skb){
 						pci_unmap_single(hmp->pci_dev,
-							hmp->tx_ring[entry].addr,
+							leXX_to_cpu(hmp->tx_ring[entry].addr),
 							skb->len,
 							PCI_DMA_TODEVICE);
 						dev_kfree_skb_irq(skb);
@@ -1500,11 +1504,11 @@ static int hamachi_rx(struct net_device *dev)
 		if (desc_status & DescOwn)
 			break;
 		pci_dma_sync_single_for_cpu(hmp->pci_dev,
-					    desc->addr,
+					    leXX_to_cpu(desc->addr),
 					    hmp->rx_buf_sz,
 					    PCI_DMA_FROMDEVICE);
 		buf_addr = (u8 *) hmp->rx_skbuff[entry]->data;
-		frame_status = le32_to_cpu(get_unaligned((s32*)&(buf_addr[data_size - 12])));
+		frame_status = le32_to_cpu(get_unaligned((__le32*)&(buf_addr[data_size - 12])));
 		if (hamachi_debug > 4)
 			printk(KERN_DEBUG "  hamachi_rx() status was %8.8x.\n",
 				frame_status);
@@ -1518,9 +1522,9 @@ static int hamachi_rx(struct net_device *dev)
 				   dev->name, desc, &hmp->rx_ring[hmp->cur_rx % RX_RING_SIZE]);
 			printk(KERN_WARNING "%s: Oversized Ethernet frame -- next status %x/%x last status %x.\n",
 				   dev->name,
-				   hmp->rx_ring[(hmp->cur_rx+1) % RX_RING_SIZE].status_n_length & 0xffff0000,
-				   hmp->rx_ring[(hmp->cur_rx+1) % RX_RING_SIZE].status_n_length & 0x0000ffff,
-				   hmp->rx_ring[(hmp->cur_rx-1) % RX_RING_SIZE].status_n_length);
+				   le32_to_cpu(hmp->rx_ring[(hmp->cur_rx+1) % RX_RING_SIZE].status_n_length) & 0xffff0000,
+				   le32_to_cpu(hmp->rx_ring[(hmp->cur_rx+1) % RX_RING_SIZE].status_n_length) & 0x0000ffff,
+				   le32_to_cpu(hmp->rx_ring[(hmp->cur_rx-1) % RX_RING_SIZE].status_n_length));
 			hmp->stats.rx_length_errors++;
 		} /* else  Omit for prototype errata??? */
 		if (frame_status & 0x00380000) {
@@ -1566,7 +1570,7 @@ static int hamachi_rx(struct net_device *dev)
 #endif
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(hmp->pci_dev,
-							    hmp->rx_ring[entry].addr,
+							    leXX_to_cpu(hmp->rx_ring[entry].addr),
 							    hmp->rx_buf_sz,
 							    PCI_DMA_FROMDEVICE);
 				/* Call copy + cksum if available. */
@@ -1579,12 +1583,12 @@ static int hamachi_rx(struct net_device *dev)
 					+ entry*sizeof(*desc), pkt_len);
 #endif
 				pci_dma_sync_single_for_device(hmp->pci_dev,
-							       hmp->rx_ring[entry].addr,
+							       leXX_to_cpu(hmp->rx_ring[entry].addr),
 							       hmp->rx_buf_sz,
 							       PCI_DMA_FROMDEVICE);
 			} else {
 				pci_unmap_single(hmp->pci_dev,
-						 hmp->rx_ring[entry].addr,
+						 leXX_to_cpu(hmp->rx_ring[entry].addr),
 						 hmp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 				skb_put(skb = hmp->rx_skbuff[entry], pkt_len);
 				hmp->rx_skbuff[entry] = NULL;
@@ -1787,21 +1791,21 @@ static int hamachi_close(struct net_device *dev)
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		skb = hmp->rx_skbuff[i];
 		hmp->rx_ring[i].status_n_length = 0;
-		hmp->rx_ring[i].addr = 0xBADF00D0; /* An invalid address. */
 		if (skb) {
 			pci_unmap_single(hmp->pci_dev,
-				hmp->rx_ring[i].addr, hmp->rx_buf_sz,
-				PCI_DMA_FROMDEVICE);
+				leXX_to_cpu(hmp->rx_ring[i].addr),
+				hmp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(skb);
 			hmp->rx_skbuff[i] = NULL;
 		}
+		hmp->rx_ring[i].addr = cpu_to_leXX(0xBADF00D0); /* An invalid address. */
 	}
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		skb = hmp->tx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(hmp->pci_dev,
-				hmp->tx_ring[i].addr, skb->len,
-				PCI_DMA_TODEVICE);
+				leXX_to_cpu(hmp->tx_ring[i].addr),
+				skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb(skb);
 			hmp->tx_skbuff[i] = NULL;
 		}
diff --git a/drivers/net/ibm_newemac/debug.c b/drivers/net/ibm_newemac/debug.c
index a2fc660..86b756a 100644
--- a/drivers/net/ibm_newemac/debug.c
+++ b/drivers/net/ibm_newemac/debug.c
@@ -26,7 +26,7 @@
 
 #include "core.h"
 
-static spinlock_t emac_dbg_lock = SPIN_LOCK_UNLOCKED;
+static DEFINE_SPINLOCK(emac_dbg_lock);
 
 static void emac_desc_dump(struct emac_instance *p)
 {
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 3021234..bf9085f 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -320,10 +320,22 @@ ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 void
 ixgb_reset(struct ixgb_adapter *adapter)
 {
+	struct ixgb_hw *hw = &adapter->hw;
 
-	ixgb_adapter_stop(&adapter->hw);
-	if(!ixgb_init_hw(&adapter->hw))
+	ixgb_adapter_stop(hw);
+	if (!ixgb_init_hw(hw))
 		DPRINTK(PROBE, ERR, "ixgb_init_hw failed.\n");
+
+	/* restore frame size information */
+	IXGB_WRITE_REG(hw, MFS, hw->max_frame_size << IXGB_MFS_SHIFT);
+	if (hw->max_frame_size >
+	    IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
+		u32 ctrl0 = IXGB_READ_REG(hw, CTRL0);
+		if (!(ctrl0 & IXGB_CTRL0_JFE)) {
+			ctrl0 |= IXGB_CTRL0_JFE;
+			IXGB_WRITE_REG(hw, CTRL0, ctrl0);
+		}
+	}
 }
 
 /**
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index db6a97d..51bbd58 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -1746,6 +1746,7 @@ static struct pcmcia_device_id pcnet_ids[] = {
 	PCMCIA_DEVICE_CIS_PROD_ID12("NDC", "Ethernet", 0x01c43ae1, 0x00b2e941, "NE2K.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("PMX   ", "PE-200", 0x34f3f1c8, 0x10b59f8c, "PE-200.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("TAMARACK", "Ethernet", 0xcf434fba, 0x00b2e941, "tamarack.cis"),
+	PCMCIA_DEVICE_PROD_ID12("Ethernet", "CF Size PC Card", 0x00b2e941, 0x43ac239b),
 	PCMCIA_DEVICE_PROD_ID123("Fast Ethernet", "CF Size PC Card", "1.0",
 		0xb4be14e3, 0x43ac239b, 0x0877b627),
 	PCMCIA_DEVICE_NULL
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 121cb10..9d80f1c 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3737,7 +3737,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 }
 
 /* Handle software interrupt used during MSI(X) test */
-static irqreturn_t __devinit s2io_test_intr(int irq, void *dev_id)
+static irqreturn_t s2io_test_intr(int irq, void *dev_id)
 {
 	struct s2io_nic *sp = dev_id;
 
@@ -3748,7 +3748,7 @@ static irqreturn_t __devinit s2io_test_intr(int irq, void *dev_id)
 }
 
 /* Test interrupt path by forcing a a software IRQ */
-static int __devinit s2io_test_msi(struct s2io_nic *sp)
+static int s2io_test_msi(struct s2io_nic *sp)
 {
 	struct pci_dev *pdev = sp->pdev;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 7200883..7eab072 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -474,7 +474,7 @@ static inline void sis190_map_to_asic(struct RxDesc *desc, dma_addr_t mapping,
 static inline void sis190_make_unusable_by_asic(struct RxDesc *desc)
 {
 	desc->PSize = 0x0;
-	desc->addr = 0xdeadbeef;
+	desc->addr = cpu_to_le32(0xdeadbeef);
 	desc->size &= cpu_to_le32(RingEnd);
 	wmb();
 	desc->status = 0x0;
@@ -580,7 +580,7 @@ static int sis190_rx_interrupt(struct net_device *dev,
 		struct RxDesc *desc = tp->RxDescRing + entry;
 		u32 status;
 
-		if (desc->status & OWNbit)
+		if (le32_to_cpu(desc->status) & OWNbit)
 			break;
 
 		status = le32_to_cpu(desc->PSize);
@@ -1381,7 +1381,7 @@ out:
 	return rc;
 }
 
-static void __devexit sis190_mii_remove(struct net_device *dev)
+static void sis190_mii_remove(struct net_device *dev)
 {
 	struct sis190_private *tp = netdev_priv(dev);
 
@@ -1538,9 +1538,9 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 
 	/* Get MAC address from EEPROM */
 	for (i = 0; i < MAC_ADDR_LEN / 2; i++) {
-		__le16 w = sis190_read_eeprom(ioaddr, EEPROMMACAddr + i);
+		u16 w = sis190_read_eeprom(ioaddr, EEPROMMACAddr + i);
 
-		((u16 *)dev->dev_addr)[i] = le16_to_cpu(w);
+		((__le16 *)dev->dev_addr)[i] = cpu_to_le16(w);
 	}
 
 	sis190_set_rgmii(tp, sis190_read_eeprom(ioaddr, EEPROMInfo));
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 6197afb..a74fc11 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -822,8 +822,13 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 
 	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), rx_reg);
 
-	/* Flush Rx MAC FIFO on any flow control or error */
-	sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), GMR_FS_ANY_ERR);
+	if (hw->chip_id == CHIP_ID_YUKON_XL) {
+		/* Hardware errata - clear flush mask */
+		sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), 0);
+	} else {
+		/* Flush Rx MAC FIFO on any flow control or error */
+		sky2_write16(hw, SK_REG(port, RX_GMF_FL_MSK), GMR_FS_ANY_ERR);
+	}
 
 	/* Set threshold to 0xa (64 bytes) + 1 to workaround pause bug  */
 	reg = RX_GMF_FL_THR_DEF + 1;
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index d04e4fa..7defa63 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -76,7 +76,7 @@
 
 
 
-#if	 SMC_USE_PXA_DMA
+#ifdef SMC_USE_PXA_DMA
 #define SMC_USE_DMA
 
 /*
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index bcc430b..6e00dc8 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1742,7 +1742,7 @@ static void set_rx_mode(struct net_device *dev)
 			if (vlan_group_get_device(np->vlgrp, i)) {
 				if (vlan_count >= 32)
 					break;
-				writew(cpu_to_be16(i), filter_addr);
+				writew(i, filter_addr);
 				filter_addr += 16;
 				vlan_count++;
 			}
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index ff98f5d..0a6186d 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -340,9 +340,9 @@ enum mac_ctrl1_bits {
 /* Note that using only 32 bit fields simplifies conversion to big-endian
    architectures. */
 struct netdev_desc {
-	u32 next_desc;
-	u32 status;
-	struct desc_frag { u32 addr, length; } frag[1];
+	__le32 next_desc;
+	__le32 status;
+	struct desc_frag { __le32 addr, length; } frag[1];
 };
 
 /* Bits in netdev_desc.status */
@@ -495,8 +495,8 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 		goto err_out_res;
 
 	for (i = 0; i < 3; i++)
-		((u16 *)dev->dev_addr)[i] =
-			le16_to_cpu(eeprom_read(ioaddr, i + EEPROM_SA_OFFSET));
+		((__le16 *)dev->dev_addr)[i] =
+			cpu_to_le16(eeprom_read(ioaddr, i + EEPROM_SA_OFFSET));
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	dev->base_addr = (unsigned long)ioaddr;
@@ -1090,8 +1090,8 @@ reset_tx (struct net_device *dev)
 		skb = np->tx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(np->pci_dev,
-				np->tx_ring[i].frag[0].addr, skb->len,
-				PCI_DMA_TODEVICE);
+				le32_to_cpu(np->tx_ring[i].frag[0].addr),
+				skb->len, PCI_DMA_TODEVICE);
 			if (irq)
 				dev_kfree_skb_irq (skb);
 			else
@@ -1214,7 +1214,7 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 				skb = np->tx_skbuff[entry];
 				/* Free the original skb. */
 				pci_unmap_single(np->pci_dev,
-					np->tx_ring[entry].frag[0].addr,
+					le32_to_cpu(np->tx_ring[entry].frag[0].addr),
 					skb->len, PCI_DMA_TODEVICE);
 				dev_kfree_skb_irq (np->tx_skbuff[entry]);
 				np->tx_skbuff[entry] = NULL;
@@ -1233,7 +1233,7 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 				skb = np->tx_skbuff[entry];
 				/* Free the original skb. */
 				pci_unmap_single(np->pci_dev,
-					np->tx_ring[entry].frag[0].addr,
+					le32_to_cpu(np->tx_ring[entry].frag[0].addr),
 					skb->len, PCI_DMA_TODEVICE);
 				dev_kfree_skb_irq (np->tx_skbuff[entry]);
 				np->tx_skbuff[entry] = NULL;
@@ -1311,19 +1311,19 @@ static void rx_poll(unsigned long data)
 				&& (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(np->pci_dev,
-							    desc->frag[0].addr,
+							    le32_to_cpu(desc->frag[0].addr),
 							    np->rx_buf_sz,
 							    PCI_DMA_FROMDEVICE);
 
 				skb_copy_to_linear_data(skb, np->rx_skbuff[entry]->data, pkt_len);
 				pci_dma_sync_single_for_device(np->pci_dev,
-							       desc->frag[0].addr,
+							       le32_to_cpu(desc->frag[0].addr),
 							       np->rx_buf_sz,
 							       PCI_DMA_FROMDEVICE);
 				skb_put(skb, pkt_len);
 			} else {
 				pci_unmap_single(np->pci_dev,
-					desc->frag[0].addr,
+					le32_to_cpu(desc->frag[0].addr),
 					np->rx_buf_sz,
 					PCI_DMA_FROMDEVICE);
 				skb_put(skb = np->rx_skbuff[entry], pkt_len);
@@ -1709,23 +1709,23 @@ static int netdev_close(struct net_device *dev)
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		np->rx_ring[i].status = 0;
-		np->rx_ring[i].frag[0].addr = 0xBADF00D0; /* An invalid address. */
 		skb = np->rx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(np->pci_dev,
-				np->rx_ring[i].frag[0].addr, np->rx_buf_sz,
-				PCI_DMA_FROMDEVICE);
+				le32_to_cpu(np->rx_ring[i].frag[0].addr),
+				np->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(skb);
 			np->rx_skbuff[i] = NULL;
 		}
+		np->rx_ring[i].frag[0].addr = cpu_to_le32(0xBADF00D0); /* poison */
 	}
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		np->tx_ring[i].next_desc = 0;
 		skb = np->tx_skbuff[i];
 		if (skb) {
 			pci_unmap_single(np->pci_dev,
-				np->tx_ring[i].frag[0].addr, skb->len,
-				PCI_DMA_TODEVICE);
+				le32_to_cpu(np->tx_ring[i].frag[0].addr),
+				skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb(skb);
 			np->tx_skbuff[i] = NULL;
 		}
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 7f68990..abac7db 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3447,7 +3447,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 	u16 length, howmany = 0;
 	u32 bd_status;
 	u8 *bdBuffer;
-	struct net_device * dev;
+	struct net_device *dev;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
diff --git a/drivers/net/ucc_geth_mii.h b/drivers/net/ucc_geth_mii.h
index d834370..1e45b20 100644
--- a/drivers/net/ucc_geth_mii.h
+++ b/drivers/net/ucc_geth_mii.h
@@ -96,5 +96,5 @@ enum enet_tbi_mii_reg {
 int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
 int uec_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
 int __init uec_mdio_init(void);
-void __exit uec_mdio_exit(void);
+void uec_mdio_exit(void);
 #endif				/* __UEC_MII_H */
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 2b733c5..5583719 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -264,6 +264,7 @@ config IPW2200_DEBUG
 config LIBERTAS
 	tristate "Marvell 8xxx Libertas WLAN driver support"
 	depends on WLAN_80211
+	select WIRELESS_EXT
 	select IEEE80211
 	select FW_LOADER
 	---help---
diff --git a/drivers/net/wireless/b43/leds.c b/drivers/net/wireless/b43/leds.c
index 19e5885..6c0e2b9 100644
--- a/drivers/net/wireless/b43/leds.c
+++ b/drivers/net/wireless/b43/leds.c
@@ -163,6 +163,9 @@ static void b43_map_led(struct b43_wldev *dev,
 		b43_register_led(dev, &dev->led_radio, name,
 				 b43_rfkill_led_name(dev),
 				 led_index, activelow);
+		/* Sync the RF-kill LED state with the switch state. */
+		if (dev->radio_hw_enable)
+			b43_led_turn_on(dev, led_index, activelow);
 		break;
 	case B43_LED_WEIRD:
 	case B43_LED_ASSOC:
@@ -232,4 +235,5 @@ void b43_leds_exit(struct b43_wldev *dev)
 	b43_unregister_led(&dev->led_tx);
 	b43_unregister_led(&dev->led_rx);
 	b43_unregister_led(&dev->led_assoc);
+	b43_unregister_led(&dev->led_radio);
 }
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index b45eecc..1c93b4f 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2163,7 +2163,6 @@ static void b43_mgmtframe_txantenna(struct b43_wldev *dev, int antenna)
 static void b43_chip_exit(struct b43_wldev *dev)
 {
 	b43_radio_turn_off(dev, 1);
-	b43_leds_exit(dev);
 	b43_gpio_cleanup(dev);
 	/* firmware is released later */
 }
@@ -2191,11 +2190,10 @@ static int b43_chip_init(struct b43_wldev *dev)
 	err = b43_gpio_init(dev);
 	if (err)
 		goto out;	/* firmware is released later */
-	b43_leds_init(dev);
 
 	err = b43_upload_initvals(dev);
 	if (err)
-		goto err_leds_exit;
+		goto err_gpio_clean;
 	b43_radio_turn_on(dev);
 
 	b43_write16(dev, 0x03E6, 0x0000);
@@ -2271,8 +2269,7 @@ out:
 
 err_radio_off:
 	b43_radio_turn_off(dev, 1);
-err_leds_exit:
-	b43_leds_exit(dev);
+err_gpio_clean:
 	b43_gpio_cleanup(dev);
 	return err;
 }
@@ -3273,10 +3270,7 @@ static void b43_wireless_core_exit(struct b43_wldev *dev)
 		return;
 	b43_set_status(dev, B43_STAT_UNINIT);
 
-	mutex_unlock(&dev->wl->mutex);
-	b43_rfkill_exit(dev);
-	mutex_lock(&dev->wl->mutex);
-
+	b43_leds_exit(dev);
 	b43_rng_exit(dev->wl);
 	b43_pio_free(dev);
 	b43_dma_free(dev);
@@ -3405,12 +3399,12 @@ static int b43_wireless_core_init(struct b43_wldev *dev)
 	memset(wl->mac_addr, 0, ETH_ALEN);
 	b43_upload_card_macaddress(dev);
 	b43_security_init(dev);
-	b43_rfkill_init(dev);
 	b43_rng_init(wl);
 
 	b43_set_status(dev, B43_STAT_INITIALIZED);
 
-      out:
+	b43_leds_init(dev);
+out:
 	return err;
 
       err_chip_exit:
@@ -3499,6 +3493,10 @@ static int b43_start(struct ieee80211_hw *hw)
 	int did_init = 0;
 	int err = 0;
 
+	/* First register RFkill.
+	 * LEDs that are registered later depend on it. */
+	b43_rfkill_init(dev);
+
 	mutex_lock(&wl->mutex);
 
 	if (b43_status(dev) < B43_STAT_INITIALIZED) {
@@ -3528,6 +3526,8 @@ static void b43_stop(struct ieee80211_hw *hw)
 	struct b43_wl *wl = hw_to_b43_wl(hw);
 	struct b43_wldev *dev = wl->current_dev;
 
+	b43_rfkill_exit(dev);
+
 	mutex_lock(&wl->mutex);
 	if (b43_status(dev) >= B43_STAT_STARTED)
 		b43_wireless_core_stop(dev);
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b43/rfkill.c
index 9b1f905..98cf70c 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -25,6 +25,8 @@
 #include "rfkill.h"
 #include "b43.h"
 
+#include <linux/kmod.h>
+
 
 /* Returns TRUE, if the radio is enabled in hardware. */
 static bool b43_is_hw_radio_enabled(struct b43_wldev *dev)
@@ -50,7 +52,10 @@ static void b43_rfkill_poll(struct input_polled_dev *poll_dev)
 	bool report_change = 0;
 
 	mutex_lock(&wl->mutex);
-	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
+	if (unlikely(b43_status(dev) < B43_STAT_INITIALIZED)) {
+		mutex_unlock(&wl->mutex);
+		return;
+	}
 	enabled = b43_is_hw_radio_enabled(dev);
 	if (unlikely(enabled != dev->radio_hw_enable)) {
 		dev->radio_hw_enable = enabled;
@@ -60,8 +65,12 @@ static void b43_rfkill_poll(struct input_polled_dev *poll_dev)
 	}
 	mutex_unlock(&wl->mutex);
 
-	if (unlikely(report_change))
-		input_report_key(poll_dev->input, KEY_WLAN, enabled);
+	/* send the radio switch event to the system - note both a key press
+	 * and a release are required */
+	if (unlikely(report_change)) {
+		input_report_key(poll_dev->input, KEY_WLAN, 1);
+		input_report_key(poll_dev->input, KEY_WLAN, 0);
+	}
 }
 
 /* Called when the RFKILL toggled in software. */
@@ -69,13 +78,15 @@ static int b43_rfkill_soft_toggle(void *data, enum rfkill_state state)
 {
 	struct b43_wldev *dev = data;
 	struct b43_wl *wl = dev->wl;
-	int err = 0;
+	int err = -EBUSY;
 
 	if (!wl->rfkill.registered)
 		return 0;
 
 	mutex_lock(&wl->mutex);
-	B43_WARN_ON(b43_status(dev) < B43_STAT_INITIALIZED);
+	if (b43_status(dev) < B43_STAT_INITIALIZED)
+		goto out_unlock;
+	err = 0;
 	switch (state) {
 	case RFKILL_STATE_ON:
 		if (!dev->radio_hw_enable) {
@@ -133,9 +144,25 @@ void b43_rfkill_init(struct b43_wldev *dev)
 	rfk->poll_dev->poll = b43_rfkill_poll;
 	rfk->poll_dev->poll_interval = 1000; /* msecs */
 
+	rfk->poll_dev->input->name = rfk->name;
+	rfk->poll_dev->input->id.bustype = BUS_HOST;
+	rfk->poll_dev->input->id.vendor = dev->dev->bus->boardinfo.vendor;
+	rfk->poll_dev->input->evbit[0] = BIT(EV_KEY);
+	set_bit(KEY_WLAN, rfk->poll_dev->input->keybit);
+
 	err = rfkill_register(rfk->rfkill);
 	if (err)
 		goto err_free_polldev;
+
+#ifdef CONFIG_RFKILL_INPUT_MODULE
+	/* B43 RF-kill isn't useful without the rfkill-input subsystem.
+	 * Try to load the module. */
+	err = request_module("rfkill-input");
+	if (err)
+		b43warn(wl, "Failed to load the rfkill-input module. "
+			"The built-in radio LED will not work.\n");
+#endif /* CONFIG_RFKILL_INPUT */
+
 	err = input_register_polled_device(rfk->poll_dev);
 	if (err)
 		goto err_unreg_rfk;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
index 35dbe45..76e9dd8 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c
@@ -219,7 +219,7 @@ static ssize_t tsf_write_file(struct file *file, const char __user *user_buf,
 	ssize_t buf_size;
 	ssize_t res;
 	unsigned long flags;
-	u64 tsf;
+	unsigned long long tsf;
 
 	buf_size = min(count, sizeof (really_big_buffer) - 1);
 	down(&big_buffer_sem);
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 54f44e5..da51f47 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -10751,7 +10751,7 @@ static void ipw_bg_link_down(struct work_struct *work)
 	mutex_unlock(&priv->mutex);
 }
 
-static int ipw_setup_deferred_work(struct ipw_priv *priv)
+static int __devinit ipw_setup_deferred_work(struct ipw_priv *priv)
 {
 	int ret = 0;
 
@@ -11600,7 +11600,8 @@ static void ipw_prom_free(struct ipw_priv *priv)
 #endif
 
 
-static int ipw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int __devinit ipw_pci_probe(struct pci_dev *pdev,
+				   const struct pci_device_id *ent)
 {
 	int err = 0;
 	struct net_device *net_dev;
@@ -11767,7 +11768,7 @@ static int ipw_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return err;
 }
 
-static void ipw_pci_remove(struct pci_dev *pdev)
+static void __devexit ipw_pci_remove(struct pci_dev *pdev)
 {
 	struct ipw_priv *priv = pci_get_drvdata(pdev);
 	struct list_head *p, *q;
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 4bdf237..3d1da07 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4743,8 +4743,10 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 		 *   when we loaded driver, and is now set to "enable".
 		 * After we're Alive, RF_KILL gets handled by
 		 *   iwl_rx_card_state_notif() */
-		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status))
+		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status)) {
+			clear_bit(STATUS_RF_KILL_HW, &priv->status);
 			queue_work(priv->workqueue, &priv->restart);
+		}
 
 		handled |= CSR_INT_BIT_RF_KILL;
 	}
@@ -6171,6 +6173,7 @@ static void iwl_alive_start(struct iwl_priv *priv)
 		mutex_lock(&priv->mutex);
 
 		if (rc) {
+			iwl_rate_control_unregister(priv->hw);
 			IWL_ERROR("Failed to register network "
 				  "device (error %d)\n", rc);
 			return;
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 8f85564..b54fe5e 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -5059,8 +5059,10 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 		 *   when we loaded driver, and is now set to "enable".
 		 * After we're Alive, RF_KILL gets handled by
 		 *   iwl_rx_card_state_notif() */
-		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status))
+		if (!hw_rf_kill && !test_bit(STATUS_ALIVE, &priv->status)) {
+			clear_bit(STATUS_RF_KILL_HW, &priv->status);
 			queue_work(priv->workqueue, &priv->restart);
+		}
 
 		handled |= CSR_INT_BIT_RF_KILL;
 	}
@@ -6527,6 +6529,7 @@ static void iwl_alive_start(struct iwl_priv *priv)
 		mutex_lock(&priv->mutex);
 
 		if (rc) {
+			iwl_rate_control_unregister(priv->hw);
 			IWL_ERROR("Failed to register network "
 				  "device (error %d)\n", rc);
 			return;
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a903645..5298a8b 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1130,6 +1130,8 @@ static void zd_mac_rx(struct zd_mac *mac, struct sk_buff *skb)
 	__skb_trim(skb, skb->len -
 		        (IEEE80211_FCS_LEN + sizeof(struct rx_status)));
 
+	ZD_ASSERT(IS_ALIGNED((unsigned long)skb->data, 4));
+
 	update_qual_rssi(mac, skb->data, skb->len, stats.signal,
 		         status->signal_strength);
 
@@ -1166,15 +1168,19 @@ static void do_rx(unsigned long mac_ptr)
 int zd_mac_rx_irq(struct zd_mac *mac, const u8 *buffer, unsigned int length)
 {
 	struct sk_buff *skb;
+	unsigned int reserved =
+		ALIGN(max_t(unsigned int,
+		            sizeof(struct zd_rt_hdr), ZD_PLCP_HEADER_SIZE), 4) -
+		ZD_PLCP_HEADER_SIZE;
 
-	skb = dev_alloc_skb(sizeof(struct zd_rt_hdr) + length);
+	skb = dev_alloc_skb(reserved + length);
 	if (!skb) {
 		struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
 		dev_warn(zd_mac_dev(mac), "Could not allocate skb.\n");
 		ieee->stats.rx_dropped++;
 		return -ENOMEM;
 	}
-	skb_reserve(skb, sizeof(struct zd_rt_hdr));
+	skb_reserve(skb, reserved);
 	memcpy(__skb_put(skb, length), buffer, length);
 	skb_queue_tail(&mac->rx_queue, skb);
 	tasklet_schedule(&mac->rx_tasklet);
diff --git a/net/mac80211/ieee80211_rate.c b/net/mac80211/ieee80211_rate.c
index 7254bd6..3260a4a 100644
--- a/net/mac80211/ieee80211_rate.c
+++ b/net/mac80211/ieee80211_rate.c
@@ -33,6 +33,7 @@ int ieee80211_rate_control_register(struct rate_control_ops *ops)
 		if (!strcmp(alg->ops->name, ops->name)) {
 			/* don't register an algorithm twice */
 			WARN_ON(1);
+			mutex_unlock(&rate_ctrl_mutex);
 			return -EALREADY;
 		}
 	}
