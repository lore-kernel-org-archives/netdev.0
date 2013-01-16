From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 2/2] xfrm: replace rwlock on xfrm_km_list with rcu
Date: Wed, 16 Jan 2013 16:05:06 +0800
Message-ID: <1358323506-19571-2-git-send-email-amwang@redhat.com>
References: <1358323506-19571-1-git-send-email-amwang@redhat.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587Ab3APIF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 03:05:57 -0500
In-Reply-To: <1358323506-19571-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>


Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/xfrm/xfrm_state.c |   58 +++++++++++++++++++++++++-----------------------
 1 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f567716..b40baf7 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1647,27 +1647,26 @@ static void xfrm_replay_timer_handler(unsigned long data)
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
@@ -1697,13 +1696,13 @@ int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
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
@@ -1713,14 +1712,14 @@ int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, __be16 sport)
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
@@ -1749,15 +1748,15 @@ int km_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
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
@@ -1769,15 +1768,15 @@ int km_report(struct net *net, u8 proto, struct xfrm_selector *sel, xfrm_address
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
@@ -1801,14 +1800,14 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
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
@@ -1822,20 +1821,23 @@ out:
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
1.7.7.6
