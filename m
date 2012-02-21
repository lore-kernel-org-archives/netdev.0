From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH rhel6 3/3] net/netfilter: refactor nf_ct_deliver_cached_events
Date: Tue, 21 Feb 2012 21:26:31 +0400
Message-ID: <1329845191-484662-4-git-send-email-antonz@parallels.com>
References: <1329845191-484662-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:55557 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654Ab2BUR0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:26:35 -0500
In-Reply-To: <1329845191-484662-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* identation lowered
* some CPU cycles saved at delayed item variable initialization

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 net/netfilter/nf_conntrack_ecache.c |   55 ++++++++++++++++++----------------
 1 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 9b8e986..577a0e8 100644
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
1.7.1
