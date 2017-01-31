From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 06/10] bnxt_en: Add tx ring mapping logic.
Date: Mon, 30 Jan 2017 20:49:31 -0500
Message-ID: <1485827375-20421-7-git-send-email-michael.chan@broadcom.com>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33760 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752199AbdAaBur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 20:50:47 -0500
Received: by mail-pf0-f178.google.com with SMTP id y143so96530353pfb.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 17:50:01 -0800 (PST)
In-Reply-To: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To support XDP_TX, we need to add a set of dedicated TX rings, each
associated with the NAPI of an RX ring.  To assign XDP rings and regular
rings in a flexible way, we add a bp->tx_ring_map[] array to do the
remapping.  In this patch, before we introduce XDP_TX, the mapping is 1:1.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 11 ++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index cb30ba4..db78103 100644
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
@@ -2967,6 +2967,8 @@ static void bnxt_free_mem(struct bnxt *bp, bool irq_re_init)
 		bnxt_free_stats(bp);
 		bnxt_free_ring_grps(bp);
 		bnxt_free_vnics(bp);
+		kfree(bp->tx_ring_map);
+		bp->tx_ring_map = NULL;
 		kfree(bp->tx_ring);
 		bp->tx_ring = NULL;
 		kfree(bp->rx_ring);
@@ -3019,6 +3021,12 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
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
@@ -3027,6 +3035,7 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 		for (i = 0; i < bp->tx_nr_rings; i++, j++) {
 			bp->tx_ring[i].bnapi = bp->bnapi[j];
 			bp->bnapi[j]->tx_ring = &bp->tx_ring[i];
+			bp->tx_ring_map[i] = i;
 		}
 
 		rc = bnxt_alloc_stats(bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 44dcc26..924c1fa 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -995,6 +995,7 @@ struct bnxt {
 
 	struct bnxt_rx_ring_info	*rx_ring;
 	struct bnxt_tx_ring_info	*tx_ring;
+	u16			*tx_ring_map;
 
 	struct sk_buff *	(*gro_func)(struct bnxt_tpa_info *, int, int,
 					    struct sk_buff *);
-- 
1.8.3.1
