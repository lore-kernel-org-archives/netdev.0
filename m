From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH 1/2] xfrm: Cleanup for unlink SPD entry
Date: Mon, 01 Dec 2008 17:55:20 +0800
Message-ID: <4933B488.3000406@cn.fujitsu.com>
References: <493383E9.50509@cn.fujitsu.com>	<4933975E.3030503@cn.fujitsu.com>	<20081201081111.GA19615@gondor.apana.org.au> <20081201.003821.42061993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59087 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbYLAJyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 04:54:11 -0500
In-Reply-To: <20081201.003821.42061993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Used __xfrm_policy_unlink() to instead of the dup codes when unlink
SPD entry.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/xfrm/xfrm_policy.c |   36 ++++++++++--------------------------
 1 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index fb216c9..0de2e1f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -63,6 +63,9 @@ static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 static void xfrm_init_pmtu(struct dst_entry *dst);
 
+static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
+						int dir);
+
 static inline int
 __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 {
@@ -602,12 +605,8 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	xfrm_pol_hold(policy);
 	xfrm_policy_count[dir]++;
 	atomic_inc(&flow_cache_genid);
-	if (delpol) {
-		hlist_del(&delpol->bydst);
-		hlist_del(&delpol->byidx);
-		list_del(&delpol->walk.all);
-		xfrm_policy_count[dir]--;
-	}
+	if (delpol)
+		__xfrm_policy_unlink(delpol, dir);
 	policy->index = delpol ? delpol->index : xfrm_gen_index(policy->type, dir);
 	hlist_add_head(&policy->byidx, xfrm_policy_byidx+idx_hash(policy->index));
 	policy->curlft.add_time = get_seconds();
@@ -679,10 +678,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 					write_unlock_bh(&xfrm_policy_lock);
 					return pol;
 				}
-				hlist_del(&pol->bydst);
-				hlist_del(&pol->byidx);
-				list_del(&pol->walk.all);
-				xfrm_policy_count[dir]--;
+				__xfrm_policy_unlink(pol, dir);
 			}
 			ret = pol;
 			break;
@@ -723,10 +719,7 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
 					write_unlock_bh(&xfrm_policy_lock);
 					return pol;
 				}
-				hlist_del(&pol->bydst);
-				hlist_del(&pol->byidx);
-				list_del(&pol->walk.all);
-				xfrm_policy_count[dir]--;
+				__xfrm_policy_unlink(pol, dir);
 			}
 			ret = pol;
 			break;
@@ -807,17 +800,14 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 	for (dir = 0; dir < XFRM_POLICY_MAX; dir++) {
 		struct xfrm_policy *pol;
 		struct hlist_node *entry;
-		int i, killed;
+		int i;
 
-		killed = 0;
 	again1:
 		hlist_for_each_entry(pol, entry,
 				     &xfrm_policy_inexact[dir], bydst) {
 			if (pol->type != type)
 				continue;
-			hlist_del(&pol->bydst);
-			hlist_del(&pol->byidx);
-			list_del(&pol->walk.all);
+			__xfrm_policy_unlink(pol, dir);
 			write_unlock_bh(&xfrm_policy_lock);
 
 			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
@@ -825,7 +815,6 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 						 audit_info->secid);
 
 			xfrm_policy_kill(pol);
-			killed++;
 
 			write_lock_bh(&xfrm_policy_lock);
 			goto again1;
@@ -838,9 +827,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 					     bydst) {
 				if (pol->type != type)
 					continue;
-				hlist_del(&pol->bydst);
-				hlist_del(&pol->byidx);
-				list_del(&pol->walk.all);
+				__xfrm_policy_unlink(pol, dir);
 				write_unlock_bh(&xfrm_policy_lock);
 
 				xfrm_audit_policy_delete(pol, 1,
@@ -848,14 +835,11 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 							 audit_info->sessionid,
 							 audit_info->secid);
 				xfrm_policy_kill(pol);
-				killed++;
 
 				write_lock_bh(&xfrm_policy_lock);
 				goto again2;
 			}
 		}
-
-		xfrm_policy_count[dir] -= killed;
 	}
 	atomic_inc(&flow_cache_genid);
 out:
-- 
1.6.0.2.530.g67faa



