From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers:net: dma_alloc_coherent: use __GFP_ZERO instead of memset(, 0)
Date: Fri, 15 Mar 2013 10:23:58 -0700
Message-ID: <dbbfc5e66dba7d2b63549d218407fb0c4031f2ed.1363367992.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	users@rt2x00.serialmonkey.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60285 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751901Ab3CORYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 13:24:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the number of calls required to alloc
a zeroed block of memory.

Trivially reduces overall object size.

Other changes around these removals
o Neaten call argument alignment
o Remove an unnecessary OOM message after dma_alloc_coherent failure
o Remove unnecessary gfp_t stack variable

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/aeroflex/greth.c              |  8 ++------
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |  8 ++++----
 drivers/net/ethernet/broadcom/bnx2.c               |  5 ++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  9 +++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    | 14 ++++++-------
 drivers/net/ethernet/broadcom/tg3.c                | 11 +++--------
 drivers/net/ethernet/brocade/bna/bnad.c            |  5 ++---
 drivers/net/ethernet/emulex/benet/be_main.c        | 14 ++++++-------
 drivers/net/ethernet/faraday/ftgmac100.c           |  5 ++---
 drivers/net/ethernet/faraday/ftmac100.c            |  8 ++++----
 drivers/net/ethernet/ibm/emac/mal.c                |  3 +--
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c   |  6 ++----
 drivers/net/ethernet/intel/igbvf/netdev.c          |  2 --
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |  3 +--
 drivers/net/ethernet/marvell/pxa168_eth.c          | 16 ++++++++-------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |  3 +--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 11 +++++------
 drivers/net/ethernet/pasemi/pasemi_mac.c           |  5 ++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    | 23 ++++++++--------------
 drivers/net/ethernet/sfc/nic.c                     |  4 ++--
 drivers/net/ethernet/sgi/meth.c                    |  5 +++--
 drivers/net/ethernet/toshiba/spider_net.c          |  3 +--
 drivers/net/ethernet/tundra/tsi108_eth.c           | 15 +++++---------
 drivers/net/ethernet/xilinx/ll_temac_main.c        |  6 ++----
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |  6 ++----
 drivers/net/fddi/defxx.c                           |  3 +--
 drivers/net/irda/ali-ircc.c                        |  6 ++----
 drivers/net/irda/nsc-ircc.c                        |  6 ++----
 drivers/net/irda/pxaficp_ir.c                      |  4 ++--
 drivers/net/irda/smsc-ircc2.c                      |  7 ++-----
 drivers/net/irda/via-ircc.c                        |  6 ++----
 drivers/net/irda/w83977af_ir.c                     |  7 ++-----
 drivers/net/wireless/b43/dma.c                     |  9 ++-------
 drivers/net/wireless/b43legacy/dma.c               |  3 +--
 drivers/net/wireless/iwlegacy/4965-mac.c           |  4 ++--
 drivers/net/wireless/iwlegacy/common.c             | 10 ++++------
 drivers/net/wireless/iwlegacy/common.h             |  5 ++---
 drivers/net/wireless/rt2x00/rt2x00pci.c            |  4 +---
 38 files changed, 104 insertions(+), 168 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 3a9fbac..2692954 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1466,25 +1466,21 @@ static int greth_of_probe(struct platform_device *ofdev)
 	/* Allocate TX descriptor ring in coherent memory */
 	greth->tx_bd_base = dma_alloc_coherent(greth->dev, 1024,
 					       &greth->tx_bd_base_phys,
-					       GFP_KERNEL);
+					       GFP_KERNEL | __GFP_ZERO);
 	if (!greth->tx_bd_base) {
 		err = -ENOMEM;
 		goto error3;
 	}
 
-	memset(greth->tx_bd_base, 0, 1024);
-
 	/* Allocate RX descriptor ring in coherent memory */
 	greth->rx_bd_base = dma_alloc_coherent(greth->dev, 1024,
 					       &greth->rx_bd_base_phys,
-					       GFP_KERNEL);
+					       GFP_KERNEL | __GFP_ZERO);
 	if (!greth->rx_bd_base) {
 		err = -ENOMEM;
 		goto error4;
 	}
 
-	memset(greth->rx_bd_base, 0, 1024);
-
 	/* Get MAC address from: module param, OF property or ID prom */
 	for (i = 0; i < 6; i++) {
 		if (macaddr[i] != 0)
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 79cf620..0b3e23e 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -862,25 +862,25 @@ static int bcm_enet_open(struct net_device *dev)
 
 	/* allocate rx dma ring */
 	size = priv->rx_ring_size * sizeof(struct bcm_enet_desc);
-	p = dma_alloc_coherent(kdev, size, &priv->rx_desc_dma, GFP_KERNEL);
+	p = dma_alloc_coherent(kdev, size, &priv->rx_desc_dma,
+			       GFP_KERNEL | __GFP_ZERO);
 	if (!p) {
 		ret = -ENOMEM;
 		goto out_freeirq_tx;
 	}
 
-	memset(p, 0, size);
 	priv->rx_desc_alloc_size = size;
 	priv->rx_desc_cpu = p;
 
 	/* allocate tx dma ring */
 	size = priv->tx_ring_size * sizeof(struct bcm_enet_desc);
-	p = dma_alloc_coherent(kdev, size, &priv->tx_desc_dma, GFP_KERNEL);
+	p = dma_alloc_coherent(kdev, size, &priv->tx_desc_dma,
+			       GFP_KERNEL | __GFP_ZERO);
 	if (!p) {
 		ret = -ENOMEM;
 		goto out_free_rx_ring;
 	}
 
-	memset(p, 0, size);
 	priv->tx_desc_alloc_size = size;
 	priv->tx_desc_cpu = p;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 2f0ba8f..e709296 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -854,12 +854,11 @@ bnx2_alloc_mem(struct bnx2 *bp)
 				sizeof(struct statistics_block);
 
 	status_blk = dma_alloc_coherent(&bp->pdev->dev, bp->status_stats_size,
-					&bp->status_blk_mapping, GFP_KERNEL);
+					&bp->status_blk_mapping,
+					GFP_KERNEL | __GFP_ZERO);
 	if (status_blk == NULL)
 		goto alloc_mem_err;
 
-	memset(status_blk, 0, bp->status_stats_size);
-
 	bnapi = &bp->bnx2_napi[0];
 	bnapi->status_blk.msi = status_blk;
 	bnapi->hw_tx_cons_ptr =
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index f865ad5..9e8d195 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1946,12 +1946,9 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 			    bool is_pf);
 
-#define BNX2X_ILT_ZALLOC(x, y, size) \
-	do { \
-		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
-		if (x) \
-			memset(x, 0, size); \
-	} while (0)
+#define BNX2X_ILT_ZALLOC(x, y, size)				\
+	x = dma_alloc_coherent(&bp->pdev->dev, size, y,		\
+			       GFP_KERNEL | __GFP_ZERO)
 
 #define BNX2X_ILT_FREE(x, y, size) \
 	do { \
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 4620fa5..8f96372 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -50,13 +50,13 @@ extern int int_mode;
 		} \
 	} while (0)
 
-#define BNX2X_PCI_ALLOC(x, y, size) \
-	do { \
-		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
-		if (x == NULL) \
-			goto alloc_mem_err; \
-		memset((void *)x, 0, size); \
-	} while (0)
+#define BNX2X_PCI_ALLOC(x, y, size)				\
+do {								\
+	x = dma_alloc_coherent(&bp->pdev->dev, size, y,		\
+			       GFP_KERNEL | __GFP_ZERO);	\
+	if (x == NULL)						\
+		goto alloc_mem_err;				\
+} while (0)
 
 #define BNX2X_ALLOC(x, size) \
 	do { \
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0c1a2ef..7794883 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8172,11 +8172,9 @@ static int tg3_mem_rx_acquire(struct tg3 *tp)
 		tnapi->rx_rcb = dma_alloc_coherent(&tp->pdev->dev,
 						   TG3_RX_RCB_RING_BYTES(tp),
 						   &tnapi->rx_rcb_mapping,
-						   GFP_KERNEL);
+						   GFP_KERNEL | __GFP_ZERO);
 		if (!tnapi->rx_rcb)
 			goto err_out;
-
-		memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 	}
 
 	return 0;
@@ -8226,12 +8224,10 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 	tp->hw_stats = dma_alloc_coherent(&tp->pdev->dev,
 					  sizeof(struct tg3_hw_stats),
 					  &tp->stats_mapping,
-					  GFP_KERNEL);
+					  GFP_KERNEL | __GFP_ZERO);
 	if (!tp->hw_stats)
 		goto err_out;
 
-	memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
-
 	for (i = 0; i < tp->irq_cnt; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
 		struct tg3_hw_status *sblk;
@@ -8239,11 +8235,10 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 		tnapi->hw_status = dma_alloc_coherent(&tp->pdev->dev,
 						      TG3_HW_STATUS_SIZE,
 						      &tnapi->status_mapping,
-						      GFP_KERNEL);
+						      GFP_KERNEL | __GFP_ZERO);
 		if (!tnapi->hw_status)
 			goto err_out;
 
-		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
 		sblk = tnapi->hw_status;
 
 		if (tg3_flag(tp, ENABLE_RSS)) {
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 7cce42d..d588f84 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1264,9 +1264,8 @@ bnad_mem_alloc(struct bnad *bnad,
 			mem_info->mdl[i].len = mem_info->len;
 			mem_info->mdl[i].kva =
 				dma_alloc_coherent(&bnad->pcidev->dev,
-						mem_info->len, &dma_pa,
-						GFP_KERNEL);
-
+						   mem_info->len, &dma_pa,
+						   GFP_KERNEL);
 			if (mem_info->mdl[i].kva == NULL)
 				goto err_return;
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2dfa205..536afa2 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -146,10 +146,9 @@ static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
 	q->entry_size = entry_size;
 	mem->size = len * entry_size;
 	mem->va = dma_alloc_coherent(&adapter->pdev->dev, mem->size, &mem->dma,
-				     GFP_KERNEL);
+				     GFP_KERNEL | __GFP_ZERO);
 	if (!mem->va)
 		return -ENOMEM;
-	memset(mem->va, 0, mem->size);
 	return 0;
 }
 
@@ -2569,10 +2568,9 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 
 	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
 	cmd.va = dma_alloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
-				    GFP_KERNEL);
+				    GFP_KERNEL | __GFP_ZERO);
 	if (cmd.va == NULL)
 		return -1;
-	memset(cmd.va, 0, cmd.size);
 
 	if (enable) {
 		status = pci_write_config_dword(adapter->pdev,
@@ -3794,12 +3792,13 @@ static int be_ctrl_init(struct be_adapter *adapter)
 
 	rx_filter->size = sizeof(struct be_cmd_req_rx_filter);
 	rx_filter->va = dma_alloc_coherent(&adapter->pdev->dev, rx_filter->size,
-					&rx_filter->dma, GFP_KERNEL);
+					   &rx_filter->dma,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (rx_filter->va == NULL) {
 		status = -ENOMEM;
 		goto free_mbox;
 	}
-	memset(rx_filter->va, 0, rx_filter->size);
+
 	mutex_init(&adapter->mbox_lock);
 	spin_lock_init(&adapter->mcc_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
@@ -3841,10 +3840,9 @@ static int be_stats_init(struct be_adapter *adapter)
 		cmd->size = sizeof(struct be_cmd_req_get_stats_v1);
 
 	cmd->va = dma_alloc_coherent(&adapter->pdev->dev, cmd->size, &cmd->dma,
-				     GFP_KERNEL);
+				     GFP_KERNEL | __GFP_ZERO);
 	if (cmd->va == NULL)
 		return -1;
-	memset(cmd->va, 0, cmd->size);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 7c361d1..0e817e6 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -780,12 +780,11 @@ static int ftgmac100_alloc_buffers(struct ftgmac100 *priv)
 
 	priv->descs = dma_alloc_coherent(priv->dev,
 					 sizeof(struct ftgmac100_descs),
-					 &priv->descs_dma_addr, GFP_KERNEL);
+					 &priv->descs_dma_addr,
+					 GFP_KERNEL | __GFP_ZERO);
 	if (!priv->descs)
 		return -ENOMEM;
 
-	memset(priv->descs, 0, sizeof(struct ftgmac100_descs));
-
 	/* initialize RX ring */
 	ftgmac100_rxdes_set_end_of_ring(&priv->descs->rxdes[RX_QUEUE_ENTRIES - 1]);
 
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index b5ea8fb..a6eda8d 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -732,13 +732,13 @@ static int ftmac100_alloc_buffers(struct ftmac100 *priv)
 {
 	int i;
 
-	priv->descs = dma_alloc_coherent(priv->dev, sizeof(struct ftmac100_descs),
-					 &priv->descs_dma_addr, GFP_KERNEL);
+	priv->descs = dma_alloc_coherent(priv->dev,
+					 sizeof(struct ftmac100_descs),
+					 &priv->descs_dma_addr,
+					 GFP_KERNEL | __GFP_ZERO);
 	if (!priv->descs)
 		return -ENOMEM;
 
-	memset(priv->descs, 0, sizeof(struct ftmac100_descs));
-
 	/* initialize RX ring */
 	ftmac100_rxdes_set_end_of_ring(&priv->descs->rxdes[RX_QUEUE_ENTRIES - 1]);
 
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index cc2db5c..610ed223 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -638,12 +638,11 @@ static int mal_probe(struct platform_device *ofdev)
 		(NUM_TX_BUFF * mal->num_tx_chans +
 		 NUM_RX_BUFF * mal->num_rx_chans);
 	mal->bd_virt = dma_alloc_coherent(&ofdev->dev, bd_size, &mal->bd_dma,
-					  GFP_KERNEL);
+					  GFP_KERNEL | __GFP_ZERO);
 	if (mal->bd_virt == NULL) {
 		err = -ENOMEM;
 		goto fail_unmap;
 	}
-	memset(mal->bd_virt, 0, bd_size);
 
 	for (i = 0; i < mal->num_tx_chans; ++i)
 		set_mal_dcrn(mal, MAL_TXCTPR(i), mal->bd_dma +
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 43462d5..a9f9c79 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1020,12 +1020,11 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
 	txdr->size = ALIGN(txdr->size, 4096);
 	txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
-					GFP_KERNEL);
+					GFP_KERNEL | __GFP_ZERO);
 	if (!txdr->desc) {
 		ret_val = 2;
 		goto err_nomem;
 	}
-	memset(txdr->desc, 0, txdr->size);
 	txdr->next_to_use = txdr->next_to_clean = 0;
 
 	ew32(TDBAL, ((u64)txdr->dma & 0x00000000FFFFFFFF));
@@ -1075,12 +1074,11 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 
 	rxdr->size = rxdr->count * sizeof(struct e1000_rx_desc);
 	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
-					GFP_KERNEL);
+					GFP_KERNEL | __GFP_ZERO);
 	if (!rxdr->desc) {
 		ret_val = 5;
 		goto err_nomem;
 	}
-	memset(rxdr->desc, 0, rxdr->size);
 	rxdr->next_to_use = rxdr->next_to_clean = 0;
 
 	rctl = er32(RCTL);
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index d60cd43..bea46bb 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -447,7 +447,6 @@ int igbvf_setup_tx_resources(struct igbvf_adapter *adapter,
 
 	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
 					   &tx_ring->dma, GFP_KERNEL);
-
 	if (!tx_ring->desc)
 		goto err;
 
@@ -488,7 +487,6 @@ int igbvf_setup_rx_resources(struct igbvf_adapter *adapter,
 
 	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
 					   &rx_ring->dma, GFP_KERNEL);
-
 	if (!rx_ring->desc)
 		goto err;
 
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index e23f023..74464c3 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -717,12 +717,11 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	txdr->size = ALIGN(txdr->size, 4096);
 
 	txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
-					GFP_KERNEL);
+					GFP_KERNEL | __GFP_ZERO);
 	if (!txdr->desc) {
 		vfree(txdr->buffer_info);
 		return -ENOMEM;
 	}
-	memset(txdr->desc, 0, txdr->size);
 
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 3ae4c7f..339bb32 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -584,12 +584,14 @@ static int init_hash_table(struct pxa168_eth_private *pep)
 	 */
 	if (pep->htpr == NULL) {
 		pep->htpr = dma_alloc_coherent(pep->dev->dev.parent,
-					      HASH_ADDR_TABLE_SIZE,
-					      &pep->htpr_dma, GFP_KERNEL);
+					       HASH_ADDR_TABLE_SIZE,
+					       &pep->htpr_dma,
+					       GFP_KERNEL | __GFP_ZERO);
 		if (pep->htpr == NULL)
 			return -ENOMEM;
+	} else {
+		memset(pep->htpr, 0, HASH_ADDR_TABLE_SIZE);
 	}
-	memset(pep->htpr, 0, HASH_ADDR_TABLE_SIZE);
 	wrl(pep, HTPR, pep->htpr_dma);
 	return 0;
 }
@@ -1023,11 +1025,11 @@ static int rxq_init(struct net_device *dev)
 	size = pep->rx_ring_size * sizeof(struct rx_desc);
 	pep->rx_desc_area_size = size;
 	pep->p_rx_desc_area = dma_alloc_coherent(pep->dev->dev.parent, size,
-						&pep->rx_desc_dma, GFP_KERNEL);
+						 &pep->rx_desc_dma,
+						 GFP_KERNEL | __GFP_ZERO);
 	if (!pep->p_rx_desc_area)
 		goto out;
 
-	memset((void *)pep->p_rx_desc_area, 0, size);
 	/* initialize the next_desc_ptr links in the Rx descriptors ring */
 	p_rx_desc = pep->p_rx_desc_area;
 	for (i = 0; i < rx_desc_num; i++) {
@@ -1084,10 +1086,10 @@ static int txq_init(struct net_device *dev)
 	size = pep->tx_ring_size * sizeof(struct tx_desc);
 	pep->tx_desc_area_size = size;
 	pep->p_tx_desc_area = dma_alloc_coherent(pep->dev->dev.parent, size,
-						&pep->tx_desc_dma, GFP_KERNEL);
+						 &pep->tx_desc_dma,
+						 GFP_KERNEL | __GFP_ZERO);
 	if (!pep->p_tx_desc_area)
 		goto out;
-	memset((void *)pep->p_tx_desc_area, 0, pep->tx_desc_area_size);
 	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
 	p_tx_desc = pep->p_tx_desc_area;
 	for (i = 0; i < tx_desc_num; i++) {
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 4f9937e..d5ffdc8 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3592,10 +3592,9 @@ static int myri10ge_alloc_slices(struct myri10ge_priv *mgp)
 		bytes = mgp->max_intr_slots * sizeof(*ss->rx_done.entry);
 		ss->rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
 						       &ss->rx_done.bus,
-						       GFP_KERNEL);
+						       GFP_KERNEL | __GFP_ZERO);
 		if (ss->rx_done.entry == NULL)
 			goto abort;
-		memset(ss->rx_done.entry, 0, bytes);
 		bytes = sizeof(*ss->fw_stats);
 		ss->fw_stats = dma_alloc_coherent(&pdev->dev, bytes,
 						  &ss->fw_stats_bus,
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 4bdca9e..abd5fba 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1470,11 +1470,10 @@ pch_gbe_alloc_rx_buffers_pool(struct pch_gbe_adapter *adapter,
 	size = rx_ring->count * bufsz + PCH_GBE_RESERVE_MEMORY;
 	rx_ring->rx_buff_pool = dma_alloc_coherent(&pdev->dev, size,
 						   &rx_ring->rx_buff_pool_logic,
-						   GFP_KERNEL);
+						   GFP_KERNEL | __GFP_ZERO);
 	if (!rx_ring->rx_buff_pool)
 		return -ENOMEM;
 
-	memset(rx_ring->rx_buff_pool, 0, size);
 	rx_ring->rx_buff_pool_size = size;
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
@@ -1773,12 +1772,12 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 	tx_ring->size = tx_ring->count * (int)sizeof(struct pch_gbe_tx_desc);
 
 	tx_ring->desc = dma_alloc_coherent(&pdev->dev, tx_ring->size,
-					   &tx_ring->dma, GFP_KERNEL);
+					   &tx_ring->dma,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (!tx_ring->desc) {
 		vfree(tx_ring->buffer_info);
 		return -ENOMEM;
 	}
-	memset(tx_ring->desc, 0, tx_ring->size);
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
@@ -1818,12 +1817,12 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 
 	rx_ring->size = rx_ring->count * (int)sizeof(struct pch_gbe_rx_desc);
 	rx_ring->desc =	dma_alloc_coherent(&pdev->dev, rx_ring->size,
-					   &rx_ring->dma, GFP_KERNEL);
+					   &rx_ring->dma,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (!rx_ring->desc) {
 		vfree(rx_ring->buffer_info);
 		return -ENOMEM;
 	}
-	memset(rx_ring->desc, 0, rx_ring->size);
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 	for (desNo = 0; desNo < rx_ring->count; desNo++) {
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index b1cfbb7..a5f0b5d 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -441,12 +441,11 @@ static int pasemi_mac_setup_rx_resources(const struct net_device *dev)
 
 	ring->buffers = dma_alloc_coherent(&mac->dma_pdev->dev,
 					   RX_RING_SIZE * sizeof(u64),
-					   &ring->buf_dma, GFP_KERNEL);
+					   &ring->buf_dma,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (!ring->buffers)
 		goto out_ring_desc;
 
-	memset(ring->buffers, 0, RX_RING_SIZE * sizeof(u64));
-
 	write_dma_reg(PAS_DMA_RXCHAN_BASEL(chno),
 		      PAS_DMA_RXCHAN_BASEL_BRBL(ring->chan.ring_dma));
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index a0649ec..2d9c23f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -422,22 +422,20 @@ int qlcnic_82xx_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
 
 	rq_size = SIZEOF_HOSTRQ_TX(struct qlcnic_hostrq_tx_ctx);
 	rq_addr = dma_alloc_coherent(&adapter->pdev->dev, rq_size,
-			&rq_phys_addr, GFP_KERNEL);
+				     &rq_phys_addr, GFP_KERNEL | __GFP_ZERO);
 	if (!rq_addr)
 		return -ENOMEM;
 
 	rsp_size = SIZEOF_CARDRSP_TX(struct qlcnic_cardrsp_tx_ctx);
 	rsp_addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
-			&rsp_phys_addr, GFP_KERNEL);
+				      &rsp_phys_addr, GFP_KERNEL | __GFP_ZERO);
 	if (!rsp_addr) {
 		err = -ENOMEM;
 		goto out_free_rq;
 	}
 
-	memset(rq_addr, 0, rq_size);
 	prq = rq_addr;
 
-	memset(rsp_addr, 0, rsp_size);
 	prsp = rsp_addr;
 
 	prq->host_rsp_dma_addr = cpu_to_le64(rsp_phys_addr);
@@ -744,10 +742,9 @@ int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *adapter,
 	size_t  nic_size = sizeof(struct qlcnic_info_le);
 
 	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-					   &nic_dma_t, GFP_KERNEL);
+					   &nic_dma_t, GFP_KERNEL | __GFP_ZERO);
 	if (!nic_info_addr)
 		return -ENOMEM;
-	memset(nic_info_addr, 0, nic_size);
 
 	nic_info = nic_info_addr;
 
@@ -795,11 +792,10 @@ int qlcnic_82xx_set_nic_info(struct qlcnic_adapter *adapter,
 		return err;
 
 	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-					   &nic_dma_t, GFP_KERNEL);
+					   &nic_dma_t, GFP_KERNEL | __GFP_ZERO);
 	if (!nic_info_addr)
 		return -ENOMEM;
 
-	memset(nic_info_addr, 0, nic_size);
 	nic_info = nic_info_addr;
 
 	nic_info->pci_func = cpu_to_le16(nic->pci_func);
@@ -845,10 +841,10 @@ int qlcnic_82xx_get_pci_info(struct qlcnic_adapter *adapter,
 	size_t pci_size = npar_size * QLCNIC_MAX_PCI_FUNC;
 
 	pci_info_addr = dma_alloc_coherent(&adapter->pdev->dev, pci_size,
-			&pci_info_dma_t, GFP_KERNEL);
+					   &pci_info_dma_t,
+					   GFP_KERNEL | __GFP_ZERO);
 	if (!pci_info_addr)
 		return -ENOMEM;
-	memset(pci_info_addr, 0, pci_size);
 
 	npar = pci_info_addr;
 	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_PCI_INFO);
@@ -940,12 +936,10 @@ int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
 	}
 
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-					&stats_dma_t, GFP_KERNEL);
+					&stats_dma_t, GFP_KERNEL | __GFP_ZERO);
 	if (!stats_addr)
 		return -ENOMEM;
 
-	memset(stats_addr, 0, stats_size);
-
 	arg1 = func | QLCNIC_STATS_VERSION << 8 | QLCNIC_STATS_PORT << 12;
 	arg1 |= rx_tx << 15 | stats_size << 16;
 
@@ -993,11 +987,10 @@ int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
 		return -ENOMEM;
 
 	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-					&stats_dma_t, GFP_KERNEL);
+					&stats_dma_t, GFP_KERNEL | __GFP_ZERO);
 	if (!stats_addr)
 		return -ENOMEM;
 
-	memset(stats_addr, 0, stats_size);
 	qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_GET_MAC_STATS);
 	cmd.req.arg[1] = stats_size << 16;
 	cmd.req.arg[2] = MSD(stats_dma_t);
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index f9f5df8..7b87798 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -305,11 +305,11 @@ int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
 			 unsigned int len)
 {
 	buffer->addr = dma_alloc_coherent(&efx->pci_dev->dev, len,
-					  &buffer->dma_addr, GFP_ATOMIC);
+					  &buffer->dma_addr,
+					  GFP_ATOMIC | __GFP_ZERO);
 	if (!buffer->addr)
 		return -ENOMEM;
 	buffer->len = len;
-	memset(buffer->addr, 0, len);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/sgi/meth.c b/drivers/net/ethernet/sgi/meth.c
index 79ad9c9..4bdbaad9 100644
--- a/drivers/net/ethernet/sgi/meth.c
+++ b/drivers/net/ethernet/sgi/meth.c
@@ -213,10 +213,11 @@ static int meth_init_tx_ring(struct meth_private *priv)
 {
 	/* Init TX ring */
 	priv->tx_ring = dma_alloc_coherent(NULL, TX_RING_BUFFER_SIZE,
-	                                   &priv->tx_ring_dma, GFP_ATOMIC);
+	                                   &priv->tx_ring_dma,
+					   GFP_ATOMIC | __GFP_ZERO);
 	if (!priv->tx_ring)
 		return -ENOMEM;
-	memset(priv->tx_ring, 0, TX_RING_BUFFER_SIZE);
+
 	priv->tx_count = priv->tx_read = priv->tx_write = 0;
 	mace->eth.tx_ring_base = priv->tx_ring_dma;
 	/* Now init skb save area */
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index f1b91fd..fef6b59 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -352,8 +352,7 @@ spider_net_init_chain(struct spider_net_card *card,
 	alloc_size = chain->num_desc * sizeof(struct spider_net_hw_descr);
 
 	chain->hwring = dma_alloc_coherent(&card->pdev->dev, alloc_size,
-		&chain->dma_addr, GFP_KERNEL);
-
+					   &chain->dma_addr, GFP_KERNEL);
 	if (!chain->hwring)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 99fe3c6..3c69a04 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1308,21 +1308,16 @@ static int tsi108_open(struct net_device *dev)
 		       data->id, dev->irq, dev->name);
 	}
 
-	data->rxring = dma_alloc_coherent(NULL, rxring_size,
-					  &data->rxdma, GFP_KERNEL);
-	if (!data->rxring) {
+	data->rxring = dma_alloc_coherent(NULL, rxring_size, &data->rxdma,
+					  GFP_KERNEL | __GFP_ZERO);
+	if (!data->rxring)
 		return -ENOMEM;
-	} else {
-		memset(data->rxring, 0, rxring_size);
-	}
 
-	data->txring = dma_alloc_coherent(NULL, txring_size,
-					  &data->txdma, GFP_KERNEL);
+	data->txring = dma_alloc_coherent(NULL, txring_size, &data->txdma,
+					  GFP_KERNEL | __GFP_ZERO);
 	if (!data->txring) {
 		pci_free_consistent(0, rxring_size, data->rxring, data->rxdma);
 		return -ENOMEM;
-	} else {
-		memset(data->txring, 0, txring_size);
 	}
 
 	for (i = 0; i < TSI108_RXRING_LEN; i++) {
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index a64a6d7..4a7c60f 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -245,23 +245,21 @@ static int temac_dma_bd_init(struct net_device *ndev)
 	/* returns a virtual address and a physical address. */
 	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
-					 &lp->tx_bd_p, GFP_KERNEL);
+					 &lp->tx_bd_p, GFP_KERNEL | __GFP_ZERO);
 	if (!lp->tx_bd_v)
 		goto out;
 
 	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
-					 &lp->rx_bd_p, GFP_KERNEL);
+					 &lp->rx_bd_p, GFP_KERNEL | __GFP_ZERO);
 	if (!lp->rx_bd_v)
 		goto out;
 
-	memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NUM);
 	for (i = 0; i < TX_BD_NUM; i++) {
 		lp->tx_bd_v[i].next = lp->tx_bd_p +
 				sizeof(*lp->tx_bd_v) * ((i + 1) % TX_BD_NUM);
 	}
 
-	memset(lp->rx_bd_v, 0, sizeof(*lp->rx_bd_v) * RX_BD_NUM);
 	for (i = 0; i < RX_BD_NUM; i++) {
 		lp->rx_bd_v[i].next = lp->rx_bd_p +
 				sizeof(*lp->rx_bd_v) * ((i + 1) % RX_BD_NUM);
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index c238f98..24748e8 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -204,25 +204,23 @@ static int axienet_dma_bd_init(struct net_device *ndev)
 	lp->tx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->tx_bd_v) * TX_BD_NUM,
 					 &lp->tx_bd_p,
-					 GFP_KERNEL);
+					 GFP_KERNEL | __GFP_ZERO);
 	if (!lp->tx_bd_v)
 		goto out;
 
 	lp->rx_bd_v = dma_alloc_coherent(ndev->dev.parent,
 					 sizeof(*lp->rx_bd_v) * RX_BD_NUM,
 					 &lp->rx_bd_p,
-					 GFP_KERNEL);
+					 GFP_KERNEL | __GFP_ZERO);
 	if (!lp->rx_bd_v)
 		goto out;
 
-	memset(lp->tx_bd_v, 0, sizeof(*lp->tx_bd_v) * TX_BD_NUM);
 	for (i = 0; i < TX_BD_NUM; i++) {
 		lp->tx_bd_v[i].next = lp->tx_bd_p +
 				      sizeof(*lp->tx_bd_v) *
 				      ((i + 1) % TX_BD_NUM);
 	}
 
-	memset(lp->rx_bd_v, 0, sizeof(*lp->rx_bd_v) * RX_BD_NUM);
 	for (i = 0; i < RX_BD_NUM; i++) {
 		lp->rx_bd_v[i].next = lp->rx_bd_p +
 				      sizeof(*lp->rx_bd_v) *
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index f116e51..4c8ddc9 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -1070,11 +1070,10 @@ static int dfx_driver_init(struct net_device *dev, const char *print_name,
 					(PI_ALIGN_K_DESC_BLK - 1);
 	bp->kmalloced = top_v = dma_alloc_coherent(bp->bus_dev, alloc_size,
 						   &bp->kmalloced_dma,
-						   GFP_ATOMIC);
+						   GFP_ATOMIC | __GFP_ZERO);
 	if (top_v == NULL)
 		return DFX_K_FAILURE;
 
-	memset(top_v, 0, alloc_size);	/* zero out memory before continuing */
 	top_p = bp->kmalloced_dma;	/* get physical address of buffer */
 
 	/*
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 9cea451..3adb43c 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -352,21 +352,19 @@ static int ali_ircc_open(int i, chipio_t *info)
 	/* Allocate memory if needed */
 	self->rx_buff.head =
 		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
+				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 	
 	self->tx_buff.head =
 		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
+				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out3;
 	}
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index 2a4f2f1..9cf836b 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -431,22 +431,20 @@ static int __init nsc_ircc_open(chipio_t *info)
 	/* Allocate memory if needed */
 	self->rx_buff.head =
 		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
+				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto out2;
 
 	}
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 	
 	self->tx_buff.head =
 		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
+				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto out3;
 	}
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 858de05..964b116 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -700,12 +700,12 @@ static int pxa_irda_start(struct net_device *dev)
 
 	err = -ENOMEM;
 	si->dma_rx_buff = dma_alloc_coherent(si->dev, IRDA_FRAME_SIZE_LIMIT,
-					     &si->dma_rx_buff_phy, GFP_KERNEL );
+					     &si->dma_rx_buff_phy, GFP_KERNEL);
 	if (!si->dma_rx_buff)
 		goto err_dma_rx_buff;
 
 	si->dma_tx_buff = dma_alloc_coherent(si->dev, IRDA_FRAME_SIZE_LIMIT,
-					     &si->dma_tx_buff_phy, GFP_KERNEL );
+					     &si->dma_tx_buff_phy, GFP_KERNEL);
 	if (!si->dma_tx_buff)
 		goto err_dma_tx_buff;
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 59b45c1..aa05dad 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -563,19 +563,16 @@ static int smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u8 dma,
 
 	self->rx_buff.head =
 		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
+				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->rx_buff.head == NULL)
 		goto err_out2;
 
 	self->tx_buff.head =
 		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
+				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->tx_buff.head == NULL)
 		goto err_out3;
 
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
-
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
 	self->tx_buff.data = self->tx_buff.head;
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index f9033c6..51f2bc3 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -364,21 +364,19 @@ static int via_ircc_open(struct pci_dev *pdev, chipio_t *info, unsigned int id)
 	/* Allocate memory if needed */
 	self->rx_buff.head =
 		dma_alloc_coherent(&pdev->dev, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
+				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 
 	self->tx_buff.head =
 		dma_alloc_coherent(&pdev->dev, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
+				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out3;
 	}
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index f5bb92f..bb8857a 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -216,22 +216,19 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	/* Allocate memory if needed */
 	self->rx_buff.head =
 		dma_alloc_coherent(NULL, self->rx_buff.truesize,
-				   &self->rx_buff_dma, GFP_KERNEL);
+				   &self->rx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out1;
 	}
 
-	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
-	
 	self->tx_buff.head =
 		dma_alloc_coherent(NULL, self->tx_buff.truesize,
-				   &self->tx_buff_dma, GFP_KERNEL);
+				   &self->tx_buff_dma, GFP_KERNEL | __GFP_ZERO);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
-	memset(self->tx_buff.head, 0, self->tx_buff.truesize);
 
 	self->rx_buff.in_frame = FALSE;
 	self->rx_buff.state = OUTSIDE_FRAME;
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 38bc5a7..f73cbb5 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -419,8 +419,6 @@ static inline
 
 static int alloc_ringmemory(struct b43_dmaring *ring)
 {
-	gfp_t flags = GFP_KERNEL;
-
 	/* The specs call for 4K buffers for 30- and 32-bit DMA with 4K
 	 * alignment and 8K buffers for 64-bit DMA with 8K alignment.
 	 * In practice we could use smaller buffers for the latter, but the
@@ -435,12 +433,9 @@ static int alloc_ringmemory(struct b43_dmaring *ring)
 
 	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
 					    ring_mem_size, &(ring->dmabase),
-					    flags);
-	if (!ring->descbase) {
-		b43err(ring->dev->wl, "DMA ringmemory allocation failed\n");
+					    GFP_KERNEL | __GFP_ZERO);
+	if (!ring->descbase)
 		return -ENOMEM;
-	}
-	memset(ring->descbase, 0, ring_mem_size);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 07d7e92..faeafe2 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -334,10 +334,9 @@ static int alloc_ringmemory(struct b43legacy_dmaring *ring)
 	ring->descbase = dma_alloc_coherent(ring->dev->dev->dma_dev,
 					    B43legacy_DMA_RINGMEMSIZE,
 					    &(ring->dmabase),
-					    GFP_KERNEL);
+					    GFP_KERNEL | __GFP_ZERO);
 	if (!ring->descbase)
 		return -ENOMEM;
-	memset(ring->descbase, 0, B43legacy_DMA_RINGMEMSIZE);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 7941eb3..238f528 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -1921,8 +1921,8 @@ drop_unlock:
 static inline int
 il4965_alloc_dma_ptr(struct il_priv *il, struct il_dma_ptr *ptr, size_t size)
 {
-	ptr->addr =
-	    dma_alloc_coherent(&il->pci_dev->dev, size, &ptr->dma, GFP_KERNEL);
+	ptr->addr = dma_alloc_coherent(&il->pci_dev->dev, size, &ptr->dma,
+				       GFP_KERNEL);
 	if (!ptr->addr)
 		return -ENOMEM;
 	ptr->size = size;
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index bd4c188..db21871 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -2566,15 +2566,13 @@ il_rx_queue_alloc(struct il_priv *il)
 	INIT_LIST_HEAD(&rxq->rx_used);
 
 	/* Alloc the circular buffer of Read Buffer Descriptors (RBDs) */
-	rxq->bd =
-	    dma_alloc_coherent(dev, 4 * RX_QUEUE_SIZE, &rxq->bd_dma,
-			       GFP_KERNEL);
+	rxq->bd = dma_alloc_coherent(dev, 4 * RX_QUEUE_SIZE, &rxq->bd_dma,
+				     GFP_KERNEL);
 	if (!rxq->bd)
 		goto err_bd;
 
-	rxq->rb_stts =
-	    dma_alloc_coherent(dev, sizeof(struct il_rb_status),
-			       &rxq->rb_stts_dma, GFP_KERNEL);
+	rxq->rb_stts = dma_alloc_coherent(dev, sizeof(struct il_rb_status),
+					  &rxq->rb_stts_dma, GFP_KERNEL);
 	if (!rxq->rb_stts)
 		goto err_rb;
 
diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/iwlegacy/common.h
index 96f2025..458e699 100644
--- a/drivers/net/wireless/iwlegacy/common.h
+++ b/drivers/net/wireless/iwlegacy/common.h
@@ -2235,9 +2235,8 @@ il_alloc_fw_desc(struct pci_dev *pci_dev, struct fw_desc *desc)
 		return -EINVAL;
 	}
 
-	desc->v_addr =
-	    dma_alloc_coherent(&pci_dev->dev, desc->len, &desc->p_addr,
-			       GFP_KERNEL);
+	desc->v_addr = dma_alloc_coherent(&pci_dev->dev, desc->len,
+					  &desc->p_addr, GFP_KERNEL);
 	return (desc->v_addr != NULL) ? 0 : -ENOMEM;
 }
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index a0c8cae..696abed 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -124,12 +124,10 @@ static int rt2x00pci_alloc_queue_dma(struct rt2x00_dev *rt2x00dev,
 	 */
 	addr = dma_alloc_coherent(rt2x00dev->dev,
 				  queue->limit * queue->desc_size,
-				  &dma, GFP_KERNEL);
+				  &dma, GFP_KERNEL | __GFP_ZERO);
 	if (!addr)
 		return -ENOMEM;
 
-	memset(addr, 0, queue->limit * queue->desc_size);
-
 	/*
 	 * Initialize all queue entries to contain valid addresses.
 	 */
-- 
1.8.1.2.459.gbcd45b4.dirty
