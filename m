From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 21/53] netns xfrm: per-netns policy hash resizing work
Date: Tue, 25 Nov 2008 20:26:53 +0300
Message-ID: <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
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
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:4839 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbYKYRY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:26 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28104nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:25 -0800 (PST)
In-Reply-To: <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_policy.c   |   52 +++++++++++++++++++++++-----------------------
 2 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index d5aadf0..c53d173 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -38,6 +38,7 @@ struct netns_xfrm {
 	struct hlist_head	policy_inexact[XFRM_POLICY_MAX * 2];
 	struct xfrm_policy_hash	policy_bydst[XFRM_POLICY_MAX * 2];
 	unsigned int		policy_count[XFRM_POLICY_MAX * 2];
+	struct work_struct	policy_hash_work;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 630ec04..1d30086 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -396,12 +396,12 @@ static unsigned long xfrm_new_hash_mask(unsigned int old_hmask)
 	return ((old_hmask + 1) << 1) - 1;
 }
 
-static void xfrm_bydst_resize(int dir)
+static void xfrm_bydst_resize(struct net *net, int dir)
 {
-	unsigned int hmask = init_net.xfrm.policy_bydst[dir].hmask;
+	unsigned int hmask = net->xfrm.policy_bydst[dir].hmask;
 	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
 	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
-	struct hlist_head *odst = init_net.xfrm.policy_bydst[dir].table;
+	struct hlist_head *odst = net->xfrm.policy_bydst[dir].table;
 	struct hlist_head *ndst = xfrm_hash_alloc(nsize);
 	int i;
 
@@ -413,20 +413,20 @@ static void xfrm_bydst_resize(int dir)
 	for (i = hmask; i >= 0; i--)
 		xfrm_dst_hash_transfer(odst + i, ndst, nhashmask);
 
-	init_net.xfrm.policy_bydst[dir].table = ndst;
-	init_net.xfrm.policy_bydst[dir].hmask = nhashmask;
+	net->xfrm.policy_bydst[dir].table = ndst;
+	net->xfrm.policy_bydst[dir].hmask = nhashmask;
 
 	write_unlock_bh(&xfrm_policy_lock);
 
 	xfrm_hash_free(odst, (hmask + 1) * sizeof(struct hlist_head));
 }
 
-static void xfrm_byidx_resize(int total)
+static void xfrm_byidx_resize(struct net *net, int total)
 {
-	unsigned int hmask = init_net.xfrm.policy_idx_hmask;
+	unsigned int hmask = net->xfrm.policy_idx_hmask;
 	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
 	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
-	struct hlist_head *oidx = init_net.xfrm.policy_byidx;
+	struct hlist_head *oidx = net->xfrm.policy_byidx;
 	struct hlist_head *nidx = xfrm_hash_alloc(nsize);
 	int i;
 
@@ -438,18 +438,18 @@ static void xfrm_byidx_resize(int total)
 	for (i = hmask; i >= 0; i--)
 		xfrm_idx_hash_transfer(oidx + i, nidx, nhashmask);
 
-	init_net.xfrm.policy_byidx = nidx;
-	init_net.xfrm.policy_idx_hmask = nhashmask;
+	net->xfrm.policy_byidx = nidx;
+	net->xfrm.policy_idx_hmask = nhashmask;
 
 	write_unlock_bh(&xfrm_policy_lock);
 
 	xfrm_hash_free(oidx, (hmask + 1) * sizeof(struct hlist_head));
 }
 
-static inline int xfrm_bydst_should_resize(int dir, int *total)
+static inline int xfrm_bydst_should_resize(struct net *net, int dir, int *total)
 {
-	unsigned int cnt = init_net.xfrm.policy_count[dir];
-	unsigned int hmask = init_net.xfrm.policy_bydst[dir].hmask;
+	unsigned int cnt = net->xfrm.policy_count[dir];
+	unsigned int hmask = net->xfrm.policy_bydst[dir].hmask;
 
 	if (total)
 		*total += cnt;
@@ -461,9 +461,9 @@ static inline int xfrm_bydst_should_resize(int dir, int *total)
 	return 0;
 }
 
-static inline int xfrm_byidx_should_resize(int total)
+static inline int xfrm_byidx_should_resize(struct net *net, int total)
 {
-	unsigned int hmask = init_net.xfrm.policy_idx_hmask;
+	unsigned int hmask = net->xfrm.policy_idx_hmask;
 
 	if ((hmask + 1) < xfrm_policy_hashmax &&
 	    total > hmask)
@@ -488,25 +488,24 @@ void xfrm_spd_getinfo(struct xfrmk_spdinfo *si)
 EXPORT_SYMBOL(xfrm_spd_getinfo);
 
 static DEFINE_MUTEX(hash_resize_mutex);
-static void xfrm_hash_resize(struct work_struct *__unused)
+static void xfrm_hash_resize(struct work_struct *work)
 {
+	struct net *net = container_of(work, struct net, xfrm.policy_hash_work);
 	int dir, total;
 
 	mutex_lock(&hash_resize_mutex);
 
 	total = 0;
 	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
-		if (xfrm_bydst_should_resize(dir, &total))
-			xfrm_bydst_resize(dir);
+		if (xfrm_bydst_should_resize(net, dir, &total))
+			xfrm_bydst_resize(net, dir);
 	}
-	if (xfrm_byidx_should_resize(total))
-		xfrm_byidx_resize(total);
+	if (xfrm_byidx_should_resize(net, total))
+		xfrm_byidx_resize(net, total);
 
 	mutex_unlock(&hash_resize_mutex);
 }
 
-static DECLARE_WORK(xfrm_hash_work, xfrm_hash_resize);
-
 /* Generate new index... KAME seems to generate them ordered by cost
  * of an absolute inpredictability of ordering of rules. This will not pass. */
 static u32 xfrm_gen_index(int dir)
@@ -607,8 +606,8 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 
 	if (delpol)
 		xfrm_policy_kill(delpol);
-	else if (xfrm_bydst_should_resize(dir, NULL))
-		schedule_work(&xfrm_hash_work);
+	else if (xfrm_bydst_should_resize(&init_net, dir, NULL))
+		schedule_work(&init_net.xfrm.policy_hash_work);
 
 	read_lock_bh(&xfrm_policy_lock);
 	gc_list = NULL;
@@ -1079,8 +1078,8 @@ static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 	init_net.xfrm.policy_count[dir]++;
 	xfrm_pol_hold(pol);
 
-	if (xfrm_bydst_should_resize(dir, NULL))
-		schedule_work(&xfrm_hash_work);
+	if (xfrm_bydst_should_resize(&init_net, dir, NULL))
+		schedule_work(&init_net.xfrm.policy_hash_work);
 }
 
 static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
@@ -2415,6 +2414,7 @@ static int __net_init xfrm_policy_init(struct net *net)
 	}
 
 	INIT_LIST_HEAD(&net->xfrm.policy_all);
+	INIT_WORK(&net->xfrm.policy_hash_work, xfrm_hash_resize);
 	if (net_eq(net, &init_net))
 		register_netdevice_notifier(&xfrm_dev_notifier);
 	return 0;
-- 
1.5.6.5

