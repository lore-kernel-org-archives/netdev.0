From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 20/53] netns xfrm: per-netns policy counts
Date: Tue, 25 Nov 2008 20:26:52 +0300
Message-ID: <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:3932 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149AbYKYRYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:23 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28136nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:22 -0800 (PST)
In-Reply-To: <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    1 +
 include/net/xfrm.h       |    6 ++----
 net/xfrm/xfrm_policy.c   |   34 ++++++++++++++++------------------
 3 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 39cfa79..d5aadf0 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -37,6 +37,7 @@ struct netns_xfrm {
 	unsigned int		policy_idx_hmask;
 	struct hlist_head	policy_inexact[XFRM_POLICY_MAX * 2];
 	struct xfrm_policy_hash	policy_bydst[XFRM_POLICY_MAX * 2];
+	unsigned int		policy_count[XFRM_POLICY_MAX * 2];
 };
 
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1ab1756..8699620 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -559,8 +559,6 @@ struct xfrm_mgr
 extern int xfrm_register_km(struct xfrm_mgr *km);
 extern int xfrm_unregister_km(struct xfrm_mgr *km);
 
-extern unsigned int xfrm_policy_count[XFRM_POLICY_MAX*2];
-
 /*
  * This structure is used for the duration where packets are being
  * transformed by IPsec.  As soon as the packet leaves IPsec the
@@ -999,7 +997,7 @@ static inline int __xfrm_policy_check2(struct sock *sk, int dir,
 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
 		return __xfrm_policy_check(sk, ndir, skb, family);
 
-	return	(!xfrm_policy_count[dir] && !skb->sp) ||
+	return	(!init_net.xfrm.policy_count[dir] && !skb->sp) ||
 		(skb->dst->flags & DST_NOPOLICY) ||
 		__xfrm_policy_check(sk, ndir, skb, family);
 }
@@ -1051,7 +1049,7 @@ extern int __xfrm_route_forward(struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
-	return	!xfrm_policy_count[XFRM_POLICY_OUT] ||
+	return	!init_net.xfrm.policy_count[XFRM_POLICY_OUT] ||
 		(skb->dst->flags & DST_NOXFRM) ||
 		__xfrm_route_forward(skb, family);
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 929b2fd..630ec04 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -46,9 +46,6 @@ EXPORT_SYMBOL(xfrm_cfg_mutex);
 
 static DEFINE_RWLOCK(xfrm_policy_lock);
 
-unsigned int xfrm_policy_count[XFRM_POLICY_MAX*2];
-EXPORT_SYMBOL(xfrm_policy_count);
-
 static DEFINE_RWLOCK(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
 
@@ -451,7 +448,7 @@ static void xfrm_byidx_resize(int total)
 
 static inline int xfrm_bydst_should_resize(int dir, int *total)
 {
-	unsigned int cnt = xfrm_policy_count[dir];
+	unsigned int cnt = init_net.xfrm.policy_count[dir];
 	unsigned int hmask = init_net.xfrm.policy_bydst[dir].hmask;
 
 	if (total)
@@ -478,12 +475,12 @@ static inline int xfrm_byidx_should_resize(int total)
 void xfrm_spd_getinfo(struct xfrmk_spdinfo *si)
 {
 	read_lock_bh(&xfrm_policy_lock);
-	si->incnt = xfrm_policy_count[XFRM_POLICY_IN];
-	si->outcnt = xfrm_policy_count[XFRM_POLICY_OUT];
-	si->fwdcnt = xfrm_policy_count[XFRM_POLICY_FWD];
-	si->inscnt = xfrm_policy_count[XFRM_POLICY_IN+XFRM_POLICY_MAX];
-	si->outscnt = xfrm_policy_count[XFRM_POLICY_OUT+XFRM_POLICY_MAX];
-	si->fwdscnt = xfrm_policy_count[XFRM_POLICY_FWD+XFRM_POLICY_MAX];
+	si->incnt = init_net.xfrm.policy_count[XFRM_POLICY_IN];
+	si->outcnt = init_net.xfrm.policy_count[XFRM_POLICY_OUT];
+	si->fwdcnt = init_net.xfrm.policy_count[XFRM_POLICY_FWD];
+	si->inscnt = init_net.xfrm.policy_count[XFRM_POLICY_IN+XFRM_POLICY_MAX];
+	si->outscnt = init_net.xfrm.policy_count[XFRM_POLICY_OUT+XFRM_POLICY_MAX];
+	si->fwdscnt = init_net.xfrm.policy_count[XFRM_POLICY_FWD+XFRM_POLICY_MAX];
 	si->spdhcnt = init_net.xfrm.policy_idx_hmask;
 	si->spdhmcnt = xfrm_policy_hashmax;
 	read_unlock_bh(&xfrm_policy_lock);
@@ -591,13 +588,13 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	else
 		hlist_add_head(&policy->bydst, chain);
 	xfrm_pol_hold(policy);
-	xfrm_policy_count[dir]++;
+	init_net.xfrm.policy_count[dir]++;
 	atomic_inc(&flow_cache_genid);
 	if (delpol) {
 		hlist_del(&delpol->bydst);
 		hlist_del(&delpol->byidx);
 		list_del(&delpol->walk.all);
-		xfrm_policy_count[dir]--;
+		init_net.xfrm.policy_count[dir]--;
 	}
 	policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
 	hlist_add_head(&policy->byidx, init_net.xfrm.policy_byidx+idx_hash(policy->index));
@@ -673,7 +670,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
 				list_del(&pol->walk.all);
-				xfrm_policy_count[dir]--;
+				init_net.xfrm.policy_count[dir]--;
 			}
 			ret = pol;
 			break;
@@ -717,7 +714,7 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
 				hlist_del(&pol->bydst);
 				hlist_del(&pol->byidx);
 				list_del(&pol->walk.all);
-				xfrm_policy_count[dir]--;
+				init_net.xfrm.policy_count[dir]--;
 			}
 			ret = pol;
 			break;
@@ -845,7 +842,7 @@ int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info)
 			}
 		}
 
-		xfrm_policy_count[dir] -= killed;
+		init_net.xfrm.policy_count[dir] -= killed;
 	}
 	atomic_inc(&flow_cache_genid);
 out:
@@ -1079,7 +1076,7 @@ static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 	list_add(&pol->walk.all, &init_net.xfrm.policy_all);
 	hlist_add_head(&pol->bydst, chain);
 	hlist_add_head(&pol->byidx, init_net.xfrm.policy_byidx+idx_hash(pol->index));
-	xfrm_policy_count[dir]++;
+	init_net.xfrm.policy_count[dir]++;
 	xfrm_pol_hold(pol);
 
 	if (xfrm_bydst_should_resize(dir, NULL))
@@ -1095,7 +1092,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 	hlist_del(&pol->bydst);
 	hlist_del(&pol->byidx);
 	list_del(&pol->walk.all);
-	xfrm_policy_count[dir]--;
+	init_net.xfrm.policy_count[dir]--;
 
 	return pol;
 }
@@ -1574,7 +1571,7 @@ restart:
 	if (!policy) {
 		/* To accelerate a bit...  */
 		if ((dst_orig->flags & DST_NOXFRM) ||
-		    !xfrm_policy_count[XFRM_POLICY_OUT])
+		    !init_net.xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
 		policy = flow_cache_lookup(fl, dst_orig->ops->family,
@@ -2407,6 +2404,7 @@ static int __net_init xfrm_policy_init(struct net *net)
 	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
 		struct xfrm_policy_hash *htab;
 
+		net->xfrm.policy_count[dir] = 0;
 		INIT_HLIST_HEAD(&net->xfrm.policy_inexact[dir]);
 
 		htab = &net->xfrm.policy_bydst[dir];
-- 
1.5.6.5

