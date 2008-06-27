From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for .26
Date: Fri, 27 Jun 2008 01:40:34 -0400
Message-ID: <20080627054034.GA32593@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33041 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750930AbYF0Fkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:40:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 Documentation/networking/s2io.txt    |    6 ++--
 drivers/net/3c59x.c                  |    5 ++-
 drivers/net/e100.c                   |    2 +
 drivers/net/e1000/e1000_ethtool.c    |    2 +-
 drivers/net/e1000e/netdev.c          |    3 +-
 drivers/net/igb/igb_main.c           |    3 +-
 drivers/net/ipg.c                    |   16 +++++++-------
 drivers/net/ixgbe/ixgbe_main.c       |    3 +-
 drivers/net/netxen/netxen_nic_main.c |   18 ++++++++++------
 drivers/net/pcmcia/axnet_cs.c        |    2 +
 drivers/net/pcmcia/pcnet_cs.c        |    3 ++
 drivers/net/qla3xxx.c                |    2 +
 drivers/net/r6040.c                  |    2 +-
 drivers/net/s2io.c                   |   35 +++++++++++----------------------
 drivers/net/s2io.h                   |    4 ---
 drivers/net/tc35815.c                |    4 ++-
 drivers/net/wan/x25_asy.c            |    3 ++
 17 files changed, 60 insertions(+), 53 deletions(-)

Al Viro (1):
      [netdrvr] netxen: fix netxen_pci_tbl[] breakage

Andi Kleen (1):
      [netdrvr] Fix IOMMU overflow checking in s2io.c

Andy Gospodarek (1):
      e1000: only enable TSO6 via ethtool when using correct hardware

Atsushi Nemoto (2):
      tc35815: Mark carrier-off before starting PHY
      tc35815: Fix receiver hangup on Rx FIFO overflow

Ben Hutchings (2):
      qla3xxx: Hold RTNL while calling dev_close()
      Hold RTNL while calling dev_close()

Ingo Molnar (1):
      [netdrvr] 3c59x: remove irqs_disabled warning from local_bh_enable

Jeff Kirsher (2):
      igb: fix EEH recovery during reset on PPC
      e1000e: fix EEH recovery during reset on PPC

Julia Lawall (1):
      drivers/net/r6040.c: Eliminate double sizeof

Kevin Hao (1):
      e100: Do pci_dma_sync after skb_alloc for proper operation on ixp4xx

Komuro (1):
      pcnet_cs, axnet_cs: clear bogus interrupt before request_irq

Michal Schmidt (1):
      s2io: fix documentation about intr_type

Paul Larson (1):
      ixgbe: fix EEH recovery during reset on PPC

Pekka Enberg (2):
      ipg: fix jumbo frame compilation
      ipg: use NULL, not zero, for pointers

diff --git a/Documentation/networking/s2io.txt b/Documentation/networking/s2io.txt
index 4bde53e..1e28e2d 100644
--- a/Documentation/networking/s2io.txt
+++ b/Documentation/networking/s2io.txt
@@ -83,9 +83,9 @@ Valid range: Limited by memory on system
 Default: 30 
 
 e. intr_type
-Specifies interrupt type. Possible values 1(INTA), 2(MSI), 3(MSI-X)
-Valid range: 1-3
-Default: 1 
+Specifies interrupt type. Possible values 0(INTA), 2(MSI-X)
+Valid values: 0, 2
+Default: 2
 
 5.  Performance suggestions
 General:
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 2edda8c..aabad8c 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1768,9 +1768,10 @@ vortex_timer(unsigned long data)
 	case XCVR_MII: case XCVR_NWAY:
 		{
 			ok = 1;
-			spin_lock_bh(&vp->lock);
+			/* Interrupts are already disabled */
+			spin_lock(&vp->lock);
 			vortex_check_media(dev, 0);
-			spin_unlock_bh(&vp->lock);
+			spin_unlock(&vp->lock);
 		}
 		break;
 	  default:					/* Other media types handled by Tx timeouts. */
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index f3cba5e..1037b13 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1803,6 +1803,8 @@ static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 	if (rx->prev->skb) {
 		struct rfd *prev_rfd = (struct rfd *)rx->prev->skb->data;
 		put_unaligned_le32(rx->dma_addr, &prev_rfd->link);
+		pci_dma_sync_single_for_device(nic->pdev, rx->prev->dma_addr,
+			sizeof(struct rfd), PCI_DMA_TODEVICE);
 	}
 
 	return 0;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 701531e..a3f6a9c 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -347,7 +347,7 @@ e1000_set_tso(struct net_device *netdev, u32 data)
 	else
 		netdev->features &= ~NETIF_F_TSO;
 
-	if (data)
+	if (data && (adapter->hw.mac_type > e1000_82547_rev_2))
 		netdev->features |= NETIF_F_TSO6;
 	else
 		netdev->features &= ~NETIF_F_TSO6;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index cab1835..648a87b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2535,7 +2535,8 @@ void e1000e_down(struct e1000_adapter *adapter)
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 
-	e1000e_reset(adapter);
+	if (!pci_channel_offline(adapter->pdev))
+		e1000e_reset(adapter);
 	e1000_clean_tx_ring(adapter);
 	e1000_clean_rx_ring(adapter);
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ae398f0..e79a26a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -718,7 +718,8 @@ void igb_down(struct igb_adapter *adapter)
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 
-	igb_reset(adapter);
+	if (!pci_channel_offline(adapter->pdev))
+		igb_reset(adapter);
 	igb_clean_all_tx_rings(adapter);
 	igb_clean_all_rx_rings(adapter);
 }
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 679a082..2c03f4e 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1271,7 +1271,7 @@ static void ipg_nic_rx_with_end(struct net_device *dev,
 
 			framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
 
-			endframeLen = framelen - jumbo->current_size;
+			endframelen = framelen - jumbo->current_size;
 			/*
 			if (framelen > IPG_RXFRAG_SIZE)
 				framelen=IPG_RXFRAG_SIZE;
@@ -1279,8 +1279,8 @@ static void ipg_nic_rx_with_end(struct net_device *dev,
 			if (framelen > IPG_RXSUPPORT_SIZE)
 				dev_kfree_skb_irq(jumbo->skb);
 			else {
-				memcpy(skb_put(jumbo->skb, endframeLen),
-				       skb->data, endframeLen);
+				memcpy(skb_put(jumbo->skb, endframelen),
+				       skb->data, endframelen);
 
 				jumbo->skb->protocol =
 				    eth_type_trans(jumbo->skb, dev);
@@ -1352,16 +1352,16 @@ static int ipg_nic_rx(struct net_device *dev)
 
 		switch (ipg_nic_rx_check_frame_type(dev)) {
 		case FRAME_WITH_START_WITH_END:
-			ipg_nic_rx_with_start_and_end(dev, tp, rxfd, entry);
+			ipg_nic_rx_with_start_and_end(dev, sp, rxfd, entry);
 			break;
 		case FRAME_WITH_START:
-			ipg_nic_rx_with_start(dev, tp, rxfd, entry);
+			ipg_nic_rx_with_start(dev, sp, rxfd, entry);
 			break;
 		case FRAME_WITH_END:
-			ipg_nic_rx_with_end(dev, tp, rxfd, entry);
+			ipg_nic_rx_with_end(dev, sp, rxfd, entry);
 			break;
 		case FRAME_NO_START_NO_END:
-			ipg_nic_rx_no_start_no_end(dev, tp, rxfd, entry);
+			ipg_nic_rx_no_start_no_end(dev, sp, rxfd, entry);
 			break;
 		}
 	}
@@ -1808,7 +1808,7 @@ static int ipg_nic_open(struct net_device *dev)
 	/* initialize JUMBO Frame control variable */
 	sp->jumbo.found_start = 0;
 	sp->jumbo.current_size = 0;
-	sp->jumbo.skb = 0;
+	sp->jumbo.skb = NULL;
 	dev->mtu = IPG_TXFRAG_SIZE;
 #endif
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7b85922..8f04609 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1969,7 +1969,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	ixgbe_reset(adapter);
+	if (!pci_channel_offline(adapter->pdev))
+		ixgbe_reset(adapter);
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6797ed0..63cd67b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -71,14 +71,18 @@ static irqreturn_t netxen_intr(int irq, void *data);
 static irqreturn_t netxen_msi_intr(int irq, void *data);
 
 /*  PCI Device ID Table  */
+#define ENTRY(device) \
+	{PCI_DEVICE(0x4040, (device)), \
+	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
+
 static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
-	{PCI_DEVICE(0x4040, 0x0001), PCI_DEVICE_CLASS(0x020000, ~0)},
-	{PCI_DEVICE(0x4040, 0x0002), PCI_DEVICE_CLASS(0x020000, ~0)},
-	{PCI_DEVICE(0x4040, 0x0003), PCI_DEVICE_CLASS(0x020000, ~0)},
-	{PCI_DEVICE(0x4040, 0x0004), PCI_DEVICE_CLASS(0x020000, ~0)},
-	{PCI_DEVICE(0x4040, 0x0005), PCI_DEVICE_CLASS(0x020000, ~0)},
-	{PCI_DEVICE(0x4040, 0x0024), PCI_DEVICE_CLASS(0x020000, ~0)},
-	{PCI_DEVICE(0x4040, 0x0025), PCI_DEVICE_CLASS(0x020000, ~0)},
+	ENTRY(0x0001),
+	ENTRY(0x0002),
+	ENTRY(0x0003),
+	ENTRY(0x0004),
+	ENTRY(0x0005),
+	ENTRY(0x0024),
+	ENTRY(0x0025),
 	{0,}
 };
 
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index ce95c5d..70d012e 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -525,12 +525,14 @@ static int axnet_open(struct net_device *dev)
     int ret;
     axnet_dev_t *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
+    unsigned int nic_base = dev->base_addr;
     
     DEBUG(2, "axnet_open('%s')\n", dev->name);
 
     if (!pcmcia_dev_present(link))
 	return -ENODEV;
 
+    outb_p(0xFF, nic_base + EN0_ISR); /* Clear bogus intr. */
     ret = request_irq(dev->irq, ei_irq_wrapper, IRQF_SHARED, "axnet_cs", dev);
     if (ret)
 	    return ret;
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index fd8158a..2d4c4ad 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -969,6 +969,7 @@ static int pcnet_open(struct net_device *dev)
     int ret;
     pcnet_dev_t *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
+    unsigned int nic_base = dev->base_addr;
 
     DEBUG(2, "pcnet_open('%s')\n", dev->name);
 
@@ -976,6 +977,8 @@ static int pcnet_open(struct net_device *dev)
 	return -ENODEV;
 
     set_misc_reg(dev);
+
+    outb_p(0xFF, nic_base + EN0_ISR); /* Clear bogus intr. */
     ret = request_irq(dev->irq, ei_irq_wrapper, IRQF_SHARED, dev_info, dev);
     if (ret)
 	    return ret;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index b7f7b22..bccee68 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3701,7 +3701,9 @@ static int ql_cycle_adapter(struct ql3_adapter *qdev, int reset)
 		printk(KERN_ERR PFX
 				"%s: Driver up/down cycle failed, "
 				"closing device\n",qdev->ndev->name);
+		rtnl_lock();
 		dev_close(qdev->ndev);
+		rtnl_unlock();
 		return -1;
 	}
 	return 0;
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 858b191..504a48f 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -273,7 +273,7 @@ static void r6040_init_ring_desc(struct r6040_descriptor *desc_ring,
 	dma_addr_t mapping = desc_dma;
 
 	while (size-- > 0) {
-		mapping += sizeof(sizeof(*desc));
+		mapping += sizeof(*desc);
 		desc->ndesc = cpu_to_le32(mapping);
 		desc->vndescp = desc + 1;
 		desc++;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index b5c1e66..ae7b697 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2625,9 +2625,7 @@ static int fill_rx_buffers(struct ring_info *ring)
 			rxdp1->Buffer0_ptr = pci_map_single
 			    (ring->pdev, skb->data, size - NET_IP_ALIGN,
 				PCI_DMA_FROMDEVICE);
-			if( (rxdp1->Buffer0_ptr == 0) ||
-				(rxdp1->Buffer0_ptr ==
-				DMA_ERROR_CODE))
+			if(pci_dma_mapping_error(rxdp1->Buffer0_ptr))
 				goto pci_map_failed;
 
 			rxdp->Control_2 =
@@ -2657,6 +2655,7 @@ static int fill_rx_buffers(struct ring_info *ring)
 			skb->data = (void *) (unsigned long)tmp;
 			skb_reset_tail_pointer(skb);
 
+			/* AK: check is wrong. 0 can be valid dma address */
 			if (!(rxdp3->Buffer0_ptr))
 				rxdp3->Buffer0_ptr =
 				   pci_map_single(ring->pdev, ba->ba_0,
@@ -2665,8 +2664,7 @@ static int fill_rx_buffers(struct ring_info *ring)
 				pci_dma_sync_single_for_device(ring->pdev,
 				(dma_addr_t) rxdp3->Buffer0_ptr,
 				    BUF0_LEN, PCI_DMA_FROMDEVICE);
-			if( (rxdp3->Buffer0_ptr == 0) ||
-				(rxdp3->Buffer0_ptr == DMA_ERROR_CODE))
+			if (pci_dma_mapping_error(rxdp3->Buffer0_ptr))
 				goto pci_map_failed;
 
 			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
@@ -2681,18 +2679,17 @@ static int fill_rx_buffers(struct ring_info *ring)
 				(ring->pdev, skb->data, ring->mtu + 4,
 						PCI_DMA_FROMDEVICE);
 
-				if( (rxdp3->Buffer2_ptr == 0) ||
-					(rxdp3->Buffer2_ptr == DMA_ERROR_CODE))
+				if (pci_dma_mapping_error(rxdp3->Buffer2_ptr))
 					goto pci_map_failed;
 
+				/* AK: check is wrong */
 				if (!rxdp3->Buffer1_ptr)
 					rxdp3->Buffer1_ptr =
 						pci_map_single(ring->pdev,
 						ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
 
-				if( (rxdp3->Buffer1_ptr == 0) ||
-					(rxdp3->Buffer1_ptr == DMA_ERROR_CODE)) {
+				if (pci_dma_mapping_error(rxdp3->Buffer1_ptr)) {
 					pci_unmap_single
 						(ring->pdev,
 						(dma_addr_t)(unsigned long)
@@ -4264,16 +4261,14 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
 					fifo->ufo_in_band_v,
 					sizeof(u64), PCI_DMA_TODEVICE);
-		if((txdp->Buffer_Pointer == 0) ||
-			(txdp->Buffer_Pointer == DMA_ERROR_CODE))
+		if (pci_dma_mapping_error(txdp->Buffer_Pointer))
 			goto pci_map_failed;
 		txdp++;
 	}
 
 	txdp->Buffer_Pointer = pci_map_single
 	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);
-	if((txdp->Buffer_Pointer == 0) ||
-		(txdp->Buffer_Pointer == DMA_ERROR_CODE))
+	if (pci_dma_mapping_error(txdp->Buffer_Pointer))
 		goto pci_map_failed;
 
 	txdp->Host_Control = (unsigned long) skb;
@@ -6884,10 +6879,8 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 				pci_map_single( sp->pdev, (*skb)->data,
 					size - NET_IP_ALIGN,
 					PCI_DMA_FROMDEVICE);
-			if( (rxdp1->Buffer0_ptr == 0) ||
-				(rxdp1->Buffer0_ptr == DMA_ERROR_CODE)) {
+			if (pci_dma_mapping_error(rxdp1->Buffer0_ptr))
 				goto memalloc_failed;
-			}
 			rxdp->Host_Control = (unsigned long) (*skb);
 		}
 	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control == 0)) {
@@ -6913,15 +6906,12 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
 					       PCI_DMA_FROMDEVICE);
-			if( (rxdp3->Buffer2_ptr == 0) ||
-				(rxdp3->Buffer2_ptr == DMA_ERROR_CODE)) {
+			if (pci_dma_mapping_error(rxdp3->Buffer2_ptr))
 				goto memalloc_failed;
-			}
 			rxdp3->Buffer0_ptr = *temp0 =
 				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
 						PCI_DMA_FROMDEVICE);
-			if( (rxdp3->Buffer0_ptr == 0) ||
-				(rxdp3->Buffer0_ptr == DMA_ERROR_CODE)) {
+			if (pci_dma_mapping_error(rxdp3->Buffer0_ptr)) {
 				pci_unmap_single (sp->pdev,
 					(dma_addr_t)rxdp3->Buffer2_ptr,
 					dev->mtu + 4, PCI_DMA_FROMDEVICE);
@@ -6933,8 +6923,7 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			rxdp3->Buffer1_ptr = *temp1 =
 				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
 						PCI_DMA_FROMDEVICE);
-			if( (rxdp3->Buffer1_ptr == 0) ||
-				(rxdp3->Buffer1_ptr == DMA_ERROR_CODE)) {
+			if (pci_dma_mapping_error(rxdp3->Buffer1_ptr)) {
 				pci_unmap_single (sp->pdev,
 					(dma_addr_t)rxdp3->Buffer0_ptr,
 					BUF0_LEN, PCI_DMA_FROMDEVICE);
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 4706f7f..1827b66 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -75,10 +75,6 @@ static int debug_level = ERR_DBG;
 /* DEBUG message print. */
 #define DBG_PRINT(dbg_level, args...)  if(!(debug_level<dbg_level)) printk(args)
 
-#ifndef DMA_ERROR_CODE
-#define DMA_ERROR_CODE          (~(dma_addr_t)0x0)
-#endif
-
 /* Protocol assist features of the NIC */
 #define L3_CKSUM_OK 0xFFFF
 #define L4_CKSUM_OK 0xFFFF
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 10e4e85..b07b8cb 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1394,6 +1394,7 @@ tc35815_open(struct net_device *dev)
 	tc35815_chip_init(dev);
 	spin_unlock_irq(&lp->lock);
 
+	netif_carrier_off(dev);
 	/* schedule a link state check */
 	phy_start(lp->phy_dev);
 
@@ -1735,7 +1736,6 @@ tc35815_rx(struct net_device *dev)
 			skb = lp->rx_skbs[cur_bd].skb;
 			prefetch(skb->data);
 			lp->rx_skbs[cur_bd].skb = NULL;
-			lp->fbl_count--;
 			pci_unmap_single(lp->pci_dev,
 					 lp->rx_skbs[cur_bd].skb_dma,
 					 RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
@@ -1791,6 +1791,7 @@ tc35815_rx(struct net_device *dev)
 #ifdef TC35815_USE_PACKEDBUFFER
 			while (lp->fbl_curid != id)
 #else
+			lp->fbl_count--;
 			while (lp->fbl_count < RX_BUF_NUM)
 #endif
 			{
@@ -2453,6 +2454,7 @@ static int tc35815_resume(struct pci_dev *pdev)
 		return 0;
 	pci_set_power_state(pdev, PCI_D0);
 	tc35815_restart(dev);
+	netif_carrier_off(dev);
 	if (lp->phy_dev)
 		phy_start(lp->phy_dev);
 	netif_device_attach(dev);
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 249e180..069f8bb 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -32,6 +32,7 @@
 #include <linux/x25.h>
 #include <linux/lapb.h>
 #include <linux/init.h>
+#include <linux/rtnetlink.h>
 #include "x25_asy.h"
 
 #include <net/x25device.h>
@@ -601,8 +602,10 @@ static void x25_asy_close_tty(struct tty_struct *tty)
 	if (!sl || sl->magic != X25_ASY_MAGIC)
 		return;
 
+	rtnl_lock();
 	if (sl->dev->flags & IFF_UP)
 		dev_close(sl->dev);
+	rtnl_unlock();
 
 	tty->disc_data = NULL;
 	sl->tty = NULL;
