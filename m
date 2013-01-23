From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/8] xfrm: replace rwlock on xfrm_km_list with rcu
Date: Wed, 23 Jan 2013 09:19:02 +0100
Message-ID: <1358929144-17806-7-git-send-email-steffen.klassert@secunet.com>
References: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50742 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098Ab3AWITf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 03:19:35 -0500
In-Reply-To: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |   58 +++++++++++++++++++++++++------------------------
 1 file changed, 30 insertions(+), 28 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 64780a6..1522f19 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1644,27 +1644,26 @@ static void xfrm_replay_timer_handler(unsigned long data)
 }
 
 static LIST_HEAD(xfrm_km_list);
-static DEFINE_RWLOCK(xfrm_km_lock);
 
 void km_policy_notify(struct xfrm_policy *xp, int dir, const struct km_event *c)
 {
 	struct xfrm_mgr *km;
 
-	read_lock(&xfrm_km_lock);
-	list_for_each_entry(km, &xfrm_km_list, list)
+	rcu_read_lock();
+	list_for_each_entry_rcu(km, &xfrm_km_list, list)
 		if (km->notify_policy)
 			km->notify_policy(xp, dir, c);
-	read_unlock(&xfrm_km_lock);
+	rcu_read_unlock();
 }
 
 void km_state_notify(struct xfrm_state *x, const struct km_event *c)
 {
 	struct xfrm_mgr *km;
-	read_lock(&xfrm_km_lock);
-	list_for_each_entry(km, &xfrm_km_list, list)
+	rcu_read_lock();
+	list_for_each_entry_rcu(km, &xfrm_km_list, list)
 		if (km->notify)
 			km->notify(x, c);
-	read_unlock(&xfrm_km_lock);
+	rcu_read_unlock();
 }
 
 EXPORT_SYMBOL(km_policy_notify);
@@ -1694,13 +1693,13 @@ int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
 	int err = -EINVAL, acqret;
 	struct xfrm_mgr *km;
 
-	read_lock(&xfrm_km_lock);
-	list_for_each_entry(km, &xfrm_km_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
 		acqret = km->acquire(x, t, pol);
 		if (!acqret)
 			err = acqret;
 	}
-	read_unlock(&xfrm_km_lock);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(km_query);
@@ -1710,14 +1709,14 @@ int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport)
 	int err = -EINVAL;
 	struct xfrm_mgr *km;
 
-	read_lock(&xfrm_km_lock);
-	list_for_each_entry(km, &xfrm_km_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
 		if (km->new_mapping)
 			err = km->new_mapping(x, ipaddr, sport);
 		if (!err)
 			break;
 	}
-	read_unlock(&xfrm_km_lock);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(km_new_mapping);
@@ -1746,15 +1745,15 @@ int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	int ret;
 	struct xfrm_mgr *km;
 
-	read_lock(&xfrm_km_lock);
-	list_for_each_entry(km, &xfrm_km_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
 		if (km->migrate) {
 			ret = km->migrate(sel, dir, type, m, num_migrate, k);
 			if (!ret)
 				err = ret;
 		}
 	}
-	read_unlock(&xfrm_km_lock);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(km_migrate);
@@ -1766,15 +1765,15 @@ int km_report(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address
 	int ret;
 	struct xfrm_mgr *km;
 
-	read_lock(&xfrm_km_lock);
-	list_for_each_entry(km, &xfrm_km_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
 		if (km->report) {
 			ret = km->report(net, proto, sel, addr);
 			if (!ret)
 				err = ret;
 		}
 	}
-	read_unlock(&xfrm_km_lock);
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(km_report);
@@ -1798,14 +1797,14 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
 		goto out;
 
 	err = -EINVAL;
-	read_lock(&xfrm_km_lock);
-	list_for_each_entry(km, &xfrm_km_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(km, &xfrm_km_list, list) {
 		pol = km->compile_policy(sk, optname, data,
 					 optlen, &err);
 		if (err >= 0)
 			break;
 	}
-	read_unlock(&xfrm_km_lock);
+	rcu_read_unlock();
 
 	if (err >= 0) {
 		xfrm_sk_policy_insert(sk, err, pol);
@@ -1819,20 +1818,23 @@ out:
 }
 EXPORT_SYMBOL(xfrm_user_policy);
 
+static DEFINE_SPINLOCK(xfrm_km_lock);
+
 int xfrm_register_km(struct xfrm_mgr *km)
 {
-	write_lock_bh(&xfrm_km_lock);
-	list_add_tail(&km->list, &xfrm_km_list);
-	write_unlock_bh(&xfrm_km_lock);
+	spin_lock_bh(&xfrm_km_lock);
+	list_add_tail_rcu(&km->list, &xfrm_km_list);
+	spin_unlock_bh(&xfrm_km_lock);
 	return 0;
 }
 EXPORT_SYMBOL(xfrm_register_km);
 
 int xfrm_unregister_km(struct xfrm_mgr *km)
 {
-	write_lock_bh(&xfrm_km_lock);
-	list_del(&km->list);
-	write_unlock_bh(&xfrm_km_lock);
+	spin_lock_bh(&xfrm_km_lock);
+	list_del_rcu(&km->list);
+	spin_unlock_bh(&xfrm_km_lock);
+	synchronize_rcu();
 	return 0;
 }
 EXPORT_SYMBOL(xfrm_unregister_km);
-- 
1.7.9.5
