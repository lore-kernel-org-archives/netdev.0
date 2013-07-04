From: Fan Du <fan.du@windriver.com>
Subject: [PATCH] xfrm: replace xfrm_policy_afinfo_lock spinlock with mutex
Date: Thu, 4 Jul 2013 14:53:47 +0800
Message-ID: <1372920827-4144-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <herbert@gondor.hengli.com.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:41135 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621Ab3GDGyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 02:54:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_policy.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e52cab3..27768ba 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -46,7 +46,7 @@ static DEFINE_SPINLOCK(xfrm_policy_sk_bundle_lock);
 static struct dst_entry *xfrm_policy_sk_bundles;
 static DEFINE_RWLOCK(xfrm_policy_lock);
 
-static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
+static DEFINE_MUTEX(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
 						__read_mostly;
 
@@ -2687,7 +2687,7 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 		return -EINVAL;
 	if (unlikely(afinfo->family >= NPROTO))
 		return -EAFNOSUPPORT;
-	spin_lock(&xfrm_policy_afinfo_lock);
+	mutex_lock(&xfrm_policy_afinfo_lock);
 	if (unlikely(xfrm_policy_afinfo[afinfo->family] != NULL))
 		err = -ENOBUFS;
 	else {
@@ -2710,7 +2710,7 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			afinfo->garbage_collect = xfrm_garbage_collect_deferred;
 		rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family], afinfo);
 	}
-	spin_unlock(&xfrm_policy_afinfo_lock);
+	mutex_unlock(&xfrm_policy_afinfo_lock);
 
 	rtnl_lock();
 	for_each_net(net) {
@@ -2743,7 +2743,7 @@ int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 		return -EINVAL;
 	if (unlikely(afinfo->family >= NPROTO))
 		return -EAFNOSUPPORT;
-	spin_lock(&xfrm_policy_afinfo_lock);
+	mutex_lock(&xfrm_policy_afinfo_lock);
 	if (likely(xfrm_policy_afinfo[afinfo->family] != NULL)) {
 		if (unlikely(xfrm_policy_afinfo[afinfo->family] != afinfo))
 			err = -EINVAL;
@@ -2751,7 +2751,7 @@ int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 			RCU_INIT_POINTER(xfrm_policy_afinfo[afinfo->family],
 					 NULL);
 	}
-	spin_unlock(&xfrm_policy_afinfo_lock);
+	mutex_unlock(&xfrm_policy_afinfo_lock);
 	if (!err) {
 		struct dst_ops *dst_ops = afinfo->dst_ops;
 
-- 
1.7.1
