From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH ipsec] xfrm: release dst_orig in case of error in xfrm_lookup()
Date: Wed, 11 Feb 2015 18:10:36 +0100
Message-ID: <1423674636-4227-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, huaibin Wang <huaibin.wang@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56931 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbbBKRKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 12:10:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: huaibin Wang <huaibin.wang@6wind.com>

dst_orig should be released on error. Function like __xfrm_route_forward()
expects that behavior.
Since a recent commit, xfrm_lookup() may also be called by xfrm_lookup_route(),
which expects the opposite.
Let's introduce a new flag (XFRM_LOOKUP_KEEP_DST_REF) to tell what should be
done in case of error.

Fixes: f92ee61982d("xfrm: Generate blackhole routes only from route lookup functions")
Signed-off-by: huaibin Wang <huaibin.wang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/dst.h      |  1 +
 net/xfrm/xfrm_policy.c | 12 ++++++------
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index a8ae4e760778..0fb99a26e973 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -481,6 +481,7 @@ void dst_init(void);
 enum {
 	XFRM_LOOKUP_ICMP = 1 << 0,
 	XFRM_LOOKUP_QUEUE = 1 << 1,
+	XFRM_LOOKUP_KEEP_DST_REF = 1 << 2,
 };
 
 struct flowi;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cee479bc655c..638af0655aaf 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2269,11 +2269,9 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 		 * have the xfrm_state's. We need to wait for KM to
 		 * negotiate new SA's or bail out with error.*/
 		if (net->xfrm.sysctl_larval_drop) {
-			dst_release(dst);
-			xfrm_pols_put(pols, drop_pols);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
-
-			return ERR_PTR(-EREMOTE);
+			err = -EREMOTE;
+			goto error;
 		}
 
 		err = -EAGAIN;
@@ -2324,7 +2322,8 @@ nopol:
 error:
 	dst_release(dst);
 dropdst:
-	dst_release(dst_orig);
+	if (!(flags & XFRM_LOOKUP_KEEP_DST_REF))
+		dst_release(dst_orig);
 	xfrm_pols_put(pols, drop_pols);
 	return ERR_PTR(err);
 }
@@ -2338,7 +2337,8 @@ struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
 				    struct sock *sk, int flags)
 {
 	struct dst_entry *dst = xfrm_lookup(net, dst_orig, fl, sk,
-					    flags | XFRM_LOOKUP_QUEUE);
+					    flags | XFRM_LOOKUP_QUEUE |
+					    XFRM_LOOKUP_KEEP_DST_REF);
 
 	if (IS_ERR(dst) && PTR_ERR(dst) == -EREMOTE)
 		return make_blackhole(net, dst_orig->ops->family, dst_orig);
-- 
2.2.2
