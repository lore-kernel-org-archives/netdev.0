From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/14] nfp: add separate buffer allocation function for napi
Date: Mon, 31 Oct 2016 20:43:16 +0000
Message-ID: <1477946602-19644-9-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34608 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034054AbcJaUoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:05 -0400
Received: by mail-wm0-f54.google.com with SMTP id u144so10409447wmu.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:05 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a separate buffer allocation function to be called
from NAPI.  We can make assumptions about the context and
buffer size.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 23 ++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 449ec798a9b7..b43d2dbae368 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1098,6 +1098,26 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
 	return frag;
 }
 
+static void *nfp_net_napi_alloc_one(struct nfp_net *nn, dma_addr_t *dma_addr)
+{
+	void *frag;
+
+	frag = napi_alloc_frag(nn->fl_bufsz);
+	if (!frag) {
+		nn_warn_ratelimit(nn, "Failed to alloc receive page frag\n");
+		return NULL;
+	}
+
+	*dma_addr = nfp_net_dma_map_rx(nn, frag, nn->fl_bufsz, DMA_FROM_DEVICE);
+	if (dma_mapping_error(&nn->pdev->dev, *dma_addr)) {
+		skb_free_frag(frag);
+		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
+		return NULL;
+	}
+
+	return frag;
+}
+
 /**
  * nfp_net_rx_give_one() - Put mapped skb on the software and hardware rings
  * @rx_ring:	RX ring structure
@@ -1413,8 +1433,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, NULL);
 			continue;
 		}
-		new_frag = nfp_net_rx_alloc_one(rx_ring, &new_dma_addr,
-						nn->fl_bufsz);
+		new_frag = nfp_net_napi_alloc_one(nn, &new_dma_addr);
 		if (unlikely(!new_frag)) {
 			nfp_net_rx_drop(r_vec, rx_ring, rxbuf, skb);
 			continue;
-- 
1.9.1
