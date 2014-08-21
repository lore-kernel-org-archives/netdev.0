From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH] net: xgene: fix possible NULL dereference in xgene_enet_free_desc_rings()
Date: Thu, 21 Aug 2014 13:44:48 -0700
Message-ID: <1408653888-10193-1-git-send-email-isubramanian@apm.com>
Cc: dan.carpenter@oracle.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og124.obsmtp.com ([64.18.0.212]:55393 "HELO
	exprod5og124.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753562AbaHUUoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 16:44:07 -0400
Received: by mail-pa0-f53.google.com with SMTP id rd3so15179636pab.12
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 13:44:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A NULL pointer dereference is possible for the argument ring->buf_pool
which is passed to xgene_enet_free_desc_ring(), as ring could be NULL.

And now since NULL pointers are being checked for before the calls to
xgene_enet_free_desc_ring(), might as well take advantage of them and
not call the function if the argument would be NULL.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index e1a8f4e..e4222af 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -563,15 +563,21 @@ static void xgene_enet_free_desc_rings(struct xgene_enet_pdata *pdata)
 	struct xgene_enet_desc_ring *ring;
 
 	ring = pdata->tx_ring;
-	if (ring && ring->cp_ring && ring->cp_ring->cp_skb)
-		devm_kfree(dev, ring->cp_ring->cp_skb);
-	xgene_enet_free_desc_ring(ring);
+	if (ring) {
+		if (ring->cp_ring && ring->cp_ring->cp_skb)
+			devm_kfree(dev, ring->cp_ring->cp_skb);
+		xgene_enet_free_desc_ring(ring);
+	}
 
 	ring = pdata->rx_ring;
-	if (ring && ring->buf_pool && ring->buf_pool->rx_skb)
-		devm_kfree(dev, ring->buf_pool->rx_skb);
-	xgene_enet_free_desc_ring(ring->buf_pool);
-	xgene_enet_free_desc_ring(ring);
+	if (ring) {
+		if (ring->buf_pool) {
+			if (ring->buf_pool->rx_skb)
+				devm_kfree(dev, ring->buf_pool->rx_skb);
+			xgene_enet_free_desc_ring(ring->buf_pool);
+		}
+		xgene_enet_free_desc_ring(ring);
+	}
 }
 
 static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
-- 
1.9.1
