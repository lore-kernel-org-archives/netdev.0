From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 11/11] ipoib: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:10 -0800
Message-ID: <20100120204559.518399582@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=ipoib.patch
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>

--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c	2010-01-20 12:02:29.269388203 -0800
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c	2010-01-20 12:24:37.828137536 -0800
@@ -624,11 +624,15 @@ void ipoib_cm_handle_rx_wc(struct net_de
 		small_skb = dev_alloc_skb(dlen + 12);
 		if (small_skb) {
 			skb_reserve(small_skb, 12);
-			ib_dma_sync_single_for_cpu(priv->ca, rx_ring[wr_id].mapping[0],
-						   dlen, DMA_FROM_DEVICE);
+			ib_dma_sync_single_for_cpu(priv->ca,
+						   rx_ring[wr_id].mapping[0],
+						   IPOIB_CM_HEAD_SIZE,
+						   DMA_FROM_DEVICE);
 			skb_copy_from_linear_data(skb, small_skb->data, dlen);
-			ib_dma_sync_single_for_device(priv->ca, rx_ring[wr_id].mapping[0],
-						      dlen, DMA_FROM_DEVICE);
+			ib_dma_sync_single_for_device(priv->ca,
+						      rx_ring[wr_id].mapping[0],
+						      IPOIB_CM_HEAD_SIZE,
+						      DMA_FROM_DEVICE);
 			skb_put(small_skb, dlen);
 			skb = small_skb;
 			goto copied;

-- 

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
