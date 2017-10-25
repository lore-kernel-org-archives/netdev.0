From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 06/12] ipsec: Create and use new helpers for dst child
 access.
Date: Wed, 25 Oct 2017 23:03:49 +0900 (KST)
Message-ID: <20171025.230349.1982073055390334770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932204AbdJYODx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:03:53 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 1F09B133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:03:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This will make a future change moving the dst->child pointer less
invasive.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |  5 +++++
 net/xfrm/xfrm_policy.c | 57 +++++++++++++++++++++++++-------------------------
 2 files changed, 33 insertions(+), 29 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4fa951112873..5a4cc05ff9e8 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1003,6 +1003,11 @@ static inline struct dst_entry *xfrm_dst_child(const struct dst_entry *dst)
 	return NULL;
 }
 
+static inline void xfrm_dst_set_child(struct xfrm_dst *xdst, struct dst_entry *child)
+{
+	xdst->u.dst.child = child;
+}
+
 static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 {
 	xfrm_pols_put(xdst->pols, xdst->num_pols);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c68fb3327a68..206ac90ff4f0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1545,8 +1545,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	unsigned long now = jiffies;
 	struct net_device *dev;
 	struct xfrm_mode *inner_mode;
-	struct dst_entry *dst_prev = NULL;
-	struct dst_entry *dst0 = NULL;
+	struct xfrm_dst *xdst_prev = NULL;
+	struct xfrm_dst *xdst0 = NULL;
 	int i = 0;
 	int err;
 	int header_len = 0;
@@ -1572,6 +1572,14 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 			goto put_states;
 		}
 
+		if (!xdst_prev)
+			xdst0 = xdst;
+		else
+			/* Ref count is taken during xfrm_alloc_dst()
+			 * No need to do dst_clone() on dst1
+			 */
+			xfrm_dst_set_child(xdst_prev, &xdst->u.dst);
+
 		if (xfrm[i]->sel.family == AF_UNSPEC) {
 			inner_mode = xfrm_ip2inner_mode(xfrm[i],
 							xfrm_af2proto(family));
@@ -1583,14 +1591,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		} else
 			inner_mode = xfrm[i]->inner_mode;
 
-		if (!dst_prev)
-			dst0 = dst1;
-		else
-			/* Ref count is taken during xfrm_alloc_dst()
-			 * No need to do dst_clone() on dst1
-			 */
-			dst_prev->child = dst1;
-
 		xdst->route = dst;
 		dst_copy_metrics(dst1, dst);
 
@@ -1615,8 +1615,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		dst1->input = dst_discard;
 		dst1->output = inner_mode->afinfo->output;
 
-		dst1->next = dst_prev;
-		dst_prev = dst1;
+		dst1->next = &xdst_prev->u.dst;
+		xdst_prev = xdst;
 
 		header_len += xfrm[i]->props.header_len;
 		if (xfrm[i]->type->flags & XFRM_TYPE_NON_FRAGMENT)
@@ -1624,40 +1624,39 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		trailer_len += xfrm[i]->props.trailer_len;
 	}
 
-	dst_prev->child = dst;
-	dst0->path = dst;
+	xfrm_dst_set_child(xdst_prev, dst);
+	xdst0->u.dst.path = dst;
 
 	err = -ENODEV;
 	dev = dst->dev;
 	if (!dev)
 		goto free_dst;
 
-	xfrm_init_path((struct xfrm_dst *)dst0, dst, nfheader_len);
-	xfrm_init_pmtu(dst_prev);
-
-	for (dst_prev = dst0; dst_prev != dst; dst_prev = xfrm_dst_child(dst_prev)) {
-		struct xfrm_dst *xdst = (struct xfrm_dst *)dst_prev;
+	xfrm_init_path(xdst0, dst, nfheader_len);
+	xfrm_init_pmtu(&xdst_prev->u.dst);
 
-		err = xfrm_fill_dst(xdst, dev, fl);
+	for (xdst_prev = xdst0; xdst_prev != (struct xfrm_dst *)dst;
+	     xdst_prev = (struct xfrm_dst *) xfrm_dst_child(&xdst_prev->u.dst)) {
+		err = xfrm_fill_dst(xdst_prev, dev, fl);
 		if (err)
 			goto free_dst;
 
-		dst_prev->header_len = header_len;
-		dst_prev->trailer_len = trailer_len;
-		header_len -= xdst->u.dst.xfrm->props.header_len;
-		trailer_len -= xdst->u.dst.xfrm->props.trailer_len;
+		xdst_prev->u.dst.header_len = header_len;
+		xdst_prev->u.dst.trailer_len = trailer_len;
+		header_len -= xdst_prev->u.dst.xfrm->props.header_len;
+		trailer_len -= xdst_prev->u.dst.xfrm->props.trailer_len;
 	}
 
 out:
-	return dst0;
+	return &xdst0->u.dst;
 
 put_states:
 	for (; i < nx; i++)
 		xfrm_state_put(xfrm[i]);
 free_dst:
-	if (dst0)
-		dst_release_immediate(dst0);
-	dst0 = ERR_PTR(err);
+	if (xdst0)
+		dst_release_immediate(&xdst0->u.dst);
+	xdst0 = ERR_PTR(err);
 	goto out;
 }
 
@@ -2005,7 +2004,7 @@ static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
 	dst1->output = xdst_queue_output;
 
 	dst_hold(dst);
-	dst1->child = dst;
+	xfrm_dst_set_child(xdst, dst);
 	dst1->path = dst;
 
 	xfrm_init_path((struct xfrm_dst *)dst1, dst, 0);
-- 
2.13.6
