From: pablo@netfilter.org
Subject: [PATCH 12/23] netfilter: nf_ct_ecache: refactor nf_ct_deliver_cached_events
Date: Thu,  8 Mar 2012 02:01:01 +0100
Message-ID: <1331168472-5820-13-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tony Zelenoff <antonz@parallels.com>

* identation lowered
* some CPU cycles saved at delayed item variable initialization

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_ecache.c |   55 ++++++++++++++++++----------------
 1 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index aa15977..5bd3047d 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -32,9 +32,11 @@ static DEFINE_MUTEX(nf_ct_ecache_mutex);
 void nf_ct_deliver_cached_events(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
-	unsigned long events;
+	unsigned long events, missed;
 	struct nf_ct_event_notifier *notify;
 	struct nf_conntrack_ecache *e;
+	struct nf_ct_event item;
+	int ret;
 
 	rcu_read_lock();
 	notify = rcu_dereference(net->ct.nf_conntrack_event_cb);
@@ -47,31 +49,32 @@ void nf_ct_deliver_cached_events(struct nf_conn *ct)
 
 	events = xchg(&e->cache, 0);
 
-	if (nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct) && events) {
-		struct nf_ct_event item = {
-			.ct	= ct,
-			.pid	= 0,
-			.report	= 0
-		};
-		int ret;
-		/* We make a copy of the missed event cache without taking
-		 * the lock, thus we may send missed events twice. However,
-		 * this does not harm and it happens very rarely. */
-		unsigned long missed = e->missed;
-
-		if (!((events | missed) & e->ctmask))
-			goto out_unlock;
-
-		ret = notify->fcn(events | missed, &item);
-		if (unlikely(ret < 0 || missed)) {
-			spin_lock_bh(&ct->lock);
-			if (ret < 0)
-				e->missed |= events;
-			else
-				e->missed &= ~missed;
-			spin_unlock_bh(&ct->lock);
-		}
-	}
+	if (!nf_ct_is_confirmed(ct) || nf_ct_is_dying(ct) || !events)
+		goto out_unlock;
+
+	/* We make a copy of the missed event cache without taking
+	 * the lock, thus we may send missed events twice. However,
+	 * this does not harm and it happens very rarely. */
+	missed = e->missed;
+
+	if (!((events | missed) & e->ctmask))
+		goto out_unlock;
+
+	item.ct = ct;
+	item.pid = 0;
+	item.report = 0;
+
+	ret = notify->fcn(events | missed, &item);
+
+	if (likely(ret >= 0 && !missed))
+		goto out_unlock;
+
+	spin_lock_bh(&ct->lock);
+	if (ret < 0)
+		e->missed |= events;
+	else
+		e->missed &= ~missed;
+	spin_unlock_bh(&ct->lock);
 
 out_unlock:
 	rcu_read_unlock();
-- 
1.7.7.3

