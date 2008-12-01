From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCHv3] xfrm: Fix kernel panic when flush and dump SPD entries
Date: Mon, 01 Dec 2008 14:27:53 +0800
Message-ID: <493383E9.50509@cn.fujitsu.com>
References: <49334542.3070502@cn.fujitsu.com> <49334788.4030409@cn.fujitsu.com> <20081201050046.GB18292@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59710 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbYLAG0o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 01:26:44 -0500
In-Reply-To: <20081201050046.GB18292@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After flush the SPD entries, dump the SPD entries will cause kernel painc.

Used the following commands to reproduct:

- echo 'spdflush;' | setkey -c
- echo 'spdadd 3ffe:501:ffff:ff01::/64 3ffe:501:ffff:ff04::/64  any -P out ipsec \
  ah/tunnel/3ffe:501:ffff:ff00:200:ff:fe00:b0b0-3ffe:501:ffff:ff02:200:ff:fe00:a1a1/require;\
  spddump;' | setkey -c
- echo 'spdflush; spddump;' | setkey -c
- echo 'spdadd 3ffe:501:ffff:ff01::/64 3ffe:501:ffff:ff04::/64  any -P out ipsec \
  ah/tunnel/3ffe:501:ffff:ff00:200:ff:fe00:b0b0-3ffe:501:ffff:ff02:200:ff:fe00:a1a1/require;\
  spddump;' | setkey -c

This is because when flush the SPD entries, the SPD entry is not remove
from the list.

This patch fix the problem by remove the SPD entry from the list. And
also do clean up of remove SPD entry.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/xfrm/xfrm_policy.c |   35 ++++++++++-------------------------
 1 files changed, 10 insertions(+), 25 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 058f04f..54e7efe 100644
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
@@ -807,16 +800,14 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
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
+			__xfrm_policy_unlink(pol, dir);
 			write_unlock_bh(&xfrm_policy_lock);
 
 			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
@@ -824,7 +815,6 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 						 audit_info->secid);
 
 			xfrm_policy_kill(pol);
-			killed++;
 
 			write_lock_bh(&xfrm_policy_lock);
 			goto again1;
@@ -837,9 +827,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 					     bydst) {
 				if (pol->type != type)
 					continue;
-				hlist_del(&pol->bydst);
-				hlist_del(&pol->byidx);
-				list_del(&pol->walk.all);
+				__xfrm_policy_unlink(pol, dir);
 				write_unlock_bh(&xfrm_policy_lock);
 
 				xfrm_audit_policy_delete(pol, 1,
@@ -847,14 +835,11 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
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



