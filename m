From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] be2net: use device model DMA API
Date: Wed,  2 Feb 2011 19:05:12 +0100
Message-ID: <1296669912-26563-1-git-send-email-ivecera@redhat.com>
Cc: sathyap@serverengines.com, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417Ab1BBSGb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 13:06:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use DMA API as PCI equivalents will be deprecated.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/benet/be_ethtool.c |   25 +++++-----
 drivers/net/benet/be_main.c    |   98 +++++++++++++++++++++-------------------
 2 files changed, 64 insertions(+), 59 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index b4be027..0c99314 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -376,8 +376,9 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		}
 
 		phy_cmd.size = sizeof(struct be_cmd_req_get_phy_info);
-		phy_cmd.va = pci_alloc_consistent(adapter->pdev, phy_cmd.size,
-					&phy_cmd.dma);
+		phy_cmd.va = dma_alloc_coherent(&adapter->pdev->dev,
+						phy_cmd.size, &phy_cmd.dma,
+						GFP_KERNEL);
 		if (!phy_cmd.va) {
 			dev_err(&adapter->pdev->dev, "Memory alloc failure\n");
 			return -ENOMEM;
@@ -416,8 +417,8 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		adapter->port_type = ecmd->port;
 		adapter->transceiver = ecmd->transceiver;
 		adapter->autoneg = ecmd->autoneg;
-		pci_free_consistent(adapter->pdev, phy_cmd.size,
-					phy_cmd.va, phy_cmd.dma);
+		dma_free_coherent(&adapter->pdev->dev, phy_cmd.size, phy_cmd.va,
+				  phy_cmd.dma);
 	} else {
 		ecmd->speed = adapter->link_speed;
 		ecmd->port = adapter->port_type;
@@ -554,8 +555,8 @@ be_test_ddr_dma(struct be_adapter *adapter)
 	};
 
 	ddrdma_cmd.size = sizeof(struct be_cmd_req_ddrdma_test);
-	ddrdma_cmd.va = pci_alloc_consistent(adapter->pdev, ddrdma_cmd.size,
-					&ddrdma_cmd.dma);
+	ddrdma_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, ddrdma_cmd.size,
+					   &ddrdma_cmd.dma, GFP_KERNEL);
 	if (!ddrdma_cmd.va) {
 		dev_err(&adapter->pdev->dev, "Memory allocation failure\n");
 		return -ENOMEM;
@@ -569,8 +570,8 @@ be_test_ddr_dma(struct be_adapter *adapter)
 	}
 
 err:
-	pci_free_consistent(adapter->pdev, ddrdma_cmd.size,
-			ddrdma_cmd.va, ddrdma_cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, ddrdma_cmd.size, ddrdma_cmd.va,
+			  ddrdma_cmd.dma);
 	return ret;
 }
 
@@ -662,8 +663,8 @@ be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 
 	memset(&eeprom_cmd, 0, sizeof(struct be_dma_mem));
 	eeprom_cmd.size = sizeof(struct be_cmd_req_seeprom_read);
-	eeprom_cmd.va = pci_alloc_consistent(adapter->pdev, eeprom_cmd.size,
-				&eeprom_cmd.dma);
+	eeprom_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, eeprom_cmd.size,
+					   &eeprom_cmd.dma, GFP_KERNEL);
 
 	if (!eeprom_cmd.va) {
 		dev_err(&adapter->pdev->dev,
@@ -677,8 +678,8 @@ be_read_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 		resp = (struct be_cmd_resp_seeprom_read *) eeprom_cmd.va;
 		memcpy(data, resp->seeprom_data + eeprom->offset, eeprom->len);
 	}
-	pci_free_consistent(adapter->pdev, eeprom_cmd.size, eeprom_cmd.va,
-			eeprom_cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, eeprom_cmd.size, eeprom_cmd.va,
+			  eeprom_cmd.dma);
 
 	return status;
 }
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 28a32a6..82b2df8 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -125,8 +125,8 @@ static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
 	struct be_dma_mem *mem = &q->dma_mem;
 	if (mem->va)
-		pci_free_consistent(adapter->pdev, mem->size,
-			mem->va, mem->dma);
+		dma_free_coherent(&adapter->pdev->dev, mem->size, mem->va,
+				  mem->dma);
 }
 
 static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
@@ -138,7 +138,8 @@ static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
 	q->len = len;
 	q->entry_size = entry_size;
 	mem->size = len * entry_size;
-	mem->va = pci_alloc_consistent(adapter->pdev, mem->size, &mem->dma);
+	mem->va = dma_alloc_coherent(&adapter->pdev->dev, mem->size, &mem->dma,
+				     GFP_KERNEL);
 	if (!mem->va)
 		return -1;
 	memset(mem->va, 0, mem->size);
@@ -484,7 +485,7 @@ static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 	AMAP_SET_BITS(struct amap_eth_hdr_wrb, len, hdr, len);
 }
 
-static void unmap_tx_frag(struct pci_dev *pdev, struct be_eth_wrb *wrb,
+static void unmap_tx_frag(struct device *dev, struct be_eth_wrb *wrb,
 		bool unmap_single)
 {
 	dma_addr_t dma;
@@ -494,11 +495,10 @@ static void unmap_tx_frag(struct pci_dev *pdev, struct be_eth_wrb *wrb,
 	dma = (u64)wrb->frag_pa_hi << 32 | (u64)wrb->frag_pa_lo;
 	if (wrb->frag_len) {
 		if (unmap_single)
-			pci_unmap_single(pdev, dma, wrb->frag_len,
-				PCI_DMA_TODEVICE);
+			dma_unmap_single(dev, dma, wrb->frag_len,
+					 DMA_TO_DEVICE);
 		else
-			pci_unmap_page(pdev, dma, wrb->frag_len,
-				PCI_DMA_TODEVICE);
+			dma_unmap_page(dev, dma, wrb->frag_len, DMA_TO_DEVICE);
 	}
 }
 
@@ -507,7 +507,7 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 {
 	dma_addr_t busaddr;
 	int i, copied = 0;
-	struct pci_dev *pdev = adapter->pdev;
+	struct device *dev = &adapter->pdev->dev;
 	struct sk_buff *first_skb = skb;
 	struct be_queue_info *txq = &adapter->tx_obj.q;
 	struct be_eth_wrb *wrb;
@@ -521,9 +521,8 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 
 	if (skb->len > skb->data_len) {
 		int len = skb_headlen(skb);
-		busaddr = pci_map_single(pdev, skb->data, len,
-					 PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(pdev, busaddr))
+		busaddr = dma_map_single(dev, skb->data, len, DMA_TO_DEVICE);
+		if (dma_mapping_error(dev, busaddr))
 			goto dma_err;
 		map_single = true;
 		wrb = queue_head_node(txq);
@@ -536,10 +535,9 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		struct skb_frag_struct *frag =
 			&skb_shinfo(skb)->frags[i];
-		busaddr = pci_map_page(pdev, frag->page,
-				       frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(pdev, busaddr))
+		busaddr = dma_map_page(dev, frag->page, frag->page_offset,
+				       frag->size, DMA_TO_DEVICE);
+		if (dma_mapping_error(dev, busaddr))
 			goto dma_err;
 		wrb = queue_head_node(txq);
 		wrb_fill(wrb, busaddr, frag->size);
@@ -563,7 +561,7 @@ dma_err:
 	txq->head = map_head;
 	while (copied) {
 		wrb = queue_head_node(txq);
-		unmap_tx_frag(pdev, wrb, map_single);
+		unmap_tx_frag(dev, wrb, map_single);
 		map_single = false;
 		copied -= wrb->frag_len;
 		queue_head_inc(txq);
@@ -888,8 +886,9 @@ get_rx_page_info(struct be_adapter *adapter,
 	BUG_ON(!rx_page_info->page);
 
 	if (rx_page_info->last_page_user) {
-		pci_unmap_page(adapter->pdev, dma_unmap_addr(rx_page_info, bus),
-			adapter->big_page_size, PCI_DMA_FROMDEVICE);
+		dma_unmap_page(&adapter->pdev->dev,
+			       dma_unmap_addr(rx_page_info, bus),
+			       adapter->big_page_size, DMA_FROM_DEVICE);
 		rx_page_info->last_page_user = false;
 	}
 
@@ -1195,9 +1194,9 @@ static void be_post_rx_frags(struct be_rx_obj *rxo)
 				rxo->stats.rx_post_fail++;
 				break;
 			}
-			page_dmaaddr = pci_map_page(adapter->pdev, pagep, 0,
-						adapter->big_page_size,
-						PCI_DMA_FROMDEVICE);
+			page_dmaaddr = dma_map_page(&adapter->pdev->dev, pagep,
+						    0, adapter->big_page_size,
+						    DMA_FROM_DEVICE);
 			page_info->page_offset = 0;
 		} else {
 			get_page(pagep);
@@ -1270,8 +1269,8 @@ static void be_tx_compl_process(struct be_adapter *adapter, u16 last_index)
 	do {
 		cur_index = txq->tail;
 		wrb = queue_tail_node(txq);
-		unmap_tx_frag(adapter->pdev, wrb, (unmap_skb_hdr &&
-					skb_headlen(sent_skb)));
+		unmap_tx_frag(&adapter->pdev->dev, wrb,
+			      (unmap_skb_hdr && skb_headlen(sent_skb)));
 		unmap_skb_hdr = false;
 
 		num_wrbs++;
@@ -2179,7 +2178,8 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 	memset(mac, 0, ETH_ALEN);
 
 	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
-	cmd.va = pci_alloc_consistent(adapter->pdev, cmd.size, &cmd.dma);
+	cmd.va = dma_alloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
+				    GFP_KERNEL);
 	if (cmd.va == NULL)
 		return -1;
 	memset(cmd.va, 0, cmd.size);
@@ -2190,8 +2190,8 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 		if (status) {
 			dev_err(&adapter->pdev->dev,
 				"Could not enable Wake-on-lan\n");
-			pci_free_consistent(adapter->pdev, cmd.size, cmd.va,
-					cmd.dma);
+			dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va,
+					  cmd.dma);
 			return status;
 		}
 		status = be_cmd_enable_magic_wol(adapter,
@@ -2204,7 +2204,7 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 		pci_enable_wake(adapter->pdev, PCI_D3cold, 0);
 	}
 
-	pci_free_consistent(adapter->pdev, cmd.size, cmd.va, cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va, cmd.dma);
 	return status;
 }
 
@@ -2528,8 +2528,8 @@ int be_load_fw(struct be_adapter *adapter, u8 *func)
 	dev_info(&adapter->pdev->dev, "Flashing firmware file %s\n", fw_file);
 
 	flash_cmd.size = sizeof(struct be_cmd_write_flashrom) + 32*1024;
-	flash_cmd.va = pci_alloc_consistent(adapter->pdev, flash_cmd.size,
-					&flash_cmd.dma);
+	flash_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, flash_cmd.size,
+					  &flash_cmd.dma, GFP_KERNEL);
 	if (!flash_cmd.va) {
 		status = -ENOMEM;
 		dev_err(&adapter->pdev->dev,
@@ -2558,8 +2558,8 @@ int be_load_fw(struct be_adapter *adapter, u8 *func)
 		status = -1;
 	}
 
-	pci_free_consistent(adapter->pdev, flash_cmd.size, flash_cmd.va,
-				flash_cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, flash_cmd.size, flash_cmd.va,
+			  flash_cmd.dma);
 	if (status) {
 		dev_err(&adapter->pdev->dev, "Firmware load error\n");
 		goto fw_exit;
@@ -2700,13 +2700,13 @@ static void be_ctrl_cleanup(struct be_adapter *adapter)
 	be_unmap_pci_bars(adapter);
 
 	if (mem->va)
-		pci_free_consistent(adapter->pdev, mem->size,
-			mem->va, mem->dma);
+		dma_free_coherent(&adapter->pdev->dev, mem->size, mem->va,
+				  mem->dma);
 
 	mem = &adapter->mc_cmd_mem;
 	if (mem->va)
-		pci_free_consistent(adapter->pdev, mem->size,
-			mem->va, mem->dma);
+		dma_free_coherent(&adapter->pdev->dev, mem->size, mem->va,
+				  mem->dma);
 }
 
 static int be_ctrl_init(struct be_adapter *adapter)
@@ -2721,8 +2721,10 @@ static int be_ctrl_init(struct be_adapter *adapter)
 		goto done;
 
 	mbox_mem_alloc->size = sizeof(struct be_mcc_mailbox) + 16;
-	mbox_mem_alloc->va = pci_alloc_consistent(adapter->pdev,
-				mbox_mem_alloc->size, &mbox_mem_alloc->dma);
+	mbox_mem_alloc->va = dma_alloc_coherent(&adapter->pdev->dev,
+						mbox_mem_alloc->size,
+						&mbox_mem_alloc->dma,
+						GFP_KERNEL);
 	if (!mbox_mem_alloc->va) {
 		status = -ENOMEM;
 		goto unmap_pci_bars;
@@ -2734,8 +2736,9 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	memset(mbox_mem_align->va, 0, sizeof(struct be_mcc_mailbox));
 
 	mc_cmd_mem->size = sizeof(struct be_cmd_req_mcast_mac_config);
-	mc_cmd_mem->va = pci_alloc_consistent(adapter->pdev, mc_cmd_mem->size,
-			&mc_cmd_mem->dma);
+	mc_cmd_mem->va = dma_alloc_coherent(&adapter->pdev->dev,
+					    mc_cmd_mem->size, &mc_cmd_mem->dma,
+					    GFP_KERNEL);
 	if (mc_cmd_mem->va == NULL) {
 		status = -ENOMEM;
 		goto free_mbox;
@@ -2751,8 +2754,8 @@ static int be_ctrl_init(struct be_adapter *adapter)
 	return 0;
 
 free_mbox:
-	pci_free_consistent(adapter->pdev, mbox_mem_alloc->size,
-		mbox_mem_alloc->va, mbox_mem_alloc->dma);
+	dma_free_coherent(&adapter->pdev->dev, mbox_mem_alloc->size,
+			  mbox_mem_alloc->va, mbox_mem_alloc->dma);
 
 unmap_pci_bars:
 	be_unmap_pci_bars(adapter);
@@ -2766,8 +2769,8 @@ static void be_stats_cleanup(struct be_adapter *adapter)
 	struct be_dma_mem *cmd = &adapter->stats_cmd;
 
 	if (cmd->va)
-		pci_free_consistent(adapter->pdev, cmd->size,
-			cmd->va, cmd->dma);
+		dma_free_coherent(&adapter->pdev->dev, cmd->size,
+				  cmd->va, cmd->dma);
 }
 
 static int be_stats_init(struct be_adapter *adapter)
@@ -2775,7 +2778,8 @@ static int be_stats_init(struct be_adapter *adapter)
 	struct be_dma_mem *cmd = &adapter->stats_cmd;
 
 	cmd->size = sizeof(struct be_cmd_req_get_stats);
-	cmd->va = pci_alloc_consistent(adapter->pdev, cmd->size, &cmd->dma);
+	cmd->va = dma_alloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
+				     GFP_KERNEL);
 	if (cmd->va == NULL)
 		return -1;
 	memset(cmd->va, 0, cmd->size);
@@ -2918,11 +2922,11 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	adapter->netdev = netdev;
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
-	status = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
+	status = dma_set_mask(&pdev->dev, DMA_BIT_MASK(64));
 	if (!status) {
 		netdev->features |= NETIF_F_HIGHDMA;
 	} else {
-		status = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		status = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
 		if (status) {
 			dev_err(&pdev->dev, "Could not set PCI DMA Mask\n");
 			goto free_netdev;
-- 
1.7.3.4

