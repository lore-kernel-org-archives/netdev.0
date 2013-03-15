From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH 1/1 v2] Fix dst_neigh_lookup/dst_neigh_lookup_skb return value handling bug
Date: Fri, 15 Mar 2013 11:21:50 +0800
Message-ID: <1363317710-30151-1-git-send-email-zhouzhouyi@gmail.com>
Cc: <yizhouzhou@ict.ac.cn>, Zhouyi Zhou <zhouzhouyi@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:36370 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536Ab3CODWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 23:22:05 -0400
Received: by mail-pb0-f51.google.com with SMTP id un15so3153810pbc.24
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 20:22:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When neighbour table is full, dst_neigh_lookup/dst_neigh_lookup_skb will return
-ENOBUFS which is absolutely non zero, while all the code in kernel which use 
above functions assume failure only on zero return which will cause panic. (for
example: : https://bugzilla.kernel.org/show_bug.cgi?id=54731).

This patch corrects above error with smallest changes to kernel source code and
also correct two return value check missing bugs in drivers/infiniband/hw/cxgb4/cm.c

Tested on my x86_64 SMP machine

Reported-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
Tested-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
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
