From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 1/2] drivers: net: xgene: fix: Disable coalescing on v1 hardware
Date: Mon, 31 Oct 2016 16:00:26 -0700
Message-ID: <1477954827-9951-2-git-send-email-isubramanian@apm.com>
References: <1477954827-9951-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>,
        Toan Le <toanle@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36611 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932263AbcJaXAT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 19:00:19 -0400
Received: by mail-oi0-f49.google.com with SMTP id v84so97867344oie.3
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 16:00:19 -0700 (PDT)
In-Reply-To: <1477954827-9951-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since ethernet v1 hardware has a bug related to coalescing, disabling
this feature.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   | 12 ------------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |  3 ++-
 2 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index c481f10..5390ae8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -204,17 +204,6 @@ static u32 xgene_enet_ring_len(struct xgene_enet_desc_ring *ring)
 	return num_msgs;
 }
 
-static void xgene_enet_setup_coalescing(struct xgene_enet_desc_ring *ring)
-{
-	u32 data = 0x7777;
-
-	xgene_enet_ring_wr32(ring, CSR_PBM_COAL, 0x8e);
-	xgene_enet_ring_wr32(ring, CSR_PBM_CTICK1, data);
-	xgene_enet_ring_wr32(ring, CSR_PBM_CTICK2, data << 16);
-	xgene_enet_ring_wr32(ring, CSR_THRESHOLD0_SET1, 0x40);
-	xgene_enet_ring_wr32(ring, CSR_THRESHOLD1_SET1, 0x80);
-}
-
 void xgene_enet_parse_error(struct xgene_enet_desc_ring *ring,
 			    struct xgene_enet_pdata *pdata,
 			    enum xgene_enet_err_code status)
@@ -929,5 +918,4 @@ struct xgene_ring_ops xgene_ring1_ops = {
 	.clear = xgene_enet_clear_ring,
 	.wr_cmd = xgene_enet_wr_cmd,
 	.len = xgene_enet_ring_len,
-	.coalesce = xgene_enet_setup_coalescing,
 };
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 3fc7b0d..1352b52 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1188,7 +1188,8 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 		tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
 	}
 
-	pdata->ring_ops->coalesce(pdata->tx_ring[0]);
+	if (pdata->ring_ops->coalesce)
+		pdata->ring_ops->coalesce(pdata->tx_ring[0]);
 	pdata->tx_qcnt_hi = pdata->tx_ring[0]->slots - 128;
 
 	return 0;
-- 
1.9.1
