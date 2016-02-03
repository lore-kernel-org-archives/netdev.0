From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 3/4] drivers: net: xgene: Add support for multiple queues
Date: Tue,  2 Feb 2016 23:55:15 -0800
Message-ID: <1454486116-23783-4-git-send-email-isubramanian@apm.com>
References: <1454486116-23783-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, toanle@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>,
	Khuong Dinh <kdinh@apm.com>, Tanmay Inamdar <tinamdar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33241 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240AbcBCHzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 02:55:18 -0500
Received: by mail-pa0-f42.google.com with SMTP id cy9so9441529pac.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 23:55:17 -0800 (PST)
In-Reply-To: <1454486116-23783-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Khuong Dinh <kdinh@apm.com>
Signed-off-by: Tanmay Inamdar <tinamdar@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c  |  11 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 452 ++++++++++++++---------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  20 +-
 3 files changed, 289 insertions(+), 194 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
index d51268f..ae0c93c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
@@ -333,13 +333,14 @@ static int xgene_cle_set_rss_skeys(struct xgene_enet_cle *cle)
 static int xgene_cle_set_rss_idt(struct xgene_enet_pdata *pdata)
 {
 	int i, ret = 0;
-	u32 fpsel, dstqid, nfpsel, idt_reg;
+	u32 fpsel, dstqid, nfpsel, idt_reg, idx;
 	u16 pool_id;
 
 	for (i = 0; i < XGENE_CLE_IDT_ENTRIES; i++) {
-		pool_id = pdata->rx_ring->buf_pool->id;
+		idx = i % pdata->rxq_cnt;
+		pool_id = pdata->rx_ring[idx]->buf_pool->id;
 		fpsel = xgene_enet_ring_bufnum(pool_id) - 0x20;
-		dstqid = xgene_enet_dst_ring_num(pdata->rx_ring);
+		dstqid = xgene_enet_dst_ring_num(pdata->rx_ring[idx]);
 		nfpsel = 0;
 		idt_reg = 0;
 
@@ -695,8 +696,8 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 		br->mask = 0xffff;
 	}
 
-	def_qid = xgene_enet_dst_ring_num(pdata->rx_ring);
-	pool_id = pdata->rx_ring->buf_pool->id;
+	def_qid = xgene_enet_dst_ring_num(pdata->rx_ring[0]);
+	pool_id = pdata->rx_ring[0]->buf_pool->id;
 	def_fpsel = xgene_enet_ring_bufnum(pool_id) - 0x20;
 
 	memset(dbptr, 0, sizeof(struct xgene_cle_dbptr) * DB_MAX_PTRS);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 2716d45..1653345 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -182,7 +182,6 @@ static int xgene_enet_tx_completion(struct xgene_enet_desc_ring *cp_ring,
 static u64 xgene_enet_work_msg(struct sk_buff *skb)
 {
 	struct net_device *ndev = skb->dev;
-	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct iphdr *iph;
 	u8 l3hlen = 0, l4hlen = 0;
 	u8 ethhdr, proto = 0, csum_enable = 0;
@@ -228,10 +227,6 @@ static u64 xgene_enet_work_msg(struct sk_buff *skb)
 			if (!mss || ((skb->len - hdr_len) <= mss))
 				goto out;
 
-			if (mss != pdata->mss) {
-				pdata->mss = mss;
-				pdata->mac_ops->set_mss(pdata);
-			}
 			hopinfo |= SET_BIT(ET);
 		}
 	} else if (iph->protocol == IPPROTO_UDP) {
@@ -413,7 +408,7 @@ out:
 	raw_desc->m0 = cpu_to_le64(SET_VAL(LL, ll) | SET_VAL(NV, nv) |
 				   SET_VAL(USERINFO, tx_ring->tail));
 	tx_ring->cp_ring->cp_skb[tx_ring->tail] = skb;
-	pdata->tx_level += count;
+	pdata->tx_level[tx_ring->cp_ring->index] += count;
 	tx_ring->tail = tail;
 
 	return count;
@@ -423,15 +418,17 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
 					 struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
-	struct xgene_enet_desc_ring *tx_ring = pdata->tx_ring;
-	u32 tx_level = pdata->tx_level;
+	struct xgene_enet_desc_ring *tx_ring;
+	int index = skb->queue_mapping;
+	u32 tx_level = pdata->tx_level[index];
 	int count;
 
-	if (tx_level < pdata->txc_level)
-		tx_level += ((typeof(pdata->tx_level))~0U);
+	tx_ring = pdata->tx_ring[index];
+	if (tx_level < pdata->txc_level[index])
+		tx_level += ((typeof(pdata->tx_level[index]))~0U);
 
-	if ((tx_level - pdata->txc_level) > pdata->tx_qcnt_hi) {
-		netif_stop_queue(ndev);
+	if ((tx_level - pdata->txc_level[index]) > pdata->tx_qcnt_hi) {
+		netif_stop_subqueue(ndev, index);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -529,7 +526,8 @@ static bool is_rx_desc(struct xgene_enet_raw_desc *raw_desc)
 static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 				   int budget)
 {
-	struct xgene_enet_pdata *pdata = netdev_priv(ring->ndev);
+	struct net_device *ndev = ring->ndev;
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct xgene_enet_raw_desc *raw_desc, *exp_desc;
 	u16 head = ring->head;
 	u16 slots = ring->slots - 1;
@@ -573,7 +571,7 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 		desc_count++;
 		processed++;
 		if (is_completion)
-			pdata->txc_level += desc_count;
+			pdata->txc_level[ring->index] += desc_count;
 
 		if (ret)
 			break;
@@ -583,8 +581,8 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 		pdata->ring_ops->wr_cmd(ring, -count);
 		ring->head = head;
 
-		if (netif_queue_stopped(ring->ndev))
-			netif_start_queue(ring->ndev);
+		if (__netif_subqueue_stopped(ndev, ring->index))
+			netif_start_subqueue(ndev, ring->index);
 	}
 
 	return processed;
@@ -609,8 +607,16 @@ static int xgene_enet_napi(struct napi_struct *napi, const int budget)
 static void xgene_enet_timeout(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	struct netdev_queue *txq;
+	int i;
 
 	pdata->mac_ops->reset(pdata);
+
+	for (i = 0; i < pdata->txq_cnt; i++) {
+		txq = netdev_get_tx_queue(ndev, i);
+		txq->trans_start = jiffies;
+		netif_tx_start_queue(txq);
+	}
 }
 
 static int xgene_enet_register_irq(struct net_device *ndev)
@@ -618,17 +624,21 @@ static int xgene_enet_register_irq(struct net_device *ndev)
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct device *dev = ndev_to_dev(ndev);
 	struct xgene_enet_desc_ring *ring;
-	int ret;
+	int ret = 0, i;
 
-	ring = pdata->rx_ring;
-	irq_set_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
-	ret = devm_request_irq(dev, ring->irq, xgene_enet_rx_irq,
-			       IRQF_SHARED, ring->irq_name, ring);
-	if (ret)
-		netdev_err(ndev, "Failed to request irq %s\n", ring->irq_name);
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		ring = pdata->rx_ring[i];
+		irq_set_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
+		ret = devm_request_irq(dev, ring->irq, xgene_enet_rx_irq,
+				       IRQF_SHARED, ring->irq_name, ring);
+		if (ret) {
+			netdev_err(ndev, "Failed to request irq %s\n",
+				   ring->irq_name);
+		}
+	}
 
-	if (pdata->cq_cnt) {
-		ring = pdata->tx_ring->cp_ring;
+	for (i = 0; i < pdata->cq_cnt; i++) {
+		ring = pdata->tx_ring[i]->cp_ring;
 		irq_set_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
 		ret = devm_request_irq(dev, ring->irq, xgene_enet_rx_irq,
 				       IRQF_SHARED, ring->irq_name, ring);
@@ -646,15 +656,19 @@ static void xgene_enet_free_irq(struct net_device *ndev)
 	struct xgene_enet_pdata *pdata;
 	struct xgene_enet_desc_ring *ring;
 	struct device *dev;
+	int i;
 
 	pdata = netdev_priv(ndev);
 	dev = ndev_to_dev(ndev);
-	ring = pdata->rx_ring;
-	irq_clear_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
-	devm_free_irq(dev, ring->irq, ring);
 
-	if (pdata->cq_cnt) {
-		ring = pdata->tx_ring->cp_ring;
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		ring = pdata->rx_ring[i];
+		irq_clear_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
+		devm_free_irq(dev, ring->irq, ring);
+	}
+
+	for (i = 0; i < pdata->cq_cnt; i++) {
+		ring = pdata->tx_ring[i]->cp_ring;
 		irq_clear_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
 		devm_free_irq(dev, ring->irq, ring);
 	}
@@ -663,12 +677,15 @@ static void xgene_enet_free_irq(struct net_device *ndev)
 static void xgene_enet_napi_enable(struct xgene_enet_pdata *pdata)
 {
 	struct napi_struct *napi;
+	int i;
 
-	napi = &pdata->rx_ring->napi;
-	napi_enable(napi);
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		napi = &pdata->rx_ring[i]->napi;
+		napi_enable(napi);
+	}
 
-	if (pdata->cq_cnt) {
-		napi = &pdata->tx_ring->cp_ring->napi;
+	for (i = 0; i < pdata->cq_cnt; i++) {
+		napi = &pdata->tx_ring[i]->cp_ring->napi;
 		napi_enable(napi);
 	}
 }
@@ -676,12 +693,15 @@ static void xgene_enet_napi_enable(struct xgene_enet_pdata *pdata)
 static void xgene_enet_napi_disable(struct xgene_enet_pdata *pdata)
 {
 	struct napi_struct *napi;
+	int i;
 
-	napi = &pdata->rx_ring->napi;
-	napi_disable(napi);
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		napi = &pdata->rx_ring[i]->napi;
+		napi_disable(napi);
+	}
 
-	if (pdata->cq_cnt) {
-		napi = &pdata->tx_ring->cp_ring->napi;
+	for (i = 0; i < pdata->cq_cnt; i++) {
+		napi = &pdata->tx_ring[i]->cp_ring->napi;
 		napi_disable(napi);
 	}
 }
@@ -692,6 +712,14 @@ static int xgene_enet_open(struct net_device *ndev)
 	const struct xgene_mac_ops *mac_ops = pdata->mac_ops;
 	int ret;
 
+	ret = netif_set_real_num_tx_queues(ndev, pdata->txq_cnt);
+	if (ret)
+		return ret;
+
+	ret = netif_set_real_num_rx_queues(ndev, pdata->rxq_cnt);
+	if (ret)
+		return ret;
+
 	mac_ops->tx_enable(pdata);
 	mac_ops->rx_enable(pdata);
 
@@ -714,6 +742,7 @@ static int xgene_enet_close(struct net_device *ndev)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	const struct xgene_mac_ops *mac_ops = pdata->mac_ops;
+	int i;
 
 	netif_stop_queue(ndev);
 
@@ -727,7 +756,8 @@ static int xgene_enet_close(struct net_device *ndev)
 
 	xgene_enet_free_irq(ndev);
 	xgene_enet_napi_disable(pdata);
-	xgene_enet_process_ring(pdata->rx_ring, -1);
+	for (i = 0; i < pdata->rxq_cnt; i++)
+		xgene_enet_process_ring(pdata->rx_ring[i], -1);
 
 	return 0;
 }
@@ -747,18 +777,26 @@ static void xgene_enet_delete_ring(struct xgene_enet_desc_ring *ring)
 static void xgene_enet_delete_desc_rings(struct xgene_enet_pdata *pdata)
 {
 	struct xgene_enet_desc_ring *buf_pool;
+	struct xgene_enet_desc_ring *ring;
+	int i;
 
-	if (pdata->tx_ring) {
-		xgene_enet_delete_ring(pdata->tx_ring);
-		pdata->tx_ring = NULL;
+	for (i = 0; i < pdata->txq_cnt; i++) {
+		ring = pdata->tx_ring[i];
+		if (ring) {
+			xgene_enet_delete_ring(ring);
+			pdata->tx_ring[i] = NULL;
+		}
 	}
 
-	if (pdata->rx_ring) {
-		buf_pool = pdata->rx_ring->buf_pool;
-		xgene_enet_delete_bufpool(buf_pool);
-		xgene_enet_delete_ring(buf_pool);
-		xgene_enet_delete_ring(pdata->rx_ring);
-		pdata->rx_ring = NULL;
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		ring = pdata->rx_ring[i];
+		if (ring) {
+			buf_pool = ring->buf_pool;
+			xgene_enet_delete_bufpool(buf_pool);
+			xgene_enet_delete_ring(buf_pool);
+			xgene_enet_delete_ring(ring);
+			pdata->rx_ring[i] = NULL;
+		}
 	}
 }
 
@@ -813,24 +851,29 @@ static void xgene_enet_free_desc_rings(struct xgene_enet_pdata *pdata)
 {
 	struct device *dev = &pdata->pdev->dev;
 	struct xgene_enet_desc_ring *ring;
+	int i;
 
-	ring = pdata->tx_ring;
-	if (ring) {
-		if (ring->cp_ring && ring->cp_ring->cp_skb)
-			devm_kfree(dev, ring->cp_ring->cp_skb);
-		if (ring->cp_ring && pdata->cq_cnt)
-			xgene_enet_free_desc_ring(ring->cp_ring);
-		xgene_enet_free_desc_ring(ring);
-	}
-
-	ring = pdata->rx_ring;
-	if (ring) {
-		if (ring->buf_pool) {
-			if (ring->buf_pool->rx_skb)
-				devm_kfree(dev, ring->buf_pool->rx_skb);
-			xgene_enet_free_desc_ring(ring->buf_pool);
+	for (i = 0; i < pdata->txq_cnt; i++) {
+		ring = pdata->tx_ring[i];
+		if (ring) {
+			if (ring->cp_ring && ring->cp_ring->cp_skb)
+				devm_kfree(dev, ring->cp_ring->cp_skb);
+			if (ring->cp_ring && pdata->cq_cnt)
+				xgene_enet_free_desc_ring(ring->cp_ring);
+			xgene_enet_free_desc_ring(ring);
+		}
+	}
+
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		ring = pdata->rx_ring[i];
+		if (ring) {
+			if (ring->buf_pool) {
+				if (ring->buf_pool->rx_skb)
+					devm_kfree(dev, ring->buf_pool->rx_skb);
+				xgene_enet_free_desc_ring(ring->buf_pool);
+			}
+			xgene_enet_free_desc_ring(ring);
 		}
-		xgene_enet_free_desc_ring(ring);
 	}
 }
 
@@ -943,104 +986,119 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	u8 bp_bufnum = pdata->bp_bufnum;
 	u16 ring_num = pdata->ring_num;
 	u16 ring_id;
-	int ret, size;
-
-	/* allocate rx descriptor ring */
-	owner = xgene_derive_ring_owner(pdata);
-	ring_id = xgene_enet_get_ring_id(RING_OWNER_CPU, cpu_bufnum++);
-	rx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
-					      RING_CFGSIZE_16KB, ring_id);
-	if (!rx_ring) {
-		ret = -ENOMEM;
-		goto err;
-	}
-
-	/* allocate buffer pool for receiving packets */
-	owner = xgene_derive_ring_owner(pdata);
-	ring_id = xgene_enet_get_ring_id(owner, bp_bufnum++);
-	buf_pool = xgene_enet_create_desc_ring(ndev, ring_num++,
-					       RING_CFGSIZE_2KB, ring_id);
-	if (!buf_pool) {
-		ret = -ENOMEM;
-		goto err;
-	}
+	int i, ret, size;
 
-	rx_ring->nbufpool = NUM_BUFPOOL;
-	rx_ring->buf_pool = buf_pool;
-	rx_ring->irq = pdata->rx_irq;
-	if (!pdata->cq_cnt) {
-		snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx-txc",
-			 ndev->name);
-	} else {
-		snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx", ndev->name);
-	}
-	buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
-					sizeof(struct sk_buff *), GFP_KERNEL);
-	if (!buf_pool->rx_skb) {
-		ret = -ENOMEM;
-		goto err;
-	}
-
-	buf_pool->dst_ring_num = xgene_enet_dst_ring_num(buf_pool);
-	rx_ring->buf_pool = buf_pool;
-	pdata->rx_ring = rx_ring;
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		/* allocate rx descriptor ring */
+		owner = xgene_derive_ring_owner(pdata);
+		ring_id = xgene_enet_get_ring_id(RING_OWNER_CPU, cpu_bufnum++);
+		rx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
+						      RING_CFGSIZE_16KB,
+						      ring_id);
+		if (!rx_ring) {
+			ret = -ENOMEM;
+			goto err;
+		}
 
-	/* allocate tx descriptor ring */
-	owner = xgene_derive_ring_owner(pdata);
-	ring_id = xgene_enet_get_ring_id(owner, eth_bufnum++);
-	tx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
-					      RING_CFGSIZE_16KB, ring_id);
-	if (!tx_ring) {
-		ret = -ENOMEM;
-		goto err;
-	}
+		/* allocate buffer pool for receiving packets */
+		owner = xgene_derive_ring_owner(pdata);
+		ring_id = xgene_enet_get_ring_id(owner, bp_bufnum++);
+		buf_pool = xgene_enet_create_desc_ring(ndev, ring_num++,
+						       RING_CFGSIZE_2KB,
+						       ring_id);
+		if (!buf_pool) {
+			ret = -ENOMEM;
+			goto err;
+		}
 
-	size = (tx_ring->slots / 2) * sizeof(__le64) * MAX_EXP_BUFFS;
-	tx_ring->exp_bufs = dma_zalloc_coherent(dev, size, &dma_exp_bufs,
+		rx_ring->nbufpool = NUM_BUFPOOL;
+		rx_ring->buf_pool = buf_pool;
+		rx_ring->irq = pdata->irqs[i];
+		if (!pdata->cq_cnt) {
+			snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx-txc",
+				 ndev->name);
+		} else {
+			snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx%d",
+				 ndev->name, i);
+		}
+		buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
+						sizeof(struct sk_buff *),
 						GFP_KERNEL);
-	if (!tx_ring->exp_bufs) {
-		ret = -ENOMEM;
-		goto err;
-	}
+		if (!buf_pool->rx_skb) {
+			ret = -ENOMEM;
+			goto err;
+		}
 
-	pdata->tx_ring = tx_ring;
+		buf_pool->dst_ring_num = xgene_enet_dst_ring_num(buf_pool);
+		rx_ring->buf_pool = buf_pool;
+		pdata->rx_ring[i] = rx_ring;
+	}
 
-	if (!pdata->cq_cnt) {
-		cp_ring = pdata->rx_ring;
-	} else {
-		/* allocate tx completion descriptor ring */
-		ring_id = xgene_enet_get_ring_id(RING_OWNER_CPU, cpu_bufnum++);
-		cp_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
+	for (i = 0; i < pdata->txq_cnt; i++) {
+		/* allocate tx descriptor ring */
+		owner = xgene_derive_ring_owner(pdata);
+		ring_id = xgene_enet_get_ring_id(owner, eth_bufnum++);
+		tx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
 						      RING_CFGSIZE_16KB,
 						      ring_id);
-		if (!cp_ring) {
+		if (!tx_ring) {
 			ret = -ENOMEM;
 			goto err;
 		}
-		cp_ring->irq = pdata->txc_irq;
-		snprintf(cp_ring->irq_name, IRQ_ID_SIZE, "%s-txc", ndev->name);
-	}
 
-	cp_ring->cp_skb = devm_kcalloc(dev, tx_ring->slots,
-				       sizeof(struct sk_buff *), GFP_KERNEL);
-	if (!cp_ring->cp_skb) {
-		ret = -ENOMEM;
-		goto err;
-	}
+		size = (tx_ring->slots / 2) * sizeof(__le64) * MAX_EXP_BUFFS;
+		tx_ring->exp_bufs = dma_zalloc_coherent(dev, size,
+							&dma_exp_bufs,
+							GFP_KERNEL);
+		if (!tx_ring->exp_bufs) {
+			ret = -ENOMEM;
+			goto err;
+		}
 
-	size = sizeof(dma_addr_t) * MAX_SKB_FRAGS;
-	cp_ring->frag_dma_addr = devm_kcalloc(dev, tx_ring->slots,
-					      size, GFP_KERNEL);
-	if (!cp_ring->frag_dma_addr) {
-		devm_kfree(dev, cp_ring->cp_skb);
-		ret = -ENOMEM;
-		goto err;
-	}
+		pdata->tx_ring[i] = tx_ring;
 
-	pdata->tx_ring->cp_ring = cp_ring;
-	pdata->tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
+		if (!pdata->cq_cnt) {
+			cp_ring = pdata->rx_ring[i];
+		} else {
+			/* allocate tx completion descriptor ring */
+			ring_id = xgene_enet_get_ring_id(RING_OWNER_CPU,
+							 cpu_bufnum++);
+			cp_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
+							      RING_CFGSIZE_16KB,
+							      ring_id);
+			if (!cp_ring) {
+				ret = -ENOMEM;
+				goto err;
+			}
+
+			cp_ring->irq = pdata->irqs[pdata->rxq_cnt + i];
+			cp_ring->index = i;
+			snprintf(cp_ring->irq_name, IRQ_ID_SIZE, "%s-txc%d",
+				 ndev->name, i);
+		}
+
+		cp_ring->cp_skb = devm_kcalloc(dev, tx_ring->slots,
+					       sizeof(struct sk_buff *),
+					       GFP_KERNEL);
+		if (!cp_ring->cp_skb) {
+			ret = -ENOMEM;
+			goto err;
+		}
 
-	pdata->tx_qcnt_hi = pdata->tx_ring->slots - 128;
+		size = sizeof(dma_addr_t) * MAX_SKB_FRAGS;
+		cp_ring->frag_dma_addr = devm_kcalloc(dev, tx_ring->slots,
+						      size, GFP_KERNEL);
+		if (!cp_ring->frag_dma_addr) {
+			devm_kfree(dev, cp_ring->cp_skb);
+			ret = -ENOMEM;
+			goto err;
+		}
+
+		tx_ring->cp_ring = cp_ring;
+		tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
+	}
+
+	pdata->tx_qcnt_hi = pdata->tx_ring[0]->slots - 128;
 
 	return 0;
 
@@ -1159,6 +1217,32 @@ static int xgene_get_rx_delay(struct xgene_enet_pdata *pdata)
 	return 0;
 }
 
+static int xgene_enet_get_irqs(struct xgene_enet_pdata *pdata)
+{
+	struct platform_device *pdev = pdata->pdev;
+	struct device *dev = &pdev->dev;
+	int i, ret, max_irqs;
+
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
+		max_irqs = 1;
+	else if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII)
+		max_irqs = 2;
+	else
+		max_irqs = XGENE_MAX_ENET_IRQ;
+
+	for (i = 0; i < max_irqs; i++) {
+		ret = platform_get_irq(pdev, i);
+		if (ret <= 0) {
+			dev_err(dev, "Unable to get ENET IRQ\n");
+			ret = ret ? : -ENXIO;
+			return ret;
+		}
+		pdata->irqs[i] = ret;
+	}
+
+	return 0;
+}
+
 static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 {
 	struct platform_device *pdev;
@@ -1240,25 +1324,9 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	if (ret)
 		return ret;
 
-	ret = platform_get_irq(pdev, 0);
-	if (ret <= 0) {
-		dev_err(dev, "Unable to get ENET Rx IRQ\n");
-		ret = ret ? : -ENXIO;
+	ret = xgene_enet_get_irqs(pdata);
+	if (ret)
 		return ret;
-	}
-	pdata->rx_irq = ret;
-
-	if (pdata->phy_mode != PHY_INTERFACE_MODE_RGMII) {
-		ret = platform_get_irq(pdev, 1);
-		if (ret <= 0) {
-			pdata->cq_cnt = 0;
-			dev_info(dev, "Unable to get Tx completion IRQ,"
-				 "using Rx IRQ instead\n");
-		} else {
-			pdata->cq_cnt = XGENE_MAX_TXC_RINGS;
-			pdata->txc_irq = ret;
-		}
-	}
 
 	pdata->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pdata->clk)) {
@@ -1296,7 +1364,7 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 	struct xgene_enet_desc_ring *buf_pool;
 	struct xgene_enet_cle *enet_cle = &pdata->cle;
 	u16 dst_ring_num;
-	int ret;
+	int i, ret;
 
 	ret = pdata->port_ops->reset(pdata);
 	if (ret)
@@ -1309,15 +1377,18 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 	}
 
 	/* setup buffer pool */
-	buf_pool = pdata->rx_ring->buf_pool;
-	xgene_enet_init_bufpool(buf_pool);
-	ret = xgene_enet_refill_bufpool(buf_pool, pdata->rx_buff_cnt);
-	if (ret) {
-		xgene_enet_delete_desc_rings(pdata);
-		return ret;
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		buf_pool = pdata->rx_ring[i]->buf_pool;
+		xgene_enet_init_bufpool(buf_pool);
+		ret = xgene_enet_refill_bufpool(buf_pool, pdata->rx_buff_cnt);
+		if (ret) {
+			xgene_enet_delete_desc_rings(pdata);
+			return ret;
+		}
 	}
 
-	dst_ring_num = xgene_enet_dst_ring_num(pdata->rx_ring);
+	dst_ring_num = xgene_enet_dst_ring_num(pdata->rx_ring[0]);
+	buf_pool = pdata->rx_ring[0]->buf_pool;
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
 		/* Initialize and Enable  PreClassifier Tree */
 		enet_cle->max_nodes = 512;
@@ -1348,17 +1419,26 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 		pdata->mac_ops = &xgene_gmac_ops;
 		pdata->port_ops = &xgene_gport_ops;
 		pdata->rm = RM3;
+		pdata->rxq_cnt = 1;
+		pdata->txq_cnt = 1;
+		pdata->cq_cnt = 0;
 		break;
 	case PHY_INTERFACE_MODE_SGMII:
 		pdata->mac_ops = &xgene_sgmac_ops;
 		pdata->port_ops = &xgene_sgport_ops;
 		pdata->rm = RM1;
+		pdata->rxq_cnt = 1;
+		pdata->txq_cnt = 1;
+		pdata->cq_cnt = 1;
 		break;
 	default:
 		pdata->mac_ops = &xgene_xgmac_ops;
 		pdata->port_ops = &xgene_xgport_ops;
 		pdata->cle_ops = &xgene_cle3in_ops;
 		pdata->rm = RM0;
+		pdata->rxq_cnt = XGENE_NUM_RX_RING;
+		pdata->txq_cnt = XGENE_NUM_TX_RING;
+		pdata->cq_cnt = XGENE_NUM_TXC_RING;
 		break;
 	}
 
@@ -1412,12 +1492,16 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 static void xgene_enet_napi_add(struct xgene_enet_pdata *pdata)
 {
 	struct napi_struct *napi;
+	int i;
 
-	napi = &pdata->rx_ring->napi;
-	netif_napi_add(pdata->ndev, napi, xgene_enet_napi, NAPI_POLL_WEIGHT);
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		napi = &pdata->rx_ring[i]->napi;
+		netif_napi_add(pdata->ndev, napi, xgene_enet_napi,
+			       NAPI_POLL_WEIGHT);
+	}
 
-	if (pdata->cq_cnt) {
-		napi = &pdata->tx_ring->cp_ring->napi;
+	for (i = 0; i < pdata->cq_cnt; i++) {
+		napi = &pdata->tx_ring[i]->cp_ring->napi;
 		netif_napi_add(pdata->ndev, napi, xgene_enet_napi,
 			       NAPI_POLL_WEIGHT);
 	}
@@ -1426,12 +1510,15 @@ static void xgene_enet_napi_add(struct xgene_enet_pdata *pdata)
 static void xgene_enet_napi_del(struct xgene_enet_pdata *pdata)
 {
 	struct napi_struct *napi;
+	int i;
 
-	napi = &pdata->rx_ring->napi;
-	netif_napi_del(napi);
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		napi = &pdata->rx_ring[i]->napi;
+		netif_napi_del(napi);
+	}
 
-	if (pdata->cq_cnt) {
-		napi = &pdata->tx_ring->cp_ring->napi;
+	for (i = 0; i < pdata->cq_cnt; i++) {
+		napi = &pdata->tx_ring[i]->cp_ring->napi;
 		netif_napi_del(napi);
 	}
 }
@@ -1445,7 +1532,8 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	const struct of_device_id *of_id;
 	int ret;
 
-	ndev = alloc_etherdev(sizeof(struct xgene_enet_pdata));
+	ndev = alloc_etherdev_mqs(sizeof(struct xgene_enet_pdata),
+				  XGENE_NUM_RX_RING, XGENE_NUM_TX_RING);
 	if (!ndev)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 05365c1..bf2f301 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -49,6 +49,11 @@
 #define XGENE_ENET_MSS	1448
 #define XGENE_MIN_ENET_FRAME_SIZE	60
 
+#define XGENE_MAX_ENET_IRQ	8
+#define XGENE_NUM_RX_RING	4
+#define XGENE_NUM_TX_RING	4
+#define XGENE_NUM_TXC_RING	4
+
 #define START_CPU_BUFNUM_0	0
 #define START_ETH_BUFNUM_0	2
 #define START_BP_BUFNUM_0	0x22
@@ -73,7 +78,6 @@
 #define X2_START_RING_NUM_1	256
 
 #define IRQ_ID_SIZE		16
-#define XGENE_MAX_TXC_RINGS	1
 
 #define PHY_POLL_LINK_ON	(10 * HZ)
 #define PHY_POLL_LINK_OFF	(PHY_POLL_LINK_ON / 5)
@@ -103,6 +107,7 @@ struct xgene_enet_desc_ring {
 	void *irq_mbox_addr;
 	u16 dst_ring_num;
 	u8 nbufpool;
+	u8 index;
 	struct sk_buff *(*rx_skb);
 	struct sk_buff *(*cp_skb);
 	dma_addr_t *frag_dma_addr;
@@ -159,15 +164,16 @@ struct xgene_enet_pdata {
 	struct clk *clk;
 	struct platform_device *pdev;
 	enum xgene_enet_id enet_id;
-	struct xgene_enet_desc_ring *tx_ring;
-	struct xgene_enet_desc_ring *rx_ring;
-	u16 tx_level;
-	u16 txc_level;
+	struct xgene_enet_desc_ring *tx_ring[XGENE_NUM_TX_RING];
+	struct xgene_enet_desc_ring *rx_ring[XGENE_NUM_RX_RING];
+	u16 tx_level[XGENE_NUM_TX_RING];
+	u16 txc_level[XGENE_NUM_TX_RING];
 	char *dev_name;
 	u32 rx_buff_cnt;
 	u32 tx_qcnt_hi;
-	u32 rx_irq;
-	u32 txc_irq;
+	u32 irqs[XGENE_MAX_ENET_IRQ];
+	u8 rxq_cnt;
+	u8 txq_cnt;
 	u8 cq_cnt;
 	void __iomem *eth_csr_addr;
 	void __iomem *eth_ring_if_addr;
-- 
1.9.1
