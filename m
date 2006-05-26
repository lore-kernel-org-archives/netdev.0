From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] new qla3xxx NIC Driver v2.02.00k29 (repost)
Date: Fri, 26 May 2006 15:33:51 -0700
Message-ID: <20060526153351.390dec72@localhost.localdomain>
References: <0BB3E5E7462EEA4295BC02D49691DC070D372D@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16024 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751623AbWEZWeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 18:34:01 -0400
To: "Ron Mercer" <ron.mercer@qlogic.com>
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC070D372D@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes:
1. Remove code has to unregister net device before doing any hardware
   tear down.  This ensures that packets won't get queued etc..

2. Need to unmap PCI request before reference in eth_type_trans

3. call free_netdev not kfree to free net_device
   see Documentation/networking/netdevices.txt

Improvements:

4. indentation. Lots of funny line breaks in your source.

5. use const if you can 

6. ethtool get_link reports carrier state

7. don't need to do multicast list comparisons?
   kernel already have to deal with multicast hash collision from drivers, 
   so if your hardware can't do it. walking the list of addresses seems like 
   unnecessary work.
   (if you want to keep this code, consider using compare_ether_addr)

7. prefetching the data before passing up is almost always a cache win
   since the first thing that happens is looking at the data.

My changes might have broken stuff, not tested (no hardware).

Next time please post in standard kernel patch format.
(ie Documentation/SubmittingPatches)

I.e as part of a kernel build tree:
	drivers/net/ql3_xxx.c
	drivers/net/ql3_def.h
and delta's for drivers/net/Kconfig and drivers/net/Makefile

--- ql3_xxx.c.orig	2006-05-24 15:41:42.000000000 -0700
+++ ql3_xxx.c	2006-05-26 15:32:39.000000000 -0700
@@ -9,10 +9,10 @@
 #define DRV_NAME  	"qla3xxx"
 #define DRV_STRING 	"QLogic ISP3XXX Network Driver"
 #define DRV_VERSION	"v2.02.00-k29"
-#define PFX			DRV_NAME " "
+#define PFX		DRV_NAME " "
 
-static char ql3xxx_driver_name[] = DRV_NAME;
-static char ql3xxx_driver_version[] = DRV_VERSION;
+static const char ql3xxx_driver_name[] = DRV_NAME;
+static const char ql3xxx_driver_version[] = DRV_VERSION;
 
 MODULE_AUTHOR("QLogic Corporation");
 MODULE_DESCRIPTION("QLogic ISP3XXX Network Driver " DRV_VERSION " ");
@@ -485,7 +485,7 @@ static int ql_get_nvram_params(struct ql
 	return checksum;
 }
 
-static u32 PHYAddr[2] = {
+static const u32 PHYAddr[2] = {
 	PORT0_PHY_ADDRESS, PORT1_PHY_ADDRESS
 };
 
@@ -1504,9 +1504,12 @@ static void ql_set_msglevel(struct net_d
 }
 
 static struct ethtool_ops ql3xxx_ethtool_ops = {
-	.get_settings = ql_get_settings,.get_drvinfo = ql_get_drvinfo,
+	.get_settings = ql_get_settings,
+	.get_drvinfo = ql_get_drvinfo,
 	.get_perm_addr = ethtool_op_get_perm_addr,
-	.get_msglevel = ql_get_msglevel,.set_msglevel = ql_set_msglevel,
+	.get_link = ethtool_op_get_link,
+	.get_msglevel = ql_get_msglevel,
+	.set_msglevel = ql_set_msglevel,
 };
 
 static struct ql_tx_buf_cb *ql_alloc_txbuf(struct ql3_adapter *qdev)
@@ -1760,9 +1763,6 @@ static void ql_process_mac_rx_intr(struc
 	u32 *curr_ial_ptr;
 	struct sk_buff *skb;
 	struct net_device *ndev = qdev->ndev;
-	int send_packet = 1;
-	struct dev_mc_list *mc_list = ndev->mc_list;
-	struct ethhdr *eth_hdr;
 	u16 length = le16_to_cpu(ib_mac_rsp_ptr->length);
 
 	/*
@@ -1799,59 +1799,27 @@ static void ql_process_mac_rx_intr(struc
 		qdev->lrg_buf_index = 0;
 	}
 	skb = lrg_buf_cb2->skb;
-	eth_hdr = (struct ethhdr *)skb->data;
-
-	if (ib_mac_rsp_ptr->flags & IB_MAC_IOCB_RSP_B) {
-		if (!(ndev->flags & (IFF_BROADCAST | IFF_PROMISC))) {
-			send_packet = 0;
-		}
-	} else if (ib_mac_rsp_ptr->flags & IB_MAC_IOCB_RSP_M) {
-		/* We received a multicast packet. Scan the list of multicast addresses 
-		 * and see if there is a match otherwise discard packet */
-		send_packet = 0;
-		if (ndev->flags & (IFF_ALLMULTI | IFF_PROMISC)) {
-			send_packet = 1;
-		} else if ((ndev->flags & IFF_MULTICAST)) {
-			while (mc_list) {
-				if ((mc_list->dmi_addr[0] == eth_hdr->h_dest[0])
-				    && (mc_list->dmi_addr[1] ==
-					eth_hdr->h_dest[1])
-				    && (mc_list->dmi_addr[2] ==
-					eth_hdr->h_dest[2])
-				    && (mc_list->dmi_addr[3] ==
-					eth_hdr->h_dest[3])
-				    && (mc_list->dmi_addr[4] ==
-					eth_hdr->h_dest[4])
-				    && (mc_list->dmi_addr[5] ==
-					eth_hdr->h_dest[5])) {
-					send_packet = 1;
-					break;
-				}
-				mc_list = mc_list->next;
-			}
-		}
-	}
 
 	qdev->stats.rx_packets++;
 	qdev->stats.rx_bytes += length;
 
-	if (send_packet) {
-		skb_put(skb, length);
-		skb->dev = qdev->ndev;
-		skb->ip_summed = CHECKSUM_NONE;
-		skb->protocol = eth_type_trans(skb, qdev->ndev);
-		pci_unmap_single(qdev->pdev,
-				 pci_unmap_addr(lrg_buf_cb2, mapaddr),
-				 pci_unmap_len(lrg_buf_cb2, maplen),
-				 PCI_DMA_FROMDEVICE);
+	skb_put(skb, length);
+	pci_unmap_single(qdev->pdev,
+			 pci_unmap_addr(lrg_buf_cb2, mapaddr),
+			 pci_unmap_len(lrg_buf_cb2, maplen),
+			 PCI_DMA_FROMDEVICE);
+	prefetch(skb->data);
+	skb->dev = qdev->ndev;
+	skb->ip_summed = CHECKSUM_NONE;
+	skb->protocol = eth_type_trans(skb, qdev->ndev);
+
 #ifdef CONFIG_QL3XXX_NAPI
-		netif_receive_skb(skb);
+	netif_receive_skb(skb);
 #else
-		netif_rx(skb);
+	netif_rx(skb);
 #endif
-		qdev->ndev->last_rx = jiffies;
-		lrg_buf_cb2->skb = NULL;
-	}
+	qdev->ndev->last_rx = jiffies;
+	lrg_buf_cb2->skb = NULL;
 
 	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
 	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb2);
@@ -1867,9 +1835,6 @@ static void ql_process_macip_rx_intr(str
 	u32 *curr_ial_ptr;
 	struct sk_buff *skb1, *skb2;
 	struct net_device *ndev = qdev->ndev;
-	struct dev_mc_list *mc_list = ndev->mc_list;
-	int send_packet = 1;
-	struct ethhdr *eth_hdr;
 	u16 length = le16_to_cpu(ib_ip_rsp_ptr->length);
 	u16 size = 0;
 
@@ -1906,70 +1871,38 @@ static void ql_process_macip_rx_intr(str
 		qdev->lrg_buf_index = 0;
 	}
 
-	if (ib_ip_rsp_ptr->flags & IB_IP_IOCB_RSP_B) {
-		if (!(ndev->flags & (IFF_BROADCAST | IFF_PROMISC))) {
-			send_packet = 0;
-		}
-	} else if (ib_ip_rsp_ptr->flags & IB_IP_IOCB_RSP_M) {
-		/* 
-		 * We received a multicast packet. Scan the list of multicast addresses 
-		 * and see if there is a match otherwise discard packet 
-		 */
-		send_packet = 0;
-		if (ndev->flags & (IFF_ALLMULTI | IFF_PROMISC)) {
-			send_packet = 1;
-		} else if ((ndev->flags & IFF_MULTICAST)) {
-			eth_hdr = (struct ethhdr *)skb1->data + VLAN_ID_LEN;
-			while (mc_list) {
-				if ((mc_list->dmi_addr[0] == eth_hdr->h_dest[0])
-				    && (mc_list->dmi_addr[1] ==
-					eth_hdr->h_dest[1])
-				    && (mc_list->dmi_addr[2] ==
-					eth_hdr->h_dest[2])
-				    && (mc_list->dmi_addr[3] ==
-					eth_hdr->h_dest[3])
-				    && (mc_list->dmi_addr[4] ==
-					eth_hdr->h_dest[4])
-				    && (mc_list->dmi_addr[5] ==
-					eth_hdr->h_dest[5])) {
-					send_packet = 1;
-					break;
-				}
-				mc_list = mc_list->next;
-			}
-		}
-	}
-
 	qdev->stats.rx_packets++;
 	qdev->stats.rx_bytes += length;
 
-	if (send_packet) {
-		/*
-		 * Copy the ethhdr from first buffer to second. This
-		 * is necessary for IP completions.
-		 */
-		if (*((u16 *) skb1->data) != 0xFFFF) {
-			size = VLAN_ETH_HLEN;
-		} else {
-			size = ETH_HLEN;
-		}
-		skb_put(skb2, length);	/* Just the second buffer length here. */
-		memcpy(skb_push(skb2, size), skb1->data + VLAN_ID_LEN, size);
-		skb2->dev = qdev->ndev;
-		skb2->ip_summed = CHECKSUM_NONE;
-		skb2->protocol = eth_type_trans(skb2, qdev->ndev);
-		pci_unmap_single(qdev->pdev,
-				 pci_unmap_addr(lrg_buf_cb2, mapaddr),
-				 pci_unmap_len(lrg_buf_cb2, maplen),
-				 PCI_DMA_FROMDEVICE);
+	/*
+	 * Copy the ethhdr from first buffer to second. This
+	 * is necessary for IP completions.
+	 */
+	if (*((u16 *) skb1->data) != 0xFFFF) {
+		size = VLAN_ETH_HLEN;
+	} else {
+		size = ETH_HLEN;
+	}
+
+	skb_put(skb2, length);	/* Just the second buffer length here. */
+	pci_unmap_single(qdev->pdev,
+			 pci_unmap_addr(lrg_buf_cb2, mapaddr),
+			 pci_unmap_len(lrg_buf_cb2, maplen),
+			 PCI_DMA_FROMDEVICE);
+	prefetch(skb2->data);
+
+	memcpy(skb_push(skb2, size), skb1->data + VLAN_ID_LEN, size);
+	skb2->dev = qdev->ndev;
+	skb2->ip_summed = CHECKSUM_NONE;
+	skb2->protocol = eth_type_trans(skb2, qdev->ndev);
+
 #ifdef CONFIG_QL3XXX_NAPI
-		netif_receive_skb(skb2);
+	netif_receive_skb(skb2);
 #else
-		netif_rx(skb2);
+	netif_rx(skb2);
 #endif
-		ndev->last_rx = jiffies;
-		lrg_buf_cb2->skb = NULL;
-	}
+	ndev->last_rx = jiffies;
+	lrg_buf_cb2->skb = NULL;
 
 	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb1);
 	ql_release_to_lrg_buf_free_list(qdev, lrg_buf_cb2);
@@ -2876,20 +2809,17 @@ static int ql_adapter_initialize(struct 
 	ql_write_page0_reg(qdev, &port_regs->macAddrIndirectPtrReg,
 			   (MAC_ADDR_INDIRECT_PTR_REG_RP_MASK << 16));
 	ql_write_page0_reg(qdev, &port_regs->macAddrDataReg,
-			   ((qdev->ndev->dev_addr[2] << 24) | (qdev->ndev->
-							       dev_addr[3] <<
-							       16) | (qdev->
-								      ndev->
-								      dev_addr
-								      [4] << 8)
+			   ((qdev->ndev->dev_addr[2] << 24) 
+			    | (qdev->ndev->dev_addr[3] << 16)
+			    | (qdev->ndev->dev_addr[4] << 8)
 			    | qdev->ndev->dev_addr[5]));
 
 	/* Program top 16 bits of the MAC address */
 	ql_write_page0_reg(qdev, &port_regs->macAddrIndirectPtrReg,
 			   ((MAC_ADDR_INDIRECT_PTR_REG_RP_MASK << 16) | 1));
 	ql_write_page0_reg(qdev, &port_regs->macAddrDataReg,
-			   ((qdev->ndev->dev_addr[0] << 8) | qdev->ndev->
-			    dev_addr[1]));
+			   ((qdev->ndev->dev_addr[0] << 8)
+			    | qdev->ndev->dev_addr[1]));
 
 	/* Enable Primary MAC */
 	ql_write_page0_reg(qdev, &port_regs->macAddrIndirectPtrReg,
@@ -3247,6 +3177,7 @@ static int ql3xxx_close(struct net_devic
 {
 	struct ql3_adapter *qdev = netdev_priv(ndev);
 	int status;
+
 	while (!(qdev->flags & QL_ADAPTER_UP)) {
 		msleep(50);
 	}
@@ -3415,10 +3346,9 @@ static void ql_reset_work(struct ql3_ada
 		 */
 		max_wait_time = 10;
 		do {
-			value =
-			    ql_read_common_reg(qdev,
-					       &port_regs->CommonRegs.
-					       ispControlStatus);
+			value = ql_read_common_reg(qdev,
+						   &port_regs->CommonRegs.
+						   ispControlStatus);
 			if ((value & ISP_CONTROL_SR) == 0) {
 				printk(KERN_DEBUG PFX
 				       "%s: %s: reset completed.\n",
@@ -3666,7 +3596,6 @@ static int __devinit ql3xxx_probe(struct
 
 	/* Turn off support for multicasting */
 	ndev->flags &= ~IFF_MULTICAST;
-	ndev->flags |= IFF_NOTRAILERS;
 
 	/* Record PCI bus information. */
 	ql_get_board_info(qdev);
@@ -3718,7 +3647,7 @@ static int __devinit ql3xxx_probe(struct
 	return err;
 }
 
-static void ql3xxx_remove(struct pci_dev *pdev)
+static void __devexit ql3xxx_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct ql3_adapter *qdev;
@@ -3729,6 +3658,7 @@ static void ql3xxx_remove(struct pci_dev
 		return;
 	}
 
+	unregister_netdev(ndev);
 	qdev = netdev_priv(ndev);
 	if (qdev == NULL) {
 		printk(KERN_ERR PFX "%s: %s: qdev == NULL, leaving.\n",
@@ -3742,8 +3672,7 @@ static void ql3xxx_remove(struct pci_dev
 	/*
 	 * Wait for any resets to complete...
 	 */
-	while (qdev->
-	       flags & (QL_RESET_ACTIVE | QL_RESET_START | QL_RESET_PER_SCSI)) {
+	while (qdev->flags & (QL_RESET_ACTIVE | QL_RESET_START | QL_RESET_PER_SCSI)) {
 		msleep(1000);
 	}
 
@@ -3755,12 +3684,13 @@ static void ql3xxx_remove(struct pci_dev
 		qdev->workqueue = NULL;
 	}
 
-	unregister_netdev(ndev);
 	iounmap((void *)qdev->mmap_virt_base);
 	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
-	kfree(ndev);
-} static struct pci_driver ql3xxx_driver = {
+	free_netdev(ndev);
+}
+
+static struct pci_driver ql3xxx_driver = {
 
 	.name = DRV_NAME,
 	.id_table = ql3xxx_pci_tbl,
