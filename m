From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 2/2] tc35815: Kill unused code
Date: Mon,  2 Nov 2009 23:34:47 +0900
Message-ID: <1257172487-5656-2-git-send-email-anemo@mba.ocn.ne.jp>
Cc: David Miller <davem@davemloft.net>,
	Ralf Roesch <ralf.roesch@rw-gmbh.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:61643 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755179AbZKBOeq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 09:34:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- TC35815_DMA_SYNC_ONDEMAND is always enabled.
- WORKAROUND_LOSTCAR is always enabled.
- WORKAROUND_100HALF_PROMISC is always enabled.
- GATHER_TXINT is always enabled.
- TC35815_USE_PACKEDBUFFER is always disabled.
- NO_CHECK_CARRIER is always disabled.
---
 drivers/net/tc35815.c |  224 +------------------------------------------------
 1 files changed, 3 insertions(+), 221 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 803eb64..6572e8a 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -50,13 +50,6 @@ static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #include <asm/io.h>
 #include <asm/byteorder.h>
 
-/* First, a few definitions that the brave might change. */
-
-#define GATHER_TXINT	/* On-Demand Tx Interrupt */
-#define WORKAROUND_LOSTCAR
-#define WORKAROUND_100HALF_PROMISC
-/* #define TC35815_USE_PACKEDBUFFER */
-
 enum tc35815_chiptype {
 	TC35815CF = 0,
 	TC35815_NWU,
@@ -326,17 +319,10 @@ struct BDesc {
 
 
 /* Some useful constants. */
-#undef NO_CHECK_CARRIER	/* Does not check No-Carrier with TP */
 
-#ifdef NO_CHECK_CARRIER
-#define TX_CTL_CMD	(Tx_EnComp | Tx_EnTxPar | Tx_EnLateColl | \
-	Tx_EnExColl | Tx_EnExDefer | Tx_EnUnder | \
-	Tx_En)	/* maybe  0x7b01 */
-#else
-#define TX_CTL_CMD	(Tx_EnComp | Tx_EnTxPar | Tx_EnLateColl | \
+#define TX_CTL_CMD	(Tx_EnTxPar | Tx_EnLateColl | \
 	Tx_EnExColl | Tx_EnLCarr | Tx_EnExDefer | Tx_EnUnder | \
 	Tx_En)	/* maybe  0x7b01 */
-#endif
 /* Do not use Rx_StripCRC -- it causes trouble on BLEx/FDAEx condition */
 #define RX_CTL_CMD	(Rx_EnGood | Rx_EnRxPar | Rx_EnLongErr | Rx_EnOver \
 	| Rx_EnCRCErr | Rx_EnAlign | Rx_RxEn) /* maybe 0x6f01 */
@@ -357,13 +343,6 @@ struct BDesc {
 #define TX_THRESHOLD_KEEP_LIMIT 10
 
 /* 16 + RX_BUF_NUM * 8 + RX_FD_NUM * 16 + TX_FD_NUM * 32 <= PAGE_SIZE*FD_PAGE_NUM */
-#ifdef TC35815_USE_PACKEDBUFFER
-#define FD_PAGE_NUM 2
-#define RX_BUF_NUM	8	/* >= 2 */
-#define RX_FD_NUM	250	/* >= 32 */
-#define TX_FD_NUM	128
-#define RX_BUF_SIZE	PAGE_SIZE
-#else /* TC35815_USE_PACKEDBUFFER */
 #define FD_PAGE_NUM 4
 #define RX_BUF_NUM	128	/* < 256 */
 #define RX_FD_NUM	256	/* >= 32 */
@@ -377,7 +356,6 @@ struct BDesc {
 #define RX_BUF_SIZE	\
 	L1_CACHE_ALIGN(ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN + NET_IP_ALIGN)
 #endif
-#endif /* TC35815_USE_PACKEDBUFFER */
 #define RX_FD_RESERVE	(2 / 2)	/* max 2 BD per RxFD */
 #define NAPI_WEIGHT	16
 
@@ -435,11 +413,7 @@ struct tc35815_local {
 	/*
 	 * Transmitting: Batch Mode.
 	 *	1 BD in 1 TxFD.
-	 * Receiving: Packing Mode. (TC35815_USE_PACKEDBUFFER)
-	 *	1 circular FD for Free Buffer List.
-	 *	RX_BUF_NUM BD in Free Buffer FD.
-	 *	One Free Buffer BD has PAGE_SIZE data buffer.
-	 * Or Non-Packing Mode.
+	 * Receiving: Non-Packing Mode.
 	 *	1 circular FD for Free Buffer List.
 	 *	RX_BUF_NUM BD in Free Buffer FD.
 	 *	One Free Buffer BD has ETH_FRAME_LEN data buffer.
@@ -453,21 +427,11 @@ struct tc35815_local {
 	struct RxFD *rfd_limit;
 	struct RxFD *rfd_cur;
 	struct FrFD *fbl_ptr;
-#ifdef TC35815_USE_PACKEDBUFFER
-	unsigned char fbl_curid;
-	void *data_buf[RX_BUF_NUM];		/* packing */
-	dma_addr_t data_buf_dma[RX_BUF_NUM];
-	struct {
-		struct sk_buff *skb;
-		dma_addr_t skb_dma;
-	} tx_skbs[TX_FD_NUM];
-#else
 	unsigned int fbl_count;
 	struct {
 		struct sk_buff *skb;
 		dma_addr_t skb_dma;
 	} tx_skbs[TX_FD_NUM], rx_skbs[RX_BUF_NUM];
-#endif
 	u32 msg_enable;
 	enum tc35815_chiptype chiptype;
 };
@@ -482,51 +446,6 @@ static inline void *fd_bus_to_virt(struct tc35815_local *lp, dma_addr_t bus)
 	return (void *)((u8 *)lp->fd_buf + (bus - lp->fd_buf_dma));
 }
 #endif
-#ifdef TC35815_USE_PACKEDBUFFER
-static inline void *rxbuf_bus_to_virt(struct tc35815_local *lp, dma_addr_t bus)
-{
-	int i;
-	for (i = 0; i < RX_BUF_NUM; i++) {
-		if (bus >= lp->data_buf_dma[i] &&
-		    bus < lp->data_buf_dma[i] + PAGE_SIZE)
-			return (void *)((u8 *)lp->data_buf[i] +
-					(bus - lp->data_buf_dma[i]));
-	}
-	return NULL;
-}
-
-#define TC35815_DMA_SYNC_ONDEMAND
-static void *alloc_rxbuf_page(struct pci_dev *hwdev, dma_addr_t *dma_handle)
-{
-#ifdef TC35815_DMA_SYNC_ONDEMAND
-	void *buf;
-	/* pci_map + pci_dma_sync will be more effective than
-	 * pci_alloc_consistent on some archs. */
-	buf = (void *)__get_free_page(GFP_ATOMIC);
-	if (!buf)
-		return NULL;
-	*dma_handle = pci_map_single(hwdev, buf, PAGE_SIZE,
-				     PCI_DMA_FROMDEVICE);
-	if (pci_dma_mapping_error(hwdev, *dma_handle)) {
-		free_page((unsigned long)buf);
-		return NULL;
-	}
-	return buf;
-#else
-	return pci_alloc_consistent(hwdev, PAGE_SIZE, dma_handle);
-#endif
-}
-
-static void free_rxbuf_page(struct pci_dev *hwdev, void *buf, dma_addr_t dma_handle)
-{
-#ifdef TC35815_DMA_SYNC_ONDEMAND
-	pci_unmap_single(hwdev, dma_handle, PAGE_SIZE, PCI_DMA_FROMDEVICE);
-	free_page((unsigned long)buf);
-#else
-	pci_free_consistent(hwdev, PAGE_SIZE, buf, dma_handle);
-#endif
-}
-#else /* TC35815_USE_PACKEDBUFFER */
 static struct sk_buff *alloc_rxbuf_skb(struct net_device *dev,
 				       struct pci_dev *hwdev,
 				       dma_addr_t *dma_handle)
@@ -551,7 +470,6 @@ static void free_rxbuf_skb(struct pci_dev *hwdev, struct sk_buff *skb, dma_addr_
 			 PCI_DMA_FROMDEVICE);
 	dev_kfree_skb_any(skb);
 }
-#endif /* TC35815_USE_PACKEDBUFFER */
 
 /* Index to functions, as function prototypes. */
 
@@ -646,8 +564,6 @@ static void tc_handle_link_change(struct net_device *dev)
 		 * TX4939 PCFG.SPEEDn bit will be changed on
 		 * NETDEV_CHANGE event.
 		 */
-
-#if !defined(NO_CHECK_CARRIER) && defined(WORKAROUND_LOSTCAR)
 		/*
 		 * WORKAROUND: enable LostCrS only if half duplex
 		 * operation.
@@ -657,7 +573,6 @@ static void tc_handle_link_change(struct net_device *dev)
 		    lp->chiptype != TC35815_TX4939)
 			tc_writel(tc_readl(&tr->Tx_Ctl) | Tx_EnLCarr,
 				  &tr->Tx_Ctl);
-#endif
 
 		lp->speed = phydev->speed;
 		lp->duplex = phydev->duplex;
@@ -666,11 +581,9 @@ static void tc_handle_link_change(struct net_device *dev)
 
 	if (phydev->link != lp->link) {
 		if (phydev->link) {
-#ifdef WORKAROUND_100HALF_PROMISC
 			/* delayed promiscuous enabling */
 			if (dev->flags & IFF_PROMISC)
 				tc35815_set_multicast_list(dev);
-#endif
 		} else {
 			lp->speed = 0;
 			lp->duplex = -1;
@@ -997,25 +910,6 @@ tc35815_init_queues(struct net_device *dev)
 		if (!lp->fd_buf)
 			return -ENOMEM;
 		for (i = 0; i < RX_BUF_NUM; i++) {
-#ifdef TC35815_USE_PACKEDBUFFER
-			lp->data_buf[i] =
-				alloc_rxbuf_page(lp->pci_dev,
-						 &lp->data_buf_dma[i]);
-			if (!lp->data_buf[i]) {
-				while (--i >= 0) {
-					free_rxbuf_page(lp->pci_dev,
-							lp->data_buf[i],
-							lp->data_buf_dma[i]);
-					lp->data_buf[i] = NULL;
-				}
-				pci_free_consistent(lp->pci_dev,
-						    PAGE_SIZE * FD_PAGE_NUM,
-						    lp->fd_buf,
-						    lp->fd_buf_dma);
-				lp->fd_buf = NULL;
-				return -ENOMEM;
-			}
-#else
 			lp->rx_skbs[i].skb =
 				alloc_rxbuf_skb(dev, lp->pci_dev,
 						&lp->rx_skbs[i].skb_dma);
@@ -1033,15 +927,9 @@ tc35815_init_queues(struct net_device *dev)
 				lp->fd_buf = NULL;
 				return -ENOMEM;
 			}
-#endif
 		}
 		printk(KERN_DEBUG "%s: FD buf %p DataBuf",
 		       dev->name, lp->fd_buf);
-#ifdef TC35815_USE_PACKEDBUFFER
-		printk(" DataBuf");
-		for (i = 0; i < RX_BUF_NUM; i++)
-			printk(" %p", lp->data_buf[i]);
-#endif
 		printk("\n");
 	} else {
 		for (i = 0; i < FD_PAGE_NUM; i++)
@@ -1074,7 +962,6 @@ tc35815_init_queues(struct net_device *dev)
 	lp->fbl_ptr = (struct FrFD *)fd_addr;
 	lp->fbl_ptr->fd.FDNext = cpu_to_le32(fd_virt_to_bus(lp, lp->fbl_ptr));
 	lp->fbl_ptr->fd.FDCtl = cpu_to_le32(RX_BUF_NUM | FD_CownsFD);
-#ifndef TC35815_USE_PACKEDBUFFER
 	/*
 	 * move all allocated skbs to head of rx_skbs[] array.
 	 * fbl_count mighe not be RX_BUF_NUM if alloc_rxbuf_skb() in
@@ -1092,11 +979,7 @@ tc35815_init_queues(struct net_device *dev)
 			lp->fbl_count++;
 		}
 	}
-#endif
 	for (i = 0; i < RX_BUF_NUM; i++) {
-#ifdef TC35815_USE_PACKEDBUFFER
-		lp->fbl_ptr->bd[i].BuffData = cpu_to_le32(lp->data_buf_dma[i]);
-#else
 		if (i >= lp->fbl_count) {
 			lp->fbl_ptr->bd[i].BuffData = 0;
 			lp->fbl_ptr->bd[i].BDCtl = 0;
@@ -1104,15 +987,11 @@ tc35815_init_queues(struct net_device *dev)
 		}
 		lp->fbl_ptr->bd[i].BuffData =
 			cpu_to_le32(lp->rx_skbs[i].skb_dma);
-#endif
 		/* BDID is index of FrFD.bd[] */
 		lp->fbl_ptr->bd[i].BDCtl =
 			cpu_to_le32(BD_CownsBD | (i << BD_RxBDID_SHIFT) |
 				    RX_BUF_SIZE);
 	}
-#ifdef TC35815_USE_PACKEDBUFFER
-	lp->fbl_curid = 0;
-#endif
 
 	printk(KERN_DEBUG "%s: TxFD %p RxFD %p FrFD %p\n",
 	       dev->name, lp->tfd_base, lp->rfd_base, lp->fbl_ptr);
@@ -1186,19 +1065,11 @@ tc35815_free_queues(struct net_device *dev)
 	lp->fbl_ptr = NULL;
 
 	for (i = 0; i < RX_BUF_NUM; i++) {
-#ifdef TC35815_USE_PACKEDBUFFER
-		if (lp->data_buf[i]) {
-			free_rxbuf_page(lp->pci_dev,
-					lp->data_buf[i], lp->data_buf_dma[i]);
-			lp->data_buf[i] = NULL;
-		}
-#else
 		if (lp->rx_skbs[i].skb) {
 			free_rxbuf_skb(lp->pci_dev, lp->rx_skbs[i].skb,
 				       lp->rx_skbs[i].skb_dma);
 			lp->rx_skbs[i].skb = NULL;
 		}
-#endif
 	}
 	if (lp->fd_buf) {
 		pci_free_consistent(lp->pci_dev, PAGE_SIZE * FD_PAGE_NUM,
@@ -1244,7 +1115,7 @@ dump_rxfd(struct RxFD *fd)
 	return bd_count;
 }
 
-#if defined(DEBUG) || defined(TC35815_USE_PACKEDBUFFER)
+#ifdef DEBUG
 static void
 dump_frfd(struct FrFD *fd)
 {
@@ -1261,9 +1132,7 @@ dump_frfd(struct FrFD *fd)
 		       le32_to_cpu(fd->bd[i].BDCtl));
 	printk("\n");
 }
-#endif
 
-#ifdef DEBUG
 static void
 panic_queues(struct net_device *dev)
 {
@@ -1466,9 +1335,7 @@ static int tc35815_send_packet(struct sk_buff *skb, struct net_device *dev)
 			(struct tc35815_regs __iomem *)dev->base_addr;
 		/* Start DMA Transmitter. */
 		txfd->fd.FDNext |= cpu_to_le32(FD_Next_EOL);
-#ifdef GATHER_TXINT
 		txfd->fd.FDCtl |= cpu_to_le32(FD_FrmOpt_IntTx);
-#endif
 		if (netif_msg_tx_queued(lp)) {
 			printk("%s: starting TxFD.\n", dev->name);
 			dump_txfd(txfd);
@@ -1640,50 +1507,9 @@ tc35815_rx(struct net_device *dev, int limit)
 			struct sk_buff *skb;
 			unsigned char *data;
 			int cur_bd;
-#ifdef TC35815_USE_PACKEDBUFFER
-			int offset;
-#endif
 
 			if (--limit < 0)
 				break;
-#ifdef TC35815_USE_PACKEDBUFFER
-			BUG_ON(bd_count > 2);
-			skb = dev_alloc_skb(pkt_len + NET_IP_ALIGN);
-			if (skb == NULL) {
-				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
-				       dev->name);
-				dev->stats.rx_dropped++;
-				break;
-			}
-			skb_reserve(skb, NET_IP_ALIGN);
-
-			data = skb_put(skb, pkt_len);
-
-			/* copy from receive buffer */
-			cur_bd = 0;
-			offset = 0;
-			while (offset < pkt_len && cur_bd < bd_count) {
-				int len = le32_to_cpu(lp->rfd_cur->bd[cur_bd].BDCtl) &
-					BD_BuffLength_MASK;
-				dma_addr_t dma = le32_to_cpu(lp->rfd_cur->bd[cur_bd].BuffData);
-				void *rxbuf = rxbuf_bus_to_virt(lp, dma);
-				if (offset + len > pkt_len)
-					len = pkt_len - offset;
-#ifdef TC35815_DMA_SYNC_ONDEMAND
-				pci_dma_sync_single_for_cpu(lp->pci_dev,
-							    dma, len,
-							    PCI_DMA_FROMDEVICE);
-#endif
-				memcpy(data + offset, rxbuf, len);
-#ifdef TC35815_DMA_SYNC_ONDEMAND
-				pci_dma_sync_single_for_device(lp->pci_dev,
-							       dma, len,
-							       PCI_DMA_FROMDEVICE);
-#endif
-				offset += len;
-				cur_bd++;
-			}
-#else /* TC35815_USE_PACKEDBUFFER */
 			BUG_ON(bd_count > 1);
 			cur_bd = (le32_to_cpu(lp->rfd_cur->bd[0].BDCtl)
 				  & BD_RxBDID_MASK) >> BD_RxBDID_SHIFT;
@@ -1711,7 +1537,6 @@ tc35815_rx(struct net_device *dev, int limit)
 				memmove(skb->data, skb->data - NET_IP_ALIGN,
 					pkt_len);
 			data = skb_put(skb, pkt_len);
-#endif /* TC35815_USE_PACKEDBUFFER */
 			if (netif_msg_pktdata(lp))
 				print_eth(data);
 			skb->protocol = eth_type_trans(skb, dev);
@@ -1753,19 +1578,11 @@ tc35815_rx(struct net_device *dev, int limit)
 			BUG_ON(id >= RX_BUF_NUM);
 #endif
 			/* free old buffers */
-#ifdef TC35815_USE_PACKEDBUFFER
-			while (lp->fbl_curid != id)
-#else
 			lp->fbl_count--;
 			while (lp->fbl_count < RX_BUF_NUM)
-#endif
 			{
-#ifdef TC35815_USE_PACKEDBUFFER
-				unsigned char curid = lp->fbl_curid;
-#else
 				unsigned char curid =
 					(id + 1 + lp->fbl_count) % RX_BUF_NUM;
-#endif
 				struct BDesc *bd = &lp->fbl_ptr->bd[curid];
 #ifdef DEBUG
 				bdctl = le32_to_cpu(bd->BDCtl);
@@ -1776,7 +1593,6 @@ tc35815_rx(struct net_device *dev, int limit)
 				}
 #endif
 				/* pass BD to controller */
-#ifndef TC35815_USE_PACKEDBUFFER
 				if (!lp->rx_skbs[curid].skb) {
 					lp->rx_skbs[curid].skb =
 						alloc_rxbuf_skb(dev,
@@ -1786,21 +1602,11 @@ tc35815_rx(struct net_device *dev, int limit)
 						break; /* try on next reception */
 					bd->BuffData = cpu_to_le32(lp->rx_skbs[curid].skb_dma);
 				}
-#endif /* TC35815_USE_PACKEDBUFFER */
 				/* Note: BDLength was modified by chip. */
 				bd->BDCtl = cpu_to_le32(BD_CownsBD |
 							(curid << BD_RxBDID_SHIFT) |
 							RX_BUF_SIZE);
-#ifdef TC35815_USE_PACKEDBUFFER
-				lp->fbl_curid = (curid + 1) % RX_BUF_NUM;
-				if (netif_msg_rx_status(lp)) {
-					printk("%s: Entering new FBD %d\n",
-					       dev->name, lp->fbl_curid);
-					dump_frfd(lp->fbl_ptr);
-				}
-#else
 				lp->fbl_count++;
-#endif
 			}
 		}
 
@@ -1872,11 +1678,7 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 	return received;
 }
 
-#ifdef NO_CHECK_CARRIER
-#define TX_STA_ERR	(Tx_ExColl|Tx_Under|Tx_Defer|Tx_LateColl|Tx_TxPar|Tx_SQErr)
-#else
 #define TX_STA_ERR	(Tx_ExColl|Tx_Under|Tx_Defer|Tx_NCarr|Tx_LateColl|Tx_TxPar|Tx_SQErr)
-#endif
 
 static void
 tc35815_check_tx_stat(struct net_device *dev, int status)
@@ -1890,16 +1692,12 @@ tc35815_check_tx_stat(struct net_device *dev, int status)
 	if (status & Tx_TxColl_MASK)
 		dev->stats.collisions += status & Tx_TxColl_MASK;
 
-#ifndef NO_CHECK_CARRIER
 	/* TX4939 does not have NCarr */
 	if (lp->chiptype == TC35815_TX4939)
 		status &= ~Tx_NCarr;
-#ifdef WORKAROUND_LOSTCAR
 	/* WORKAROUND: ignore LostCrS in full duplex operation */
 	if (!lp->link || lp->duplex == DUPLEX_FULL)
 		status &= ~Tx_NCarr;
-#endif
-#endif
 
 	if (!(status & TX_STA_ERR)) {
 		/* no error. */
@@ -1929,12 +1727,10 @@ tc35815_check_tx_stat(struct net_device *dev, int status)
 		dev->stats.tx_fifo_errors++;
 		msg = "Excessive Deferral.";
 	}
-#ifndef NO_CHECK_CARRIER
 	if (status & Tx_NCarr) {
 		dev->stats.tx_carrier_errors++;
 		msg = "Lost Carrier Sense.";
 	}
-#endif
 	if (status & Tx_LateColl) {
 		dev->stats.tx_aborted_errors++;
 		msg = "Late Collision.";
@@ -2025,9 +1821,7 @@ tc35815_txdone(struct net_device *dev)
 
 				/* start DMA Transmitter again */
 				txhead->fd.FDNext |= cpu_to_le32(FD_Next_EOL);
-#ifdef GATHER_TXINT
 				txhead->fd.FDCtl |= cpu_to_le32(FD_FrmOpt_IntTx);
-#endif
 				if (netif_msg_tx_queued(lp)) {
 					printk("%s: start TxFD on queue.\n",
 					       dev->name);
@@ -2138,14 +1932,12 @@ tc35815_set_multicast_list(struct net_device *dev)
 		(struct tc35815_regs __iomem *)dev->base_addr;
 
 	if (dev->flags & IFF_PROMISC) {
-#ifdef WORKAROUND_100HALF_PROMISC
 		/* With some (all?) 100MHalf HUB, controller will hang
 		 * if we enabled promiscuous mode before linkup... */
 		struct tc35815_local *lp = netdev_priv(dev);
 
 		if (!lp->link)
 			return;
-#endif
 		/* Enable promiscuous mode */
 		tc_writel(CAM_CompEn | CAM_BroadAcc | CAM_GroupAcc | CAM_StationAcc, &tr->CAM_Ctl);
 	} else if ((dev->flags & IFF_ALLMULTI) ||
@@ -2332,9 +2124,6 @@ static void tc35815_chip_init(struct net_device *dev)
 		tc_writel(DMA_BURST_SIZE | DMA_RxAlign_2, &tr->DMA_Ctl);
 	else
 		tc_writel(DMA_BURST_SIZE, &tr->DMA_Ctl);
-#ifdef TC35815_USE_PACKEDBUFFER
-	tc_writel(RxFrag_EnPack | ETH_ZLEN, &tr->RxFragSize);	/* Packing */
-#endif
 	tc_writel(0, &tr->TxPollCtr);	/* Batch mode */
 	tc_writel(TX_THRESHOLD, &tr->TxThrsh);
 	tc_writel(INT_EN_CMD, &tr->Int_En);
@@ -2352,19 +2141,12 @@ static void tc35815_chip_init(struct net_device *dev)
 	tc_writel(RX_CTL_CMD, &tr->Rx_Ctl);	/* start MAC receiver */
 
 	/* start MAC transmitter */
-#ifndef NO_CHECK_CARRIER
 	/* TX4939 does not have EnLCarr */
 	if (lp->chiptype == TC35815_TX4939)
 		txctl &= ~Tx_EnLCarr;
-#ifdef WORKAROUND_LOSTCAR
 	/* WORKAROUND: ignore LostCrS in full duplex operation */
 	if (!lp->phy_dev || !lp->link || lp->duplex == DUPLEX_FULL)
 		txctl &= ~Tx_EnLCarr;
-#endif
-#endif /* !NO_CHECK_CARRIER */
-#ifdef GATHER_TXINT
-	txctl &= ~Tx_EnComp;	/* disable global tx completion int. */
-#endif
 	tc_writel(txctl, &tr->Tx_Ctl);
 }
 
-- 
1.5.6.5

