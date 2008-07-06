From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 3/3] amd8111e: delete non NAPI code from the driver.
Date: Sun, 6 Jul 2008 23:44:03 +0200
Message-ID: <20080706214403.GB19387@electric-eye.fr.zoreil.com>
References: <20080704125446.GA30300@havoc.gtf.org> <20080705.211029.199316974.davem@davemloft.net> <20080705.212051.82650078.davem@davemloft.net> <20080706214109.GA13120@electric-eye.fr.zoreil.com> <20080706214255.GA19387@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59612 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752358AbYGFVoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 17:44:16 -0400
Content-Disposition: inline
In-Reply-To: <20080706214255.GA19387@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jiri Bohac <jbohac@suse.cz>
---
 arch/mips/configs/mtx1_defconfig     |    1 -
 arch/powerpc/configs/maple_defconfig |    1 -
 arch/x86/configs/x86_64_defconfig    |    1 -
 drivers/net/Kconfig                  |   14 ----
 drivers/net/amd8111e.c               |  137 ++--------------------------------
 5 files changed, 7 insertions(+), 147 deletions(-)

diff --git a/arch/mips/configs/mtx1_defconfig b/arch/mips/configs/mtx1_defconfig
index 6449635..636c517 100644
--- a/arch/mips/configs/mtx1_defconfig
+++ b/arch/mips/configs/mtx1_defconfig
@@ -1261,7 +1261,6 @@ CONFIG_NET_PCI=y
 CONFIG_PCNET32=m
 # CONFIG_PCNET32_NAPI is not set
 CONFIG_AMD8111_ETH=m
-# CONFIG_AMD8111E_NAPI is not set
 CONFIG_ADAPTEC_STARFIRE=m
 CONFIG_B44=m
 CONFIG_FORCEDETH=m
diff --git a/arch/powerpc/configs/maple_defconfig b/arch/powerpc/configs/maple_defconfig
index 7a166a3..9415c16 100644
--- a/arch/powerpc/configs/maple_defconfig
+++ b/arch/powerpc/configs/maple_defconfig
@@ -587,7 +587,6 @@ CONFIG_MII=y
 CONFIG_NET_PCI=y
 # CONFIG_PCNET32 is not set
 CONFIG_AMD8111_ETH=y
-# CONFIG_AMD8111E_NAPI is not set
 # CONFIG_ADAPTEC_STARFIRE is not set
 # CONFIG_B44 is not set
 # CONFIG_FORCEDETH is not set
diff --git a/arch/x86/configs/x86_64_defconfig b/arch/x86/configs/x86_64_defconfig
index c88a85a..3114453 100644
--- a/arch/x86/configs/x86_64_defconfig
+++ b/arch/x86/configs/x86_64_defconfig
@@ -712,7 +712,6 @@ CONFIG_TULIP=y
 CONFIG_NET_PCI=y
 # CONFIG_PCNET32 is not set
 CONFIG_AMD8111_ETH=y
-# CONFIG_AMD8111E_NAPI is not set
 # CONFIG_ADAPTEC_STARFIRE is not set
 CONFIG_B44=y
 CONFIG_FORCEDETH=y
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9255895..5717da9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1286,20 +1286,6 @@ config AMD8111_ETH
 	  To compile this driver as a module, choose M here. The module
 	  will be called amd8111e.
 
-config AMD8111E_NAPI
-	bool "Use RX polling (NAPI)"
-	depends on AMD8111_ETH
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  If in doubt, say N.
-
 config ADAPTEC_STARFIRE
 	tristate "Adaptec Starfire/DuraLAN support"
 	depends on NET_PCI && PCI
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 85f7276..c54967f 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -101,9 +101,9 @@ Revision History:
 
 #include "amd8111e.h"
 #define MODULE_NAME	"amd8111e"
-#define MODULE_VERS	"3.0.6"
+#define MODULE_VERS	"3.0.7"
 MODULE_AUTHOR("Advanced Micro Devices, Inc.");
-MODULE_DESCRIPTION ("AMD8111 based 10/100 Ethernet Controller. Driver Version 3.0.6");
+MODULE_DESCRIPTION ("AMD8111 based 10/100 Ethernet Controller. Driver Version "MODULE_VERS);
 MODULE_LICENSE("GPL");
 MODULE_DEVICE_TABLE(pci, amd8111e_pci_tbl);
 module_param_array(speed_duplex, int, NULL, 0);
@@ -671,11 +671,7 @@ This is the receive indication function for packets with vlan tag.
 */
 static int amd8111e_vlan_rx(struct amd8111e_priv *lp, struct sk_buff *skb, u16 vlan_tag)
 {
-#ifdef CONFIG_AMD8111E_NAPI
 	return vlan_hwaccel_receive_skb(skb, lp->vlgrp,vlan_tag);
-#else
-	return vlan_hwaccel_rx(skb, lp->vlgrp, vlan_tag);
-#endif /* CONFIG_AMD8111E_NAPI */
 }
 #endif
 
@@ -722,7 +718,6 @@ static int amd8111e_tx(struct net_device *dev)
 	return 0;
 }
 
-#ifdef CONFIG_AMD8111E_NAPI
 /* This function handles the driver receive operation in polling mode */
 static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 {
@@ -734,7 +729,6 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 	int min_pkt_len, status;
 	unsigned int intr0;
 	int num_rx_pkt = 0;
-	/*int max_rx_pkt = NUM_RX_BUFFERS;*/
 	short pkt_len;
 #if AMD8111E_VLAN_TAG_USED
 	short vtag;
@@ -850,108 +844,6 @@ rx_not_empty:
 	return num_rx_pkt;
 }
 
-#else
-/*
-This function will check the ownership of receive buffers and descriptors. It will indicate to kernel up to half the number of maximum receive buffers in the descriptor ring, in a single receive interrupt. It will also replenish the descriptors with new skbs.
-*/
-static int amd8111e_rx(struct net_device *dev)
-{
-	struct amd8111e_priv *lp = netdev_priv(dev);
-	struct sk_buff *skb,*new_skb;
-	int rx_index = lp->rx_idx & RX_RING_DR_MOD_MASK;
-	int min_pkt_len, status;
-	int num_rx_pkt = 0;
-	int max_rx_pkt = NUM_RX_BUFFERS;
-	short pkt_len;
-#if AMD8111E_VLAN_TAG_USED
-	short vtag;
-#endif
-
-	/* If we own the next entry, it's a new packet. Send it up. */
-	while(++num_rx_pkt <= max_rx_pkt){
-		status = le16_to_cpu(lp->rx_ring[rx_index].rx_flags);
-		if(status & OWN_BIT)
-			return 0;
-
-		/* check if err summary bit is set */
-		if(status & ERR_BIT){
-			/*
-			 * There is a tricky error noted by John Murphy,
-			 * <murf@perftech.com> to Russ Nelson: Even with full-sized
-			 * buffers it's possible for a jabber packet to use two
-			 * buffers, with only the last correctly noting the error.			 */
-			/* reseting flags */
-			lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
-			goto err_next_pkt;
-		}
-		/* check for STP and ENP */
-		if(!((status & STP_BIT) && (status & ENP_BIT))){
-			/* reseting flags */
-			lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
-			goto err_next_pkt;
-		}
-		pkt_len = le16_to_cpu(lp->rx_ring[rx_index].msg_count) - 4;
-
-#if AMD8111E_VLAN_TAG_USED
-		vtag = status & TT_MASK;
-		/*MAC will strip vlan tag*/
-		if(lp->vlgrp != NULL && vtag !=0)
-			min_pkt_len =MIN_PKT_LEN - 4;
-		else
-#endif
-			min_pkt_len =MIN_PKT_LEN;
-
-		if (pkt_len < min_pkt_len) {
-			lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
-			lp->drv_rx_errors++;
-			goto err_next_pkt;
-		}
-		if(!(new_skb = dev_alloc_skb(lp->rx_buff_len))){
-			/* if allocation fail,
-				ignore that pkt and go to next one */
-			lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
-			lp->drv_rx_errors++;
-			goto err_next_pkt;
-		}
-
-		skb_reserve(new_skb, 2);
-		skb = lp->rx_skbuff[rx_index];
-		pci_unmap_single(lp->pci_dev,lp->rx_dma_addr[rx_index],
-			lp->rx_buff_len-2, PCI_DMA_FROMDEVICE);
-		skb_put(skb, pkt_len);
-		lp->rx_skbuff[rx_index] = new_skb;
-		lp->rx_dma_addr[rx_index] = pci_map_single(lp->pci_dev,
-			new_skb->data, lp->rx_buff_len-2,PCI_DMA_FROMDEVICE);
-
-		skb->protocol = eth_type_trans(skb, dev);
-
-#if AMD8111E_VLAN_TAG_USED
-		if(lp->vlgrp != NULL && (vtag == TT_VLAN_TAGGED)){
-			amd8111e_vlan_rx(lp, skb,
-				 le16_to_cpu(lp->rx_ring[rx_index].tag_ctrl_info));
-		} else
-#endif
-
-			netif_rx (skb);
-			/*COAL update rx coalescing parameters*/
-			lp->coal_conf.rx_packets++;
-			lp->coal_conf.rx_bytes += pkt_len;
-
-			dev->last_rx = jiffies;
-
-err_next_pkt:
-		lp->rx_ring[rx_index].buff_phy_addr
-			 = cpu_to_le32(lp->rx_dma_addr[rx_index]);
-		lp->rx_ring[rx_index].buff_count =
-				cpu_to_le16(lp->rx_buff_len-2);
-		wmb();
-		lp->rx_ring[rx_index].rx_flags |= cpu_to_le16(OWN_BIT);
-		rx_index = (++lp->rx_idx) & RX_RING_DR_MOD_MASK;
-	}
-
-	return 0;
-}
-#endif /* CONFIG_AMD8111E_NAPI */
 /*
 This function will indicate the link status to the kernel.
 */
@@ -1280,29 +1172,22 @@ static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 	writel(intr0, mmio + INT0);
 
 	/* Check if Receive Interrupt has occurred. */
-#ifdef CONFIG_AMD8111E_NAPI
-	if(intr0 & RINT0){
-		if(netif_rx_schedule_prep(dev, &lp->napi)){
+	if (intr0 & RINT0) {
+		if (netif_rx_schedule_prep(dev, &lp->napi)) {
 			/* Disable receive interupts */
 			writel(RINTEN0, mmio + INTEN0);
 			/* Schedule a polling routine */
 			__netif_rx_schedule(dev, &lp->napi);
-		}
-		else if (intren0 & RINTEN0) {
+		} else if (intren0 & RINTEN0) {
 			printk("************Driver bug! \
 				interrupt while in poll\n");
 			/* Fix by disable receive interrupts */
 			writel(RINTEN0, mmio + INTEN0);
 		}
 	}
-#else
-	if(intr0 & RINT0){
-		amd8111e_rx(dev);
-		writel(VAL2 | RDMD0, mmio + CMD0);
-	}
-#endif /* CONFIG_AMD8111E_NAPI */
+
 	/* Check if  Transmit Interrupt has occurred. */
-	if(intr0 & TINT0)
+	if (intr0 & TINT0)
 		amd8111e_tx(dev);
 
 	/* Check if  Link Change Interrupt has occurred. */
@@ -1340,9 +1225,7 @@ static int amd8111e_close(struct net_device * dev)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	netif_stop_queue(dev);
 
-#ifdef CONFIG_AMD8111E_NAPI
 	napi_disable(&lp->napi);
-#endif
 
 	spin_lock_irq(&lp->lock);
 
@@ -1374,9 +1257,7 @@ static int amd8111e_open(struct net_device * dev )
 					 dev->name, dev))
 		return -EAGAIN;
 
-#ifdef CONFIG_AMD8111E_NAPI
 	napi_enable(&lp->napi);
-#endif
 
 	spin_lock_irq(&lp->lock);
 
@@ -1384,9 +1265,7 @@ static int amd8111e_open(struct net_device * dev )
 
 	if(amd8111e_restart(dev)){
 		spin_unlock_irq(&lp->lock);
-#ifdef CONFIG_AMD8111E_NAPI
 		napi_disable(&lp->napi);
-#endif
 		if (dev->irq)
 			free_irq(dev->irq, dev);
 		return -ENOMEM;
@@ -2036,9 +1915,7 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 	dev->irq =pdev->irq;
 	dev->tx_timeout = amd8111e_tx_timeout;
 	dev->watchdog_timeo = AMD8111E_TX_TIMEOUT;
-#ifdef CONFIG_AMD8111E_NAPI
 	netif_napi_add(dev, &lp->napi, amd8111e_rx_poll, 32);
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = amd8111e_poll;
 #endif
-- 
1.5.3.3

