From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v3 08/12] bnxt_en: Add tx ring mapping logic.
Date: Mon,  6 Feb 2017 16:55:39 -0500
Message-ID: <1486418143-8958-9-git-send-email-michael.chan@broadcom.com>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35769 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751746AbdBFV4I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:56:08 -0500
Received: by mail-pf0-f179.google.com with SMTP id f144so26939463pfa.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:56:08 -0800 (PST)
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To support XDP_TX, we need to add a set of dedicated TX rings, each
associated with the NAPI of an RX ring.  To assign XDP rings and regular
rings in a flexible way, we add a bp->tx_ring_map[] array to do the
remapping.  The netdev txq index is stored in the new field txq_index
so that we can retrieve the netdev txq when handling TX completions.
In this patch, before we introduce XDP_TX, the mapping is 1:1.

v2: Fixed a bug in bnxt_tx_int().

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 15 ++++++++++++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  2 ++
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 1b051f9..811bc82 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -262,8 +262,8 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
-	txr = &bp->tx_ring[i];
 	txq = netdev_get_tx_queue(dev, i);
+	txr = &bp->tx_ring[bp->tx_ring_map[i]];
 	prod = txr->tx_prod;
 
 	free_size = bnxt_tx_avail(bp, txr);
@@ -509,8 +509,7 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static void bnxt_tx_int(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
 {
 	struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
-	int index = txr - &bp->tx_ring[0];
-	struct netdev_queue *txq = netdev_get_tx_queue(bp->dev, index);
+	struct netdev_queue *txq = netdev_get_tx_queue(bp->dev, txr->txq_index);
 	u16 cons = txr->tx_cons;
 	struct pci_dev *pdev = bp->pdev;
 	int i;
@@ -2975,6 +2974,8 @@ static void bnxt_free_mem(struct bnxt *bp, bool irq_re_init)
 		bnxt_free_stats(bp);
 		bnxt_free_ring_grps(bp);
 		bnxt_free_vnics(bp);
+		kfree(bp->tx_ring_map);
+		bp->tx_ring_map = NULL;
 		kfree(bp->tx_ring);
 		bp->tx_ring = NULL;
 		kfree(bp->rx_ring);
@@ -3027,6 +3028,12 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 		if (!bp->tx_ring)
 			return -ENOMEM;
 
+		bp->tx_ring_map = kcalloc(bp->tx_nr_rings, sizeof(u16),
+					  GFP_KERNEL);
+
+		if (!bp->tx_ring_map)
+			return -ENOMEM;
+
 		if (bp->flags & BNXT_FLAG_SHARED_RINGS)
 			j = 0;
 		else
@@ -3035,6 +3042,8 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 		for (i = 0; i < bp->tx_nr_rings; i++, j++) {
 			bp->tx_ring[i].bnapi = bp->bnapi[j];
 			bp->bnapi[j]->tx_ring = &bp->tx_ring[i];
+			bp->tx_ring_map[i] = i;
+			bp->tx_ring[i].txq_index = i;
 		}
 
 		rc = bnxt_alloc_stats(bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 3a079b8..97ccce1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -566,6 +566,7 @@ struct bnxt_tx_ring_info {
 	struct bnxt_napi	*bnapi;
 	u16			tx_prod;
 	u16			tx_cons;
+	u16			txq_index;
 	void __iomem		*tx_doorbell;
 
 	struct tx_bd		*tx_desc_ring[MAX_TX_PAGES];
@@ -995,6 +996,7 @@ struct bnxt {
 
 	struct bnxt_rx_ring_info	*rx_ring;
 	struct bnxt_tx_ring_info	*tx_ring;
+	u16			*tx_ring_map;
 
 	struct sk_buff *	(*gro_func)(struct bnxt_tpa_info *, int, int,
 					    struct sk_buff *);
-- 
1.8.3.1
