From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] IPoIB: Call skb_dst_drop() once skb is enqueued for sending
Date: Wed, 19 Dec 2012 09:17:19 -0800
Message-ID: <1355937439-6521-1-git-send-email-roland@kernel.org>
Cc: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>

Currently, IPoIB delays collecting send completions for TX packets in
order to batch work more efficiently.  It does skb_orphan() right after
queuing the packets so that destructors run early, to avoid problems
like holding socket send buffers for too long (since we might not
collect a send completion until a long time after the packet is
actually sent).

However, IPoIB clears IFF_XMIT_DST_RELEASE because it actually looks
at skb_dst() to update the PMTU when it gets a too-long packet.  This
means that the packets sitting in the TX ring with uncollected send
completions are holding a reference on the dst.  We've seen this lead
to pathological behavior with respect to route and neighbour GC.  The
easy fix for this is to call skb_dst_drop() when we call skb_orphan().

Also, give packets sent via connected mode (CM) the same skb_orphan()
/ skb_dst_drop() treatment that packets sent via datagram mode get.

Signed-off-by: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
---
Planning to merge this for 3.8 unless someone objects.

 drivers/infiniband/ulp/ipoib/ipoib_cm.c | 3 +++
 drivers/infiniband/ulp/ipoib/ipoib_ib.c | 3 ++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 72ae63f..03103d2 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -752,6 +752,9 @@ void ipoib_cm_send(struct net_device *dev, struct sk_buff *skb, struct ipoib_cm_
 		dev->trans_start = jiffies;
 		++tx->tx_head;
 
+		skb_orphan(skb);
+		skb_dst_drop(skb);
+
 		if (++priv->tx_outstanding == ipoib_sendq_size) {
 			ipoib_dbg(priv, "TX ring 0x%x full, stopping kernel net queue\n",
 				  tx->qp->qp_num);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index f10221f..a1bca70 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -615,8 +615,9 @@ void ipoib_send(struct net_device *dev, struct sk_buff *skb,
 
 		address->last_send = priv->tx_head;
 		++priv->tx_head;
-		skb_orphan(skb);
 
+		skb_orphan(skb);
+		skb_dst_drop(skb);
 	}
 
 	if (unlikely(priv->tx_outstanding > MAX_SEND_CQE))
-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
