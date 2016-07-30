From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH net-next 03/10] drivers: net: xgene: fix: Delete descriptor rings and buffer pools
Date: Fri, 29 Jul 2016 17:33:56 -0700
Message-ID: <1469838843-19943-4-git-send-email-isubramanian@apm.com>
References: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1469838843-19943-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

xgene_enet_init_hw() should delete any descriptor rings and
buffer pools setup should le_ops->cle_init() return an error.

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 5246457..6fc5698 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1464,10 +1464,8 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
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
@@ -1484,7 +1482,7 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 		ret = pdata->cle_ops->cle_init(pdata);
 		if (ret) {
 			netdev_err(ndev, "Preclass Tree init error\n");
-			return ret;
+			goto err;
 		}
 	} else {
 		pdata->port_ops->cle_bypass(pdata, dst_ring_num, buf_pool->id);
@@ -1494,6 +1492,10 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
