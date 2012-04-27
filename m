From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH RFC 1/2] netfilter: conntrack: remove RCU usage in conntrack notifier
Date: Fri, 27 Apr 2012 14:28:52 -0400
Message-ID: <1335551333-6103-1-git-send-email-bpoirier@suse.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mike Frysinger <vapier@gentoo.org>,
	Arun Sharma <asharma@fb.com>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think that the rcu usage in this code is pointless. It should either be
removed or, if it was intended to protect against something, it ought to make
that clear.

1) The code does not make use of the deferred deletion/wait for completion rcu
api (ie. synchronize_rcu(), call_rcu()).
2) It does not benefit from the barriers implied by the rcu primitives used.
The code deals with callback pointers. There's no need to order writes to the
function code (!) before writes to the function pointers here.
---
 include/net/netfilter/nf_conntrack_ecache.h |   20 +++------
 include/net/netns/conntrack.h               |    4 +-
 net/netfilter/nf_conntrack_ecache.c         |   58 +++++++-------------------
 3 files changed, 25 insertions(+), 57 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index a88fb69..ac5b8d2 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -99,14 +99,13 @@ nf_conntrack_eventmask_report(unsigned int eventmask,
 	struct nf_ct_event_notifier *notify;
 	struct nf_conntrack_ecache *e;
 
-	rcu_read_lock();
-	notify = rcu_dereference(net->ct.nf_conntrack_event_cb);
+	notify = net->ct.nf_conntrack_event_cb;
 	if (notify == NULL)
-		goto out_unlock;
+		return ret;
 
 	e = nf_ct_ecache_find(ct);
 	if (e == NULL)
-		goto out_unlock;
+		return ret;
 
 	if (nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct)) {
 		struct nf_ct_event item = {
@@ -118,7 +117,7 @@ nf_conntrack_eventmask_report(unsigned int eventmask,
 		unsigned long missed = e->pid ? 0 : e->missed;
 
 		if (!((eventmask | missed) & e->ctmask))
-			goto out_unlock;
+			return ret;
 
 		ret = notify->fcn(eventmask | missed, &item);
 		if (unlikely(ret < 0 || missed)) {
@@ -137,8 +136,6 @@ nf_conntrack_eventmask_report(unsigned int eventmask,
 			spin_unlock_bh(&ct->lock);
 		}
 	}
-out_unlock:
-	rcu_read_unlock();
 	return ret;
 }
 
@@ -178,14 +175,13 @@ nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
 	struct nf_exp_event_notifier *notify;
 	struct nf_conntrack_ecache *e;
 
-	rcu_read_lock();
-	notify = rcu_dereference(net->ct.nf_expect_event_cb);
+	notify = net->ct.nf_expect_event_cb;
 	if (notify == NULL)
-		goto out_unlock;
+		return;
 
 	e = nf_ct_ecache_find(exp->master);
 	if (e == NULL)
-		goto out_unlock;
+		return;
 
 	if (e->expmask & (1 << event)) {
 		struct nf_exp_event item = {
@@ -195,8 +191,6 @@ nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
 		};
 		notify->fcn(1 << event, &item);
 	}
-out_unlock:
-	rcu_read_unlock();
 }
 
 static inline void
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 7a911ec..c96fd8c 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -18,8 +18,8 @@ struct netns_ct {
 	struct hlist_nulls_head	unconfirmed;
 	struct hlist_nulls_head	dying;
 	struct ip_conntrack_stat __percpu *stat;
-	struct nf_ct_event_notifier __rcu *nf_conntrack_event_cb;
-	struct nf_exp_event_notifier __rcu *nf_expect_event_cb;
+	struct nf_ct_event_notifier *nf_conntrack_event_cb;
+	struct nf_exp_event_notifier *nf_expect_event_cb;
 	int			sysctl_events;
 	unsigned int		sysctl_events_retry_timeout;
 	int			sysctl_acct;
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index b924f3a..0134009 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -38,19 +38,18 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 	struct nf_ct_event item;
 	int ret;
 
-	rcu_read_lock();
-	notify = rcu_dereference(net->ct.nf_conntrack_event_cb);
+	notify = net->ct.nf_conntrack_event_cb;
 	if (notify == NULL)
-		goto out_unlock;
+		return;
 
 	e = nf_ct_ecache_find(ct);
 	if (e == NULL)
-		goto out_unlock;
+		return;
 
 	events = xchg(&e->cache, 0);
 
 	if (!nf_ct_is_confirmed(ct) || nf_ct_is_dying(ct) || !events)
-		goto out_unlock;
+		return;
 
 	/* We make a copy of the missed event cache without taking
 	 * the lock, thus we may send missed events twice. However,
@@ -58,7 +57,7 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 	missed = e->missed;
 
 	if (!((events | missed) & e->ctmask))
-		goto out_unlock;
+		return;
 
 	item.ct = ct;
 	item.pid = 0;
@@ -67,7 +66,7 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 	ret = notify->fcn(events | missed, &item);
 
 	if (likely(ret >= 0 && !missed))
-		goto out_unlock;
+		return;
 
 	spin_lock_bh(&ct->lock);
 	if (ret < 0)
@@ -75,9 +74,6 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 	else
 		e->missed &= ~missed;
 	spin_unlock_bh(&ct->lock);
-
-out_unlock:
-	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 
@@ -85,21 +81,14 @@ int nf_conntrack_register_notifier(struct net *net,
 				   struct nf_ct_event_notifier *new)
 {
 	int ret = 0;
-	struct nf_ct_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
-	notify = rcu_dereference_protected(net->ct.nf_conntrack_event_cb,
-					   lockdep_is_held(&nf_ct_ecache_mutex));
-	if (notify != NULL) {
+	if (net->ct.nf_conntrack_event_cb != NULL)
 		ret = -EBUSY;
-		goto out_unlock;
-	}
-	rcu_assign_pointer(net->ct.nf_conntrack_event_cb, new);
+	else
+		net->ct.nf_conntrack_event_cb = new;
 	mutex_unlock(&nf_ct_ecache_mutex);
-	return ret;
 
-out_unlock:
-	mutex_unlock(&nf_ct_ecache_mutex);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_register_notifier);
@@ -107,13 +96,9 @@ EXPORT_SYMBOL_GPL(nf_conntrack_register_notifier);
 void nf_conntrack_unregister_notifier(struct net *net,
 				      struct nf_ct_event_notifier *new)
 {
-	struct nf_ct_event_notifier *notify;
-
 	mutex_lock(&nf_ct_ecache_mutex);
-	notify = rcu_dereference_protected(net->ct.nf_conntrack_event_cb,
-					   lockdep_is_held(&nf_ct_ecache_mutex));
-	BUG_ON(notify != new);
-	RCU_INIT_POINTER(net->ct.nf_conntrack_event_cb, NULL);
+	BUG_ON(net->ct.nf_conntrack_event_cb != new);
+	net->ct.nf_conntrack_event_cb = NULL;
 	mutex_unlock(&nf_ct_ecache_mutex);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_unregister_notifier);
@@ -122,21 +107,14 @@ int nf_ct_expect_register_notifier(struct net *net,
 				   struct nf_exp_event_notifier *new)
 {
 	int ret = 0;
-	struct nf_exp_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
-	notify = rcu_dereference_protected(net->ct.nf_expect_event_cb,
-					   lockdep_is_held(&nf_ct_ecache_mutex));
-	if (notify != NULL) {
+	if (net->ct.nf_expect_event_cb != NULL)
 		ret = -EBUSY;
-		goto out_unlock;
-	}
-	rcu_assign_pointer(net->ct.nf_expect_event_cb, new);
+	else
+		net->ct.nf_expect_event_cb = new;
 	mutex_unlock(&nf_ct_ecache_mutex);
-	return ret;
 
-out_unlock:
-	mutex_unlock(&nf_ct_ecache_mutex);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_register_notifier);
@@ -144,13 +122,9 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_register_notifier);
 void nf_ct_expect_unregister_notifier(struct net *net,
 				      struct nf_exp_event_notifier *new)
 {
-	struct nf_exp_event_notifier *notify;
-
 	mutex_lock(&nf_ct_ecache_mutex);
-	notify = rcu_dereference_protected(net->ct.nf_expect_event_cb,
-					   lockdep_is_held(&nf_ct_ecache_mutex));
-	BUG_ON(notify != new);
-	RCU_INIT_POINTER(net->ct.nf_expect_event_cb, NULL);
+	BUG_ON(net->ct.nf_expect_event_cb != new);
+	net->ct.nf_expect_event_cb = NULL;
 	mutex_unlock(&nf_ct_ecache_mutex);
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_unregister_notifier);
-- 
1.7.7

