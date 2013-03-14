From: Zhouyi Zhou <zhouzhouyi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] Fix dst_neigh_lookup/dst_neigh_lookup_skb return value handling bug
Date: Thu, 14 Mar 2013 11:41:32 +0800
Message-ID: <1363232492-4562-1-git-send-email-zhouzhouyi@gmail.com>
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <yizhouzhou-6xnC4QlcT6v/PtFMR13I2A@public.gmane.org>,
	<swise-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Zhouyi Zhou <zhouzhouyi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tested on my x86_64 machine

Signed-off-by: Zhouyi Zhou <zhouzhouyi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c |   12 ++++++++++++
 include/net/dst.h                |    6 ++++--
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 565bfb1..6b95851 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1575,6 +1575,12 @@ static int c4iw_reconnect(struct c4iw_ep *ep)
 
 	neigh = dst_neigh_lookup(ep->dst,
 			&ep->com.cm_id->remote_addr.sin_addr.s_addr);
+	if (!neigh) {
+		pr_err("%s - cannot alloc neigh.\n", __func__);
+		err = -ENOMEM;
+		goto fail4;
+	}
+
 	/* get a l2t entry */
 	if (neigh->dev->flags & IFF_LOOPBACK) {
 		PDBG("%s LOOPBACK\n", __func__);
@@ -3053,6 +3059,12 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	dst = &rt->dst;
 	neigh = dst_neigh_lookup_skb(dst, skb);
 
+	if (!neigh) {
+		pr_err("%s - failed to allocate neigh!\n",
+		       __func__);
+		goto free_dst;
+	}
+
 	if (neigh->dev->flags & IFF_LOOPBACK) {
 		pdev = ip_dev_find(&init_net, iph->daddr);
 		e = cxgb4_l2t_get(dev->rdev.lldi.l2t, neigh,
diff --git a/include/net/dst.h b/include/net/dst.h
index 853cda1..c083b5a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -413,13 +413,15 @@ static inline int dst_neigh_output(struct dst_entry *dst, struct neighbour *n,
 
 static inline struct neighbour *dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
-	return dst->ops->neigh_lookup(dst, NULL, daddr);
+	struct neighbour *n = dst->ops->neigh_lookup(dst, NULL, daddr);
+	return IS_ERR(n) ? NULL : n;
 }
 
 static inline struct neighbour *dst_neigh_lookup_skb(const struct dst_entry *dst,
 						     struct sk_buff *skb)
 {
-	return dst->ops->neigh_lookup(dst, skb, NULL);
+	struct neighbour *n =  dst->ops->neigh_lookup(dst, skb, NULL);
+	return IS_ERR(n) ? NULL : n;
 }
 
 static inline void dst_link_failure(struct sk_buff *skb)
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
