From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 5/7] bnxt_en: Optimize doorbell write operations for newer chips.
Date: Mon, 29 May 2017 19:06:08 -0400
Message-ID: <1496099170-701-6-git-send-email-michael.chan@broadcom.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:34134 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdE2XGw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 19:06:52 -0400
Received: by mail-qt0-f182.google.com with SMTP id c13so58619477qtc.1
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 16:06:52 -0700 (PDT)
In-Reply-To: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Older chips require the doorbells to be written twice, but newer chips
do not.  Add a new common function bnxt_db_write() to write all
doorbells appropriately depending on the chip.  Eliminating the extra
doorbell on newer chips has a significant performance improvement
on pktgen.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 30 +++++++++--------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  9 +++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  3 +--
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     |  2 +-
 4 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 427db49..d7c1295 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -463,8 +463,7 @@ static netdev_tx_t bnxt_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	prod = NEXT_TX(prod);
 	txr->tx_prod = prod;
 
-	writel(DB_KEY_TX | prod, txr->tx_doorbell);
-	writel(DB_KEY_TX | prod, txr->tx_doorbell);
+	bnxt_db_write(bp, txr->tx_doorbell, DB_KEY_TX | prod);
 
 tx_done:
 
@@ -1779,8 +1778,7 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 		/* Sync BD data before updating doorbell */
 		wmb();
 
-		writel(DB_KEY_TX | prod, db);
-		writel(DB_KEY_TX | prod, db);
+		bnxt_db_write(bp, db, DB_KEY_TX | prod);
 	}
 
 	cpr->cp_raw_cons = raw_cons;
@@ -1796,14 +1794,10 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 	if (event & BNXT_RX_EVENT) {
 		struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 
-		writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
-		writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
-		if (event & BNXT_AGG_EVENT) {
-			writel(DB_KEY_RX | rxr->rx_agg_prod,
-			       rxr->rx_agg_doorbell);
-			writel(DB_KEY_RX | rxr->rx_agg_prod,
-			       rxr->rx_agg_doorbell);
-		}
+		bnxt_db_write(bp, rxr->rx_doorbell, DB_KEY_RX | rxr->rx_prod);
+		if (event & BNXT_AGG_EVENT)
+			bnxt_db_write(bp, rxr->rx_agg_doorbell,
+				      DB_KEY_RX | rxr->rx_agg_prod);
 	}
 	return rx_pkts;
 }
@@ -1863,13 +1857,11 @@ static int bnxt_poll_nitroa0(struct napi_struct *napi, int budget)
 
 	cpr->cp_raw_cons = raw_cons;
 	BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
-	writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
-	writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
+	bnxt_db_write(bp, rxr->rx_doorbell, DB_KEY_RX | rxr->rx_prod);
 
-	if (event & BNXT_AGG_EVENT) {
-		writel(DB_KEY_RX | rxr->rx_agg_prod, rxr->rx_agg_doorbell);
-		writel(DB_KEY_RX | rxr->rx_agg_prod, rxr->rx_agg_doorbell);
-	}
+	if (event & BNXT_AGG_EVENT)
+		bnxt_db_write(bp, rxr->rx_agg_doorbell,
+			      DB_KEY_RX | rxr->rx_agg_prod);
 
 	if (!bnxt_has_work(bp, cpr) && rx_pkts < budget) {
 		napi_complete_done(napi, rx_pkts);
@@ -7714,6 +7706,8 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	bp->gro_func = bnxt_gro_func_5730x;
 	if (BNXT_CHIP_P4_PLUS(bp))
 		bp->gro_func = bnxt_gro_func_5731x;
+	else
+		bp->flags |= BNXT_FLAG_DOUBLE_DB;
 
 	rc = bnxt_hwrm_func_drv_rgtr(bp);
 	if (rc)
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index c59b2cd..5984423 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1022,6 +1022,7 @@ struct bnxt {
 	#define BNXT_FLAG_FW_LLDP_AGENT	0x80000
 	#define BNXT_FLAG_MULTI_HOST	0x100000
 	#define BNXT_FLAG_SHORT_CMD	0x200000
+	#define BNXT_FLAG_DOUBLE_DB	0x400000
 	#define BNXT_FLAG_CHIP_NITRO_A0	0x1000000
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
@@ -1254,6 +1255,14 @@ static inline u32 bnxt_tx_avail(struct bnxt *bp, struct bnxt_tx_ring_info *txr)
 		((txr->tx_prod - txr->tx_cons) & bp->tx_ring_mask);
 }
 
+/* For TX and RX ring doorbells */
+static inline void bnxt_db_write(struct bnxt *bp, void __iomem *db, u32 val)
+{
+	writel(val, db);
+	if (bp->flags & BNXT_FLAG_DOUBLE_DB)
+		writel(val, db);
+}
+
 extern const u16 bnxt_lhint_arr[];
 
 int bnxt_alloc_rx_data(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 11ddf0a..fd11815 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -2376,8 +2376,7 @@ static int bnxt_run_loopback(struct bnxt *bp)
 	/* Sync BD data before updating doorbell */
 	wmb();
 
-	writel(DB_KEY_TX | txr->tx_prod, txr->tx_doorbell);
-	writel(DB_KEY_TX | txr->tx_prod, txr->tx_doorbell);
+	bnxt_db_write(bp, txr->tx_doorbell, DB_KEY_TX | txr->tx_prod);
 	rc = bnxt_poll_loopback(bp, pkt_size);
 
 	dma_unmap_single(&bp->pdev->dev, map, pkt_size, PCI_DMA_TODEVICE);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 9dae327..8ce793a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -63,7 +63,7 @@ void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
 		tx_buf = &txr->tx_buf_ring[last_tx_cons];
 		rx_prod = tx_buf->rx_prod;
 	}
-	writel(DB_KEY_RX | rx_prod, rxr->rx_doorbell);
+	bnxt_db_write(bp, rxr->rx_doorbell, DB_KEY_RX | rx_prod);
 }
 
 /* returns the following:
-- 
1.8.3.1
