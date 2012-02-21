From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH rhel6 2/3] net/netfilter: refactor notifier registration
Date: Tue, 21 Feb 2012 21:26:30 +0400
Message-ID: <1329845191-484662-3-git-send-email-antonz@parallels.com>
References: <1329845191-484662-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:55555 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653Ab2BUR0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:26:35 -0500
In-Reply-To: <1329845191-484662-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* ret variable initialization removed as useless
* Similar code strings concatenated and functions code
  flow became more plain

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 net/netfilter/nf_conntrack_ecache.c |   26 ++++++++++----------------
 1 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index aa15977..9b8e986 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -81,21 +81,18 @@ EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 int nf_conntrack_register_notifier(struct net *net,
 				   struct nf_ct_event_notifier *new)
 {
-	int ret = 0;
+	int ret;
 	struct nf_ct_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
 	notify = rcu_dereference_protected(net->ct.nf_conntrack_event_cb,
 					   lockdep_is_held(&nf_ct_ecache_mutex));
-	if (notify != NULL) {
+	if (likely(!notify)) {
+		rcu_assign_pointer(net->ct.nf_conntrack_event_cb, new);
+		ret = 0;
+	} else
 		ret = -EBUSY;
-		goto out_unlock;
-	}
-	rcu_assign_pointer(net->ct.nf_conntrack_event_cb, new);
-	mutex_unlock(&nf_ct_ecache_mutex);
-	return ret;
 
-out_unlock:
 	mutex_unlock(&nf_ct_ecache_mutex);
 	return ret;
 }
@@ -118,21 +115,18 @@ EXPORT_SYMBOL_GPL(nf_conntrack_unregister_notifier);
 int nf_ct_expect_register_notifier(struct net *net,
 				   struct nf_exp_event_notifier *new)
 {
-	int ret = 0;
+	int ret;
 	struct nf_exp_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
 	notify = rcu_dereference_protected(net->ct.nf_expect_event_cb,
 					   lockdep_is_held(&nf_ct_ecache_mutex));
-	if (notify != NULL) {
+	if (likely(!notify)) {
+		rcu_assign_pointer(net->ct.nf_expect_event_cb, new);
+		ret = 0;
+	} else
 		ret = -EBUSY;
-		goto out_unlock;
-	}
-	rcu_assign_pointer(net->ct.nf_expect_event_cb, new);
-	mutex_unlock(&nf_ct_ecache_mutex);
-	return ret;
 
-out_unlock:
 	mutex_unlock(&nf_ct_ecache_mutex);
 	return ret;
 }
-- 
1.7.1
