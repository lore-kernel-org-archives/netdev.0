From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v2 03/12] drivers: net: xgene: fix: Delete descriptor rings and buffer pools
Date: Fri, 12 Aug 2016 22:05:39 -0700
Message-ID: <1471064748-28033-4-git-send-email-isubramanian@apm.com>
References: <1471064748-28033-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35856 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbcHMFEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 01:04:54 -0400
Received: by mail-pf0-f174.google.com with SMTP id h186so2048442pfg.3
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 22:04:53 -0700 (PDT)
In-Reply-To: <1471064748-28033-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xgene_enet_init_hw() should delete any descriptor rings and
buffer pools setup should le_ops->cle_init() return an error.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index c1fd33d..6b36e0f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1462,10 +1462,8 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 		buf_pool = pdata->rx_ring[i]->buf_pool;
 		xgene_enet_init_bufpool(buf_pool);
 		ret = xgene_enet_refill_bufpool(buf_pool, pdata->rx_buff_cnt);
-		if (ret) {
-			xgene_enet_delete_desc_rings(pdata);
-			return ret;
-		}
+		if (ret)
+			goto err;
 	}
 
 	dst_ring_num = xgene_enet_dst_ring_num(pdata->rx_ring[0]);
@@ -1482,7 +1480,7 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 		ret = pdata->cle_ops->cle_init(pdata);
 		if (ret) {
 			netdev_err(ndev, "Preclass Tree init error\n");
-			return ret;
+			goto err;
 		}
 	} else {
 		pdata->port_ops->cle_bypass(pdata, dst_ring_num, buf_pool->id);
@@ -1492,6 +1490,10 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 	pdata->mac_ops->init(pdata);
 
 	return ret;
+
+err:
+	xgene_enet_delete_desc_rings(pdata);
+	return ret;
 }
 
 static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
-- 
1.9.1
